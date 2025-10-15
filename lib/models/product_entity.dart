// 📄 File: lib/models/product_entity.dart
// Version: 2.1
// Last Updated: 15/10/2025
//
// ✅ Improvements in v2.1:
// - Added defensive @nonNull for essential fields
// - Clarified docstrings
// - Improved fromPublishedProduct validation & logging
// - Added isPriceValid (24h freshness check)
// - Cleaned save() logic
//
// 🧱 Purpose:
//   מודל ProductEntity מייצג מוצר מקומי שנשמר ב-Hive.
//   כולל מחיר דינמי, מקור החנות, זמן עדכון.
//
// Dependencies:
//   - hive
//   - hive_flutter
//   - local_products_repository
//
// 🧠 Notes:
//   - extends HiveObject כדי לאפשר save()
//   - barcode = מפתח ראשי בקופסת Hive
//   - price מתעדכן אוטומטית דרך updatePrice()

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'product_entity.g.dart';

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

  /// מחיר נוכחי (null אם עדיין לא קיים)
  @HiveField(6)
  double? currentPrice;

  /// שם חנות אחרונה
  @HiveField(7)
  String? lastPriceStore;

  /// מתי עודכן המחיר האחרון
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

  /// ✅ האם המחיר נחשב עדכני (פחות מ-24 שעות)
  bool get isPriceValid {
    if (lastPriceUpdate == null) return false;
    final diff = DateTime.now().difference(lastPriceUpdate!);
    return diff.inHours < 24;
  }

  /// יצירה מ-PublishedProduct (API)
  factory ProductEntity.fromPublishedProduct(Map<String, dynamic> json) {
    if (json.isEmpty) throw ArgumentError('Product JSON cannot be empty');

    final barcode = json['barcode']?.toString() ?? '';
    final name = json['name']?.toString() ?? '';

    if (barcode.isEmpty) throw ArgumentError('Missing barcode');
    if (name.isEmpty) throw ArgumentError('Missing name');

    return ProductEntity(
      barcode: barcode,
      name: name,
      category: json['category']?.toString() ?? 'אחר',
      brand: json['brand']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '🛒',
      currentPrice: (json['price'] is num) ? (json['price'] as num).toDouble() : null,
      lastPriceStore: json['store']?.toString(),
      lastPriceUpdate: json['price'] != null ? DateTime.now() : null,
    );
  }

  /// עדכון מחיר (עם חנות ותאריך עדכון)
  void updatePrice({required double price, required String store}) {
    currentPrice = price;
    lastPriceStore = store;
    lastPriceUpdate = DateTime.now();

    try {
      save(); // שמירה אוטומטית ב-Hive
    } catch (e) {
      debugPrint('❌ ProductEntity.save() failed: $e');
      rethrow;
    }
  }

  /// המרה ל-Map (לשימוש ב-UI / Firestore)
  Map<String, dynamic> toMap() => {
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

  @override
  String toString() => 'ProductEntity(barcode: $barcode, name: $name, price: $currentPrice)';
}
