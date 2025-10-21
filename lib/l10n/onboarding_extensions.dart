// 📄 File: lib/l10n/onboarding_extensions.dart
//
// 🎯 מטרה: Extensions למחרוזות Onboarding - תרגומים לגילאי ילדים וימי שבוע
//
// שימוש:
// ```dart
// final ageLabel = OnboardingExtensions.getAgeLabel('babies'); // "תינוקות (0-2)"
// final dayLabel = OnboardingExtensions.getDayLabel(0); // "ראשון"
// ```

class OnboardingExtensions {
  const OnboardingExtensions._();

  /// תרגום גיל ילדים לעברית
  static String getAgeLabel(String age) {
    switch (age) {
      case 'babies':
        return 'תינוקות (0-2)';
      case 'toddlers':
        return 'פעוטות (3-6)';
      case 'children':
        return 'ילדים (7-12)';
      case 'teens':
        return 'בני נוער (13-18)';
      default:
        return age;
    }
  }

  /// תרגום יום בשבוע לעברית (0=ראשון, 6=שבת)
  static String getDayLabel(int day) {
    switch (day) {
      case 0:
        return 'ראשון';
      case 1:
        return 'שני';
      case 2:
        return 'שלישי';
      case 3:
        return 'רביעי';
      case 4:
        return 'חמישי';
      case 5:
        return 'שישי';
      case 6:
        return 'שבת';
      default:
        return '';
    }
  }

  /// רשימת כל גילאי הילדים
  static const List<String> allAges = ['babies', 'toddlers', 'children', 'teens'];

  /// רשימת כל ימי השבוע
  static const List<int> allDays = [0, 1, 2, 3, 4, 5, 6];
}
