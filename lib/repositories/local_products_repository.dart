// 📄 lib/repositories/local_products_repository.dart
//
// 🎯 Repository לניהול מוצרים מקומית ב-Hive
// - שמירת מוצרים קבועה (עם Batch + Progress)
// - עדכון מחירים דינמי
// - CRUD מלא
//
// ✨ תכונות חדשות:
// - 📦 Batch Save: שמירה ב-100 מוצרים כל פעם
// - 📊 Progress Callback: עדכון התקדמות בזמן אמיתי
// - ⚡ Performance: מאפשר ל-UI להתעדכן בין batches

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_entity.dart';

class LocalProductsRepository {
  static const String _boxName = 'products';
  static const int _batchSize = 100; // 📦 גודל batch
  Box<ProductEntity>? _box;

  /// אתחול ה-Box (חייב לקרוא ב-main)
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

  /// בדיקה אם ה-Box מוכן
  bool get isReady => _box != null && _box!.isOpen;

  /// קבלת כל המוצרים
  List<ProductEntity> getAllProducts() {
    if (!isReady) {
      debugPrint('⚠️ getAllProducts: Box לא מוכן');
      return [];
    }
    final products = _box!.values.toList();
    debugPrint('📦 getAllProducts: החזרת ${products.length} מוצרים');
    return products;
  }

  /// קבלת מוצר לפי ברקוד
  ProductEntity? getProductByBarcode(String barcode) {
    if (!isReady) return null;
    return _box!.get(barcode);
  }

  /// בדיקה אם מוצר קיים
  bool hasProduct(String barcode) {
    if (!isReady) return false;
    return _box!.containsKey(barcode);
  }

  /// שמירת מוצר חדש (ללא מחיר)
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

  /// 🆕 שמירת רשימת מוצרים עם Batch + Progress
  /// 
  /// [products] - רשימת המוצרים לשמירה
  /// [onProgress] - callback להתקדמות: (current, total)
  /// 
  /// Returns: מספר המוצרים שנשמרו בהצלחה
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
          await Future.delayed(const Duration(milliseconds: 10));
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

  /// שמירת רשימת מוצרים (ללא progress - לתאימות לאחור)
  Future<void> saveProducts(List<ProductEntity> products) async {
    await saveProductsWithProgress(products);
  }

  /// עדכון מחיר למוצר קיים
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

  /// עדכון מחירים לרשימת מוצרים
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

  /// מחיקת מוצר
  Future<void> deleteProduct(String barcode) async {
    if (!isReady) return;

    try {
      await _box!.delete(barcode);
      debugPrint('🗑️ נמחק מוצר: $barcode');
    } catch (e) {
      debugPrint('❌ שגיאה במחיקת מוצר: $e');
    }
  }

  /// ניקוי כל המוצרים
  Future<void> clearAll() async {
    if (!isReady) return;

    try {
      await _box!.clear();
      debugPrint('🧹 נמחקו כל המוצרים');
    } catch (e) {
      debugPrint('❌ שגיאה בניקוי: $e');
    }
  }

  /// קבלת מוצרים לפי קטגוריה
  List<ProductEntity> getProductsByCategory(String category) {
    if (!isReady) return [];
    return _box!.values.where((p) => p.category == category).toList();
  }

  /// חיפוש מוצרים
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

  /// קבלת כל הקטגוריות
  List<String> getCategories() {
    if (!isReady) return [];
    return _box!.values.map((p) => p.category).toSet().toList()..sort();
  }

  /// סטטיסטיקות
  int get totalProducts => isReady ? _box!.length : 0;

  int get productsWithPrice =>
      isReady ? _box!.values.where((p) => p.currentPrice != null).length : 0;

  int get productsWithoutPrice =>
      isReady ? _box!.values.where((p) => p.currentPrice == null).length : 0;

  /// סגירת ה-Box
  Future<void> close() async {
    if (isReady) {
      await _box!.close();
      debugPrint('🔒 LocalProductsRepository: נסגר');
    }
  }
}
