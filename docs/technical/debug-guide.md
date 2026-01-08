# Debug Guide - MemoZap

## Debug Print Patterns

The codebase uses `debugPrint()` with emoji prefixes for easy log identification.

### Log Prefixes

| Emoji | Meaning | Example |
|-------|---------|---------|
| `🔐` | Auth operations | `🔐 Connected to Auth Emulator` |
| `🔥` | Firebase operations | `🔥 Connected to Firestore Emulator` |
| `📦` | Storage/Hive | `📦 Connected to Storage Emulator` |
| `📥` | Data incoming (fromJson) | `📥 InventoryItem.fromJson: id=...` |
| `📤` | Data outgoing (toJson) | `📤 InventoryItem.toJson: id=...` |
| `⚠️` | Warnings | `⚠️ SharedUsersMapConverter: Converting old List format` |
| `🔴` | Errors | `🔴 Flutter Error: ...` |
| `❌` | Failures | `❌ Firebase initialization error` |
| `✅` | Success | `✅ User logged in successfully` |
| `🎨` | Theme/UI | `🎨 Material You enabled` |
| `📍` | Locations | `📍 Location loaded: ...` |
| `🛒` | Shopping | `🛒 Shopping session started` |
| `📋` | Lists | `📋 List created: ...` |
| `👥` | Groups | `👥 Group loaded: ...` |
| `📬` | Notifications | `📬 Notification received: ...` |

---

## Enabling Debug Mode

### 1. VS Code / Android Studio

Debug mode is enabled automatically when running with debugger.

### 2. Command Line

```bash
flutter run --debug
```

### 3. Check Debug Mode in Code

```dart
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  debugPrint('Debug message');
}
```

---

## Firebase Emulators

### Configuration

Edit `lib/config/app_config.dart`:

```dart
class AppConfig {
  // Set to true to use local emulators
  static const bool useEmulators = true;

  static const String emulatorHost = 'localhost';
  static const int firestorePort = 8080;
  static const int authPort = 9099;
  static const int storagePort = 9199;
}
```

### Starting Emulators

```bash
firebase emulators:start
```

### Emulator UI

- Firestore: http://localhost:8080
- Auth: http://localhost:9099
- Storage: http://localhost:9199

---

## Common Debug Scenarios

### 1. User Not Loading

**Symptoms:**
- Stuck on loading screen
- `currentUser` is null

**Check:**
```dart
// In UserContext
debugPrint('🔐 User state: ${_currentUser?.email ?? "null"}');
debugPrint('🔐 HouseholdId: $_householdId');
debugPrint('🔐 IsLoggedIn: $isLoggedIn');
```

**Common Causes:**
- Firebase not initialized
- Auth token expired
- Network issue

---

### 2. Lists Not Showing

**Symptoms:**
- Empty list screen
- Data exists in Firebase but not in app

**Check:**
```dart
// In ShoppingListsProvider
debugPrint('📋 Lists count: ${_lists.length}');
debugPrint('📋 HouseholdId: $_householdId');
debugPrint('📋 Repository subscription active: ${_subscription != null}');
```

**Common Causes:**
- `householdId` mismatch
- Provider not updated with UserContext
- Firestore security rules blocking

---

### 3. Real-time Updates Not Working

**Symptoms:**
- Changes in Firebase not reflecting in app
- Need to restart app to see updates

**Check:**
```dart
// In provider
void _setupListener() {
  debugPrint('🔄 Setting up listener for householdId: $_householdId');
  _subscription?.cancel();
  _subscription = _repository.watch(_householdId).listen(
    (data) {
      debugPrint('🔄 Received update: ${data.length} items');
      _items = data;
      notifyListeners();
    },
    onError: (e) {
      debugPrint('🔴 Listener error: $e');
    },
  );
}
```

**Common Causes:**
- Subscription cancelled
- Provider disposed
- Firestore index missing

---

### 4. Shopping Session Issues

**Symptoms:**
- Can't start shopping
- Timer not working
- Items not updating

**Check:**
```dart
// In ShoppingListsProvider
debugPrint('🛒 Active shoppers: ${list.activeShoppers.length}');
debugPrint('🛒 Is being shopped: ${list.isBeingShopped}');
debugPrint('🛒 Current user is shopper: ${list.isUserShopping(userId)}');
debugPrint('🛒 Can user finish: ${list.canUserFinish(userId)}');
```

