// 📄 lib/config/list_type_keys.dart
//
// 🎯 מפתחות סוגי רשימות - קובץ משותף למניעת circular imports
//
// ✅ השימוש:
// - ListTypes (config) מייבא את הקובץ הזה
// - ShoppingList (model) יכול לייבא גם ListTypes וגם הקובץ הזה
// - אין מעגל תלות!
//
// 📜 חוקי עבודה:
// - המפתחות הם חוזה נתונים: לא משנים keys קיימים לעולם, רק מוסיפים
// - key לא מוכר → fallback ל-ListTypeKeys.other
// - ListTypeKeys.all = סוגים שמוצגים למשתמש (UI בלבד)
// - סדר all = סדר תצוגה, other חייב להיות אחרון
// - naming: lowercase באנגלית, underscore לפי צורך
//
// 🔗 Related: list_types_config.dart, shopping_list.dart

import 'package:flutter/foundation.dart';

/// 🗂️ מפתחות סוגי רשימות
///
/// משמש כ-Single Source of Truth למפתחות (keys) בלבד.
/// ה-metadata (emoji, name, icon) נמצא ב-ListTypes.
class ListTypeKeys {
  ListTypeKeys._(); // מניעת instances

  /// 🛒 סופרמרקט - כל המוצרים
  static const String supermarket = 'supermarket';

  /// 💊 בית מרקחת - היגיינה וניקיון
  static const String pharmacy = 'pharmacy';

  /// 🥬 ירקן - פירות וירקות
  static const String greengrocer = 'greengrocer';

  /// 🥩 אטליז - בשר ועוף
  static const String butcher = 'butcher';

  /// 🍞 מאפייה - לחם ומאפים
  static const String bakery = 'bakery';

  /// 🏪 שוק - מעורב
  static const String market = 'market';

  /// 🏠 צרכי בית - מוצרים מותאמים
  static const String household = 'household';

  /// 🎉 אירוע - מסיבות ומנגלים
  static const String event = 'event';

  /// ➕ אחר
  static const String other = 'other';

  /// רשימת כל המפתחות (לשימוש בלולאות/בדיקות)
  /// ✅ סדר תצוגה - other חייב להיות אחרון
  static const List<String> all = [
    supermarket,
    pharmacy,
    greengrocer,
    butcher,
    bakery,
    market,
    household,
    event,
    other, // ✅ תמיד אחרון (fallback)
  ];

  /// 🔍 Sanity check - בדיקת פיתוח בלבד
  ///
  /// מוודא:
  /// 1. אין כפילויות ב-all
  /// 2. other הוא האחרון ברשימה
  ///
  /// קרא לפונקציה זו ב-main.dart או בטסטים לוודא תקינות.
  static void ensureSanity() {
    if (!kDebugMode) return;

    // 1️⃣ בדיקת כפילויות
    final seen = <String>{};
    for (final key in all) {
      if (seen.contains(key)) {
        assert(false, '❌ ListTypeKeys: כפילות! "$key" מופיע יותר מפעם אחת ב-all');
      }
      seen.add(key);
    }

    // 2️⃣ בדיקה ש-other הוא אחרון
    if (all.isNotEmpty && all.last != other) {
      assert(false,
        '❌ ListTypeKeys: "$other" חייב להיות אחרון ב-all! '
        'נמצא: "${all.last}"',
      );
    }

    debugPrint('✅ ListTypeKeys.ensureSanity(): ${all.length} keys, no issues');
  }

  /// Fallback לערך לא מוכר
  static String resolve(String? key) {
    if (key == null || !all.contains(key)) return other;
    return key;
  }
}
