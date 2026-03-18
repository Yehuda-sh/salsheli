// 📄 lib/config/filters_config.dart
//
// 🗄️ Categories API - slim config class using shared validation
// 
// ✅ Extracted from 187-line manual data file
// ✅ Uses ConfigValidation mixin (eliminates future validation debt)
// ✅ Delegates data to filters_data.dart
//
// 🔗 Related: filters_data.dart, my_pantry_screen, base_config.dart

import 'base_config.dart';
import 'filters_data.dart';

/// 🗂️ Categories configuration API  
class FiltersConfig with ConfigValidation {
  FiltersConfig._();
  static final FiltersConfig _instance = FiltersConfig._();

  /// All category info (backward compatibility)
  static Map<String, CategoryInfo> get kCategoryInfo => CategoriesData.data;

  /// Category order for UI (backward compatibility)
  static List<String> get kCategoryOrder => CategoriesData.order;

  /// Synonyms mapping (backward compatibility)
  static Map<String, String> get kCategorySynonyms => CategoriesData.synonyms;

  /// Get category info by key - safe fallback to 'other'
  static CategoryInfo getCategoryInfo(String key) {
    _instance.ensureValid();
    return CategoriesData.data[key] ?? CategoriesData.data['other']!;
  }

  /// Resolve synonym to canonical key
  static String resolveCategory(String input) {
    _instance.ensureValid();
    
    // Direct key match
    if (CategoriesData.data.containsKey(input)) {
      return input;
    }
    
    // Synonym lookup
    final synonym = CategoriesData.synonyms[input];
    if (synonym != null && CategoriesData.data.containsKey(synonym)) {
      return synonym;
    }
    
    // Fallback to 'other'
    return 'other';
  }

  /// Check if category exists
  static bool isValidCategory(String key) {
    _instance.ensureValid();
    return CategoriesData.data.containsKey(key);
  }

  /// Get all category keys in UI order
  static List<String> getAllCategories() {
    _instance.ensureValid();
    return CategoriesData.order;
  }

  /// Backward compatibility functions
  static String hebrewCategoryToEnglish(String hebrewCategory) {
    return resolveCategory(hebrewCategory);
  }

  static String getCategoryEmoji(String key) {
    return getCategoryInfo(key).emoji;
  }

  /// ✅ Validation implementation
  @override
  void performValidation() {
    final data = CategoriesData.data;
    final order = CategoriesData.order;
    const synonyms = CategoriesData.synonyms;

    // 1. Check required keys exist
    const required = ['all', 'other'];
    for (final key in required) {
      if (!data.containsKey(key)) {
        throw AssertionError('FiltersConfig: Required category "$key" missing from data');
      }
    }

    // 2. Check order matches data keys
    final dataKeys = data.keys.toSet();
    final orderKeys = order.toSet();
    
    if (!dataKeys.containsAll(orderKeys) || !orderKeys.containsAll(dataKeys)) {
      throw AssertionError(
        'FiltersConfig: Order keys don\'t match data keys\n'
        'Data keys: $dataKeys\n'
        'Order keys: $orderKeys'
      );
    }

    // 3. Check 'all' first, 'other' last in order
    if (order.isNotEmpty) {
      if (order.first != 'all') {
        throw AssertionError('FiltersConfig: "all" must be first in order, found: ${order.first}');
      }
      if (order.last != 'other') {
        throw AssertionError('FiltersConfig: "other" must be last in order, found: ${order.last}');
      }
    }

    // 4. Check synonyms point to valid keys
    for (final entry in synonyms.entries) {
      if (!data.containsKey(entry.value)) {
        throw AssertionError(
          'FiltersConfig: Synonym "${entry.key}" points to non-existent category "${entry.value}"'
        );
      }
    }
  }
}