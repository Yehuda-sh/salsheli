# Salsheli Project - Technical Guide for Claude

> **CRITICAL:** All responses to user MUST be in Hebrew (except code itself)

## Project Overview

**Salsheli** = Family shopping list management app
- **Stack:** Flutter 3.x + Firebase + Firestore + Provider
- **Location:** `C:\projects\salsheli\`
- **Design System:** Sticky Notes (colorful post-it notes theme)
- **Multi-user:** Family members share same lists via household_id

---

## Auto-Fix Rules - Apply Without Asking

### 1. Opacity API (Flutter 3.x)
```dart
// ❌ OLD - Deprecated
Colors.blue.withOpacity(0.5)

// ✅ NEW - Required
Colors.blue.withValues(alpha: 0.5)
```

### 2. Button Callbacks - Async Functions
```dart
// ❌ WRONG
StickyButton(onPressed: _saveData)

// ✅ CORRECT
StickyButton(onPressed: () => _saveData())
```

### 3. Mounted Check After Await
```dart
// ❌ CRASH RISK
await fetchData();
setState(() {});

// ✅ SAFE
await fetchData();
if (!mounted) return;
setState(() {});
```

### 4. DropdownButton API
```dart
// ❌ OLD
DropdownButton(value: 'Select...')

// ✅ NEW
DropdownButton(initialValue: 'Select...')
```

### 5. Magic Numbers → Constants
```dart
// ❌ BAD
padding: EdgeInsets.all(16)

// ✅ GOOD
padding: EdgeInsets.all(kPaddingMedium)
```
**Location:** `lib/core/ui_constants.dart`

### 6. Const Widgets
```dart
// ❌ INEFFICIENT
SizedBox(height: 8)

