// 📄 lib/l10n/onboarding_extensions.dart
//
// Extensions למחרוזות Onboarding - תרגום גילאי ילדים וימי שבוע לעברית.
// כולל getAgeLabel, getDayLabel, ורשימות allAges/allDays.
//
// ⚠️ שימו לב: allAges חייב להיות מסונכרן עם kValidChildrenAges ב-constants.dart!
//
// 🔗 Related: onboarding_screen, onboarding_data, AppStrings, constants.dart

class OnboardingExtensions {
  const OnboardingExtensions._();

  /// תרגום גיל ילדים לעברית
  ///
  /// ⚠️ הערכים חייבים להתאים ל-kValidChildrenAges ב-constants.dart!
  static String getAgeLabel(String age) {
    switch (age) {
      case '0-1':
        return 'תינוק/ת (0-1)';
      case '2-3':
        return 'גיל הרך (2-3)';
      case '4-6':
        return 'גן (4-6)';
      case '7-12':
        return 'בית ספר (7-12)';
      case '13-18':
        return 'נוער (13-18)';
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
  ///
  /// ⚠️ חייב להתאים ל-kValidChildrenAges ב-constants.dart!
  /// סדר: תינוקות → גיל הרך → גן → בי"ס → נוער
  static const List<String> allAges = ['0-1', '2-3', '4-6', '7-12', '13-18'];

  /// רשימת כל ימי השבוע
  static const List<int> allDays = [0, 1, 2, 3, 4, 5, 6];
}
