# CODE.md - MemoZap Development Patterns

> **For AI agents only** | Updated: 26/10/2025 | Version: 2.1

---

## 🧩 Architecture Principles

### Core Patterns

```yaml
Provider Pattern:
  - Every stateful module uses ChangeNotifier
  - Must include addListener/removeListener
  - init() and dispose() required

Repository Layer:
  - Centralizes data logic (CRUD only)
  - Use async/await with error handling
  - No direct Firebase access from UI

Model Layer:
  - Must be JSON serializable (@JsonSerializable)
  - No UI logic in models
  - Immutable when possible

State Management:
  - Prefer Provider or Riverpod
  - Minimal dependencies
  - Clear separation of concerns
```

---

## 🔄 Provider Pattern

### Standard Template

```dart
// ✅ Complete Provider Example
class TasksProvider extends ChangeNotifier {
  final TasksRepository _repository;
  final UserContext _userContext;
  
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Constructor
  TasksProvider(this._repository, this._userContext) {
    _userContext.addListener(_onUserChanged);
    _loadTasks();
  }
  
  // Dispose (CRITICAL!)
  @override
  void dispose() {
    _userContext.removeListener(_onUserChanged); // Must remove!
    super.dispose();
  }
  
  // Methods
  Future<void> addTask(Task task) async {
    try {
      _setLoading(true);
      await _repository.addTask(task);
      _tasks.add(task);
      notifyListeners(); // Always after state change!
    } catch (e) {
      _setError('Failed to add task: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Private helpers
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  Future<void> _loadTasks() async {
    // Load logic
  }
  
  void _onUserChanged() {
    _loadTasks();
  }
}
```

### Lazy Provider Pattern (Performance Optimization)

**Problem:** Provider loads data in constructor → slow app startup

**Solution:** Load data only when needed

```dart
class ProductsProvider extends ChangeNotifier {
  final ProductsRepository _repository;
  final UserContext _userContext;
  
  List<Product> _products = [];
  bool _isInitialized = false;
  
  ProductsProvider(this._repository, this._userContext) {
    // ✅ DON'T load data here!
    _userContext.addListener(_onUserChanged);
  }
  
  // ✅ Load only when called
  Future<void> ensureInitialized() async {
    if (_isInitialized) return; // Already loaded
    _isInitialized = true;
    await _loadProducts();
  }
  
  Future<void> _loadProducts() async {
    try {
      _products = await _repository.getAll();
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }
}
```

**Usage in Screen:**

```dart
class AddProductScreen extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    // Load products only when entering this screen
    _loadProducts();
  }
  
  Future<void> _loadProducts() async {
    final products = Provider.of<ProductsProvider>(
      context, 
      listen: false,
    );
    await products.ensureInitialized(); // Load now!
  }
}
```

