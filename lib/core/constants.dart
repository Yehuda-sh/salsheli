// 📄 File: lib/core/constants.dart
//
// 🎯 מטרה: קבועים גלובליים לכל האפליקציה
//
// 📋 כולל:
// - סוגי רשימות קניות (ListType class)
//
// 🔗 קבצים קשורים:
// - lib/config/list_type_mappings.dart - מיפוי types לקטגוריות וחנויות
// - lib/config/category_config.dart - עיצוב מלא של קטגוריות (צבעים, אימוג'י)
// - lib/config/filters_config.dart - טקסטים לפילטרים (kCategories, kStatuses)
//
// 📝 הערות:
// - קבצי Config אחרים מכילים קבועים ספציפיים יותר
// - קובץ זה מכיל רק constants בסיסיים שמשותפים לכל המערכת
//
// Version: 3.1
// Last Updated: 06/10/2025

// ========================================
// מיפויי אימוג'י וטקסטים
// ========================================

/// מיפוי category ID לאימוג'י
/// 
/// 🎯 שימוש: הצגת אימוג'י לפי קטגוריה
/// 📝 הערה: משמש ב-widgets שצריכים אימוג'י בלבד ללא Config מלא
const Map<String, String> kCategoryEmojis = {
  'dairy': '🥛',
  'meat': '🥩',
  'produce': '🥦',
  'bakery': '🥐',
  'beverages': '🥤',
  'dry_goods': '📦',
  'household': '🧽',
  'frozen': '🧊',
  'snacks': '🍿',
  'condiments': '🧂',
  'other': '🛒',
};

/// מיקומי אחסון נפוצים
/// 
/// 🎯 שימוש: Map של מיקומי אחסון עם שמות ואימוג'י
/// 📝 הערה: משמש ב-storage_location_manager
const Map<String, Map<String, String>> kStorageLocations = {
  'refrigerator': {'name': 'מקרר', 'emoji': '❄️'},
  'freezer': {'name': 'מקפיא', 'emoji': '🧊'},
  'pantry': {'name': 'מזווה', 'emoji': '📦'},
  'cabinet': {'name': 'ארון מטבח', 'emoji': '🚪'},
  'shelf_top': {'name': 'מדף עליון', 'emoji': '📏'},
  'shelf_bottom': {'name': 'מדף תחתון', 'emoji': '📍'},
  'drawer': {'name': 'מגירה', 'emoji': '🗄️'},
  'other': {'name': 'אחר', 'emoji': '📍'},
};

/// מיפוי list types לשמות, אימוג'י ותיאורים
/// 
/// 🎯 שימוש: יצירת רשימות, תצוגה של סוגים
/// 📝 הערה: משמש ב-create_list_dialog
const Map<String, Map<String, String>> kListTypes = {
  'super': {
    'name': 'סופרמרקט',
    'icon': '🛒',
    'description': 'קניות יומיומיות ומזון'
  },
  'pharmacy': {
    'name': 'בית מרקחת',
    'icon': '💊',
    'description': 'תרופות ומוצרי בריאות'
  },
  'hardware': {
    'name': 'חומרי בניין',
    'icon': '🔨',
    'description': 'כלים וחומרי בניין'
  },
  'clothing': {
    'name': 'ביגוד',
    'icon': '👕',
    'description': 'בגדים ואביזרים'
  },
  'electronics': {
    'name': 'אלקטרוניקה',
    'icon': '📱',
    'description': 'מכשירים חשמליים'
  },
  'pets': {
    'name': 'חיות מחמד',
    'icon': '🐕',
    'description': 'מזון וצרכים לחיות'
  },
  'cosmetics': {
    'name': 'קוסמטיקה',
    'icon': '💄',
    'description': 'מוצרי יופי וטיפוח'
  },
  'stationery': {
    'name': 'כלי כתיבה',
    'icon': '✏️',
    'description': 'מוצרי משרד וכתיבה'
  },
  'toys': {
    'name': 'צעצועים',
    'icon': '🧸',
    'description': 'משחקים וצעצועים'
  },
  'books': {
    'name': 'ספרים',
    'icon': '📚',
    'description': 'ספרים וחומרי קריאה'
  },
  'sports': {
    'name': 'ספורט',
    'icon': '⚽',
    'description': 'ציוד ספורט וכושר'
  },
  'home_decor': {
    'name': 'עיצוב הבית',
    'icon': '🏠',
    'description': 'מוצרים לעיצוב הבית'
  },
  'automotive': {
    'name': 'רכב',
    'icon': '🚗',
    'description': 'צרכים לרכב'
  },
  'baby': {
    'name': 'תינוקות',
    'icon': '👶',
    'description': 'מוצרים לתינוקות'
  },
  'gifts': {
    'name': 'מתנות',
    'icon': '🎁',
    'description': 'רעיונות למתנות'
  },
  'birthday': {
    'name': 'יום הולדת',
    'icon': '🎂',
    'description': 'צרכים ליום הולדת'
  },
  'party': {
    'name': 'מסיבה',
    'icon': '🎉',
    'description': 'צרכים למסיבה'
  },
  'wedding': {
    'name': 'חתונה',
    'icon': '💒',
    'description': 'צרכים לחתונה'
  },
  'picnic': {
    'name': 'פיקניק',
    'icon': '🧺',
    'description': 'צרכים לטיול'
  },
  'holiday': {
    'name': 'חג',
    'icon': '✨',
    'description': 'קניות לחג'
  },
  'other': {
    'name': 'אחר',
    'icon': '📝',
    'description': 'סוג אחר'
  },
};

