# Providers Architecture - MemoZap

## Overview

MemoZap uses Provider pattern for state management with a hierarchical dependency structure.

---

## Provider Initialization Order

```
┌────────────────────────────────────────────────────────────────┐
│                        1. SERVICES                              │
│  ┌─────────────────┐    ┌─────────────────────────────────────┐│
│  │   AuthService   │    │     NotificationsService            ││
│  │   (Firebase)    │    │     (Firestore notifications)       ││
│  └────────┬────────┘    └─────────────────────────────────────┘│
└───────────┼────────────────────────────────────────────────────┘
            │
            ▼
┌────────────────────────────────────────────────────────────────┐
│                    2. REPOSITORIES                              │
│  ┌─────────────────┐    ┌─────────────────┐                    │
│  │ UserRepository  │    │ LocalProducts   │ (JSON file)        │
│  │ (Firebase)      │    │   Repository    │                    │
│  └────────┬────────┘    └─────────────────┘                    │
│           │                                                     │
│  ┌────────┴────────┐    ┌─────────────────┐    ┌─────────────┐ │
│  │ ShoppingLists   │    │   Inventory     │    │  Receipt    │ │
│  │   Repository    │    │   Repository    │    │ Repository  │ │
│  └─────────────────┘    └─────────────────┘    └─────────────┘ │
└────────────────────────────────────────────────────────────────┘
            │
            ▼
┌────────────────────────────────────────────────────────────────┐
│                    3. USER CONTEXT                              │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                   UserContext                                ││
│  │  - Current user (UserEntity)                                ││
│  │  - household_id                                             ││
│  │  - Theme mode (light/dark/system)                           ││
│  │  - Login state                                              ││
│  │  Dependencies: AuthService, UserRepository                  ││
│  └──────────────────────────┬──────────────────────────────────┘│
└─────────────────────────────┼──────────────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────────┐
│               4. DATA PROVIDERS (Level 1)                       │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐      │
│  │   Products    │  │  Locations    │  │ Shopping      │      │
│  │   Provider    │  │  Provider     │  │ Lists         │      │
│  │               │  │               │  │ Provider      │      │
│  │ (Local JSON)  │  │ (Firebase)    │  │ (Firebase)    │      │
│  └───────────────┘  └───────────────┘  └───────────────┘      │
│                                                                 │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐      │
│  │   Receipt     │  │ProductLocation│  │ Pending       │      │
│  │   Provider    │  │  Provider     │  │ Invites       │      │
│  │ (Firebase)    │  │ (Location     │  │ Provider      │      │
│  │               │  │  memory)      │  │               │      │
│  └───────────────┘  └───────────────┘  └───────────────┘      │
└────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────────┐
│               5. DATA PROVIDERS (Level 2)                       │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                    GroupsProvider                          │ │
│  │  Dependencies: UserContext, PendingInvitesProvider         │ │
│  │  Manages: Groups, group members, group invites             │ │
│  └──────────────────────────┬────────────────────────────────┘ │
│                             │                                   │
│  ┌──────────────────────────┴────────────────────────────────┐ │
│  │                  InventoryProvider                         │ │
│  │  Dependencies: UserContext, GroupsProvider                 │ │
│  │  Manages: Household inventory, Group inventories           │ │
│  └──────────────────────────┬────────────────────────────────┘ │
└─────────────────────────────┼──────────────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────────┐
│               6. COMPUTED PROVIDERS                             │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                 SuggestionsProvider                        │ │
│  │  Dependencies: InventoryProvider                           │ │
│  │  Computes: Smart shopping suggestions based on inventory   │ │
│  └───────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────┘
```

---

## Provider Details

### 1. UserContext

**Purpose:** Central auth state and user data management

**Dependencies:**
- `AuthService` - Firebase Authentication
- `UserRepository` - Firestore user data

**Manages:**
- `currentUser` (UserEntity)
- `householdId` - Used by all other providers
- `isLoggedIn` state
- `themeMode` (light/dark/system)
- Onboarding data

**Used by:** All data providers

