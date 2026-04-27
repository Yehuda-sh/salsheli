// lib/models/custom_location.dart — Custom location model — user-defined pantry storage locations

import 'package:flutter/foundation.dart' show immutable;
import 'package:json_annotation/json_annotation.dart';

part 'custom_location.g.dart';

// ---- JSON Read Helpers ----

/// קורא emoji עם fallback לברירת מחדל אם null או ריק
Object? _readEmoji(Map<dynamic, dynamic> json, String key) {
  final value = json['emoji'];
  if (value == null || (value is String && value.isEmpty)) {
    return null; // יחזיר את ברירת המחדל מה-constructor
  }
  return value;
}

/// מודל למיקום אחסון מותאם אישית
///
/// כולל מזהה ייחודי (key), שם בעברית, ואמוג'י.
///
/// **דוגמה:**
/// ```dart
/// // יצירה רגילה
/// final loc = CustomLocation(key: 'wine_fridge', name: 'מקרר יינות', emoji: '🍷');
/// ```
@JsonSerializable()
@immutable
class CustomLocation {
  /// מזהה ייחודי (באנגלית, lowercase, עם underscores)
  @JsonKey(defaultValue: '')
  final String key;

  /// שם המיקום בעברית
  @JsonKey(defaultValue: '')
  final String name;

  /// אמוג'י לתצוגה
  /// readValue: מחזיר null אם ריק → משתמש בברירת מחדל מה-constructor
  @JsonKey(readValue: _readEmoji, defaultValue: '📍')
  final String emoji;

  /// מזהה המשתמש שיצר את המיקום (לסנכרון משק בית)
  @JsonKey(includeIfNull: false)
  final String? createdBy;

  const CustomLocation({
    required this.key,
    required this.name,
    this.emoji = '📍',
    this.createdBy,
  });

  /// יצירה מ-JSON
  factory CustomLocation.fromJson(Map<String, dynamic> json) =>
      _$CustomLocationFromJson(json);

  /// המרה ל-JSON
  Map<String, dynamic> toJson() => _$CustomLocationToJson(this);

  // ---- Validation Helpers ----

  /// מנרמל key לפורמט תקין (lowercase, underscores)
  ///
  /// Rules:
  /// - Lowercase letters, numbers, underscores only
  /// - תווים עבריים ותווים מיוחדים מומרים ל-underscores
  /// - No leading/trailing underscores
  /// - No consecutive underscores
  ///
  /// Examples:
  /// - "My Location" → "my_location"
  /// - "  _test_  " → "test"
  /// - "a__b" → "a_b"
  /// - "מדף תבלינים" → `custom_{hash}` (fallback for Hebrew-only)
  static String normalizeKey(String input) {
    final normalized = input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_') // spaces → underscores
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_') // non-latin → underscores
        .replaceAll(RegExp(r'_+'), '_') // collapse multiple underscores
        .replaceAll(RegExp(r'^_|_$'), ''); // trim leading/trailing underscores

    // Fallback: אם ה-input היה רק תווים לא-לטיניים, תן key ייחודי מבוסס hash
    if (normalized.isEmpty) {
      final hash = input.trim().hashCode.abs().toRadixString(36);
      return 'custom_$hash';
    }
    return normalized;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomLocation && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() =>
      'CustomLocation(key: $key, name: $name, emoji: $emoji, createdBy: $createdBy)';
}
