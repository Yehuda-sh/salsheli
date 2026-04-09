// 📄 File: lib/models/timestamp_converter.dart
//
// 🇮🇱 ממירים מרכזיים ל-JSON:
//     - DateTime ↔️ Timestamp/String/int
//     - double גמיש (num/string עם פסיק)
//
// 🇬🇧 Central JSON converters:
//     - DateTime ↔️ Timestamp/String/int
//     - Flexible double (num/string with comma)
//
// 🔧 Supports: Timestamp, String, int (epoch), DateTime, num with comma
//
// 📋 Converter Types:
//     - Strict (Timestamp/NullableTimestamp): זורק על טיפוס לא תקין
//     - Lenient (Flexible...): מחזיר fallback + אזהרה בדיבאג
//
// Version: 1.3 - FlexibleDateTimeConverter fallback: DateTime.now() → epoch sentinel
// Last Updated: 24/03/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

/// 🎯 ממיר לשדות DateTime לא nullable
class TimestampConverter implements JsonConverter<DateTime, Object> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    if (json is DateTime) return json;
    throw ArgumentError('Cannot convert value to DateTime: $json (${json.runtimeType})');
  }

  @override
  Object toJson(DateTime date) => Timestamp.fromDate(date);
}

/// 🎯 ממיר לשדות DateTime? nullable
class NullableTimestampConverter implements JsonConverter<DateTime?, Object?> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.tryParse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    if (json is DateTime) return json;
    throw ArgumentError('Cannot convert value to DateTime?: $json (${json.runtimeType})');
  }

  @override
  Object? toJson(DateTime? date) => date == null ? null : Timestamp.fromDate(date);
}

// ---- Flexible Converters (lenient - for data from various sources) ----
// 🔧 Lenient: לא זורקים על טיפוס לא תקין - מחזירים fallback
// שימושי לנתונים מ-FCM, גרסאות ישנות, או מקורות חיצוניים

/// 🎯 ממיר גמיש לשדות DateTime (lenient - לא זורק!)
/// 🇬🇧 Flexible DateTime converter (lenient - doesn't throw!)
///
/// תומך ב: Timestamp, String, int (epoch), DateTime
/// ⚠️ אם הטיפוס לא מוכר או null → מחזיר epoch (1970-01-01) כ-sentinel
class FlexibleDateTimeConverter implements JsonConverter<DateTime, dynamic> {
  const FlexibleDateTimeConverter();

  /// Sentinel value for missing/invalid dates — epoch makes bad data obvious
  /// in UI (sorted to bottom) without crashing.
  static final DateTime _fallback = DateTime.utc(1970);

  @override
  DateTime fromJson(dynamic json) {
    if (json == null) {
      debugPrint('[FlexibleDateTimeConverter] null value → fallback to epoch');
      return _fallback;
    }
    if (json is Timestamp) return json.toDate();
    if (json is String) {
      final parsed = DateTime.tryParse(json);
      if (parsed != null) return parsed;
      debugPrint('[FlexibleDateTimeConverter] unparseable string "$json" → fallback to epoch');
      return _fallback;
    }
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    if (json is DateTime) return json;
    // טיפוס לא מוכר - fallback
    debugPrint('[FlexibleDateTimeConverter] unknown type ${json.runtimeType} → fallback to epoch');
    return _fallback;
  }

  @override
  Object toJson(DateTime date) => Timestamp.fromDate(date);
}

/// 🎯 ממיר גמיש לשדות DateTime? nullable (lenient - לא זורק!)
/// 🇬🇧 Flexible nullable DateTime converter (lenient - doesn't throw!)
///
/// תומך ב: Timestamp, String, int (epoch), DateTime, null
/// ⚠️ אם הטיפוס לא מוכר → מחזיר null
class NullableFlexibleDateTimeConverter implements JsonConverter<DateTime?, dynamic> {
  const NullableFlexibleDateTimeConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) {
      final parsed = DateTime.tryParse(json);
      return parsed;
    }
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    if (json is DateTime) return json;
    // טיפוס לא מוכר - null
    return null;
  }

  @override
  Object? toJson(DateTime? date) => date == null ? null : Timestamp.fromDate(date);
}

// ---- Numeric Converters ----

/// 🎯 ממיר double גמיש (מספרים/מחרוזות עם פסיק)
/// 🇬🇧 Flexible double converter (num/string with comma support)
///
/// תומך ב:
/// - num (int/double) → toDouble()
/// - String עם פסיק ("3,50" → 3.5)
/// - null → 0.0
class FlexDoubleConverter implements JsonConverter<double, Object?> {
  const FlexDoubleConverter();

  @override
  double fromJson(Object? json) {
    if (json == null) return 0.0;
    if (json is num) return json.toDouble();
    if (json is String) {
      final cleaned = json.replaceAll(',', '.');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Object toJson(double object) => object;
}
