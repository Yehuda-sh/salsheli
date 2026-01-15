// 📄 File: lib/models/inventory_item.dart
//
// 🇮🇱 מודל פריט במלאי/מזווה:
//     - מייצג פריט במלאי של משק הבית
//     - תומך בתאריך תפוגה, הערות, ומוצרים קבועים
//     - כולל סטטיסטיקות קנייה (purchaseCount, lastPurchased)
//     - household_id לא חלק מהמודל (Repository מוסיף אותו)
//
// 🇬🇧 Inventory/pantry item model:
//     - Represents an item in household inventory
//     - Supports expiry date, notes, and recurring items
//     - Includes purchase statistics (purchaseCount, lastPurchased)
//     - household_id not part of model (Repository handles it)
//
// 🔗 Related:
//     - InventoryRepository (repositories/inventory_repository.dart)
//     - InventoryProvider (providers/inventory_provider.dart)
//     - SmartSuggestion (models/smart_suggestion.dart)
//

import 'package:flutter/foundation.dart' show immutable;
import 'package:json_annotation/json_annotation.dart';

import 'timestamp_converter.dart';

part 'inventory_item.g.dart';

// ---- JSON Read Helpers ----

/// קורא emoji עם fallback ל-null אם ריק
/// 🔄 מטפל ב-"" מהשרת → מחזיר null → UI יציג fallback
Object? _readEmoji(Map<dynamic, dynamic> json, String key) {
  final value = json['emoji'];
  if (value == null || (value is String && value.isEmpty)) {
    return null;
  }
  return value;
}

/// 🇮🇱 מודל פריט במלאי/מזווה
/// 🇬🇧 Inventory/pantry item model
@immutable
@JsonSerializable()
class InventoryItem {
  /// מזהה ייחודי (UUID)
  final String id;

  /// שם המוצר (e.g., "חלב 3%")
  /// 📌 defaultValue ריק - UI יציג תווית מתאימה (AppStrings)
  @JsonKey(name: 'product_name', defaultValue: '')
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
  /// 🔄 readValue: מחזיר null אם ריק → UI יציג fallback
  @JsonKey(readValue: _readEmoji)
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

  // ---- JSON Serialization ----

  /// 🇮🇱 יצירה מ-JSON
  /// 🇬🇧 Create from JSON
  factory InventoryItem.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemFromJson(json);

  /// 🇮🇱 המרה ל-JSON
  /// 🇬🇧 Convert to JSON
  Map<String, dynamic> toJson() => _$InventoryItemToJson(this);

  // ---- Copy With ----

  /// 🇮🇱 יצירת עותק עם שינויים (id נשאר קבוע)
  /// 🇬🇧 Create a copy with updates (id stays immutable)
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

  // ---- Helper Getters ----

  /// 🇮🇱 האם הפריט במלאי נמוך (מתחת למינימום שהוגדר)
  /// 🇬🇧 Is the item low stock (below minimum threshold)
  bool get isLowStock => quantity < minQuantity;

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

  // ---- Equality & Debug ----

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
