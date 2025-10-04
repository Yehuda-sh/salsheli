// 📄 File: lib/core/constants.dart
// תיאור: קבועים גלובליים לכל האפליקציה
//
// כולל:
// - רשימות ברירת מחדל (חנויות, קטגוריות, מיקומי אחסון)
// - הגדרות כלליות (גבולות, מגבלות)
// - קבועי UI (ריווחים, גדלים)
// - מיפוי אמוג'י לקטגוריות

// ========================================
// חנויות וקטגוריות
// ========================================

/// רשימת חנויות ברירת מחדל
const List<String> kPredefinedStores = <String>[
  "שופרסל",
  "רמי לוי",
  "יוחננוף",
  "ויקטורי",
  "טיב טעם",
  "אושר עד",
];

/// רשימת קטגוריות ברירת מחדל
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
/// - key: מזהה ייחודי באנגלית
/// - name: שם בעברית לתצוגה
/// - emoji: אמוג'י לייצוג ויזואלי
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

/// מיפוי קטגוריות לאמוג'י
///
/// משמש לתצוגה ויזואלית של מוצרים לפי קטגוריה
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
const int kMinFamilySize = 1;

/// גודל משפחה מקסימלי
const int kMaxFamilySize = 20;

/// תקציב חודשי מינימלי (בשקלים)
const double kMinMonthlyBudget = 100.0;

/// תקציב חודשי מקסימלי (בשקלים)
const double kMaxMonthlyBudget = 50000.0;

// ========================================
// קבועי UI
// ========================================

/// ריווח קטן בין אלמנטים
const double kSpacingSmall = 8.0;

/// ריווח בינוני בין אלמנטים
const double kSpacingMedium = 16.0;

/// ריווח גדול בין אלמנטים
const double kSpacingLarge = 24.0;

/// גובה כפתור סטנדרטי
const double kButtonHeight = 48.0;

/// רדיוס פינות סטנדרטי
const double kBorderRadius = 12.0;

// ========================================
// סוגי רשימות קניות
// ========================================

/// סוגי רשימות קניות זמינים
///
/// כל סוג מוגדר עם:
/// - key: מזהה ייחודי (super/pharmacy/other)
/// - name: שם בעברית לתצוגה
/// - description: תיאור קצר
/// - icon: אמוג'י לייצוג ויזואלי
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
  "other": {"name": "אחר", "description": "רשימה כללית", "icon": "📝"},
};

/// קבועי type - להשוואה ב-enum style
class ListType {
  static const String super_ = 'super';
  static const String pharmacy = 'pharmacy';
  static const String other = 'other';
}
