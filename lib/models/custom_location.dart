// 📄 File: lib/models/custom_location.dart
// תיאור: מודל למיקום אחסון מותאם אישית
//
// מייצג מיקום שהמשתמש הוסיף בעצמו (מעבר למיקומי ברירת המחדל)

import 'package:flutter/foundation.dart';

/// מודל למיקום אחסון מותאם אישית
@immutable
class CustomLocation {
  /// מזהה ייחודי (באנגלית, lowercase, עם underscores)
  final String key;

  /// שם המיקום בעברית
  final String name;

  /// אמוג'י לתצוגה
  final String emoji;

  const CustomLocation({
    required this.key,
    required this.name,
    this.emoji = "📍",
  });

  /// יצירה מ-JSON
  factory CustomLocation.fromJson(Map<String, dynamic> json) {
    return CustomLocation(
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '📍',
    );
  }

  /// המרה ל-JSON
  Map<String, dynamic> toJson() {
    return {'key': key, 'name': name, 'emoji': emoji};
  }

  /// יצירת עותק עם שינויים
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
