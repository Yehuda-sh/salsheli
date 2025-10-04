// 📄 lib/providers/products_provider.dart
//
// 🎯 Provider למוצרים - ניהול state של מוצרים
// - טעינה מקומית (מהירה)
// - עדכון מחירים מ-API (אופציונלי)
// - חיפוש וסינון
// 🐛 עם Logging מפורט לטרמינל

import 'package:flutter/foundation.dart';
import '../repositories/products_repository.dart';
import '../repositories/hybrid_products_repository.dart';

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

  // Search & Filter
  String _searchQuery = '';
  String? _selectedCategory;

  ProductsProvider({
    required ProductsRepository repository,
    bool skipInitialLoad = false, // ⚠️ אם true - לא טוען מייד
  }) : _repository = repository {
    debugPrint('\n🚀 ProductsProvider: נוצר (skipInitialLoad: $skipInitialLoad)');
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
  List<Map<String, dynamic>> get products => _getFilteredProducts();
  List<Map<String, dynamic>> get allProducts => List.unmodifiable(_products);
  List<String> get categories => List.unmodifiable(_categories);
  DateTime? get lastUpdated => _lastUpdated;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  bool get isEmpty => _products.isEmpty;

  // 📊 סטטיסטיקות (רק אם זה Hybrid)
  int get totalProducts {
    if (_repository is HybridProductsRepository) {
      return (_repository as HybridProductsRepository).totalProducts;
    }
    return _products.length;
  }

  int get productsWithPrice {
    if (_repository is HybridProductsRepository) {
      return (_repository as HybridProductsRepository).productsWithPrice;
    }
    return _products.where((p) => p['price'] != null).length;
  }

  int get productsWithoutPrice {
    if (_repository is HybridProductsRepository) {
      return (_repository as HybridProductsRepository).productsWithoutPrice;
    }
    return _products.where((p) => p['price'] == null).length;
  }

  // === Initialization ===
  Future<void> _initialize() async {
    debugPrint('═══════════════════════════════════════════');
    debugPrint('🔧 ProductsProvider._initialize()');
    debugPrint('═══════════════════════════════════════════');
    
    // אתחול Hybrid Repository אם צריך
    if (_repository is HybridProductsRepository) {
      debugPrint('📞 קורא ל-HybridProductsRepository.initialize()');
      await (_repository as HybridProductsRepository).initialize();
    }

    await loadProducts();
    _hasInitialized = true; // ✅ סימון שאותחל
  }

  /// 🆕 אתחול ו-טעינה ידנית (כשמשתמש מתחבר)
  Future<void> initializeAndLoad() async {
    if (_hasInitialized) {
      debugPrint('⚠️ initializeAndLoad: כבר אותחל, מדלג');
      return;
    }
    debugPrint('🚀 initializeAndLoad: מתחיל אתחול...');
    await _initialize();
  }

  // === Load Products ===
  Future<void> loadProducts() async {
    if (_isLoading) {
      debugPrint('⚠️ loadProducts: כבר טוען, מדלג');
      return;
    }

    debugPrint('\n═══════════════════════════════════════════');
    debugPrint('📥 ProductsProvider.loadProducts() - התחלה');
    debugPrint('═══════════════════════════════════════════');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('📞 קורא ל-repository.getAllProducts()');
      _products = await _repository.getAllProducts();
      
      debugPrint('📞 קורא ל-repository.getCategories()');
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
      debugPrint('❌ שגיאה בטעינת מוצרים:');
      debugPrint('   $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('═══════════════════════════════════════════\n');
    }
  }

  // === Refresh Products (עדכון מחירים) ===
  Future<void> refreshProducts({bool force = false}) async {
    if (_isRefreshing) {
      debugPrint('⚠️ refreshProducts: כבר מרענן, מדלג');
      return;
    }

    debugPrint('\n═══════════════════════════════════════════');
    debugPrint('🔄 ProductsProvider.refreshProducts(force: $force)');
    debugPrint('═══════════════════════════════════════════');

    _isRefreshing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('📞 קורא ל-repository.refreshProducts()');
      await _repository.refreshProducts(force: force);
      
      debugPrint('📞 קורא ל-repository.getAllProducts()');
      _products = await _repository.getAllProducts();
      
      debugPrint('📞 קורא ל-repository.getCategories()');
      _categories = await _repository.getCategories();
      
      _lastUpdated = DateTime.now();
      _errorMessage = null;

      debugPrint('✅ רענון הושלם בהצלחה');
      debugPrint('   📊 סה"כ מוצרים: $totalProducts');
      debugPrint('   💰 עם מחיר: $productsWithPrice');
      debugPrint('   ❌ ללא מחיר: $productsWithoutPrice');
    } catch (e) {
      _errorMessage = 'שגיאה ברענון מוצרים: $e';
      debugPrint('❌ שגיאה ברענון מוצרים:');
      debugPrint('   $e');
    } finally {
      _isRefreshing = false;
      notifyListeners();
      debugPrint('═══════════════════════════════════════════\n');
    }
  }

  // === Search ===
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    debugPrint('🔍 חיפוש: "$query"');
    _searchQuery = query;
    notifyListeners();
    debugPrint('   נמצאו: ${_getFilteredProducts().length} מוצרים');
  }

  void clearSearch() {
    debugPrint('🔍 ניקוי חיפוש');
    _searchQuery = '';
    notifyListeners();
  }

  // === Filter by Category ===
  void setCategory(String? category) {
    if (_selectedCategory == category) return;
    debugPrint('🏷️ סינון לפי קטגוריה: $category');
    _selectedCategory = category;
    notifyListeners();
    debugPrint('   נמצאו: ${_getFilteredProducts().length} מוצרים');
  }

  void clearCategory() {
    debugPrint('🏷️ ניקוי סינון קטגוריה');
    _selectedCategory = null;
    notifyListeners();
  }

  // === Get Filtered Products ===
  List<Map<String, dynamic>> _getFilteredProducts() {
    var filtered = List<Map<String, dynamic>>.from(_products);

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
      debugPrint('🔍 חיפוש מוצר לפי ברקוד: $barcode');
      final product = await _repository.getProductByBarcode(barcode);
      if (product != null) {
        debugPrint('   ✅ נמצא: ${product['name']}');
      } else {
        debugPrint('   ❌ לא נמצא');
      }
      return product;
    } catch (e) {
      debugPrint('❌ שגיאה בחיפוש מוצר לפי ברקוד: $e');
      return null;
    }
  }

  // === Search Products (async) ===
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      debugPrint('🔍 חיפוש async: "$query"');
      final results = await _repository.searchProducts(query);
      debugPrint('   ✅ נמצאו: ${results.length} תוצאות');
      return results;
    } catch (e) {
      debugPrint('❌ שגיאה בחיפוש מוצרים: $e');
      return [];
    }
  }

  // === Get Products by Category (async) ===
  Future<List<Map<String, dynamic>>> getProductsByCategory(
    String category,
  ) async {
    try {
      debugPrint('🏷️ קבלת מוצרים לפי קטגוריה: $category');
      final results = await _repository.getProductsByCategory(category);
      debugPrint('   ✅ נמצאו: ${results.length} מוצרים');
      return results;
    } catch (e) {
      debugPrint('❌ שגיאה בקבלת מוצרים לפי קטגוריה: $e');
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
    debugPrint('🗑️ ניקוי כל הסינונים');
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }
}
