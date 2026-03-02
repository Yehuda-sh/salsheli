// 📄 lib/l10n/onboarding_extensions.dart
//
// Extensions למחרוזות Onboarding - תרגום גילאי ילדים וימי שבוע לעברית.
//
// 📋 Features:
// - שימוש ב-Dart Extensions לתחביר נקי ('4-6'.ageLabel, 1.dayLabel)
// - תיעוד מלא לכל הרחבה
//
// ✅ Single Source of Truth: kChildrenAgeGroups ב-constants.dart
// ✅ Labels מגיעים מ-AppStrings (גילאים)
//
// 🔗 Related: onboarding_screen, onboarding_data, AppStrings, constants.dart
//
// 📝 Version: 2.0
// 📅 Updated: 22/02/2026

import '../core/constants.dart';
import 'app_strings.dart';

/// 🎂 Extension לתרגום גילאי ילדים לעברית
///
/// ממפה מחרוזות גיל (כגון '0-1', '4-6') ל-label מתורגם מ-AppStrings.
///
/// ```dart
/// final label = '4-6'.ageLabel; // => 'גן (4-6)'
/// ```
extension OnboardingAgeX on String {
  /// מחזיר label מתורגם לפי key מ-kChildrenAgeGroups.
  /// אם הערך לא מוכר, מחזיר את המחרוזת המקורית כ-fallback.
  String get ageLabel {
    final s = AppStrings.onboarding;
    return switch (this) {
      '0-1' => s.ageBaby,
      '2-3' => s.ageToddler,
      '4-6' => s.agePreschool,
      '7-12' => s.ageSchool,
      '13-18' => s.ageTeen,
      _ => this,
    };
  }

  /// רשימת כל גילאי הילדים
  /// ✅ Single Source of Truth: kChildrenAgeGroups ב-constants.dart
  static List<String> get allAges => kChildrenAgeGroups;
}

/// 📅 Extension לתרגום יום בשבוע לעברית
///
/// ממפה אינדקס יום (0=ראשון, 6=שבת) ל-label בעברית.
///
/// ```dart
/// final label = 1.dayLabel; // => 'שני'
/// final labels = [0, 5, 6].map((d) => d.dayLabel); // => ['ראשון', 'שישי', 'שבת']
/// ```
extension OnboardingDayX on int {
  /// מחזיר שם היום בעברית (0=ראשון ... 6=שבת).
  /// אם המספר מחוץ לטווח 0-6, מחזיר 'לא ידוע'.
  String get dayLabel {
    return switch (this) {
      0 => 'ראשון',
      1 => 'שני',
      2 => 'שלישי',
      3 => 'רביעי',
      4 => 'חמישי',
      5 => 'שישי',
      6 => 'שבת',
      _ => 'לא ידוע',
    };
  }

  /// רשימת כל ימי השבוע (0-6)
  static const List<int> allDays = [0, 1, 2, 3, 4, 5, 6];
}
