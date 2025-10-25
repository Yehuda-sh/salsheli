// 📄 File: lib/models/smart_suggestion.dart
//
// 🇮🇱 המלצה חכמה מתקדמת:
//     - מבוססת על ניתוח מלאי במזווה
//     - תומכת בדחייה זמנית (יום/שבוע/חודש/לעולם)
//     - מעקב אחרי סטטוס (ממתין/נוסף/נדחה/נמחק)
//     - מציגה מלאי נוכחי מול סף מינימום
//
// 💡 תרחיש שימוש:
//     1. המערכת בודקת: חלב במזווה = 2, סף = 5
//     2. יוצרת המלצה: "חלב - נשארו רק 2 יחידות"
//     3. משתמש בוחר:
//        - הוסף → מתווסף לרשימה הבאה
//        - דחה → לא יציע השבוע (dismissedUntil = +7 days)
//        - מחק → לא יציע יותר (status = deleted)
//
// 🇬🇧 Advanced smart suggestion:
//     - Based on pantry inventory analysis
//     - Supports temporary dismissal (day/week/month/forever)
//     - Tracks status (pending/added/dismissed/deleted)
//     - Shows current stock vs minimum threshold

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'enums/suggestion_status.dart';
import 'timestamp_converter.dart';
import 'unified_list_item.dart';
import 'enums/item_type.dart';

part 'smart_suggestion.g.dart';

/// 🇮🇱 המלצה חכמה מתקדמת
/// 🇬🇧 Advanced smart suggestion
@immutable
@JsonSerializable(explicitToJson: true)
class SmartSuggestion {
  /// 🇮🇱 מזהה ייחודי להמלצה
  /// 🇬🇧 Unique suggestion identifier
  final String id;

  /// 🇮🇱 מזהה המוצר במזווה (InventoryItem.id)
  /// 🇬🇧 Product ID in inventory (InventoryItem.id)
  @JsonKey(name: 'product_id')
  final String productId;

  /// 🇮🇱 שם המוצר
  /// 🇬🇧 Product name
  @JsonKey(name: 'product_name')
  final String productName;

  /// 🇮🇱 קטגוריה
  /// 🇬🇧 Category
  @JsonKey(defaultValue: 'כללי')
  final String category;

  /// 🇮🇱 מלאי נוכחי במזווה
  /// 🇬🇧 Current stock in pantry
  @JsonKey(name: 'current_stock', defaultValue: 0)
  final int currentStock;

  /// 🇮🇱 סף מינימום (threshold)
  /// 🇬🇧 Minimum threshold
  @JsonKey(defaultValue: 5)
  final int threshold;

  /// 🇮🇱 כמה חסר עד הסף
  /// 🇬🇧 How much is missing to reach threshold
  @JsonKey(name: 'quantity_needed', defaultValue: 1)
  final int quantityNeeded;

  /// 🇮🇱 יחידת מידה
  /// 🇬🇧 Unit of measurement
  @JsonKey(defaultValue: 'יח\'')
  final String unit;

  /// 🇮🇱 סטטוס ההמלצה
  /// 🇬🇧 Suggestion status
  @JsonKey(defaultValue: SuggestionStatus.pending)
  final SuggestionStatus status;

  /// 🇮🇱 תאריך יצירת ההמלצה
  /// 🇬🇧 Suggestion creation date
  @TimestampConverter()
  @JsonKey(name: 'suggested_at')
  final DateTime suggestedAt;

  /// 🇮🇱 עד מתי נדחתה ההמלצה (null אם לא נדחתה)
  /// 🇬🇧 Until when the suggestion is dismissed (null if not dismissed)
  @TimestampConverter()
  @JsonKey(name: 'dismissed_until')
  final DateTime? dismissedUntil;

  /// 🇮🇱 מתי נוספה לרשימה (null אם לא נוספה)
  /// 🇬🇧 When it was added to a list (null if not added)
  @TimestampConverter()
  @JsonKey(name: 'added_at')
  final DateTime? addedAt;

  /// 🇮🇱 למי הרשימה שהמלצה נוספה אליה (null אם לא נוספה)
  /// 🇬🇧 Which list the suggestion was added to (null if not added)
  @JsonKey(name: 'added_to_list_id')
  final String? addedToListId;

  const SmartSuggestion({
    required this.id,
    required this.productId,
    required this.productName,
    required this.category,
    required this.currentStock,
    required this.threshold,
    required this.quantityNeeded,
    required this.unit,
    required this.status,
    required this.suggestedAt,
    this.dismissedUntil,
    this.addedAt,
    this.addedToListId,
  });

  // ---- Factory Constructors ----

