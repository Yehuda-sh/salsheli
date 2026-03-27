# Firebase/Firestore Schema - MemoZap

## Database Structure Overview

```
Firebase
├── Authentication (Firebase Auth)
│   └── users (auth accounts)
│
└── Firestore Database
    ├── users/{userId}
    │   ├── private_lists/{listId}
    │   ├── inventory/{itemId}
    │   ├── notifications/{notifId}
    │   ├── pending_invites/{inviteId}
    │   └── saved_contacts/{contactId}
    │
    ├── households/{householdId}
    │   ├── info
    │   ├── members/{memberId}
    │   ├── inventory/{itemId}
    │   ├── receipts/{receiptId}
    │   ├── shared_lists/{listId}
    │   ├── invites/{inviteId}
    │   └── join_requests/{requestId}
    │
    └── products/{productId}
```

---

## Collections Reference

### users/{userId}

**User Entity - Document**

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | string | Firebase Auth UID | "abc123" |
| `name` | string | Full name | "יוגב כהן" |
| `email` | string | Email address | "yogev@gmail.com" |
| `phone` | string? | Phone (05XXXXXXXX) | "0541234567" |
| `household_id` | string | Household reference | "house_abc123" |
| `profile_image_url` | string? | Avatar URL | "https://..." |
| `joined_at` | timestamp | Registration date | 2024-01-15T10:00:00Z |
| `last_login_at` | timestamp? | Last login | 2024-06-01T08:30:00Z |
| `preferred_stores` | array<string> | Favorite stores | ["רמי לוי", "שופרסל"] |
| `favorite_products` | array<string> | Favorite barcodes | ["7290000123"] |
| `weekly_budget` | number | Weekly budget (₪) | 800.0 |
| `is_admin` | boolean | Household admin? | true |
| `family_size` | number | Family members (1-10) | 4 |
| `shopping_frequency` | number | Times per week | 2 |
| `shopping_days` | array<number> | Days (0=Sun, 6=Sat) | [1, 4] |
| `has_children` | boolean | Has children? | true |
| `share_lists` | boolean | Share with family? | true |
| `reminder_time` | string? | Reminder (HH:MM) | "09:00" |
| `seen_onboarding` | boolean | Completed onboarding | true |
| `seen_tutorial` | boolean | Seen home tutorial | false |

**Example JSON:**
```json
{
  "id": "user_yogev_123",
  "name": "יוגב כהן",
  "email": "yogev@gmail.com",
  "phone": "0541234567",
  "household_id": "house_cohen_abc",
  "profile_image_url": null,
  "joined_at": "2024-01-15T10:00:00.000Z",
  "last_login_at": "2024-06-01T08:30:00.000Z",
  "preferred_stores": ["רמי לוי", "שופרסל"],
  "favorite_products": [],
  "weekly_budget": 800.0,
  "is_admin": true,
  "family_size": 4,
  "shopping_frequency": 2,
  "shopping_days": [1, 4],
  "has_children": true,
  "share_lists": true,
  "reminder_time": "09:00",
  "seen_onboarding": true,
  "seen_tutorial": false
}
```

---

### users/{userId}/private_lists/{listId}

**Private Shopping List - Subcollection**

Same structure as `shared_lists` below, but stored under user.

---

### users/{userId}/notifications/{notifId}

**Notification - Subcollection**

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | string | Notification ID | "notif_123" |
| `user_id` | string | Recipient user | "user_yogev" |
| `household_id` | string | Household ref | "house_cohen" |
| `type` | string | Type (see below) | "invite" |
| `title` | string | Hebrew title | "הזמנה לרשימה" |
| `message` | string | Detailed message | "שרה הזמינה אותך..." |
| `action_data` | object | Extra data | { "listId": "..." } |
| `is_read` | boolean | Read status | false |
| `created_at` | timestamp | Creation time | 2024-06-01T10:00:00Z |
| `read_at` | timestamp? | When read | null |

**Notification Types:**
- `invite` - List/household invitation
- `request_approved` - Editor request approved
- `request_rejected` - Editor request rejected
- `role_changed` - Role updated
- `user_removed` - Removed from list
- `low_stock` - Low inventory alert
- `member_left` - Member left the household
- `who_brings_volunteer` - Someone volunteered to bring an item

---

### households/{householdId}/shared_lists/{listId}

**Shopping List - Document**

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | string | List ID | "list_abc123" |
| `name` | string | List name | "קניות לסופ\"ש" |
| `updated_date` | timestamp | Last update | 2024-06-01T... |
| `created_date` | timestamp | Creation date | 2024-05-28T... |
| `status` | string | Status | "active" / "completed" / "archived" |
| `type` | string | List type | "supermarket" / "pharmacy" / ... |
| `budget` | number? | Budget (₪) | 500.0 |
| `is_shared` | boolean | Is shared? | true |
| `is_private` | boolean | Is private? | false |
| `created_by` | string | Creator user ID | "user_yogev" |
| `shared_with` | array<string> | Shared user IDs | ["user_sara"] |
| `event_date` | timestamp? | Event date | null |
| `target_date` | timestamp? | Deadline | 2024-06-05T... |
| `items` | array<object> | List items | [...] |
| `template_id` | string? | From template | null |
| `format` | string | Format | "shared" / "assigned" / "personal" |
| `created_from_template` | boolean | From template? | false |
| `active_shoppers` | array<object> | Active shoppers | [...] |
| `shared_users` | object | User map | { "userId": {...} } |
| `pending_requests` | array<object> | Pending requests | [...] |
| `event_mode` | string? | Event mode | "who_brings" / "shopping" / "tasks" |