**Benefits:**
- ⚡ Faster app startup (don't load unused providers)
- 💾 Less memory usage (only active providers in RAM)
- 🎯 Load only what you need

**When to use:**
- Provider not needed immediately at startup
- Data-heavy providers (large lists, images)
- Features used occasionally (settings, reports)

**Example from project:**
```dart
// ProductsProvider - only needed when adding items
// InventoryProvider - only needed in pantry screen
// LocationsProvider - only needed during shopping
```

**Performance impact:**
- Before: 11 Providers loaded at startup
- After: 5 essential Providers → 50% faster startup!

### Critical Rules

```yaml
✅ Always:
  - notifyListeners() after state change
  - removeListener() in dispose()
  - Try-catch around async operations
  - Unmodifiable getters for lists

❌ Never:
  - Forget to call super.dispose()
  - Modify state without notifyListeners()
  - Direct Firebase access
  - Expose mutable state
```

### Provider Cleanup (CRITICAL - Memory Leaks!)

**5 Things to ALWAYS Clean in dispose():**

```dart
@override
void dispose() {
  // 1. UserContext listener (MOST COMMON leak!)
  _userContext.removeListener(_onUserChanged);
  
  // 2. Controllers
  _textController.dispose();
  _animationController.dispose();
  _scrollController.dispose();
  
  // 3. Timers & Periodic operations
  _periodicTimer?.cancel();
  _debounceTimer?.cancel();
  
  // 4. Stream subscriptions
  _streamSubscription?.cancel();
  _firestoreSubscription?.cancel();
  
  // 5. ML Kit / Platform resources
  _textRecognizer?.close();
  _imageLabeler?.close();
  
  super.dispose(); // ALWAYS last!
}
```

**What happens if you forget?**
- 💀 Memory leak - objects never freed
- 🔊 Keeps listening after widget disposed
- 🔋 Battery drain (timers keep running)
- 🐌 App slows down over time
- 💥 Potential crashes (using disposed context)

**Real example from project (happened 31 times!):**

```dart
// ❌ Memory leak pattern
class MyProvider extends ChangeNotifier {
  MyProvider(UserContext userContext) {
    userContext.addListener(_onUserChanged);
  }
  // dispose() MISSING! Listener never removed!
}

// ✅ Correct pattern
class MyProvider extends ChangeNotifier {
  final UserContext _userContext;
  
  MyProvider(this._userContext) {
    _userContext.addListener(_onUserChanged);
  }
  
  @override
  void dispose() {
    _userContext.removeListener(_onUserChanged); // Clean up!
    super.dispose();
  }
}
```

**Checklist before committing Provider:**
- [ ] Every `addListener` has matching `removeListener`
- [ ] Every `Timer` has `cancel()` in dispose
- [ ] Every `StreamSubscription` has `cancel()`
- [ ] Every `Controller` has `dispose()`
- [ ] `super.dispose()` is LAST line

---

## 🗄️ Repository Pattern

### Template

```dart
// ✅ Repository Interface
abstract class TasksRepository {
  Future<List<Task>> getTasks(String userId);
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String taskId);
}

// ✅ Firebase Implementation
class FirebaseTasksRepository implements TasksRepository {
  final FirebaseFirestore _firestore;
  
  FirebaseTasksRepository(this._firestore);
  
  @override
  Future<List<Task>> getTasks(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('user_id', isEqualTo: userId)
          .where('household_id', isEqualTo: getHouseholdId()) // CRITICAL!
          .get();
      
      return snapshot.docs
          .map((doc) => Task.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw RepositoryException('Failed to load tasks: $e');
    }
  }
  
  @override
  Future<void> addTask(Task task) async {
    await _firestore
        .collection('tasks')
        .doc(task.id)
        .set(task.toJson());
  }
}
```

### 🚨 SECURITY CRITICAL: household_id Filter

**⛔ THE RULE (NEVER VIOLATE!)**

**EVERY Firestore query MUST filter by household_id**

---

#### Why This is Critical?

```dart
// ❌ WITHOUT household_id
.where('user_id', isEqualTo: userId)
// Result: User sees OTHER USERS' data from ALL households! 🔓
// This is a SECURITY BREACH!

// ✅ WITH household_id
.where('household_id', isEqualTo: householdId)
.where('user_id', isEqualTo: userId)
// Result: User sees ONLY their household data 🔒
```

#### Real Example:

```dart
// ❌ SECURITY BREACH!
Future<List<Task>> getTasks(String userId) async {
  return await _firestore
      .collection('tasks')
      .where('user_id', isEqualTo: userId)
      .get(); // User can see tasks from OTHER households!
}

// ✅ SECURE
Future<List<Task>> getTasks(String userId, String householdId) async {
  return await _firestore
      .collection('tasks')
      .where('household_id', isEqualTo: householdId) // MUST HAVE!
      .where('user_id', isEqualTo: userId)
      .get(); // Only THIS household
}
```

#### What Could Go Wrong?

**Scenario:** User A from household "family-123" can see:
- ❌ Shopping lists of household "family-456"
- ❌ Tasks of household "family-789"
- ❌ Inventory of OTHER families
- ❌ Personal data of strangers

**Impact:** 🔥 GDPR violation, privacy breach, app store removal

#### Security Checklist:

```yaml
Before committing ANY repository code:
  - [ ] Every .collection() has .where('household_id', ...)
  - [ ] No query without household_id
  - [ ] Firebase Rules enforce household_id
  - [ ] Test: Can user see other households? → NO!
```

#### Testing:

```dart
// Unit test to catch this bug
test('getTasks filters by household_id', () async {
  // Setup: Two households
  await createTask(userId: 'user1', householdId: 'house-A');
  await createTask(userId: 'user1', householdId: 'house-B');
  
  // Test: User only sees their household
  final tasks = await repository.getTasks('user1', 'house-A');
  
  expect(tasks.length, 1); // Only house-A task
  expect(tasks[0].householdId, 'house-A');
});
```

---

## 🏗️ Model Patterns

### JSON Serialization

```dart
// ✅ Model with json_serializable
import 'package:json_annotation/json_annotation.dart';

part 'task.g.dart';

@JsonSerializable(explicitToJson: true)
class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? reminder;
  final bool isCompleted;
  
  const Task({
    required this.id,
    required this.title,
    this.description,
    this.reminder,
    this.isCompleted = false,
  });
  
  // JSON methods
  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);
  
  // copyWith for immutability
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? reminder,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      reminder: reminder ?? this.reminder,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
```

### After Model Changes

```bash
# Always run after @JsonSerializable changes:
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 🎯 Common Mistakes & Solutions

### 1. const Usage (Performance Critical! ⚡)

**Impact:** Missing const = 5-10% unnecessary rebuilds

**Critical Places to Add const:**
1. SizedBox with fixed height/width
2. EdgeInsets with constants (including EdgeInsets.zero)
3. Padding with fixed values
4. Icon/Text with string literals
5. Duration with fixed milliseconds
6. PopScope/AlertDialog with static content
7. Any Widget with zero dynamic data

```dart
// ❌ Wrong - can't use const with dynamic arguments
const SizedBox(height: spacing) // spacing is variable

// ✅ Correct - const only with literals
const SizedBox(height: 16)

// ❌ Wrong - const on widget with variable props
const _StatCard(value: count) // count is variable

// ✅ Correct - no const with dynamic data
_StatCard(value: count)

// ✅ Example - Fully optimized PopScope
const PopScope(
  canPop: false,
  child: AlertDialog(
    title: const Text('כותרת'),
    content: const Text('תוכן'),
    actions: [
      const TextButton(
        onPressed: null,
        child: const Text('אישור'),
      ),
    ],
  ),
)

// ✅ EdgeInsets optimization
const EdgeInsets.zero // Not just EdgeInsets.zero
const EdgeInsets.all(16) // With literal
```

### 2. Color API (Flutter 3.22+)

```dart
// ❌ Deprecated
Colors.black.withOpacity(0.5)

// ✅ New API
Colors.black.withValues(alpha: 0.5)
```

### 3. Async Callbacks

```dart
// ❌ Wrong - type mismatch
onPressed: _asyncFunc // Future<void> instead of void

// ✅ Correct - wrap in anonymous function
onPressed: () => _asyncFunc()

// ✅ Also correct - async anonymous function
onPressed: () async {
  await _asyncFunc();
}
```

### 4. Context After Await (Common Crash!)

**Problem:** Widget can be disposed DURING await → context becomes invalid

**When this happens:**
- User navigates away during async operation
- Widget disposed before async completes
- Context no longer valid → CRASH! 💥

**Real scenarios:**
- Saving data while user presses back button
- Loading content while switching screens
- API call while app goes to background

```dart
// ❌ WRONG - context may be invalid
Future<void> _saveAndNavigate() async {
  await _save(); // Takes 2 seconds
  // User pressed back during these 2 seconds!
  Navigator.of(context).push(...); // CRASH!
  ScaffoldMessenger.of(context).showSnackBar(...); // CRASH!
}

// ✅ CORRECT - capture before await
Future<void> _saveAndNavigate() async {
  // 1. Capture BEFORE any await
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  
  // 2. Async operation (context might become invalid here)
  await _save();
  
  // 3. Check if widget still alive
  if (!mounted) return; // Widget disposed - abort!
  
  // 4. Use captured references (not context!)
  navigator.push(MaterialPageRoute(
    builder: (_) => NextScreen(),
  ));
  messenger.showSnackBar(
    SnackBar(content: Text('נשמר בהצלחה')),
  );
}
```

**Key Points:**
1. Capture `Navigator.of(context)` BEFORE await
2. Capture `ScaffoldMessenger.of(context)` BEFORE await
3. Check `if (!mounted) return;` AFTER await
4. Use captured references, never `context` directly

**What NOT to capture:**
```dart
// ❌ Don't capture Theme or MediaQuery
final theme = Theme.of(context); // May change
final size = MediaQuery.of(context).size; // May change

// ✅ These are safe to capture
final navigator = Navigator.of(context);
final messenger = ScaffoldMessenger.of(context);
```

### 5. UserContext Integration

```dart
// ❌ Wrong - memory leak!
class MyProvider extends ChangeNotifier {
  MyProvider(UserContext userContext) {
    userContext.addListener(_onUserChanged);
  }
  // Missing removeListener in dispose!
}

// ✅ Correct - clean disposal
class MyProvider extends ChangeNotifier {
  final UserContext _userContext;
  
  MyProvider(this._userContext) {
    _userContext.addListener(_onUserChanged);
  }
  
  @override
  void dispose() {
    _userContext.removeListener(_onUserChanged); // Must remove!
    super.dispose();
  }
}
```

### 6. Relative Imports (Project Standard)

**Rule:** NEVER use relative paths (`../`) in imports

```dart
// ❌ WRONG - relative imports
import '../models/task.dart';
import '../../widgets/common/button.dart';
import '../../../providers/tasks_provider.dart';

// ✅ CORRECT - package imports
import 'package:memozap/models/task.dart';
import 'package:memozap/widgets/common/button.dart';
import 'package:memozap/providers/tasks_provider.dart';
```

**Why package imports are better:**

1. ✅ **Works everywhere** - no path confusion
   - Move files without breaking imports
   - Same import works in any file

2. ✅ **Easier refactoring**
   - IDE auto-updates package imports
   - Relative paths break easily

3. ✅ **Better IDE support**
   - Autocomplete works better
   - "Go to definition" more reliable

4. ✅ **Project standard**
   - All MemoZap code uses package imports
   - Consistent with Flutter best practices

**How to fix relative imports:**

```dart
// Before
import '../../models/shopping_list.dart';

// After
import 'package:memozap/models/shopping_list.dart';
```

**Note:** Package name is `memozap` (from pubspec.yaml), not project folder name

---

## 🧪 Testing Patterns

### Widget Testing - 4 States

```dart
// ✅ Always test these 4 states:
testWidgets('Loading state', (tester) async {
  // Mock loading state
  when(() => mockProvider.isLoading).thenReturn(true);
  
  await tester.pumpWidget(MyWidget());
  
  // Expect skeleton/shimmer
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});

testWidgets('Error state', (tester) async {
  when(() => mockProvider.errorMessage).thenReturn('Error occurred');
  
  await tester.pumpWidget(MyWidget());
  
  // Expect error message + retry button
  expect(find.text('Error occurred'), findsOneWidget);
  expect(find.text('Retry'), findsOneWidget);
});

testWidgets('Empty state', (tester) async {
  when(() => mockProvider.items).thenReturn([]);
  
  await tester.pumpWidget(MyWidget());
  
  // Expect empty message + CTA
  expect(find.text('No items'), findsOneWidget);
  expect(find.text('Add Item'), findsOneWidget);
});

testWidgets('Content state', (tester) async {
  when(() => mockProvider.items).thenReturn([item1, item2]);
  
  await tester.pumpWidget(MyWidget());
  
  // Expect content rendering
  expect(find.text(item1.title), findsOneWidget);
  expect(find.text(item2.title), findsOneWidget);
});
```

### Mock Patterns

```dart
// ✅ Complete mock setup
import 'package:mocktail/mocktail.dart';

class MockTasksProvider extends Mock implements TasksProvider {}

void main() {
  late MockTasksProvider mockProvider;
  
  setUp(() {
    mockProvider = MockTasksProvider();
    
    // Stub all properties used in tests
    when(() => mockProvider.tasks).thenReturn([]);
    when(() => mockProvider.isLoading).thenReturn(false);
    when(() => mockProvider.errorMessage).thenReturn(null);
  });
  
  testWidgets('Test name', (tester) async {
    // Override specific stubs for this test
    when(() => mockProvider.tasks).thenReturn([testTask]);
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tasksProvider.overrideWith((ref) => mockProvider),
        ],
        child: MyApp(),
      ),
    );
    
    // Assertions
  });
}
```

### Stub Property Error Fix

```dart
// ❌ Error: "The getter 'x' isn't defined for the type 'Mock'"
// Cause: Missing stub for property

