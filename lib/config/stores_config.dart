// 📄 File: lib/config/stores_config.dart
//
// 🏪 Stores Configuration
// 
// Defines available stores in the app and validation logic
//
// Used by:
// - onboarding_data.dart - validates preferred stores
//
// Version: 1.0
// Created: 29/10/2025
// Last Updated: 29/10/2025

/// Configuration for supported stores
class StoresConfig {
  StoresConfig._(); // Prevent instantiation

  /// List of all supported stores
  static const List<String> allStores = [
    'שופרסל',
    'רמי לוי',
    'מגה',
    'יינות ביתן',
    'ויקטורי',
    'AM:PM',
    'חצי חינם',
    'סופר פארם',
  ];

  /// Check if a store name is valid
  static bool isValid(String store) {
    return allStores.contains(store);
  }

  /// Get store display name (for UI)
  static String getDisplayName(String store) {
    return store; // Currently just returns the same name
  }
}
