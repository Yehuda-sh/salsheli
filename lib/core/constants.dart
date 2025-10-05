// 📄 File: lib/core/constants.dart
// 🎯 מטרה: קבועים גלובליים לכל האפליקציה
//
// 📋 כולל:
// - רשימות ברירת מחדל (חנויות, קטגוריות, מיקומי אחסון)
// - הגדרות כלליות (גבולות, מגבלות)
// - קבועי UI (ריווחים, גדלים)
// - מיפוי אמוג'י לקטגוריות
// - סוגי רשימות קניות
//
// 🔗 קבצים קשורים:
// - lib/config/category_config.dart - עיצוב מלא של קטגוריות (צבעים, אימוג'י)
// - lib/config/filters_config.dart - טקסטים לפילטרים
// - lib/models/custom_location.dart - מודל למיקומי אחסון מותאמים

// ========================================
// חנויות וקטגוריות
// ========================================

/// רשימת חנויות ברירת מחדל
/// 
/// 🎯 שימוש: Autocomplete, Dropdowns, רשימות חנויות מועדפות
/// 📝 הערה: משתמשים יכולים להוסיף חנויות נוספות
/// 
/// **דוגמאות שימוש:**
/// ```dart
/// // ב-Autocomplete
/// Autocomplete<String>(
///   optionsBuilder: (textEditingValue) {
///     return kPredefinedStores.where((store) =>
///       store.contains(textEditingValue.text)
///     );
///   },
/// )
/// 
/// // בדיקה אם חנות ידועה
/// final isKnown = kPredefinedStores.contains(storeName);
/// ```
const List<String> kPredefinedStores = <String>[
  "שופרסל",
  "רמי לוי",
  "יוחננוף",
  "ויקטורי",
  "טיב טעם",
  "אושר עד",
];

/// רשימת קטגוריות ברירת מחדל
/// 
/// 🎯 שימוש: תצוגה בסיסית של קטגוריות (ללא עיצוב)
/// 📝 הערה: לעיצוב מלא (צבעים, אימוג'י) ראה category_config.dart
/// 
/// **דוגמאות שימוש:**
/// ```dart
/// // בחירה מרשימה
/// DropdownButton<String>(
///   items: kCategories.map((cat) =>
///     DropdownMenuItem(value: cat, child: Text(cat))
///   ).toList(),
/// )
/// ```
const List<String> kCategories = <String>[
  "ירקות ופירות",
  "מוצרי חלב",
  "מוצרי ניקיון",
  "בשר ודגים",
  "משקאות",
  "חטיפים",
];

// ========================================
// מיקומי אחסון
// ========================================

/// מיקומי אחסון ברירת מחדל
///
/// כל מיקום מוגדר עם:
/// - **key** - מזהה ייחודי באנגלית (snake_case)
/// - **name** - שם בעברית לתצוגה
/// - **emoji** - אמוג'י לייצוג ויזואלי
/// 
/// 🎯 שימוש: ניהול מלאי, ארגון פריטים לפי מיקום
/// 📝 הערה: משתמשים יכולים להוסיף מיקומים מותאמים דרך LocationsProvider
/// 
/// **דוגמאות שימוש:**
/// ```dart
/// // קבלת שם מיקום
/// final name = kStorageLocations['refrigerator']?['name'] ?? 'לא ידוע';
/// // תוצאה: "מקרר"
/// 
/// // קבלת אמוג'י
/// final emoji = kStorageLocations['main_pantry']?['emoji'] ?? '📦';
/// // תוצאה: "🏠"
/// 
/// // רשימת כל המפתחות
/// final allKeys = kStorageLocations.keys.toList();
/// // ['main_pantry', 'refrigerator', 'freezer', ...]
/// ```
const Map<String, Map<String, String>> kStorageLocations = {
  "main_pantry": {"name": "מזווה ראשי", "emoji": "🏠"},
  "refrigerator": {"name": "מקרר", "emoji": "❄️"},
  "freezer": {"name": "מקפיא", "emoji": "🧊"},
  "secondary_storage": {"name": "אחסון משני", "emoji": "📦"},
  "bathroom": {"name": "אמבטיה", "emoji": "🛁"},
  "laundry": {"name": "חדר כביסה", "emoji": "🧺"},
  "garage": {"name": "מחסן / חניה", "emoji": "🚗"},
  "cleaning_cabinet": {"name": "ארון ניקיון", "emoji": "🧼"},
  "spices_shelf": {"name": "מדף תבלינים", "emoji": "🧂"},
  "drinks_corner": {"name": "פינת שתייה", "emoji": "🍹"},
};

