// 📄 File: lib/config/filters_config.dart
//
// 🇮🇱 קובץ זה מגדיר קונפיגורציה קבועה של פילטרים:
//     - CATEGORIES: רשימת קטגוריות מוצרים לשימוש במסכים (סינון/תצוגה).
//     - STATUSES: רשימת סטטוסים לפריטים (ממתין, נלקח, חסר וכו').
//
// 🇬🇧 This file defines static configuration for filters:
//     - CATEGORIES: Product categories for UI filtering/display.
//     - STATUSES: Item statuses (pending, taken, missing, replaced).
//

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

/// 🇮🇱 סטטוס פריט ברשימה.
/// 🇬🇧 Item status in shopping list.
const Map<String, String> STATUSES = {
  "all": "כל הסטטוסים", // all statuses
  "pending": "ממתין", // pending
  "taken": "נלקח", // taken
  "missing": "חסר", // missing
  "replaced": "הוחלף", // replaced
};
