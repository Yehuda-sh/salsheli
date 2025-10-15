// 📄 File: lib/models/inventory_item.dart
// Version: 2.2
// Last Updated: 15/10/2025
//
// ✅ Improvements in v2.2:
// - Added @JsonKey(defaultValue) for safe defaults
// - Removed manual null cleaning
// - Protected `id` from modification in copyWith()
// - Cleaned up debug logging
//
// 🧱 Purpose:
//   מודל InventoryItem מייצג פריט במלאי/מזווה של משק הבית.
//   תומך בסנכרון עם Firebase Firestore בפורמט JSON.
//
// 🚀 Features:
//   ✅ JSON serialization (json_annotation)
//   ✅ Immutable model (@immutable)
//   ✅ copyWith for updates (id immutable)
//   ✅ Equality & hashCode
//   ✅ Firebase-ready (household_id handled by Repository)
//   ✅ Default fallbacks for missing data
//   ✅ Clean debug logging
//
// 🧠 Notes:
//   - household_id לא חלק מהמודל (Repository מוסיף אותו)
//   - Repository מסנן לפי household_id בטעינה
//   - כל שדות ה-JSON עם @JsonKey(defaultValue) כדי למנוע null values

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'inventory_item.g.dart';

@immutable
@JsonSerializable()
class InventoryItem {
  /// מזהה ייחודי (UUID)
  final String id;

  /// שם המוצר (e.g., "חלב 3%")
  @JsonKey(defaultValue: 'מוצר לא ידוע')
  final String productName;

  /// קטגוריה (e.g., "מוצרי חלב", "ירקות")
  @JsonKey(defaultValue: 'כללי')
  final String category;

  /// מיקום אחסון (e.g., "מקרר", "מקפיא", "ארון")
  @JsonKey(defaultValue: 'כללי')
  final String location;

  /// כמות זמינה
  @JsonKey(defaultValue: 0)
  final int quantity;

  /// יחידת מידה (e.g., "יח'", "ק"ג", "ליטר")
  @JsonKey(defaultValue: 'יח\'')
  final String unit;

  const InventoryItem({
    required this.id,
    required this.productName,
    required this.category,
    required this.location,
    required this.quantity,
    required this.unit,
  });

  // =========================================================
  // ✅ JSON Serialization / Deserialization
  // =========================================================

  /// יצירה מ-JSON (deserialize)
  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      debugPrint(
        '📥 InventoryItem.fromJson: id=${json['id']}, '
        'product=${json['productName']}, qty=${json['quantity']}',
      );
    }
    return _$InventoryItemFromJson(json);
  }

  /// המרה ל-JSON (serialize)
  Map<String, dynamic> toJson() {
    if (kDebugMode) {
      debugPrint(
        '📤 InventoryItem.toJson: id=$id, '
        'product=$productName, qty=$quantity',
      );
    }
    return _$InventoryItemToJson(this);
  }

  // =========================================================
  // 🧩 copyWith (id protected)
  // =========================================================

  /// יצירת עותק חדש עם עדכונים (id נשאר קבוע)
  InventoryItem copyWith({String? productName, String? category, String? location, int? quantity, String? unit}) {
    return InventoryItem(
      id: id,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      location: location ?? this.location,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  // =========================================================
  // 🧾 Debug / Equality
  // =========================================================

  @override
  String toString() => 'InventoryItem(id: $id, name: $productName, qty: $quantity $unit, location: $location)';

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
  int get hashCode => Object.hash(id, productName, category, location, quantity, unit);
}
