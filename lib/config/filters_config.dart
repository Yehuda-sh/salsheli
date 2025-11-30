// 📄 lib/config/filters_config.dart
//
// 🎯 הגדרות סינון קטגוריות למזווה
// 📦 43 קטגוריות + תרגום לעברית + אמוג'י
// 🔗 משמש ב: my_pantry_screen.dart → PantryFilters widget (Dropdown סינון)
//
// 💡 איך לראות בממשק:
//    1. פתח את מסך "המזווה שלי" (My Pantry)
//    2. בראש המסך יש Dropdown עם רשימת קטגוריות
//    3. בחר קטגוריה → מסנן את הפריטים לפי הקטגוריה הנבחרת

/// מידע על קטגוריה: שם בעברית + אמוג'י
class CategoryInfo {
  final String label;
  final String emoji;
  const CategoryInfo(this.label, this.emoji);
}

/// כל הקטגוריות הזמינות (מפתח EN → מידע)
const Map<String, CategoryInfo> kCategoryInfo = {
  // === כללי ===
  'all': CategoryInfo('הכל', '📋'),
  'other': CategoryInfo('אחר', '📦'),

  // === מזון בסיסי ===
  'dairy': CategoryInfo('מוצרי חלב', '🥛'),
  'vegetables': CategoryInfo('ירקות', '🥬'),
  'fruits': CategoryInfo('פירות', '🍎'),
  'meat_fish': CategoryInfo('בשר ודגים', '🥩'),
  'rice_pasta': CategoryInfo('אורז ופסטה', '🍝'),
  'spices_baking': CategoryInfo('תבלינים ואפייה', '🧂'),
  'coffee_tea': CategoryInfo('קפה ותה', '☕'),
  'sweets_snacks': CategoryInfo('ממתקים וחטיפים', '🍬'),

  // === בשר מפורט ===
  'beef': CategoryInfo('בקר', '🥩'),
  'chicken': CategoryInfo('עוף', '🍗'),
  'turkey': CategoryInfo('הודו', '🦃'),
  'lamb': CategoryInfo('טלה וכבש', '🐑'),
  'fish': CategoryInfo('דגים', '🐟'),
  'meat_substitutes': CategoryInfo('תחליפי בשר', '🌱'),

  // === מאפים ולחם ===
  'bakery': CategoryInfo('מאפים', '🥖'),
  'cookies_sweets': CategoryInfo('עוגיות ומתוקים', '🍪'),
  'cakes': CategoryInfo('עוגות', '🎂'),

  // === שימורים ויבשים ===
  'canned': CategoryInfo('שימורים', '🥫'),
  'legumes_grains': CategoryInfo('קטניות ודגנים', '🫘'),
  'cereals': CategoryInfo('דגנים', '🥣'),
  'dried_fruits': CategoryInfo('פירות יבשים', '🍇'),
  'nuts_seeds': CategoryInfo('אגוזים וגרעינים', '🥜'),

  // === משקאות ורטבים ===
  'beverages': CategoryInfo('משקאות', '🥤'),
  'oils_sauces': CategoryInfo('שמנים ורטבים', '🫒'),
  'sweet_spreads': CategoryInfo('ממרחים מתוקים', '🍯'),

  // === קפואים ומוכנים ===
  'frozen': CategoryInfo('קפואים', '🧊'),
  'ready_salads': CategoryInfo('סלטים מוכנים', '🥗'),
  'dairy_substitutes': CategoryInfo('תחליפי חלב', '🥛'),

  // === היגיינה וטיפוח ===
  'personal_hygiene': CategoryInfo('היגיינה אישית', '🧴'),
  'oral_care': CategoryInfo('טיפוח הפה', '🦷'),
  'cosmetics': CategoryInfo('קוסמטיקה וטיפוח', '💄'),
  'feminine_hygiene': CategoryInfo('היגיינה נשית', '🌸'),

  // === בית וניקיון ===
  'cleaning': CategoryInfo('מוצרי ניקיון', '🧹'),
  'home_products': CategoryInfo('מוצרי בית', '🏠'),
  'disposable': CategoryInfo('חד פעמי', '🥤'),
  'garden': CategoryInfo('מוצרי גינה', '🌱'),
  'pet_food': CategoryInfo('מזון לחיות מחמד', '🐕'),

  // === תרופות ובריאות ===
  'otc_medicine': CategoryInfo('תרופות ללא מרשם', '💊'),
  'vitamins': CategoryInfo('ויטמינים ותוספי תזונה', '💪'),
  'first_aid': CategoryInfo('עזרה ראשונה', '🩹'),
  'baby_products': CategoryInfo('מוצרי תינוקות', '👶'),

  // === אחר ===
  'accessories': CategoryInfo('מוצרים נלווים', '🛒'),
};

/// רשימת מפתחות הקטגוריות (לשימוש ב-Dropdown)
List<String> get kCategories => kCategoryInfo.keys.toList();

/// מיפוי עברית → אנגלית (לסינון מול JSON)
final Map<String, String> _hebrewToEnglish = {
  for (final entry in kCategoryInfo.entries) entry.value.label: entry.key,
};

/// מחזיר שם בעברית לקטגוריה
String getCategoryLabel(String categoryId) {
  return kCategoryInfo[categoryId]?.label ?? 'לא ידוע';
}

/// מחזיר אמוג'י לקטגוריה
String getCategoryEmoji(String categoryId) {
  return kCategoryInfo[categoryId]?.emoji ?? '📦';
}

/// ממיר שם קטגוריה בעברית למפתח באנגלית
/// משמש לסינון כשה-JSON מכיל קטגוריות בעברית
String? hebrewCategoryToEnglish(String hebrewCategory) {
  return _hebrewToEnglish[hebrewCategory];
}
