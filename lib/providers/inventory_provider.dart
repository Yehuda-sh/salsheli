// 📄 File: lib/providers/inventory_provider.dart
//
// 🇮🇱 מנהל את פריטי המלאי (Inventory) עם טעינה בטוחה וסנכרון אוטומטי:
//     - טוען פריטים מ-Repository לפי household_id
//     - מאזין לשינויים ב-UserContext ומריענן אוטומטית
//     - מספק CRUD מלא עם error handling
//     - אופטימיזציה: עדכון local במקום ריענון מלא
//     - פילטרים נוחים: לפי קטגוריה/מיקום
//
// 🇬🇧 Manages inventory items with safe loading and auto-sync:
//     - Loads items from Repository by household_id
//     - Listens to UserContext changes and auto-refreshes
//     - Provides full CRUD with error handling
//     - Optimization: local updates instead of full reload
//     - Convenient filters: by category/location
//
// Dependencies:
//     - InventoryRepository: data source
//     - UserContext: household_id + auth state
//
// Usage:
//     final provider = context.watch<InventoryProvider>();
//     await provider.createItem(productName: 'חלב', ...);
//     final milkItems = provider.itemsByCategory('מוצרי חלב');

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/inventory_item.dart';
import '../models/unified_list_item.dart';
import '../models/enums/item_type.dart';
import '../repositories/inventory_repository.dart';
import 'user_context.dart';

class InventoryProvider with ChangeNotifier {
  final InventoryRepository _repository;
  UserContext? _userContext;
  bool _listening = false;
  bool _hasInitialized = false; // מניעת אתחול כפול

  bool _isLoading = false;
  String? _errorMessage;
  List<InventoryItem> _items = [];

  static final Uuid _uuid = Uuid();
  Future<void>? _loadingFuture; // מניעת טעינות כפולות

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

  // === חיבור UserContext ===
  
  /// מעדכן את ה-UserContext ומאזין לשינויים
  /// נקרא אוטומטית מ-ProxyProvider
  void updateUserContext(UserContext newContext) {
    // מניעת update כפול של אותו context
    if (_userContext == newContext) {
      return;
    }

    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
      _listening = false;
    }
    _userContext = newContext;
    _userContext!.addListener(_onUserChanged);
    _listening = true;

    // אתחול רק בפעם הראשונה
    if (!_hasInitialized) {
      _hasInitialized = true;
      _initialize();
    }
  }

  void _onUserChanged() {
    _loadItems();
  }

  void _initialize() {
    _loadItems();  // _doLoad יטפל בכל הלוגיקה (מחובר/לא מחובר)
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
    final householdId = _userContext?.user?.householdId;
    if (_userContext?.isLoggedIn != true || householdId == null) {
      _items = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _repository.fetchItems(householdId);
    } catch (e, st) {
      _errorMessage = 'שגיאה בטעינת מלאי: $e';
      debugPrint('❌ InventoryProvider._doLoad: שגיאה - $e');
      debugPrintStack(label: 'InventoryProvider._doLoad', stackTrace: st);
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
  }) async {
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) {
      throw Exception('❌ householdId לא נמצא');
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
      );

      await _repository.saveItem(newItem, householdId);

      // אופטימיזציה: הוספה local במקום ריענון מלא
      _items.add(newItem);
      notifyListeners();

      return newItem;
    } catch (e) {
      debugPrint('❌ InventoryProvider.createItem: שגיאה - $e');
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
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) {
      return;
    }

    try {
      await _repository.saveItem(item, householdId);

      // עדכון local - יוצר רשימה חדשה כדי ש-Flutter יזהה את השינוי
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items = List.from(_items)..[index] = item;
      } else {
        _items = [..._items, item];
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ InventoryProvider.updateItem: שגיאה - $e');
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
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) {
      return;
    }

    try {
      await _repository.deleteItem(id, householdId);

      // מחיקה local - יוצר רשימה חדשה כדי ש-Flutter יזהה את השינוי
      _items = _items.where((i) => i.id != id).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ InventoryProvider.deleteItem: שגיאה - $e');
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
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) {
      return;
    }

    try {
      // מצא פריט לפי שם
      final existingItem = _items.where((i) => i.productName.trim().toLowerCase() == productName.trim().toLowerCase()).firstOrNull;

      if (existingItem != null) {
        // עדכן מלאי - חיבור!
        final updatedItem = existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
        );

        await _repository.saveItem(updatedItem, householdId);

        // עדכון local
        final index = _items.indexWhere((i) => i.id == existingItem.id);
        if (index != -1) {
          _items[index] = updatedItem;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('❌ addStock: שגיאה - $e');
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

  // === Cleanup ===

  @override
  void dispose() {
    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
    }

    super.dispose();
  }
}