// ✅ Fix: Add explicit stub
when(() => mockProvider.pendingSuggestionsCount).thenReturn(2);
```

### Testing Best Practices - Widget Finders

**❌ WRONG - Don't Access Widget Properties:**

```dart
// This will FAIL in Flutter tests!
find.byWidgetPredicate(
  (widget) => widget is TextFormField && 
               widget.decoration != null
)

// Also fails:
find.byWidgetPredicate(
  (widget) => widget.textInputAction == TextInputAction.next
)
```

**Why it fails:**
- TextFormField doesn't expose `decoration` as public getter in tests
- Widget properties are not accessible via predicates
- This pattern breaks with Flutter's testing architecture

**✅ CORRECT - Use Semantics or Keys:**

```dart
// Best practice - adds accessibility too!
find.bySemanticsLabel(AppStrings.auth.emailLabel)
find.bySemanticsLabel('שם משתמש')

// Also good - explicit keys
find.byKey(Key('email_field'))
find.byKey(Key('password_field'))

// For types
find.byType(TextFormField)
```

**Why bySemanticsLabel is better:**
1. ✅ Works in tests
2. ✅ Adds accessibility (screen readers)
3. ✅ Doesn't break with UI changes
4. ✅ Follows Flutter best practices
5. ✅ Better for localization testing

**Real example from project:**

```dart
// ❌ Before (login_flow_integration_test.dart)
find.byWidgetPredicate(
  (widget) => widget is TextFormField && 
               widget.decoration?.labelText == 'Email'
) // Failed!

