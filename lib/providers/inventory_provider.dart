// 📄 lib/providers/inventory_provider.dart
//
// Provider לניהול מזווה - אישי (לפי household).
// CRUD מלא, פילטרים, וניהול מלאי.
//
// 🔗 Related: InventoryItem, InventoryRepository, UserContext

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/constants.dart';
import '../l10n/app_strings.dart';
import '../models/enums/item_type.dart';
import '../models/inventory_item.dart';
import '../models/unified_list_item.dart';
import '../repositories/inventory_repository.dart';
import 'user_context.dart';

/// מיקום המזווה הנוכחי
enum InventoryMode {
  /// מזווה אישי - /users/{userId}/inventory
  personal,
  /// מזווה משותף - /households/{householdId}/inventory (real-time)
  household,
}

class InventoryProvider with ChangeNotifier {
  final InventoryRepository _repository;
  UserContext? _userContext;
  bool _listeningToUser = false;
  bool _hasInitialized = false; // מניעת אתחול כפול

  // 🔒 דגל לבדיקה אם ה-provider כבר disposed
  bool _isDisposed = false;

  bool _isLoading = false;
  String? _errorMessage;
  List<InventoryItem> _items = [];

  // מצב מזווה נוכחי
  InventoryMode _currentMode = InventoryMode.personal;

  static const Uuid _uuid = Uuid();
  Future<void>? _loadingFuture; // מניעת טעינות כפולות
  int _loadGeneration = 0; // זיהוי גרסת טעינה - לביטול טעינות ישנות
  StreamSubscription<List<InventoryItem>>? _inventorySubscription;
  String? _subscribedHouseholdId; // track current subscription

  // === Safe Notification ===

  /// 🔒 קורא ל-notifyListeners() רק אם ה-provider לא disposed
  void _notifySafe() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// 🔒 מריץ פעולה async עם טיפול בשגיאות ובדיקת dispose
  ///
  /// **Parameters:**
  /// - [operation]: שם הפעולה (לצורכי logging)
  /// - [action]: הפעולה ה-async לביצוע
  /// - [setLoading]: האם לעדכן את _isLoading (ברירת מחדל: true)
  /// - [rethrowError]: האם לזרוק מחדש שגיאות (ברירת מחדל: true)
  /// - [errorMessagePrefix]: prefix להודעת שגיאה
  ///
  /// **Returns:** הערך שהוחזר מה-action, או null אם נכשל
  Future<T?> _runAsync<T>({
    required String operation,
    required Future<T> Function() action,
    bool setLoading = true,
    bool rethrowError = true,
    String? errorMessagePrefix,
  }) async {
    if (_isDisposed) {
      return null;
    }

    if (setLoading) {
      _isLoading = true;
      _errorMessage = null;
      _notifySafe();
    }

    try {
      final result = await action();
      _errorMessage = null;
      return result;
    } catch (e) {
      _errorMessage = errorMessagePrefix != null
          ? '$errorMessagePrefix: ${e.toString()}'
          : e.toString();
      if (rethrowError) rethrow;
      return null;
    } finally {
      if (setLoading) {
        _isLoading = false;
      }
      _notifySafe();
    }
  }

  // === Validation Helpers ===

  /// בודק אם שם מוצר תקין (לא ריק)
  bool _isValidProductName(String? name) =>
      name != null && name.trim().isNotEmpty;

  /// בודק אם ID תקין (לא ריק)
  bool _isValidId(String? id) =>
      id != null && id.trim().isNotEmpty;

  /// בודק אם כמות תקינה (חיובית)
  bool _isValidQuantity(int? qty) =>
      qty != null && qty > 0;

  InventoryProvider({
    required InventoryRepository repository,
    required UserContext userContext,
  }) : _repository = repository {
    updateUserContext(userContext);
  }

  // === Getters ===
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _items.isEmpty;
  List<InventoryItem> get items => List.unmodifiable(_items);

  /// מצב המזווה הנוכחי (אישי)
  InventoryMode get currentMode => _currentMode;

  /// שם המזווה להצגה
  String get inventoryTitle => 'המזווה שלי';

  // === חיבור UserContext ===

