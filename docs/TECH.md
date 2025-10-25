# 🔧 TECH.md - MemoZap Technical Guide
> **For AI Agents** | Focus: Firebase, Security, Models | Updated: 25/10/2025

---

## 🎯 Purpose

Technical reference for:
- Firebase/Firestore structure
- Security rules
- Model serialization
- Dependencies
- Build configuration

---

## 🔥 Firebase Structure

### Collections

```
firestore/
  shopping_lists/
    {listId}/
      id: string
      name: string
      created_by: string (userId)
      created_date: timestamp
      updated_date: timestamp
      household_id: string ⚠️ CRITICAL!
      
      items: array [UnifiedListItem]
      shared_users: array [SharedUser]
      pending_requests: array [PendingRequest]
  
  users/
    {userId}/
      id: string
      email: string
      display_name: string
      household_id: string
      created_date: timestamp
  
  households/
    {householdId}/
      id: string
      name: string
      created_by: string
      members: array [userId]
```

### Required Indexes

```dart
// Create in Firebase Console → Firestore → Indexes

1. shopping_lists:
   - household_id (Ascending) + created_date (Descending)
   - household_id (Ascending) + updated_date (Descending)

2. Composite (if using complex queries):
   - household_id + status + updated_date
```

---

## 🔐 Security Rules

### Core Principles

1. **household_id filter** - MANDATORY on ALL queries
2. **Role-based access** - Owner/Admin/Editor/Viewer
3. **Editor restrictions** - Can only modify pending_requests
4. **Owner exclusive** - Only owner can delete

### Rules Summary

```javascript
// firestore.rules (simplified)

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper: Check user role
    function getUserRole(list) {
      let userId = request.auth.uid;
      
      // Owner check
      if (userId == list.data.created_by) return 'owner';
      
      // Shared user check
      let sharedUser = list.data.shared_users
        .filter(u => u.user_id == userId);
      
      return sharedUser.size() > 0 
        ? sharedUser[0].role 
        : null;
    }
    
    // Helper: Can read?
    function canRead(list) {
      let role = getUserRole(list);
      return role in ['owner', 'admin', 'editor', 'viewer'];
    }
    
    // Helper: Can write?
    function canWrite(list) {
      let role = getUserRole(list);
      return role in ['owner', 'admin'];
    }
    
    // Shopping Lists Rules
    match /shopping_lists/{listId} {
      // Read: All roles
      allow read: if request.auth != null && canRead(resource);
      
      // Create: Any authenticated user
      allow create: if request.auth != null &&
        request.resource.data.created_by == request.auth.uid &&
        request.resource.data.household_id == request.auth.token.household_id;
      
      // Update: Owner/Admin (full), Editor (pending_requests only)
      allow update: if request.auth != null && (
        canWrite(resource) ||
        (getUserRole(resource) == 'editor' && 
         request.resource.data.diff(resource.data)
           .affectedKeys()
           .hasOnly(['pending_requests', 'updated_date']))
      );
      
      // Delete: Owner only
      allow delete: if request.auth != null && 
        getUserRole(resource) == 'owner';
    }
  }
}
```

**Deploy:**
```bash
firebase deploy --only firestore:rules
```

---

## 📦 Models & Serialization

### JSON Serializable Pattern

```dart
// ALWAYS use @JsonSerializable
import 'package:json_annotation/json_annotation.dart';

part 'model_name.g.dart';

@JsonSerializable(explicitToJson: true)
class ModelName {
  final String id;
  final String name;
  
  @JsonKey(name: 'created_date')
  final DateTime createdDate;
  
  // Constructor
  ModelName({
    required this.id,
    required this.name,
    required this.createdDate,
  });
  
  // Factory constructors
  factory ModelName.fromJson(Map<String, dynamic> json) =>
      _$ModelNameFromJson(json);
  
  Map<String, dynamic> toJson() => _$ModelNameToJson(this);
  
  // CopyWith
  ModelName copyWith({
    String? id,
    String? name,
    DateTime? createdDate,
  }) {
    return ModelName(
      id: id ?? this.id,
      name: name ?? this.name,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}
```

