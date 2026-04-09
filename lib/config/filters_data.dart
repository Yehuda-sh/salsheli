// 📄 lib/config/filters_data.dart
//
// 🗄️ Categories data only - extracted from filters_config.dart
//
// ✅ Single responsibility: category data and mappings
// ✅ Lazy labels: CategoryInfo.label resolved via callback → locale-safe
// ❌ No API methods here - see filters_config.dart
//
// 🔗 Related: filters_config.dart, my_pantry_screen

import '../l10n/app_strings.dart';

/// מידע על קטגוריה: שם (מהתרגום) + אמוג'י
/// label is resolved lazily so it updates on locale switch
class CategoryInfo {
  final String Function() _labelFn;
  final String emoji;
  CategoryInfo(this._labelFn, this.emoji);

  String get label => _labelFn();
}

/// Categories data - auto-generated list order
class CategoriesData {
  CategoriesData._();

  /// All categories data (key → info)
  static final Map<String, CategoryInfo> data = {
    'all': CategoryInfo(() => AppStrings.categories.all, '📋'),
    'other': CategoryInfo(() => AppStrings.categories.other, '🏷️'),
    'dairy': CategoryInfo(() => AppStrings.categories.dairy, '🥛'),
    'vegetables': CategoryInfo(() => AppStrings.categories.vegetables, '🥬'),
    'fruits': CategoryInfo(() => AppStrings.categories.fruits, '🍎'),
    'meat_fish': CategoryInfo(() => AppStrings.categories.meatFish, '🥩'),
    'rice_pasta': CategoryInfo(() => AppStrings.categories.ricePasta, '🍝'),
    'spices': CategoryInfo(() => AppStrings.categories.spices, '🧂'),
    'coffee_tea': CategoryInfo(() => AppStrings.categories.coffeeTea, '☕'),
    'sweets_snacks': CategoryInfo(() => AppStrings.categories.sweetsSnacks, '🍬'),
    'beef': CategoryInfo(() => AppStrings.categories.beef, '🐄'),
    'chicken': CategoryInfo(() => AppStrings.categories.chicken, '🍗'),
    'turkey': CategoryInfo(() => AppStrings.categories.turkey, '🦃'),
    'lamb': CategoryInfo(() => AppStrings.categories.lamb, '🐑'),
    'fish': CategoryInfo(() => AppStrings.categories.fish, '🐟'),
    'meat_substitutes': CategoryInfo(() => AppStrings.categories.meatSubstitutes, '🌱'),
    'bread_bakery': CategoryInfo(() => AppStrings.categories.breadBakery, '🍞'),
    'cookies_sweets': CategoryInfo(() => AppStrings.categories.cookiesSweets, '🍪'),
    'cakes': CategoryInfo(() => AppStrings.categories.cakes, '🎂'),
    'canned': CategoryInfo(() => AppStrings.categories.canned, '🥫'),
    'legumes_grains': CategoryInfo(() => AppStrings.categories.legumesGrains, '🫘'),
    'cereals': CategoryInfo(() => AppStrings.categories.cereals, '🥣'),
    'dried_fruits': CategoryInfo(() => AppStrings.categories.driedFruits, '🍇'),
    'nuts_seeds': CategoryInfo(() => AppStrings.categories.nutsSeeds, '🥜'),
    'beverages': CategoryInfo(() => AppStrings.categories.beverages, '🥤'),
    'oils_sauces': CategoryInfo(() => AppStrings.categories.oilsSauces, '🫒'),
    'sweet_spreads': CategoryInfo(() => AppStrings.categories.sweetSpreads, '🍯'),
    'frozen': CategoryInfo(() => AppStrings.categories.frozen, '🧊'),
    'ready_salads': CategoryInfo(() => AppStrings.categories.readySalads, '🥗'),
    'dairy_substitutes': CategoryInfo(() => AppStrings.categories.dairySubstitutes, '🌾'),
    'hygiene': CategoryInfo(() => AppStrings.categories.hygiene, '🧴'),
    'cosmetics': CategoryInfo(() => AppStrings.categories.cosmetics, '💄'),
    'cleaning': CategoryInfo(() => AppStrings.categories.cleaning, '🧽'),
    'vitamins': CategoryInfo(() => AppStrings.categories.vitamins, '💊'),
    'baby_products': CategoryInfo(() => AppStrings.categories.babyProducts, '🍼'),
    'pet_food': CategoryInfo(() => AppStrings.categories.petFood, '🐕'),
    'otc_medicine': CategoryInfo(() => AppStrings.categories.otcMedicine, '🩹'),
    'first_aid': CategoryInfo(() => AppStrings.categories.firstAid, '🏥'),
  };

