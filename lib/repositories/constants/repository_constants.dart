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
  
  // Shopping List fields
  static const String name = 'name';
  static const String createdBy = 'created_by';
  static const String status = 'status';
  
  // Inventory fields
  static const String productId = 'product_id';
  static const String quantity = 'quantity';
  static const String expiryDate = 'expiry_date';
}
