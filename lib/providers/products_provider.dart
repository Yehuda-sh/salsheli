// 📄 File: lib/providers/products_provider.dart
//
// 🎯 Purpose: Provider למוצרים - ניהול state מרכזי של כל המוצרים באפליקציה
//
// 📦 Dependencies:
// - ProductsRepository: ממשק לטעינת מוצרים
// - HybridProductsRepository: מימוש היברידי (Local + Firebase + API)
// - ListTypeMappings: מיפוי בין סוגי רשימות לקטגוריות
//
// ✨ Features:
// - 📥 טעינה חכמה: Local (מהיר) → Firebase → API → Fallback
// - 🔄 רענון מחירים: עדכון מחירים מ-API
// - 🔍 חיפוש: לפי שם, ברקוד, קטגוריה
// - 🎯 סינון: לפי סוג רשימה, קטגוריה, טקסט
// - 📊 סטטיסטיקות: כמה מוצרים, עם/בלי מחיר
// - 💾 Cache: מוצרים נשמרים במטמון לביצועים
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
// 2. loadProducts() → טעינה מ-Repository
// 3. setSearchQuery/setCategory/setListType → סינון
// 4. notifyListeners() → UI מתעדכן
//
// Version: 2.0 (עם getByName + logging מלא)

import 'package:flutter/foundation.dart';
import '../repositories/products_repository.dart';
import '../repositories/hybrid_products_repository.dart';
import '../config/list_type_mappings.dart';

class ProductsProvider with ChangeNotifier {
  final ProductsRepository _repository;

  // State
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _hasInitialized = false; // 🆕 דגל אתחול
  String? _errorMessage;
  List<Map<String, dynamic>> _products = [];
  List<String> _categories = [];
  DateTime? _lastUpdated;
  
  // 📊 Progress tracking (NEW)
  int _loadingProgress = 0;
  int _loadingTotal = 0;

  // Search & Filter
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedListType; // ✅ חדש - סוג הרשימה

  // 💾 Cache for filtered products
  List<Map<String, dynamic>> _cachedFiltered = [];
  String _cacheKey = '';

  ProductsProvider({
    required ProductsRepository repository,
    bool skipInitialLoad = false, // ⚠️ אם true - לא טוען מייד
  }) : _repository = repository {
    if (!skipInitialLoad) {
      _initialize();
    }
  }

  // === Getters ===
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get hasInitialized => _hasInitialized; // 🆕 גישה פומבית
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  
  // 📊 Progress getters (NEW)
  int get loadingProgress => _loadingProgress;
  int get loadingTotal => _loadingTotal;
  double get loadingPercentage => _loadingTotal > 0 
      ? (_loadingProgress / _loadingTotal) * 100 
      : 0.0;
  
  // 💾 Cached filtered products
  List<Map<String, dynamic>> get products {
    final key = '$_searchQuery|$_selectedCategory|$_selectedListType';
    
    // Cache hit
    if (key == _cacheKey && _cachedFiltered.isNotEmpty) {
      return _cachedFiltered;
    }
    
    // Cache miss - filter products
    _cachedFiltered = _getFilteredProducts();
    _cacheKey = key;
    
    return _cachedFiltered;
  }
  
  List<Map<String, dynamic>> get allProducts => List.unmodifiable(_products);
  List<String> get categories => List.unmodifiable(_categories);
  DateTime? get lastUpdated => _lastUpdated;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String? get selectedListType => _selectedListType; // ✅ חדש
  bool get isEmpty => _products.isEmpty;

  // 📊 סטטיסטיקות (רק אם זה Hybrid)
  int get totalProducts {
    final repo = _repository;
    if (repo is HybridProductsRepository) {
      return repo.totalProducts;
    }
    return _products.length;
  }

  int get productsWithPrice {
    final repo = _repository;
    if (repo is HybridProductsRepository) {
      return repo.productsWithPrice;
    }
    return _products.where((p) => p['price'] != null).length;
  }

  int get productsWithoutPrice {
    final repo = _repository;
    if (repo is HybridProductsRepository) {
      return repo.productsWithoutPrice;
    }
    return _products.where((p) => p['price'] == null).length;
  }

