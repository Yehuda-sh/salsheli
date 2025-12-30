// 📄 lib/config/stores_config.dart
//
// הגדרות חנויות נתמכות - סופרמרקטים, מיניקמטים, בתי מרקחת וחנויות משקאות.
// כולל קטגוריזציה לפי סוג חנות ופונקציות עזר לולידציה.
//
// 🔗 Related: onboarding_data, StoreCategory

/// Store category types
enum StoreCategory {
  supermarket,
  minimarket,
  pharmacy,
  liquorStore,
}

/// Configuration for supported stores
class StoresConfig {
  StoresConfig._(); // Prevent instantiation

  // ========================================
  // Store Categories
  // ========================================

  /// Supermarkets - full product range
  static const List<String> supermarkets = [
    'שופרסל',
    'רמי לוי',
    'מגה',
    'חצי חינם',
    'ויקטורי',
  ];

  /// Minimarkets - convenience stores
  static const List<String> minimarkets = [
    'AM:PM',
  ];

  /// Pharmacies - health & hygiene
  static const List<String> pharmacies = [
    'סופר פארם',
  ];

  /// Liquor stores - wine & alcohol
  static const List<String> liquorStores = [
    'יינות ביתן',
  ];

  /// List of all supported stores (combined)
  static const List<String> allStores = [
    ...supermarkets,
    ...minimarkets,
    ...pharmacies,
    ...liquorStores,
  ];

  // ========================================
  // Validation & Helpers
  // ========================================

  /// Check if a store name is valid
  static bool isValid(String store) {
    return allStores.contains(store);
  }

  /// Get category for a store
  ///
  /// Returns null if store not found
  static StoreCategory? getCategory(String store) {
    if (supermarkets.contains(store)) return StoreCategory.supermarket;
    if (minimarkets.contains(store)) return StoreCategory.minimarket;
    if (pharmacies.contains(store)) return StoreCategory.pharmacy;
    if (liquorStores.contains(store)) return StoreCategory.liquorStore;
    return null;
  }
}
