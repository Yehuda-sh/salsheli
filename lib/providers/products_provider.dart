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
// Version: 3.2 - Lazy Loading (טעינה איטית)
// 🚀 חיסכון ענק בביצועים:
//    - טעינה ראשונית: רק 100 מוצרים (מהיר מאוד!)
//    - טעינה ברקע: את השאר בחלקים של 200 (לא חוסם UI)
//    - loadMore(): למשתמש שרוצה scroll אינסופי

import 'dart:async';

import 'package:flutter/foundation.dart';
import '../repositories/local_products_repository.dart';
import '../repositories/products_repository.dart';
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

  // 📊 Lazy Loading State
  bool _hasLoadedAll = false;
  bool _isLoadingMore = false;
  static const int _batchSize = 100; // טען 100 מוצרים בכל פעם

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
  
  // 📊 Lazy Loading Getters
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => !_hasLoadedAll && _hasInitialized;
  
  /// מוצרים מסוננים (לפי חיפוש/קטגוריה/סוג רשימה)
  /// 
  /// Flutter כבר עושה caching אוטומטי של getters, אין צורך ב-cache ידני
  List<Map<String, dynamic>> get products => _getFilteredProducts();
  
  List<Map<String, dynamic>> get allProducts => List.unmodifiable(_products);
  List<String> get categories => List.unmodifiable(_categories);
  
  /// קטגוריות רלוונטיות לסוג הרשימה שנבחר
  /// 
  /// אם לא נבחר סוג רשימה - מחזיר את כל הקטגוריות
  /// אם נבחר סוג רשימה - מחזיר רק קטגוריות של המוצרים המסוננים
  List<String> get relevantCategories {
    if (_selectedListType == null) {
      return List.unmodifiable(_categories);
    }
    
    // חלץ קטגוריות ייחודיות מהמוצרים המסוננים
    final filtered = _getFilteredProducts();
    final categoriesSet = <String>{};
    
    for (final product in filtered) {
      final category = product['category'] as String?;
      if (category != null && category.isNotEmpty) {
        categoriesSet.add(category);
      }
    }

    return categoriesSet.toList()..sort();
  }
  
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
    await loadProducts();
    _hasInitialized = true;
  }

  /// 🆕 אתחול ו-טעינה ידנית (כשמשתמש מתחבר)
  Future<void> initializeAndLoad() async {
    if (_hasInitialized) return;
    await _initialize();
  }

  // === Load Products (Lazy Loading) ===
  Future<void> loadProducts() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _products.clear(); // נקה מוצרים קודמים
    _hasLoadedAll = false;
    notifyListeners();

    try {
      // ⚡ טוען מוצרים ראשונים
      final initialProducts = await _loadProductsByTypeOrAll(limit: _batchSize);

      // 🏷️ חלץ קטגוריות מהמוצרים שנטענו (לא מה-cache המלא!)
      _categories = _extractCategories(initialProducts);

      _products = initialProducts;
      _hasLoadedAll = initialProducts.length < _batchSize; // אם קיבלנו פחות מ-100, סיימנו
      _lastUpdated = DateTime.now();
      _errorMessage = null;

      // 🚀 טען את השאר ברקע (לא חוסם UI)
      if (hasMore) {
        unawaited(_loadAllInBackground());
      }
    } catch (e) {
      _errorMessage = 'שגיאה בטעינת מוצרים: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔄 טוען את כל המוצרים ברקע (אחרי הטעינה הראשונית)
  ///
  /// לא חוסם את ה-UI - רק מעדכן אותו כל 200 מוצרים
  Future<void> _loadAllInBackground() async {
    if (_hasLoadedAll || _isLoadingMore) return;

    _isLoadingMore = true;

    try {
      int loadedCount = _products.length;
      const step = 200; // טען 200 בכל שלב

      while (!_hasLoadedAll) {
        // המתן קצת כדי לא לחסום את ה-UI
        await Future.delayed(const Duration(milliseconds: 50));

        // טען עוד מוצרים
        final moreProducts = await _loadProductsByTypeOrAll(
          limit: step,
          offset: loadedCount,
        );

        if (moreProducts.isEmpty || moreProducts.length < step) {
          _hasLoadedAll = true;
        }

        _products.addAll(moreProducts);
        loadedCount += moreProducts.length;

        // 🏷️ עדכן קטגוריות מכל המוצרים שנטענו עד כה
        _categories = _extractCategories(_products);

        // עדכן UI כל 200 מוצרים
        notifyListeners();
      }
    } catch (e) {
      // לא משנים את _errorMessage כי זו טעינה ברקע
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// 📥 טוען עוד מוצרים (למקרה שהמשתמש רוצה "טען עוד")
  ///
  /// שימושי אם רוצים scroll אינסופי במקום טעינה אוטומטית ברקע
  Future<void> loadMore() async {
    if (_isLoadingMore || _hasLoadedAll || _isLoading) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final currentCount = _products.length;
      final moreProducts = await _loadProductsByTypeOrAll(
        limit: _batchSize,
        offset: currentCount,
      );

      if (moreProducts.isEmpty || moreProducts.length < _batchSize) {
        _hasLoadedAll = true;
      } else {
        _products.addAll(moreProducts);
      }
    } catch (e) {
      _errorMessage = 'שגיאה בטעינת מוצרים נוספים: $e';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// 🏷️ חולץ קטגוריות מרשימת מוצרים
  List<String> _extractCategories(List<Map<String, dynamic>> products) {
    final categoriesSet = <String>{};

    for (final product in products) {
      final category = product['category'] as String?;
      if (category != null && category.isNotEmpty) {
        categoriesSet.add(category);
      }
    }

    return categoriesSet.toList()..sort();
  }

  /// 📥 טוען מוצרים לפי list_type או כולם
  ///
  /// אם יש _selectedListType ו-Repository הוא LocalProductsRepository:
  /// → קורא ל-getProductsByListType() (טוען קובץ JSON ספציפי)
  /// אחרת:
  /// → קורא ל-getAllProducts() (טוען מ-supermarket)
  Future<List<Map<String, dynamic>>> _loadProductsByTypeOrAll({
    int? limit,
    int? offset,
  }) async {
    // אם יש list_type נבחר ו-Repository תומך ב-getProductsByListType
    if (_selectedListType != null && _repository is LocalProductsRepository) {
      return await _repository.getProductsByListType(
        _selectedListType!,
        limit: limit,
        offset: offset,
      );
    }

    // אחרת - טען הכל (מ-supermarket או Firebase)
    return await _repository.getAllProducts(
      limit: limit,
      offset: offset,
    );
  }

  // === Refresh Products (עדכון מחירים) ===
  Future<void> refreshProducts({bool force = false}) async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.refreshProducts(force: force);
      _products = await _loadProductsByTypeOrAll();

      // 🏷️ חלץ קטגוריות מהמוצרים שנטענו
      _categories = _extractCategories(_products);

      _lastUpdated = DateTime.now();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'שגיאה ברענון מוצרים: $e';
      notifyListeners();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  // === Retry (Error Recovery) ===
  /// ניסיון חוזר לאחר שגיאה
  Future<void> retry() async {
    _errorMessage = null;
    await loadProducts();
  }

  // === Search ===
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;

    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // === Filter by List Type ===
  void setListType(String? listType) {
    if (_selectedListType == listType) return;

    _selectedListType = listType;
    _selectedCategory = null;

    // 🔄 טען מחדש מוצרים מהקובץ החדש!
    loadProducts();
  }

  void clearListType({bool notify = true}) {
    _selectedListType = null;
    if (notify) {
      notifyListeners();
    }
  }

  void setCategory(String? category) {
    if (_selectedCategory == category) return;

    _selectedCategory = category;
    notifyListeners();
  }

  void clearCategory() {
    _selectedCategory = null;
    notifyListeners();
  }

  // === Get Filtered Products ===
  List<Map<String, dynamic>> _getFilteredProducts() {
    var filtered = List<Map<String, dynamic>>.from(_products);

    // ⚠️ אין צורך בסינון לפי list_type - המוצרים כבר נטענו מהקובץ הנכון!
    // (pharmacy.json, bakery.json וכו')

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
      return exact;
    }

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
      return await _repository.getProductsByCategory(category);
    } catch (e) {
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
    _searchQuery = '';
    _selectedCategory = null;
    _selectedListType = null;
    _errorMessage = null;
    notifyListeners();
  }

  // === Dispose ===
  @override
  void dispose() {
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
