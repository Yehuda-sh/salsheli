// 📄 lib/config/filters_data.dart
//
// 🗄️ Categories data only - extracted from filters_config.dart
// 
// ✅ Single responsibility: category data and mappings
// ❌ No API methods here - see filters_config.dart
//
// 🔗 Related: filters_config.dart, my_pantry_screen

import '../l10n/app_strings.dart';

/// מידע על קטגוריה: שם (מהתרגום) + אמוג'י
class CategoryInfo {
  final String label;
  final String emoji;
  const CategoryInfo(this.label, this.emoji);
}

/// Categories data - auto-generated list order
class CategoriesData {
  CategoriesData._();

  /// All categories data (key → info)
  static final Map<String, CategoryInfo> data = {
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
    'cosmetics': CategoryInfo(AppStrings.categories.cosmetics, '💄'),
    'cleaning': CategoryInfo(AppStrings.categories.cleaning, '🧽'),
    'vitamins': CategoryInfo(AppStrings.categories.vitamins, '💊'),
    'baby_products': CategoryInfo(AppStrings.categories.babyProducts, '🍼'),
    'pet_food': CategoryInfo(AppStrings.categories.petFood, '🐕'),
    'otc_medicine': CategoryInfo(AppStrings.categories.otcMedicine, '💊'),
    'first_aid': CategoryInfo(AppStrings.categories.firstAid, '🏥'),
  };

  /// Fixed UI order (auto-generated from data keys, 'all' first, 'other' last)
  static List<String> get order {
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
    
    return result;
  }

  /// Synonyms mapping (Hebrew → English key)
  static const Map<String, String> synonyms = {
    'חלב': 'dairy',
    'חלבי': 'dairy',
    'גבינה': 'dairy',
    'יוגורט': 'dairy',
    'ירקות': 'vegetables',
    'ירק': 'vegetables',
    'פירות': 'fruits',
    'פרי': 'fruits',
    'בשר': 'meat_fish',
    'עוף': 'chicken',
    'דג': 'fish',
    'דגים': 'fish',
    'לחם': 'bread_bakery',
    'מאפה': 'bread_bakery',
    'ממתקים': 'sweets_snacks',
    'חטיפים': 'sweets_snacks',
    'משקאות': 'beverages',
    'שתייה': 'beverages',
    'קפה': 'coffee_tea',
    'תה': 'coffee_tea',
    'תבלינים': 'spices',
    'אורז': 'rice_pasta',
    'פסטה': 'rice_pasta',
    'שימורים': 'canned',
    'קפוא': 'frozen',
    'ניקיון': 'cleaning',
    'היגיינה': 'hygiene',
    'תינוק': 'baby_products',
    'חיות מחמד': 'pet_food',
    'כלים': 'other',
    'שונות': 'other',
    'כללי': 'other',
  };
}