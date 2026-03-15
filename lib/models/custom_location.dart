// 📄 File: lib/models/custom_location.dart
//
// מודל למיקום אחסון מותאם אישית:
// - מייצג מיקום שהמשתמש הוסיף בעצמו (מעבר למיקומי ברירת המחדל).
// - כולל מזהה ייחודי (key), שם בעברית, ואמוג'י.
// - נתמך ע"י JSON לצורך שמירה מקומית.
//
// 📋 Features:
// - יצירת Key אוטומטית (Smart Factory)
// - תמיכה בצבעי מותג (AppBrand Integration)
// - ולידציה קפדנית
//
// 🔗 Related:
// - LocationsProvider (providers/locations_provider.dart)
// - LocationsRepository (repositories/locations_repository.dart)
// - StorageLocationManager (widgets/inventory/storage_location_manager.dart)
//
// 📝 Version: 4.0
// 📅 Updated: 22/02/2026

import 'dart:ui';

import 'package:flutter/foundation.dart' show immutable;
import 'package:json_annotation/json_annotation.dart';

import '../core/ui_constants.dart';

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
/// כולל מזהה ייחודי (key), שם בעברית, אמוג'י, וצבע מזהה אוטומטי.
///
/// **דוגמה:**
/// ```dart
/// // יצירה רגילה
/// final loc = CustomLocation(key: 'wine_fridge', name: 'מקרר יינות', emoji: '🍷');
///
/// // יצירה אוטומטית מ-שם
/// final loc2 = CustomLocation.fromName('Garden Shed', emoji: '🌿');
/// // key => 'garden_shed'
///
/// // צבע מזהה עקבי
/// loc.color; // => Color (מתוך פלטת Sticky Notes)
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
  @JsonKey(readValue: _readEmoji, defaultValue: '')
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

  /// יצירה אוטומטית מ-שם — ה-key נוצר באמצעות [normalizeKey]
  ///
  /// ```dart
  /// final loc = CustomLocation.fromName('מדף תבלינים', emoji: '🧂');
  /// // key => 'mdf_tvlynym' (normalized)
  /// ```
  factory CustomLocation.fromName(
    String name, {
    String? emoji,
    String? createdBy,
  }) {
    return CustomLocation(
      key: normalizeKey(name),
      name: name.trim(),
      emoji: emoji ?? '📍',
      createdBy: createdBy,
    );
  }

  /// יצירה מ-JSON
  factory CustomLocation.fromJson(Map<String, dynamic> json) =>
      _$CustomLocationFromJson(json);

  /// המרה ל-JSON
  Map<String, dynamic> toJson() => _$CustomLocationToJson(this);

  // ---- Visual Properties ----

  /// פלטת צבעים למיקומים (מתוך Sticky Notes)
  static const _colorPalette = [
    kStickyYellow,
    kStickyPink,
    kStickyGreen,
    kStickyCyan,
    kStickyPurple,
    kStickyOrange,
  ];

  /// צבע מזהה עקבי — נגזר מ-hashCode של ה-key
  ///
  /// מחזיר צבע קבוע מתוך פלטת Sticky Notes,
  /// כך שלכל מיקום יש "צבע מזהה" אוטומטי ועקבי.
  Color get color => _colorPalette[key.hashCode.abs() % _colorPalette.length];

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
  /// - "מדף תבלינים" → "custom_location" (fallback for Hebrew-only)
  static String normalizeKey(String input) {
    final normalized = input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_') // spaces → underscores
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_') // non-latin → underscores
        .replaceAll(RegExp(r'_+'), '_') // collapse multiple underscores
        .replaceAll(RegExp(r'^_|_$'), ''); // trim leading/trailing underscores

    // Fallback: אם ה-input היה רק תווים לא-לטיניים, תן key ברירת מחדל
    return normalized.isEmpty ? 'custom_location' : normalized;
  }

  /// האם ה-key תקין (לא ריק ובפורמט נורמלי)
  bool get isValidKey => key.isNotEmpty && key == normalizeKey(key);

  /// האם emoji תקין (לא ריק)
  bool get hasValidEmoji => emoji.isNotEmpty;

  /// יצירת עותק עם שינויים
  CustomLocation copyWith({
    String? key,
    String? name,
    String? emoji,
    String? createdBy,
  }) {
    return CustomLocation(
      key: key ?? this.key,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      createdBy: createdBy ?? this.createdBy,
    );
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
