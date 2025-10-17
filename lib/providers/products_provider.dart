// 📄 File: lib/providers/products_provider.dart
//
// 🎯 Purpose: Provider למוצרים - ניהול state מרכזי של כל המוצרים באפליקציה
//
// 📦 Dependencies:
// - ProductsRepository: ממשק לטעינת מוצרים
// - FirebaseProductsRepository: מימוש Firebase
// - ListTypeMappings: מיפוי בין סוגי רשימות לקטגוריות
// - UserContext: מידע על המשתמש הנוכחי (חובה!)
//
// ✨ Features:
// - 📥 טעינה מ-Firebase
// - 🔄 רענון מחירים: עדכון מחירים מ-API
// - 🔍 חיפוש: לפי שם, ברקוד, קטגוריה
// - 🎯 סינון: לפי סוג רשימה, קטגוריה, טקסט
// - 📊 סטטיסטיקות: כמה מוצרים, עם/בלי מחיר
// - 👤 UserContext Integration: עדכון אוטומטי בהתחברות/התנתקות
// - 🐛 Logging מפורט: כל פעולה עם debugPrint
//
// 📝 Usage:
// ```dart
// // בקריאת נתונים:
// final provider = context.watch<ProductsProvider>();
// final products = provider.products; // מסונן לפי חיפוש/סינון
//
// // בפעולות:
// context.read<ProductsProvider>().setSearchQuery('חלב');
// context.read<ProductsProvider>().setListType('weekly_groceries');
//
// // חיפוש ספציפי:
// final product = await provider.getProductByBarcode('1234567890');
// final product2 = provider.getByName('חלב 3%');
// ```
//
// 🔄 State Flow:
// 1. Constructor → _initialize() (אם skipInitialLoad=false)
// 2. updateUserContext() → חיבור ל-UserContext
// 3. _onUserChanged() → טעינה אוטומטית בשינויים
// 4. loadProducts() → טעינה מ-Repository
// 5. setSearchQuery/setCategory/setListType → סינון
// 6. notifyListeners() → UI מתעדכן
//
// Version: 3.1 (קוד מנוקה - הוסרו cache ו-progress מיותרים)

import 'package:flutter/foundation.dart';
import '../repositories/products_repository.dart';
import '../config/list_type_mappings.dart';
import 'user_context.dart';

class ProductsProvider with ChangeNotifier {
  final ProductsRepository _repository;

  // 👤 UserContext Integration
  UserContext? _userContext;
  bool _listening = false;

  // State
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _hasInitialized = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _products = [];
  List<String> _categories = [];
  DateTime? _lastUpdated;

  // Search & Filter
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedListType;

  ProductsProvider({
    required ProductsRepository repository,
    bool skipInitialLoad = false,
  }) : _repository = repository {
    if (!skipInitialLoad) {
      _initialize();
    }
  }

  // === UserContext Integration ===
  
  /// 🔗 חיבור ל-UserContext - מתעדכן אוטומטית עם שינויי משתמש
  void updateUserContext(UserContext newContext) {
    debugPrint('🔗 ProductsProvider.updateUserContext()');
    
    // נקה listener קודם אם קיים
    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
      _listening = false;
    }

    // עדכן UserContext
    _userContext = newContext;

    // הוסף listener חדש
    _userContext!.addListener(_onUserChanged);
    _listening = true;