// ========================================
// מיפוי אמוג'י לקטגוריות
// ========================================

/// מיפוי קטגוריות לאמוג'י (באנגלית)
///
/// 🎯 שימוש: תצוגה ויזואלית של מוצרים לפי קטגוריה
/// ⚠️ הערה חשובה: המפתחות באנגלית! לקטגוריות בעברית ראה storage_location_manager.dart
/// 
/// **דוגמאות שימוש:**
/// ```dart
/// // קבלת אמוג'י לקטגוריה
/// final emoji = kCategoryEmojis['dairy'] ?? '📦';
/// // תוצאה: "🥛"
/// 
/// // fallback בטוח
/// String getEmoji(String category) {
///   return kCategoryEmojis[category] ?? kCategoryEmojis['other'] ?? '📦';
/// }
/// ```
const Map<String, String> kCategoryEmojis = {
  "dairy": "🥛",
  "meat": "🥩",
  "chicken": "🍗",
  "fish": "🐟",
  "vegetables": "🥬",
  "fruits": "🍎",
  "bakery": "🍞",
  "pasta_rice": "🍝",
  "snacks": "🍿",
  "sweets": "🍬",
  "beverages": "🥤",
  "alcohol": "🍷",
  "canned": "🥫",
  "frozen": "🧊",
  "spices": "🧂",
  "cleaning": "🧼",
  "toiletries": "🧻",
  "baby": "🍼",
  "pet": "🐾",
  "paper_goods": "📄",
  "health": "💊",
  "cosmetics": "💄",
  "household": "🏠",
  "tech": "💻",
  "clothing": "👕",
  "tools": "🛠️",
  "other": "📦",
};

// ========================================
// הגדרות משפחה ותקציב
// ========================================

/// גודל משפחה מינימלי
/// 
/// 🎯 שימוש: Validation בטפסים
const int kMinFamilySize = 1;

/// גודל משפחה מקסימלי
/// 
/// 🎯 שימוש: Validation בטפסים
const int kMaxFamilySize = 20;

/// תקציב חודשי מינימלי (בשקלים)
/// 
/// 🎯 שימוש: Validation בהגדרת תקציב
/// 📝 הערה: ₪100 הוא המינימום הריאלי
const double kMinMonthlyBudget = 100.0;

/// תקציב חודשי מקסימלי (בשקלים)
/// 
/// 🎯 שימוש: Validation בהגדרת תקציב
/// 📝 הערה: ₪50,000 מספיק למשפחות גדולות
const double kMaxMonthlyBudget = 50000.0;

// ========================================
// קבועי UI
// ========================================

/// ריווח קטן בין אלמנטים
/// 
/// 🎯 שימוש: Padding, SizedBox בתוך Rows/Columns קטנים
/// 
/// **דוגמה:**
/// ```dart
/// SizedBox(height: kSpacingSmall)
/// Padding(padding: EdgeInsets.all(kSpacingSmall))
/// ```
const double kSpacingSmall = 8.0;

/// ריווח בינוני בין אלמנטים
/// 
/// 🎯 שימוש: Padding רגיל, מרווחים בין Widgets
/// 
/// **דוגמה:**
/// ```dart
/// SizedBox(height: kSpacingMedium)
/// Padding(padding: EdgeInsets.symmetric(horizontal: kSpacingMedium))
/// ```
const double kSpacingMedium = 16.0;

/// ריווח גדול בין אלמנטים
/// 
/// 🎯 שימוש: מרווחים בין קטעים, Padding של מסכים
/// 
/// **דוגמה:**
/// ```dart
/// SizedBox(height: kSpacingLarge)
/// Padding(padding: EdgeInsets.all(kSpacingLarge))
/// ```
const double kSpacingLarge = 24.0;

/// גובה כפתור סטנדרטי
/// 
/// 🎯 שימוש: ElevatedButton, OutlinedButton
/// 📝 הערה: עומד בתקני נגישות (מינימום 48px לחיצה)
/// 
/// **דוגמה:**
/// ```dart
/// SizedBox(
///   height: kButtonHeight,
///   child: ElevatedButton(...),
/// )
/// ```
const double kButtonHeight = 48.0;

