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
const Map<String, CategoryInfo> kCategoryInfo = {
  // === כללי ===
  'all': CategoryInfo('הכל', '📋'),
  'other': CategoryInfo('אחר', '📦'),
  'general': CategoryInfo('כללי', '📦'),

  // === מזון בסיסי ===
  'dairy': CategoryInfo('מוצרי חלב', '🥛'),
  'dairy_eggs': CategoryInfo('חלב וביצים', '🥛'),
  'vegetables': CategoryInfo('ירקות', '🥬'),
  'fruits': CategoryInfo('פירות', '🍎'),
  'vegetables_fruits': CategoryInfo('ירקות ופירות', '🥬'),
  'meat_fish': CategoryInfo('בשר ודגים', '🥩'),
  'rice_pasta': CategoryInfo('אורז ופסטה', '🍝'),
  'spices_baking': CategoryInfo('תבלינים ואפייה', '🧂'),
  'spices': CategoryInfo('תבלינים', '🧂'),
  'coffee_tea': CategoryInfo('קפה ותה', '☕'),
  'sweets_snacks': CategoryInfo('ממתקים וחטיפים', '🍬'),
  'snacks': CategoryInfo('חטיפים', '🍿'),

  // === בשר מפורט ===
  'beef': CategoryInfo('בקר', '🥩'),
  'chicken': CategoryInfo('עוף', '🍗'),
  'turkey': CategoryInfo('הודו', '🦃'),
  'lamb': CategoryInfo('טלה וכבש', '🐑'),
  'fish': CategoryInfo('דגים', '🐟'),
  'meat_substitutes': CategoryInfo('תחליפי בשר', '🌱'),

  // === מאפים ולחם ===
  'bakery': CategoryInfo('מאפים', '🥖'),
  'bread': CategoryInfo('לחמים', '🍞'),
  'bread_bakery': CategoryInfo('לחם ומאפים', '🍞'),
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
  'hygiene': CategoryInfo('היגיינה', '🚿'),
  'oral_care': CategoryInfo('טיפוח הפה', '🦷'),
  'cosmetics': CategoryInfo('קוסמטיקה וטיפוח', '💄'),
  'feminine_hygiene': CategoryInfo('היגיינה נשית', '🌸'),

  // === בית וניקיון ===
  'cleaning': CategoryInfo('מוצרי ניקיון', '🧹'),
  'cleaning_supplies': CategoryInfo('חומרי ניקיון', '🧽'),
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

/// סדר קטגוריות קבוע ל-Dropdown (UX עקבי)
/// 'all' תמיד ראשון, אחר כך לפי קבוצות לוגיות
const List<String> kCategoryOrder = [
  // === כללי (תמיד ראשון) ===
  'all',

  // === מזון בסיסי ===
  'dairy',
  'dairy_eggs',
  'vegetables',
  'fruits',
  'vegetables_fruits',
  'meat_fish',
  'rice_pasta',
  'spices_baking',
  'spices',
  'coffee_tea',
  'sweets_snacks',
  'snacks',

  // === בשר מפורט ===
  'beef',
  'chicken',
  'turkey',
  'lamb',
  'fish',
  'meat_substitutes',

  // === מאפים ולחם ===
  'bakery',
  'bread',
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
  'personal_hygiene',
  'hygiene',
  'oral_care',
  'cosmetics',
  'feminine_hygiene',

  // === בית וניקיון ===
  'cleaning',
  'cleaning_supplies',
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
  'general',
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
String getCategoryLabel(String categoryId) {
  return kCategoryInfo[categoryId]?.label ?? AppStrings.common.categoryUnknown;
}

/// מחזיר אמוג'י לקטגוריה
String getCategoryEmoji(String categoryId) {
  return kCategoryInfo[categoryId]?.emoji ?? '📦';
}

/// ממיר שם קטגוריה בעברית למפתח באנגלית
/// משמש לסינון כשה-JSON מכיל קטגוריות בעברית
/// כולל נורמליזציה: trim + החלפת רווחים כפולים
String? hebrewCategoryToEnglish(String hebrewCategory) {
  // 🔍 בדיקת כפילויות labels בפעם הראשונה (debug mode בלבד)
  if (kDebugMode) {
    ensureNoDuplicateLabels();
  }

  final normalized = hebrewCategory
      .trim()
      .replaceAll(RegExp(r'\s+'), ' '); // רווחים כפולים → רווח בודד
  return _hebrewToEnglish[normalized];
}
