# 👨‍💻 Developer Guide - Salsheli

> **מטרה:** כל מה שמפתח צריך במקום אחד  
> **עדכון:** 18/10/2025 | **גרסה:** 1.0 - מדריך מאוחד

---

## 📚 תוכן עניינים

- [🎯 Quick Reference - תשובות ב-30 שניות](#quick-reference)
- [🏗️ Architecture Patterns](#architecture-patterns)
- [💻 Code Examples & Best Practices](#code-examples--best-practices)
- [🧪 Testing Guidelines](#testing-guidelines)
- [🔒 Security Best Practices](#security-best-practices)
- [⚡ Performance Optimization](#performance-optimization)
- [📋 Checklists](#checklists)

---

## 🎯 Quick Reference

### Dead Code Detection (30 שניות)

**5-Step Verification:**
```powershell
# 1. Full import search
Ctrl+Shift+F → "import.*my_file.dart"

# 2. Relative import search (CRITICAL!)
Ctrl+Shift+F → "folder_name/my_file"

# 3. Class name search
Ctrl+Shift+F → "MyClassName"

# 4. Check related files
# data → screens, config → providers, model → repositories

# 5. Read file itself
# Look for "EXAMPLE", "DO NOT USE", "דוגמה בלבד"
```

**Decision:**
- 0 imports + 0 uses + verified → 🗑️ **Delete**
- Any doubt → ❓ **Ask user**

---

### Dormant Code (2 דקות)

**4-Question Framework:**
1. Does model support it? (field exists)
2. Is it useful UX?
3. Is code quality high? (90+/100)
4. Quick to implement? (<30 min)

**Result:**
- **4/4** → 🚀 Activate
- **0-3** → 🗑️ Delete

---

### Constants Location

| Type | Location | Example |
|------|----------|---------|
| **Spacing** | `lib/core/ui_constants.dart` | `kSpacingSmall` (8px) |
| **Colors** | `lib/core/ui_constants.dart` | `kStickyYellow` |
| **UI** | `lib/core/ui_constants.dart` | `kButtonHeight` (48px) |
| **Business** | `lib/config/` | `HouseholdConfig` |

---

### Deprecated APIs

| Old ❌ | New ✅ | Why |
|--------|--------|-----|
| `.withOpacity(0.5)` | `.withValues(alpha: 0.5)` | Flutter 3.22+ |
| `value` (Dropdown) | `initialValue` | API change |
| `kQuantityFieldWidth` | `kFieldWidthNarrow` | Renamed |
| `kBorderRadiusFull` | `kRadiusPill` | Renamed |

---

### Async Callbacks

```dart
// ❌ Type Error
onPressed: _asyncFunction

// ✅ Wrapped
onPressed: () => _asyncFunction()
```

---

### Context Management

```dart
// ❌ Dangerous
await operation();
Navigator.push(context, ...);

// ✅ Safe
final navigator = Navigator.of(context);
await operation();
if (mounted) navigator.push(...);
```

---

## 🏗️ Architecture Patterns

### 1. Repository Pattern

**Interface + Implementation:**
```dart
// Abstract interface
abstract class MyRepository {
  Future<List<Item>> fetchItems(String householdId);
  Future<void> createItem(Item item, String householdId);
}

// Firebase implementation
class FirebaseMyRepository implements MyRepository {
  final FirebaseFirestore _firestore;
  
  @override
  Future<List<Item>> fetchItems(String householdId) async {
    final snapshot = await _firestore
      .collection('items')
      .where('household_id', isEqualTo: householdId) // ⚠️ Critical!
      .get();
    
    return snapshot.docs.map((doc) => 
      Item.fromJson(doc.data())
    ).toList();
  }
}
```

**Why:**
- ✅ Easy to swap implementations (Firestore → SQLite)
- ✅ Easy to mock for testing
- ✅ Centralized data access
- ✅ Enforces household_id filtering

---

### 2. Provider Pattern

**Template:**
```dart
class MyProvider extends ChangeNotifier {
  final MyRepository _repository;
  final UserContext _userContext;
  
  // State
  List<Item> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _items.isEmpty;
  
  // Constructor
  MyProvider(this._repository, this._userContext) {
    _userContext.addListener(_onUserChanged);
    _loadData();
  }
  
  // Lifecycle
  @override
  void dispose() {
    _userContext.removeListener(_onUserChanged);
    super.dispose();
  }
  
  // Methods
  void _onUserChanged() {
    _loadData();
  }
  
  Future<void> _loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final householdId = _userContext.householdId;
      if (householdId == null) {
        _items = [];
        return;
      }
      
      _items = await _repository.fetchItems(householdId);
    } catch (e) {
      debugPrint('❌ _loadData: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      if (mounted) notifyListeners();
    }
  }
  
  // Recovery
  void retry() {
    _errorMessage = null;
    notifyListeners();
    _loadData();
  }
  
  void clearAll() {
    _items.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
```

---

### 3. UserContext Integration

**Pattern (mandatory):**
```dart
class MyProvider extends ChangeNotifier {
  final UserContext _userContext;
  
  MyProvider(this._userContext) {
    _userContext.addListener(_onUserChanged); // ✅ Listen
  }
  
  void _onUserChanged() {
    // React to household switch
    _loadData(_userContext.householdId);
  }
  
  @override
  void dispose() {
    _userContext.removeListener(_onUserChanged); // ✅ Cleanup!
    super.dispose();
  }
}
```

---

### 4. household_id Pattern

**Security Rule #1:**
```dart
// ❌ SECURITY ISSUE - Shows all data!
await _firestore.collection('lists').get()

// ✅ SECURE - Only household's data
await _firestore
  .collection('lists')
  .where('household_id', isEqualTo: householdId)
  .get()
```

**Why:**
- Multi-tenant security
- Data isolation
- Privacy protection

---

### 5. Loading States Pattern

**4 States Required:**
```dart
Widget build(BuildContext context) {
  final provider = context.watch<MyProvider>();
  
  // 1. Loading State
  if (provider.isLoading && provider.isEmpty) {
    return _buildSkeleton();
  }
  
  // 2. Error State
  if (provider.hasError) {
    return _buildError();
  }
  
  // 3. Empty State
  if (provider.isEmpty) {
    return _buildEmpty();
  }
  
  // 4. Data State
  return _buildData();
}
```

---

### 6. Batch Processing

**For 100+ items:**
```dart
// ❌ Blocks UI
await saveAll(items); // 1000 items at once!

// ✅ Responsive
for (int i = 0; i < items.length; i += 100) {
  final batch = items.sublist(i, min(i + 100, items.length));
  await saveBatch(batch);
  
  // Allow UI to update
  await Future.delayed(Duration(milliseconds: 10));
  
  // Report progress
  onProgress?.call(i + batch.length, items.length);
}
```

**Firestore Limit:** Max **500 operations** per batch!

---

### 7. Real Project Examples

**Want to see these patterns in action?**

#### Repository Pattern:
- `lib/repositories/shopping_lists_repository.dart` - Shopping lists CRUD
- `lib/repositories/products_repository.dart` - Products from Shufersal API
- `lib/repositories/inventory_repository.dart` - Pantry management

#### Provider Pattern:
- `lib/providers/shopping_lists_provider.dart` - Lists state management
- `lib/providers/products_provider.dart` - Products state + search
- `lib/providers/inventory_provider.dart` - Inventory tracking

#### UserContext Integration:
- `lib/providers/user_context.dart` - Main implementation
- All providers extend ChangeNotifier and listen to UserContext
- See any provider for household switching pattern

#### Sticky Notes Design:
- `lib/screens/auth/login_screen.dart` - Complete compact design example
- `lib/widgets/common/sticky_note.dart` - Base component
- `lib/widgets/common/sticky_button.dart` - Button component

**💡 Pro Tip:** Open these files to see real implementation of patterns from this guide!

---

## 💻 Code Examples & Best Practices

### 1. Async Functions

#### Problem: Type Error with Callbacks
```dart
// ❌ Type error
StickyButton(
  onPressed: _handleLogin, // Future<void> Function()
)

// ✅ Solution 1: Lambda wrapper
StickyButton(
  onPressed: () => _handleLogin(),
)

// ✅ Solution 2: With loading state
StickyButton(
  onPressed: _isLoading ? () {} : () => _handleLogin(),
  label: _isLoading ? 'מתחבר...' : 'התחבר',
)

// ✅ Solution 3: Wrapper function
void _onLoginPressed() {
  _handleLogin();
}

StickyButton(
  onPressed: _onLoginPressed,
)
```

#### Context Management
```dart
// ❌ Context invalid after await
Future<void> _handleLogin() async {
  await userContext.signIn(...);
  Navigator.push(context, ...); // ⚠️ May crash!
}

// ✅ Save references before await
Future<void> _handleLogin() async {
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  
  await userContext.signIn(...);
  
  if (!mounted) return; // ✅ Check!
  
  navigator.push(...);
  messenger.showSnackBar(...);
}
```

---

### 2. State Management

#### Loading States
```dart
class _MyScreenState extends State<MyScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  
  Future<void> _handleAction() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous errors
    });
    
    try {
      await operation();
      
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      Navigator.push(...);
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return ErrorWidget(message: _errorMessage);
    }
    
    return StickyButton(
      onPressed: _isLoading ? () {} : () => _handleAction(),
      label: _isLoading ? 'טוען...' : 'המשך',
    );
  }
}
```

---

### 3. Form Validation

```dart
class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  @override
  void dispose() {
    _emailController.dispose(); // ✅ Always dispose!
    super.dispose();
  }
  
  Future<void> _handleSubmit() async {
    // Validate before proceeding
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final email = _emailController.text.trim(); // ✅ Trim whitespace
    // ... continue
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: TextFormField(
        controller: _emailController,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'שדה חובה';
          }
          if (!value.contains('@')) {
            return 'אימייל לא תקין';
          }
          return null; // ✅ null = valid
        },
      ),
    );
  }
}
```

---

### 4. Race Condition Prevention

```dart
class UserContext extends ChangeNotifier {
  bool _isSigningUp = false; // Flag to prevent race
  
  // Auth listener
  void _onAuthStateChange(User? user) {
    if (_isSigningUp) return; // ✅ Skip during signup!
    // ... handle auth change
  }
  
  // Manual operation
  Future<void> signUp(...) async {
    _isSigningUp = true; // Lock
    try {
      await _authService.signUp(...);
      // Create user once only
    } finally {
      _isSigningUp = false; // Unlock
    }
  }
}
```

---

### 5. Error Handling

```dart
// ✅ Comprehensive error handling
try {
  await riskyOperation();
} on FirebaseAuthException catch (e) {
  // Specific Firebase errors
  switch (e.code) {
    case 'too-many-requests':
      showSnackBar('יותר מדי ניסיונות. נסה שוב מאוחר יותר.');
      break;
    case 'wrong-password':
      showSnackBar('סיסמה שגויה.');
      break;
    default:
      showSnackBar('שגיאה: ${e.message}');
  }
} on NetworkException catch (e) {
  // Network errors
  showSnackBar('בעיית רשת: $e');
} catch (e) {
  // Fallback
  showSnackBar('שגיאה לא צפויה: $e');
}
```

---

### 6. Documentation Standards

#### File Header
```dart
/// Shopping list management screen.
///
/// Features:
/// - Create new lists
/// - Edit existing lists
/// - Delete with undo
/// - Share with household
///
/// Navigation:
/// - From: HomeDashboard
/// - To: ShoppingListDetails
library;
```

#### Public Functions
```dart
/// Creates a shopping list with the given parameters.
///
/// Parameters:
/// - [name]: List name (required)
/// - [items]: Initial items (optional)
///
/// Returns the created [ShoppingList].
///
/// Throws [FirebaseException] if creation fails.
Future<ShoppingList> createList({
  required String name,
  List<ShoppingItem>? items,
}) async {
  // Implementation...
}
```

#### Private Functions
```dart
/// Validates email format.
/// Returns true if valid, false otherwise.
bool _validateEmail(String email) {
  // Implementation...
}
```

---

## 🧪 Testing Guidelines

### 1. Test Coverage Targets

| Component | Target | Priority |
|-----------|--------|----------|
| **Models** | 90%+ | 🔴 High |
| **Providers** | 80%+ | 🔴 High |
| **Repositories** | 85%+ | 🔴 High |
| **Services** | 75%+ | 🟡 Medium |
| **UI** | 60%+ | 🟢 Low |

---

### 2. Provider Test Template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([MyRepository])
void main() {
  group('MyProvider', () {
    late MockMyRepository mockRepo;
    late MyProvider provider;
    
    setUp(() {
      mockRepo = MockMyRepository();
      provider = MyProvider(mockRepo);
    });
    
    tearDown(() {
      provider.dispose();
    });
    
    test('initial state is correct', () {
      expect(provider.items, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isFalse);
    });
    
    test('load() updates items successfully', () async {
      // Arrange
      final mockItems = [item1, item2];
      when(mockRepo.fetchItems('household-1'))
        .thenAnswer((_) async => mockItems);
      
      // Act
      await provider.load('household-1');
      
      // Assert
      expect(provider.items, equals(mockItems));
      expect(provider.isLoading, isFalse);
      verify(mockRepo.fetchItems('household-1')).called(1);
    });
    
    test('load() handles errors', () async {
      // Arrange
      when(mockRepo.fetchItems('household-1'))
        .thenThrow(Exception('Network error'));
      
      // Act
      await provider.load('household-1');
      
      // Assert
      expect(provider.hasError, isTrue);
      expect(provider.errorMessage, isNotEmpty);
    });
  });
}
```

---

### 3. Widget Test Template

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('MyScreen', () {
    testWidgets('displays loading skeleton', (tester) async {
      // Arrange
      final mockProvider = MockMyProvider();
      when(mockProvider.isLoading).thenReturn(true);
      when(mockProvider.items).thenReturn([]);
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MyProvider>.value(
            value: mockProvider,
            child: MyScreen(),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(SkeletonWidget), findsWidgets);
    });
  });
}
```

---

### 4. Quick Commands

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/providers/my_provider_test.dart

# Run with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
start coverage/html/index.html # Windows
```

---

## 🔒 Security Best Practices

### 1. Firestore Security Rules

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isHouseholdMember(householdId) {
      return isSignedIn() &&
        get(/databases/$(database)/documents/households/$(householdId))
          .data.members.hasAny([request.auth.uid]);
    }
    
    // Shopping Lists - household-based
    match /shopping_lists/{listId} {
      allow read: if isHouseholdMember(resource.data.household_id);
      allow create: if isHouseholdMember(request.resource.data.household_id);
      allow update: if isHouseholdMember(resource.data.household_id) &&
                       resource.data.household_id == request.resource.data.household_id;
      allow delete: if isHouseholdMember(resource.data.household_id);
    }
  }
}
```

---

### 2. Data Validation

```dart
class MyProvider extends ChangeNotifier {
  Future<void> createList(ShoppingList list, String householdId) async {
    // ✅ Validate household_id
    assert(householdId == userContext.householdId,
      'household_id mismatch!');
    
    // ✅ Ensure household_id is set
    if (list.householdId != householdId) {
      throw Exception('household_id not set correctly');
    }
    
    await _repo.createList(list, householdId);
  }
}
```

---

### 3. Sensitive Data Handling

```dart
// ❌ NEVER log sensitive data
debugPrint('User: $email, Password: $password'); // NEVER!
debugPrint('Auth token: $token'); // NEVER!

// ✅ Log only safe data
debugPrint('User logged in: ${user.uid}');
debugPrint('🚀 Login process started');
```

---

### 4. API Key Security

```dart
// ❌ NEVER hardcode API keys
const String FIREBASE_API_KEY = 'AIza...'; // WRONG!

// ✅ Use Firebase auto-initialization
// Firebase is initialized in main.dart automatically

// ✅ For other APIs, use environment variables
const String API_KEY = String.fromEnvironment('API_KEY');
```

---

### 5. Security Checklist

**Before every commit:**
- [ ] No API keys in code
- [ ] No passwords in code
- [ ] All Firestore queries have household_id
- [ ] No sensitive data in debugPrint
- [ ] Firestore Rules tested
- [ ] Auth flow tested

---

## ⚡ Performance Optimization

### 1. Performance Rules

| Issue | Bad ❌ | Good ✅ | Impact |
|-------|-------|---------|--------|
| Static widgets | `SizedBox(height: 8)` | `const SizedBox(height: 8)` | -30% rebuilds |
| Long lists | `ListView(children: [...])` | `ListView.builder(...)` | -70% memory |
| Images | `Image.network(url)` | `CachedNetworkImage(url)` | -80% loading |
| Null safety | `Widget? _widget;` | `late Widget _widget;` | Cleaner |

---

### 2. Debouncing Pattern

```dart
Timer? _debounceTimer;

void _handleSearch(String query) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(Duration(milliseconds: 500), () {
    _performSearch(query); // Only after typing stops
  });
}

@override
void dispose() {
  _debounceTimer?.cancel();
  super.dispose();
}
```

---

### 3. Isolate for Heavy Work

```dart
// ❌ Blocks UI
final result = _heavyComputation(data);

// ✅ Runs in background
final result = await compute(_heavyComputation, data);

// ✅ With progress updates
static Future<List<Item>> _processInBackground(List<Item> items) async {
  return items.map((item) => _transform(item)).toList();
}

final result = await compute(_processInBackground, items);
```

---

### 4. Lazy Loading

```dart
// ❌ Load all at once
final allItems = await _repo.fetchAll();

// ✅ Load in batches
List<Item> _items = [];
bool _hasMore = true;
int _currentPage = 0;

Future<void> _loadMore() async {
  if (!_hasMore || _isLoading) return;
  
  _isLoading = true;
  notifyListeners();
  
  final newItems = await _repo.fetchPage(
    page: _currentPage,
    limit: 20,
  );
  
  _items.addAll(newItems);
  _hasMore = newItems.length == 20;
  _currentPage++;
  _isLoading = false;
  notifyListeners();
}
```

---

### 5. Performance Benchmarks

**Historical Performance Improvements (Oct 2025):**

| Operation | Before | After | Improvement |
|-----------|--------|-------|-------------|
| **Suggestions refresh (4 calls)** | 4 runs | 1 run | 75% less |
| **50+ items analysis** | 62 frames skipped | 0 frames skipped | 100% |
| **80 receipts loading** | UI freezes | Progressive | Smooth |
| **Response time** | 2-3s | <500ms | 80% faster |

---

## 📋 Checklists

### 🔍 Code Review Checklist

#### Provider
- [ ] Uses Repository (not Firestore directly)
- [ ] Has error handling + logging
- [ ] Has getters: items, isLoading, hasError, isEmpty
- [ ] Integrates with UserContext
- [ ] Implements dispose()
- [ ] Has retry() method
- [ ] Has clearAll() method

#### Screen
- [ ] Uses SafeArea + SingleChildScrollView
- [ ] Has 4 Empty States (Loading/Error/Empty/Data)
- [ ] Uses Skeleton Screen (not CircularProgressIndicator)
- [ ] Uses AppStrings (not hardcoded text)
- [ ] Padding is symmetric (RTL support)
- [ ] Has animations (buttons/lists/cards)
- [ ] mounted check after every await

#### Model
- [ ] Has @JsonSerializable()
- [ ] All fields are final
- [ ] Has copyWith() method
- [ ] Has *.g.dart generated file
- [ ] Has equality (==) and hashCode
- [ ] Has toString()

#### Repository
- [ ] Has Interface + Implementation
- [ ] Filters by household_id
- [ ] Has logging with emojis
- [ ] Has error handling
- [ ] Has retry logic

---

### ✅ New Screen Checklist

#### Design
- [ ] Uses Sticky Notes Design System
- [ ] Background: kPaperBackground + NotebookBackground
- [ ] Spacing: compact if single-screen
- [ ] Colors: max 3 colors
- [ ] Rotations: -0.03 to 0.03
- [ ] Logo: StickyNoteLogo
- [ ] Buttons: StickyButton
- [ ] Content: wrapped in StickyNote

#### Code
- [ ] Async functions wrapped in lambda
- [ ] Context saved before await
- [ ] mounted check after await
- [ ] withValues (not withOpacity)
- [ ] initialValue (not value) for Dropdown
- [ ] Constants from lib/core/
- [ ] Controllers disposed
- [ ] Form validation defined
- [ ] File header documentation
- [ ] Function documentation (public + private)

#### UX
- [ ] Loading states defined
- [ ] Clear error messages
- [ ] Success messages
- [ ] Buttons accessible (44-48px)
- [ ] Text readable (11px+)
- [ ] 4 Empty States (Loading/Error/Empty/Data)
- [ ] Skeleton Screens
- [ ] Animations

#### Performance
- [ ] const where possible
- [ ] Lazy loading for lists
- [ ] No unnecessary rebuilds
- [ ] Debug prints removed (production)

#### Security
- [ ] household_id in all queries
- [ ] No API keys in code
- [ ] No sensitive data in logs
- [ ] Data validated before save

#### Testing
- [ ] Unit tests written
- [ ] Widget tests (if complex)
- [ ] Manual testing done
- [ ] Dark mode tested
- [ ] Works on real device

---

### 🏆 Production Readiness Checklist

**Before deployment:**

#### Code Quality
- [ ] `flutter analyze` → 0 issues
- [ ] `dart format lib/ -w` → formatted
- [ ] All TODO comments resolved
- [ ] No debug prints in production code
- [ ] No commented-out code

#### Testing
- [ ] Unit tests pass (90%+ coverage for models)
- [ ] Widget tests pass
- [ ] Manual testing complete
- [ ] Dark mode tested
- [ ] RTL tested

#### Security
- [ ] Firestore Rules deployed and tested
- [ ] No API keys in code
- [ ] No hardcoded secrets
- [ ] Auth flow tested
- [ ] household_id filtering verified

#### Performance
- [ ] Build time < 2 minutes
- [ ] App size < 50MB
- [ ] Cold start < 3 seconds
- [ ] Smooth 60 FPS
- [ ] No memory leaks

#### Documentation
- [ ] README updated
- [ ] CHANGELOG updated
- [ ] API docs complete
- [ ] User guide ready

---

## 🎓 Common Patterns Summary

### Pattern Index

| Pattern | When | Reference |
|---------|------|-----------|
| **Repository** | Data access | Architecture #1 |
| **Provider** | State management | Architecture #2 |
| **UserContext** | Household switching | Architecture #3 |
| **household_id** | Multi-tenant security | Architecture #4 |
| **4 Loading States** | UI feedback | Architecture #5 |
| **Batch Processing** | 100+ items | Architecture #6 |
| **Async Callbacks** | Button handlers | Code Examples #1 |
| **Context Management** | After await | Code Examples #1 |
| **Form Validation** | User input | Code Examples #3 |
| **Race Condition** | Concurrent ops | Code Examples #4 |
| **Error Handling** | All async | Code Examples #5 |
| **Debouncing** | Search/input | Performance #2 |
| **Isolate** | Heavy work | Performance #3 |
| **Lazy Loading** | Large lists | Performance #4 |

---

## 📚 Related Documentation

| Document | Purpose |
|----------|---------|
| **AI_MASTER_GUIDE.md** | AI behavior instructions |
| **DESIGN_GUIDE.md** | UI/UX guidelines |
| **GETTING_STARTED.md** | Quick start for beginners |
| **PROJECT_INFO.md** | Project overview |

---

## 🆘 Need Help?

### Quick Answers

| Question | Section |
|----------|---------|
| How to check Dead Code? | Quick Reference |
| How to structure Provider? | Architecture #2 |
| How to handle async callbacks? | Code Examples #1 |
| How to write tests? | Testing Guidelines |
| How to secure data? | Security Best Practices |
| How to improve performance? | Performance Optimization |

### Can't Find It?

1. Check **Quick Reference** first (30 seconds)
2. Search this document (Ctrl+F)
3. Check **AI_MASTER_GUIDE.md** for AI-specific rules
4. Check **DESIGN_GUIDE.md** for UI/UX

---

**Made with ❤️ by Humans & AI** 👨‍💻🤖  
**Version:** 1.0 | **Created:** 18/10/2025  
**Purpose:** Complete developer reference - single source of truth
