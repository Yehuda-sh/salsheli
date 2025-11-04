// 📄 File: lib/repositories/firebase_products_repository.dart
//
// 🇮🇱 Repository למוצרים מ-Firebase Firestore:
//     - טעינה מהירה מ-Firestore עם cache חכם (1 שעה).
//     - חיפוש מוצרים לפי שם, ברקוד, קטגוריה.
//     - אופציה לעדכונים בזמן אמת (עתידי).
//     - ממירה ProductsRepository.
//
// 💾 מצב נוכחי:
//     ⚠️ לא בשימוש כרגע! הפרויקט משתמש ב-LocalProductsRepository.
//     לשימוש ב-Firebase:
//     1. העלה מוצרים ל-Firestore (upload script required).
//     2. עדכן main.dart להשתמש ב-FirebaseProductsRepository.
//     3. ודא ש-firebase_options.dart מוגדר נכון.
//
// 💡 רעיונות עתידיים:
//     - עדכונים בזמן אמת (snapshots).
//     - סנכרון מחירים אוטומטי מה-API.
//     - Offline persistence (עבודה בלי אינטרנט).
//     - סטטיסטיקות: מוצרים פופולריים, חיפושים נפוצים.
//
// 🇬🇧 Firebase Firestore products repository:
//     - Fast loading from Firestore with smart cache (1 hour).
//     - Search products by name, barcode, category.
//     - Optional real-time updates (future).
//     - Implements ProductsRepository interface.
//
// 💾 Current state:
//     ⚠️ Not in use! Project uses LocalProductsRepository.
//     To use Firebase:
//     1. Upload products to Firestore (upload script required).
//     2. Update main.dart to use FirebaseProductsRepository.
//     3. Ensure firebase_options.dart is configured.
//
// 💡 Future ideas:
//     - Real-time updates (snapshots).
//     - Auto price sync from API.
//     - Offline persistence.
//     - Statistics: popular products, common searches.
//
// 🔗 Related:
//     - ProductsRepository (interface)
//     - LocalProductsRepository (current implementation)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'constants/repository_constants.dart';
import 'products_repository.dart';

class FirebaseProductsRepository implements ProductsRepository {
  final FirebaseFirestore _firestore;

  // Cache מקומי
  List<Map<String, dynamic>>? _cachedProducts;
  DateTime? _lastCacheUpdate;
  final Duration _cacheValidity;

