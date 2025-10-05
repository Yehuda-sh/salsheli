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
  final String _collectionName = 'products';

  // Cache מקומי
  List<Map<String, dynamic>>? _cachedProducts;
  DateTime? _lastCacheUpdate;
  static const Duration _cacheValidity = Duration(hours: 1);

  FirebaseProductsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// בדיקה אם ה-cache תקף
  bool get _isCacheValid {
    if (_cachedProducts == null || _lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheValidity;
  }

  /// טעינת כל המוצרים מ-Firestore
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

  /// חיפוש מוצרים
  @override
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      // טוען את כל המוצרים ומסנן מקומית (Firestore לא תומך ב-LIKE)
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

  /// קבלת כל הקטגוריות
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
  @override
  Future<void> refreshProducts({bool force = false}) async {
    if (force) {
      _cachedProducts = null;
      _lastCacheUpdate = null;
    }
    await getAllProducts();
  }

  /// ניקוי cache
  void clearCache() {
    _cachedProducts = null;
    _lastCacheUpdate = null;
    debugPrint('🧹 Cache נוקה');
  }
}
