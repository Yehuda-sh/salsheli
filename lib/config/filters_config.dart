// 📄 lib/config/filters_config.dart
//
// הגדרות סינון קטגוריות למזווה - 53 קטגוריות עם תרגום לעברית ואמוג'י.
// משמש ב-PantryFilters (Dropdown סינון) ובכל מקום שצריך תרגום קטגוריה.
//
// 🔗 Related: my_pantry_screen, StorageLocationManager, CategoryInfo

import 'package:flutter/foundation.dart';

import '../l10n/app_strings.dart';

/// מידע על קטגוריה: שם בעברית + אמוג'י
class CategoryInfo {
  final String label;
  final String emoji;
  const CategoryInfo(this.label, this.emoji);
}

/// כל הקטגוריות הזמינות (מפתח EN → מידע)
/// ✅ v2: צומצם מ-53 ל-41 קטגוריות (איחוד כפילויות)
const Map<String, CategoryInfo> kCategoryInfo = {
  // === כללי ===
  'all': CategoryInfo('הכל', '📋'),
  'other': CategoryInfo('אחר', '📦'),
  // ❌ general - אוחד ל-other

  // === מזון בסיסי ===
  'dairy': CategoryInfo('מוצרי חלב', '🥛'),
  // ❌ dairy_eggs - אוחד ל-dairy
  'vegetables': CategoryInfo('ירקות', '🥬'),
  'fruits': CategoryInfo('פירות', '🍎'),
  // ❌ vegetables_fruits - מיותר, יש vegetables + fruits
  'meat_fish': CategoryInfo('בשר ודגים', '🥩'),
  'rice_pasta': CategoryInfo('אורז ופסטה', '🍝'),
  'spices': CategoryInfo('תבלינים', '🧂'),
  // ❌ spices_baking - אוחד ל-spices
  'coffee_tea': CategoryInfo('קפה ותה', '☕'),
  'sweets_snacks': CategoryInfo('ממתקים וחטיפים', '🍬'),
  // ❌ snacks - אוחד ל-sweets_snacks

  // === בשר מפורט ===
  'beef': CategoryInfo('בקר', '🥩'),
  'chicken': CategoryInfo('עוף', '🍗'),
  'turkey': CategoryInfo('הודו', '🦃'),
  'lamb': CategoryInfo('טלה וכבש', '🐑'),
  'fish': CategoryInfo('דגים', '🐟'),
  'meat_substitutes': CategoryInfo('תחליפי בשר', '🌱'),

  // === מאפים ולחם ===
  'bread_bakery': CategoryInfo('לחם ומאפים', '🍞'),
  // ❌ bakery, bread - אוחדו ל-bread_bakery
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
  'hygiene': CategoryInfo('היגיינה', '🚿'),
  // ❌ personal_hygiene - אוחד ל-hygiene
  'oral_care': CategoryInfo('טיפוח הפה', '🦷'),
  'cosmetics': CategoryInfo('קוסמטיקה וטיפוח', '💄'),
  'feminine_hygiene': CategoryInfo('היגיינה נשית', '🌸'),

  // === בית וניקיון ===
  'cleaning': CategoryInfo('מוצרי ניקיון', '🧹'),
  // ❌ cleaning_supplies - אוחד ל-cleaning
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

// ═══════════════════════════════════════════════════════════════════════════
// BACKWARD COMPATIBILITY - מיפוי IDs ישנים לחדשים
// ═══════════════════════════════════════════════════════════════════════════

/// מיפוי קטגוריות שאוחדו - תאימות אחורה
/// IDs ישנים ימופו אוטומטית ל-ID החדש
const Map<String, String> kCategoryAliases = {
  'general': 'other',
  'dairy_eggs': 'dairy',
  'vegetables_fruits': 'vegetables', // או fruits - בחרנו vegetables
  'spices_baking': 'spices',
  'snacks': 'sweets_snacks',
  'bakery': 'bread_bakery',
  'bread': 'bread_bakery',
  'personal_hygiene': 'hygiene',
  'cleaning_supplies': 'cleaning',
};

/// מחזיר את ה-ID הקנוני (אחרי פתרון aliases)
String resolveCategory(String categoryId) {
  return kCategoryAliases[categoryId] ?? categoryId;
}

// ═══════════════════════════════════════════════════════════════════════════
// HEBREW SYNONYMS - מיפוי וריאציות עברית מ-JSON
// ═══════════════════════════════════════════════════════════════════════════

/// מיפוי שמות עברית נוספים (שלא ב-kCategoryInfo) לקטגוריות קיימות
/// מכסה וריאציות מקבצי JSON ב-assets/data/list_types/
const Map<String, String> kHebrewSynonyms = {
  // === משקאות ואלכוהול ===
  'משקאות אלכוהוליים': 'beverages',
  'יינות': 'beverages',
  'בירות': 'beverages',
  'אלכוהול': 'beverages',
  'מיצים': 'beverages',
  'שתייה': 'beverages',

  // === קפואים ===
  'גלידות': 'frozen',
  'גלידות וקינוחים קפואים': 'frozen',
  'קינוחים קפואים': 'frozen',
  'ירקות קפואים': 'frozen',
  'מוצרים קפואים': 'frozen',

  // === מוצרי בית ===
  'מוצרי נייר': 'home_products',
  'כלי מטבח': 'home_products',
  'כלים חד פעמיים': 'disposable',
  'נייר טואלט': 'home_products',
  'מגבות נייר': 'home_products',

  // === חלב וביצים (וריאציות) ===
  'חלב': 'dairy',
  'ביצים': 'dairy',
  'חלב וביצים': 'dairy',
  'גבינות': 'dairy',
  'יוגורטים': 'dairy',
  'מוצרי חלב וביצים': 'dairy',

  // === לחם ומאפים (וריאציות) ===
  'לחם': 'bread_bakery',
  'מאפים': 'bread_bakery',
  'לחמים': 'bread_bakery',
  'פיתות': 'bread_bakery',
  'חלות': 'bread_bakery',

  // === ירקות ופירות (וריאציות) ===
  'ירקות ופירות': 'vegetables',
  'פירות וירקות': 'vegetables',
  'ירקות טריים': 'vegetables',
  'פירות טריים': 'fruits',

  // === חטיפים וממתקים (וריאציות) ===
  'חטיפים': 'sweets_snacks',
  'ממתקים': 'sweets_snacks',
  'שוקולד': 'sweets_snacks',
  'שוקולדים': 'sweets_snacks',
  'ביסקוויטים': 'sweets_snacks',
  'חטיפים מלוחים': 'sweets_snacks',

  // === תבלינים (וריאציות) ===
  'תבלינים ואפייה': 'spices',
  'אבקות אפייה': 'spices',
  'מוצרי אפייה': 'spices',

  // === היגיינה (וריאציות) ===
  'היגיינה אישית': 'hygiene',
  'טיפוח': 'hygiene',
  'סבונים': 'hygiene',
  'שמפו': 'hygiene',

  // === ניקיון (וריאציות) ===
  'חומרי ניקיון': 'cleaning',
  'ניקיון': 'cleaning',
  'כביסה': 'cleaning',
  'אבקת כביסה': 'cleaning',

  // === בריאות ===
  'מזון בריאות': 'other', // אין קטגוריה ייעודית
  'מוצרים אורגניים': 'other', // אין קטגוריה ייעודית
  'טבק': 'other', // אין קטגוריה ייעודית

  // === כללי (וריאציות) ===
  'כללי': 'other',
  'שונות': 'other',
  'מוצרים שונים': 'other',
};

/// סדר קטגוריות קבוע ל-Dropdown (UX עקבי)
/// 'all' תמיד ראשון, אחר כך לפי קבוצות לוגיות
/// ✅ v2: 41 קטגוריות (אחרי איחוד כפילויות)
const List<String> kCategoryOrder = [
  // === כללי (תמיד ראשון) ===
  'all',

  // === מזון בסיסי ===
  'dairy',
  'vegetables',
  'fruits',
  'meat_fish',
  'rice_pasta',
  'spices',
  'coffee_tea',
  'sweets_snacks',

  // === בשר מפורט ===
  'beef',
  'chicken',
  'turkey',
  'lamb',
  'fish',
  'meat_substitutes',

  // === מאפים ולחם ===
  'bread_bakery',
  'cookies_sweets',
  'cakes',

  // === שימורים ויבשים ===
  'canned',
  'legumes_grains',
  'cereals',
  'dried_fruits',
  'nuts_seeds',

  // === משקאות ורטבים ===
  'beverages',
  'oils_sauces',
  'sweet_spreads',

  // === קפואים ומוכנים ===
  'frozen',
  'ready_salads',
  'dairy_substitutes',

  // === היגיינה וטיפוח ===
  'hygiene',
  'oral_care',
  'cosmetics',
  'feminine_hygiene',

  // === בית וניקיון ===
  'cleaning',
  'home_products',
  'disposable',
  'garden',
  'pet_food',

  // === תרופות ובריאות ===
  'otc_medicine',
  'vitamins',
  'first_aid',
  'baby_products',

  // === אחר (תמיד אחרון) ===
  'accessories',
  'other', // ✅ 'other' תמיד אחרון (catch-all)
];

/// רשימת מפתחות הקטגוריות (לשימוש ב-Dropdown)
/// משתמש בסדר קבוע, מסנן רק קטגוריות שקיימות ב-kCategoryInfo
List<String> get kCategories =>
    kCategoryOrder.where((k) => kCategoryInfo.containsKey(k)).toList();

/// מיפוי עברית → אנגלית (לסינון מול JSON)
/// ⚠️ בדיקת כפילויות בזמן פיתוח - ראה assert למטה
final Map<String, String> _hebrewToEnglish = {
  for (final entry in kCategoryInfo.entries) entry.value.label: entry.key,
};

/// 🔍 בדיקת כפילויות labels (רצה פעם אחת באתחול)
/// אם יש שתי קטגוריות עם אותו label בעברית - יזרוק שגיאה
bool _duplicatesChecked = false;
void ensureNoDuplicateLabels() {
  if (_duplicatesChecked) return;
  _duplicatesChecked = true;

  final labels = <String, String>{};
  for (final entry in kCategoryInfo.entries) {
    final label = entry.value.label;
    if (labels.containsKey(label)) {
      assert(false,
        'כפילות label בקטגוריות! '
        'Label: "$label" - '
        'קטגוריה 1: ${labels[label]}, '
        'קטגוריה 2: ${entry.key}',
      );
    }
    labels[label] = entry.key;
  }
}

/// מחזיר שם בעברית לקטגוריה
/// ✅ תומך ב-aliases (IDs ישנים שאוחדו)
String getCategoryLabel(String categoryId) {
  final resolved = resolveCategory(categoryId);
  return kCategoryInfo[resolved]?.label ?? AppStrings.common.categoryUnknown;
}

/// מחזיר אמוג'י לקטגוריה
/// ✅ תומך ב-aliases (IDs ישנים שאוחדו)
String getCategoryEmoji(String categoryId) {
  final resolved = resolveCategory(categoryId);
  return kCategoryInfo[resolved]?.emoji ?? '📦';
}

/// ממיר שם קטגוריה בעברית למפתח באנגלית
/// משמש לסינון כשה-JSON מכיל קטגוריות בעברית
/// כולל נורמליזציה: trim + החלפת רווחים כפולים
///
/// סדר חיפוש:
/// 1. labels מ-kCategoryInfo (מיפוי ישיר)
/// 2. kHebrewSynonyms (וריאציות ושמות מקבצי JSON)
/// 3. null (יופנה ל-'other' על ידי הקורא)
String? hebrewCategoryToEnglish(String hebrewCategory) {
  // 🔍 בדיקת כפילויות labels בפעם הראשונה (debug mode בלבד)
  if (kDebugMode) {
    ensureNoDuplicateLabels();
  }

  final normalized = hebrewCategory
      .trim()
      .replaceAll(RegExp(r'\s+'), ' '); // רווחים כפולים → רווח בודד

  // 1️⃣ חיפוש ב-labels של kCategoryInfo
  final fromLabels = _hebrewToEnglish[normalized];
  if (fromLabels != null) return fromLabels;

  // 2️⃣ חיפוש ב-kHebrewSynonyms (וריאציות נוספות)
  final fromSynonyms = kHebrewSynonyms[normalized];
  if (fromSynonyms != null) return fromSynonyms;

  // 3️⃣ לא נמצא - יחזיר null (הקורא יחליט אם להשתמש ב-'other')
  if (kDebugMode) {
    debugPrint('⚠️ hebrewCategoryToEnglish: לא נמצא מיפוי ל-"$normalized"');
  }
  return null;
}
