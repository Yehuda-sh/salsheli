// 📄 File: lib/repositories/hybrid_products_repository.dart
//
// 🇮🇱 Repository היברידי - משלב Firestore + Local + API:
//     - טעינה ראשונית: Firestore (1758 מוצרים!)
//     - Fallback 1: products.json (מקומי)
//     - Fallback 2: API (אונליין)
//     - Fallback 3: 8 מוצרים דמה
//     - Cache חכם ב-Hive (מהיר!)
//     - עדכון מחירים מ-API
//
// 💾 מצב נוכחי:
//     ✅ בשימוש! (main.dart)
//     🔥 Firestore: 1758 מוצרים זמינים
//     💾 Hive: Cache מהיר
//     📡 API: עדכוני מחירים
//
// 💡 יתרונות:
//     - מהיר: Hive cache (O(1) lookup)
//     - מסונכרן: Firestore בין מכשירים
//     - עובד Offline: אם יש cache
//     - מחירים עדכניים: מה-API
//
// 🇬🇧 Hybrid Repository - combines Firestore + Local + API:
//     - Primary: Firestore (1758 products!)
//     - Fallback 1: products.json (local)
//     - Fallback 2: API (online)
//     - Fallback 3: 8 demo products
//     - Smart Hive cache (fast!)
//     - Price updates from API
//
// 💾 Current state:
//     ✅ In use! (main.dart)
//     🔥 Firestore: 1758 products available
//     💾 Hive: Fast cache
//     📡 API: Price updates
//
// 💡 Advantages:
//     - Fast: Hive cache (O(1) lookup)
//     - Synced: Firestore across devices
//     - Works Offline: If cache exists
//     - Updated prices: From API
//
// 🔗 Related:
//     - FirebaseProductsRepository (Firestore access)
//     - LocalProductsRepository (Hive storage)
//     - ShufersalPricesService (API price updates)
//     - products.json (local fallback)
//
// 📝 Version: 2.0 - Added docstrings + constants + version info
// 📅 Last Updated: 09/10/2025
//

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../services/shufersal_prices_service.dart';
import 'local_products_repository.dart';
import 'firebase_products_repository.dart';
import 'products_repository.dart';
import '../models/product_entity.dart';

class HybridProductsRepository implements ProductsRepository {
  final LocalProductsRepository _localRepo;
  final FirebaseProductsRepository? _firebaseRepo;

  bool _isInitialized = false;
  bool _isPriceUpdateInProgress = false;

  /// ספי מינימום למוצרים תקינים (פחות מזה = DB ישן)
  static const int _minProductsThreshold = 100;
  
  /// מרווח logging ב-progress (כל X מוצרים)
  static const int _progressLogInterval = 200;

  HybridProductsRepository({
    required LocalProductsRepository localRepo,
    FirebaseProductsRepository? firebaseRepo,
  })  : _localRepo = localRepo,
        _firebaseRepo = firebaseRepo;

  /// המרת נתון מ-Map ל-ProductEntity עם validation
  /// 
  /// מחזיר null אם הנתונים לא תקינים (barcode/name חסרים)
  /// 
  /// Example:
  /// ```dart
  /// final entity = _parseProductData(data);
  /// if (entity != null) {
  ///   entities.add(entity);
  /// }
  /// ```
  ProductEntity? _parseProductData(Map<String, dynamic> data) {
    final barcode = data['barcode']?.toString();
    final name = data['name']?.toString();

    // Validation - חובה שיהיה ברקוד ושם
    if (barcode == null || barcode.isEmpty || 
        name == null || name.isEmpty) {
      return null;
    }

    return ProductEntity(
      barcode: barcode,
      name: name,
      category: data['category']?.toString() ?? 'אחר',
      brand: data['brand']?.toString() ?? '',
      unit: data['unit']?.toString() ?? '',
      icon: data['icon']?.toString() ?? '🛒',
      currentPrice: data['currentPrice'] as double?,
      lastPriceStore: data['lastPriceStore']?.toString(),
      lastPriceUpdate: data['lastPriceUpdate'] != null 
        ? DateTime.tryParse(data['lastPriceUpdate'].toString())
        : null,
    );
  }