  /// Fixed UI order (auto-generated from data keys, 'all' first, 'other' last)
  static final List<String> order = _buildOrder();

  static List<String> _buildOrder() {
    final keys = data.keys.toList();
    final result = <String>[];

    // 'all' always first
    if (keys.contains('all')) {
      result.add('all');
      keys.remove('all');
    }

    // 'other' always last
    if (keys.contains('other')) {
      keys.remove('other');
    }

    // Sort remaining alphabetically
    keys.sort();
    result.addAll(keys);

    // Add 'other' last
    if (data.containsKey('other')) {
      result.add('other');
    }

    return List.unmodifiable(result);
  }

  /// Synonyms mapping (Hebrew → English key)
  /// ⚠️ Matched by exact key, NOT substring! Use full category names.
  static const Map<String, String> synonyms = {
    // חלב
    'חלב': 'dairy',
    'חלבי': 'dairy',
    'גבינה': 'dairy',
    'יוגורט': 'dairy',
    'מוצרי חלב': 'dairy',
    // תחליפי חלב
    'תחליפי חלב': 'dairy_substitutes',
    // ירקות
    'ירקות': 'vegetables',
    'ירק': 'vegetables',
    'פירות וירקות': 'vegetables',
    // פירות
    'פירות': 'fruits',
    'פרי': 'fruits',
    'פירות יבשים': 'dried_fruits',
    // בשר ודגים
    'בשר': 'meat_fish',
    'בשר ודגים': 'meat_fish',
    'עוף': 'chicken',
    'דג': 'fish',
    'דגים': 'fish',
    // תחליפי בשר
    'תחליפי בשר': 'meat_substitutes',
    // לחם ומאפים
    'לחם': 'bread_bakery',
    'מאפה': 'bread_bakery',
    'לחם ומאפים': 'bread_bakery',
    // ממתקים
    'ממתקים': 'sweets_snacks',
    'חטיפים': 'sweets_snacks',
    'ממתקים וחטיפים': 'sweets_snacks',
    // משקאות
    'משקאות': 'beverages',
    'שתייה': 'beverages',
    // קפה ותה
    'קפה': 'coffee_tea',
    'תה': 'coffee_tea',
    'קפה ותה': 'coffee_tea',
    // תבלינים
    'תבלינים': 'spices',
    'תבלינים ואפייה': 'spices',
    // אורז ופסטה
    'אורז': 'rice_pasta',
    'פסטה': 'rice_pasta',
    'אורז ופסטה': 'rice_pasta',
    // דגנים וקטניות
    'דגנים': 'cereals',
    'קטניות': 'legumes_grains',
    'קטניות ודגנים': 'legumes_grains',
    // שימורים
    'שימורים': 'canned',
    // קפואים
    'קפוא': 'frozen',
    'קפואים': 'frozen',
    // ניקיון והיגיינה
    'ניקיון': 'cleaning',
    'מוצרי ניקיון': 'cleaning',
    'היגיינה': 'hygiene',
    'היגיינה אישית': 'hygiene',
    'מוצרי בית': 'cleaning',
    // קוסמטיקה וטיפוח
    'קוסמטיקה': 'cosmetics',
    'קוסמטיקה וטיפוח': 'cosmetics',
    'איפור': 'cosmetics',
    'טיפוח': 'cosmetics',
    // פארם ורפואה
    'פארם': 'otc_medicine',
    'תרופות ללא מרשם': 'otc_medicine',
    'מוצרי עזר רפואיים': 'first_aid',
    'עזרה ראשונה': 'first_aid',
    // ויטמינים
    'ויטמינים ותוספי תזונה': 'vitamins',
    'ויטמינים': 'vitamins',
    // גילוח והיגיינה נשית
    'מוצרי גילוח': 'hygiene',
    'היגיינה נשית': 'hygiene',
    'טיפוח הפה': 'hygiene',
    // שיער
    'אביזרי שיער': 'cosmetics',
    // מזון בריאות
    'מזון בריאות': 'other',
    // תינוקות וחיות
    'תינוק': 'baby_products',
    'מוצרי תינוקות': 'baby_products',
    'חיות מחמד': 'pet_food',
    'מזון לחיות מחמד': 'pet_food',
    // קטגוריות חדשות (מ-supermarket.json)
    'אגוזים וגרעינים': 'nuts_seeds',
    'שמנים ורטבים': 'oils_sauces',
    'ממרחים מתוקים': 'sweet_spreads',
    'סלטים מוכנים': 'ready_salads',
    // כללי
    'כלים': 'other',
    'שונות': 'other',
    'כללי': 'other',
    'אחר': 'other',
  };
}