### Build Runner

```bash
# Generate .g.dart files
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate)
flutter pub run build_runner watch --delete-conflicting-outputs
```

**⚠️ CRITICAL:** Run build_runner after EVERY model change!

---

## 📚 Dependencies

### Core Packages (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^3.11.0
  firebase_auth: ^5.3.4
  firebase_firestore: ^5.5.5
  cloud_functions: ^5.2.3
  
  # State Management
  provider: ^6.1.2
  
  # JSON Serialization
  json_annotation: ^4.9.0
  
  # Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # UI
  google_fonts: ^6.2.1
  
  # Localization
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
  
  # Utilities
  uuid: ^4.5.1
  path_provider: ^2.1.5

dev_dependencies:
  # Code Generation
  build_runner: ^2.4.13
  json_serializable: ^6.8.0
  
  # Testing
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  
  # Linting
  flutter_lints: ^5.0.0
```

---

## 🔧 Build Configuration

### Android (android/app/build.gradle)

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}

dependencies {
    // Firebase
    implementation platform('com.google.firebase:firebase-bom:33.7.0')
}
```

### iOS (ios/Podfile)

```ruby
platform :ios, '13.0'

# Firebase
pod 'Firebase/Analytics'
pod 'Firebase/Auth'
pod 'Firebase/Firestore'
```

---

## 🔄 Common Technical Patterns

### 1. Firestore Query with household_id

```dart
// ✅ CORRECT - ALWAYS filter by household_id
Future<List<ShoppingList>> getLists(String householdId) async {
  final snapshot = await _firestore
      .collection('shopping_lists')
      .where('household_id', isEqualTo: householdId)
      .orderBy('created_date', descending: true)
      .get();
  
  return snapshot.docs
      .map((doc) => ShoppingList.fromJson(doc.data()))
      .toList();
}

// ❌ WRONG - Missing household_id filter
Future<List<ShoppingList>> getLists() async {
  final snapshot = await _firestore
      .collection('shopping_lists')
      .get(); // SECURITY RISK!
  ...
}
```

### 2. Add/Update with Timestamps

```dart
// ✅ CORRECT - Use FieldValue.serverTimestamp()
Future<void> createList(ShoppingList list) async {
  await _firestore
      .collection('shopping_lists')
      .doc(list.id)
      .set({
        ...list.toJson(),
        'created_date': FieldValue.serverTimestamp(),
        'updated_date': FieldValue.serverTimestamp(),
      });
}

// ✅ CORRECT - Update updated_date
Future<void> updateList(ShoppingList list) async {
  await _firestore
      .collection('shopping_lists')
      .doc(list.id)
      .update({
        ...list.toJson(),
        'updated_date': FieldValue.serverTimestamp(),
      });
}
```

### 3. Array Operations

```dart
// ✅ Add to array
await _firestore
    .collection('shopping_lists')
    .doc(listId)
    .update({
      'shared_users': FieldValue.arrayUnion([sharedUser.toJson()]),
      'updated_date': FieldValue.serverTimestamp(),
    });

// ✅ Remove from array
await _firestore
    .collection('shopping_lists')
    .doc(listId)
    .update({
      'shared_users': FieldValue.arrayRemove([sharedUser.toJson()]),
      'updated_date': FieldValue.serverTimestamp(),
    });
```

### 4. Error Handling

```dart
// ✅ CORRECT - Handle all error cases
try {
  final doc = await _firestore
      .collection('shopping_lists')
      .doc(listId)
      .get();
  
  if (!doc.exists) {
    throw Exception('List not found');
  }
  
  return ShoppingList.fromJson(doc.data()!);
  
} on FirebaseException catch (e) {
  // Log Firebase-specific error
  debugPrint('❌ Firebase error: ${e.code} - ${e.message}');
  rethrow;
  
} catch (e) {
  // Log generic error
  debugPrint('❌ Error loading list: $e');
  rethrow;
}
```

---

## ⚡ Performance Tips