```dart
ChangeNotifierProxyProvider2<AuthService, UserRepository, UserContext>(
  create: (context) => UserContext(
    repository: context.read<UserRepository>(),
    authService: context.read<AuthService>(),
  ),
  ...
)
```

---

### 2. ProductsProvider

**Purpose:** Global product catalog (local JSON database)

**Dependencies:**
- `LocalProductsRepository` - Local JSON file

**Manages:**
- Product database with categories
- Product search
- Barcode lookup

**Note:** `skipInitialLoad: true` - Waits for UserContext login

```dart
ChangeNotifierProxyProvider<UserContext, ProductsProvider>(
  lazy: false,  // Important: must be false
  create: (context) => ProductsProvider(
    repository: productsRepo,
    skipInitialLoad: true,
  ),
  ...
)
```

---

### 3. LocationsProvider

**Purpose:** Storage locations management

**Dependencies:**
- `UserContext`
- `FirebaseLocationsRepository`

**Manages:**
- Custom storage locations
- Location CRUD operations

```dart
ChangeNotifierProxyProvider<UserContext, LocationsProvider>(
  create: (context) => LocationsProvider(
    userContext: context.read<UserContext>(),
    repository: locationsRepo,
  ),
  ...
)
```

---

### 4. ShoppingListsProvider

**Purpose:** Shopping lists management (core feature)

**Dependencies:**
- `UserContext`
- `FirebaseShoppingListsRepository`
- `FirebaseReceiptRepository`

**Manages:**
- Shopping lists (private & shared)
- List items (UnifiedListItem)
- Active shopping sessions
- List sharing with users

**Key Methods:**
- `createList()` - Create new list
- `updateItem()` - Update item in list
- `startShopping()` - Begin shopping session
- `finishShopping()` - End session, create receipt
- `shareList()` - Share with other users

```dart
ChangeNotifierProxyProvider<UserContext, ShoppingListsProvider>(
  create: (context) {
    final provider = ShoppingListsProvider(
      repository: shoppingListsRepo,
      receiptRepository: receiptRepo,
    );
    provider.updateUserContext(context.read<UserContext>());
    return provider;
  },
  ...
)
```

---

### 5. ReceiptProvider

**Purpose:** Shopping receipts/history management

**Dependencies:**
- `UserContext`
- `FirebaseReceiptRepository`

**Manages:**
- Receipt history
- Virtual receipts (from shopping completion)
- Receipt statistics

```dart
ChangeNotifierProxyProvider<UserContext, ReceiptProvider>(
  create: (context) => ReceiptProvider(
    userContext: context.read<UserContext>(),
    repository: receiptRepo,
  ),
  ...
)
```

---

### 6. PendingInvitesProvider

**Purpose:** Group invitation management

**Dependencies:** None (standalone)

**Manages:**
- Pending group invites
- Invite accept/reject

```dart
ChangeNotifierProvider<PendingInvitesProvider>(
  create: (_) => PendingInvitesProvider(),
)
```

---

### 7. GroupsProvider

**Purpose:** Group management

**Dependencies:**
- `UserContext`
- `PendingInvitesProvider` (shares repository)
- `FirebaseGroupRepository`

**Manages:**
- Groups
- Group members
- Group settings
- Member roles

```dart
ChangeNotifierProxyProvider2<UserContext, PendingInvitesProvider, GroupsProvider>(
  create: (context) => GroupsProvider(
    repository: FirebaseGroupRepository(),
    inviteRepository: context.read<PendingInvitesProvider>().repository,
  ),
  ...
)
```

---

### 8. InventoryProvider

**Purpose:** Pantry/inventory management

**Dependencies:**
- `UserContext`
- `GroupsProvider` - For group inventories
- `FirebaseInventoryRepository`

**Manages:**
- Household inventory items
- Group inventory items
- Low stock alerts
- Expiry tracking

**Note:** Must come after GroupsProvider

```dart
ChangeNotifierProxyProvider2<UserContext, GroupsProvider, InventoryProvider>(
  create: (context) => InventoryProvider(
    userContext: context.read<UserContext>(),
    repository: inventoryRepo,
  ),
  update: (context, userContext, groupsProvider, previous) {
    ...
    provider.updateGroupsProvider(groupsProvider);
    return provider;
  },
)
```

