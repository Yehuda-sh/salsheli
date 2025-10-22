// 📄 File: lib/core/constants.dart
//
// 🎯 מטרה: קבועים גלובליים לכל האפליקציה
//
// 📋 כולל:
// - FirestoreCollections - שמות collections ב-Firestore
// - FirestoreFields - שמות שדות משותפים ב-Firestore
// - ListType - סוגי רשימות קניות
// - UI Maps - אימוג'י, מיקומים, types
// - Validation Limits - גבולות ערכים
//
// 🔗 קבצים קשורים:
// - lib/core/ui_constants.dart - קבועי UI (צבעים, מרווחים, גדלים)
// - lib/config/list_type_mappings.dart - מיפוי types לקטגוריות וחנויות
// - lib/config/filters_config.dart - טקסטים לפילטרים וקטגוריות (kCategories, kStatuses)
// - lib/config/pantry_config.dart - הגדרות מלאי ומזווה
//
// 📝 הערות:
// - קבצי Config אחרים מכילים קבועים ספציפיים יותר
// - קובץ זה מכיל רק constants בסיסיים שמשותפים לכל המערכת
//
// Version: 4.0
// Last Updated: 17/10/2025
// Changes: ✅ השלמת FirestoreCollections, ✅ הוספת FirestoreFields, ✅ שיפור תיעוד

// ========================================
// Firestore Collections
// ========================================

/// שמות Collections ב-Firestore
/// 
/// 🎯 שימוש: שמירה על consistency בשמות הקולקציות
/// 📝 הערה: משמש בכל ה-Repositories
/// ⚠️ חשוב: **תמיד** השתמש בקבועים אלה, לעולם לא ב-hardcoded strings!
/// 
/// **דוגמה:**
/// ```dart
/// // ✅ טוב - constant (type-safe)
/// await _firestore
///   .collection(FirestoreCollections.shoppingLists)
///   .where(FirestoreFields.householdId, isEqualTo: householdId)
///   .get();
/// 
/// // ❌ רע - hardcoded strings (שגיאות אפשריות!)
/// await _firestore
///   .collection('shopping_lists')  // אם תעשה טעות כתיב - קריסה!
///   .where('household_id', isEqualTo: householdId)
///   .get();
/// ```
class FirestoreCollections {
  // מניעת יצירת instances
  const FirestoreCollections._();

  // ========================================
  // Core Collections - קולקציות ליבה
  // ========================================

  /// 👥 משתמשים - נתוני פרופיל, הגדרות, preferences
  static const String users = 'users';

  /// 🏠 משקי בית - קבוצות משפחתיות/שיתופיות
  /// ⚠️ חשוב: כל המשתמשים שייכים ל-household אחד או יותר
  static const String households = 'households';

  // ========================================
  // Shopping & Lists - קניות ורשימות
  // ========================================

  /// 🛒 רשימות קניות - רשימות פעילות וארכיון
  static const String shoppingLists = 'shopping_lists';

  /// 📋 תבניות רשימות - תבניות מערכת ואישיות
  /// 🔒 is_system=true רק ע"י Admin SDK!
  static const String templates = 'templates';

  // ========================================
  // Inventory & Products - מלאי ומוצרים
  // ========================================

  /// 📦 מלאי - פריטים במזווה/מקרר/מקפיא
  static const String inventory = 'inventory';

  /// 🏷️ מוצרים - קטלוג מוצרים (shared database)
  static const String products = 'products';

  /// 📍 מיקומים - מיקומי אחסון מותאמים אישית
  /// 📝 לדוגמה: "מדף עליון - מטבח", "מגירה 2 - מקרר"
  static const String locations = 'locations';

  /// 🧠 זיכרון מיקומי מוצרים - למידה אוטומטית של מיקומים
  /// 📝 המערכת זוכרת איפה כל מוצר בדרך כלל מאוחסן
  static const String productLocationMemory = 'product_location_memory';

  // ========================================
  // Receipts & Analysis - קבלות וניתוח
  // ========================================

  /// 🧾 קבלות - קבלות סרוקות ונתוני קנייה
  static const String receipts = 'receipts';

  // ========================================
  // Habits & Settings - הרגלים והגדרות
  // ========================================

  /// ✨ הרגלים - מעקב אחר הרגלי קנייה וצריכה
  static const String habits = 'habits';

