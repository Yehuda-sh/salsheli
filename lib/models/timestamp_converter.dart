// 📄 File: lib/models/timestamp_converter.dart
//
// 🇮🇱 Converter להמרת Timestamp של Firebase ל-DateTime ולהפך
// 🇬🇧 Converter for Firebase Timestamp to DateTime and back
//
// 📝 Version: 1.0
// 📅 Created: 07/10/2025

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converter להמרה אוטומטית בין Timestamp של Firebase ל-DateTime
/// 
/// שימוש:
/// ```dart
/// @TimestampConverter()
/// final DateTime myDate;
/// ```
class TimestampConverter implements JsonConverter<DateTime, Object> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is Timestamp) {
      return json.toDate();
    } else if (json is String) {
      return DateTime.parse(json);
    } else if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    }
    throw ArgumentError('Cannot convert $json to DateTime');
  }

  @override
  Object toJson(DateTime date) {
    // ממיר ל-Timestamp של Firebase
    return Timestamp.fromDate(date);
  }
}
