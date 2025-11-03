# TECH.md - MemoZap Technical Reference

> Machine-readable | Firebase + Security + Models | Updated: 03/11/2025

---

## REPOSITORY CONSTANTS

```yaml
location: lib/repositories/constants/repository_constants.dart

purpose:
  - single source of truth for Firestore strings
  - easier refactoring (rename collections/fields)
  - no magic strings in repositories
  - maintainability + consistency

classes:
  FirestoreCollections:
    - shoppingLists
    - users
    - households
    - inventory
    - products
    - receipts
    - habitPreferences
    - customLocations
  
  FirestoreFields:
    - id, name, createdBy, createdDate, updatedDate
    - householdId (CRITICAL!)
    - userId, userName, email, displayName
    - items, sharedUsers, pendingRequests
    - date, category, barcode, brand
    - preferredProduct, lastPurchased, createdAt
    - type, status, role (sharing/requests)

usage:
  good: .collection(FirestoreCollections.shoppingLists)
  good: .where(FirestoreFields.householdId, isEqualTo: id)
  bad: .collection('shopping_lists') // magic string!
  bad: .where('household_id', ...) // magic string!

migrated_repositories: 6
  - firebase_user_repository
  - firebase_receipt_repository  
  - firebase_habits_repository
  - firebase_locations_repository
  - firebase_products_repository
  - firebase_shopping_list_repository (partial)
```

---

## FIREBASE STRUCTURE

```yaml
firestore:
  shopping_lists/{listId}:
    id: string
    name: string
    list_type: string  # supermarket, pharmacy, greengrocer, butcher, bakery, market, household, other
    created_by: string (userId)
    created_date: timestamp
    updated_date: timestamp
    household_id: string  # CRITICAL - ALWAYS filter by this!
    items: array[UnifiedListItem]
    shared_users: array[SharedUser]  # userId, role (owner/admin/editor/viewer), sharedAt
    pending_requests: array[PendingRequest]  # id, requesterId, itemData, status, requestedAt
    active_shoppers: array[ActiveShopper]  # userId, joinedAt, isStarter, isActive
  
  users/{userId}:
    id: string
    email: string
    display_name: string
    household_id: string
    created_date: timestamp
  
  households/{householdId}:
    id: string
    name: string
    created_by: string
    members: array[userId]
  
  receipts/{receiptId}:
    id: string
    household_id: string  # CRITICAL - ALWAYS filter by this!
    linked_shopping_list_id: string?  # connection to shopping list
    is_virtual: bool  # true = created automatically, false = scanned
    created_by: string (userId)
    created_date: timestamp
    items: array[ReceiptItem]  # includes checkedBy, checkedAt fields

indexes_required:
  - household_id (Asc) + created_date (Desc)
  - household_id (Asc) + updated_date (Desc)
  - household_id (Asc) + linked_shopping_list_id (Asc)  # for receipt lookups
```

---

## SECURITY RULES

```yaml
core_principles:
  1. household_id filter - MANDATORY on ALL queries
  2. role_based_access - Owner/Admin/Editor/Viewer (4 tiers)
  3. editor_restrictions - Can only add pending_requests, NOT direct items
  4. owner_exclusive - Only owner can delete lists
  5. starter_permissions - Only starter can finish shopping

roles:
  owner:
    - Full access to list (create/read/update)
    - Delete list
    - Manage users (invite/remove/change roles)
    - Approve/reject pending requests
    - Add items directly (no approval needed)
  
  admin:
    - Full access to list (create/read/update)
    - Cannot delete list (owner only)
    - Manage users (invite/remove/change roles)
    - Approve/reject pending requests
    - Add items directly (no approval needed)
  
  editor:
    - Read list (full visibility)
    - Add items → creates pending_request (needs approval)
    - Cannot modify existing items
    - Cannot delete items
    - Cannot manage users
  
  viewer:
    - Read-only access
    - Cannot add/edit/delete anything
    - Cannot create requests

rules_location: firestore.rules
deploy_command: firebase deploy --only firestore:rules
```

**Critical Query Pattern:**
```dart
// ✅ CORRECT - ALWAYS filter by household_id
.where('household_id', isEqualTo: householdId)

// ❌ WRONG - Missing household_id = SECURITY BREACH!
.collection('shopping_lists').get()  // Can see ALL households!
```

---

## KEY MODELS

### Phase 3B: User Sharing System

