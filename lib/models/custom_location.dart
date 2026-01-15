// 📄 File: lib/models/custom_location.dart
//
// 🇮🇱 מודל למיקום אחסון מותאם אישית:
//     - מייצג מיקום שהמשתמש הוסיף בעצמו (מעבר למיקומי ברירת המחדל).
//     - כולל מזהה ייחודי (key), שם בעברית, ואמוג'י.
//     - נתמך ע"י JSON לצורך שמירה מקומית.
//
// 💡 רעיונות עתידיים:
//     - הוספת תמיכה בשמות רב-לשוניים (אנגלית, ערבית).
//     - קטגוריות למיקומים (מטבח, חדר, מחסן).
//     - סנכרון עם משתמשים אחרים במשק בית.
//
// 🇬🇧 Custom storage location model:
//     - Represents a user-defined location (beyond default locations).
//     - Includes unique key, Hebrew name, and emoji.
//     - Supports JSON for local storage.
//
// 💡 Future ideas:
//     - Multi-language support (English, Arabic).
//     - Location categories (kitchen, room, storage).
//     - Sync with other household members.
//
// 🔗 Related:
//     - LocationsProvider (providers/locations_provider.dart)
//     - LocationsRepository (repositories/locations_repository.dart)
//     - StorageLocationManager (widgets/inventory/storage_location_manager.dart)
//

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

/// 🇮🇱 מודל למיקום אחסון מותאם אישית
/// 🇬🇧 Custom storage location model
@JsonSerializable()
@immutable
class CustomLocation {
  /// 🇮🇱 מזהה ייחודי (באנגלית, lowercase, עם underscores)
  /// 🇬🇧 Unique identifier (English, lowercase, with underscores)
  final String key;

  /// 🇮🇱 שם המיקום בעברית
  /// 🇬🇧 Location name in Hebrew
  final String name;

  /// 🇮🇱 אמוג'י לתצוגה
  /// 🇬🇧 Display emoji
  /// 🔄 readValue: מחזיר null אם ריק → משתמש בברירת מחדל מה-constructor
  @JsonKey(readValue: _readEmoji)
  final String emoji;

  const CustomLocation({
    required this.key,
    required this.name,
    this.emoji = "📍",
  });

  /// 🇮🇱 יצירה מ-JSON
  /// 🇬🇧 Create from JSON
  factory CustomLocation.fromJson(Map<String, dynamic> json) =>
      _$CustomLocationFromJson(json);

  /// 🇮🇱 המרה ל-JSON
  /// 🇬🇧 Convert to JSON
  Map<String, dynamic> toJson() => _$CustomLocationToJson(this);

  // ---- Validation Helpers ----

  /// 🇮🇱 מנרמל key לפורמט תקין (lowercase, underscores)
  /// 🇬🇧 Normalizes key to valid format (lowercase, underscores)
  ///
  /// Rules:
  /// - Lowercase letters, numbers, underscores only
  /// - No leading/trailing underscores
  /// - No consecutive underscores
  ///
  /// Examples:
  /// - "My Location" → "my_location"
  /// - "  _test_  " → "test"
  /// - "a__b" → "a_b"
  /// - "שלום" → "" (empty - invalid)
  static String normalizeKey(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_') // spaces → underscores
        .replaceAll(RegExp(r'[^a-z0-9_]'), '') // remove invalid chars
        .replaceAll(RegExp(r'_+'), '_') // collapse multiple underscores
        .replaceAll(RegExp(r'^_|_$'), ''); // trim leading/trailing underscores
  }

  /// 🇮🇱 האם ה-key תקין (לא ריק ובפורמט נורמלי)
  /// 🇬🇧 Is the key valid (not empty and normalized)
  bool get isValidKey => key.isNotEmpty && key == normalizeKey(key);

  /// 🇮🇱 האם emoji תקין (לא ריק)
  /// 🇬🇧 Is emoji valid (not empty)
  bool get hasValidEmoji => emoji.isNotEmpty;

  /// 🇮🇱 יצירת עותק עם שינויים
  /// 🇬🇧 Create a copy with updates
  CustomLocation copyWith({String? key, String? name, String? emoji}) {
    return CustomLocation(
      key: key ?? this.key,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
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
  String toString() => 'CustomLocation(key: $key, name: $name, emoji: $emoji)';
}
