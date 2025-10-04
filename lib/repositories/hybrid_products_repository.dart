// 📄 lib/repositories/hybrid_products_repository.dart
//
// 🎯 Repository היברידי - משלב מקומי + API
// - טוען מוצרים מקומית (מהיר)
// - מעדכן מחירים מ-API (אופציונלי)
// - מוסיף מוצרים חדשים אוטומטית

import 'package:flutter/foundation.dart';
import '../services/published_prices_service.dart';
import 'local_products_repository.dart';
import 'products_repository.dart';
import '../models/product_entity.dart';

class HybridProductsRepository implements ProductsRepository {
  final LocalProductsRepository _localRepo;
  final PublishedPricesService _apiService;

  bool _isInitialized = false;
  bool _isPriceUpdateInProgress = false;

  HybridProductsRepository({
    required LocalProductsRepository localRepo,
    PublishedPricesService? apiService,
  })  : _localRepo = localRepo,
        _apiService = apiService ?? PublishedPricesService();

  /// אתחול - טוען מוצרים מה-API אם ה-DB ריק
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ HybridProductsRepository.initialize: כבר אותחל, מדלג');
      return;
    }

    try {
      debugPrint('\n🚀 HybridProductsRepository.initialize() - מתחיל...');
      debugPrint('   📊 בודק מספר מוצרים מקומיים: ${_localRepo.totalProducts}');

      // אם אין מוצרים מקומית - טוען מה-API
      if (_localRepo.totalProducts == 0) {
        debugPrint('   ➡️ DB ריק - טוען מה-API...');
        await _loadInitialProducts();
      } else {
        debugPrint('   ✅ נמצאו ${_localRepo.totalProducts} מוצרים מקומית - לא צריך לטעון מה-API');
      }

      _isInitialized = true;
      debugPrint('✅ HybridProductsRepository.initialize: הושלם בהצלחה\n');
    } catch (e) {
      debugPrint('❌ שגיאה באתחול HybridProductsRepository: $e');
    }
  }

  /// טעינת מוצרים ראשונית מה-API (ללא מחירים)
  Future<void> _loadInitialProducts() async {
    try {
      debugPrint('📥 מנסה לטעון מוצרים מ-API...');
      final apiProducts = await _apiService.getProducts(forceRefresh: true);

      if (apiProducts.isEmpty) {
        debugPrint('⚠️ לא נמצאו מוצרים ב-API, טוען fallback מקומי');
        await _loadFallbackProducts();
        return;
      }

      // המרה ל-ProductEntity (ללא מחירים)
      final entities = apiProducts.map((p) {
        final appFormat = p.toAppFormat();
        return ProductEntity(
          barcode: appFormat['barcode'] ?? '',
          name: appFormat['name'] ?? '',
          category: appFormat['category'] ?? 'אחר',
          brand: appFormat['brand'] ?? '',
          unit: appFormat['unit'] ?? '',
          icon: appFormat['icon'] ?? '🛒',
          // לא שומרים מחיר בשלב זה
          currentPrice: null,
          lastPriceStore: null,
          lastPriceUpdate: null,
        );
      }).toList();

      await _localRepo.saveProducts(entities);
      debugPrint('✅ נשמרו ${entities.length} מוצרים (ללא מחירים)');
    } catch (e) {
      debugPrint('❌ שגיאה בטעינת מוצרים מ-API: $e');
      debugPrint('🔄 טוען מוצרים דמה במקום...');
      await _loadFallbackProducts();
    }
  }

  /// טעינת מוצרים דמה כ-fallback
  Future<void> _loadFallbackProducts() async {
    final fallbackProducts = [
      ProductEntity(
        barcode: '7290000000001',
        name: 'חלב 3%',
        category: 'מוצרי חלב',
        brand: 'תנובה',
        unit: 'ליטר',
        icon: '🥛',
      ),
      ProductEntity(
        barcode: '7290000000010',
        name: 'לחם שחור',
        category: 'מאפים',
        brand: 'אנג\'ל',
        unit: 'יחידה',
        icon: '🍞',
      ),
      ProductEntity(
        barcode: '7290000000020',
        name: 'גבינה צהובה',
        category: 'מוצרי חלב',
        brand: 'תנובה',
        unit: '200 גרם',
        icon: '🧀',
      ),
      ProductEntity(
        barcode: '7290000000030',
        name: 'עגבניות',
        category: 'ירקות',
        brand: 'מקומי',
        unit: 'ק"ג',
        icon: '🍅',
      ),
      ProductEntity(
        barcode: '7290000000040',
        name: 'מלפפון',
        category: 'ירקות',
        brand: 'מקומי',
        unit: 'ק"ג',
        icon: '🥒',
      ),
      ProductEntity(
        barcode: '7290000000051',
        name: 'בננה',
        category: 'פירות',
        brand: 'מקומי',
        unit: 'ק"ג',
        icon: '🍌',
      ),
      ProductEntity(
        barcode: '7290000000060',
        name: 'תפוח עץ',
        category: 'פירות',
        brand: 'מקומי',
        unit: 'ק"ג',
        icon: '🍎',
      ),
      ProductEntity(
        barcode: '7290000000070',
        name: 'שמן זית',
        category: 'שמנים ורטבים',
        brand: 'עין זית',
        unit: '1 ליטר',
        icon: '🫗',
      ),
    ];

    await _localRepo.saveProducts(fallbackProducts);
    debugPrint('✅ נשמרו ${fallbackProducts.length} מוצרים דמה');
  }

  @override
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    if (!_isInitialized) await initialize();

    final products = _localRepo.getAllProducts();
    return products.map((p) => p.toMap()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getProductsByCategory(
    String category,
  ) async {
    if (!_isInitialized) await initialize();

    final products = _localRepo.getProductsByCategory(category);
    return products.map((p) => p.toMap()).toList();
  }

  @override
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    if (!_isInitialized) await initialize();

    final product = _localRepo.getProductByBarcode(barcode);
    return product?.toMap();
  }

  @override
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    if (!_isInitialized) await initialize();

    final products = _localRepo.searchProducts(query);
    return products.map((p) => p.toMap()).toList();
  }

  @override
  Future<List<String>> getCategories() async {
    if (!_isInitialized) await initialize();
    return _localRepo.getCategories();
  }

  @override
  Future<void> refreshProducts({bool force = false}) async {
    if (!_isInitialized) await initialize();

    // 🔄 עדכון מחירים בלבד
    await updatePrices();
  }

  /// 💰 עדכון מחירים בלבד מה-API
  Future<void> updatePrices() async {
    if (_isPriceUpdateInProgress) {
      debugPrint('⚠️ עדכון מחירים כבר בתהליך');
      return;
    }

    _isPriceUpdateInProgress = true;

    try {
      debugPrint('💰 מעדכן מחירים מ-API...');

      final apiProducts = await _apiService.getProducts();

      if (apiProducts.isEmpty) {
        debugPrint('⚠️ לא נמצאו מוצרים ב-API');
        return;
      }

      int updated = 0;
      int added = 0;

      for (final apiProduct in apiProducts) {
        final appFormat = apiProduct.toAppFormat();
        final barcode = appFormat['barcode'] as String?;
        final price = appFormat['price'] as double?;
        final store = appFormat['store'] as String?;

        if (barcode == null || price == null || store == null) continue;

        // בדיקה אם המוצר קיים
        if (_localRepo.hasProduct(barcode)) {
          // עדכון מחיר בלבד
          await _localRepo.updatePrice(
            barcode: barcode,
            price: price,
            store: store,
          );
          updated++;
        } else {
          // מוצר חדש - הוספה
          final newProduct = ProductEntity.fromPublishedProduct(appFormat);
          await _localRepo.saveProduct(newProduct);
          added++;
        }
      }

      debugPrint('✅ עדכון הסתיים: $updated מחירים עודכנו, $added מוצרים נוספו');
    } catch (e) {
      debugPrint('❌ שגיאה בעדכון מחירים: $e');
    } finally {
      _isPriceUpdateInProgress = false;
    }
  }

  /// 📊 סטטיסטיקות
  int get totalProducts => _localRepo.totalProducts;
  int get productsWithPrice => _localRepo.productsWithPrice;
  int get productsWithoutPrice => _localRepo.productsWithoutPrice;

  /// ניקוי
  Future<void> clearAll() async {
    await _localRepo.clearAll();
  }
}
