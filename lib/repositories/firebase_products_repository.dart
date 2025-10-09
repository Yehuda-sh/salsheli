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
//     1. העלה מוצרים ל-Firestore (ראה scripts/upload_to_firebase.js).
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
//     1. Upload products to Firestore (see scripts/upload_to_firebase.js).
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
//     - scripts/upload_to_firebase.js (upload script)

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'products_repository.dart';

class FirebaseProductsRepository implements ProductsRepository {
  final FirebaseFirestore _firestore;
  static const String _collectionName = 'products';

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
  /// Returns:
  ///   - List של Maps עם נתוני מוצרים
  ///   - List ריק במקרה של שגיאה
  /// 
  /// Example:
  /// ```dart
  /// final products = await repo.getAllProducts();
  /// print('נטענו ${products.length} מוצרים');
  /// ```
  @override
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    // אם יש cache תקף - החזר אותו
    if (_isCacheValid && _cachedProducts != null) {
      debugPrint('✅ מחזיר ${_cachedProducts!.length} מוצרים מ-cache');
      return _cachedProducts!;
    }

    try {
      debugPrint('📥 טוען מוצרים מ-Firestore...');
      final snapshot = await _firestore.collection(_collectionName).get();

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
          .collection(_collectionName)
          .where('category', isEqualTo: category)
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
          .collection(_collectionName)
          .where('barcode', isEqualTo: barcode)
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
