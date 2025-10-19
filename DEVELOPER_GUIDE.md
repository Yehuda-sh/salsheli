# 👨‍💻 Developer Guide - Salsheli

> **מטרה:** Code patterns, testing, security - כל מה שמפתח צריך  
> **עדכון:** 19/10/2025 | **גרסה:** 1.2 - Cleaned & Optimized

---

## 📚 תוכן עניינים

- [🎯 Quick Reference](#quick-reference)
- [🏗️ Architecture Patterns](#architecture-patterns)
- [💻 Code Examples](#code-examples)
- [🧪 Testing Guidelines](#testing-guidelines)
- [🔒 Security Best Practices](#security-best-practices)
- [⚡ Performance Optimization](#performance-optimization)
- [📋 Checklists](#checklists)

---

## 🎯 Quick Reference

### Constants Location

| Type | Location | Example |
|------|----------|---------|
| **Spacing** | `lib/core/ui_constants.dart` | `kSpacingSmall` (8px) |
| **Colors** | `lib/core/ui_constants.dart` | `kStickyYellow` |
| **UI** | `lib/core/ui_constants.dart` | `kButtonHeight` (48px) |
| **Business** | `lib/config/` | `HouseholdConfig` |

### Deprecated APIs

| Old ❌ | New ✅ | Why |
|--------|--------|-----|
| `.withOpacity(0.5)` | `.withValues(alpha: 0.5)` | Flutter 3.22+ |
| `value` (Dropdown) | `initialValue` | API change |

### Async Callbacks

```dart
// ❌ Type Error
onPressed: _asyncFunction

// ✅ Wrapped
onPressed: () => _asyncFunction()
```

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

**See:** `lib/repositories/shopping_lists_repository.dart`

**Why:**
- Easy to swap implementations (Firestore → SQLite)
- Easy to mock for testing
- Centralized data access
- Enforces household_id filtering

**Pattern:**
```dart
abstract class MyRepository {
  Future<List<Item>> fetchItems(String householdId);
}

class FirebaseMyRepository implements MyRepository {
  @override
  Future<List<Item>> fetchItems(String householdId) async {
    return await _firestore
      .collection('items')
      .where('household_id', isEqualTo: householdId) // ⚠️ Critical!
      .get();
  }
}
```

---

### 2. Provider Pattern

**See:** `lib/providers/shopping_lists_provider.dart`

**Key Points:**
- Use UserContext integration
- Implement all 4 getters: items, isLoading, hasError, isEmpty
- Always dispose listeners
- Include retry() and clearAll() methods

**Template:**
```dart
class MyProvider extends ChangeNotifier {
  final MyRepository _repository;
  final UserContext _userContext;
  
  List<Item> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  MyProvider(this._repository, this._userContext) {
    _userContext.addListener(_onUserChanged);
    _loadData();
  }
  
  @override
  void dispose() {
    _userContext.removeListener(_onUserChanged); // ✅ Critical!
    super.dispose();
  }
  
  // ... rest of implementation
}
```

---

### 3. UserContext Integration

**Pattern:**
- Listen in constructor
- Remove listener in dispose
- React to household changes

**See:** Any provider in `lib/providers/`

---

### 4. household_id Pattern

**Security Rule #1:**
```dart
// ❌ SECURITY ISSUE
await _firestore.collection('lists').get()

// ✅ SECURE
await _firestore
  .collection('lists')
  .where('household_id', isEqualTo: householdId)
  .get()
```

---

### 5. Loading States Pattern

**All 4 states required:**
```dart
Widget build(BuildContext context) {
  final provider = context.watch<MyProvider>();
  
  if (provider.isLoading && provider.isEmpty) return _buildSkeleton();
  if (provider.hasError) return _buildError();
  if (provider.isEmpty) return _buildEmpty();
  return _buildData();
}
```

---

### 6. Real Project Examples

**Want to see patterns in action?**

| Pattern | File |
|---------|------|
| Repository | `lib/repositories/shopping_lists_repository.dart` |
| Provider | `lib/providers/shopping_lists_provider.dart` |
| UserContext Integration | Any provider file |
| Sticky Notes Design | `lib/screens/auth/login_screen.dart` |
| Components | `lib/widgets/common/sticky_note.dart` |

---

## 💻 Code Examples

### Async Functions

**Problem: Type Error with Callbacks**
```dart
// ❌ Error
StickyButton(onPressed: _handleLogin)

// ✅ Solution
StickyButton(onPressed: () => _handleLogin())
```

**Context Management:**
```dart
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

### State Management

**Loading States:**
```dart
Future<void> _handleAction() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });
  
  try {
    await operation();
    if (!mounted) return;
    setState(() => _isLoading = false);
  } catch (e) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _errorMessage = e.toString();
    });
  }
}
```

---

### Form Validation

**See:** `lib/screens/auth/login_screen.dart`

**Key Points:**
- Always dispose controllers
- Trim whitespace
- Return null for valid

---

### Race Condition Prevention

```dart
class UserContext extends ChangeNotifier {
  bool _isSigningUp = false;
  
  void _onAuthStateChange(User? user) {
    if (_isSigningUp) return; // ✅ Skip during signup!
    // ... handle auth change
  }
  
  Future<void> signUp(...) async {
    _isSigningUp = true;
    try {
      await _authService.signUp(...);
    } finally {
      _isSigningUp = false;
    }
  }
}
```

---

### Error Handling

```dart
try {
  await riskyOperation();
} on FirebaseAuthException catch (e) {
  switch (e.code) {
    case 'too-many-requests':
      showSnackBar('יותר מדי ניסיונות');
      break;
    case 'wrong-password':
      showSnackBar('סיסמה שגויה');
      break;
    default:
      showSnackBar('שגיאה: ${e.message}');
  }
} catch (e) {
  showSnackBar('שגיאה לא צפויה: $e');
}
```

---

## 🧪 Testing Guidelines

### Test Coverage Targets

| Component | Target | Priority |
|-----------|--------|----------|
| **Models** | 90%+ | 🔴 High |
| **Providers** | 80%+ | 🔴 High |
| **Repositories** | 85%+ | 🔴 High |
| **Services** | 75%+ | 🟡 Medium |
| **UI** | 60%+ | 🟢 Low |

---

### Provider Test Template

**See:** `test/providers/`

**Key Points:**
- Mock repository
- Test initial state
- Test success/error cases
- Always dispose provider

---

### Quick Commands

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

---

## 🔒 Security Best Practices

### 1. Firestore Security Rules

**See:** `firestore.rules`

**Key Points:**
- Always check authentication
- Verify household membership
- Prevent household_id changes

---

### 2. Data Validation

```dart
Future<void> createList(ShoppingList list, String householdId) async {
  // ✅ Validate household_id
  assert(householdId == userContext.householdId);
  
  // ✅ Ensure household_id is set
  if (list.householdId != householdId) {
    throw Exception('household_id not set correctly');
  }
  
  await _repo.createList(list, householdId);
}
```

---

### 3. Sensitive Data Handling

```dart
// ❌ NEVER log sensitive data
debugPrint('User: $email, Password: $password'); // NEVER!

// ✅ Log only safe data
debugPrint('User logged in: ${user.uid}');
```

---

### 4. API Key Security

```dart
// ❌ NEVER hardcode API keys
const String API_KEY = 'AIza...'; // WRONG!

// ✅ Use environment variables
const String API_KEY = String.fromEnvironment('API_KEY');
```

---

## ⚡ Performance Optimization

### Performance Rules

| Issue | Fix | Impact |
|-------|-----|--------|
| Static widgets | Add `const` | -30% rebuilds |
| Long lists | Use `ListView.builder` | -70% memory |
| Images | Use `CachedNetworkImage` | -80% loading |

---

### Debouncing Pattern

```dart
Timer? _debounceTimer;

void _handleSearch(String query) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(Duration(milliseconds: 500), () {
    _performSearch(query);
  });
}