  /// מעדכן את ה-UserContext ומאזין לשינויים
  /// נקרא אוטומטית מ-ProxyProvider
  /// 🔧 משתמש ב-microtask כדי למנוע notifyListeners בזמן build
  void updateUserContext(UserContext newContext) {
    // מניעת update כפול של אותו context
    if (_userContext == newContext) {
      return;
    }

    if (_listeningToUser && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
      _listeningToUser = false;
    }
    _userContext = newContext;
    _userContext!.addListener(_onUserChanged);
    _listeningToUser = true;

    // אתחול רק בפעם הראשונה
    // ⚠️ חובה microtask! אחרת notifyListeners נקרא בזמן build (ProxyProvider)
    if (!_hasInitialized) {
      _hasInitialized = true;
      Future.microtask(_initialize);
    }
  }

  void _onUserChanged() {
    _updateInventoryLocation();
  }

  void _initialize() {
    _updateInventoryLocation();
  }

  /// מזהה את מיקום המזווה הנכון וטוען את הפריטים
  void _updateInventoryLocation() {
    final userId = _userContext?.userId;
    if (userId == null || _userContext?.isLoggedIn != true) {
      // 🔧 Logout/no user: איפוס מלא של state
      _currentMode = InventoryMode.personal;
      _items = [];
      _isLoading = false;
      _errorMessage = null;
      _loadingFuture = null;
      // ⚠️ העלאת דור כדי לבטל טעינות באמצע
      _loadGeneration++;
      _notifySafe();
      return;
    }

    // מזווה אישי/משפחתי (לפי householdId)
    if (_currentMode != InventoryMode.personal || _items.isEmpty && !_isLoading) {
      _currentMode = InventoryMode.personal;
      _loadItems();
    }
  }

  // === טעינת פריטים ===

  Future<void> _loadItems() {
    // 🔒 הגדלת הדור - מבטל טעינות קודמות
    _loadGeneration++;
    final currentGeneration = _loadGeneration;

    // 🔧 FIX: אם יש טעינה קיימת - חכה לה ואז התחל חדשה
    // החזר Future שמסתיים כשהטעינה החדשה מסתיימת (לא הישנה!)
    if (_loadingFuture != null) {
      // שרשור נכון: חכה לישנה → התחל חדשה → החזר את החדשה
      final chainedFuture = _loadingFuture!.then((_) {
        // בדוק אם עדיין רלוונטי
        if (_loadGeneration != currentGeneration || _isDisposed) {
          return Future<void>.value();
        }
        // התחל טעינה חדשה והחזר אותה
        _loadingFuture = null;
        return _loadItems();
      });
      // 🔧 שמור את ה-chain כדי למנוע שרשראות כפולות
      _loadingFuture = chainedFuture;
      return chainedFuture;
    }

    _loadingFuture = _doLoad(currentGeneration).whenComplete(() => _loadingFuture = null);
    return _loadingFuture!;
  }

  Future<void> _doLoad(int generation) async {
    final userId = _userContext?.userId;
    if (_userContext?.isLoggedIn != true || userId == null) {
      _cancelSubscription();
      _items = [];
      _isLoading = false;
      _errorMessage = null;
      _notifySafe();
      return;
    }

    // 🏠 בדיקה אם המשתמש בבית משותף
    final householdId = _userContext?.householdId;
    final isPersonalHousehold = householdId == null ||
        householdId == 'house_$userId' ||
        householdId == 'house_${userId.hashCode.abs()}';

    if (!isPersonalHousehold) {
      // 🏠 Household mode — real-time stream
      _currentMode = InventoryMode.household;
      _subscribeToHousehold(householdId);
      return;
    }

    // 👤 Personal mode — one-time fetch
    _currentMode = InventoryMode.personal;
    _cancelSubscription();

    // 🔒 שמירת המצב בתחילת הטעינה - לזיהוי race condition
    final loadingMode = _currentMode;

    _isLoading = true;
    _errorMessage = null;
    _notifySafe();

    try {
      final loadedItems = await _repository.fetchUserItems(userId);

      // 🔒 בדיקה: אם הדור השתנה או המצב השתנה - לא לעדכן!
      if (_loadGeneration != generation) return;
      if (_currentMode != loadingMode) {
        _isLoading = false;
        _notifySafe();
        return;
      }

      _items = loadedItems;
    } catch (e, st) {
      if (_loadGeneration != generation) return;
      _errorMessage = 'שגיאה בטעינת מלאי: $e';
      if (kDebugMode) {
        debugPrintStack(label: 'InventoryProvider._doLoad', stackTrace: st);
      }
    }

    _isLoading = false;
    _notifySafe();
  }