// ✅ After
find.bySemanticsLabel(AppStrings.auth.emailLabel) // Works!
```

**Fixed in project:**
- `login_flow_integration_test.dart` - 13 fixes
- `register_flow_integration_test.dart` - 13 fixes
- All `widget.decoration` → `bySemanticsLabel`

---

## 🪵 Logging Standards

### Format

```dart
// ✅ Consistent format with emoji
log("✅ Task added successfully [TasksProvider]");
log("⚠️ Low stock detected [InventoryProvider]");
log("❌ Failed to sync: $error [SyncService]");
```

### Limits & Best Practices

**Rule:** Maximum 15 debugPrint per file

**Why 15?**
- More = noise, hard to debug in production logs
- Real example: `settings_screen.dart` had 31 logs → reduced to 15 (52% cut)
- Still fully debuggable with focused logging

**What to KEEP:**
```yaml
✅ Keep:
  - Lifecycle (initState, dispose)
  - Errors (try-catch blocks)
  - Critical actions (logout, delete, payment)
  - Warnings (validation failures)
```

**What to REMOVE:**
```yaml
❌ Remove:
  - Function start/end ("_loadSettings started/ended")
  - Routine CRUD operations (simple add/edit/delete)
  - Simple navigations (screen to screen)
  - UI button presses ("button X pressed")