@override
void dispose() {
  _debounceTimer?.cancel();
  super.dispose();
}
```

---

### Isolate for Heavy Work

```dart
// ❌ Blocks UI
final result = _heavyComputation(data);

// ✅ Runs in background
final result = await compute(_heavyComputation, data);
```

---

### Lazy Loading

```dart
// ❌ Load all at once
final allItems = await _repo.fetchAll();

// ✅ Load in batches
final newItems = await _repo.fetchPage(
  page: _currentPage,
  limit: 20,
);
```

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
- [ ] Uses Skeleton Screen
- [ ] Padding is symmetric (RTL support)
- [ ] Has animations
- [ ] mounted check after every await
- [ ] Navigation accessible from UI

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
- [ ] Has logging
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

#### UX
- [ ] Loading states defined
- [ ] Clear error messages
- [ ] Success messages
- [ ] Buttons accessible (44-48px)
- [ ] Text readable (11px+)
- [ ] 4 Empty States
- [ ] Skeleton Screens
- [ ] Animations

#### Performance
- [ ] const where possible
- [ ] Lazy loading for lists
- [ ] No unnecessary rebuilds
- [ ] Debug prints removed

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

---

## 📚 Related Documentation

| Document | Purpose |
|----------|---------|
| **AI_MASTER_GUIDE.md** | AI behavior instructions |
| **DESIGN_GUIDE.md** | UI/UX guidelines |
| **PROJECT_INFO.md** | Project overview |

---

## 📈 Version History

### v1.2 - 19/10/2025 🆕 **LATEST - Cleaned & Optimized**
- 🧹 Removed Dead/Dormant/Navigation sections (moved to AI_MASTER_GUIDE)
- ✂️ Replaced code examples with file references
- 📊 Result: 40% reduction in size

### v1.1 - 19/10/2025
- ✅ Added Navigation section + checklist

---

**Version:** 1.2  
**Created:** 18/10/2025 | **Updated:** 19/10/2025  
**Purpose:** Complete developer reference - patterns, testing, security
