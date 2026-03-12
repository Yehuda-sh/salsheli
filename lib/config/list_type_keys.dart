// 📄 lib/config/list_type_keys.dart
//
// 🎯 מפתחות סוגי רשימות - קובץ משותף למניעת circular imports.
//
// ✅ השימוש:
// - ListTypes (config) מייבא את הקובץ הזה.
// - ShoppingList (model) יכול לייבא גם ListTypes וגם הקובץ הזה.
// - אין מעגל תלות!
//
// 📜 חוקי עבודה:
// - המפתחות הם חוזה נתונים: לא משנים keys קיימים לעולם, רק מוסיפים.
// - key לא מוכר ← fallback ל-ListTypeKeys.other.
// - ListTypeKeys.all = סוגים שמוצגים למשתמש (UI בלבד).
// - סדר all = סדר תצוגה, other חייב להיות אחרון.
// - naming: lowercase באנגלית, underscore לפי צורך.
//
// 🔗 Related: list_types_config.dart, shopping_list.dart

import 'package:flutter/foundation.dart';

/// 🗂️ מפתחות סוגי רשימות
///
/// משמש כ-Single Source of Truth למפתחות (keys) בלבד.
/// ה-metadata (אמוג'י, שם, אייקון) מנוהל בנפרד ב-ListTypesConfig.
class ListTypeKeys {
  ListTypeKeys._(); // מניעת instances

  /// 🛒 סופרמרקט - כל המוצרים הכלליים
  static const String supermarket = 'supermarket';

  /// 💊 בית מרקחת - מוצרי פארם, היגיינה וניקיון
  static const String pharmacy = 'pharmacy';

  /// 🥬 ירקן - פירות וירקות טריים
  static const String greengrocer = 'greengrocer';

  /// 🥩 אטליז - בשר, עוף ודגים
  static const String butcher = 'butcher';

  /// 🍞 מאפייה - לחם, מאפים ועוגות
  static const String bakery = 'bakery';

  /// 🏪 שוק - רשימות מעורבות (כמו מחנה יהודה)
  static const String market = 'market';

  /// 🏠 צרכי בית - מוצרי תחזוקה, גינה או כלי בית
  static const String household = 'household';

  /// 🎉 אירוע - רשימות ייעודיות למסיבות, חגים או מנגלים
  static const String event = 'event';

  /// ➕ אחר - סוג רשימה כללי (Fallback)
  static const String other = 'other';

  /// רשימת כל המפתחות (לשימוש ב-UI או ב-Validators)
  /// ✅ סדר תצוגה קבוע - other תמיד מופיע בסוף
  static const List<String> all = [
    supermarket,
    pharmacy,
    greengrocer,
    butcher,
    bakery,
    market,
    household,
    event,
    other,
  ];

  /// 🔍 בדיקת תקינות בזמן פיתוח
  ///
  /// מוודא שאין כפילויות במערך ה-all וששדה ה-fallback (other) נמצא במקום הנכון.
  static void ensureSanity() {
    if (!kDebugMode) return;

    // 1️⃣ בדיקת כפילויות (באמצעות Set ליעילות)
    final distinctKeys = all.toSet();
    if (distinctKeys.length != all.length) {
      // מציאת המפתח הכפול לטובת הודעת השגיאה
      final duplicates = all.where((key) {
        return all.indexOf(key) != all.lastIndexOf(key);
      }).toSet();

      assert(false, '❌ ListTypeKeys: נמצאו כפילויות ב-all: $duplicates');
    }

    // 2️⃣ בדיקה ש-other הוא הערך האחרון (קריטי ל-UI)
    if (all.isNotEmpty && all.last != other) {
      assert(
        false,
        '❌ ListTypeKeys: "$other" חייב להיות האיבר האחרון ב-all לצורך עקביות ב-UI. '
        'נמצא: "${all.last}"',
      );
    }
  }

  /// המרת String למפתח מוכר (עם Fallback)
  /// שימושי בטעינת נתונים מה-Database (Firestore/Hive)
  static String resolve(String? key) {
    if (key == null) return other;
    final normalized = key.trim().toLowerCase();
    if (!all.contains(normalized)) return other;
    return normalized;
  }
}
