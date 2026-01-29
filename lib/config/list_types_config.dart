// 📄 File: lib/config/list_types_config.dart
//
// 🎯 מטרה: הגדרה מרכזית של כל סוגי הרשימות (9 סוגים)
//
// ✨ יתרונות:
// - מקור אמת יחיד (Single Source of Truth)
// - קל להוסיף סוג חדש (רק במקום אחד)
// - עקביות בכל האפליקציה
// - קל לתחזוקה ולבדיקה
//
// 📜 חוקי עבודה:
// - key לא מוכר → fallback ל-ListTypeKeys.other
// - סדר all = סדר UX, other חייב להיות אחרון
// - חייב להיות 1:1 עם ListTypeKeys.all
//
// TODO(i18n): להעביר fullName/shortName ל-AppStrings לתמיכה בתרגום
// ראה: lib/l10n/app_strings.dart

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import 'list_type_keys.dart';

/// 📦 הגדרת סוג רשימה אחד
/// מכיל את כל המידע הויזואלי והטקסטואלי
class ListTypeConfig {
  /// מפתח ייחודי (תואם ל-ShoppingList constants)
  final String key;
  
  /// שם מלא להצגה (למשל ב-Drawer)
  final String fullName;
  
  /// שם קצר להצגה (למשל ב-Dropdown)
  final String shortName;
  
  /// אימוג'י ייצוגי
  final String emoji;
  
  /// אייקון Material
  final IconData icon;
  
  /// צבע אופציונלי (לשימוש עתידי)
  final Color? color;

  const ListTypeConfig({
    required this.key,
    required this.fullName,
    required this.shortName,
    required this.emoji,
    required this.icon,
    this.color,
  });
}

/// 🗂️ כל סוגי הרשימות במערכת
class ListTypes {
  /// רשימת כל הסוגים (8 סוגים + "אחר")
  static const List<ListTypeConfig> all = [
    ListTypeConfig(
      key: ListTypeKeys.supermarket,
      fullName: 'סופרמרקט',
      shortName: 'סופר',
      emoji: '🛒',
      icon: Icons.shopping_cart,
    ),
    ListTypeConfig(
      key: ListTypeKeys.pharmacy,
      fullName: 'בית מרקחת',
      shortName: 'מרקחת',
      emoji: '💊',
      icon: Icons.medication,
    ),
    ListTypeConfig(
      key: ListTypeKeys.greengrocer,
      fullName: 'ירקן',
      shortName: 'ירקן',
      emoji: '🥬',
      icon: Icons.local_florist,
    ),
    ListTypeConfig(
      key: ListTypeKeys.butcher,
      fullName: 'אטליז',
      shortName: 'אטליז',
      emoji: '🥩',
      icon: Icons.set_meal,
    ),
    ListTypeConfig(
      key: ListTypeKeys.bakery,
      fullName: 'מאפייה',
      shortName: 'מאפייה',
      emoji: '🥖',
      icon: Icons.bakery_dining,
    ),
    ListTypeConfig(
      key: ListTypeKeys.market,
      fullName: 'שוק',
      shortName: 'שוק',
      emoji: '🏪',
      icon: Icons.store,
    ),
    ListTypeConfig(
      key: ListTypeKeys.household,
      fullName: 'צרכי בית',
      shortName: 'בית',
      emoji: '🏠',
      icon: Icons.home,
    ),
    ListTypeConfig(
      key: ListTypeKeys.event,
      fullName: 'אירוע',
      shortName: 'אירוע',
      emoji: '🎉',
      icon: Icons.celebration,
    ),
    ListTypeConfig(
      key: ListTypeKeys.other,
      fullName: 'אחר',
      shortName: 'אחר',
      emoji: '📝',
      icon: Icons.more_horiz,
    ),
  ];

  // ========================================
  // 🔍 Lookup API
  // ========================================

  /// 🔍 מצא config לפי key (nullable)
  /// @deprecated השתמש ב-getByKeySafe() שמחזיר תמיד Config
  static ListTypeConfig? getByKey(String key) {
    // ✅ בדיקת תקינות בזמן פיתוח בלבד
    if (kDebugMode) {
      ensureSanity();
    }

    try {
      return all.firstWhere((config) => config.key == key);
    } catch (e) {
      return null;
    }
  }

  /// ✅ מצא config לפי key - תמיד מחזיר Config!
  ///
  /// API בטוח שלא יפיל UI:
  /// - key לא מוכר → מחזיר other
  /// - key == null → מחזיר other
  static ListTypeConfig getByKeySafe(String? key) {
    if (kDebugMode) {
      ensureSanity();
    }

    if (key == null) return _otherConfig;

    // חיפוש ב-all
    for (final config in all) {
      if (config.key == key) return config;
    }

    // לא נמצא → fallback ל-other
    if (kDebugMode) {
      debugPrint('⚠️ ListTypes.getByKeySafe: key לא מוכר "$key" → fallback ל-other');
    }
    return _otherConfig;
  }

  /// Cache ל-other config (ביצועים)
  static final ListTypeConfig _otherConfig = all.firstWhere(
    (c) => c.key == ListTypeKeys.other,
    orElse: () => all.last, // safety fallback
  );

  // ========================================
  // 🔧 Debug Validation
  // ========================================

  static bool _sanityChecked = false;

  /// 🔍 Sanity check - בדיקת פיתוח בלבד
  ///
  /// מוודא:
  /// 1. אין כפילויות keys ב-all
  /// 2. התאמה 1:1 עם ListTypeKeys.all
  /// 3. other הוא אחרון (סדר UX)
  static void ensureSanity() {
    if (!kDebugMode) return;
    if (_sanityChecked) return;
    _sanityChecked = true;

    // 1️⃣ בדיקת כפילויות
    final keys = <String, int>{};
    for (var i = 0; i < all.length; i++) {
      final key = all[i].key;
      if (keys.containsKey(key)) {
        assert(false,
          '❌ ListTypes: כפילות key! '
          '"$key" מופיע באינדקס ${keys[key]} ו-$i',
        );
      }
      keys[key] = i;
    }

    // 2️⃣ בדיקת התאמה 1:1 עם ListTypeKeys.all
    final configKeys = all.map((c) => c.key).toSet();
    final expectedKeys = ListTypeKeys.all.toSet();

    // בדיקת keys חסרים (יש ב-ListTypeKeys אבל אין ב-ListTypes)
    final missingInConfigs = expectedKeys.difference(configKeys);
    if (missingInConfigs.isNotEmpty) {
      assert(false,
        '❌ ListTypes: חסרים configs עבור keys: $missingInConfigs\n'
        'הוסף ListTypeConfig עבור כל key חסר',
      );
    }

    // בדיקת keys מיותרים (יש ב-ListTypes אבל אין ב-ListTypeKeys)
    final extraInConfigs = configKeys.difference(expectedKeys);
    if (extraInConfigs.isNotEmpty) {
      assert(false,
        '❌ ListTypes: יש configs עם keys לא מוכרים: $extraInConfigs\n'
        'הוסף את ה-keys ל-ListTypeKeys.all או הסר את ה-configs',
      );
    }

    // 3️⃣ בדיקה ש-other הוא אחרון
    if (all.isNotEmpty && all.last.key != ListTypeKeys.other) {
      assert(false,
        '❌ ListTypes: "${ListTypeKeys.other}" חייב להיות אחרון ב-all! '
        'נמצא: "${all.last.key}"',
      );
    }

    debugPrint('✅ ListTypes.ensureSanity(): ${all.length} configs, התאמה מלאה ל-ListTypeKeys');
  }
}