  /// ⚙️ הגדרות - העדפות אפליקציה והגדרות מערכת
  /// 📝 לדוגמה: תזכורות, נוטיפיקציות, תצוגות ברירת מחדל
  static const String settings = 'settings';

  // ========================================
  // Utility Methods - פונקציות עזר
  // ========================================

  /// רשימת כל ה-collections הזמינים
  /// 
  /// 🎯 שימוש: validations, testing, admin tools
  static const List<String> allCollections = [
    users,
    households,
    shoppingLists,
    templates,
    inventory,
    products,
    locations,
    productLocationMemory,
    receipts,
    habits,
    settings,
  ];

  /// בדיקה אם collection name תקין
  /// 
  /// **דוגמה:**
  /// ```dart
  /// if (FirestoreCollections.isValid('users')) { ... }  // true
  /// if (FirestoreCollections.isValid('invalid')) { ... }  // false
  /// ```
  static bool isValid(String collection) => allCollections.contains(collection);
}

// ========================================
// Firestore Fields
// ========================================

/// שמות שדות משותפים ב-Firestore
/// 
/// 🎯 שימוש: שמירה על consistency בשמות השדות
/// ⚠️ חשוב: **כל query חייב** לכלול household_id filtering!
/// 🔒 Security: Firestore Rules מסתמכות על שמות אלה
/// 
/// **דוגמה:**
/// ```dart
/// // ✅ טוב - constants + household_id filtering
/// await _firestore
///   .collection(FirestoreCollections.inventory)
///   .where(FirestoreFields.householdId, isEqualTo: householdId)
///   .where(FirestoreFields.isActive, isEqualTo: true)
///   .orderBy(FirestoreFields.createdAt, descending: true)
///   .get();
/// 
/// // ❌ רע - hardcoded + חסר household_id!
/// await _firestore
///   .collection('inventory')
///   .where('is_active', isEqualTo: true)
///   .get();  // ⚠️ Security risk! יחזיר נתונים מכל ה-households!
/// ```
class FirestoreFields {
  // מניעת יצירת instances
  const FirestoreFields._();

  // ========================================
  // Security & Multi-Tenancy - אבטחה ו-multi-tenancy
  // ========================================

  /// 🏠 household_id - מזהה משק בית
  /// ⚠️ **חובה בכל query!** למניעת גישה לנתונים של households אחרים
  /// 🔒 Security Rules בודקות שדה זה
  /// 
  /// **דוגמה נכונה:**
  /// ```dart
  /// // ✅ תמיד סנן לפי household_id
  /// .where(FirestoreFields.householdId, isEqualTo: userContext.currentHouseholdId)
  /// ```
  static const String householdId = 'household_id';

  /// 👤 user_id - מזהה משתמש (יוצר/בעלים)
  /// 📝 לדוגמה: מי יצר רשימה, מי הוסיף פריט
  static const String userId = 'user_id';

  // ========================================
  // Timestamps - חותמות זמן
  // ========================================

  /// 📅 created_at - תאריך יצירה
  /// 🔄 @TimestampConverter() אוטומטי במודלים
  static const String createdAt = 'created_at';

  /// 🔄 updated_at - תאריך עדכון אחרון
  /// 📝 מתעדכן אוטומטית בכל שינוי
  static const String updatedAt = 'updated_at';

  /// 🗑️ deleted_at - תאריך מחיקה (soft delete)
  /// 📝 null = פעיל, timestamp = נמחק
  static const String deletedAt = 'deleted_at';

  // ========================================
  // Status & Flags - סטטוס ודגלים
  // ========================================

  /// ✅ is_active - האם הרשומה פעילה
  /// 📝 false = archived/disabled
  static const String isActive = 'is_active';

  /// 🔒 is_system - האם זו רשומת מערכת
  /// ⚠️ רק Admin SDK יכול ליצור is_system=true!
  /// 📝 לדוגמה: system templates
  static const String isSystem = 'is_system';

  /// ✅ is_completed - האם הושלם
  /// 📝 לדוגמה: רשימת קניות, משימה
  static const String isCompleted = 'is_completed';

  /// ⭐ is_favorite - האם מועדף
  /// 📝 לדוגמה: מוצרים מועדפים, רשימות חשובות
  static const String isFavorite = 'is_favorite';

  // ========================================
  // Common Data Fields - שדות נתונים נפוצים
  // ========================================

  /// 📝 name - שם (כללי)
  static const String name = 'name';

  /// 📋 description - תיאור
  static const String description = 'description';

  /// 🏷️ type - סוג/קטגוריה
  static const String type = 'type';

