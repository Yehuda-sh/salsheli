// 📄 lib/models/product_entity.dart
//
// 🎯 Entity למוצר - מאוחסן מקומית ב-Hive
// - שמירת מוצרים קבועה (ללא מחירים)
// - עדכון מחירים דינמי

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

  // 💰 מחיר - NULL אם עדיין לא נטען מה-API
  @HiveField(6)
  double? currentPrice;

  // 🏪 חנות אחרונה שממנה נשלף המחיר
  @HiveField(7)
  String? lastPriceStore;

  // 📅 מתי עודכן המחיר לאחרונה
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
  factory ProductEntity.fromPublishedProduct(
    Map<String, dynamic> publishedProduct,
  ) {
    return ProductEntity(
      barcode: publishedProduct['barcode'] ?? '',
      name: publishedProduct['name'] ?? '',
      category: publishedProduct['category'] ?? 'אחר',
      brand: publishedProduct['brand'] ?? '',
      unit: publishedProduct['unit'] ?? '',
      icon: publishedProduct['icon'] ?? '🛒',
      currentPrice: publishedProduct['price'],
      lastPriceStore: publishedProduct['store'],
      lastPriceUpdate: DateTime.now(),
    );
  }

  /// עדכון מחיר בלבד
  void updatePrice({
    required double price,
    required String store,
  }) {
    currentPrice = price;
    lastPriceStore = store;
    lastPriceUpdate = DateTime.now();
    save(); // שמירה ב-Hive
  }

  /// האם המחיר תקף? (עד 24 שעות)
  bool get isPriceValid {
    if (currentPrice == null || lastPriceUpdate == null) return false;
    final age = DateTime.now().difference(lastPriceUpdate!);
    return age.inHours < 24;
  }

  @override
  String toString() =>
      'ProductEntity(barcode: $barcode, name: $name, price: $currentPrice)';
}