```dart
// SharedUser - represents a user with access to a shopping list
class SharedUser {
  // Core fields
  @JsonKey(name: 'user_id')
  final String userId;
  final UserRole role;  // owner, admin, editor, viewer
  @JsonKey(name: 'shared_at')
  final DateTime sharedAt;
  
  // Cache fields (metadata from users collection)
  @JsonKey(name: 'user_name')
  final String? userName;        // Display name for UI
  @JsonKey(name: 'user_email')
  final String? userEmail;       // Email for contact
  @JsonKey(name: 'user_avatar')
  final String? userAvatar;      // Avatar URL
}

enum UserRole {
  owner,   // 👑 Full access + delete + manage users (canManageUsers, canDeleteList)
  admin,   // 🔧 Full access + manage users (no delete) (canApproveRequests, canManageUsers)
  editor,  // ✏️ Read + create pending requests (canRequest)
  viewer,  // 👀 Read-only (canRead only)
  
  // Permissions helpers:
  // - canAddDirectly (owner/admin)
  // - canEditDirectly (owner/admin)
  // - canDeleteDirectly (owner/admin)
  // - canApproveRequests (owner/admin)
  // - canManageUsers (owner only)
  // - canDeleteList (owner only)
  // - canRequest (editor only)
  // - canRead (all)
}

// PendingRequest - Editor's item addition/edit/delete request
class PendingRequest {
  // Core fields
  final String id;
  @JsonKey(name: 'list_id')
  final String listId;           // Which list this request belongs to
  @JsonKey(name: 'requester_id')
  final String requesterId;      // userId who created request
  final RequestType type;        // addItem, editItem, deleteItem
  final RequestStatus status;    // pending, approved, rejected
  @JsonKey(name: 'created_at')
  final DateTime createdAt;      // When request was created
  
  // Request data (varies by type)
  @JsonKey(name: 'request_data')
  final Map<String, dynamic> requestData;
  // Examples:
  // - addItem: { name, quantity, unitPrice, ... }
  // - editItem: { itemId, changes: { name: 'new', quantity: 5 } }
  // - deleteItem: { itemId }
  
  // Review fields
  @JsonKey(name: 'reviewer_id')
  final String? reviewerId;      // userId who approved/rejected
  @JsonKey(name: 'reviewed_at')
  final DateTime? reviewedAt;    // When approved/rejected
  @JsonKey(name: 'rejection_reason')
  final String? rejectionReason; // Why rejected
  
  // Cache fields
  @JsonKey(name: 'requester_name')
  final String? requesterName;   // Requester display name
  @JsonKey(name: 'reviewer_name')
  final String? reviewerName;    // Reviewer display name
  
  // Helpers:
  // - isPending, isApproved, isRejected
  // - minutesAgo, timeAgoText
}

enum RequestStatus {
  pending,   // 🔵 Waiting for approval
  approved,  // ✅ Approved by owner/admin
  rejected,  // ❌ Rejected by owner/admin
}

enum RequestType {
  addItem,    // ➕ Request to add new item
  editItem,   // ✏️ Request to edit existing item
  deleteItem, // 🗑️ Request to delete item
}
```

### Receipt to Inventory System

```dart
// ActiveShopper - tracks who's shopping in real-time
class ActiveShopper {
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'joined_at')
  final DateTime joinedAt;
  @JsonKey(name: 'is_starter')
  final bool isStarter;  // First person = starter (can finish shopping)
  @JsonKey(name: 'is_active')
  final bool isActive;   // Still shopping or left (default: true)
  
  // Factory constructors:
  // - ActiveShopper.starter(userId) - creates starter
  // - ActiveShopper.helper(userId) - creates helper
}

// Receipt - complete receipt model
class Receipt {
  // Core fields
  final String id;
  @JsonKey(name: 'store_name')
  final String storeName;
  final DateTime date;
  @JsonKey(name: 'created_date')
  final DateTime? createdDate;
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  final List<ReceiptItem> items;
  
  // File fields
  @JsonKey(name: 'original_url')
  final String? originalUrl;     // Original receipt link
  @JsonKey(name: 'file_url')
  final String? fileUrl;         // Firebase Storage URL
  
  // Collaborative shopping fields
  @JsonKey(name: 'linked_shopping_list_id')
  final String? linkedShoppingListId;  // Connection to shopping list
  @JsonKey(name: 'is_virtual')
  final bool isVirtual;          // true = auto-created, false = scanned
  @JsonKey(name: 'created_by')
  final String? createdBy;       // userId who created (starter)
  
  // Security
  @JsonKey(name: 'household_id')
  final String householdId;      // CRITICAL - required!
  
  // Helpers:
  // - isVirtualReceipt (virtual + no scan)
  // - isRealConnected (virtual + has scan)
  // - isRealScanned (not virtual + has scan)
  
  // Factory constructors:
  // - Receipt.newReceipt(...) - regular receipt
  // - Receipt.virtual(...) - virtual receipt from shopping
}

// ReceiptItem - item in receipt
class ReceiptItem {
  // Core fields
  final String id;
  final String? name;
  final int quantity;            // >= 0
  @JsonKey(name: 'unit_price')
  final double unitPrice;        // >= 0
  @JsonKey(name: 'is_checked')
  final bool isChecked;          // Backward compatibility
  
  // Product metadata
  final String? barcode;
  final String? manufacturer;
  final String? category;
  final String? unit;
  
  // Collaborative shopping fields
  @JsonKey(name: 'checked_by')
  final String? checkedBy;       // userId who marked as purchased
  @JsonKey(name: 'checked_at')
  final DateTime? checkedAt;     // When marked as purchased
  
  // Helpers:
  // - totalPrice (quantity * unitPrice)
  // - wasChecked (has checkedBy)
}
```

