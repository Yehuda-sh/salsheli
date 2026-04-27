// lib/config/filters_config.dart — Category API — resolve Hebrew/English category names, get emoji, validate keys

import 'base_config.dart';
import 'filters_data.dart';

/// 🗂️ Categories configuration API  
class FiltersConfig with ConfigValidation {
  FiltersConfig._();
  static final FiltersConfig _instance = FiltersConfig._();

  /// All category info — used by dropdowns/grids that iterate every category.
  static Map<String, CategoryInfo> get kCategoryInfo => CategoriesData.data;

  /// Get category info by key — safe fallback to 'other' if missing.
  static CategoryInfo getCategoryInfo(String key) {
    _instance.ensureValid();
    return CategoriesData.data[key] ?? CategoriesData.data['other']!;
  }

  /// Resolve a Hebrew category label or synonym to its canonical English key.
  /// Falls back to 'other' for unknown input.
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

  /// Translate a Hebrew category label to its canonical English key.
  /// Equivalent to [resolveCategory]; kept as an alias because most
  /// callsites pass Hebrew strings and the explicit name reads better.
  static String hebrewCategoryToEnglish(String hebrewCategory) {
    return resolveCategory(hebrewCategory);
  }

  /// Get the emoji for a category by canonical key.
  /// For Hebrew labels, wrap with [hebrewCategoryToEnglish] first.
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