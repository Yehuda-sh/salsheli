// 📄 File: lib/repositories/constants/repository_constants.dart
//
// 🎯 Purpose: Firestore collection names and field names
// - Centralized constants for Firestore operations
// - Easier to maintain and refactor
//
// 🏗️ Database Structure:
//   /users/{userId}/
//     ├── private_lists/{listId}      ← רשימות פרטיות
//     ├── inventory/{itemId}          ← מזווה אישי
//     ├── notifications/{notifId}
//     ├── pending_invites/{inviteId}
//     └── saved_contacts/{contactId}
//
//   /households/{householdId}/         ← משק בית (נוצר אוטומטית)
//     ├── info
//     ├── members/{memberId}
//     ├── inventory/{itemId}          ← מזווה משק בית
//     ├── receipts/{receiptId}
//     ├── shared_lists/{listId}       ← רשימות משותפות
//     ├── invites/{inviteId}
//     └── join_requests/{requestId}
//
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
  static const String userInventory = 'inventory'; // מזווה אישי

  // === Household subcollections ===
  static const String sharedLists = 'shared_lists';
  static const String householdInventory = 'inventory';
  static const String householdReceipts = 'receipts';
  static const String members = 'members';
  static const String invites = 'invites';
  static const String joinRequests = 'join_requests';
  static const String householdInfo = 'info';

  // ✅ Legacy constants REMOVED (shoppingLists, inventory, receipts)
  static const String customLocations = 'custom_locations';
}

class FirestoreFields {
  // === Common fields ===
  static const String id = 'id';
  static const String householdId = 'household_id';
  static const String createdDate = 'created_date';
  static const String updatedDate = 'updated_date';
  static const String createdAt = 'created_at';

  // === User fields ===
  static const String userId = 'user_id';
  static const String userName = 'user_name';
  static const String email = 'email';
  static const String phone = 'phone';

  // === Shopping List fields ===
  static const String name = 'name';
  static const String createdBy = 'created_by';
  static const String status = 'status';
  static const String shoppingListId = 'shopping_list_id';
  static const String activeShoppers = 'active_shoppers';
  static const String isShared = 'is_shared';
  static const String isPrivate = 'is_private';
  static const String ownerId = 'owner_id';

  // === List Item fields (UnifiedListItem) ===
  static const String unitPrice = 'unit_price';
  static const String imageUrl = 'image_url';
  static const String notes = 'notes';
  static const String isChecked = 'is_checked';
  static const String checkedBy = 'checked_by';
  static const String checkedAt = 'checked_at';

  // === Inventory fields ===
  static const String productId = 'product_id';
  static const String productName = 'product_name';
  static const String quantity = 'quantity';
  static const String location = 'location';
  static const String expiryDate = 'expiry_date';

  // === Product fields ===
  static const String category = 'category';
  static const String barcode = 'barcode';
  static const String brand = 'brand';

  // === Receipt fields ===
  static const String storeName = 'store_name';
  static const String purchaseDate = 'purchase_date';
  static const String totalAmount = 'total_amount';
  static const String items = 'items';
  static const String date = 'date';

  // === Sharing fields ===
  static const String role = 'role';
  static const String type = 'type';
  static const String sharedUsers = 'shared_users';
  static const String pendingRequests = 'pending_requests';

  // === Location fields ===
  static const String locationName = 'location_name';
}
