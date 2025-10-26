# TECH.md - MemoZap Technical Reference

> Machine-readable | Firebase + Security + Models | Updated: 25/10/2025

---

## FIREBASE STRUCTURE

```yaml
firestore:
  shopping_lists/{listId}:
    id: string
    name: string
    created_by: string (userId)
    created_date: timestamp
    updated_date: timestamp
    household_id: string  # CRITICAL - ALWAYS filter by this!
    items: array[UnifiedListItem]
    shared_users: array[SharedUser]
    pending_requests: array[PendingRequest]
  
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

indexes_required:
  - household_id (Asc) + created_date (Desc)
  - household_id (Asc) + updated_date (Desc)
```

---

## SECURITY RULES

```yaml
core_principles:
  1. household_id filter - MANDATORY on ALL queries
  2. role_based_access - Owner/Admin/Editor/Viewer
  3. editor_restrictions - Can only modify pending_requests
  4. owner_exclusive - Only owner can delete

roles:
  owner: full_access + delete
  admin: full_access
  editor: read + modify_pending_requests_only
  viewer: read_only

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
  - firebase_core: ^3.11.0
  - firebase_auth: ^5.3.4
  - firebase_firestore: ^5.5.5
  - cloud_functions: ^5.2.3

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
  - google_fonts: ^6.2.1

l10n:
  - flutter_localizations (sdk)
  - intl: ^0.19.0

utils:
  - uuid: ^4.5.1
  - path_provider: ^2.1.5

testing:
  - flutter_test (sdk)
  - mockito: ^5.4.4
  - flutter_lints: ^5.0.0 (dev)
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
  compileSdkVersion: 34
  minSdkVersion: 21
  targetSdkVersion: 34
  firebase_bom: 33.7.0

ios:
  platform: 13.0
  pods:
    - Firebase/Analytics
    - Firebase/Auth
    - Firebase/Firestore
```

---

End of Technical Reference
Version: 1.0 | Date: 25/10/2025
Optimized for AI parsing - minimal formatting, maximum data density.