  /// 🏠 Subscribe to household inventory stream (real-time sync)
  void _subscribeToHousehold(String householdId) {
    if (_subscribedHouseholdId == householdId) return; // already subscribed
    _cancelSubscription();
    _subscribedHouseholdId = householdId;

    _isLoading = true;
    _errorMessage = null;
    _notifySafe();

    _inventorySubscription = _repository.watchInventory(householdId).listen(
      (items) {
        if (_isDisposed) return;
        _items = items;
        _isLoading = false;
        _errorMessage = null;
        _notifySafe();
      },
      onError: (e) {
        if (_isDisposed) return;
        _errorMessage = 'שגיאה בטעינת מזווה משותף: $e';
        _isLoading = false;
        _notifySafe();
      },
    );
  }

  /// ביטול subscription קיים
  void _cancelSubscription() {
    _inventorySubscription?.cancel();
    _inventorySubscription = null;
    _subscribedHouseholdId = null;
  }

  /// טוען את כל הפריטים מחדש מה-Repository
  ///
  /// Example:
  /// ```dart
  /// await inventoryProvider.loadItems();
  /// ```
  Future<void> loadItems() {
    return _loadItems();
  }

  // === יצירה/עדכון/מחיקה ===

  /// יוצר פריט מלאי חדש ומוסיף לרשימה
  ///
  /// Example:
  /// ```dart
  /// final item = await inventoryProvider.createItem(
  ///   productName: 'חלב',
  ///   category: 'מוצרי חלב',
  ///   location: 'מקרר',
  ///   quantity: 2,
  ///   unit: 'ליטר',
  /// );
  /// ```
  Future<InventoryItem> createItem({
    required String productName,
    required String category,
    required String location,
    int quantity = 1,
    String unit = "יח'",
    int minQuantity = 2,
    DateTime? expiryDate,
    String? notes,
    bool isRecurring = false,
    String? emoji,
  }) async {
    final userId = _userContext?.userId;
    if (userId == null) {
      throw Exception('❌ משתמש לא מחובר');
    }

    // ולידציה
    if (!_isValidProductName(productName)) {
      throw ArgumentError('שם מוצר לא תקין');
    }
    if (!_isValidQuantity(quantity)) {
      throw ArgumentError('כמות חייבת להיות חיובית');
    }

    // 🚫 בדיקת הגבלת פריטים במזווה
    if (_items.length >= kMaxItemsPerPantry) {
      throw Exception(AppStrings.inventory.maxItemsReached(kMaxItemsPerPantry));
    }

    final newItem = InventoryItem(
      id: _uuid.v4(),
      productName: productName,
      category: category,
      location: location,
      quantity: quantity,
      unit: unit,
      minQuantity: minQuantity,
      expiryDate: expiryDate,
      notes: notes,
      isRecurring: isRecurring,
      emoji: emoji,
      lastUpdatedBy: userId,
    );

    final previousItems = _items;

    await _runAsync(
      operation: 'createItem',
      setLoading: false,
      errorMessagePrefix: 'שגיאה ביצירת פריט',
      action: () async {
        // 🚀 Optimistic: עדכון מיידי של ה-UI
        _errorMessage = null;
        _items = [..._items, newItem];
        _notifySafe();

        try {
          if (_currentMode == InventoryMode.household &&
              _subscribedHouseholdId != null) {
            await _repository.saveItem(newItem, _subscribedHouseholdId!);
          } else {
            await _repository.saveUserItem(newItem, userId);
          }
        } catch (e) {
          // 🔄 Rollback: שחזור המצב הקודם
          _items = previousItems;
          rethrow;
        }
      },
    );

    return newItem;
  }

  /// מעדכן פריט קיים במלאי
  ///
  /// Example:
  /// ```dart
  /// final updatedItem = item.copyWith(quantity: 5);
  /// await inventoryProvider.updateItem(updatedItem);
  /// ```
  Future<void> updateItem(InventoryItem item) async {
    final userId = _userContext?.userId;
    if (userId == null) return;

    // 🔒 תמיד הגדר lastUpdatedBy — נדרש ע"י Firestore rules
    final itemWithAudit = item.lastUpdatedBy == userId
        ? item
        : item.copyWith(lastUpdatedBy: userId);

    final previousItems = _items;

    await _runAsync(
      operation: 'updateItem',
      setLoading: false,
      errorMessagePrefix: 'שגיאה בעדכון פריט',
      action: () async {
        // 🚀 Optimistic: עדכון מיידי של ה-UI
        _errorMessage = null;
        final index = _items.indexWhere((i) => i.id == itemWithAudit.id);
        if (index != -1) {
          _items = List.from(_items)..[index] = itemWithAudit;
        } else {
          _items = [..._items, itemWithAudit];
        }
        _notifySafe();

        try {
          if (_currentMode == InventoryMode.household &&
              _subscribedHouseholdId != null) {
            await _repository.saveItem(itemWithAudit, _subscribedHouseholdId!);
          } else {
            await _repository.saveUserItem(itemWithAudit, userId);
          }
        } catch (e) {
          // 🔄 Rollback: שחזור המצב הקודם
          _items = previousItems;
          rethrow;
        }
      },
    );
  }

