// 📄 File: lib/models/product_entity.dart
// Version: 2.0
// Last Updated: 06/10/2025
//
// Purpose:
//   מודל ProductEntity מייצג מוצר שמאוחסן מקומית ב-Hive.
//   תומך בשמירת מידע בסיסי על מוצר + עדכון מחירים דינמי.
//
// Features:
//   ✅ Hive persistence (@HiveType)
//   ✅ Dynamic price updates (updatePrice)
//   ✅ Price validity check (24h expiry)
//   ✅ JSON-like toMap for UI
//   ✅ Factory from PublishedProduct (API)
//   ✅ Error handling + logging
//
// Usage:
//   ```dart
//   // יצירה מ-API response
//   final product = ProductEntity.fromPublishedProduct({
//     'barcode': '7290000000001',
//     'name': 'חלב 3%',
//     'category': 'מוצרי חלב',
//     'brand': 'תנובה',
//     'unit': 'ליטר',
//     'icon': '🥛',
//     'price': 6.5,
//     'store': 'שופרסל',
//   });
//
//   // שמירה ב-Hive
//   await box.put(product.barcode, product);
//
//   // עדכון מחיר
//   product.updatePrice(price: 6.9, store: 'רמי לוי');
//
//   // המרה ל-Map ל-UI
//   final map = product.toMap();
//   ```
//
// Dependencies:
//   - hive: Local storage
//   - local_products_repository: CRUD operations
//
// Notes:
//   - typeId=0 ב-Hive (ProductEntityAdapter)
//   - extends HiveObject לאפשר save() ישיר

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'product_entity.g.dart';

/// לא immutable כי updatePrice() משנה currentPrice, lastPriceStore, lastPriceUpdate
@HiveType(typeId: 0)
class ProductEntity extends HiveObject {
  @HiveField(0)
  final String barcode;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String brand;

  @HiveField(4)
  final String unit;

  @HiveField(5)
  final String icon;

  /// מחיר נוכחי (null אם עדיין לא נטען)
  @HiveField(6)
  double? currentPrice;

  /// חנות ממנה נשלף המחיר
  @HiveField(7)
  String? lastPriceStore;

  /// תאריך עדכון מחיר אחרון
  @HiveField(8)
  DateTime? lastPriceUpdate;

  ProductEntity({
    required this.barcode,
    required this.name,
    required this.category,
    required this.brand,
    required this.unit,
    required this.icon,
    this.currentPrice,
    this.lastPriceStore,
    this.lastPriceUpdate,
  });

  /// המרה ל-Map (לשימוש ב-UI)
  /// 
  /// Returns:
  ///   Map עם כל הנתונים כולל מחיר ו-lastUpdate
  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'name': name,
      'category': category,
      'brand': brand,
      'unit': unit,
      'icon': icon,
      'price': currentPrice,
      'store': lastPriceStore,
      'lastUpdate': lastPriceUpdate?.toIso8601String(),
    };
  }

  /// יצירה מ-PublishedProduct (מה-API)
  /// 
  /// Parameters:
  ///   publishedProduct: Map עם נתוני מוצר מה-API
  /// 
  /// Returns:
  ///   ProductEntity חדש עם נתונים מה-API
  /// 
  /// Throws:
  ///   Exception אם publishedProduct null או ריק
  factory ProductEntity.fromPublishedProduct(
    Map<String, dynamic> publishedProduct,
  ) {
    if (publishedProduct.isEmpty) {
      throw Exception('PublishedProduct cannot be empty');
    }

    final barcode = publishedProduct['barcode']?.toString() ?? '';
    final name = publishedProduct['name']?.toString() ?? '';
    
    if (barcode.isEmpty) {
      throw Exception('Barcode is required');
    }
    
    if (name.isEmpty) {
      throw Exception('Product name is required');
    }

    return ProductEntity(
      barcode: barcode,
      name: name,
      category: publishedProduct['category']?.toString() ?? 'אחר',
      brand: publishedProduct['brand']?.toString() ?? '',
      unit: publishedProduct['unit']?.toString() ?? '',
      icon: publishedProduct['icon']?.toString() ?? '🛒',
      currentPrice: publishedProduct['price'] as double?,
      lastPriceStore: publishedProduct['store']?.toString(),
      lastPriceUpdate: publishedProduct['price'] != null ? DateTime.now() : null,
    );
  }

  /// עדכון מחיר בלבד
  /// 
  /// Parameters:
  ///   price: מחיר חדש
  ///   store: שם החנות
  /// 
  /// Side effects:
  ///   מעדכן currentPrice, lastPriceStore, lastPriceUpdate
  ///   שומר ב-Hive אוטומטית (save())
  void updatePrice({
    required double price,
    required String store,
  }) {
    try {
      currentPrice = price;
      lastPriceStore = store;
      lastPriceUpdate = DateTime.now();
      
      save(); // שמירה ב-Hive
    } catch (e) {
      debugPrint('❌ ProductEntity.updatePrice שגיאה: $e');
      rethrow;
    }
  }

  @override
  String toString() =>
      'ProductEntity(barcode: $barcode, name: $name, price: $currentPrice)';
}
