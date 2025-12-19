// 📄 File: lib/providers/inventory_provider.dart
// Version: 4.0
// Last Updated: 16/12/2025
//
// ✅ Improvements in v4.0:
// - תמיכה במזווה אישי (/users/{userId}/inventory)
// - תמיכה במזווה קבוצתי (/groups/{groupId}/inventory)
// - זיהוי אוטומטי של מיקום מזווה לפי חברות בקבוצת משפחה
// - העברת מזווה אישי לקבוצה בעת הצטרפות
// - מחיקת מזווה אישי בעת הצטרפות לקבוצה
//
// 🇮🇱 מנהל את פריטי המלאי (Inventory) עם טעינה בטוחה וסנכרון אוטומטי:
//     - זיהוי אוטומטי: user inventory או group inventory
//     - מאזין לשינויים ב-UserContext וב-GroupsProvider
//     - מספק CRUD מלא עם error handling
//     - אופטימיזציה: עדכון local במקום ריענון מלא
//     - פילטרים נוחים: לפי קטגוריה/מיקום
//     - תמיכה בהעברת מזווה בין אישי לקבוצתי
//
// 🇬🇧 Manages inventory items with safe loading and auto-sync:
//     - Auto-detect: user inventory vs group inventory
//     - Listens to UserContext and GroupsProvider changes
//     - Provides full CRUD with error handling
//     - Optimization: local updates instead of full reload
//     - Convenient filters: by category/location
//     - Support for transferring inventory between personal and group
//
// Dependencies:
//     - InventoryRepository: data source (user & group inventory)
//     - UserContext: user auth state
//     - GroupsProvider: detect family group membership
//
// Usage:
//     final provider = context.watch<InventoryProvider>();
//     await provider.createItem(productName: 'חלב', ...);
//     final milkItems = provider.itemsByCategory('מוצרי חלב');
//
//     // העברת מזווה לקבוצה
//     await provider.transferToGroup(groupId);

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/enums/item_type.dart';
import '../models/group.dart';
import '../models/inventory_item.dart';
import '../models/unified_list_item.dart';
import '../repositories/inventory_repository.dart';
import 'groups_provider.dart';
import 'user_context.dart';

/// מיקום המזווה הנוכחי
enum InventoryMode {
  /// מזווה אישי - /users/{userId}/inventory
  personal,

  /// מזווה קבוצתי - /groups/{groupId}/inventory
  group,
}

class InventoryProvider with ChangeNotifier {
  final InventoryRepository _repository;
  UserContext? _userContext;
  GroupsProvider? _groupsProvider;
  bool _listeningToUser = false;
  bool _listeningToGroups = false;
  bool _hasInitialized = false; // מניעת אתחול כפול

  bool _isLoading = false;
  String? _errorMessage;
  List<InventoryItem> _items = [];

  // מצב מזווה נוכחי
  InventoryMode _currentMode = InventoryMode.personal;
  String? _currentGroupId; // ID של הקבוצה אם במצב group

  static const Uuid _uuid = Uuid();
  Future<void>? _loadingFuture; // מניעת טעינות כפולות

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

  /// מצב המזווה הנוכחי (אישי או קבוצתי)
  InventoryMode get currentMode => _currentMode;

  /// האם המזווה הוא קבוצתי
  bool get isGroupMode => _currentMode == InventoryMode.group;

  /// ID של הקבוצה הנוכחית (null אם מזווה אישי)
  String? get currentGroupId => _currentGroupId;

  /// שם המזווה להצגה
  String get inventoryTitle => isGroupMode ? 'מזווה משותף' : 'המזווה שלי';

  // === חיבור UserContext ===

