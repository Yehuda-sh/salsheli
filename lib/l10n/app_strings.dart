// 📄 File: lib/l10n/app_strings.dart
//
// 🌍 מטרה: מחרוזות UI לאפליקציה (Localization-ready)
//
// 📝 הערות:
// - נבנה להיות תואם למעבר ל-flutter_localizations בעתיד
// - כרגע עברית בלבד, אבל המבנה תומך בהוספת שפות
// - כל המחרוזות מקובצות לפי קטגוריות לוגיות
//
// 🎯 שימוש:
// ```dart
// import 'package:salsheli/l10n/app_strings.dart';
// 
// Text(AppStrings.layout.appTitle)  // "סל חכם"
// Text(AppStrings.common.logout)    // "התנתק"
// ```
//
// 🔮 עתיד: כשנוסיף flutter_localizations, נחליף את הקובץ הזה
//          ב-AppLocalizations generated class
//
// Version: 1.0
// Last Updated: 06/10/2025

/// מחרוזות UI - כרגע עברית בלבד
/// 
/// המבנה:
/// - `layout` - מחרוזות AppLayout (AppBar, Drawer, BottomNav)
/// - `common` - מחרוזות נפוצות (כפתורים, הודעות)
/// - `navigation` - שמות טאבים ומסכים
class AppStrings {
  // מניעת instances
  const AppStrings._();

  // ========================================
  // Layout & Navigation
  // ========================================
  
  static const layout = _LayoutStrings();
  static const navigation = _NavigationStrings();
  
  // ========================================
  // Common UI Elements
  // ========================================
  
  static const common = _CommonStrings();
}

// ========================================
// Layout Strings (AppLayout)
// ========================================

class _LayoutStrings {
  const _LayoutStrings();
  
  // AppBar
  String get appTitle => 'סל חכם';
  
  // Notifications
  String get notifications => 'התראות';
  String get noNotifications => 'אין התראות חדשות';
  String notificationsCount(int count) => 'יש לך $count עדכונים חדשים';
  
  // User Menu
  String get hello => 'שלום 👋';
  String get welcome => 'ברוך הבא לסל חכם';
  String welcomeWithUpdates(int count) => 'יש לך $count עדכונים חדשים';
  
  // Offline
  String get offline => 'אין חיבור לרשת';
}

// ========================================
// Navigation Strings (Tabs)
// ========================================

class _NavigationStrings {
  const _NavigationStrings();
  
  String get home => 'בית';
  String get lists => 'רשימות';
  String get pantry => 'מזווה';
  String get insights => 'תובנות';
  String get settings => 'הגדרות';
}

// ========================================
// Common Strings (Buttons, Actions)
// ========================================

class _CommonStrings {
  const _CommonStrings();
  
  // Actions
  String get logout => 'התנתק';
  String get logoutAction => 'התנתקות';
  String get cancel => 'ביטול';
  String get save => 'שמור';
  String get delete => 'מחק';
  String get edit => 'ערוך';
  String get add => 'הוסף';
  String get search => 'חיפוש';
  
  // Confirmations
  String get yes => 'כן';
  String get no => 'לא';
  String get ok => 'אישור';
  
  // Status
  String get loading => 'טוען...';
  String get error => 'שגיאה';
  String get success => 'הצלחה';
  String get noData => 'אין נתונים';
}

// ========================================
// 💡 טיפים לשימוש
// ========================================
//
// 1. **Import פשוט:**
//    ```dart
//    import 'package:salsheli/l10n/app_strings.dart';
//    ```
//
// 2. **שימוש ב-Widget:**
//    ```dart
//    Text(AppStrings.layout.appTitle)
//    Text(AppStrings.common.logout)
//    Text(AppStrings.navigation.home)
//    ```
//
// 3. **מחרוזות עם פרמטרים:**
//    ```dart
//    Text(AppStrings.layout.notificationsCount(5))
//    // "יש לך 5 עדכונים חדשים"
//    ```
//
// 4. **מעבר ל-flutter_localizations בעתיד:**
//    - נחליף את הקובץ הזה ב-ARB files
//    - נשנה רק את ה-import, הקוד יישאר זהה
//    - המבנה כבר תואם: AppStrings.category.key
//
