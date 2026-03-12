// 📄 lib/config/filters_config.dart
//
// הגדרות סינון קטגוריות למזווה - 41 קטגוריות עם תרגום לעברית ואמוג'י.
// כולל מיפוי וריאציות (Synonyms) ותאימות לאחור (Aliases).
//
// 🔗 Related: my_pantry_screen, StorageLocationManager, AppStrings

import '../l10n/app_strings.dart';

/// מידע על קטגוריה: שם (מהתרגום) + אמוג'י
class CategoryInfo {
  final String label;
  final String emoji;
  const CategoryInfo(this.label, this.emoji);
}

/// כל הקטגוריות הזמינות (מפתח EN → מידע)
/// המידע נמשך ישירות מ-AppStrings לטובת תמיכה עתידית ב-i18n
final Map<String, CategoryInfo> kCategoryInfo = {
  'all': CategoryInfo(AppStrings.categories.all, '📋'),
  'other': CategoryInfo(AppStrings.categories.other, '📦'),
  'dairy': CategoryInfo(AppStrings.categories.dairy, '🥛'),
  'vegetables': CategoryInfo(AppStrings.categories.vegetables, '🥬'),
  'fruits': CategoryInfo(AppStrings.categories.fruits, '🍎'),
  'meat_fish': CategoryInfo(AppStrings.categories.meatFish, '🥩'),
  'rice_pasta': CategoryInfo(AppStrings.categories.ricePasta, '🍝'),
  'spices': CategoryInfo(AppStrings.categories.spices, '🧂'),
  'coffee_tea': CategoryInfo(AppStrings.categories.coffeeTea, '☕'),
  'sweets_snacks': CategoryInfo(AppStrings.categories.sweetsSnacks, '🍬'),
  'beef': CategoryInfo(AppStrings.categories.beef, '🥩'),
  'chicken': CategoryInfo(AppStrings.categories.chicken, '🍗'),
  'turkey': CategoryInfo(AppStrings.categories.turkey, '🦃'),
  'lamb': CategoryInfo(AppStrings.categories.lamb, '🐑'),
  'fish': CategoryInfo(AppStrings.categories.fish, '🐟'),
  'meat_substitutes': CategoryInfo(AppStrings.categories.meatSubstitutes, '🌱'),
  'bread_bakery': CategoryInfo(AppStrings.categories.breadBakery, '🍞'),
  'cookies_sweets': CategoryInfo(AppStrings.categories.cookiesSweets, '🍪'),
  'cakes': CategoryInfo(AppStrings.categories.cakes, '🎂'),
  'canned': CategoryInfo(AppStrings.categories.canned, '🥫'),
  'legumes_grains': CategoryInfo(AppStrings.categories.legumesGrains, '🫘'),
  'cereals': CategoryInfo(AppStrings.categories.cereals, '🥣'),
  'dried_fruits': CategoryInfo(AppStrings.categories.driedFruits, '🍇'),
  'nuts_seeds': CategoryInfo(AppStrings.categories.nutsSeeds, '🥜'),
  'beverages': CategoryInfo(AppStrings.categories.beverages, '🥤'),
  'oils_sauces': CategoryInfo(AppStrings.categories.oilsSauces, '🫒'),
  'sweet_spreads': CategoryInfo(AppStrings.categories.sweetSpreads, '🍯'),
  'frozen': CategoryInfo(AppStrings.categories.frozen, '🧊'),
  'ready_salads': CategoryInfo(AppStrings.categories.readySalads, '🥗'),
  'dairy_substitutes': CategoryInfo(AppStrings.categories.dairySubstitutes, '🥛'),
  'hygiene': CategoryInfo(AppStrings.categories.hygiene, '🚿'),
  'oral_care': CategoryInfo(AppStrings.categories.oralCare, '🦷'),
  'cosmetics': CategoryInfo(AppStrings.categories.cosmetics, '💄'),
  'feminine_hygiene': CategoryInfo(AppStrings.categories.feminineHygiene, '🌸'),
  'cleaning': CategoryInfo(AppStrings.categories.cleaning, '🧹'),
  'home_products': CategoryInfo(AppStrings.categories.homeProducts, '🏠'),
  'disposable': CategoryInfo(AppStrings.categories.disposable, '🥤'),
  'garden': CategoryInfo(AppStrings.categories.garden, '🌱'),
  'pet_food': CategoryInfo(AppStrings.categories.petFood, '🐕'),
  'otc_medicine': CategoryInfo(AppStrings.categories.otcMedicine, '💊'),
  'vitamins': CategoryInfo(AppStrings.categories.vitamins, '💪'),
  'first_aid': CategoryInfo(AppStrings.categories.firstAid, '🩹'),
  'baby_products': CategoryInfo(AppStrings.categories.babyProducts, '👶'),
  'accessories': CategoryInfo(AppStrings.categories.accessories, '🛒'),
};

