// 📄 lib/repositories/local_products_repository.dart
//
// 🎯 Repository לניהול מוצרים מקומית ב-Hive
//
// ✨ Features:
// - 📦 Batch Save: שמירה ב-100 מוצרים כל פעם (מונע Skipped Frames)
// - 📊 Progress Callback: עדכון התקדמות בזמן אמיתי
// - ⚡ Performance: מאפשר ל-UI להתעדכן בין batches (10ms delay)
// - 💾 CRUD מלא: Create, Read, Update, Delete
// - 🔍 חיפוש וסינון: לפי ברקוד, קטגוריה, טקסט חופשי
// - 📈 סטטיסטיקות: מוצרים עם/בלי מחיר
//
// 🔗 Related:
// - lib/repositories/hybrid_products_repository.dart - משתמש ב-LocalProductsRepository
// - lib/models/product_entity.dart - מבנה הנתונים
// - lib/main.dart - אתחול ב-main()
//
// 📝 Version: 2.0 - Added docstrings + version info + batch delay constant
// 📅 Last Updated: 09/10/2025
//

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_entity.dart';

class LocalProductsRepository {
  static const String _boxName = 'products';
  static const int _batchSize = 100; // 📦 גודל batch
  static const int _batchDelayMs = 10; // ⏱️ delay בין batches (ms)
  
  Box<ProductEntity>? _box;

  /// אתחול ה-Box של Hive
  /// 
  /// חובה לקרוא לפני כל שימוש ב-Repository!
  /// 
  /// Example:
  /// ```dart
  /// final repo = LocalProductsRepository();
  /// await repo.init();
  /// print('מוצרים קיימים: ${repo.totalProducts}');
  /// ```
  Future<void> init() async {
    debugPrint('\n🛠️ LocalProductsRepository.init() - מתחיל...');
    try {
      debugPrint('   1️⃣ מאתחל Hive.initFlutter()');
      await Hive.initFlutter();
      
      // רישום ה-Adapter של ProductEntity
      if (!Hive.isAdapterRegistered(0)) {
        debugPrint('   2️⃣ מרשם ProductEntityAdapter');
        Hive.registerAdapter(ProductEntityAdapter());
      } else {
        debugPrint('   2️⃣ ProductEntityAdapter כבר רשום');
      }

      debugPrint('   3️⃣ פותח Box: $_boxName');
      _box = await Hive.openBox<ProductEntity>(_boxName);
      debugPrint('✅ LocalProductsRepository: אותחל עם ${_box!.length} מוצרים');
    } catch (e) {
      debugPrint('❌ LocalProductsRepository.init failed: $e');
      rethrow;
    }
  }

  /// בדיקה אם ה-Repository מוכן לשימוש
  /// 
  /// Returns: true אם ה-Box פתוח וזמין
  bool get isReady => _box != null && _box!.isOpen;

  /// מחזיר את כל המוצרים
  /// 
  /// Returns: רשימת כל המוצרים ב-Repository
  /// 
  /// Example:
  /// ```dart
  /// final products = repo.getAllProducts();
  /// print('${products.length} מוצרים במערכת');
  /// ```
  List<ProductEntity> getAllProducts() {
    if (!isReady) {
      debugPrint('⚠️ getAllProducts: Box לא מוכן');
      return [];
    }
    final products = _box!.values.toList();
    debugPrint('📦 getAllProducts: החזרת ${products.length} מוצרים');
    return products;
  }

  /// מחזיר מוצר לפי ברקוד (חיפוש מדויק)
  /// 
  /// [barcode] - מספר הברקוד (למשל: '7290000000001')
  /// 
  /// Returns: המוצר או null אם לא נמצא
  /// 
  /// Example:
  /// ```dart
  /// final product = repo.getProductByBarcode('7290000000001');
  /// if (product != null) {
  ///   print('נמצא: ${product.name}');
  /// }
  /// ```
  ProductEntity? getProductByBarcode(String barcode) {
    if (!isReady) return null;
    return _box!.get(barcode);
  }

  /// בדיקה אם מוצר קיים לפי ברקוד
  /// 
  /// [barcode] - מספר הברקוד
  /// 
  /// Returns: true אם המוצר קיים
  /// 
  /// Example:
  /// ```dart
  /// if (repo.hasProduct('7290000000001')) {
  ///   print('מוצר קיים במערכת');
  /// }
  /// ```
  bool hasProduct(String barcode) {
    if (!isReady) return false;
    return _box!.containsKey(barcode);
  }

