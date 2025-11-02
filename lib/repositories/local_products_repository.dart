// 📄 File: lib/repositories/local_products_repository.dart
// Repository למוצרים מקובץ JSON מקומי
//
// 🎯 Purpose:
// - טוען מוצרים מ-assets/data/list_types/{type}.json
// - Cache חכם (נפרד לכל סוג רשימה)
// - Fallback ל-supermarket.json אם הקובץ לא קיים
// - ממיר ProductsRepository interface
//
// 💡 Usage:
// ```dart
// final repo = LocalProductsRepository();
// final products = await repo.getProductsByListType('bakery');
// ```
//
// 📦 Supported List Types:
// - supermarket, pharmacy, greengrocer, butcher, bakery, market
// - household, other → fallback to supermarket

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'products_repository.dart';

class LocalProductsRepository implements ProductsRepository {
  // Cache של מוצרים - נפרד לכל list_type
  final Map<String, List<Map<String, dynamic>>> _cache = {};
  final Set<String> _loading = {};

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
  /// [listType] - סוג הרשימה (supermarket, bakery, וכו')
  /// [limit] - מספר מקסימלי של מוצרים
  /// [offset] - כמה מוצרים לדלג (pagination)
  /// 
  /// Returns: רשימת מוצרים מסוננת לפי סוג הרשימה
  Future<List<Map<String, dynamic>>> getProductsByListType(
    String listType, {
    int? limit,
    int? offset,
  }) async {
    // קבע איזה קובץ לטעון
    final fileType = _supportedTypes.contains(listType) ? listType : _fallbackType;

    // אם יש cache - החזר אותו
    if (_cache.containsKey(fileType)) {
      return _applyPagination(_cache[fileType]!, limit: limit, offset: offset);
    }

    // אם כבר טוען - חכה
    if (_loading.contains(fileType)) {
      while (_loading.contains(fileType)) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return _applyPagination(_cache[fileType]!, limit: limit, offset: offset);
    }

    try {
      _loading.add(fileType);
      final path = 'assets/data/list_types/$fileType.json';
      debugPrint('📥 טוען מוצרים מ-$path...');

      final jsonString = await rootBundle.loadString(path);
      final List<dynamic> jsonData = json.decode(jsonString);

      _cache[fileType] = jsonData.cast<Map<String, dynamic>>();
      debugPrint('✅ נטענו ${_cache[fileType]!.length} מוצרים מ-$fileType');

      return _applyPagination(_cache[fileType]!, limit: limit, offset: offset);
    } catch (e) {
      debugPrint('❌ שגיאה בטעינת מוצרים מ-$fileType: $e');

      // Fallback ל-supermarket אם נכשל
      if (fileType != _fallbackType) {
        debugPrint('⚠️ נסה fallback ל-$_fallbackType...');
        return getProductsByListType(_fallbackType, limit: limit, offset: offset);
      }

      _cache[fileType] = [];
      return [];
    } finally {
      _loading.remove(fileType);
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
    // חפש בכל הקבצים שנטענו ב-cache
    final results = <Map<String, dynamic>>[];
    final lowerQuery = query.toLowerCase();

    for (final products in _cache.values) {
      results.addAll(
        products.where((product) {
          final name = (product['name'] ?? '').toString().toLowerCase();
          final brand = (product['brand'] ?? '').toString().toLowerCase();
          return name.contains(lowerQuery) || brand.contains(lowerQuery);
        }),
      );
    }

    // אם אין תוצאות - חפש בסופרמרקט
    if (results.isEmpty) {
      final all = await getProductsByListType(_fallbackType);
      results.addAll(
        all.where((product) {
          final name = (product['name'] ?? '').toString().toLowerCase();
          final brand = (product['brand'] ?? '').toString().toLowerCase();
          return name.contains(lowerQuery) || brand.contains(lowerQuery);
        }),
      );
    }

    return results;
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
      debugPrint('🧹 Cache נוקה');
    }
    // טען מחדש את supermarket
    await getProductsByListType(_fallbackType);
  }

  /// ניקוי cache
  void clearCache() {
    _cache.clear();
    debugPrint('🧹 Cache נוקה - ${_cache.length} קבצים');
  }

  /// ניקוי cache של סוג רשימה ספציפי
  void clearCacheForType(String listType) {
    _cache.remove(listType);
    debugPrint('🧹 Cache נוקה עבור $listType');
  }
}