  // === Initialization ===
  Future<void> _initialize() async {
    // אתחול Hybrid Repository אם צריך
    final repo = _repository;
    if (repo is HybridProductsRepository) {
      await repo.initialize();
    }

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
      notifyListeners(); // ✅ הוסף - ה-UI צריך לדעת על השגיאה
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === Refresh Products (עדכון מחירים) ===
  Future<void> refreshProducts({bool force = false}) async {
    if (_isRefreshing) return;

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
      notifyListeners(); // ✅ הוסף - ה-UI צריך לדעת על השגיאה
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
    _searchQuery = query;
    _cacheKey = ''; // ✅ נקה cache
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _cacheKey = ''; // ✅ נקה cache
    notifyListeners();
  }

  // === Filter by List Type (NEW) ===
  void setListType(String? listType) {
    if (_selectedListType == listType) return;
    _selectedListType = listType;
    _selectedCategory = null; // נקה קטגוריה נבחרת
    _cacheKey = ''; // ✅ נקה cache
    notifyListeners();
  }

  void clearListType() {
    _selectedListType = null;
    _cacheKey = ''; // ✅ נקה cache
    notifyListeners();
  }

  // === Get Relevant Categories for Current List Type (NEW) ===
  List<String> get relevantCategories {
    if (_selectedListType == null) return _categories;
    
    final typeCategories = ListTypeMappings.getCategoriesForType(_selectedListType!);
    
    // החזר רק קטגוריות שקיימות במוצרים
    return _categories.where((cat) {
      return _isCategoryRelevantForListType(cat, typeCategories);
    }).toList();
  }

  // === Get Suggested Stores for Current List Type (NEW) ===
  List<String> get suggestedStores {
    if (_selectedListType == null) return [];
    return ListTypeMappings.getStoresForType(_selectedListType!);
  }
  void setCategory(String? category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _cacheKey = ''; // ✅ נקה cache
    notifyListeners();
  }

  void clearCategory() {
    _selectedCategory = null;
    _cacheKey = ''; // ✅ נקה cache
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

    // ✅ Filter by list type - סינון לפי סוג הרשימה
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
      return await _repository.getProductByBarcode(barcode);
    } catch (e) {
      debugPrint('❌ getProductByBarcode שגיאה: $e');
      _errorMessage = 'שגיאה בחיפוש ברקוד: $e';
      notifyListeners(); // ✅ הוסף - ה-UI צריך לדעת על השגיאה
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

    if (exact.isNotEmpty) return exact;

    // 2. נסה התאמה חלקית
    final partial = _products.firstWhere(
      (p) => (p['name'] as String).toLowerCase().contains(lowerName),
      orElse: () => {},
    );

    return partial.isNotEmpty ? partial : null;
  }

  // === Search Products (async) ===
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      return await _repository.searchProducts(query);
    } catch (e) {
      debugPrint('❌ searchProducts שגיאה: $e');
      _errorMessage = 'שגיאה בחיפוש מוצרים: $e';
      notifyListeners(); // ✅ הוסף - ה-UI צריך לדעת על השגיאה
      return [];
    }
  }

  // === Get Products by Category (async) ===
  Future<List<Map<String, dynamic>>> getProductsByCategory(
    String category,
  ) async {
    try {
      return await _repository.getProductsByCategory(category);
    } catch (e) {
      debugPrint('❌ getProductsByCategory שגיאה: $e');
      _errorMessage = 'שגיאה בטעינת קטגוריה: $e';
      notifyListeners(); // ✅ הוסף - ה-UI צריך לדעת על השגיאה
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
    _errorMessage = null; // ✅ נקה שגיאות
    _cacheKey = ''; // ✅ נקה cache
    _loadingProgress = 0; // ✅ נקה progress
    _loadingTotal = 0;
    notifyListeners();
  }

  // === Dispose ===
  @override
  void dispose() {
    debugPrint('🗑️ ProductsProvider.dispose()');
    _cachedFiltered.clear();
    _products.clear();
    _categories.clear();
    super.dispose();
  }
}