  /// שומר מוצר בודד
  /// 
  /// [product] - המוצר לשמירה
  /// 
  /// Example:
  /// ```dart
  /// final product = ProductEntity(
  ///   barcode: '123',
  ///   name: 'חלב',
  ///   category: 'מוצרי חלב',
  /// );
  /// await repo.saveProduct(product);
  /// ```
  Future<void> saveProduct(ProductEntity product) async {
    if (!isReady) {
      debugPrint('⚠️ Box לא מוכן');
      return;
    }

    try {
      await _box!.put(product.barcode, product);
      debugPrint('💾 נשמר מוצר: ${product.name} (${product.barcode})');
    } catch (e) {
      debugPrint('❌ שגיאה בשמירת מוצר: $e');
    }
  }

  /// שומר רשימת מוצרים עם Batch + Progress (מומלץ!)
  /// 
  /// [products] - רשימת המוצרים לשמירה
  /// [onProgress] - callback להתקדמות: (current, total)
  /// 
  /// Returns: מספר המוצרים שנשמרו בהצלחה
  /// 
  /// Note: שומר ב-batches של $_batchSize מוצרים עם delay של ${_batchDelayMs}ms
  ///       כדי לאפשר ל-UI להתעדכן ולמנוע Skipped Frames
  /// 
  /// Example:
  /// ```dart
  /// final saved = await repo.saveProductsWithProgress(
  ///   products,
  ///   onProgress: (current, total) {
  ///     print('התקדמות: $current/$total');
  ///   },
  /// );
  /// print('נשמרו $saved מוצרים');
  /// ```
  Future<int> saveProductsWithProgress(
    List<ProductEntity> products, {
    void Function(int current, int total)? onProgress,
  }) async {
    if (!isReady) {
      debugPrint('⚠️ saveProductsWithProgress: Box לא מוכן');
      return 0;
    }

    if (products.isEmpty) {
      debugPrint('⚠️ saveProductsWithProgress: רשימה ריקה');
      return 0;
    }

    try {
      debugPrint('💾 saveProductsWithProgress: שומר ${products.length} מוצרים...');
      debugPrint('   📦 Batch size: $_batchSize מוצרים');
      
      int saved = 0;
      final totalBatches = (products.length / _batchSize).ceil();
      
      for (int i = 0; i < products.length; i += _batchSize) {
        final end = (i + _batchSize < products.length) 
            ? i + _batchSize 
            : products.length;
        
        final batch = products.sublist(i, end);
        final currentBatch = (i / _batchSize).floor() + 1;
        
        // שמירת ה-batch
        final Map<String, ProductEntity> batchMap = {
          for (var p in batch) p.barcode: p,
        };
        
        await _box!.putAll(batchMap);
        saved += batch.length;
        
        // עדכון התקדמות
        onProgress?.call(saved, products.length);
        
        debugPrint('   ✅ Batch $currentBatch/$totalBatches: נשמרו ${batch.length} מוצרים (סה"כ: $saved/${products.length})');
        
        // תן ל-UI להתעדכן בין batches
        if (i + _batchSize < products.length) {
          await Future.delayed(Duration(milliseconds: _batchDelayMs));
        }
      }
      
      debugPrint('✅ saveProductsWithProgress: הושלם!');
      debugPrint('   📊 נשמרו: $saved מוצרים');
      debugPrint('   📊 סה"כ ב-DB: ${_box!.length} מוצרים');
      
      return saved;
    } catch (e) {
      debugPrint('❌ שגיאה בשמירת מוצרים: $e');
      return 0;
    }
  }

  /// שומר רשימת מוצרים (ללא progress - לתאימות לאחור)
  /// 
  /// [products] - רשימת המוצרים לשמירה
  /// 
  /// Note: מומלץ להשתמש ב-saveProductsWithProgress() לביצועים טובים יותר
  /// 
  /// Example:
  /// ```dart
  /// await repo.saveProducts(products);
  /// ```
  Future<void> saveProducts(List<ProductEntity> products) async {
    await saveProductsWithProgress(products);
  }

  /// מעדכן מחיר למוצר קיים
  /// 
  /// [barcode] - ברקוד המוצר לעדכון
  /// [price] - המחיר החדש
  /// [store] - שם החנות
  /// 
  /// Note: המוצר חייב להיות קיים במערכת!
  /// 
  /// Example:
  /// ```dart
  /// await repo.updatePrice(
  ///   barcode: '7290000000001',
  ///   price: 8.90,
  ///   store: 'שופרסל',
  /// );
  /// ```
  Future<void> updatePrice({
    required String barcode,
    required double price,
    required String store,
  }) async {
    if (!isReady) return;

    final product = _box!.get(barcode);
    if (product != null) {
      product.updatePrice(price: price, store: store);
      debugPrint('💰 עודכן מחיר: ${product.name} -> $price ₪');
    }
  }

