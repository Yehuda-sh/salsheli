// 📄 File: lib/config/filters_config.dart
//
// 🎯 מטרה: הגדרת קבועי פילטרים לשימוש במסכים שונים
// 
// 📋 תוכן:
// - CATEGORIES: רשימת קטגוריות מוצרים לסינון ותצוגה
// - STATUSES: רשימת סטטוסים לפריטים ברשימות קניות
//
// 🔗 קשור: lib/config/category_config.dart - לעיצוב ואימוג'י של קטגוריות
//
// 🇮🇱 קובץ זה מגדיר קונפיגורציה קבועה של פילטרים:
//     - CATEGORIES: רשימת קטגוריות מוצרים לשימוש במסכים (סינון/תצוגה).
//     - STATUSES: רשימת סטטוסים לפריטים (ממתין, נלקח, חסר וכו').
//
// 🇬🇧 This file defines static configuration for filters:
//     - CATEGORIES: Product categories for UI filtering/display.
//     - STATUSES: Item statuses (pending, taken, missing, replaced).
//

/// קטגוריות מוצרים לפילטרים
/// 
/// 🎯 שימוש: Dropdowns, רשימות סינון, תפריטים
/// 📝 הערה: זה רק הטקסט לתצוגה. לעיצוב ואימוג'י ראה category_config.dart
/// 
/// **דוגמאות שימוש:**
/// ```dart
/// // ב-Dropdown
/// DropdownButton<String>(
///   items: CATEGORIES.entries.map((e) =>
///     DropdownMenuItem(value: e.key, child: Text(e.value))
///   ).toList(),
/// )
/// 
/// // בדיקה
/// if (category == CATEGORIES.keys.first) { ... } // 'all'
/// ```
/// 
/// 🇮🇱 קטגוריות מוצרים לפילטרים.
/// 🇬🇧 Product categories for filters.
const Map<String, String> CATEGORIES = {
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
/// Text(STATUSES[item.status] ?? 'לא ידוע')
/// 
/// // בדיקה אם הכל נלקח
/// final allTaken = items.every((item) => item.status == 'taken');
/// ```
/// 
/// 🇮🇱 סטטוס פריט ברשימה.
/// 🇬🇧 Item status in shopping list.
const Map<String, String> STATUSES = {
  "all": "כל הסטטוסים", // all statuses
  "pending": "ממתין", // pending
  "taken": "נלקח", // taken
  "missing": "חסר", // missing
  "replaced": "הוחלף", // replaced
};

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
///    final displayText = CATEGORIES[category] ?? 'לא ידוע';
///    ```
/// 
/// 3. **רשימת כל המפתחות:**
///    ```dart
///    final allKeys = CATEGORIES.keys.toList();  // ['all', 'dairy', ...]
///    ```
/// 
/// 4. **קישור ל-category_config.dart:**
///    ```dart
///    // לעיצוב ואימוג'י:
///    import 'package:salsheli/config/category_config.dart';
///    final config = categoryById('dairy');  // 🥛 חלב וביצים + צבע
///    ```