/// מיפוי קטגוריות שאוחדו - תאימות אחורה
const Map<String, String> kCategoryAliases = {
  'general': 'other',
  'dairy_eggs': 'dairy',
  'vegetables_fruits': 'vegetables',
  'spices_baking': 'spices',
  'snacks': 'sweets_snacks',
  'bakery': 'bread_bakery',
  'bread': 'bread_bakery',
  'personal_hygiene': 'hygiene',
  'cleaning_supplies': 'cleaning',
};

/// מיפוי וריאציות עברית נוספות מ-JSON
const Map<String, String> kHebrewSynonyms = {
  'משקאות אלכוהוליים': 'beverages',
  'אלכוהול': 'beverages',
  'שתייה': 'beverages',
  'שתיה': 'beverages',
  'גלידות': 'frozen',
  'קפואים': 'frozen',
  'כלי מטבח': 'home_products',
  'נייר טואלט': 'home_products',
  'חלב': 'dairy',
  'ביצים': 'dairy',
  'גבינות': 'dairy',
  'לחם': 'bread_bakery',
  'מאפים': 'bread_bakery',
  'ירקות ופירות': 'vegetables',
  'חטיפים': 'sweets_snacks',
  'ממתקים': 'sweets_snacks',
  'תבלינים': 'spices',
  'חומרי ניקיון': 'cleaning',
  'ניקוי': 'cleaning',
  'כביסה': 'cleaning',
  'שונות': 'other',
  'כללי': 'other',
};

/// סדר קטגוריות קבוע ל-UI
const List<String> kCategoryOrder = [
  'all',
  'dairy',
  'vegetables',
  'fruits',
  'meat_fish',
  'rice_pasta',
  'spices',
  'coffee_tea',
  'sweets_snacks',
  'beef',
  'chicken',
  'turkey',
  'lamb',
  'fish',
  'meat_substitutes',
  'bread_bakery',
  'cookies_sweets',
  'cakes',
  'canned',
  'legumes_grains',
  'cereals',
  'dried_fruits',
  'nuts_seeds',
  'beverages',
  'oils_sauces',
  'sweet_spreads',
  'frozen',
  'ready_salads',
  'dairy_substitutes',
  'hygiene',
  'oral_care',
  'cosmetics',
  'feminine_hygiene',
  'cleaning',
  'home_products',
  'disposable',
  'garden',
  'pet_food',
  'otc_medicine',
  'vitamins',
  'first_aid',
  'baby_products',
  'accessories',
  'other',
];

/// רשימת מפתחות סופית ל-Dropdown
/// ✅ תיקון אזהרה: שימוש ב-Tear-off במקום ב-Lambda
final List<String> kCategories = List.unmodifiable(kCategoryOrder.where(kCategoryInfo.containsKey));

/// מיפוי עברית → אנגלית (נוצר פעם אחת בשימוש הראשון)
final Map<String, String> _hebrewToEnglish = {for (final entry in kCategoryInfo.entries) entry.value.label: entry.key};

/// פונקציות עזר לקבלת מידע
String resolveCategory(String categoryId) => kCategoryAliases[categoryId] ?? categoryId;

String getCategoryLabel(String categoryId) {
  final resolved = resolveCategory(categoryId);
  return kCategoryInfo[resolved]?.label ?? AppStrings.common.categoryUnknown;
}

String getCategoryEmoji(String categoryId) {
  final resolved = resolveCategory(categoryId);
  return kCategoryInfo[resolved]?.emoji ?? '📦';
}

/// המרת שם קטגוריה למפתח אנגלי (סלחני לרווחים ורישיות)
String? hebrewCategoryToEnglish(String category) {
  final normalized = category.trim().replaceAll(RegExp(r'\s+'), ' ');
  final lowercase = normalized.toLowerCase();

  // 1. בדיקה אם זה כבר מפתח אנגלי
  if (kCategoryInfo.containsKey(lowercase)) return lowercase;

  // 2. בדיקה במפה ההפוכה (עברית)
  final fromLabels = _hebrewToEnglish[normalized];
  if (fromLabels != null) return fromLabels;

  // 3. בדיקה במילים נרדפות
  return kHebrewSynonyms[normalized];
}