  /// מעדכן מחירים לרשימת מוצרים
  /// 
  /// [pricesData] - רשימת Map עם barcode, price, store
  /// 
  /// Example:
  /// ```dart
  /// await repo.updatePrices([
  ///   {'barcode': '123', 'price': 8.9, 'store': 'שופרסל'},
  ///   {'barcode': '456', 'price': 5.5, 'store': 'רמי לוי'},
  /// ]);
  /// ```
  Future<void> updatePrices(List<Map<String, dynamic>> pricesData) async {
    if (!isReady) return;

    int updated = 0;
    for (final data in pricesData) {
      final barcode = data['barcode'] as String?;
      final price = data['price'] as double?;
      final store = data['store'] as String?;

      if (barcode != null && price != null && store != null) {
        final product = _box!.get(barcode);
        if (product != null) {
          product.updatePrice(price: price, store: store);
          updated++;
        }
      }
    }

    debugPrint('💰 עודכנו $updated מחירים');
  }

  /// מוחק מוצר לפי ברקוד
  /// 
  /// [barcode] - ברקוד המוצר למחיקה
  /// 
  /// Example:
  /// ```dart
  /// await repo.deleteProduct('7290000000001');
  /// ```
  Future<void> deleteProduct(String barcode) async {
    if (!isReady) return;

    try {
      await _box!.delete(barcode);
      debugPrint('🗑️ נמחק מוצר: $barcode');
    } catch (e) {
      debugPrint('❌ שגיאה במחיקת מוצר: $e');
    }
  }

  /// מוחק את כל המוצרים מה-Repository
  /// 
  /// Warning: פעולה בלתי הפיכה!
  /// 
  /// Example:
  /// ```dart
  /// await repo.clearAll();
  /// print('כל המוצרים נמחקו');
  /// ```
  Future<void> clearAll() async {
    if (!isReady) return;

    try {
      await _box!.clear();
      debugPrint('🧹 נמחקו כל המוצרים');
    } catch (e) {
      debugPrint('❌ שגיאה בניקוי: $e');
    }
  }

  /// מחזיר מוצרים לפי קטגוריה
  /// 
  /// [category] - שם הקטגוריה (למשל: 'מוצרי חלב')
  /// 
  /// Returns: רשימת מוצרים מהקטגוריה
  /// 
  /// Example:
  /// ```dart
  /// final dairy = repo.getProductsByCategory('מוצרי חלב');
  /// print('${dairy.length} מוצרי חלב');
  /// ```
  List<ProductEntity> getProductsByCategory(String category) {
    if (!isReady) return [];
    return _box!.values.where((p) => p.category == category).toList();
  }

  /// חיפוש מוצרים לפי טקסט חופשי
  /// 
  /// [query] - מחרוזת חיפוש
  /// 
  /// Returns: רשימת מוצרים שמתאימים לחיפוש
  /// 
  /// Note: מחפש בשדות name ו-brand (case-insensitive)
  /// 
  /// Example:
  /// ```dart
  /// final results = repo.searchProducts('חלב');
  /// print('נמצאו ${results.length} תוצאות');
  /// ```
  List<ProductEntity> searchProducts(String query) {
    if (!isReady) return [];

    final lowerQuery = query.toLowerCase();
    return _box!.values
        .where(
          (p) =>
              p.name.toLowerCase().contains(lowerQuery) ||
              p.brand.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  /// מחזיר את רשימת כל הקטגוריות הזמינות
  /// 
  /// Returns: רשימת שמות קטגוריות ייחודיות (ממוינת)
  /// 
  /// Example:
  /// ```dart
  /// final categories = repo.getCategories();
  /// print('${categories.length} קטגוריות זמינות');
  /// ```
  List<String> getCategories() {
    if (!isReady) return [];
    return _box!.values.map((p) => p.category).toSet().toList()..sort();
  }

  // === 📊 Statistics Getters ===

  /// סך כל המוצרים ב-Repository
  int get totalProducts => isReady ? _box!.length : 0;

  /// מספר מוצרים עם מחיר
  int get productsWithPrice =>
      isReady ? _box!.values.where((p) => p.currentPrice != null).length : 0;

  /// מספר מוצרים ללא מחיר
  int get productsWithoutPrice =>
      isReady ? _box!.values.where((p) => p.currentPrice == null).length : 0;

  /// סוגר את ה-Box (שימושי בסוף אפליקציה)
  /// 
  /// Example:
  /// ```dart
  /// await repo.close();
  /// ```
  Future<void> close() async {
    if (isReady) {
      await _box!.close();
      debugPrint('🔒 LocalProductsRepository: נסגר');
    }
  }
}