**List Types:**
| Type | Hebrew | Emoji |
|------|--------|-------|
| `supermarket` | סופרמרקט | 🛒 |
| `pharmacy` | בית מרקחת | 💊 |
| `greengrocer` | ירקן | 🥦 |
| `butcher` | אטליז | 🥩 |
| `bakery` | מאפייה | 🥖 |
| `market` | שוק | 🏪 |
| `household` | כלי בית | 🏠 |
| `event` | אירוע | 🎉 |
| `other` | אחר | 📝 |

**Example JSON:**
```json
{
  "id": "list_weekend_001",
  "name": "קניות לסופ\"ש",
  "updated_date": "2024-06-01T14:30:00.000Z",
  "created_date": "2024-05-28T09:00:00.000Z",
  "status": "active",
  "type": "supermarket",
  "budget": 500.0,
  "is_shared": true,
  "is_private": false,
  "created_by": "user_yogev_123",
  "shared_with": ["user_sara_456"],
  "event_date": null,
  "target_date": null,
  "items": [
    {
      "id": "item_001",
      "name": "חלב 3%",
      "type": "product",
      "isChecked": false,
      "category": "מוצרי חלב",
      "productData": {
        "quantity": 2,
        "unitPrice": 7.9,
        "unit": "ליטר"
      }
    }
  ],
  "template_id": null,
  "format": "shared",
  "created_from_template": false,
  "active_shoppers": [],
  "shared_users": {
    "user_sara_456": {
      "user_id": "user_sara_456",
      "role": "editor",
      "shared_at": "2024-05-28T10:00:00.000Z"
    }
  },
  "pending_requests": [],
  "event_mode": null
}
```

---

### UnifiedListItem (embedded in items array)

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | string | Item ID | "item_001" |
| `name` | string | Item name | "חלב 3%" |
| `type` | string | "product" / "task" | "product" |
| `isChecked` | boolean | Is checked? | false |
| `category` | string? | Category | "מוצרי חלב" |
| `notes` | string? | Notes | "תנובה רגיל" |
| `image_url` | string? | Image URL | null |
| `productData` | object? | Product fields | {...} |
| `taskData` | object? | Task fields | {...} |
| `checked_by` | string? | Who checked | "user_yogev" |
| `checked_at` | string? | When checked | "2024-06-01T..." |

**productData:**
```json
{
  "quantity": 2,
  "unitPrice": 7.9,
  "barcode": "7290000123",
  "unit": "ליטר",
  "brand": "תנובה"
}
```

**taskData (regular):**
```json
{
  "dueDate": "2024-06-05T12:00:00.000Z",
  "assignedTo": "user_sara",
  "priority": "high",
  "itemType": "task"
}
```

**taskData (whoBrings):**
```json
{
  "itemType": "whoBrings",
  "neededCount": 2,
  "volunteers": [
    { "userId": "user_yogev", "displayName": "יוגב", "addedAt": "..." }
  ]
}
```

**taskData (voting):**
```json
{
  "itemType": "voting",
  "votesFor": [{ "userId": "...", "displayName": "..." }],
  "votesAgainst": [],
  "votesAbstain": [],
  "isAnonymous": false,
  "votingEndDate": "2024-06-10T23:59:59.000Z"
}
```

---

### ActiveShopper (embedded in active_shoppers array)

| Field | Type | Description |
|-------|------|-------------|
| `user_id` | string | Shopper user ID |
| `user_name` | string | Display name |
| `joined_at` | timestamp | Join time |
| `is_active` | boolean | Currently active? |
| `is_starter` | boolean | Started the session? |

---

### SharedUser (embedded in shared_users map)

| Field | Type | Description |
|-------|------|-------------|
| `user_id` | string | User ID |
| `role` | string | "owner" / "admin" / "editor" / "viewer" |
| `shared_at` | timestamp | When shared |
| `shared_by` | string? | Who shared |
| `display_name` | string? | Cached name |
| `email` | string? | Cached email |

---

### households/{householdId}/inventory/{itemId}

**Inventory Item - Subcollection**

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | string | Item ID | "inv_001" |
| `product_name` | string | Product name | "חלב 3%" |
| `category` | string | Category | "מוצרי חלב" |
| `location` | string | Storage location | "מקרר" |
| `quantity` | number | Current quantity | 2 |
| `unit` | string | Unit | "ליטר" |
| `min_quantity` | number | Low stock threshold | 1 |
| `expiry_date` | timestamp? | Expiration date | 2024-06-15T... |
| `notes` | string? | Notes | null |
| `is_recurring` | boolean | Auto-add to lists? | true |
| `last_purchased` | timestamp? | Last purchase | 2024-06-01T... |
| `purchase_count` | number | Times purchased | 12 |
| `emoji` | string? | Custom emoji | "🥛" |

