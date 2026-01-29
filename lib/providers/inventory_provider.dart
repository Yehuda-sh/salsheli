// 📄 lib/providers/inventory_provider.dart
//
// Provider לניהול מזווה - אישי (לפי household).
// CRUD מלא, פילטרים, וניהול מלאי.
//
// 🔗 Related: InventoryItem, InventoryRepository, UserContext

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

  // === Safe Notification ===

  /// 🔒 קורא ל-notifyListeners() רק אם ה-provider לא disposed
  void _notifySafe() {
    if (!_isDisposed) {
      notifyListeners();
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
    if (kDebugMode) {
      debugPrint('📍 InventoryProvider._updateInventoryLocation: userId=$userId, isLoggedIn=${_userContext?.isLoggedIn}');
    }
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
      if (kDebugMode) {
        debugPrint('👤 InventoryProvider: מזווה אישי/משפחתי');
      }
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
      _items = [];
      _isLoading = false;
      _errorMessage = null;
      _notifySafe();
      return;
    }

    // 🔒 שמירת המצב בתחילת הטעינה - לזיהוי race condition
    final loadingMode = _currentMode;

    _isLoading = true;
    _errorMessage = null;
    _notifySafe();

    try {
      // טעינה ממזווה אישי
      if (kDebugMode) {
        debugPrint('📦 InventoryProvider: טוען ממזווה אישי $userId');
      }
      final loadedItems = await _repository.fetchUserItems(userId);

      // 🔒 בדיקה: אם הדור השתנה או המצב השתנה - לא לעדכן!
      if (_loadGeneration != generation) {
        if (kDebugMode) {
          debugPrint('⚠️ InventoryProvider: דור טעינה השתנה - מתעלם מתוצאות');
        }
        return; // אל תשנה isLoading - הטעינה החדשה תטפל בזה
      }

      if (_currentMode != loadingMode) {
        if (kDebugMode) {
          debugPrint('⚠️ InventoryProvider: מצב השתנה תוך כדי טעינה - מתעלם מתוצאות');
        }
        _isLoading = false;
        _notifySafe();
        return;
      }

      _items = loadedItems;
    } catch (e, st) {
      // בדוק שוב שהדור לא השתנה לפני עדכון שגיאה
      if (_loadGeneration != generation) return;

      _errorMessage = 'שגיאה בטעינת מלאי: $e';
      if (kDebugMode) {
        debugPrint('❌ InventoryProvider._doLoad: שגיאה - $e');
        debugPrintStack(label: 'InventoryProvider._doLoad', stackTrace: st);
      }
    }

    _isLoading = false;
    _notifySafe();
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
      if (kDebugMode) {
        debugPrint('❌ createItem: הגעת למקסימום $kMaxItemsPerPantry פריטים במזווה');
      }
      throw Exception(AppStrings.inventory.maxItemsReached(kMaxItemsPerPantry));
    }

    try {
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
      );

      // שמירה למזווה אישי
      await _repository.saveUserItem(newItem, userId);

      // אופטימיזציה: הוספה local במקום ריענון מלא
      _items = [..._items, newItem];
      notifyListeners();

      return newItem;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ InventoryProvider.createItem: שגיאה - $e');
      }
      _errorMessage = 'שגיאה ביצירת פריט';
      notifyListeners();
      rethrow;
    }
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

    try {
      // שמירה למזווה אישי
      await _repository.saveUserItem(item, userId);

      // עדכון local - יוצר רשימה חדשה כדי ש-Flutter יזהה את השינוי
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items = List.from(_items)..[index] = item;
      } else {
        _items = [..._items, item];
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ InventoryProvider.updateItem: שגיאה - $e');
      }
      _errorMessage = 'שגיאה בעדכון פריט';
      notifyListeners();
      rethrow;
    }
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

    try {
      // מחיקה ממזווה אישי
      await _repository.deleteUserItem(id, userId);

      // מחיקה local - יוצר רשימה חדשה כדי ש-Flutter יזהה את השינוי
      _items = _items.where((i) => i.id != id).toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ InventoryProvider.deleteItem: שגיאה - $e');
      }
      _errorMessage = 'שגיאה במחיקת פריט';
      notifyListeners();
      rethrow;
    }
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
    notifyListeners();
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
    notifyListeners();
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

    try {
      // מצא פריט לפי שם
      final existingItem = _items.where((i) => i.productName.trim().toLowerCase() == productName.trim().toLowerCase()).firstOrNull;

      if (existingItem != null) {
        // עדכן מלאי - חיבור!
        final updatedItem = existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
        );

        // שמירה למזווה אישי
        await _repository.saveUserItem(updatedItem, userId);

        // עדכון local
        final index = _items.indexWhere((i) => i.id == existingItem.id);
        if (index != -1) {
          _items = List.from(_items)..[index] = updatedItem;
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ addStock: שגיאה - $e');
      }
      _errorMessage = 'שגיאה בעדכון מלאי';
      notifyListeners();
      rethrow;
    }
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
      if (kDebugMode) {
        debugPrint('❌ hasPersonalInventory: שגיאה - $e');
      }
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
      if (kDebugMode) {
        debugPrint('❌ getPersonalInventoryCount: שגיאה - $e');
      }
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
      notifyListeners();

      if (kDebugMode) {
        debugPrint('✅ InventoryProvider: נוספו $successCount פריטי starter למזווה');
      }

      return successCount;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ InventoryProvider.addStarterItems: שגיאה - $e');
      }
      _errorMessage = 'שגיאה בהוספת פריטים';
      notifyListeners();
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
      if (kDebugMode) {
        debugPrint('🗑️ InventoryProvider: מוחק מזווה אישי של $userId');
      }

      final deletedCount = await _repository.deleteAllUserItems(userId);

      if (kDebugMode) {
        debugPrint('✅ InventoryProvider: נמחקו $deletedCount פריטים');
      }

      return deletedCount;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ InventoryProvider.deletePersonalInventory: שגיאה - $e');
      }
      _errorMessage = 'שגיאה במחיקת מזווה אישי';
      notifyListeners();
      rethrow;
    }
  }

  // === Cleanup ===

  @override
  void dispose() {
    _isDisposed = true;

    if (_listeningToUser && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
    }

    super.dispose();
  }
}
