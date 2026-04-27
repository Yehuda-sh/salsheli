// lib/repositories/constants/repository_constants.dart — Repository constants — Firestore collection/field name strings

class FirestoreCollections {
  // === Top-level collections ===
  static const String users = 'users';
  static const String households = 'households';
  static const String products = 'products';

  // === User subcollections ===
  static const String privateLists = 'private_lists';
  static const String notifications = 'notifications';
  static const String userInventory = 'inventory'; // מזווה אישי

  // === Household subcollections ===
  static const String sharedLists = 'shared_lists';
  static const String householdInventory = 'inventory';
  static const String householdReceipts = 'receipts';
  static const String members = 'members';

  // === Other top-level collections ===
  static const String shoppingPatterns = 'shopping_patterns';
  static const String customLocations = 'custom_locations';
}

class FirestoreFields {
  // === Common fields ===
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
  static const String isPrivate = 'is_private';
  static const String ownerId = 'owner_id';

  // === Inventory fields ===
  static const String productName = 'product_name';
  static const String quantity = 'quantity';
  static const String location = 'location';

  // === Product fields ===
  static const String category = 'category';
  static const String barcode = 'barcode';

  // === Receipt fields ===
  static const String date = 'date';

  // === Sharing fields ===
  static const String role = 'role';
  static const String type = 'type';
  static const String sharedUsers = 'shared_users';
  static const String pendingRequests = 'pending_requests';
}
