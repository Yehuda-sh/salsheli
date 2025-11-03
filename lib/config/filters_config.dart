// 📄 File: lib/config/filters_config.dart
//
// 🎯 Purpose: Configuration for inventory/pantry category filters
//
// Defines the available categories for filtering inventory items.
// Used by PantryFilters widget to filter items by category.
//
// Version: 1.1
// Updated: 03/11/2025
// Changes: Updated categories to match actual product JSON files

/// Available inventory categories for filtering
/// 
/// Categories match the product JSON files in assets/data/categories/:
/// - all: Show all items (no filter)
/// - coffee_tea: Coffee and tea products
/// - dairy: Milk products, cheese, yogurt, eggs
/// - fruits: Fresh and processed fruits
/// - meat_fish: Meat, poultry, fish, and seafood
/// - other: Miscellaneous products
/// - personal_hygiene: Personal care and hygiene products
/// - rice_pasta: Rice, pasta, and grain products
/// - spices_baking: Spices, herbs, and baking ingredients
/// - sweets_snacks: Sweets, snacks, and treats
/// - vegetables: Fresh and processed vegetables
const List<String> kCategories = [
  'all',
  'coffee_tea',
  'dairy',
  'fruits',
  'meat_fish',
  'other',
  'personal_hygiene',
  'rice_pasta',
  'spices_baking',
  'sweets_snacks',
  'vegetables',
];

/// Category display names in Hebrew
/// 
/// Labels match the category names used in product JSON files
const Map<String, String> kCategoryLabels = {
  'all': 'הכל',
  'coffee_tea': 'קפה ותה',
  'dairy': 'מוצרי חלב',
  'fruits': 'פירות',
  'meat_fish': 'בשר ודגים',
  'other': 'אחר',
  'personal_hygiene': 'טיפוח אישי',
  'rice_pasta': 'אורז ופסטה',
  'spices_baking': 'תבלינים ואפייה',
  'sweets_snacks': 'ממתקים וחטיפים',
  'vegetables': 'ירקות',
};

/// Get display label for a category
/// 
/// Returns the Hebrew label for the given category ID.
/// If category is not found, returns 'לא ידוע' (Unknown).
String getCategoryLabel(String categoryId) {
  return kCategoryLabels[categoryId] ?? 'לא ידוע';
}

/// Check if a category ID is valid
bool isValidCategory(String categoryId) {
  return kCategories.contains(categoryId);
}