```

**If you need more than 15 logs:**
Use `logger` package with levels:

```dart
import 'package:logger/logger.dart';

final logger = Logger();

logger.d('Debug info');      // Only in dev
logger.i('General info');    // Normal operations
logger.w('Warning');         // Important issues
logger.e('Error', error: e); // Critical problems
```

**Benefits of logger package:**
- Filter by level in production
- Better formatting with colors
- Stack traces for errors
- File output support

---

## 🔄 CRUD Flow Template

```dart
// Create
Future<void> createItem(Item item) async {
  // 1. Validate
  if (!_validate(item)) throw ValidationException();
  
  // 2. Repository
  await _repository.create(item);
  
  // 3. Update state
  _items.add(item);
  notifyListeners();
  
  // 4. Log
  log("✅ Item created [ItemsProvider]");
}

// Read
Future<void> loadItems() async {
  try {
    _setLoading(true);
    _items = await _repository.getAll();
    notifyListeners();
  } catch (e) {
    _setError('Failed to load: $e');
  } finally {
    _setLoading(false);
  }
}

// Update
Future<void> updateItem(Item item) async {
  await _repository.update(item);
  
  // Rebuild UI only if changed
  final index = _items.indexWhere((i) => i.id == item.id);
  if (index != -1) {
    _items[index] = item;
    notifyListeners();
  }
}

// Delete
Future<void> deleteItem(String id) async {
  // Soft delete if possible
  await _repository.softDelete(id);
  _items.removeWhere((i) => i.id == id);
  notifyListeners();
}
```

---

## 📦 Build Commands

```bash
# Get dependencies
flutter pub get

# Generate code (after model changes)
flutter pub run build_runner build --delete-conflicting-outputs

# Clean build
flutter pub run build_runner clean
flutter pub run build_runner build

# Format code
dart format lib/

# Analyze
flutter analyze

# Test
flutter test
flutter test test/widgets/my_widget_test.dart # Single file
```

---

## 🔗 Related Docs

| Topic | File |
|-------|------|
| **Operation guide** | GUIDE.md |
| **UI/UX patterns** | DESIGN.md |
| **Firebase/models** | TECH.md |
| **Past mistakes** | LESSONS_LEARNED.md |

---

**End of CODE.md** 🎯

*Follow these patterns for consistent, maintainable code.*