    // טען נתונים אם המשתמש מחובר
    if (_userContext?.isLoggedIn == true && !_hasInitialized) {
      _initialize();
    } else if (_userContext?.isLoggedIn == false) {
      _clearData();
    }
  }

  /// 🔄 מופעל כאשר UserContext משתנה (התחברות/התנתקות)
  void _onUserChanged() {
    debugPrint('🔄 ProductsProvider._onUserChanged() - isLoggedIn: ${_userContext?.isLoggedIn}');
    
    if (_userContext?.isLoggedIn == true) {
      // משתמש התחבר - טען מוצרים
      if (!_hasInitialized) {
        _initialize();
      }
    } else {
      // משתמש התנתק - נקה נתונים
      _clearData();
    }
  }

  /// 🧹 ניקוי נתונים (כשמשתמש מתנתק)
  void _clearData() {
    debugPrint('🧹 ProductsProvider._clearData()');
    _products.clear();
    _categories.clear();
    _hasInitialized = false;
    _lastUpdated = null;
    _errorMessage = null;
    notifyListeners();
  }

  // === Getters ===
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get hasInitialized => _hasInitialized;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  UserContext? get userContext => _userContext;
  
  /// מוצרים מסוננים (לפי חיפוש/קטגוריה/סוג רשימה)
  /// 
  /// Flutter כבר עושה caching אוטומטי של getters, אין צורך ב-cache ידני
  List<Map<String, dynamic>> get products => _getFilteredProducts();
  
  List<Map<String, dynamic>> get allProducts => List.unmodifiable(_products);
  List<String> get categories => List.unmodifiable(_categories);
  DateTime? get lastUpdated => _lastUpdated;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String? get selectedListType => _selectedListType;
  bool get isEmpty => _products.isEmpty;

  // 📊 סטטיסטיקות
  int get totalProducts {
    return _products.length;
  }

  int get productsWithPrice {
    return _products.where((p) => p['price'] != null).length;
  }

  int get productsWithoutPrice {
    return _products.where((p) => p['price'] == null).length;
  }

  // === Initialization ===
  Future<void> _initialize() async {
    debugPrint('🚀 ProductsProvider._initialize()');
    
    await loadProducts();
    _hasInitialized = true;
  }

  /// 🆕 אתחול ו-טעינה ידנית (כשמשתמש מתחבר)
  Future<void> initializeAndLoad() async {
    if (_hasInitialized) return;
    await _initialize();
  }

  // === Load Products ===
  Future<void> loadProducts() async {
    if (_isLoading) return;

    debugPrint('📥 ProductsProvider.loadProducts() - מתחיל...');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _repository.getAllProducts();
      _categories = await _repository.getCategories();
      _lastUpdated = DateTime.now();
      _errorMessage = null;

      debugPrint('✅ נטענו ${_products.length} מוצרים בהצלחה');
      debugPrint('   📊 סה"כ מוצרים: $totalProducts');
      debugPrint('   💰 עם מחיר: $productsWithPrice');
      debugPrint('   ❌ ללא מחיר: $productsWithoutPrice');
      debugPrint('   🏷️ קטגוריות: ${_categories.length}');
    } catch (e) {
      _errorMessage = 'שגיאה בטעינת מוצרים: $e';
      debugPrint('❌ שגיאה בטעינת מוצרים: $e');
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === Refresh Products (עדכון מחירים) ===
  Future<void> refreshProducts({bool force = false}) async {
    if (_isRefreshing) return;

    debugPrint('🔄 ProductsProvider.refreshProducts(force: $force)');
    _isRefreshing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.refreshProducts(force: force);
      _products = await _repository.getAllProducts();
      _categories = await _repository.getCategories();
      _lastUpdated = DateTime.now();
      _errorMessage = null;

      debugPrint('✅ רענון הושלם - $totalProducts מוצרים ($productsWithPrice עם מחיר)');
    } catch (e) {
      _errorMessage = 'שגיאה ברענון מוצרים: $e';
      debugPrint('❌ שגיאה ברענון מוצרים: $e');
      notifyListeners();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  // === Retry (Error Recovery) ===
  /// ניסיון חוזר לאחר שגיאה
  Future<void> retry() async {
    debugPrint('🔄 ProductsProvider.retry() - מנסה שוב...');
    _errorMessage = null;
    await loadProducts();
  }

  // === Search ===
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    
    debugPrint('🔍 ProductsProvider.setSearchQuery("$query")');
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    debugPrint('🧹 ProductsProvider.clearSearch()');
    _searchQuery = '';
    notifyListeners();
  }

  // === Filter by List Type ===
  void setListType(String? listType) {
    if (_selectedListType == listType) return;
    
    debugPrint('🎯 ProductsProvider.setListType("$listType")');
    _selectedListType = listType;
    _selectedCategory = null;
    notifyListeners();
  }

  void clearListType({bool notify = true}) {
    debugPrint('🧹 ProductsProvider.clearListType()');
    _selectedListType = null;
    if (notify) {
      notifyListeners();
    }
  }

  // === Get Relevant Categories for Current List Type ===
  List<String> get relevantCategories {
    if (_selectedListType == null) return _categories;
    
    final typeCategories = ListTypeMappings.getCategoriesForType(_selectedListType!);
    
    return _categories.where((cat) {
      return _isCategoryRelevantForListType(cat, typeCategories);
    }).toList();
  }

  // === Get Suggested Stores for Current List Type ===
  List<String> get suggestedStores {
    if (_selectedListType == null) return [];
    return ListTypeMappings.getStoresForType(_selectedListType!);
  }

  void setCategory(String? category) {
    if (_selectedCategory == category) return;
    
    debugPrint('🏷️ ProductsProvider.setCategory("$category")');
    _selectedCategory = category;
    notifyListeners();
  }

  void clearCategory() {
    debugPrint('🧹 ProductsProvider.clearCategory()');
    _selectedCategory = null;
    notifyListeners();
  }

  // === Helper: Check if category is relevant for list type ===
  bool _isCategoryRelevantForListType(
    String productCategory,
    List<String> typeCategories,
  ) {
    return typeCategories.any(
      (typeCat) => productCategory.toLowerCase().contains(typeCat.toLowerCase()) ||
                   typeCat.toLowerCase().contains(productCategory.toLowerCase()),
    );
  }

  // === Get Filtered Products ===
  List<Map<String, dynamic>> _getFilteredProducts() {
    var filtered = List<Map<String, dynamic>>.from(_products);

    // Filter by list type
    if (_selectedListType != null) {
      final typeCategories = ListTypeMappings.getCategoriesForType(_selectedListType!);
      
      filtered = filtered.where((p) {
        final productCategory = p['category'] as String? ?? '';
        return _isCategoryRelevantForListType(productCategory, typeCategories);
      }).toList();
    }

    // Filter by category
    if (_selectedCategory != null) {
      filtered = filtered
          .where((p) => p['category'] == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (p) =>
                (p['name'] as String).toLowerCase().contains(lowerQuery) ||
                (p['category'] as String).toLowerCase().contains(lowerQuery) ||
                (p['brand'] as String?)?.toLowerCase().contains(lowerQuery) ==
                    true,
          )
          .toList();
    }

    return filtered;
  }

  // === Get Product by Barcode ===
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    try {
      debugPrint('🔍 ProductsProvider.getProductByBarcode("$barcode")');
      return await _repository.getProductByBarcode(barcode);
    } catch (e) {
      debugPrint('❌ getProductByBarcode שגיאה: $e');
      _errorMessage = 'שגיאה בחיפוש ברקוד: $e';
      notifyListeners();
      return null;
    }
  }

  // === Get Product by Name (sync) ===
  /// חיפוש מוצר לפי שם (מחזיר את ההתאמה הראשונה)
  /// 
  /// מחפש התאמה מדויקת, ואם לא מוצא - מחפש התאמה חלקית.
  /// 
  /// Returns: Map עם נתוני המוצר או null אם לא נמצא
  Map<String, dynamic>? getByName(String name) {
    if (name.isEmpty || _products.isEmpty) return null;

    final lowerName = name.toLowerCase().trim();

    // 1. נסה התאמה מדויקת
    final exact = _products.firstWhere(
      (p) => (p['name'] as String).toLowerCase().trim() == lowerName,
      orElse: () => {},
    );

    if (exact.isNotEmpty) {
      debugPrint('✅ getByName: התאמה מדויקת - "${exact['name']}"');
      return exact;
    }

    // 2. נסה התאמה חלקית
    final partial = _products.firstWhere(
      (p) => (p['name'] as String).toLowerCase().contains(lowerName),
      orElse: () => {},
    );

    if (partial.isNotEmpty) {
      debugPrint('✅ getByName: התאמה חלקית - "${partial['name']}"');
    } else {
      debugPrint('❌ getByName: לא נמצא מוצר עבור "$name"');
    }

    return partial.isNotEmpty ? partial : null;
  }

  // === Search Products (async) ===
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      debugPrint('🔍 ProductsProvider.searchProducts("$query")');
      return await _repository.searchProducts(query);
    } catch (e) {
      debugPrint('❌ searchProducts שגיאה: $e');
      _errorMessage = 'שגיאה בחיפוש מוצרים: $e';
      notifyListeners();
      return [];
    }
  }

  // === Get Products by Category (async) ===
  Future<List<Map<String, dynamic>>> getProductsByCategory(
    String category,
  ) async {
    try {
      debugPrint('🏷️ ProductsProvider.getProductsByCategory("$category")');
      return await _repository.getProductsByCategory(category);
    } catch (e) {
      debugPrint('❌ getProductsByCategory שגיאה: $e');
      _errorMessage = 'שגיאה בטעינת קטגוריה: $e';
      notifyListeners();
      return [];
    }
  }

  // === Statistics ===
  int get filteredProductsCount => _getFilteredProducts().length;

  Map<String, int> get productsByCategory {
    final map = <String, int>{};
    for (final product in _products) {
      final category = product['category'] as String;
      map[category] = (map[category] ?? 0) + 1;
    }
    return map;
  }

  // === Clear All ===
  void clearAll() {
    debugPrint('🧹 ProductsProvider.clearAll()');
    _searchQuery = '';
    _selectedCategory = null;
    _selectedListType = null;
    _errorMessage = null;
    notifyListeners();
  }

  // === Dispose ===
  @override
  void dispose() {
    debugPrint('🗑️ ProductsProvider.dispose()');
    
    // ✅ נקה UserContext listener
    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
      _listening = false;
    }
    
    _products.clear();
    _categories.clear();
    super.dispose();
  }
}
