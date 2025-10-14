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
import '../repositories/inventory_repository.dart';
import 'user_context.dart';

class InventoryProvider with ChangeNotifier {
  final InventoryRepository _repository;
  UserContext? _userContext;
  bool _listening = false;

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
    debugPrint('🔄 InventoryProvider.updateUserContext');
    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
      _listening = false;
    }
    _userContext = newContext;
    _userContext!.addListener(_onUserChanged);
    _listening = true;
    debugPrint('✅ Listener הוסף, מתחיל initialization');
    _initialize();
  }

  void _onUserChanged() {
    debugPrint('👤 InventoryProvider._onUserChanged: משתמש השתנה');
    _loadItems();
  }

  void _initialize() {
    debugPrint('🔧 InventoryProvider._initialize');
    _loadItems();  // _doLoad יטפל בכל הלוגיקה (מחובר/לא מחובר)
  }

  // === טעינת פריטים ===
  
  Future<void> _loadItems() {
    debugPrint('📥 InventoryProvider._loadItems');
    
    if (_loadingFuture != null) {
      debugPrint('   ⏳ טעינה כבר בתהליך, ממתין...');
      return _loadingFuture!;
    }
    
    _loadingFuture = _doLoad().whenComplete(() => _loadingFuture = null);
    return _loadingFuture!;
  }

  Future<void> _doLoad() async {
    debugPrint('🔄 InventoryProvider._doLoad: מתחיל טעינה');
    
    final householdId = _userContext?.user?.householdId;
    if (_userContext?.isLoggedIn != true || householdId == null) {
      debugPrint('   ⚠️ אין household_id, מנקה רשימה');
      _items = [];
      notifyListeners();
      debugPrint('   🔔 InventoryProvider: notifyListeners() (no household_id)');
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    debugPrint('   🔔 InventoryProvider: notifyListeners() (isLoading=true)');

    try {
      _items = await _repository.fetchItems(householdId);
      debugPrint('✅ InventoryProvider._doLoad: נטענו ${_items.length} פריטים');
    } catch (e, st) {
      _errorMessage = "שגיאה בטעינת מלאי: $e";
      debugPrint('❌ InventoryProvider._doLoad: שגיאה - $e');
      debugPrintStack(label: 'InventoryProvider._doLoad', stackTrace: st);
    }

    _isLoading = false;
    notifyListeners();
    debugPrint('   🔔 InventoryProvider: notifyListeners() (isLoading=false, items=${_items.length})');
  }

  /// טוען את כל הפריטים מחדש מה-Repository
  /// 
  /// Example:
  /// ```dart
  /// await inventoryProvider.loadItems();
  /// ```
  Future<void> loadItems() {
    debugPrint('🔄 InventoryProvider.loadItems: רענון ידני');
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
  }) async {
    debugPrint('➕ InventoryProvider.createItem: $productName');
    debugPrint('   קטגוריה: $category, מיקום: $location, כמות: $quantity');
    
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) {
      debugPrint('❌ householdId לא נמצא');
      throw Exception("❌ householdId לא נמצא");
    }

    try {
      final newItem = InventoryItem(
        id: _uuid.v4(),
        productName: productName,
        category: category,
        location: location,
        quantity: quantity,
        unit: unit,
      );

      await _repository.saveItem(newItem, householdId);
      debugPrint('✅ פריט נשמר ב-Repository: ${newItem.id}');
      
      // אופטימיזציה: הוספה local במקום ריענון מלא
      _items.add(newItem);
      notifyListeners();
      debugPrint('   🔔 InventoryProvider: notifyListeners() (item created: ${newItem.id})');
      
      return newItem;
    } catch (e) {
      debugPrint('❌ InventoryProvider.createItem: שגיאה - $e');
      _errorMessage = 'שגיאה ביצירת פריט';
      notifyListeners();
      debugPrint('   🔔 InventoryProvider: notifyListeners() (error)');
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
    debugPrint('✏️ InventoryProvider.updateItem: ${item.id}');
    debugPrint('   מוצר: ${item.productName}, כמות: ${item.quantity}');
    
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) {
      debugPrint('⚠️ householdId לא נמצא, מדלג');
      return;
    }

    try {
      await _repository.saveItem(item, householdId);
      debugPrint('✅ פריט עודכן ב-Repository');
      
      // אופטימיזציה: עדכון local במקום ריענון מלא
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = item;
        notifyListeners();
        debugPrint('   🔔 InventoryProvider: notifyListeners() (item updated: ${item.id})');
      } else {
        debugPrint('⚠️ פריט לא נמצא ברשימה, מבצע ריענון מלא');
        await _loadItems();
      }
    } catch (e) {
      debugPrint('❌ InventoryProvider.updateItem: שגיאה - $e');
      _errorMessage = 'שגיאה בעדכון פריט';
      notifyListeners();
      debugPrint('   🔔 InventoryProvider: notifyListeners() (error)');
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
    debugPrint('🗑️ InventoryProvider.deleteItem: $id');
    
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) {
      debugPrint('⚠️ householdId לא נמצא, מדלג');
      return;
    }

    try {
      await _repository.deleteItem(id, householdId);
      debugPrint('✅ פריט נמחק מ-Repository');
      
      // אופטימיזציה: מחיקה local במקום ריענון מלא
      _items.removeWhere((i) => i.id == id);
      notifyListeners();
      debugPrint('   🔔 InventoryProvider: notifyListeners() (item deleted: $id)');
    } catch (e) {
      debugPrint('❌ InventoryProvider.deleteItem: שגיאה - $e');
      _errorMessage = 'שגיאה במחיקת פריט';
      notifyListeners();
      debugPrint('   🔔 InventoryProvider: notifyListeners() (error)');
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
    debugPrint('🔄 InventoryProvider.retry: מנסה שוב');
    _errorMessage = null;
    notifyListeners();
    debugPrint('   🔔 InventoryProvider: notifyListeners() (error cleared)');
    await _loadItems();
  }

  /// מנקה את כל הנתונים והשגיאות
  /// 
  /// Example:
  /// ```dart
  /// inventoryProvider.clearAll();
  /// ```
  void clearAll() {
    debugPrint('🧹 InventoryProvider.clearAll: מנקה הכל');
    _items = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
    debugPrint('   🔔 InventoryProvider: notifyListeners() (all cleared)');
  }

  // === פילטרים נוחים ===
  
  /// מחזיר פריטים לפי קטגוריה
  /// 
  /// Example:
  /// ```dart
  /// final milkProducts = provider.itemsByCategory('מוצרי חלב');
  /// ```
  List<InventoryItem> itemsByCategory(String category) {
    final filtered = _items.where((i) => i.category == category).toList();
    debugPrint('🔍 itemsByCategory($category): ${filtered.length} פריטים');
    return filtered;
  }

  /// מחזיר פריטים לפי מיקום
  /// 
  /// Example:
  /// ```dart
  /// final fridgeItems = provider.itemsByLocation('מקרר');
  /// ```
  List<InventoryItem> itemsByLocation(String location) {
    final filtered = _items.where((i) => i.location == location).toList();
    debugPrint('🔍 itemsByLocation($location): ${filtered.length} פריטים');
    return filtered;
  }

  // === Cleanup ===
  
  @override
  void dispose() {
    debugPrint('🧹 InventoryProvider.dispose');
    
    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
      debugPrint('   ✅ Listener הוסר');
    }
    
    super.dispose();
  }
}
