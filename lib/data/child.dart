// 📄 File: lib/data/child.dart
// 🎯 Purpose: מודל Child - ייצוג ילד במשפחה
//
// 📋 Features:
// - תמיכה באמוג'י וצבעים לכל קבוצת גיל
// - שילוב עם OnboardingAgeX
// - ולידציה משופרת
//
// Version: 2.0 (22/02/2026)

import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../l10n/onboarding_extensions.dart';

/// מודל ייצוג ילד
///
/// מכיל שם וקטגוריית גיל לשם פרסונליזציה והמלצות מוצרים.
/// כולל מאפיינים ויזואליים (אמוג'י, צבע) לשימוש ב-UI.
///
/// **דוגמה:**
/// ```dart
/// final child = Child(name: 'נועה', ageCategory: '0-1'); // תינוקת
/// child.emoji;          // => '👶'
/// child.ageDescription; // => 'תינוק/ת (0-1)'
/// child.isBaby;         // => true
/// ```
class Child {
  /// שם הילד/ה
  final String name;

  /// קטגוריית גיל (מתוך kValidChildrenAges)
  ///
  /// אפשרויות:
  /// - '0-1': תינוקות
  /// - '2-3': גיל הרך
  /// - '4-6': גן
  /// - '7-12': בית ספר
  /// - '13-18': נוער
  final String ageCategory;

  const Child({
    required this.name,
    required this.ageCategory,
  });

  /// בדיקה אם הגיל תקין
  bool get isValidAge => kValidChildrenAges.contains(ageCategory);

  /// האם הילד בגיל תינוקות/רך (0-3)
  ///
  /// שימושי להצעת מוצרים כמו חיתולים, תחליפי חלב וכו'.
  bool get isBaby => ageCategory == '0-1' || ageCategory == '2-3';

  /// תיאור טקסטואלי של הגיל (מ-AppStrings דרך OnboardingAgeX)
  String get ageDescription => ageCategory.ageLabel;

  /// אמוג'י מתאים לקבוצת הגיל
  String get emoji {
    return switch (ageCategory) {
      '0-1' => '👶',
      '2-3' => '🧒',
      '4-6' => '🎨',
      '7-12' => '🎒',
      '13-18' => '🎓',
      _ => '👤',
    };
  }

  /// צבע פסטל עדין לפי קבוצת גיל (לשימוש ב-UI)
  Color get color {
    return switch (ageCategory) {
      '0-1' => const Color(0xFFE91E63).withValues(alpha: 0.15), // ורוד
      '2-3' => const Color(0xFFFF9800).withValues(alpha: 0.15), // כתום
      '4-6' => const Color(0xFF4CAF50).withValues(alpha: 0.15), // ירוק
      '7-12' => const Color(0xFF2196F3).withValues(alpha: 0.15), // כחול
      '13-18' => const Color(0xFF9C27B0).withValues(alpha: 0.15), // סגול
      _ => const Color(0xFF9E9E9E).withValues(alpha: 0.15), // אפור
    };
  }

  /// המרה ל-JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ageCategory': ageCategory,
    };
  }

  /// טעינה מ-JSON
  ///
  /// ולידציה: אם ageCategory לא תקין, נופל לערך ברירת מחדל ('0-1').
  factory Child.fromJson(Map<String, dynamic> json) {
    final rawAge = json['ageCategory'] as String? ?? '';
    final safeAge = kValidChildrenAges.contains(rawAge) ? rawAge : '0-1';

    return Child(
      name: (json['name'] as String? ?? '').trim(),
      ageCategory: safeAge,
    );
  }

  /// יצירת עותק מעודכן
  Child copyWith({
    String? name,
    String? ageCategory,
  }) {
    return Child(
      name: name ?? this.name,
      ageCategory: ageCategory ?? this.ageCategory,
    );
  }

  @override
  String toString() => 'Child(name: $name, age: $ageCategory)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Child &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          ageCategory == other.ageCategory;

  @override
  int get hashCode => name.hashCode ^ ageCategory.hashCode;
}