**Storage Locations:**
- `מקרר` - Refrigerator
- `מקפיא` - Freezer
- `ארון` - Cabinet
- `מזווה` - Pantry
- `כללי` - General

**Example JSON:**
```json
{
  "id": "inv_milk_001",
  "product_name": "חלב 3% תנובה",
  "category": "מוצרי חלב",
  "location": "מקרר",
  "quantity": 2,
  "unit": "ליטר",
  "min_quantity": 1,
  "expiry_date": "2024-06-15T00:00:00.000Z",
  "notes": null,
  "is_recurring": true,
  "last_purchased": "2024-06-01T14:30:00.000Z",
  "purchase_count": 12,
  "emoji": "🥛"
}
```

---

### households/{householdId}/receipts/{receiptId}

**Receipt - Subcollection**

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | string | Receipt ID | "rcpt_001" |
| `store_name` | string | Store name | "רמי לוי" |
| `date` | timestamp | Purchase date | 2024-06-01T... |
| `created_date` | timestamp? | Record creation | 2024-06-01T... |
| `total_amount` | number | Total (₪) | 234.50 |
| `items` | array<object> | Items purchased | [...] |
| `original_url` | string? | Source URL | null |
| `file_url` | string? | Scanned image | "https://storage..." |
| `linked_shopping_list_id` | string? | Source list | "list_abc" |
| `is_virtual` | boolean | Virtual receipt? | true |
| `created_by` | string? | Creator user ID | "user_yogev" |
| `household_id` | string | Household ref | "house_cohen" |

**ReceiptItem:**
```json
{
  "id": "ri_001",
  "name": "חלב 3%",
  "quantity": 2,
  "unit_price": 7.9,
  "is_checked": true,
  "barcode": "7290000123",
  "manufacturer": "תנובה",
  "category": "מוצרי חלב",
  "unit": "ליטר",
  "checked_by": "user_yogev",
  "checked_at": "2024-06-01T14:30:00.000Z"
}
```

---

## User Roles

| Role | Hebrew | Permissions |
|------|--------|-------------|
| `owner` | בעלים | Everything - delete list, manage users, invite |
| `admin` | מנהל | Approve requests, manage users |
| `editor` | עורך | Add/edit items, requests need approval |
| `viewer` | צופה | View only |

---

## Collection Constants (from code)

```dart
// lib/repositories/constants/repository_constants.dart

class FirestoreCollections {
  // Top-level
  static const String users = 'users';
  static const String households = 'households';
  static const String products = 'products';

  // User subcollections
  static const String privateLists = 'private_lists';
  static const String notifications = 'notifications';
  static const String pendingInvites = 'pending_invites';
  static const String savedContacts = 'saved_contacts';
  static const String userInventory = 'inventory';

  // Household subcollections
  static const String sharedLists = 'shared_lists';
  static const String householdInventory = 'inventory';
  static const String householdReceipts = 'receipts';
  static const String members = 'members';
  static const String invites = 'invites';
  static const String joinRequests = 'join_requests';
  static const String householdInfo = 'info';
}
```

---

## Relationships Diagram

```
                    ┌─────────────────┐
                    │   Firebase Auth │
                    │     (users)     │
                    └────────┬────────┘
                             │
                             ▼
┌────────────────────────────────────────────────────────┐
│                    users/{userId}                       │
│  ┌────────────────┐  ┌────────────────┐               │
│  │ private_lists  │  │ notifications  │               │
│  └────────────────┘  └────────────────┘               │
│  ┌────────────────┐  ┌────────────────┐               │
│  │   inventory    │  │ saved_contacts │               │
│  └────────────────┘  └────────────────┘               │
└────────────────────────────┬───────────────────────────┘
                             │ household_id
                             ▼
┌────────────────────────────────────────────────────────┐
│               households/{householdId}                  │
│  ┌────────────────┐  ┌────────────────┐               │
│  │  shared_lists  │  │   inventory    │               │
│  └────────────────┘  └────────────────┘               │
│  ┌────────────────┐  ┌────────────────┐               │
│  │    receipts    │  │    members     │               │
│  └────────────────┘  └────────────────┘               │
│  ┌────────────────┐                                    │
│  │    invites     │  (list sharing invitations)       │
│  └────────────────┘                                    │
└────────────────────────────────────────────────────────┘
```

---

## Security Model

**Data Scoping:**
- All data is scoped by `household_id`
- Users can only access their household's data
- Private lists are under user's own document
- Shared lists are under household

**Role-based Access:**
- `owner` - Full control
- `admin` - Manage users, approve requests
- `editor` - Edit items, changes may need approval
- `viewer` - Read-only access
