// 📄 File: lib/repositories/local_products_repository.dart
// Repository למוצרים מקובץ JSON מקומי
//
// 🎯 Purpose:
// - טוען מוצרים מ-assets/data/products.json
// - Cache חכם (פעם אחת בלבד)
// - ממיר ProductsRepository interface
//
// 💡 Usage:
// ```dart
// final repo = LocalProductsRepository();
// final products = await repo.getAllProducts();
// ```

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'products_repository.dart';

class LocalProductsRepository implements ProductsRepository {
  // Cache של המוצרים
  List<Map<String, dynamic>>? _cachedProducts;
  bool _isLoading = false;

  /// טוען את כל המוצרים מה-JSON
  @override
  Future<List<Map<String, dynamic>>> getAllProducts({
    int? limit,
    int? offset,
  }) async {
    // אם יש cache - החזר אותו עם pagination
    if (_cachedProducts != null) {
      return _applyPagination(_cachedProducts!, limit: limit, offset: offset);
    }

    // טוען רק פעם אחת
    if (_isLoading) {
      // מחכה עד שהטעינה תסתיים
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return _applyPagination(_cachedProducts!, limit: limit, offset: offset);
    }

    try {
      _isLoading = true;
      debugPrint('📥 טוען מוצרים מ-assets/data/products.json...');

      final jsonString = await rootBundle.loadString('assets/data/products.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      _cachedProducts = jsonData.cast<Map<String, dynamic>>();
      debugPrint('✅ נטענו ${_cachedProducts!.length} מוצרים מ-JSON');

      return _applyPagination(_cachedProducts!, limit: limit, offset: offset);
    } catch (e) {
      debugPrint('❌ שגיאה בטעינת מוצרים: $e');
      _cachedProducts = [];
      return [];
    } finally {
      _isLoading = false;
    }
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
    final all = await getAllProducts();
    return all.where((p) => p['category'] == category).toList();
  }

  @override
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    final all = await getAllProducts();
    try {
      return all.firstWhere((p) => p['barcode'] == barcode);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final all = await getAllProducts();
    final lowerQuery = query.toLowerCase();

    return all.where((product) {
      final name = (product['name'] ?? '').toString().toLowerCase();
      final brand = (product['brand'] ?? '').toString().toLowerCase();
      return name.contains(lowerQuery) || brand.contains(lowerQuery);
    }).toList();
  }

  @override
  Future<List<String>> getCategories() async {
    final all = await getAllProducts();
    return all
        .map((p) => p['category']?.toString() ?? 'אחר')
        .toSet()
        .toList()
      ..sort();
  }

  @override
  Future<void> refreshProducts({bool force = false}) async {
    if (force) {
      _cachedProducts = null;
    }
    await getAllProducts();
  }

  /// ניקוי cache
  void clearCache() {
    _cachedProducts = null;
    debugPrint('🧹 Cache נוקה');
  }
}
