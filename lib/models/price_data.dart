// 📄 File: lib/models/price_data.dart
//
// 🇮🇱 מודל מידע מחירים:
//     - מייצג מידע מחירים עבור מוצר אחד או מספר וריאנטים שלו.
//     - כולל ממוצע, טווח מחירים (min/max), מידע לפי חנויות (StorePrice),
//       ומידע לפי ברקוד/וריאנט (PriceItem).
//     - נתמך ע"י JSON לצורך שמירה מקומית או סנכרון מול API.
//
// 💡 רעיונות עתידיים:
//     - הוספת מטבעות נוספים (USD, EUR).
//     - הוספת "confidence score" לאמינות הנתונים.
//     - חיבור ל־Product כדי לקשר מחירים ישירות למוצר.
//
// 🇬🇧 Price data model:
//     - Represents price information for a product or its variants.
//     - Includes average, price range (min/max),
//       store-level pricing (StorePrice),
//       and barcode-level details (PriceItem).
//     - Supports JSON for local storage or API sync.
//
// 💡 Future ideas:
//     - Multi-currency support (USD, EUR).
//     - Add "confidence score" for data reliability.
//     - Link directly to Product model.
//

import 'package:json_annotation/json_annotation.dart';

part 'price_data.g.dart';

/// ─────────────────────────────────────────────
/// PriceData (מידע מחירים כולל עבור מוצר)
/// ─────────────────────────────────────────────
@JsonSerializable(explicitToJson: true)
class PriceData {
  /// 🇮🇱 שם המוצר
  /// 🇬🇧 Product name
  final String productName;

  /// 🇮🇱 מחיר ממוצע
  /// 🇬🇧 Average price
  final double averagePrice;

  /// 🇮🇱 מחיר מינימום
  /// 🇬🇧 Minimum price found
  final double minPrice;

  /// 🇮🇱 מחיר מקסימום
  /// 🇬🇧 Maximum price found
  final double maxPrice;

  /// 🇮🇱 מחירים לפי חנויות
  /// 🇬🇧 Prices by store
  final List<StorePrice> stores;

  /// 🇮🇱 וריאנטים לפי ברקוד/מזהה מוצר
  /// 🇬🇧 Variants by barcode/product code
  final List<PriceItem>? items;

  /// 🇮🇱 מתי עודכן לאחרונה
  /// 🇬🇧 Last update timestamp
  final DateTime? lastUpdated;

  const PriceData({
    required this.productName,
    required this.averagePrice,
    required this.minPrice,
    required this.maxPrice,
    required this.stores,
    this.items,
    this.lastUpdated,
  });

  factory PriceData.fromJson(Map<String, dynamic> json) =>
      _$PriceDataFromJson(json);

  Map<String, dynamic> toJson() => _$PriceDataToJson(this);

  /// 🇮🇱 יצירת עותק חדש עם עדכונים
  /// 🇬🇧 Create a new copy with updates
  PriceData copyWith({
    String? productName,
    double? averagePrice,
    double? minPrice,
    double? maxPrice,
    List<StorePrice>? stores,
    List<PriceItem>? items,
    DateTime? lastUpdated,
  }) {
    return PriceData(
      productName: productName ?? this.productName,
      averagePrice: averagePrice ?? this.averagePrice,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      stores: stores ?? this.stores,
      items: items ?? this.items,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() =>
      'PriceData(product: $productName, avg: $averagePrice, '
      'range: $minPrice-$maxPrice, stores: ${stores.length}, '
      'items: ${items?.length ?? 0})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceData &&
          other.productName == productName &&
          other.averagePrice == averagePrice &&
          other.minPrice == minPrice &&
          other.maxPrice == maxPrice &&
          other.stores == stores &&
          other.items == items &&
          other.lastUpdated == lastUpdated;

  @override
  int get hashCode => Object.hash(
    productName,
    averagePrice,
    minPrice,
    maxPrice,
    stores,
    items,
    lastUpdated,
  );
}

/// ─────────────────────────────────────────────
/// StorePrice (מחיר ברמת חנות)
/// ─────────────────────────────────────────────
@JsonSerializable()
class StorePrice {
  /// 🇮🇱 שם החנות
  /// 🇬🇧 Store name
  final String storeName;

  /// 🇮🇱 מחיר בחנות זו
  /// 🇬🇧 Price in this store
  final double price;

  const StorePrice({required this.storeName, required this.price});

  factory StorePrice.fromJson(Map<String, dynamic> json) =>
      _$StorePriceFromJson(json);

  Map<String, dynamic> toJson() => _$StorePriceToJson(this);

  StorePrice copyWith({String? storeName, double? price}) {
    return StorePrice(
      storeName: storeName ?? this.storeName,
      price: price ?? this.price,
    );
  }

  @override
  String toString() => 'StorePrice($storeName: $price)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorePrice &&
          other.storeName == storeName &&
          other.price == price;

  @override
  int get hashCode => Object.hash(storeName, price);
}

/// ─────────────────────────────────────────────
/// PriceItem (וריאנט לפי ברקוד/קוד מוצר)
/// ─────────────────────────────────────────────
@JsonSerializable()
class PriceItem {
  /// 🇮🇱 קוד/ברקוד של המוצר
  /// 🇬🇧 Product code / barcode
  final String code;

  /// 🇮🇱 שם הוריאנט
  /// 🇬🇧 Variant name
  final String name;

  /// 🇮🇱 מחיר הוריאנט
  /// 🇬🇧 Variant price
  final double price;

  /// 🇮🇱 יצרן/מותג (אופציונלי)
  /// 🇬🇧 Manufacturer/brand (optional)
  final String? manufacturer;

  const PriceItem({
    required this.code,
    required this.name,
    required this.price,
    this.manufacturer,
  });

  factory PriceItem.fromJson(Map<String, dynamic> json) =>
      _$PriceItemFromJson(json);

  Map<String, dynamic> toJson() => _$PriceItemToJson(this);

  PriceItem copyWith({
    String? code,
    String? name,
    double? price,
    String? manufacturer,
  }) {
    return PriceItem(
      code: code ?? this.code,
      name: name ?? this.name,
      price: price ?? this.price,
      manufacturer: manufacturer ?? this.manufacturer,
    );
  }

  @override
  String toString() => 'PriceItem($code - $name: $price)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceItem &&
          other.code == code &&
          other.name == name &&
          other.price == price &&
          other.manufacturer == manufacturer;

  @override
  int get hashCode => Object.hash(code, name, price, manufacturer);
}