/// רדיוס פינות סטנדרטי
/// 
/// 🎯 שימוש: Container, Card, BorderRadius
/// 📝 הערה: 12px נותן מראה מודרני וידידותי
/// 
/// **דוגמה:**
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: BorderRadius.circular(kBorderRadius),
///   ),
/// )
/// ```
const double kBorderRadius = 12.0;

// ========================================
// סוגי רשימות קניות
// ========================================

/// סוגי רשימות קניות זמינים
///
/// כל סוג מוגדר עם:
/// - **key** - מזהה ייחודי (super/pharmacy/other)
/// - **name** - שם בעברית לתצוגה
/// - **description** - תיאור קצר
/// - **icon** - אמוג'י לייצוג ויזואלי
/// 
/// 🎯 שימוש: יצירת רשימות, סינון, תצוגה
/// 
/// **דוגמאות שימוש:**
/// ```dart
/// // קבלת שם סוג רשימה
/// final name = kListTypes['super']?['name'] ?? 'לא ידוע';
/// // תוצאה: "סופרמרקט"
/// 
/// // קבלת אייקון
/// final icon = kListTypes['pharmacy']?['icon'] ?? '📝';
/// // תוצאה: "💊"
/// 
/// // בניית Dropdown
/// DropdownButton<String>(
///   items: kListTypes.entries.map((e) =>
///     DropdownMenuItem(
///       value: e.key,
///       child: Row(
///         children: [
///           Text(e.value['icon']!),
///           SizedBox(width: 8),
///           Text(e.value['name']!),
///         ],
///       ),
///     )
///   ).toList(),
/// )
/// ```
const Map<String, Map<String, String>> kListTypes = {
  "super": {
    "name": "סופרמרקט",
    "description": "קניות מזון ומוצרי בית",
    "icon": "🛒",
  },
  "pharmacy": {
    "name": "בית מרקחת",
    "description": "תרופות וקוסמטיקה",
    "icon": "💊",
  },
  "hardware": {
    "name": "חומרי בניין",
    "description": "כלים וחומרי בניין",
    "icon": "🔨",
  },
  "clothing": {
    "name": "ביגוד",
    "description": "בגדים והנעלה",
    "icon": "👕",
  },
  "electronics": {
    "name": "אלקטרוניקה",
    "description": "מוצרי חשמל ואלקטרוניקה",
    "icon": "💻",
  },
  "pets": {
    "name": "חיות מחמד",
    "description": "מזון ומוצרים לחיות",
    "icon": "🐾",
  },
  "cosmetics": {
    "name": "קוסמטיקה",
    "description": "מוצרי טיפוח ויופי",
    "icon": "💄",
  },
  "stationery": {
    "name": "ציוד משרדי",
    "description": "ציוד כתיבה ומשרד",
    "icon": "✏️",
  },
  "toys": {
    "name": "צעצועים",
    "description": "משחקים וצעצועים",
    "icon": "🧸",
  },
  "books": {
    "name": "ספרים",
    "description": "ספרים ומגזינים",
    "icon": "📚",
  },
  "sports": {
    "name": "ספורט",
    "description": "ציוד ספורט וכושר",
    "icon": "⚽",
  },
  "home_decor": {
    "name": "עיצוב הבית",
    "description": "ריהוט ואביזרים",
    "icon": "🏠",
  },
  "automotive": {
    "name": "רכב",
    "description": "אביזרים ותחזוקה",
    "icon": "🚗",
  },
  "baby": {
    "name": "תינוקות",
    "description": "מוצרי תינוקות",
    "icon": "👶",
  },
  "gifts": {
    "name": "מתנות",
    "description": "רעיונות למתנות",
    "icon": "🎁",
  },
  "birthday": {
    "name": "יום הולדת",
    "description": "מצרכים לעוגה וחד\"פ",
    "icon": "🎂",
  },
  "party": {
    "name": "מסיבה",
    "description": "אירוח ומסיבות",
    "icon": "🎉",
  },
  "wedding": {
    "name": "חתונה",
    "description": "הכנות לאירוע",
    "icon": "💍",
  },
  "picnic": {
    "name": "פיקניק",
    "description": "קמפינג וטיולים",
    "icon": "🧺",
  },
  "holiday": {
    "name": "שבת וחג",
    "description": "הכנות לשבת וחגים",
    "icon": "🕯️",
  },
  "other": {
    "name": "אחר",
    "description": "רשימה כללית",
    "icon": "📝",
  },
};

