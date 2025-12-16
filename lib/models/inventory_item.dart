// 📄 File: lib/models/inventory_item.dart
// Version: 3.0
// Last Updated: 16/12/2025
//
// ✅ Improvements in v3.0:
// - Added expiryDate field for expiration tracking
// - Added notes field for item notes
// - Added isRecurring field for recurring items (auto-add to new lists)
// - Added lastPurchased field for purchase history
// - Added purchaseCount field for purchase statistics
// - Added emoji field for custom item emoji
//
// ✅ Improvements in v2.3:
// - Added minQuantity field for low stock threshold per item
// - Fixed product_name snake_case for Firestore index compatibility
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
//   ✅ Expiry date tracking
//   ✅ Purchase history & statistics
//   ✅ Recurring items support
//
// 🧠 Notes:
//   - household_id לא חלק מהמודל (Repository מוסיף אותו)
//   - Repository מסנן לפי household_id בטעינה
//   - כל שדות ה-JSON עם @JsonKey(defaultValue) כדי למנוע null values

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'timestamp_converter.dart';

part 'inventory_item.g.dart';

@immutable
@JsonSerializable()
class InventoryItem {
  /// מזהה ייחודי (UUID)
  final String id;

  /// שם המוצר (e.g., "חלב 3%")
  @JsonKey(name: 'product_name', defaultValue: 'מוצר לא ידוע')
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

  /// כמות מינימלית - מתחת לסף הזה יוצג כ"מלאי נמוך"
  /// ברירת מחדל: 2
  @JsonKey(name: 'min_quantity', defaultValue: 2)
  final int minQuantity;

  /// תאריך תפוגה (אופציונלי)
  @JsonKey(name: 'expiry_date')
  @NullableTimestampConverter()
  final DateTime? expiryDate;

  /// הערות לפריט (אופציונלי)
  final String? notes;

  /// האם מוצר קבוע (מתווסף אוטומטית לרשימות חדשות)
  @JsonKey(name: 'is_recurring', defaultValue: false)
  final bool isRecurring;

  /// תאריך קנייה אחרון
  @JsonKey(name: 'last_purchased')
  @NullableTimestampConverter()
  final DateTime? lastPurchased;

  /// מספר פעמים שנקנה
  @JsonKey(name: 'purchase_count', defaultValue: 0)
  final int purchaseCount;

  /// אמוג'י מותאם (אופציונלי)
  final String? emoji;

  const InventoryItem({
    required this.id,
    required this.productName,
    required this.category,
    required this.location,
    required this.quantity,
    required this.unit,
    this.minQuantity = 2,
    this.expiryDate,
    this.notes,
    this.isRecurring = false,
    this.lastPurchased,
    this.purchaseCount = 0,
    this.emoji,
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
  InventoryItem copyWith({
    String? productName,
    String? category,
    String? location,
    int? quantity,
    String? unit,
    int? minQuantity,
    DateTime? expiryDate,
    bool clearExpiryDate = false,
    String? notes,
    bool clearNotes = false,
    bool? isRecurring,
    DateTime? lastPurchased,
    bool clearLastPurchased = false,
    int? purchaseCount,
    String? emoji,
    bool clearEmoji = false,
  }) {
    return InventoryItem(
      id: id,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      location: location ?? this.location,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      minQuantity: minQuantity ?? this.minQuantity,
      expiryDate: clearExpiryDate ? null : (expiryDate ?? this.expiryDate),
      notes: clearNotes ? null : (notes ?? this.notes),
      isRecurring: isRecurring ?? this.isRecurring,
      lastPurchased: clearLastPurchased ? null : (lastPurchased ?? this.lastPurchased),
      purchaseCount: purchaseCount ?? this.purchaseCount,
      emoji: clearEmoji ? null : (emoji ?? this.emoji),
    );
  }

  /// האם הפריט במלאי נמוך (מתחת למינימום שהוגדר)
  bool get isLowStock => quantity <= minQuantity;

  /// האם יש תאריך תפוגה
  bool get hasExpiryDate => expiryDate != null;

  /// האם פג תוקף
  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());

  /// האם תפוגה קרובה (תוך 7 ימים)
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry >= 0 && daysUntilExpiry <= 7;
  }

  /// ימים עד תפוגה (או מאז תפוגה אם שלילי)
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  /// האם נקנה לאחרונה (תוך 30 יום)
  bool get wasRecentlyPurchased {
    if (lastPurchased == null) return false;
    return DateTime.now().difference(lastPurchased!).inDays <= 30;
  }

  /// האם מוצר פופולרי (נקנה 4+ פעמים)
  bool get isPopular => purchaseCount >= 4;

  // =========================================================
  // 🧾 Debug / Equality
  // =========================================================

  @override
  String toString() => 'InventoryItem(id: $id, name: $productName, qty: $quantity $unit, min: $minQuantity, location: $location, expiry: $expiryDate, recurring: $isRecurring)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryItem &&
          other.id == id &&
          other.productName == productName &&
          other.category == category &&
          other.location == location &&
          other.quantity == quantity &&
          other.unit == unit &&
          other.minQuantity == minQuantity &&
          other.expiryDate == expiryDate &&
          other.notes == notes &&
          other.isRecurring == isRecurring &&
          other.lastPurchased == lastPurchased &&
          other.purchaseCount == purchaseCount &&
          other.emoji == emoji;

  @override
  int get hashCode => Object.hash(
        id,
        productName,
        category,
        location,
        quantity,
        unit,
        minQuantity,
        expiryDate,
        notes,
        isRecurring,
        lastPurchased,
        purchaseCount,
        emoji,
      );
}
