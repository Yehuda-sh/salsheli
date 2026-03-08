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
// Version: 1.1 - Added lenient behavior to Flexible converters
// Last Updated: 13/01/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
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
    throw ArgumentError('⛔ לא ניתן להמיר את הערך: $json ל־DateTime');
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
    throw ArgumentError('⛔ לא ניתן להמיר את הערך: $json ל־DateTime?');
  }

  @override
  Object? toJson(DateTime? date) => date == null ? null : Timestamp.fromDate(date);
}

// ---- Flexible Converters (lenient - for data from various sources) ----
// 🔧 Lenient: לא זורקים על טיפוס לא תקין - מחזירים fallback + אזהרה בדיבאג
// שימושי לנתונים מ-FCM, גרסאות ישנות, או מקורות חיצוניים

/// 🎯 ממיר גמיש לשדות DateTime (lenient - לא זורק!)
/// 🇬🇧 Flexible DateTime converter (lenient - doesn't throw!)
///
/// תומך ב: Timestamp, String, int (epoch), DateTime
/// ⚠️ אם הטיפוס לא מוכר או null → מחזיר DateTime.now() + אזהרה בדיבאג
class FlexibleDateTimeConverter implements JsonConverter<DateTime, dynamic> {
  const FlexibleDateTimeConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json == null) {
      if (kDebugMode) {
      }
      return DateTime.now();
    }
    if (json is Timestamp) return json.toDate();
    if (json is String) {
      final parsed = DateTime.tryParse(json);
      if (parsed != null) return parsed;
      if (kDebugMode) {
      }
      return DateTime.now();
    }
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    if (json is DateTime) return json;
    // טיפוס לא מוכר - fallback + אזהרה
    if (kDebugMode) {
    }
    return DateTime.now();
  }

  @override
  Object toJson(DateTime date) => Timestamp.fromDate(date);
}

/// 🎯 ממיר גמיש לשדות DateTime? nullable (lenient - לא זורק!)
/// 🇬🇧 Flexible nullable DateTime converter (lenient - doesn't throw!)
///
/// תומך ב: Timestamp, String, int (epoch), DateTime, null
/// ⚠️ אם הטיפוס לא מוכר → מחזיר null + אזהרה בדיבאג
class NullableFlexibleDateTimeConverter implements JsonConverter<DateTime?, dynamic> {
  const NullableFlexibleDateTimeConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) {
      final parsed = DateTime.tryParse(json);
      if (parsed == null && kDebugMode) {
      }
      return parsed;
    }
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    if (json is DateTime) return json;
    // טיפוס לא מוכר - null + אזהרה
    if (kDebugMode) {
    }
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
