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

import '../l10n/app_strings.dart';

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
/// 
/// ⚠️ השתמש ב-getCategoryLabel() לקבלת טקסט בעברית
const List<String> kCategories = [
  "all",
  "dairy",
  "meat",
  "vegetables",
  "fruits",
  "bakery",
  "dry_goods",
  "cleaning",
  "toiletries",
  "frozen",
  "beverages",
];

/// קבלת טקסט בעברית לקטגוריה
/// 
/// דוגמה:
/// ```dart
/// getCategoryLabel('dairy') // "חלב וביצים"
/// getCategoryLabel('all') // "כל הקטגוריות"
/// ```
String getCategoryLabel(String categoryId) {
  switch (categoryId) {
    case 'all':
      return AppStrings.filters.allCategories;
    case 'dairy':
      return AppStrings.filters.categoryDairy;
    case 'meat':
      return AppStrings.filters.categoryMeat;
    case 'vegetables':
      return AppStrings.filters.categoryVegetables;
    case 'fruits':
      return AppStrings.filters.categoryFruits;
    case 'bakery':
      return AppStrings.filters.categoryBakery;
    case 'dry_goods':
      return AppStrings.filters.categoryDryGoods;
    case 'cleaning':
      return AppStrings.filters.categoryCleaning;
    case 'toiletries':
      return AppStrings.filters.categoryToiletries;
    case 'frozen':
      return AppStrings.filters.categoryFrozen;
    case 'beverages':
      return AppStrings.filters.categoryBeverages;
    default:
      return categoryId; // fallback
  }
}

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
/// 
/// ⚠️ השתמש ב-getStatusLabel() לקבלת טקסט בעברית
const List<String> kStatuses = [
  "all",
  "pending",
  "taken",
  "missing",
  "replaced",
];

/// קבלת טקסט בעברית לסטטוס
/// 
/// דוגמה:
/// ```dart
/// getStatusLabel('pending') // "ממתין"
/// getStatusLabel('all') // "כל הסטטוסים"
/// ```
String getStatusLabel(String statusId) {
  switch (statusId) {
    case 'all':
      return AppStrings.filters.allStatuses;
    case 'pending':
      return AppStrings.filters.statusPending;
    case 'taken':
      return AppStrings.filters.statusTaken;
    case 'missing':
      return AppStrings.filters.statusMissing;
    case 'replaced':
      return AppStrings.filters.statusReplaced;
    default:
      return statusId; // fallback
  }
}

/// תאימות לאחור (שמות ישנים)
@Deprecated('Use kCategories and getCategoryLabel() instead')
Map<String, String> get CATEGORIES => {
      for (final id in kCategories) id: getCategoryLabel(id),
    };

@Deprecated('Use kStatuses and getStatusLabel() instead')
Map<String, String> get STATUSES => {
      for (final id in kStatuses) id: getStatusLabel(id),
    };

/// 💡 טיפים לשימוש:
/// 
/// 1. **קבלת טקסט בעברית:**
///    ```dart
///    final text = getCategoryLabel('dairy'); // "חלב וביצים"
///    final status = getStatusLabel('pending'); // "ממתין"
///    ```
/// 
/// 2. **השוואת מפתחות בלבד:**
///    ```dart
///    if (category == 'dairy') { ... }  // ✅ השווה למפתח
///    if (category == 'חלב וביצים') { ... }  // ❌ אל תשווה לערך
///    ```
/// 
/// 3. **רשימת כל הקטגוריות:**
///    ```dart
///    for (final id in kCategories) {
///      print('$id: ${getCategoryLabel(id)}');
///    }
///    ```
/// 
/// 4. **קישור ל-category_config.dart:**
///    ```dart
///    // לעיצוב ואימוג'י:
///    import 'package:salsheli/config/category_config.dart';
///    final config = categoryById('dairy');  // 🥛 חלב וביצים + צבע
///    ```
