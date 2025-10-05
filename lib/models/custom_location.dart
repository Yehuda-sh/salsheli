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

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'custom_location.g.dart';

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
  final String emoji;

  const CustomLocation({
    required this.key,
    required this.name,
    this.emoji = "📍",
  });

  /// 🇮🇱 יצירה מ-JSON
  /// 🇬🇧 Create from JSON
  factory CustomLocation.fromJson(Map<String, dynamic> json) {
    debugPrint('📥 CustomLocation.fromJson:');
    debugPrint('   key: ${json['key']}');
    debugPrint('   name: ${json['name']}');
    debugPrint('   emoji: ${json['emoji']}');
    return _$CustomLocationFromJson(json);
  }

  /// 🇮🇱 המרה ל-JSON
  /// 🇬🇧 Convert to JSON
  Map<String, dynamic> toJson() {
    debugPrint('📤 CustomLocation.toJson:');
    debugPrint('   key: $key');
    debugPrint('   name: $name');
    debugPrint('   emoji: $emoji');
    return _$CustomLocationToJson(this);
  }

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
