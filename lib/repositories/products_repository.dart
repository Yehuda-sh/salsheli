// 📄 lib/repositories/products_repository.dart
//
// 🎯 Repository למוצרים - שכבת ביניים בין UI למקור הנתונים
// - תומך בטעינה מקאש
// - תומך בעדכון מהשרת
// - חיפוש וסינון

import 'package:flutter/foundation.dart';
import '../services/published_prices_service.dart';

abstract class ProductsRepository {
  Future<List<Map<String, dynamic>>> getAllProducts();
  Future<List<Map<String, dynamic>>> getProductsByCategory(String category);
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode);
  Future<List<Map<String, dynamic>>> searchProducts(String query);
  Future<List<String>> getCategories();
  Future<void> refreshProducts({bool force = false});
}

/// מימוש עם PublishedPricesService (מחירון רשמי)
class PublishedPricesRepository implements ProductsRepository {
  final PublishedPricesService _pricesService;

  PublishedPricesRepository({PublishedPricesService? pricesService})
    : _pricesService = pricesService ?? PublishedPricesService();

  @override
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      final products = await _pricesService.getProducts();
      return products.map((p) => p.toAppFormat()).toList();
    } catch (e) {
      debugPrint('❌ שגיאה בטעינת כל המוצרים: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getProductsByCategory(
    String category,
  ) async {
    try {
      final allProducts = await _pricesService.getProducts();
      // ✅ המוצרים כבר ממופים ל-Map עם שדה 'category'
      return allProducts
          .map((p) => p.toAppFormat()) // המרה למפה
          .where((productMap) => productMap['category'] == category) // סינון
          .toList();
    } catch (e) {
      debugPrint('❌ שגיאה בטעינת מוצרים לפי קטגוריה: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    try {
      final allProducts = await _pricesService.getProducts();
      final product = allProducts.cast<PublishedProduct?>().firstWhere(
        (p) => p?.itemCode == barcode,
        orElse: () => null,
      );
      return product?.toAppFormat();
    } catch (e) {
      debugPrint('❌ שגיאה בחיפוש מוצר לפי ברקוד: $e');
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final allProducts = await _pricesService.getProducts();
      final lowerQuery = query.toLowerCase();
      return allProducts
          .where(
            (p) =>
                p.itemName.toLowerCase().contains(lowerQuery) ||
                p.manufacturerName.toLowerCase().contains(lowerQuery),
          )
          .map((p) => p.toAppFormat())
          .toList();
    } catch (e) {
      debugPrint('❌ שגיאה בחיפוש מוצרים: $e');
      return [];
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final allProducts = await _pricesService.getProducts();
      // ✅ שולף את כל הקטגוריות מהמוצרים הממופים
      return allProducts
          .map((p) => p.toAppFormat()['category'] as String)
          .toSet() // הסרת כפילויות
          .toList()
        ..sort(); // מיון אלפביתי
    } catch (e) {
      debugPrint('❌ שגיאה בקבלת קטגוריות: $e');
      return [];
    }
  }

  @override
  Future<void> refreshProducts({bool force = false}) async {
    try {
      await _pricesService.getProducts(forceRefresh: force);
    } catch (e) {
      debugPrint('❌ שגיאה ברענון מוצרים: $e');
    }
  }
}

/// מימוש Mock - לפיתוח ובדיקות
class MockProductsRepository implements ProductsRepository {
  final List<Map<String, dynamic>> _mockProducts = [
    {
      'name': 'חלב 3%',
      'category': 'מוצרי חלב',
      'icon': '🥛',
      'price': 7.9,
      'unit': 'ליטר',
      'barcode': '7290000000001',
    },
    {
      'name': 'לחם שחור',
      'category': 'מאפים',
      'icon': '🍞',
      'price': 8.5,
      'unit': 'יחידה',
      'barcode': '7290000000010',
    },
    {
      'name': 'גבינה צהובה',
      'category': 'מוצרי חלב',
      'icon': '🧀',
      'price': 15.2,
      'unit': '100 גרם',
      'barcode': '7290000000020',
    },
    {
      'name': 'עגבניות',
      'category': 'ירקות',
      'icon': '🍅',
      'price': 5.4,
      'unit': 'ק"ג',
      'barcode': '7290000000030',
    },
    {
      'name': 'בננה',
      'category': 'פירות',
      'icon': '🍌',
      'price': 6.5,
      'unit': 'ק"ג',
      'barcode': '7290000000051',
    },
  ];

  @override
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockProducts);
  }

  @override
  Future<List<Map<String, dynamic>>> getProductsByCategory(
    String category,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockProducts.where((p) => p['category'] == category).toList();
  }

  @override
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _mockProducts.firstWhere((p) => p['barcode'] == barcode);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final lowerQuery = query.toLowerCase();
    return _mockProducts
        .where((p) => (p['name'] as String).toLowerCase().contains(lowerQuery))
        .toList();
  }

  @override
  Future<List<String>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockProducts.map((p) => p['category'] as String).toSet().toList()
      ..sort();
  }

  @override
  Future<void> refreshProducts({bool force = false}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock - לא עושה כלום
  }
}
