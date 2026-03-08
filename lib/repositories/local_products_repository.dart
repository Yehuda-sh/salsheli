// 📄 File: lib/repositories/local_products_repository.dart
//
// 🎯 Purpose: Repository למוצרים מקובצי JSON מקומיים (assets)
//
// 📋 Features:
//     - טעינת מוצרים מ-assets/data/list_types/{type}.json
//     - Cache חכם (נפרד לכל סוג רשימה)
//     - טעינה מקבילית (Parallel Loading) עם Future.wait
//     - ניהול Concurrency מבוסס Future-Sharing (ללא polling)
//     - ייעול אלגוריתם החיפוש (cache-first + lazy load)
//     - Fallback ל-supermarket.json אם הקובץ לא קיים
//
// 📦 Supported List Types:
//     - supermarket, pharmacy, greengrocer, butcher, bakery, market
//     - household, other → fallback to supermarket
//
// 💡 Usage:
//     ```dart
//     final repo = LocalProductsRepository();
//     final products = await repo.getProductsByListType('bakery');
//     ```
//
// 🔗 Related:
//     - lib/repositories/products_repository.dart - Interface
//     - lib/repositories/hybrid_products_repository.dart - מימוש משולב
//     - lib/providers/products_provider.dart - Provider
//
// Version: 4.0
// Last Updated: 22/02/2026

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'products_repository.dart';

class LocalProductsRepository implements ProductsRepository {
  // Cache של מוצרים - נפרד לכל list_type
  final Map<String, List<Map<String, dynamic>>> _cache = {};

  // Shared Futures - מבטיח שקובץ לא נטען פעמיים בו-זמנית
  final Map<String, Future<List<Map<String, dynamic>>>> _loadingFutures = {};

  // List types עם JSON ייעודי
  static const Set<String> _supportedTypes = {
    'supermarket',
    'pharmacy',
    'greengrocer',
    'butcher',
    'bakery',
    'market',
  };

  // Fallback type
  static const String _fallbackType = 'supermarket';

  /// טוען מוצרים לפי סוג רשימה
  ///
  /// משתמש ב-Shared Futures: אם קובץ כבר בטעינה, קריאות נוספות
  /// מחכות לאותו Future במקום לטעון מחדש (zero polling).
  ///
  /// [listType] - סוג הרשימה (supermarket, bakery, וכו')
  /// [limit] - מספר מקסימלי של מוצרים
  /// [offset] - כמה מוצרים לדלג (pagination)
  ///
  /// Returns: רשימת מוצרים מסוננת לפי סוג הרשימה
  @override
  Future<List<Map<String, dynamic>>> getProductsByListType(
    String listType, {
    int? limit,
    int? offset,
  }) async {
    final fileType = _supportedTypes.contains(listType) ? listType : _fallbackType;

    // Cache hit - החזר מיד
    if (_cache.containsKey(fileType)) {
      return _applyPagination(_cache[fileType]!, limit: limit, offset: offset);
    }

    // Shared Future - אם כבר בטעינה, חכה לאותו Future
    final products = await (_loadingFutures[fileType] ??= _loadFile(fileType));

    return _applyPagination(products, limit: limit, offset: offset);
  }

  /// טוען קובץ JSON בודד ושומר ב-cache
  ///
  /// מנקה את ה-Future מ-_loadingFutures בסיום (הצלחה או כשלון)
  Future<List<Map<String, dynamic>>> _loadFile(String fileType) async {
    try {
      final path = 'assets/data/list_types/$fileType.json';

      final jsonString = await rootBundle.loadString(path);
      final List<dynamic> jsonData = json.decode(jsonString);

      // Cast בטוח - מוודא שכל אלמנט הוא Map תקין
      final products = jsonData
          .whereType<Map<String, dynamic>>()
          .toList();

      _cache[fileType] = products;

      return products;
    } catch (e) {

      // Fallback ל-supermarket אם נכשל
      if (fileType != _fallbackType) {
        return getProductsByListType(_fallbackType);
      }

      _cache[fileType] = [];
      return [];
    } finally {
      unawaited(_loadingFutures.remove(fileType));
    }
  }

  /// טוען את כל המוצרים (מכל הסוגים)
  /// 
  /// ⚠️ Legacy method - עדיף להשתמש ב-getProductsByListType!
  @override
  Future<List<Map<String, dynamic>>> getAllProducts({
    int? limit,
    int? offset,
  }) async {
    // Default: טוען מ-supermarket
    return getProductsByListType(_fallbackType, limit: limit, offset: offset);
  }