// ✅ EFFICIENT
const SizedBox(height: 8)
```

### 7. Sticky Notes Design Compliance
Every screen MUST use the Sticky Notes design system. If missing, suggest conversion.

---

## Sticky Notes Design System

### Required Structure
```dart
Scaffold(
  backgroundColor: kPaperBackground,
  body: Stack(
    children: [
      const NotebookBackground(),  // Lined paper background
      SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(kPaddingMedium),
          child: Column(
            children: [
              const StickyNoteLogo(),
              const SizedBox(height: 8),
              StickyNote(
                color: kStickyYellow,
                rotation: -0.02,  // Slight rotation for authenticity
                child: /* content */,
              ),
              StickyButton(
                label: 'Continue',
                color: kStickyPink,
                onPressed: () => _handleAction(),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
)
```

### Color Palette
| Color | Usage | Constant |
|-------|-------|----------|
| Yellow | Important info | `kStickyYellow` |
| Pink | Action buttons | `kStickyPink` |
| Green | Success/confirmation | `kStickyGreen` |
| Blue | Information | `kStickyBlue` |
| Cyan | Input fields | `kStickyCyan` |
| Orange | Warnings | `kStickyOrange` |

**Rule:** Max 3 colors per screen

---

## Architectural Rules - NEVER Violate

### 1. Repository Pattern - Mandatory
```dart
// ❌ FORBIDDEN - Direct Firebase in screens
class MyScreen {
  void loadData() {
    FirebaseFirestore.instance.collection('items').get();
  }
}

// ✅ REQUIRED - Through repository
class MyScreen {
  final ItemsRepository _repo;
  
  void loadData() {
    _repo.fetchItems();
  }
}
```

### 2. household_id Filter - Always Required
```dart
// ❌ SECURITY ISSUE - Shows all data
firestore.collection('lists').get()

// ✅ SECURE - Only user's household
firestore
  .collection('lists')
  .where('household_id', isEqualTo: userHouseholdId)
  .get()
```

### 3. Loading States - All 4 Required
```dart
if (isLoading) return SkeletonScreen();
if (hasError) return ErrorWidget();
if (isEmpty) return EmptyWidget();
return DataWidget();
```

### 4. UserContext Listeners - Must Dispose
```dart
class MyProvider extends ChangeNotifier {
  MyProvider(this._userContext) {
    _userContext.addListener(_onUserChanged);
  }
  
  @override
  void dispose() {
    _userContext.removeListener(_onUserChanged);
    super.dispose();
  }
}
```

---

## Project Structure

```
lib/
├── core/
│   ├── ui_constants.dart       # Colors, padding, etc.
│   └── theme.dart              # App theme
├── models/
│   ├── shopping_list.dart
│   ├── shopping_item.dart
│   └── user_model.dart
├── providers/
│   ├── user_context_provider.dart
│   ├── shopping_list_provider.dart
│   └── auth_provider.dart
├── repositories/
│   ├── auth_repository.dart
│   ├── household_repository.dart
│   └── shopping_list_repository.dart
├── screens/
│   ├── auth/
│   ├── home/
│   └── lists/
├── widgets/
│   ├── sticky_note.dart
│   ├── sticky_button.dart
│   ├── sticky_note_logo.dart
│   └── notebook_background.dart
└── main.dart
```

---

## Common Patterns

### Screen Template
```dart
class MyScreen extends StatefulWidget {
  const MyScreen({super.key});
  
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPaperBackground,
      body: Stack(
        children: [
          const NotebookBackground(),
          SafeArea(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContent() {
    if (_isLoading) return _buildLoading();
    return _buildData();
  }
  
  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
  
  Widget _buildData() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(kPaddingMedium),
      child: Column(
        children: [
          const StickyNoteLogo(),
          const SizedBox(height: 8),
          // Content here
        ],
      ),
    );
  }
}
```

### Provider Template
```dart
class MyProvider extends ChangeNotifier {
  final MyRepository _repository;
  final UserContextProvider _userContext;
  
  bool _isLoading = false;
  String? _error;
  List<MyModel> _items = [];
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<MyModel> get items => _items;
  bool get isEmpty => _items.isEmpty;
  bool get hasError => _error != null;
  
  MyProvider(this._repository, this._userContext) {
    _userContext.addListener(_onUserChanged);
    _loadData();
  }
  
  @override
  void dispose() {
    _userContext.removeListener(_onUserChanged);
    super.dispose();
  }
  
  void _onUserChanged() {
    _loadData();
  }
  
  Future<void> _loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final householdId = _userContext.currentHouseholdId;
      if (householdId == null) {
        _items = [];
        return;
      }
      
      _items = await _repository.fetchItems(householdId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      if (mounted) notifyListeners();
    }
  }
}
```

---

## Response Guidelines

### Always in Hebrew
- All explanations to user must be in Hebrew
- Code itself remains in English
- Comments in code can be in English
- Error messages to user in Hebrew

### Response Structure
1. Acknowledge request in Hebrew
2. Show code changes
3. Explain what was fixed (in Hebrew)
4. If needed, suggest improvements (in Hebrew)

### Example Response Template
```
✅ תיקנתי את הקובץ!

[show code changes]

🔧 מה שינינו:
1. הוספתי בדיקת mounted אחרי await
2. המרתי withOpacity ל-withValues
3. הוספתי const ל-widgets שלא משתנים

💡 השינויים האלה מונעים קריסות ומשפרים ביצועים.
```

---

## Quick Commands from User

| User Says | Action |
|-----------|--------|
| "תקן את הקובץ" | Check all 7 auto-fixes + design |
| "צור מסך חדש" | Generate screen with Sticky Notes design |
| "הסבר" | Explain code in simple Hebrew |
| "סרוק Dead Code" | Find unused files |
| "סיכום המשכיות" | Summarize session + next steps |

---

## Related Documentation
- `LESSONS_LEARNED.md` - Technical lessons
- `BEST_PRACTICES.md` - Code examples
- `STICKY_NOTES_DESIGN.md` - Full design guide
- `QUICK_REFERENCE.md` - Quick answers

---

**Note:** User is beginner-level developer. Keep explanations simple and practical.
