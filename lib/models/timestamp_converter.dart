// 📄 File: lib/models/timestamp_converter.dart
//
// 🇮🇱 ממירים בין Firebase Timestamp ↔️ DateTime / DateTime?
// 🇬🇧 Converts Firebase Timestamp ↔️ DateTime / DateTime?
//
// 🔧 Supports: Timestamp, String, int (epoch), DateTime

import 'package:cloud_firestore/cloud_firestore.dart';
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
