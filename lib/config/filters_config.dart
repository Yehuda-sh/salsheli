// 📄 File: lib/config/filters_config.dart
//
// 🎯 מטרה: הגדרת קבועי פילטרים לשימוש במסכים שונים
// 
// 📋 תוכן:
// - kCategories: רשימת קטגוריות מוצרים לסינון ותצוגה
// - kStatuses: רשימת סטטוסים לפריטים ברשימות קניות
//
// 🔗 קשור: lib/config/category_config.dart - לעיצוב ואימוג'י של קטגוריות
//
// 🇮🇱 קובץ זה מגדיר קונפיגורציה קבועה של פילטרים:
//     - kCategories: רשימת קטגוריות מוצרים לשימוש במסכים (סינון/תצוגה).
//     - kStatuses: רשימת סטטוסים לפריטים (ממתין, נלקח, חסר וכו').
//
// 🇬🇧 This file defines static configuration for filters:
//     - kCategories: Product categories for UI filtering/display.
//     - kStatuses: Item statuses (pending, taken, missing, replaced).
//

// ignore_for_file: constant_identifier_names

/// קטגוריות מוצרים לפילטרים
/// 
/// 🎯 שימוש: Dropdowns, רשימות סינון, תפריטים
/// 📝 הערה: זה רק הטקסט לתצוגה. לעיצוב ואימוג'י ראה category_config.dart
/// 
/// **דוגמאות שימוש:**
/// ```dart
/// // ב-Dropdown
/// DropdownButton<String>(
///   items: kCategories.entries.map((e) =>
///     DropdownMenuItem(value: e.key, child: Text(e.value))
///   ).toList(),
/// )
/// 
/// // בדיקה
/// if (category == kCategories.keys.first) { ... } // 'all'
/// ```
/// 
/// 🇮🇱 קטגוריות מוצרים לפילטרים.
/// 🇬🇧 Product categories for filters.
const Map<String, String> kCategories = {
  "all": "כל הקטגוריות", // all categories
  "dairy": "חלב וביצים", // dairy & eggs
  "meat": "בשר ודגים", // meat & fish
  "vegetables": "ירקות", // vegetables
  "fruits": "פירות", // fruits
  "bakery": "לחם ומאפים", // bakery
  "dry_goods": "מוצרים יבשים", // dry goods
  "cleaning": "חומרי ניקיון", // cleaning
  "toiletries": "טואלטיקה", // toiletries
  "frozen": "קפואים", // frozen
  "beverages": "משקאות", // beverages
};

/// סטטוסים של פריטים ברשימות קניות
/// 
/// 🎯 שימוש: מעקב אחר מצב פריטים במהלך קניות
/// 
/// **מצבים אפשריים:**
/// - `pending` (ממתין) - עדיין לא נקנה
/// - `taken` (נלקח) - נוסף לעגלה/נקנה
/// - `missing` (חסר) - לא נמצא בחנות
/// - `replaced` (הוחלף) - נקנה תחליף
/// 
/// **דוגמאות שימוש:**
/// ```dart
/// // סינון רק פריטים שנלקחו
/// items.where((item) => item.status == 'taken')
/// 
/// // הצגת טקסט לפי סטטוס
/// Text(kStatuses[item.status] ?? 'לא ידוע')
/// 
/// // בדיקה אם הכל נלקח
/// final allTaken = items.every((item) => item.status == 'taken');
/// ```
/// 
/// 🇮🇱 סטטוס פריט ברשימה.
/// 🇬🇧 Item status in shopping list.
const Map<String, String> kStatuses = {
  "all": "כל הסטטוסים", // all statuses
  "pending": "ממתין", // pending
  "taken": "נלקח", // taken
  "missing": "חסר", // missing
  "replaced": "הוחלף", // replaced
};

/// תאימות לאחור (שמות ישנים)
@Deprecated('Use kCategories instead')
const Map<String, String> CATEGORIES = kCategories;

@Deprecated('Use kStatuses instead')
const Map<String, String> STATUSES = kStatuses;

/// 💡 טיפים לשימוש:
/// 
/// 1. **השוואת מפתחות בלבד:**
///    ```dart
///    if (category == 'dairy') { ... }  // ✅ השווה למפתח
///    if (category == 'חלב וביצים') { ... }  // ❌ אל תשווה לערך
///    ```
/// 
/// 2. **Fallback בטוח:**
///    ```dart
///    final displayText = kCategories[category] ?? 'לא ידוע';
///    ```
/// 
/// 3. **רשימת כל המפתחות:**
///    ```dart
///    final allKeys = kCategories.keys.toList();  // ['all', 'dairy', ...]
///    ```
/// 
/// 4. **קישור ל-category_config.dart:**
///    ```dart
///    // לעיצוב ואימוג'י:
///    import 'package:salsheli/config/category_config.dart';
///    final config = categoryById('dairy');  // 🥛 חלב וביצים + צבע
///    ```
