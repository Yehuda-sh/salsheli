# CODE.md - MemoZap Development Patterns

> **For AI agents only** | Updated: 25/10/2025 | Version: 2.0

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

### household_id Rule (CRITICAL!)

```dart
// ✅ ALWAYS filter by household_id
.where('household_id', isEqualTo: householdId)

// ❌ Security risk - sees other users' data!
.where('user_id', isEqualTo: userId) // Missing household_id!
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

### 1. const Usage

```dart
// ❌ Wrong - can't use const with dynamic arguments
const SizedBox(height: spacing) // spacing is variable

// ✅ Correct - const only with literals
const SizedBox(height: 16)

// ❌ Wrong - const on widget with variable props
const _StatCard(value: count) // count is variable

// ✅ Correct - no const with dynamic data
_StatCard(value: count)
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

### 4. Context After Await

```dart
// ❌ Wrong - context may be invalid after await
await saveData();
Navigator.of(context).push(...); // Dangerous!

// ✅ Correct - capture navigator before await
final navigator = Navigator.of(context);
await saveData();
if (!mounted) return; // Check if still mounted
navigator.push(...);
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

---

## 🪵 Logging Standards

### Format

```dart
// ✅ Consistent format with emoji
log("✅ Task added successfully [TasksProvider]");
log("⚠️ Low stock detected [InventoryProvider]");
log("❌ Failed to sync: $error [SyncService]");
```

### Limits

```yaml
Maximum per file: 15 logs
Keep:
  - Lifecycle (initState, dispose)
  - Errors (try-catch)
  - Critical actions (logout, delete)

Remove:
  - Start/end of normal functions
  - Simple navigations
  - UI button presses
```

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