/// קבועי type - להשוואה ב-enum style
/// 
/// 🎯 שימוש: השוואות type-safe במקום strings
/// 
/// **דוגמאות שימוש:**
/// ```dart
/// // ✅ טוב - type safe
/// if (list.type == ListType.super_) { ... }
/// 
/// // ❌ רע - string literal
/// if (list.type == 'super') { ... }
/// 
/// // יצירת רשימה חדשה
/// final list = ShoppingList(
///   type: ListType.pharmacy,
///   // ...
/// );
/// ```
class ListType {
  static const String super_ = 'super';
  static const String pharmacy = 'pharmacy';
  static const String hardware = 'hardware';
  static const String clothing = 'clothing';
  static const String electronics = 'electronics';
  static const String pets = 'pets';
  static const String cosmetics = 'cosmetics';
  static const String stationery = 'stationery';
  static const String toys = 'toys';
  static const String books = 'books';
  static const String sports = 'sports';
  static const String homeDecor = 'home_decor';
  static const String automotive = 'automotive';
  static const String baby = 'baby';
  static const String gifts = 'gifts';
  static const String birthday = 'birthday';
  static const String party = 'party';
  static const String wedding = 'wedding';
  static const String picnic = 'picnic';
  static const String holiday = 'holiday';
  static const String other = 'other';
}

// ========================================
// מוצרים פופולריים
// ========================================

/// רשימת מוצרים פופולריים לחיפוש מהיר
///
/// 🎯 שימוש: חיפוש מהיר, המלצות, autocomplete
/// 📝 הערה: מוצרים שימושיים וחוזרים בקניות יומיומיות
/// 
/// **דוגמאות שימוש:**
/// ```dart
/// // רשימת כפתורים מהירים
/// for (final product in kPopularProducts)
///   ElevatedButton(
///     onPressed: () => search(product),
///     child: Text(product),
///   )
/// 
/// // בדיקה אם מוצר פופולרי
/// final isPopular = kPopularProducts.contains(productName);
/// ```
const List<String> kPopularProducts = [
  "חלב",
  "לחם",
  "ביצים",
  "אורז",
  "שמן זית",
  "פסטה",
  "עגבניות",
  "מלפפונים",
];

/// מוצרים פופולריים עם מטא-דאטה (אימוג'י, קטגוריה)
///
/// 🎯 שימוש: חיפוש חכם עם הצעות מעוצבות
/// 📝 הערה: כולל אימוג'י וקטגוריה לכל מוצר
/// 
/// **דוגמאות שימוש:**
/// ```dart
/// // בניית רשימת הצעות
/// for (final item in kPopularSearches)
///   ListTile(
///     leading: Text(item['icon']!),
///     title: Text(item['name']!),
///     subtitle: Text(item['category']!),
///     onTap: () => search(item['name']!),
///   )
/// 
/// // קבלת אימוג'י למוצר
/// final emoji = kPopularSearches
///   .firstWhere((item) => item['name'] == 'חלב')['icon'];
/// ```
const List<Map<String, String>> kPopularSearches = [
  {"name": "חלב", "icon": "🥛", "category": "מוצרי חלב"},
  {"name": "לחם", "icon": "🍞", "category": "מאפים"},
  {"name": "ביצים", "icon": "🥚", "category": "מזווה"},
  {"name": "עגבניות", "icon": "🍅", "category": "ירקות"},
  {"name": "מלפפונים", "icon": "🥒", "category": "ירקות"},
  {"name": "אורז", "icon": "🍚", "category": "מזווה"},
  {"name": "שמן זית", "icon": "🫒", "category": "מזווה"},
  {"name": "פסטה", "icon": "🍝", "category": "מזווה"},
];

// ========================================
// 💡 טיפים לשימוש
// ========================================
//
// 1. **העדף קבועים על strings קשיחים:**
//    ```dart
//    // ✅ טוב
//    if (location == kStorageLocations.keys.first) { ... }
//    
//    // ❌ רע
//    if (location == 'main_pantry') { ... }
//    ```
//
// 2. **תמיד השתמש ב-fallback:**
//    ```dart
//    final emoji = kCategoryEmojis[category] ?? '📦';
//    ```
//
// 3. **קישור לקבצים מתקדמים:**
//    - קטגוריות: category_config.dart (צבעים, עיצוב)
//    - פילטרים: filters_config.dart (טקסטים)
//    - מיקומים: LocationsProvider (מותאמים אישית)
//