  /// 🎨 color - צבע (hex או שם)
  static const String color = 'color';

  /// 🔢 quantity - כמות
  static const String quantity = 'quantity';

  /// 💰 price - מחיר
  static const String price = 'price';

  /// 📍 location - מיקום
  static const String location = 'location';

  /// 🏷️ category - קטגוריה (למוצרים)
  /// 📝 לדוגמה: 'dairy', 'meat', 'produce'
  static const String category = 'category';

  /// 📦 product_name - שם מוצר (למלאי)
  /// 📝 לדוגמה: 'חלב 3%', 'עגבניות'
  static const String productName = 'product_name';

  // ========================================
  // Utility Methods - פונקציות עזר
  // ========================================

  /// רשימת כל השדות המשותפים
  /// 
  /// 🎯 שימוש: validations, testing, documentation
  static const List<String> allFields = [
    householdId,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    isActive,
    isSystem,
    isCompleted,
    isFavorite,
    name,
    description,
    type,
    color,
    quantity,
    price,
    location,
    category,
    productName,
  ];

  /// בדיקה אם שם שדה תקין
  /// 
  /// **דוגמה:**
  /// ```dart
  /// if (FirestoreFields.isValid('household_id')) { ... }  // true
  /// if (FirestoreFields.isValid('invalid_field')) { ... }  // false
  /// ```
  static bool isValid(String field) => allFields.contains(field);
}

// ========================================
// מיפויי אימוג'י וטקסטים
// ========================================

/// מיפוי category ID לאימוג'י
/// 
/// 🎯 שימוש: הצגת אימוג'י לפי קטגוריה
/// 📝 הערה: משמש ב-widgets שצריכים אימוג'י בלבד ללא Config מלא
const Map<String, String> kCategoryEmojis = const {
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
const Map<String, Map<String, String>> kStorageLocations = const {
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
const Map<String, Map<String, String>> kListTypes = const {
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
// Onboarding - גבולות ערכים
// ========================================

/// גודל משפחה - גבולות min/max
/// 
/// 🎯 שימוש: validation ב-onboarding flow
const int kMinFamilySize = 1;
const int kMaxFamilySize = 10;

/// תקציב חודשי - גבולות min/max (₪)
/// 
/// 🎯 שימוש: validation ב-onboarding flow
const double kMinMonthlyBudget = 500.0;
const double kMaxMonthlyBudget = 20000.0;

/// גילאי ילדים תקינים
/// 
/// 🎯 שימוש: validation בהעדפות onboarding
/// 📝 הערה: משמש ב-OnboardingData._filterValidAges()
const Set<String> kValidChildrenAges = {
  'babies',   // תינוקות (0-2)
  'toddlers', // פעוטות (2-5)
  'children', // ילדים (5-12)
  'teens',    // בני נוער (12+)
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
/// // ❌ רע - string literal (שגיאות אפשריות!)
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
// 1. **השתמש תמיד ב-Constants (לא hardcoded strings!):**
//    ```dart
//    // ✅ טוב
//    await _firestore
//      .collection(FirestoreCollections.shoppingLists)
//      .where(FirestoreFields.householdId, isEqualTo: householdId)
//      .get();
//    
//    // ❌ רע
//    await _firestore
//      .collection('shopping_lists')  // שגיאות כתיב אפשריות!
//      .where('household_id', isEqualTo: householdId)
//      .get();
//    ```
//
// 2. **Security Rule #1: תמיד סנן לפי household_id!**
//    ```dart
//    // ✅ חובה בכל query!
//    .where(FirestoreFields.householdId, isEqualTo: userContext.currentHouseholdId)
//    ```
//
// 3. **קישור לקבצי Config אחרים:**
//    - UI: lib/core/ui_constants.dart
//    - פילטרים וקטגוריות: lib/config/filters_config.dart
//    - מיפויים: lib/config/list_type_mappings.dart
//    - מלאי: lib/config/pantry_config.dart
//
// 4. **Validation Examples:**
//    ```dart
//    // Collections
//    if (!FirestoreCollections.isValid(collectionName)) {
//      throw Exception('Invalid collection');
//    }
//    
//    // Fields
//    if (!FirestoreFields.isValid(fieldName)) {
//      throw Exception('Invalid field');
//    }
//    
//    // List Types
//    if (!ListType.isValid(userInput)) {
//      throw Exception('Invalid type');
//    }
//    ```
//