  /// מיישם pagination על רשימה
  List<Map<String, dynamic>> _applyPagination(
    List<Map<String, dynamic>> products, {
    int? limit,
    int? offset,
  }) {
    final start = offset ?? 0;
    if (start >= products.length) return [];

    final end = limit != null ? start + limit : products.length;
    return products.sublist(
      start.clamp(0, products.length),
      end.clamp(0, products.length),
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getProductsByCategory(String category) async {
    // טוען מסופרמרקט (הכי מקיף)
    final all = await getProductsByListType(_fallbackType);
    return all.where((p) => p['category'] == category).toList();
  }

  @override
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    // חפש בכל הקבצים שנטענו ב-cache
    for (final products in _cache.values) {
      try {
        return products.firstWhere((p) => p['barcode'] == barcode);
      } catch (_) {
        // ממשיך לקובץ הבא
      }
    }

    // אם לא נמצא - טען מסופרמרקט וחפש
    final all = await getProductsByListType(_fallbackType);
    try {
      return all.firstWhere((p) => p['barcode'] == barcode);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final lowerQuery = query.toLowerCase();

    // וודא שלפחות supermarket נטען (cache-first)
    if (_cache.isEmpty) {
      await getProductsByListType(_fallbackType);
    }

    // חפש בכל ה-cache הקיים בסריקה אחת
    return _cache.values
        .expand((products) => products)
        .where((product) => _matchesQuery(product, lowerQuery))
        .toList();
  }

  @override
  Stream<List<Map<String, dynamic>>> searchProductsStream(String query) {
    return Stream.fromFuture(searchProducts(query));
  }

  /// בודק אם מוצר תואם לחיפוש (שם או מותג)
  bool _matchesQuery(Map<String, dynamic> product, String lowerQuery) {
    final name = (product['name'] as String?)?.toLowerCase() ?? '';
    final brand = (product['brand'] as String?)?.toLowerCase() ?? '';
    return name.contains(lowerQuery) || brand.contains(lowerQuery);
  }

  @override
  Future<List<String>> getCategories() async {
    // איסוף קטגוריות מכל הקבצים שנטענו
    final categories = <String>{};

    for (final products in _cache.values) {
      categories.addAll(
        products.map((p) => p['category']?.toString() ?? 'אחר'),
      );
    }

    // אם אין cache - טען מסופרמרקט
    if (categories.isEmpty) {
      final all = await getProductsByListType(_fallbackType);
      categories.addAll(
        all.map((p) => p['category']?.toString() ?? 'אחר'),
      );
    }

    return categories.toList()..sort();
  }

  @override
  Future<void> refreshProducts({bool force = false}) async {
    if (force) {
      _cache.clear();
      _loadingFutures.clear();
    }
    await getProductsByListType(_fallbackType);
  }

  /// טוען מוצרים מכל סוגי הרשימות (למזווה)
  ///
  /// משתמש ב-Future.wait לטעינה מקבילית של כל הקבצים -
  /// מקצר משמעותית את זמן הטעינה הראשונית.
  /// מסיר כפילויות לפי שם מוצר.
  ///
  /// Returns: רשימת כל המוצרים מכל הסוגים (ללא כפילויות)
  Future<List<Map<String, dynamic>>> getAllListTypesProducts() async {
    // טעינה מקבילית של כל הקבצים
    final typesList = _supportedTypes.toList();
    final results = await Future.wait(
      typesList.map(getProductsByListType),
    );

    // מיזוג עם הסרת כפילויות
    final allProducts = <Map<String, dynamic>>[];
    final seenNames = <String>{};

    for (var i = 0; i < typesList.length; i++) {
      final listType = typesList[i];
      for (final product in results[i]) {
        final name = (product['name'] as String?)?.toLowerCase() ?? '';
        if (name.isNotEmpty && seenNames.add(name)) {
          allProducts.add({...product, 'source': listType});
        }
      }
    }

    return allProducts;
  }

  /// ניקוי cache מלא
  void clearCache() {
    _cache.clear();
    _loadingFutures.clear();
  }

  /// ניקוי cache של סוג רשימה ספציפי
  void clearCacheForType(String listType) {
    _cache.remove(listType);
    _loadingFutures.remove(listType);
  }
}