  /// אתחול ה-Repository - טוען מוצרים אם ה-DB ריק
  /// 
  /// אסטרטגיית טעינה (4 שלבים):
  /// 1. Firestore (1758 מוצרים) - מקור ראשי
  /// 2. products.json - fallback מקומי
  /// 3. API (שופרסל) - fallback אונליין
  /// 4. 8 מוצרים דמה - fallback אחרון
  /// 
  /// Note: אם יש פחות מ-$_minProductsThreshold מוצרים, מוחק ה-DB וטוען מחדש
  /// 
  /// Example:
  /// ```dart
  /// final repo = HybridProductsRepository(localRepo: localRepo);
  /// await repo.initialize();
  /// print('מוצרים זמינים: ${repo.totalProducts}');
  /// ```
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ HybridProductsRepository.initialize: כבר אותחל, מדלג');
      return;
    }

    try {
      debugPrint('\n🚀 HybridProductsRepository.initialize() - מתחיל...');
      debugPrint('   📊 בודק מספר מוצרים מקומיים: ${_localRepo.totalProducts}');

      // אם יש פחות מספי מינימום - נמחק וטוען מחדש
      if (_localRepo.totalProducts > 0 && _localRepo.totalProducts < _minProductsThreshold) {
        debugPrint('   🗑️ מוחק DB ישן (${_localRepo.totalProducts} מוצרים דמה)...');
        await _localRepo.clearAll();
        debugPrint('   ✅ DB נמחק - יטען מחדש');
      }

      // אם אין מוצרים מקומית - טוען מקורות שונים
      if (_localRepo.totalProducts == 0) {
        debugPrint('   ➡️ DB ריק - מתחיל טעינה...');
        await _loadInitialProducts();
      } else {
        debugPrint('   ✅ נמצאו ${_localRepo.totalProducts} מוצרים מקומית - לא צריך לטעון');
      }

      _isInitialized = true;
      debugPrint('✅ HybridProductsRepository.initialize: הושלם בהצלחה');
      
      // 💰 עדכון מחירים ברקע (ללא חסימת ה-UI)
      if (_localRepo.totalProducts > 0) {
        debugPrint('💰 מתחיל עדכון מחירים ברקע (async)...');
        updatePrices().then((_) {
          debugPrint('✅ עדכון מחירים הושלם בהצלחה ברקע');
        }).catchError((e) {
          debugPrint('⚠️ עדכון מחירים נכשל (לא קריטי): $e');
        });
      }
      debugPrint('');
    } catch (e) {
      debugPrint('❌ שגיאה באתחול HybridProductsRepository: $e');
      _isInitialized = true; // סימון כמוכן למרות השגיאה
    }
  }

  /// טעינת מוצרים ראשונית - אסטרטגיה משולבת (4 שלבים)
  Future<void> _loadInitialProducts() async {
    try {
      debugPrint('📥 אסטרטגיית טעינה:');
      debugPrint('   0️⃣ נסיון ראשון: Firestore (1758 מוצרים!)');
      debugPrint('   1️⃣ נסיון שני: products.json');
      debugPrint('   2️⃣ נסיון שלישי: API');
      debugPrint('   3️⃣ גיבוי: 8 מוצרים דמה');
      debugPrint('');

      // 🔥 נסיון 0: טעינה מ-Firestore
      if (_firebaseRepo != null) {
        final firebaseSuccess = await _loadFromFirestore();
        if (firebaseSuccess) {
          debugPrint('✅ טעינה מ-Firestore הצליחה!');
          return;
        }
      } else {
        debugPrint('⚠️ Firebase לא מוגדר, מדלג לנסיון הבא...');
      }

      // נסיון 1: טעינה מ-products.json
      final success = await _loadFromJson();
      if (success) {
        debugPrint('✅ טעינה מ-products.json הצליחה!');
        return;
      }

      // נסיון 2: טעינה מ-API
      debugPrint('⚠️ products.json נכשל, מנסה API...');
      final apiSuccess = await _loadFromAPI();
      if (apiSuccess) {
        debugPrint('✅ טעינה מ-API הצליחה!');
        return;
      }

      // נסיון 3: fallback
      debugPrint('⚠️ כל המקורות נכשלו, טוען מוצרים דמה...');
      await _loadFallbackProducts();
      debugPrint('✅ טעינת fallback הושלמה');
      
    } catch (e) {
      debugPrint('❌ שגיאה קריטית בטעינת מוצרים: $e');
      await _loadFallbackProducts();
    }
  }

  /// טעינה מ-Firestore (נסיון 0)
  Future<bool> _loadFromFirestore() async {
    try {
      debugPrint('🔥 מנסה לטעון מ-Firestore...');
      
      // טעינת כל המוצרים מ-Firestore
      final firestoreProducts = await _firebaseRepo!.getAllProducts();
      
      if (firestoreProducts.isEmpty) {
        debugPrint('⚠️ Firestore ריק או לא זמין');
        return false;
      }

      debugPrint('📋 נמצאו ${firestoreProducts.length} מוצרים ב-Firestore');

      // המרה ל-ProductEntity
      final entities = <ProductEntity>[];
      int validProducts = 0;
      int invalidProducts = 0;

      for (final data in firestoreProducts) {
        try {
          final entity = _parseProductData(data);
          if (entity != null) {
            entities.add(entity);
            validProducts++;
          } else {
            invalidProducts++;
          }
        } catch (e) {
          invalidProducts++;
          debugPrint('⚠️ שגיאה בהמרת מוצר מ-Firestore: $e');
        }
      }

      if (entities.isEmpty) {
        debugPrint('❌ לא נמצאו מוצרים תקינים ב-Firestore');
        return false;
      }

      // שמירה ב-Hive עם Progress
      debugPrint('💾 שומר ${entities.length} מוצרים ב-Hive (עם batches)...');
      await _localRepo.saveProductsWithProgress(
        entities,
        onProgress: (current, total) {
          if (current % _progressLogInterval == 0 || current == total) {
            debugPrint('   📊 Progress: $current/$total (${(current/total*100).toStringAsFixed(1)}%)');
          }
        },
      );
      
      debugPrint('✅ נשמרו ${entities.length} מוצרים מ-Firestore');
      debugPrint('   ✔️ תקינים: $validProducts');
      if (invalidProducts > 0) {
        debugPrint('   ⚠️ נדחו: $invalidProducts');
      }

      return true;
    } catch (e) {
      debugPrint('❌ שגיאה בטעינת Firestore: $e');
      return false;
    }
  }

  /// טעינה מ-products.json (נסיון 1)
  Future<bool> _loadFromJson() async {
    try {
      debugPrint('📂 מנסה לטעון מ-products.json...');
      
      // קריאה מהקובץ (JSON הוא Array)
      final jsonString = await rootBundle.loadString('assets/data/products.json');
      final productsData = json.decode(jsonString) as List;
      
      if (productsData.isEmpty) {
        debugPrint('⚠️ products.json ריק או לא תקין');
        return false;
      }

      debugPrint('📋 נמצאו ${productsData.length} מוצרים ב-JSON');

      // המרה ל-ProductEntity
      final entities = <ProductEntity>[];
      int validProducts = 0;
      int invalidProducts = 0;

      for (final data in productsData) {
        try {
          final entity = _parseProductData(data);
          if (entity != null) {
            entities.add(entity);
            validProducts++;
          } else {
            invalidProducts++;
          }
        } catch (e) {
          invalidProducts++;
          debugPrint('⚠️ שגיאה בהמרת מוצר: $e');
        }
      }

      if (entities.isEmpty) {
        debugPrint('❌ לא נמצאו מוצרים תקינים ב-JSON');
        return false;
      }

      // שמירה ב-Hive עם Progress
      debugPrint('💾 שומר ${entities.length} מוצרים ב-Hive (עם batches)...');
      await _localRepo.saveProductsWithProgress(
        entities,
        onProgress: (current, total) {
          if (current % _progressLogInterval == 0 || current == total) {
            debugPrint('   📊 Progress: $current/$total (${(current/total*100).toStringAsFixed(1)}%)');
          }
        },
      );
      
      debugPrint('✅ נשמרו ${entities.length} מוצרים מ-products.json');
      debugPrint('   ✔️ תקינים: $validProducts');
      if (invalidProducts > 0) {
        debugPrint('   ⚠️ נדחו: $invalidProducts');
      }

      return true;
    } catch (e) {
      debugPrint('❌ שגיאה בטעינת products.json: $e');
      return false;
    }
  }

  /// טעינה מ-API - שופרסל (נסיון 2)
  Future<bool> _loadFromAPI() async {
    try {
      debugPrint('📞 מנסה לטעון מוצרים מ-API (שופרסל)...');
      final apiProducts = await ShufersalPricesService.getProducts();

      if (apiProducts.isEmpty) {
        debugPrint('⚠️ לא נמצאו מוצרים ב-API');
        return false;
      }

      // המרה ל-ProductEntity
      final entities = apiProducts.map((p) {
        final appFormat = p.toAppFormat();
        return ProductEntity(
          barcode: appFormat['barcode'] ?? '',
          name: appFormat['name'] ?? '',
          category: appFormat['category'] ?? 'אחר',
          brand: appFormat['brand'] ?? '',
          unit: appFormat['unit'] ?? '',
          icon: appFormat['icon'] ?? '🛒',
          currentPrice: appFormat['price'] as double?,
          lastPriceStore: appFormat['store'] as String?,
          lastPriceUpdate: DateTime.now(),
        );
      }).toList();

      // שמירה ב-Hive עם Progress
      debugPrint('💾 שומר ${entities.length} מוצרים מ-API ב-Hive (עם batches)...');
      await _localRepo.saveProductsWithProgress(
        entities,
        onProgress: (current, total) {
          if (current % _progressLogInterval == 0 || current == total) {
            debugPrint('   📊 Progress: $current/$total (${(current/total*100).toStringAsFixed(1)}%)');
          }
        },
      );
      debugPrint('✅ נשמרו ${entities.length} מוצרים מ-API');
      return true;
    } catch (e) {
      debugPrint('❌ שגיאה בטעינת מוצרים מ-API: $e');
      return false;
    }
  }

  /// טעינת מוצרים דמה כ-fallback (נסיון 3 - גיבוי אחרון)
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

    // מוצרים דמה - פשוט בלי progress
    await _localRepo.saveProducts(fallbackProducts);
    debugPrint('✅ נשמרו ${fallbackProducts.length} מוצרים דמה');
  }

  // === ProductsRepository Interface Implementation ===

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

    // עדכון מחירים בלבד
    await updatePrices();
  }

  // === Additional Public Methods ===

  /// מעדכן מחירים בלבד מ-API (שופרסל)
  /// 
  /// מעדכן מחירים למוצרים קיימים ומוסיף מוצרים חדשים אם יש
  /// 
  /// Note: הפעולה רצה ברקע ולא חוסמת את ה-UI
  /// 
  /// Example:
  /// ```dart
  /// await repo.updatePrices();
  /// print('עדכון מחירים הושלם');
  /// ```
  Future<void> updatePrices() async {
    if (_isPriceUpdateInProgress) {
      debugPrint('⚠️ עדכון מחירים כבר בתהליך');
      return;
    }

    _isPriceUpdateInProgress = true;

    try {
      debugPrint('💰 מעדכן מחירים מ-API (שופרסל)...');

      final apiProducts = await ShufersalPricesService.getProducts();

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
          final newProduct = ProductEntity(
            barcode: barcode,
            name: appFormat['name'] ?? '',
            category: appFormat['category'] ?? 'אחר',
            brand: appFormat['brand'] ?? '',
            unit: appFormat['unit'] ?? '',
            icon: appFormat['icon'] ?? '🛒',
            currentPrice: price,
            lastPriceStore: store,
            lastPriceUpdate: DateTime.now(),
          );
          await _localRepo.saveProduct(newProduct);
          added++;
        }
      }

      debugPrint(
          '✅ עדכון הסתיים: $updated מחירים עודכנו, $added מוצרים נוספו');
    } catch (e) {
      debugPrint('❌ שגיאה בעדכון מחירים: $e');
    } finally {
      _isPriceUpdateInProgress = false;
    }
  }

  /// מנקה את כל המוצרים מה-cache המקומי
  /// 
  /// Warning: פעולה בלתי הפיכה! צריך לקרוא ל-initialize() אחר כך
  /// 
  /// Example:
  /// ```dart
  /// await repo.clearAll();
  /// await repo.initialize(); // טעינה מחדש
  /// ```
  Future<void> clearAll() async {
    await _localRepo.clearAll();
    _isInitialized = false;
  }

  // === Statistics Getters ===

  /// סך כל המוצרים במערכת
  int get totalProducts => _localRepo.totalProducts;

  /// מספר מוצרים עם מחיר
  int get productsWithPrice => _localRepo.productsWithPrice;

  /// מספר מוצרים ללא מחיר
  int get productsWithoutPrice => _localRepo.productsWithoutPrice;
}