**Common Causes:**
- User not added to activeShoppers
- isStarter flag not set
- Timeout exceeded (6 hours)

---

### 5. Inventory Not Updating After Shopping

**Symptoms:**
- Finished shopping but inventory unchanged
- Receipt created but inventory same

**Check:**
```dart
// In InventoryProvider
debugPrint('📦 Inventory items: ${_items.length}');
debugPrint('📦 Should update pantry: ${ShoppingList.shouldUpdatePantry(type, isPrivate: isPrivate)}');
```

**Common Causes:**
- List type is "event" (doesn't update pantry)
- List is private (doesn't update shared pantry)
- `finishShopping()` failed silently

---

## Firestore Debug

### Check Security Rules

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Debug: allow all (NEVER in production!)
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

### Query Debug

In Firebase Console:
1. Go to Firestore
2. Click on collection
3. Check document structure matches model

### Index Errors

Error: `The query requires an index`

Solution: Click the link in error message to create index, or create manually:

```javascript
// firestore.indexes.json
{
  "indexes": [
    {
      "collectionGroup": "shared_lists",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "household_id", "order": "ASCENDING" },
        { "fieldPath": "updated_date", "order": "DESCENDING" }
      ]
    }
  ]
}
```

---

## Provider Debug

### Watch Provider Changes

```dart
Consumer<ShoppingListsProvider>(
  builder: (context, provider, child) {
    debugPrint('🔄 ShoppingListsProvider rebuild');
    debugPrint('🔄 Lists: ${provider.lists.length}');
    return ...;
  },
)
```

### Check Provider Dependencies

```dart
// In main.dart, add logging
ChangeNotifierProxyProvider<UserContext, ShoppingListsProvider>(
  update: (context, userContext, previous) {
    debugPrint('🔄 ShoppingListsProvider update called');
    debugPrint('🔄 UserContext.isLoggedIn: ${userContext.isLoggedIn}');
    debugPrint('🔄 UserContext.householdId: ${userContext.householdId}');
    ...
  },
)
```

---

## Network Debug

### Check Connectivity

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

final result = await Connectivity().checkConnectivity();
debugPrint('🌐 Connectivity: $result');
```

### Firebase Offline Mode

```dart
// Enable persistence (default)
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
);

// Check if from cache
snapshot.metadata.isFromCache
```

---

## Memory & Performance

### Check Widget Rebuilds

```dart
@override
Widget build(BuildContext context) {
  debugPrint('🎨 ${widget.runtimeType} build');
  return ...;
}
```

### Profile Mode

```bash
flutter run --profile
```

### DevTools

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

---

## Useful Debug Commands

### Flutter

```bash
# Clean build
flutter clean && flutter pub get

# Analyze code
flutter analyze

# Run tests
flutter test

# Check dependencies
flutter pub outdated
```

### Firebase

```bash
# Deploy rules
firebase deploy --only firestore:rules

# Deploy indexes
firebase deploy --only firestore:indexes

# View logs
firebase functions:log

# Clear emulator data
firebase emulators:start --clear
```

---

## Adding Debug Logs

### Standard Pattern

```dart
import 'package:flutter/foundation.dart';

class MyProvider with ChangeNotifier {
  void myMethod() {
    if (kDebugMode) {
      debugPrint('📋 MyProvider.myMethod called');
      debugPrint('📋 Current state: $_state');
    }

    // ... logic

    if (kDebugMode) {
      debugPrint('📋 MyProvider.myMethod completed');
    }
  }
}
```

### Error Logging

```dart
try {
  await riskyOperation();
} catch (e, stackTrace) {
  if (kDebugMode) {
    debugPrint('🔴 Error in riskyOperation: $e');
    debugPrint('🔴 Stack: $stackTrace');
  }
  rethrow; // or handle gracefully
}
```

---

## Quick Checklist

When debugging:

1. **Check Firebase Connection**
   - Is Firebase initialized?
   - Are emulators running (if using)?

2. **Check UserContext**
   - Is user logged in?
   - Is householdId set?

3. **Check Provider**
   - Is provider initialized?
   - Is subscription active?
   - Is notifyListeners() called?

4. **Check Firestore**
   - Does document exist?
   - Are security rules correct?
   - Are indexes created?

5. **Check UI**
   - Is Consumer/Watch used correctly?
   - Is widget rebuilding?
