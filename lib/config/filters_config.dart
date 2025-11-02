// 📄 File: lib/config/filters_config.dart
//
// 🎯 Purpose: Configuration for inventory/pantry category filters
//
// Defines the available categories for filtering inventory items.
// Used by PantryFilters widget to filter items by category.
//
// Version: 1.0
// Created: 02/11/2025

/// Available inventory categories for filtering
/// 
/// Categories are based on common household product types:
/// - all: Show all items (no filter)
/// - dairy: Milk products, cheese, yogurt, etc.
/// - meat: Meat, chicken, fish
/// - vegetables: Fresh vegetables
/// - fruits: Fresh fruits
/// - bakery: Bread, pastries, baked goods
/// - dry_goods: Pasta, rice, canned goods
/// - cleaning: Cleaning products
/// - toiletries: Personal hygiene products
/// - frozen: Frozen foods
/// - beverages: Drinks (water, juice, soda)
const List<String> kCategories = [
  'all',
  'dairy',
  'meat',
  'vegetables',
  'fruits',
  'bakery',
  'dry_goods',
  'cleaning',
  'toiletries',
  'frozen',
  'beverages',
];

/// Category display names in Hebrew
const Map<String, String> kCategoryLabels = {
  'all': 'הכל',
  'dairy': 'חלב וביצים',
  'meat': 'בשר ודגים',
  'vegetables': 'ירקות',
  'fruits': 'פירות',
  'bakery': 'לחם ומאפים',
  'dry_goods': 'מוצרים יבשים',
  'cleaning': 'חומרי ניקיון',
  'toiletries': 'טואלטיקה',
  'frozen': 'קפואים',
  'beverages': 'משקאות',
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
