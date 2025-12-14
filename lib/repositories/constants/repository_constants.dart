// 📄 File: lib/repositories/constants/repository_constants.dart
//
// 🎯 Purpose: Firestore collection names and field names
// - Centralized constants for Firestore operations
// - Easier to maintain and refactor
//
// 🏗️ Database Structure:
//   /users/{userId}/
//     ├── private_lists/{listId}      ← רשימות פרטיות
//     ├── notifications/{notifId}
//     ├── pending_invites/{inviteId}
//     └── saved_contacts/{contactId}
//
//   /households/{householdId}/
//     ├── info
//     ├── members/{memberId}
//     ├── inventory/{itemId}          ← מזווה משותפת
//     ├── receipts/{receiptId}
//     ├── shared_lists/{listId}       ← רשימות משותפות
//     ├── invites/{inviteId}
//     └── join_requests/{requestId}

class FirestoreCollections {
  // === Top-level collections ===
  static const String users = 'users';
  static const String households = 'households';
  static const String products = 'products';

  // === User subcollections ===
  static const String privateLists = 'private_lists';
  static const String notifications = 'notifications';
  static const String pendingInvites = 'pending_invites';
  static const String savedContacts = 'saved_contacts';

  // === Household subcollections ===
  static const String sharedLists = 'shared_lists';
  static const String householdInventory = 'inventory';
  static const String householdReceipts = 'receipts';
  static const String members = 'members';
  static const String invites = 'invites';
  static const String joinRequests = 'join_requests';
  static const String householdInfo = 'info';

  // === Legacy (deprecated - for migration) ===
  @Deprecated('Use privateLists or sharedLists instead')
  static const String shoppingLists = 'shopping_lists';
  @Deprecated('Use householdInventory instead')
  static const String inventory = 'inventory';
  @Deprecated('Use householdReceipts instead')
  static const String receipts = 'receipts';
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
  static const String productName = 'product_name';
  static const String quantity = 'quantity';
  static const String location = 'location';
  static const String expiryDate = 'expiry_date';
  
  // Product fields
  static const String category = 'category';
  static const String barcode = 'barcode';
  static const String brand = 'brand';
  
  // Location fields
  static const String locationName = 'location_name';
  static const String createdAt = 'created_at';
  
  // User fields
  static const String userId = 'user_id';
  static const String userName = 'user_name';
  static const String email = 'email';
  
  // Sharing fields
  static const String role = 'role';
  static const String type = 'type';
  static const String sharedUsers = 'shared_users';
  static const String pendingRequests = 'pending_requests';

  // Shopping list fields (new)
  static const String isPrivate = 'is_private';
  static const String ownerId = 'owner_id';
}
