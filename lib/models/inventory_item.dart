// 📄 File: lib/models/inventory_item.dart
// Version: 2.0
// Last Updated: 06/10/2025
//
// Purpose:
//   מודל InventoryItem מייצג פריט במלאי/מזווה של משק הבית.
//   תומך בסנכרון עם Firebase Firestore ב-JSON format.
//
// Features:
//   ✅ JSON serialization (json_annotation)
//   ✅ Immutable model (@immutable)
//   ✅ copyWith for updates
//   ✅ Equality & hashCode
//   ✅ Firebase-ready (household_id handled by Repository)
//   ✅ Compact debug logging
//
// Usage:
//   ```dart
//   // יצירה
//   final item = InventoryItem(
//     id: uuid.v4(),
//     productName: 'חלב 3%',
//     category: 'מוצרי חלב',
//     location: 'מקרר',
//     quantity: 2,
//     unit: 'ליטר',
//   );
//
//   // JSON
//   final json = item.toJson();
//   final fromJson = InventoryItem.fromJson(json);
//
//   // עדכון
//   final updated = item.copyWith(quantity: 1);
//   ```
//
// Dependencies:
//   - json_annotation: JSON serialization
//   - firebase_inventory_repository: household_id management
//
// Notes:
//   - household_id לא חלק מהמודל (Repository מנהל אותו)
//   - Repository מוסיף household_id בשמירה ל-Firestore
//   - Repository מסנן לפי household_id בטעינה

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'inventory_item.g.dart';

@immutable
@JsonSerializable()
class InventoryItem {
  /// מזהה ייחודי (UUID)
  final String id;

  /// שם המוצר (e.g., "חלב 3%")
  final String productName;

  /// קטגוריה (e.g., "מוצרי חלב", "ירקות")
  final String category;

  /// מיקום אחסון (e.g., "מקרר", "מקפיא", "ארון")
  final String location;

  /// כמות זמינה
  final int quantity;

  /// יחידת מידה (e.g., "יח'", "ק"ג", "ליטר")
  final String unit;

  const InventoryItem({
    required this.id,
    required this.productName,
    required this.category,
    required this.location,
    required this.quantity,
    required this.unit,
  });

  /// יצירה מ-JSON (deserialize)
  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    debugPrint('📥 InventoryItem.fromJson: id=${json['id']}, product=${json['productName']}, qty=${json['quantity']}');
    return _$InventoryItemFromJson(json);
  }

  /// המרה ל-JSON (serialize)
  Map<String, dynamic> toJson() {
    debugPrint('📤 InventoryItem.toJson: id=$id, product=$productName, qty=$quantity');
    return _$InventoryItemToJson(this);
  }

  /// יצירת עותק חדש עם עדכונים
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