---

### 9. SuggestionsProvider

**Purpose:** Smart shopping suggestions

**Dependencies:**
- `InventoryProvider`

**Computes:**
- Low stock suggestions
- Frequently purchased items
- Items expiring soon

```dart
ChangeNotifierProxyProvider<InventoryProvider, SuggestionsProvider>(
  create: (context) => SuggestionsProvider(
    inventoryProvider: context.read<InventoryProvider>(),
  ),
  ...
)
```

---

### 10. ProductLocationProvider

**Purpose:** Remember product locations in stores

**Dependencies:**
- `UserContext`

**Manages:**
- Product-to-aisle mapping
- Store location memory

```dart
ChangeNotifierProxyProvider<UserContext, ProductLocationProvider>(
  create: (context) => ProductLocationProvider(),
  update: (context, userContext, previous) {
    previous?.updateUserContext(userContext);
    return previous ?? ProductLocationProvider();
  },
)
```

---

## Data Flow Patterns

### 1. Login Flow

```
User enters credentials
        ↓
   AuthService.signIn()
        ↓
   UserContext updates
        ↓
   All providers receive
   new householdId
        ↓
   Providers load data
   from Firestore
```

### 2. Shopping List Update

```
User adds item to list
        ↓
   ShoppingListsProvider.addItem()
        ↓
   Repository writes to Firestore
        ↓
   notifyListeners()
        ↓
   UI rebuilds via Consumer<>
```

### 3. Shopping Completion

```
User finishes shopping
        ↓
   ShoppingListsProvider.finishShopping()
        ↓
   Creates Receipt (ReceiptProvider)
        ↓
   Updates Inventory (InventoryProvider)
        ↓
   Archives list
        ↓
   SuggestionsProvider recalculates
```

---

## Provider Dependency Graph

```
              AuthService
                  │
            UserRepository
                  │
                  ▼
             UserContext ──────────────────────────┐
                  │                                │
    ┌─────────────┼─────────────┐                  │
    │             │             │                  │
    ▼             ▼             ▼                  │
Products    Locations    ShoppingLists            │
Provider    Provider      Provider                │
                              │                    │
                              │                    │
                         Receipt                   │
                         Provider                  │
                                                   │
              PendingInvites                       │
                Provider                           │
                    │                              │
                    ▼                              │
               Groups ←────────────────────────────┘
               Provider
                    │
                    ▼
               Inventory
               Provider
                    │
                    ▼
              Suggestions
               Provider
```

---

## Important Notes

### Lazy Loading
- `ProductsProvider` uses `lazy: false` - Must initialize early
- Other providers use default lazy loading

### Update Methods
Providers that depend on UserContext implement:
```dart
void updateUserContext(UserContext userContext) {
  if (_householdId != userContext.householdId) {
    _householdId = userContext.householdId;
    _loadData();
    notifyListeners();
  }
}
```

### Real-time Updates
Providers use Firestore snapshots for real-time sync:
```dart
_subscription = _repository.watchItems(householdId).listen((items) {
  _items = items;
  notifyListeners();
});
```

---

## Screen-Provider Mapping

| Screen | Primary Providers |
|--------|------------------|
| IndexScreen | UserContext |
| LoginScreen | AuthService |
| RegisterScreen | AuthService, UserContext |
| MainNavigationScreen | UserContext |
| HomeDashboardScreen | ShoppingListsProvider, ReceiptProvider, SuggestionsProvider |
| ShoppingListsScreen | ShoppingListsProvider |
| CreateListScreen | ShoppingListsProvider, ProductsProvider |
| ShoppingListDetailsScreen | ShoppingListsProvider, ProductsProvider |
| ActiveShoppingScreen | ShoppingListsProvider, ProductLocationProvider |
| ShoppingSummaryScreen | ShoppingListsProvider, ReceiptProvider, InventoryProvider |
| MyPantryScreen | InventoryProvider |
| GroupsListScreen | GroupsProvider, PendingInvitesProvider |
| GroupDetailsScreen | GroupsProvider |
| SettingsScreen | UserContext, ReceiptProvider, InventoryProvider |