---

## MODEL SERIALIZATION

```dart
// Template - copy this!
import 'package:json_annotation/json_annotation.dart';

part 'model_name.g.dart';

@JsonSerializable(explicitToJson: true)
class ModelName {
  final String id;
  final String name;
  
  @JsonKey(name: 'created_date')
  final DateTime createdDate;
  
  ModelName({required this.id, required this.name, required this.createdDate});
  
  factory ModelName.fromJson(Map<String, dynamic> json) => _$ModelNameFromJson(json);
  Map<String, dynamic> toJson() => _$ModelNameToJson(this);
  
  ModelName copyWith({String? id, String? name, DateTime? createdDate}) {
    return ModelName(
      id: id ?? this.id,
      name: name ?? this.name,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}
```

**After EVERY model change:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## DEPENDENCIES

```yaml
firebase:
  - firebase_core: ^4.2.0
  - firebase_auth: ^6.1.1
  - cloud_firestore: ^6.0.3
  - firebase_storage: ^13.0.3

state:
  - provider: ^6.1.2

serialization:
  - json_annotation: ^4.9.0
  - build_runner: ^2.4.13 (dev)
  - json_serializable: ^6.8.0 (dev)

storage:
  - hive: ^2.2.3
  - hive_flutter: ^1.1.0

ui:
  - cupertino_icons: ^1.0.8
  - font_awesome_flutter: ^10.7.0
  - flutter_animate: ^4.5.0
  - shimmer: ^3.0.0
  - dynamic_color: ^1.7.0

l10n:
  - flutter_localizations (sdk)
  - intl: ^0.20.2

media:
  - camera: ^0.11.0+2
  - image_picker: ^1.1.2
  - mobile_scanner: ^7.1.2

utils:
  - uuid: ^4.5.0
  - path_provider: ^2.1.4
  - path: ^1.9.0
  - http: ^1.2.2
  - timeago: ^3.7.0
  - xml: ^6.6.1
  - archive: ^4.0.7

charts:
  - fl_chart: ^1.1.1

testing:
  - flutter_test (sdk)
  - mockito: ^5.4.4
  - test: ^1.25.0
  - analyzer: ^7.7.1
  - flutter_lints: ^6.0.0 (dev)
```

---

## CRITICAL PATTERNS

### 1. Firestore Query (household_id MANDATORY!)
```dart
// ✅ CORRECT
final snapshot = await _firestore
    .collection('shopping_lists')
    .where('household_id', isEqualTo: householdId)  // MUST HAVE!
    .orderBy('created_date', descending: true)
    .get();

// ❌ WRONG - Security breach!
.collection('shopping_lists').get()  // NO household_id filter!
```

### 2. Timestamps
```dart
// ✅ CORRECT - Server timestamp
'created_date': FieldValue.serverTimestamp()

// ❌ WRONG - Client timestamp (can be wrong)
'created_date': DateTime.now()
```

### 3. Array Operations
```dart
// ✅ Add to array
FieldValue.arrayUnion([item.toJson()])

// ✅ Remove from array
FieldValue.arrayRemove([item.toJson()])
```

### 4. Error Handling
```dart
try {
  final doc = await _firestore.collection('shopping_lists').doc(id).get();
  if (!doc.exists) throw Exception('Not found');
  return Model.fromJson(doc.data()!);
} on FirebaseException catch (e) {
  debugPrint('❌ Firebase: ${e.code} - ${e.message}');
  rethrow;
} catch (e) {
  debugPrint('❌ Error: $e');
  rethrow;
}
```