  /// מעדכן את ה-UserContext ומאזין לשינויים
  /// נקרא אוטומטית מ-ProxyProvider
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
    if (!_hasInitialized) {
      _hasInitialized = true;
      _initialize();
    }
  }

  /// מעדכן את ה-GroupsProvider ומאזין לשינויים
  /// נקרא אוטומטית מ-ProxyProvider
  void updateGroupsProvider(GroupsProvider? newProvider) {
    if (_groupsProvider == newProvider) return;

    if (_listeningToGroups && _groupsProvider != null) {
      _groupsProvider!.removeListener(_onGroupsChanged);
      _listeningToGroups = false;
    }

    _groupsProvider = newProvider;
    if (newProvider != null) {
      newProvider.addListener(_onGroupsChanged);
      _listeningToGroups = true;
      // עדכון מיקום מזווה בהתבסס על קבוצות
      _updateInventoryLocation();
    }
  }

  void _onUserChanged() {
    _updateInventoryLocation();
  }

  void _onGroupsChanged() {
    _updateInventoryLocation();
  }

  void _initialize() {
    _updateInventoryLocation();
  }

  /// מזהה את מיקום המזווה הנכון וטוען את הפריטים
  void _updateInventoryLocation() {
    final userId = _userContext?.userId;
    if (userId == null || _userContext?.isLoggedIn != true) {
      _currentMode = InventoryMode.personal;
      _currentGroupId = null;
      _items = [];
      notifyListeners();
      return;
    }

    // חפש קבוצה עם מזווה משותף (family/roommates)
    final pantryGroup = _findPantryGroup(userId);

    if (pantryGroup != null) {
      // יש קבוצה עם מזווה - עבור למצב קבוצתי
      final newGroupId = pantryGroup.id;
      if (_currentMode != InventoryMode.group || _currentGroupId != newGroupId) {
        _currentMode = InventoryMode.group;
        _currentGroupId = newGroupId;
        if (kDebugMode) {
          debugPrint('🏠 InventoryProvider: מעבר למזווה קבוצתי - ${pantryGroup.name}');
        }
        _loadItems();
      }
    } else {
      // אין קבוצה עם מזווה - מצב אישי
      if (_currentMode != InventoryMode.personal) {
        _currentMode = InventoryMode.personal;
        _currentGroupId = null;
        if (kDebugMode) {
          debugPrint('👤 InventoryProvider: מעבר למזווה אישי');
        }
        _loadItems();
      } else if (_items.isEmpty && !_isLoading) {
        // טעינה ראשונית
        _loadItems();
      }
    }
  }

  /// מוצא קבוצה עם מזווה משותף שהמשתמש חבר בה
  Group? _findPantryGroup(String userId) {
    if (_groupsProvider == null) return null;

    // חפש קבוצה מסוג family או roommates (hasPantry=true)
    for (final group in _groupsProvider!.groups) {
      if (group.type.hasPantry && group.isMember(userId)) {
        return group;
      }
    }
    return null;
  }

  // === טעינת פריטים ===

  Future<void> _loadItems() {
    if (_loadingFuture != null) {
      return _loadingFuture!;
    }

    _loadingFuture = _doLoad().whenComplete(() => _loadingFuture = null);
    return _loadingFuture!;
  }

  Future<void> _doLoad() async {
    final userId = _userContext?.userId;
    if (_userContext?.isLoggedIn != true || userId == null) {
      _items = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_currentMode == InventoryMode.group && _currentGroupId != null) {
        // טעינה ממזווה קבוצתי
        if (kDebugMode) {
          debugPrint('📦 InventoryProvider: טוען ממזווה קבוצתי $_currentGroupId');
        }
        _items = await _repository.fetchGroupItems(_currentGroupId!);
      } else {
        // טעינה ממזווה אישי
        if (kDebugMode) {
          debugPrint('📦 InventoryProvider: טוען ממזווה אישי $userId');
        }
        _items = await _repository.fetchUserItems(userId);
      }
    } catch (e, st) {
      _errorMessage = 'שגיאה בטעינת מלאי: $e';
      if (kDebugMode) {
        debugPrint('❌ InventoryProvider._doLoad: שגיאה - $e');
        debugPrintStack(label: 'InventoryProvider._doLoad', stackTrace: st);
      }
    }

    _isLoading = false;
    notifyListeners();
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

      // שמירה למיקום הנכון
      if (_currentMode == InventoryMode.group && _currentGroupId != null) {
        await _repository.saveGroupItem(newItem, _currentGroupId!);
      } else {
        await _repository.saveUserItem(newItem, userId);
      }

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
      // שמירה למיקום הנכון
      if (_currentMode == InventoryMode.group && _currentGroupId != null) {
        await _repository.saveGroupItem(item, _currentGroupId!);
      } else {
        await _repository.saveUserItem(item, userId);
      }

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
      // מחיקה מהמיקום הנכון
      if (_currentMode == InventoryMode.group && _currentGroupId != null) {
        await _repository.deleteGroupItem(id, _currentGroupId!);
      } else {
        await _repository.deleteUserItem(id, userId);
      }

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

        // שמירה למיקום הנכון
        if (_currentMode == InventoryMode.group && _currentGroupId != null) {
          await _repository.saveGroupItem(updatedItem, _currentGroupId!);
        } else {
          await _repository.saveUserItem(updatedItem, userId);
        }

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
      notifyListeners();
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

  /// מעביר את כל המזווה האישי לקבוצה
  ///
  /// משמש בעת הצטרפות לקבוצה עם מזווה (משפחה/שותפים)
  ///
  /// Example:
  /// ```dart
  /// final count = await provider.transferToGroup('grp_xxx');
  /// print('הועברו $count פריטים לקבוצה');
  /// ```
  Future<int> transferToGroup(String groupId) async {
    final userId = _userContext?.userId;
    if (userId == null) {
      throw Exception('❌ משתמש לא מחובר');
    }

    try {
      if (kDebugMode) {
        debugPrint('📦 InventoryProvider: מעביר מזווה אישי לקבוצה $groupId');
      }

      final transferredCount = await _repository.transferUserItemsToGroup(
        userId,
        groupId,
      );

      if (kDebugMode) {
        debugPrint('✅ InventoryProvider: הועברו $transferredCount פריטים');
      }

      // עדכון המצב לקבוצתי וטעינה מחדש
      _currentMode = InventoryMode.group;
      _currentGroupId = groupId;
      await _loadItems();

      return transferredCount;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ InventoryProvider.transferToGroup: שגיאה - $e');
      }
      _errorMessage = 'שגיאה בהעברת מזווה לקבוצה';
      notifyListeners();
      rethrow;
    }
  }

  /// מוחק את כל המזווה האישי
  ///
  /// משמש בעת הצטרפות לקבוצה - אם המשתמש בוחר לא להעביר
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
    if (_listeningToUser && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
    }
    if (_listeningToGroups && _groupsProvider != null) {
      _groupsProvider!.removeListener(_onGroupsChanged);
    }

    super.dispose();
  }
}
