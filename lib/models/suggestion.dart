// 📄 File: lib/models/suggestion.dart
//
// 🇮🇱 מודל המלצות חכמות למוצרים:
//     - מייצג המלצה למוצר שכדאי להוסיף לרשימת קניות.
//     - מבוסס על ניתוח מלאי נמוך או היסטוריית קניות.
//     - כולל עדיפות, סיבה, וכמות מומלצת.
//     - נתמך ע"י JSON לצורך סנכרון עם שרת ושמירה מקומית.
//
// 💡 רעיונות עתידיים:
//     - למידת מכונה: חיזוי מוצרים לפי עונה ומועדים.
//     - התראות פרואקטיביות: "חלב עומד להיגמר בעוד יומיים".
//     - המלצות חכמות: "הוספת עגבניות? אולי גם מלפפון?"
//     - אינטגרציה עם מבצעים: "יוגורט במבצע בסופר!"
//     - שיתוף המלצות בין משתמשי משק הבית.
//
// 🇬🇧 Smart product suggestions model:
//     - Represents a product recommendation to add to shopping list.
//     - Based on low inventory analysis or purchase history.
//     - Includes priority, reason, and suggested quantity.
//     - Supports JSON for server sync and local storage.
//
// 💡 Future ideas:
//     - Machine learning: predict products by season and events.
//     - Proactive alerts: "Milk running out in 2 days".
//     - Smart suggestions: "Adding tomatoes? Maybe cucumber too?"
//     - Sales integration: "Yogurt on sale at the supermarket!"
//     - Share suggestions between household members.
//

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'suggestion.g.dart';

/// 🇮🇱 מודל המלצה חכמה למוצר
/// 🇬🇧 Smart product suggestion model
@JsonSerializable()
class Suggestion {
  /// 🇮🇱 מזהה ייחודי להמלצה
  /// 🇬🇧 Unique suggestion identifier
  final String id;

  /// 🇮🇱 שם המוצר
  /// 🇬🇧 Product name
  @JsonKey(name: 'product_name')
  final String productName;

  /// 🇮🇱 סיבת ההמלצה: "running_low" | "frequently_bought" | "both"
  /// 🇬🇧 Suggestion reason: "running_low" | "frequently_bought" | "both"
  @JsonKey(defaultValue: 'frequently_bought')
  final String reason;

  /// 🇮🇱 קטגוריית המוצר
  /// 🇬🇧 Product category
  @JsonKey(defaultValue: 'כללי')
  final String category;

  /// 🇮🇱 כמות מומלצת לקנייה
  /// 🇬🇧 Suggested quantity to buy
  @JsonKey(name: 'suggested_quantity', defaultValue: 1)
  final int suggestedQuantity;

  /// 🇮🇱 יחידת מידה (יחידות, ק"ג, ליטר)
  /// 🇬🇧 Unit of measurement (units, kg, liter)
  @JsonKey(defaultValue: 'יחידות')
  final String unit;

  /// 🇮🇱 רמת עדיפות: "high" | "medium" | "low"
  /// 🇬🇧 Priority level: "high" | "medium" | "low"
  @JsonKey(defaultValue: 'medium')
  final String priority;

  /// 🇮🇱 מקור ההמלצה: "inventory" | "history" | "both"
  /// 🇬🇧 Suggestion source: "inventory" | "history" | "both"
  @JsonKey(defaultValue: 'inventory')
  final String source;

  /// 🇮🇱 תאריך יצירת ההמלצה
  /// 🇬🇧 Suggestion creation date
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const Suggestion({
    required this.id,
    required this.productName,
    required this.reason,
    required this.category,
    required this.suggestedQuantity,
    required this.unit,
    required this.priority,
    required this.source,
    required this.createdAt,
  });

  // ---- JSON Serialization ----

  /// 🇮🇱 יצירה מ-JSON
  /// 🇬🇧 Create from JSON
  factory Suggestion.fromJson(Map<String, dynamic> json) {
    debugPrint('📥 Suggestion.fromJson:');
    debugPrint('   id: ${json['id']}');
    debugPrint('   product_name: ${json['product_name']}');
    debugPrint('   reason: ${json['reason']}');
    debugPrint('   priority: ${json['priority']}');
    return _$SuggestionFromJson(json);
  }

  /// 🇮🇱 המרה ל-JSON
  /// 🇬🇧 Convert to JSON
  Map<String, dynamic> toJson() {
    debugPrint('📤 Suggestion.toJson:');
    debugPrint('   id: $id');
    debugPrint('   product_name: $productName');
    debugPrint('   reason: $reason');
    debugPrint('   priority: $priority');
    return _$SuggestionToJson(this);
  }

  // ---- Copy & Update ----

  /// 🇮🇱 יצירת עותק עם שינויים
  /// 🇬🇧 Create a copy with updates
  Suggestion copyWith({
    String? id,
    String? productName,
    String? reason,
    String? category,
    int? suggestedQuantity,
    String? unit,
    String? priority,
    String? source,
    DateTime? createdAt,
  }) {
    return Suggestion(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      reason: reason ?? this.reason,
      category: category ?? this.category,
      suggestedQuantity: suggestedQuantity ?? this.suggestedQuantity,
      unit: unit ?? this.unit,
      priority: priority ?? this.priority,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ---- Computed Properties ----

  /// 🇮🇱 טקסט תיאור הסיבה בעברית
  /// 🇬🇧 Reason description text in Hebrew
  String get reasonText {
    switch (reason) {
      case 'running_low':
        return 'נגמר במזווה';
      case 'frequently_bought':
        return 'נקנה לעיתים קרובות';
      case 'both':
        return 'נגמר במזווה ונקנה לעיתים קרובות';
      default:
        return 'מומלץ';
    }
  }

  /// 🇮🇱 צבע לפי רמת עדיפות
  /// 🇬🇧 Color by priority level
  int get priorityColor {
    switch (priority) {
      case 'high':
        return 0xFFEF5350; // אדום / Red
      case 'medium':
        return 0xFFFF9800; // כתום / Orange
      case 'low':
        return 0xFF66BB6A; // ירוק / Green
      default:
        return 0xFF9E9E9E; // אפור / Gray
    }
  }

  @override
  String toString() {
    return 'Suggestion(id: $id, productName: $productName, reason: $reason, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Suggestion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
