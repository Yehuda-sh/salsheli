// 📄 File: lib/config/stores_config.dart
//
// 🏪 Stores Configuration
// 
// Defines available stores in the app with categorization and validation logic
//
// Categories:
// - Supermarkets: full-size stores with all products
// - Minimarkets: convenience stores
// - Pharmacies: health & hygiene products
// - Liquor Stores: wine & alcohol
//
// Used by:
// - onboarding_data.dart - validates preferred stores
//
// Version: 2.0
// Created: 29/10/2025
// Last Updated: 03/11/2025

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

  /// Get category display name (Hebrew)
  static String getCategoryDisplayName(StoreCategory category) {
    switch (category) {
      case StoreCategory.supermarket:
        return 'סופרמרקט';
      case StoreCategory.minimarket:
        return 'מינימרקט';
      case StoreCategory.pharmacy:
        return 'בית מרקחת';
      case StoreCategory.liquorStore:
        return 'חנות משקאות';
    }
  }

  /// Get stores by category
  static List<String> getStoresByCategory(StoreCategory category) {
    switch (category) {
      case StoreCategory.supermarket:
        return supermarkets;
      case StoreCategory.minimarket:
        return minimarkets;
      case StoreCategory.pharmacy:
        return pharmacies;
      case StoreCategory.liquorStore:
        return liquorStores;
    }
  }

  /// Get store display name (for UI)
  /// 
  /// Currently returns the same name, but can be extended
  /// to add icons, format, or translate to English
  static String getDisplayName(String store) {
    return store;
  }
}