// ========================================
// סוגי רשימות קניות
// ========================================

/// קבועי type - להשוואה ב-enum style
/// 
/// 🎯 שימוש: השוואות type-safe במקום strings
/// 📝 הערה: משמש ב-list_type_mappings.dart ובמודל ShoppingList
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
/// 
/// // שימוש ב-ListTypeMappings
/// final categories = ListTypeMappings.getCategoriesForType(ListType.clothing);
/// final stores = ListTypeMappings.getStoresForType(ListType.super_);
/// ```
class ListType {
  // מניעת יצירת instances
  const ListType._();

  // קניות יומיומיות
  static const String super_ = 'super';
  static const String pharmacy = 'pharmacy';
  
  // קניות מיוחדות
  static const String hardware = 'hardware';
  static const String clothing = 'clothing';
  static const String electronics = 'electronics';
  static const String pets = 'pets';
  static const String cosmetics = 'cosmetics';
  static const String stationery = 'stationery';
  static const String toys = 'toys';
  static const String books = 'books';
  static const String sports = 'sports';
  
  // קטגוריות נוספות
  static const String homeDecor = 'home_decor';
  static const String automotive = 'automotive';
  static const String baby = 'baby';
  
  // אירועים
  static const String gifts = 'gifts';
  static const String birthday = 'birthday';
  static const String party = 'party';
  static const String wedding = 'wedding';
  static const String picnic = 'picnic';
  static const String holiday = 'holiday';
  
  // כללי
  static const String other = 'other';

  /// רשימת כל הסוגים הזמינים
  /// 
  /// 🎯 שימוש: לולאות, validations, dropdowns
  /// 
  /// **דוגמה:**
  /// ```dart
  /// // בדיקה אם type תקין
  /// if (!ListType.allTypes.contains(type)) {
  ///   throw Exception('Invalid list type: $type');
  /// }
  /// 
  /// // Dropdown של כל הסוגים
  /// DropdownButton<String>(
  ///   items: ListType.allTypes.map((type) =>
  ///     DropdownMenuItem(value: type, child: Text(type))
  ///   ).toList(),
  /// )
  /// ```
  static const List<String> allTypes = [
    super_,
    pharmacy,
    hardware,
    clothing,
    electronics,
    pets,
    cosmetics,
    stationery,
    toys,
    books,
    sports,
    homeDecor,
    automotive,
    baby,
    gifts,
    birthday,
    party,
    wedding,
    picnic,
    holiday,
    other,
  ];

  /// בדיקה אם type תקין
  /// 
  /// **דוגמה:**
  /// ```dart
  /// if (ListType.isValid('super')) { ... }  // true
  /// if (ListType.isValid('invalid')) { ... }  // false
  /// ```
  static bool isValid(String type) => allTypes.contains(type);
}

// ========================================
// 💡 טיפים לשימוש
// ========================================
//
// 1. **השתמש ב-ListType במקום strings:**
//    ```dart
//    // ✅ טוב
//    final type = ListType.super_;
//    
//    // ❌ רע
//    final type = 'super';
//    ```
//
// 2. **קישור לקבצי Config:**
//    - קטגוריות: lib/config/category_config.dart
//    - פילטרים: lib/config/filters_config.dart
//    - מיפויים: lib/config/list_type_mappings.dart
//
// 3. **Validation:**
//    ```dart
//    if (!ListType.isValid(userInput)) {
//      throw Exception('Invalid type');
//    }
//    ```
//