  /// מחיק פריט מהמלאי
  ///
  /// Example:
  /// ```dart
  /// await inventoryProvider.deleteItem(item.id);
  /// ```
  Future<void> deleteItem(String id) async {
    final userId = _userContext?.userId;
    if (userId == null) return;

    // ולידציה
    if (!_isValidId(id)) {
      throw ArgumentError('ID פריט לא תקין');
    }

    final previousItems = _items;

    await _runAsync(
      operation: 'deleteItem',
      setLoading: false,
      errorMessagePrefix: 'שגיאה במחיקת פריט',
      action: () async {
        // 🚀 Optimistic: הסרה מיידית מה-UI
        _errorMessage = null;
        _items = _items.where((i) => i.id != id).toList();
        _notifySafe();

        try {
          if (_currentMode == InventoryMode.household &&
              _subscribedHouseholdId != null) {
            await _repository.deleteItem(id, _subscribedHouseholdId!);
          } else {
            await _repository.deleteUserItem(id, userId);
          }
        } catch (e) {
          // 🔄 Rollback: שחזור המצב הקודם
          _items = previousItems;
          rethrow;
        }
      },
    );
  }

  // === Error Recovery ===
  
  /// מנקה שגיאות ומטעין מחדש את הפריטים
  /// 
  /// Example:
  /// ```dart
  /// if (provider.hasError) {
  ///   await provider.retry();
  /// }
  /// ```
  Future<void> retry() async {
    _errorMessage = null;
    _notifySafe();
    await _loadItems();
  }

  /// מנקה את כל הנתונים והשגיאות
  ///
  /// Example:
  /// ```dart
  /// inventoryProvider.clearAll();
  /// ```
  void clearAll() {
    _items = [];
    _errorMessage = null;
    _isLoading = false;
    _notifySafe();
  }

  // === פילטרים נוחים ===
  
  /// מחזיר פריטים לפי קטגוריה
  /// 
  /// Example:
  /// ```dart
  /// final milkProducts = provider.itemsByCategory('מוצרי חלב');
  /// ```
  List<InventoryItem> itemsByCategory(String category) {
    return _items.where((i) => i.category == category).toList();
  }

  /// מחזיר מוצרים שאוזלים (מתחת למינימום שהוגדר לכל פריט)
  ///
  /// כל פריט יש לו minQuantity משלו, כך שהסף מותאם אישית.
  ///
  /// Example:
  /// ```dart
  /// final lowStock = provider.getLowStockItems();
  /// ```
  List<InventoryItem> getLowStockItems() {
    return _items.where((item) => item.isLowStock).toList();
  }

  /// מוסיף מלאי למוצר קיים (חיבור!)
  ///
  /// Example:
  /// ```dart
  /// await provider.addStock('חלב', 2); // +2 יחידות
  /// ```
  Future<void> addStock(String productName, int quantity) async {
    final userId = _userContext?.userId;
    if (userId == null) return;

    // ולידציה
    if (!_isValidProductName(productName)) {
      throw ArgumentError('שם מוצר לא תקין');
    }
    if (!_isValidQuantity(quantity)) {
      throw ArgumentError('כמות חייבת להיות חיובית');
    }

    // מצא פריט לפי שם
    final existingItem = _items.where((i) => i.productName.trim().toLowerCase() == productName.trim().toLowerCase()).firstOrNull;
    if (existingItem == null) {
      // 🆕 מוצר חדש שלא קיים במזווה — צור אותו אוטומטית
      await createItem(
        productName: productName,
        category: 'כללי',
        location: 'כללי',
        quantity: quantity,
      );
      return;
    }

    final updatedItem = existingItem.copyWith(
      quantity: existingItem.quantity + quantity,
      lastUpdatedBy: userId,
    );
    final previousItems = _items;

    await _runAsync(
      operation: 'addStock',
      setLoading: false,
      errorMessagePrefix: 'שגיאה בעדכון מלאי',
      action: () async {
        // 🚀 Optimistic: עדכון כמות מיידי ב-UI
        _errorMessage = null;
        final index = _items.indexWhere((i) => i.id == existingItem.id);
        if (index != -1) {
          _items = List.from(_items)..[index] = updatedItem;
          _notifySafe();
        }

        try {
          await _repository.saveUserItem(updatedItem, userId);
        } catch (e) {
          // 🔄 Rollback: שחזור המצב הקודם
          _items = previousItems;
          rethrow;
        }
      },
    );
  }

