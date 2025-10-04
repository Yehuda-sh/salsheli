// 📄 File: lib/models/inventory_item.dart
//
// 🇮🇱 מודל InventoryItem מייצג פריט במלאי / מזווה:
//     - מזהה ייחודי (UUID/ברקוד).
//     - שם מוצר, קטגוריה, מיקום אחסון.
//     - כמות ויחידת מידה.
//     - נתמך ב־JSON לצורך שמירה מקומית (SharedPreferences / Hive)
//       או סנכרון מול API.
//
// 💡 רעיונות עתידיים:
//     - תאריך תפוגה (expiryDate).
//     - התראות כשכמות נמוכה.
//     - קישור ישיר למודל Product/PriceData.
//
// 🇬🇧 The InventoryItem model represents a pantry/storage item:
//     - Unique identifier (UUID/barcode).
//     - Product name, category, and storage location.
//     - Quantity and unit.
//     - JSON supported for local storage (SharedPreferences / Hive)
//       or API synchronization.
//
// 💡 Future ideas:
//     - Expiry date field.
//     - Low-stock notifications.
//     - Link to Product/PriceData model.
//

import 'package:json_annotation/json_annotation.dart';

part 'inventory_item.g.dart';

@JsonSerializable()
class InventoryItem {
  /// 🇮🇱 מזהה ייחודי לפריט (UUID/ברקוד).
  /// 🇬🇧 Unique identifier (UUID/barcode).
  final String id;

  /// 🇮🇱 שם המוצר (לדוגמה: "חלב 3%").
  /// 🇬🇧 Product name (e.g., "Milk 3%").
  final String productName;

  /// 🇮🇱 קטגוריה (חלב, בשר, ירקות...).
  /// 🇬🇧 Category (dairy, meat, vegetables...).
  final String category;

  /// 🇮🇱 מיקום אחסון (מקרר, מקפיא, ארון).
  /// 🇬🇧 Storage location (fridge, freezer, pantry).
  final String location;

  /// 🇮🇱 כמות זמינה.
  /// 🇬🇧 Available quantity.
  final int quantity;

  /// 🇮🇱 יחידת מידה (יחידה, ק"ג, ליטר...).
  /// 🇬🇧 Unit of measure (pcs, kg, liter...).
  final String unit;

  const InventoryItem({
    required this.id,
    required this.productName,
    required this.category,
    required this.location,
    required this.quantity,
    required this.unit,
  });

  /// 🇮🇱 יצירה מ־JSON (deserialize).
  /// 🇬🇧 Create from JSON.
  factory InventoryItem.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemFromJson(json);

  /// 🇮🇱 המרה ל־JSON (serialize).
  /// 🇬🇧 Convert to JSON.
  Map<String, dynamic> toJson() => _$InventoryItemToJson(this);

  /// 🇮🇱 יצירת עותק חדש עם עדכונים.
  /// 🇬🇧 Create a new copy with updates.
  InventoryItem copyWith({
    String? id,
    String? productName,
    String? category,
    String? location,
    int? quantity,
    String? unit,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      location: location ?? this.location,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  @override
  String toString() =>
      'InventoryItem(id: $id, name: $productName, qty: $quantity $unit, location: $location)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryItem &&
          other.id == id &&
          other.productName == productName &&
          other.category == category &&
          other.location == location &&
          other.quantity == quantity &&
          other.unit == unit;

  @override
  int get hashCode =>
      Object.hash(id, productName, category, location, quantity, unit);
}