---

## PERFORMANCE

```yaml
offline_persistence:
  # main.dart
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

limit_queries:
  .limit(50)  # Add to large collections

transactions:
  # Use for atomic updates
  await _firestore.runTransaction((transaction) async {
    # ...
  });
```

---

## COMMON MISTAKES

```yaml
1_missing_household_id:
  error: "❌ .get() without .where('household_id', ...)" 
  impact: SECURITY BREACH - sees other households!
  fix: ALWAYS add household_id filter

2_forgot_build_runner:
  error: "❌ Changed model, forgot build_runner"
  impact: Compilation errors (.g.dart missing)
  fix: flutter pub run build_runner build --delete-conflicting-outputs

3_client_timestamp:
  error: "❌ DateTime.now() instead of FieldValue.serverTimestamp()"
  impact: Wrong time (client clock can be wrong)
  fix: Use FieldValue.serverTimestamp()

4_direct_firestore_in_ui:
  error: "❌ FirebaseFirestore.instance in Screen/Widget"
  impact: Breaks Repository pattern, hard to test
  fix: Use Repository → Provider → Screen

5_no_error_handling:
  error: "❌ No try-catch on async Firebase calls"
  impact: Crashes
  fix: Wrap all async Firebase operations in try-catch

6_magic_strings:
  error: "❌ Hardcoded 'shopping_lists' or 'household_id' strings"
  impact: Hard to refactor, typo-prone
  fix: Use FirestoreCollections/FirestoreFields constants
```

---

## CHECKLIST

```yaml
before_commit:
  - [ ] All queries have household_id filter
  - [ ] build_runner executed after model changes
  - [ ] All timestamps use FieldValue.serverTimestamp()
  - [ ] Repository pattern used (no direct Firestore in UI)
  - [ ] Try-catch on all async Firebase operations
  - [ ] Tests pass (flutter test)
  - [ ] Use FirestoreCollections/Fields constants (no magic strings)

before_deploy:
  - [ ] Firestore rules deployed
  - [ ] Indexes created in Firebase Console
  - [ ] No sensitive data in logs
  - [ ] Security rules tested in Console
```

---

## BUILD CONFIG

```yaml
android:
  compileSdk: flutter.compileSdkVersion
  minSdk: flutter.minSdkVersion
  targetSdk: flutter.targetSdkVersion
  ndkVersion: 27.0.12077973
  jvmTarget: 21

ios:
  platform: 13.0
```

---

End of Technical Reference
Version: 1.4 | Date: 03/11/2025
Optimized for AI parsing - minimal formatting, maximum data density.

**Updates v1.1 (29/10/2025):**
- Added REPOSITORY CONSTANTS section (session 38)
- Added magic_strings to COMMON MISTAKES
- Updated before_commit checklist
- 6 repositories migrated to constants

**Updates v1.2 (29/10/2025 - session 46):**
- Fixed dependencies (updated to current versions from pubspec.yaml)
- Fixed FirestoreCollections: inventory (not inventoryItems)
- Added missing FirestoreFields: userName, role, type, status
- Updated Build Config to match current setup
- Removed deprecated firebase_bom, google_fonts
- Added new dependencies: firebase_storage, camera, image_picker, etc.

**Updates v1.3 (02/11/2025 - session 49):**
- Added KEY MODELS section with Phase 3B (SharedUser, PendingRequest, UserRole)
- Added Receipt to Inventory models (ActiveShopper, Receipt fields, ReceiptItem fields)
- Expanded FIREBASE STRUCTURE with receipts collection + new fields
- Enhanced SECURITY RULES with 4-tier role system details
- Added list_type field to shopping_lists
- Added linked_shopping_list_id index for receipt lookups
- Documented Editor restrictions (pending requests workflow)

**Updates v1.4 (03/11/2025 - session 50):**
- COMPLETE MODEL DOCUMENTATION: Expanded all models with full field details
- SharedUser: Added cache fields (userName, userEmail, userAvatar)
- PendingRequest: Added ALL fields (listId, reviewer fields, cache fields, helpers)
- UserRole: Added complete permission matrix (canAddDirectly, canManageUsers, etc.)
- Receipt: Complete model (storeName, dates, files, security, helpers, factory constructors)
- ReceiptItem: Complete model (all core fields, metadata, collaborative shopping fields)
- ActiveShopper: Added factory constructors documentation
- All enums documented with emojis and Hebrew names
- Added @JsonKey annotations for all snake_case fields
