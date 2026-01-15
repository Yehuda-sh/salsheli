// 📄 File: lib/models/product_location_memory.dart
//
// 🎯 מטרה: זיכרון מיקומי אחסון למוצרים
// המערכת זוכרת איפה כל מוצר אמור להיות ולומדת הרגלים
//
// 📋 Features:
// - זיכרון מיקום ברירת מחדל למוצר
// - זיהוי יציב לפי barcode (עדיף) או שם מנורמל
// - defaultLocation = המיקום האחרון שנבחר (משתנה מיד)
// - isConfident = true רק אחרי 3 פעמים ברצף באותו מיקום
// - נרמול מיקומים (trim, רווחים כפולים)
//
// Version: 1.3 - Added barcode empty→null, defaultLocation normalization
// Last Updated: 13/01/2026

import 'package:flutter/foundation.dart' show immutable;
import 'package:json_annotation/json_annotation.dart';

import 'timestamp_converter.dart' show FlexibleDateTimeConverter;

part 'product_location_memory.g.dart';

// ---- JSON Read Helpers ----

/// 🔧 קורא barcode עם fallback ל-null אם ריק
/// מונע התנגשויות: barcode="" → null → יזוהה לפי שם מנורמל
Object? _readBarcode(Map<dynamic, dynamic> json, String key) {
  final value = json['barcode'];
  if (value == null || (value is String && value.isEmpty)) {
    return null;
  }
  return value;
}

/// 🔧 מספר הפעמים שצריך לשים מוצר באותו מקום כדי שיהפוך ל-default
const int kConfidenceThreshold = 3;

@immutable
@JsonSerializable(fieldRename: FieldRename.snake)
class ProductLocationMemory {
  /// שם המוצר (לתצוגה)
  final String productName;

  /// 🔧 ברקוד - מזהה יציב (עדיף על שם)
  /// אם יש barcode, הוא משמש לזיהוי. אחרת, משתמשים ב-normalizedKey.
  /// 🔄 readValue: ממיר "" ל-null למניעת התנגשויות
  @JsonKey(readValue: _readBarcode)
  final String? barcode;

  /// מיקום ברירת מחדל (מנורמל)
  final String defaultLocation;

  final String? category;

  /// כמה פעמים המוצר הונח במיקום הזה
  final int usageCount;

  /// 🔧 כמה פעמים ברצף אותו מיקום (לבניית confidence)
  /// כשמגיע ל-kConfidenceThreshold - המיקום הופך ל-"ודאי"
  final int consecutiveCount;

  @FlexibleDateTimeConverter()
  final DateTime lastUpdated;

  final String? householdId;

  /// 🔒 Private constructor - משתמש ב-factory ProductLocationMemory() לאכיפת נרמול
  const ProductLocationMemory._({
    required this.productName,
    this.barcode,
    required this.defaultLocation,
    this.category,
    this.usageCount = 1,
    this.consecutiveCount = 1,
    required this.lastUpdated,
    this.householdId,
  });

  /// 🔧 Factory constructor - מנרמל defaultLocation אוטומטית
  factory ProductLocationMemory({
    required String productName,
    String? barcode,
    required String defaultLocation,
    String? category,
    int usageCount = 1,
    int consecutiveCount = 1,
    required DateTime lastUpdated,
    String? householdId,
  }) {
    return ProductLocationMemory._(
      productName: productName,
      barcode: barcode,
      defaultLocation: normalizeLocation(defaultLocation),
      category: category,
      usageCount: usageCount,
      consecutiveCount: consecutiveCount,
      lastUpdated: lastUpdated,
      householdId: householdId,
    );
  }

  /// 🔧 מפתח ייחודי לזיהוי: barcode (אם קיים) או שם מנורמל
  String get uniqueKey => barcode ?? normalizedProductName;

  /// 🔧 שם מנורמל להשוואה (lowercase, ללא רווחים כפולים, trim)
  String get normalizedProductName =>
      productName.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

  /// 🔧 האם ה-confidence מספיק גבוה (3+ פעמים ברצף)
  bool get isConfident => consecutiveCount >= kConfidenceThreshold;

  /// 🔧 נרמול מיקום (static helper)
  ///
  /// "  המזווה  " → "המזווה"
  /// "ארון   מזווה" → "ארון מזווה"
  static String normalizeLocation(String location) {
    return location.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// 🔧 עדכון עם מיקום חדש - מחזיר instance מעודכן
  ///
  /// אם אותו מיקום: מגדיל consecutiveCount
  /// אם מיקום שונה: מאפס consecutiveCount ל-1
  ProductLocationMemory updateWithLocation(String newLocation) {
    final normalizedNew = normalizeLocation(newLocation);
    final normalizedCurrent = normalizeLocation(defaultLocation);

    if (normalizedNew == normalizedCurrent) {
      // אותו מיקום - מגדיל confidence
      return copyWith(
        usageCount: usageCount + 1,
        consecutiveCount: consecutiveCount + 1,
        lastUpdated: DateTime.now(),
      );
    } else {
      // מיקום שונה - מאפס consecutive, מחליף default
      return copyWith(
        defaultLocation: normalizedNew,
        usageCount: usageCount + 1,
        consecutiveCount: 1,
        lastUpdated: DateTime.now(),
      );
    }
  }

  factory ProductLocationMemory.fromJson(Map<String, dynamic> json) =>
      _$ProductLocationMemoryFromJson(json);

  Map<String, dynamic> toJson() => _$ProductLocationMemoryToJson(this);

  ProductLocationMemory copyWith({
    String? productName,
    String? barcode,
    String? defaultLocation,
    String? category,
    int? usageCount,
    int? consecutiveCount,
    DateTime? lastUpdated,
    String? householdId,
  }) {
    return ProductLocationMemory(
      productName: productName ?? this.productName,
      barcode: barcode ?? this.barcode,
      defaultLocation: defaultLocation ?? this.defaultLocation,
      category: category ?? this.category,
      usageCount: usageCount ?? this.usageCount,
      consecutiveCount: consecutiveCount ?? this.consecutiveCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      householdId: householdId ?? this.householdId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductLocationMemory && other.uniqueKey == uniqueKey;
  }

  @override
  int get hashCode => uniqueKey.hashCode;

  @override
  String toString() =>
      'ProductLocationMemory(name: $productName, location: $defaultLocation, confidence: $consecutiveCount/$kConfidenceThreshold)';
}