  /// עדכון מלאי אוטומטי אחרי קנייה
  /// 
  /// עובד ב-batch mode - ממשיך גם אם חלק נכשל
  /// 
  /// Returns: מספר פריטים שעודכנו בהצלחה
  /// 
  /// Example:
  /// ```dart
  /// final successCount = await provider.updateStockAfterPurchase(checkedItems);
  /// print('עודכנו $successCount מתוך ${checkedItems.length} פריטים');
  /// ```
  Future<int> updateStockAfterPurchase(List<UnifiedListItem> purchasedItems) async {
    int successCount = 0;
    int failureCount = 0;
    final failures = <String>[];

    for (final item in purchasedItems) {
      if (item.type == ItemType.product && item.quantity != null) {
        try {
          await addStock(item.name, item.quantity!);
          successCount++;
        } catch (e) {
          failureCount++;
          failures.add(item.name);
        }
      }
    }

    if (failureCount > 0) {
      _errorMessage = 'עודכנו $successCount פריטים, נכשלו $failureCount: ${failures.join(", ")}';
      _notifySafe(); // 🔒 בטוח גם אם המשתמש יצא מהמסך
    }

    return successCount;
  }

  /// מחזיר פריטים לפי מיקום
  ///
  /// Example:
  /// ```dart
  /// final fridgeItems = provider.itemsByLocation('מקרר');
  /// ```
  List<InventoryItem> itemsByLocation(String location) {
    return _items.where((i) => i.location == location).toList();
  }

  // === העברת מזווה ===

  /// בודק אם למשתמש יש פריטים במזווה האישי
  ///
  /// שימושי לפני הצטרפות לקבוצה - כדי לשאול אם להעביר את המזווה
  Future<bool> hasPersonalInventory() async {
    final userId = _userContext?.userId;
    if (userId == null) return false;

    try {
      final userItems = await _repository.fetchUserItems(userId);
      return userItems.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// מחזיר את מספר הפריטים במזווה האישי
  Future<int> getPersonalInventoryCount() async {
    final userId = _userContext?.userId;
    if (userId == null) return 0;

    try {
      final userItems = await _repository.fetchUserItems(userId);
      return userItems.length;
    } catch (e) {
      return 0;
    }
  }

  /// 🏺 מוסיף פריטי starter למזווה (Onboarding)
  ///
  /// מקבל רשימת InventoryItem ומוסיף אותם למזווה הנוכחי.
  /// משמש להוספת מוצרי יסוד בפעם הראשונה שמשתמש נכנס למזווה ריק.
  ///
  /// Example:
  /// ```dart
  /// final items = await TemplateService.loadPantryStarterItems();
  /// await provider.addStarterItems(items);
  /// ```
  Future<int> addStarterItems(List<InventoryItem> items) async {
    final userId = _userContext?.userId;
    if (userId == null) {
      throw Exception('משתמש לא מחובר');
    }

    if (items.isEmpty) return 0;

    int successCount = 0;

    try {
      for (final item in items) {
        // שמירה למזווה אישי
        await _repository.saveUserItem(item, userId);
        successCount++;
      }

      // עדכון local
      _items = [..._items, ...items];
      _notifySafe();


      return successCount;
    } catch (e) {
      _errorMessage = 'שגיאה בהוספת פריטים';
      _notifySafe();
      rethrow;
    }
  }

  /// מוחק את כל המזווה האישי
  ///
  /// Example:
  /// ```dart
  /// final count = await provider.deletePersonalInventory();
  /// print('נמחקו $count פריטים');
  /// ```
  Future<int> deletePersonalInventory() async {
    final userId = _userContext?.userId;
    if (userId == null) {
      throw Exception('❌ משתמש לא מחובר');
    }

    try {

      final deletedCount = await _repository.deleteAllUserItems(userId);


      return deletedCount;
    } catch (e) {
      _errorMessage = 'שגיאה במחיקת מזווה אישי';
      _notifySafe();
      rethrow;
    }
  }

  // === Cleanup ===

  @override
  void dispose() {
    _isDisposed = true;
    _cancelSubscription();

    if (_listeningToUser && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
    }

    super.dispose();
  }
}