### 1. Use Offline Persistence

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Enable offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  runApp(MyApp());
}
```

### 2. Limit Query Results

```dart
// ✅ Use .limit() for large collections
final snapshot = await _firestore
    .collection('shopping_lists')
    .where('household_id', isEqualTo: householdId)
    .orderBy('created_date', descending: true)
    .limit(50) // Limit results
    .get();
```

### 3. Use Transactions for Critical Updates

```dart
// ✅ Use transactions for atomic updates
Future<void> transferOwnership(String listId, String newOwnerId) async {
  await _firestore.runTransaction((transaction) async {
    final listRef = _firestore.collection('shopping_lists').doc(listId);
    final listDoc = await transaction.get(listRef);
    
    if (!listDoc.exists) throw Exception('List not found');
    
    transaction.update(listRef, {
      'created_by': newOwnerId,
      'updated_date': FieldValue.serverTimestamp(),
    });
  });
}
```

---

## 🧪 Testing Setup

### Mock Firebase

```dart
// test/helpers/mock_firestore.dart

class MockFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock 
    implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock 
    implements DocumentReference<Map<String, dynamic>> {}

// test/repositories/firebase_shopping_lists_repository_test.dart

void main() {
  late MockFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  
  setUp(() {
    mockFirestore = MockFirestore();
    mockCollection = MockCollectionReference();
    
    when(mockFirestore.collection('shopping_lists'))
        .thenReturn(mockCollection);
  });
  
  test('getLists filters by household_id', () async {
    // Test implementation
  });
}
```

---

## ❌ Common Mistakes

### 1. Missing household_id Filter

```dart
// ❌ WRONG - Security risk!
_firestore.collection('shopping_lists').get();

// ✅ CORRECT
_firestore
    .collection('shopping_lists')
    .where('household_id', isEqualTo: householdId)
    .get();
```

### 2. Forgetting build_runner

```dart
// ❌ Changed model but forgot to run build_runner
// Result: Compilation errors about missing .g.dart

// ✅ ALWAYS run after model changes
// flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Not Using FieldValue.serverTimestamp()

```dart
// ❌ WRONG - Client timestamp (can be wrong)
'created_date': DateTime.now()

// ✅ CORRECT - Server timestamp (always accurate)
'created_date': FieldValue.serverTimestamp()
```

### 4. Modifying Firestore Directly from UI

```dart
// ❌ WRONG - Direct Firestore access from screen
class MyScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  void _addItem() {
    _firestore.collection('shopping_lists').add(...);
  }
}

// ✅ CORRECT - Use Repository → Provider → Screen
class MyScreen extends StatelessWidget {
  void _addItem() {
    Provider.of<ShoppingListsProvider>(context, listen: false)
        .addList(...);
  }
}
```

---

## ✅ Technical Checklist

### Before Deploying:
- [ ] All queries filter by household_id
- [ ] Firestore rules deployed
- [ ] Indexes created in Firebase Console
- [ ] build_runner executed after model changes
- [ ] All timestamps use FieldValue.serverTimestamp()
- [ ] Repository pattern used (no direct Firestore in UI)
- [ ] Error handling in all async operations
- [ ] Tests pass (flutter test)
- [ ] No sensitive data in logs

---

## 🔗 Related Docs

| Need | See |
|------|-----|
| Code patterns | `CODE.md` |
| UI/UX design | `DESIGN.md` |
| MCP tools | `GUIDE.md` |
| Past mistakes | `LESSONS_LEARNED.md` |

---

**📍 Location:** `C:\projects\salsheli\docs\TECH.md`  
**📅 Version:** 1.0  
**✍️ Updated:** 25/10/2025

---

## 💡 Quick Tips

1. **household_id** - Filter EVERY Firestore query
2. **build_runner** - Run after EVERY model change
3. **Timestamps** - Use FieldValue.serverTimestamp()
4. **Repository** - NEVER access Firestore directly from UI
5. **Errors** - Try-catch ALL async Firebase operations
6. **Rules** - Test in Firebase Console before deploying
7. **Indexes** - Create BEFORE running complex queries
8. **Offline** - Enable persistence for better UX

**🔧 Tech = Security + Performance + Maintainability**
