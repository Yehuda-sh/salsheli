// 📄 File: lib/repositories/constants/repository_constants.dart
//
// 🎯 Purpose: Firestore collection names and field names
// - Centralized constants for Firestore operations
// - Easier to maintain and refactor

class FirestoreCollections {
  static const String receipts = 'receipts';
  static const String shoppingLists = 'shopping_lists';
  static const String inventory = 'inventory';
  static const String products = 'products';
  static const String users = 'users';
  static const String households = 'households';
  static const String habitPreferences = 'habit_preferences';
  static const String customLocations = 'custom_locations';
}

class FirestoreFields {
  // Common fields
  static const String id = 'id';
  static const String householdId = 'household_id';
  static const String createdDate = 'created_date';
  static const String updatedDate = 'updated_date';
  
  // Receipt fields
  static const String storeName = 'store_name';
  static const String purchaseDate = 'purchase_date';
  static const String totalAmount = 'total_amount';
  static const String items = 'items';
  static const String date = 'date';
  
  // Shopping List fields
  static const String name = 'name';
  static const String createdBy = 'created_by';
  static const String status = 'status';
  
  // Inventory fields
  static const String productId = 'product_id';
  static const String quantity = 'quantity';
  static const String expiryDate = 'expiry_date';
  
  // Product fields
  static const String category = 'category';
  static const String barcode = 'barcode';
  static const String brand = 'brand';
  
  // Habit Preference fields
  static const String preferredProduct = 'preferred_product';
  static const String lastPurchased = 'last_purchased';
  
  // Location fields
  static const String locationName = 'location_name';
  static const String createdAt = 'created_at';
}