  /// 🇮🇱 יצירת המלצה חדשה מניתוח מזווה
  /// 🇬🇧 Create a new suggestion from pantry analysis
  factory SmartSuggestion.fromInventory({
    required String id,
    required String productId,
    required String productName,
    required String category,
    required int currentStock,
    required int threshold,
    required String unit,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    final needed = (threshold - currentStock).clamp(1, 999);

    return SmartSuggestion(
      id: id,
      productId: productId,
      productName: productName,
      category: category,
      currentStock: currentStock,
      threshold: threshold,
      quantityNeeded: needed,
      unit: unit,
      status: SuggestionStatus.pending,
      suggestedAt: timestamp,
    );
  }

  // ---- Computed Properties ----

  /// 🇮🇱 האם ההמלצה פעילה (pending ולא נדחתה)
  /// 🇬🇧 Is the suggestion active (pending and not dismissed)
  bool get isActive {
    if (status != SuggestionStatus.pending) return false;
    if (dismissedUntil == null) return true;
    return DateTime.now().isAfter(dismissedUntil!);
  }

  /// �י🇱 האם המלאי אזל לגמרי
  /// 🇬🇧 Is the stock completely out
  bool get isOutOfStock => currentStock <= 0;

  /// 🇮🇱 האם המלאי נמוך מאוד (< 20% מהסף)
  /// 🇬🇧 Is the stock critically low (< 20% of threshold)
  bool get isCriticallyLow => currentStock < (threshold * 0.2);

  /// 🇮🇱 האם המלאי נמוך (< 50% מהסף)
  /// 🇬🇧 Is the stock low (< 50% of threshold)
  bool get isLow => currentStock < (threshold * 0.5);

  /// 🇮🇱 רמת דחיפות: "critical" | "high" | "medium" | "low"
  /// 🇬🇧 Urgency level: "critical" | "high" | "medium" | "low"
  String get urgency {
    if (isOutOfStock) return 'critical';
    if (isCriticallyLow) return 'high';
    if (isLow) return 'medium';
    return 'low';
  }

  /// 🇮🇱 אחוז מלאי מהסף (0-100)
  /// 🇬🇧 Stock percentage of threshold (0-100)
  int get stockPercentage {
    if (threshold == 0) return 100;
    return ((currentStock / threshold) * 100).clamp(0, 100).round();
  }

  /// 🇮🇱 טקסט תיאור המלאי
  /// 🇬🇧 Stock description text
  String get stockDescription {
    if (isOutOfStock) {
      return 'נגמר! צריך לקנות';
    } else if (currentStock == 1) {
      return 'נשאר 1 $unit בלבד';
    } else {
      return 'נשארו רק $currentStock $unit';
    }
  }

  // ---- JSON Serialization ----

  /// 🇮🇱 יצירה מ-JSON
  /// 🇬🇧 Create from JSON
  factory SmartSuggestion.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      debugPrint('📥 SmartSuggestion.fromJson:');
      debugPrint('   id: ${json['id']}');
      debugPrint('   product: ${json['product_name']}');
      debugPrint('   status: ${json['status']}');
    }
    return _$SmartSuggestionFromJson(json);
  }

  /// 🇮🇱 המרה ל-JSON
  /// 🇬🇧 Convert to JSON
  Map<String, dynamic> toJson() {
    if (kDebugMode) {
      debugPrint('📤 SmartSuggestion.toJson:');
      debugPrint('   id: $id');
      debugPrint('   product: $productName');
      debugPrint('   status: ${status.value}');
    }
    return _$SmartSuggestionToJson(this);
  }

  // ---- Copy & Update ----

  /// 🇮🇱 יצירת עותק עם שינויים
  /// 🇬🇧 Create a copy with updates
  SmartSuggestion copyWith({
    String? id,
    String? productId,
    String? productName,
    String? category,
    int? currentStock,
    int? threshold,
    int? quantityNeeded,
    String? unit,
    SuggestionStatus? status,
    DateTime? suggestedAt,
    DateTime? dismissedUntil,
    DateTime? addedAt,
    String? addedToListId,
  }) {
    return SmartSuggestion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      currentStock: currentStock ?? this.currentStock,
      threshold: threshold ?? this.threshold,
      quantityNeeded: quantityNeeded ?? this.quantityNeeded,
      unit: unit ?? this.unit,
      status: status ?? this.status,
      suggestedAt: suggestedAt ?? this.suggestedAt,
      dismissedUntil: dismissedUntil ?? this.dismissedUntil,
      addedAt: addedAt ?? this.addedAt,
      addedToListId: addedToListId ?? this.addedToListId,
    );
  }

  /// 🇮🇱 המרה ל-UnifiedListItem (למוצר)
  /// 🇬🇧 Convert to UnifiedListItem (as product)
  UnifiedListItem toUnifiedListItem() {
    return UnifiedListItem.product(
      id: productId,
      name: productName,
      quantity: quantityNeeded,
      unitPrice: 0.0, // לא ידוע
      unit: unit,
      category: category,
    );
  }

  @override
  String toString() {
    return 'SmartSuggestion(id: $id, product: $productName, '
        'stock: $currentStock/$threshold, status: ${status.value})';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmartSuggestion &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