  /// יוצר instance חדש של FirebaseProductsRepository
  /// 
  /// Parameters:
  ///   - [firestore]: instance של FirebaseFirestore (אופציונלי)
  ///   - [cacheValidity]: משך זמן תקינות ה-cache (ברירת מחדל: שעה)
  /// 
  /// Example:
  /// ```dart
  /// // שימוש רגיל
  /// final repo = FirebaseProductsRepository();
  /// 
  /// // עם cache של 30 דקות
  /// final repo = FirebaseProductsRepository(
  ///   cacheValidity: Duration(minutes: 30),
  /// );
  /// ```
  FirebaseProductsRepository({
    FirebaseFirestore? firestore,
    Duration cacheValidity = const Duration(hours: 1),
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _cacheValidity = cacheValidity;

  /// בדיקה אם ה-cache תקף
  bool get _isCacheValid {
    if (_cachedProducts == null || _lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheValidity;
  }

  /// טעינת כל המוצרים מ-Firestore
  /// 
  /// משתמש ב-cache חכם - אם ה-cache תקף, מחזיר אותו.
  /// אחרת, טוען מחדש מ-Firestore ומעדכן את ה-cache.
  /// 
  /// Parameters:
  ///   - [limit]: מספר מקסימלי של מוצרים להחזיר (null = הכל)
  ///   - [offset]: כמה מוצרים לדלג (לדפדוף)
  /// 
  /// Returns:
  ///   - List של Maps עם נתוני מוצרים
  ///   - List ריק במקרה של שגיאה
  /// 
  /// Example:
  /// ```dart
  /// // טען את כל המוצרים
  /// final all = await repo.getAllProducts();
  /// 
  /// // טען 100 ראשונים
  /// final first100 = await repo.getAllProducts(limit: 100);
  /// 
  /// // טען 100-200 (דף שני)
  /// final second100 = await repo.getAllProducts(limit: 100, offset: 100);
  /// ```
  @override
  Future<List<Map<String, dynamic>>> getAllProducts({
    int? limit,
    int? offset,
  }) async {
    // 🚀 אם יש limit/offset - לא משתמשים ב-cache, טוענים ישירות
    if (limit != null || offset != null) {
      return _loadProductsWithPagination(limit: limit, offset: offset);
    }

    // אם יש cache תקף - החזר אותו
    if (_isCacheValid && _cachedProducts != null) {
      debugPrint('✅ מחזיר ${_cachedProducts!.length} מוצרים מ-cache');
      return _cachedProducts!;
    }

    try {
      debugPrint('📥 טוען מוצרים מ-Firestore...');
      final snapshot = await _firestore.collection(FirestoreCollections.products).get();

      _cachedProducts = snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
      _lastCacheUpdate = DateTime.now();

      debugPrint('✅ נטענו ${_cachedProducts!.length} מוצרים מ-Firestore');
      return _cachedProducts!;
    } catch (e) {
      debugPrint('❌ שגיאה בטעינת מוצרים מ-Firestore: $e');
      return _cachedProducts ?? [];
    }
  }

  /// 📄 טוען מוצרים עם pagination (limit + offset)
  /// 
  /// פנימי - נקרא רק כש-limit או offset מוגדרים.
  Future<List<Map<String, dynamic>>> _loadProductsWithPagination({
    int? limit,
    int? offset,
  }) async {
    try {
      debugPrint('📥 טוען מוצרים מ-Firestore (limit: $limit, offset: $offset)...');
      
      // 🚀 אם יש cache מלא, נשתמש בו במקום query
      if (_isCacheValid && _cachedProducts != null) {
        final start = offset ?? 0;
        final end = limit != null ? start + limit : _cachedProducts!.length;
        final result = _cachedProducts!.sublist(
          start.clamp(0, _cachedProducts!.length),
          end.clamp(0, _cachedProducts!.length),
        );
        debugPrint('✅ מחזיר ${result.length} מוצרים מ-cache (pagination)');
        return result;
      }

      // 🔥 אין cache - טען מ-Firestore
      Query query = _firestore.collection(FirestoreCollections.products);
      
      // הוסף offset (skip) אם יש
      // ⚠️ Note: Firestore לא תומך ישירות ב-offset, אז נשתמש בטריק:
      // נטען offset+limit ואז ניקח רק את ה-limit האחרונים
      if (offset != null && offset > 0) {
        // טען את כולם עד offset+limit
        final totalToLoad = limit != null ? offset + limit : offset + 100;
        query = query.limit(totalToLoad);
        
        final snapshot = await query.get();
        final allDocs = snapshot.docs
            .map((doc) => <String, dynamic>{
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            })
            .toList();
        
        // החזר רק את החלק הרלוונטי
        final result = allDocs.skip(offset).take(limit ?? allDocs.length).toList();
        debugPrint('✅ נטענו ${result.length} מוצרים (pagination)');
        return result;
      }
      
      // אין offset - פשוט limit
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      final products = snapshot.docs
          .map((doc) => <String, dynamic>{
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          })
          .toList();

      debugPrint('✅ נטענו ${products.length} מוצרים מ-Firestore');
      return products;
    } catch (e) {
      debugPrint('❌ שגיאה בטעינת מוצרים עם pagination: $e');
      return [];
    }
  }

  /// טעינת מוצרים לפי קטגוריה
  /// 
  /// מבצע query ב-Firestore לפי שדה 'category'
  /// 
  /// Parameters:
  ///   - [category]: שם הקטגוריה (למשל: 'מוצרי חלב', 'ירקות')
  /// 
  /// Returns:
  ///   - List של מוצרים בקטגוריה
  ///   - List ריק אם אין תוצאות או שגיאה
  /// 
  /// Example:
  /// ```dart
  /// final dairy = await repo.getProductsByCategory('מוצרי חלב');
  /// print('${dairy.length} מוצרי חלב');
  /// ```
  @override
  Future<List<Map<String, dynamic>>> getProductsByCategory(
    String category,
  ) async {
    try {
      debugPrint('📥 טוען מוצרים בקטגוריה: $category');
      final snapshot = await _firestore
          .collection(FirestoreCollections.products)
          .where(FirestoreFields.category, isEqualTo: category)
          .get();

      final products = snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();

      debugPrint('✅ נמצאו ${products.length} מוצרים בקטגוריה $category');
      return products;
    } catch (e) {
      debugPrint('❌ שגיאה בטעינת מוצרים לפי קטגוריה: $e');
      return [];
    }
  }

  /// קבלת מוצר לפי ברקוד
  /// 
  /// חיפוש ב-Firestore collection 'products' לפי שדה 'barcode'
  /// 
  /// Parameters:
  ///   - [barcode]: הברקוד לחיפוש (למשל: '7290000000001')
  /// 
  /// Returns:
  ///   - Map עם נתוני המוצר אם נמצא
  ///   - null אם לא נמצא או שגיאה
  /// 
  /// Example:
  /// ```dart
  /// final product = await repo.getProductByBarcode('7290000000001');
  /// if (product != null) {
  ///   print('נמצא: ${product['name']}');
  /// } else {
  ///   print('מוצר לא נמצא');
  /// }
  /// ```
  @override
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    try {
      debugPrint('🔍 מחפש מוצר עם ברקוד: $barcode');
      final snapshot = await _firestore
          .collection(FirestoreCollections.products)
          .where(FirestoreFields.barcode, isEqualTo: barcode)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('⚠️ מוצר לא נמצא');
        return null;
      }

      final product = {...snapshot.docs.first.data(), 'id': snapshot.docs.first.id};
      debugPrint('✅ מוצר נמצא: ${product['name']}');
      return product;
    } catch (e) {
      debugPrint('❌ שגיאה בחיפוש מוצר: $e');
      return null;
    }
  }

  /// חיפוש מוצרים לפי שם או מותג
  /// 
  /// ⚠️ Note: טוען את כל המוצרים ומסנן מקומית (Firestore לא תומך ב-LIKE)
  /// לפרויקטים גדולים מומלץ Algolia/Elasticsearch
  /// 
  /// Parameters:
  ///   - [query]: טקסט לחיפוש (case-insensitive)
  /// 
  /// Returns:
  ///   - List של מוצרים שמתאימים לחיפוש
  ///   - List ריק אם אין תוצאות או שגיאה
  /// 
  /// Example:
  /// ```dart
  /// final results = await repo.searchProducts('חלב');
  /// print('נמצאו ${results.length} תוצאות');
  /// ```
  @override
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      // ⚠️ טוען את כל המוצרים ומסנן מקומית (Firestore לא תומך ב-LIKE)
      final allProducts = await getAllProducts();
      final lowerQuery = query.toLowerCase();

      final results = allProducts.where((product) {
        final name = (product['name'] ?? '').toString().toLowerCase();
        final brand = (product['brand'] ?? '').toString().toLowerCase();
        return name.contains(lowerQuery) || brand.contains(lowerQuery);
      }).toList();

      debugPrint('🔍 נמצאו ${results.length} תוצאות עבור: $query');
      return results;
    } catch (e) {
      debugPrint('❌ שגיאה בחיפוש: $e');
      return [];
    }
  }

  /// קבלת רשימת כל הקטגוריות הייחודיות
  /// 
  /// סורק את כל המוצרים ומחלץ את הקטגוריות הייחודיות
  /// 
  /// Returns:
  ///   - List של שמות קטגוריות (ממוין אלפביתית)
  ///   - List ריק במקרה של שגיאה
  /// 
  /// Example:
  /// ```dart
  /// final categories = await repo.getCategories();
  /// print('יש ${categories.length} קטגוריות');
  /// for (var cat in categories) {
  ///   print('- $cat');
  /// }
  /// ```
  @override
  Future<List<String>> getCategories() async {
    try {
      final allProducts = await getAllProducts();
      final categories = allProducts
          .map((p) => p['category']?.toString() ?? 'אחר')
          .toSet()
          .toList()
        ..sort();

      debugPrint('📂 נמצאו ${categories.length} קטגוריות');
      return categories;
    } catch (e) {
      debugPrint('❌ שגיאה בקבלת קטגוריות: $e');
      return [];
    }
  }

  /// רענון מוצרים (מאלץ טעינה מחדש מ-Firestore)
  /// 
  /// Parameters:
  ///   - [force]: אם true, מנקה את ה-cache ומאלץ טעינה מחדש
  /// 
  /// Example:
  /// ```dart
  /// // רענון רגיל (משתמש ב-cache אם תקף)
  /// await repo.refreshProducts();
  /// 
  /// // רענון מאולץ (מתעלם מ-cache)
  /// await repo.refreshProducts(force: true);
  /// ```
  @override
  Future<void> refreshProducts({bool force = false}) async {
    if (force) {
      _cachedProducts = null;
      _lastCacheUpdate = null;
    }
    await getAllProducts();
  }

  /// טוען מוצרים לפי סוג רשימה (list_type)
  /// 
  /// Parameters:
  ///   - [listType]: סוג הרשימה (supermarket, pharmacy, greengrocer, וכו')
  ///   - [limit]: מספר מקסימלי של מוצרים
  ///   - [offset]: כמה מוצרים לדלג (pagination)
  /// 
  /// Returns: רשימת מוצרים מסוננת לפי סוג הרשימה
  /// 
  /// Note: ב-Firebase אין שדה list_type, אז נסנן לפי category
  ///       (בדומה ל-LocalProductsRepository)
  /// 
  /// Example:
  /// ```dart
  /// final bakeryProducts = await repo.getProductsByListType('bakery');
  /// ```
  @override
  Future<List<Map<String, dynamic>>> getProductsByListType(
    String listType, {
    int? limit,
    int? offset,
  }) async {
    // ⚠️ Firebase לא מחלק לפי list_type, אז נחזיר את כל המוצרים
    // (הסינון יתבצע ב-ListTypeFilterService)
    return getAllProducts(limit: limit, offset: offset);
  }

  /// ניקוי ה-cache המקומי
  /// 
  /// משמש כאשר רוצים לכפות טעינה מחדש מ-Firestore
  /// בפעם הבאה ש-getAllProducts() ייקרא
  /// 
  /// Example:
  /// ```dart
  /// repo.clearCache();
  /// final products = await repo.getAllProducts(); // טוען מחדש
  /// ```
  void clearCache() {
    _cachedProducts = null;
    _lastCacheUpdate = null;
    debugPrint('🧹 Cache נוקה');
  }
}
