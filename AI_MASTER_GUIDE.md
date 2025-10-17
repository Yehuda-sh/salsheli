# AI Master Guide - Salsheli Project

> **CRITICAL:** Read this file at the start of EVERY new conversation  
> **Purpose:** Complete AI behavior instructions + technical rules  
> **Updated:** 18/10/2025 | **Version:** 2.0 - Unified Documentation

---

## 🗣️ Part 1: Communication & Response Guidelines

### Language Rule - ABSOLUTE
**ALL responses to user MUST be in Hebrew (except code itself)**

- Explanations: Hebrew
- Comments in responses: Hebrew  
- Error messages: Hebrew
- Code: English (standard)
- Code comments: Can be English

### Response Structure Template

**Standard response format:**
```
✅ [Action completed in Hebrew]

[Show code changes]

🔧 מה שינינו:
1. [Change 1]
2. [Change 2]
3. [Change 3]

💡 [Why these changes matter - brief explanation]
```

**Example:**
```
✅ תיקנתי את הקובץ!

[code changes shown]

🔧 מה שינינו:
1. הוספתי בדיקת mounted אחרי await
2. המרתי withOpacity ל-withValues
3. הוספתי const ל-widgets שלא משתנים

💡 השינויים האלה מונעים קריסות ומשפרים ביצועים.
```

### Tone & Style
- ✅ Friendly but professional
- ✅ Technical but accessible (user is beginner)
- ✅ Concise - no unnecessary explanations
- ✅ Use emojis sparingly for emphasis
- ✅ Bold key terms for scannability

### When to Ask vs When to Fix
**Fix immediately WITHOUT asking:**
- Technical errors (withOpacity, const, mounted check)
- Deprecated APIs
- Sticky Notes Design violations
- Missing imports
- Dead code removal (after verification)
- Performance issues (const, lazy loading)
- Security issues (household_id missing)
- Accessibility issues (sizes < 44px)

**Ask before fixing:**
- Architectural changes
- Feature additions/removals
- Major refactoring (>100 lines)
- Unclear requirements

---

## 🛠️ Part 2: Tools & Workflow

### Filesystem:edit_file > artifacts

**⚠️ CRITICAL: User prefers Filesystem:edit_file over artifacts!**

| Scenario | Tool | Why |
|----------|------|-----|
| Fix existing file | `Filesystem:edit_file` | ✅ Direct, fast, preferred |
| Create new file | `Filesystem:write_file` | ✅ Clean creation |
| Convert design | `Filesystem:edit_file` (multiple calls) | ✅ Precise changes |
| Code examples | Only if user asks | ❌ Avoid unnecessary artifacts |
| Documentation | `Filesystem:write_file` | ✅ Direct to file |

**Example workflow:**
```
User: "תקן את הקובץ"
You: [Read file] → [Filesystem:edit_file] → "✅ תוקן!"
```

**NOT:**
```
User: "תקן את הקובץ"
You: "הנה הקובץ המתוקן:" [500-line artifact]
User: "😡 אני לא רוצה בלוקים!"
```

---

## 🔍 Part 3: Auto Code Review

### When Reading ANY Dart File - Check Automatically:

#### 1️⃣ Technical Errors (Fix immediately!)

| Error | Fix | Why |
|-------|-----|-----|
| `withOpacity(0.5)` | → `withValues(alpha: 0.5)` | Deprecated API |
| `value` (Dropdown) | → `initialValue` | API change |
| `kQuantityFieldWidth` | → `kFieldWidthNarrow` | Renamed constant |
| `kBorderRadiusFull` | → `kRadiusPill` | Renamed constant |
| Async in onPressed | → Wrap: `() => func()` | Type safety |
| Static widget, no const | → Add `const` | Performance |
| Unused imports | → Remove | Clean code |
| No mounted check after await | → Add check | Prevent crashes |
| ListView with children | → `ListView.builder()` | Performance |
| Image.network() | → `CachedNetworkImage()` | Caching |

#### 2️⃣ Sticky Notes Design Compliance (UI screens only!)

**⚠️ CRITICAL: Check EVERY UI screen for Sticky Notes Design!**

**Required components:**
- ✅ `NotebookBackground()` + `kPaperBackground`
- ✅ `StickyNote()` for content
- ✅ `StickyButton()` for buttons
- ✅ `StickyNoteLogo()` for logo
- ✅ Rotations: -0.03 to 0.03
- ✅ Colors: kStickyYellow/Pink/Green/Cyan
- ✅ Max 3 colors per screen

**If screen is NOT compliant:**
1. 🚨 Report: "המסך לא מעוצב לפי Sticky Notes Design!"
2. 🎨 Offer: "האם תרצה שאהמיר את המסך?"
3. ⚡ If yes: Convert using `Filesystem:edit_file`

#### 3️⃣ Security Checks (Fix immediately!)

| Check | Action if missing |
|-------|-------------------|
| household_id in Firestore queries | **Add immediately** |
| API keys in code | **Report as CRITICAL** |
| Passwords in debugPrint | **Remove immediately** |
| Sensitive data exposed | **Report as CRITICAL** |

#### 4️⃣ Performance Checks

| Check | Action if missing |
|-------|-------------------|
| `const` for static widgets | Add |
| ListView.builder for lists | Convert |
| Image caching | Add CachedNetworkImage |
| Batch processing (100+ items) | Implement |

#### 5️⃣ Accessibility Checks

| Check | Action if missing |
|-------|-------------------|
| Button height < 44px | Increase to 44px minimum |
| Text size < 11px | Increase to 11px minimum |
| Missing Semantics | Add for custom widgets |
| Poor contrast | Fix color combinations |

#### 6️⃣ Best Practices

| Check | Action if missing |
|-------|-------------------|
| File header documentation | Add |
| Public function docs (`///`) | Add |
| Private function docs | Add (brief) |
| Consistent naming | Fix |
| Magic numbers | Replace with constants |
| Dead code (commented) | Remove |
| Context saved before await | Fix |
| mounted check after await | Add |
| Error handling in async | Add try-catch |

---

## 🗑️ Part 4: Dead Code Detection

**⚠️ NEVER delete file based on 0 imports alone!**

### 5-Step Verification Process:

1. **Full import search:** `"import.*file_name.dart"`
2. **Relative import search:** `"folder_name/file_name"` ← CRITICAL!
3. **Class name search:** `"ClassName"`
4. **Check related files:** (data→screens, config→providers, model→repositories)
5. **Read file itself:** Look for "EXAMPLE", "DO NOT USE", "דוגמה בלבד"

### Real Example from Project:
```powershell
# onboarding_data.dart LOOKS like Dead Code:
Ctrl+Shift+F → "import.*onboarding_data" → 0 results ❌

# BUT! Relative path search finds it:
Ctrl+Shift+F → "data/onboarding_data" → Found! ✅
# In onboarding_screen.dart: import '../../data/onboarding_data.dart';
```

### Safe to Delete (Confirmed):
- ✅ Files marked "EXAMPLE ONLY"
- ✅ Files marked "DO NOT USE"
- ✅ Debug screens not in routes
- ✅ After ALL 5 checks show 0 usage

### DO NOT Delete:
- ⚠️ 0 imports but found via relative path
- ⚠️ 0 imports but listed in routes
- ⚠️ 0 imports but used in Provider
- ⚠️ Any doubt → ASK USER

---

## 🟡 Part 5: Dormant Code

**Good code that's not currently used - activate or delete?**

### 4-Question Framework:

```
1. Does model support it?
   ✅ Yes → +1 point
   ❌ No → DELETE

2. Is it useful UX?
   ✅ Yes → +1 point
   ❌ No → DELETE

3. Is code quality high? (90+/100)
   ✅ Yes → +1 point
   ❌ No → DELETE

4. Quick to implement? (<30 min)
   ✅ Yes → +1 point
   ❌ No → DELETE
```

**Result:**
- **4/4 points** → 🚀 Activate!
- **0-3 points** → 🗑️ Delete

---

## ⚡ Part 6: 7 Auto-Fixes

**Apply these fixes automatically WITHOUT asking:**

### 1. Opacity API
```dart
// ❌ OLD - Deprecated
Colors.blue.withOpacity(0.5)

// ✅ NEW - Required
Colors.blue.withValues(alpha: 0.5)
```
**Why:** Flutter 3.22+ requirement

### 2. Async Callbacks
```dart
// ❌ WRONG - Type error
StickyButton(onPressed: _saveData)

// ✅ CORRECT - Lambda wrapper
StickyButton(onPressed: () => _saveData())
```
**Why:** Type safety for async functions

### 3. Mounted Check
```dart
// ❌ CRASH RISK
await fetchData();
setState(() {});

// ✅ SAFE
await fetchData();
if (!mounted) return;
setState(() {});
```
**Why:** Screen might be disposed during async operation

### 4. Dropdown API
```dart
// ❌ OLD
DropdownButton(value: 'Select...')

// ✅ NEW  
DropdownButton(initialValue: 'Select...')
```

### 5. Magic Numbers
```dart
// ❌ BAD - What is 16?
padding: EdgeInsets.all(16)

// ✅ GOOD - Clear constant
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
**Why:** Performance - single instance reused

### 7. Sticky Notes Design
**Every UI screen must use Sticky Notes design system**  
If missing → suggest conversion immediately

---

## 🏗️ Part 7: Architectural Rules (NEVER Violate!)

### 1. Repository Pattern - Mandatory
```dart
// ❌ FORBIDDEN - Direct Firebase in screens
FirebaseFirestore.instance.collection('items').get()

// ✅ REQUIRED - Through repository
_repository.fetchItems()
```

### 2. household_id Filter - Always Required
```dart
// ❌ SECURITY ISSUE
firestore.collection('lists').get()

// ✅ SECURE
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

## 🔒 Part 8: Security Best Practices

### Critical Security Checks

**Before EVERY commit:**
```dart
// ✅ Check 1: No API keys in code
grep -r "AIza" lib/
grep -r "api_key" lib/

// ✅ Check 2: No passwords
grep -r "password.*=" lib/

// ✅ Check 3: All queries have household_id
grep -r "collection(" lib/repositories/

// ✅ Check 4: No sensitive data in logs
grep -r "debugPrint.*password" lib/
grep -r "debugPrint.*token" lib/
```

### Security Patterns

```dart
// ✅ Validate household_id before operations
assert(householdId == userContext.currentHouseholdId,
  'household_id mismatch!');

// ✅ Never log sensitive data
debugPrint('User logged in: ${user.uid}'); // ✅
debugPrint('Password: $password');         // ❌ NEVER!

// ✅ Verify ownership
if (data['created_by'] != currentUserId) {
  throw Exception('Unauthorized');
}
```

---

## ⚡ Part 9: Performance Optimization

### Performance Rules

| Issue | Bad ❌ | Good ✅ | Impact |
|-------|-------|---------|--------|
| Const widgets | `SizedBox(height: 8)` | `const SizedBox(height: 8)` | -30% rebuilds |
| ListView | `ListView(children: [...])` | `ListView.builder(...)` | -70% memory |
| Image caching | `Image.network(url)` | `CachedNetworkImage(url)` | -80% loading |
| Late init | `Widget? _widget;` | `late Widget _widget;` | Cleaner null safety |
| Batch processing | Load all at once | Batch 50-100 items | -90% lag |

### Debouncing Pattern
```dart
Timer? _debounceTimer;

void _handleSearch(String query) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(Duration(milliseconds: 500), () {
    _performSearch(query); // Only run once after typing stops
  });
}
```

### Isolate for Heavy Computations
```dart
// ❌ Blocks UI
final result = _heavyComputation(data);

// ✅ Runs in background
final result = await compute(_heavyComputation, data);
```

---

## ♿ Part 10: Accessibility Guidelines

### Accessibility Checklist

**Every new screen:**
```dart
// ✅ Minimum sizes
// Buttons: 44-48px height
// Text: 11px minimum
// Touch target: 44x44px minimum

// ✅ Contrast ratios
// Normal text: 4.5:1
// Large text: 3:1

// ✅ Semantics for custom widgets
Semantics(
  button: true,
  label: 'התחבר למערכת',
  enabled: !_isLoading,
  child: MyCustomButton(...),
)

// ✅ Screen readers
// Test with TalkBack (Android) / VoiceOver (iOS)
```

---

## 🐛 Part 11: Error Handling Standards

### Error Handling Pattern

**Every async function must have:**
```dart
Future<void> myFunction() async {
  try {
    await operation();
    
    // ⚠️ Check mounted before setState
    if (!mounted) return;
    
    setState(() {
      _isLoading = false;
      _errorMessage = null; // ← Clear errors!
    });
  } catch (e) {
    debugPrint('❌ myFunction: $e');
    
    if (!mounted) return;
    
    setState(() {
      _errorMessage = e.toString();
      _isLoading = false;
    });
  }
}
```

### Logging Standards

**Use emojis for quick identification:**
```dart
debugPrint('🚀 LoginScreen: initState');
debugPrint('🔄 Logging in...');
debugPrint('✅ Login successful');
debugPrint('❌ Login failed: $e');
debugPrint('💾 Saving data...');
debugPrint('🗑️ Deleting item...');
```

---

## 🧪 Part 12: Testing Guidelines

### When to Write Tests

- ✅ **Every Model** → Unit test (JSON serialization, copyWith)
- ✅ **Every Provider** → Unit test + Widget test
- ✅ **Every Repository** → Unit test (mock Firebase)
- ⚠️ **UI Screens** → Optional but recommended

### Coverage Targets

| Component | Target | Priority |
|-----------|--------|----------|
| Models | 90%+ | High |
| Providers | 80%+ | High |
| Repositories | 85%+ | High |
| Services | 75%+ | Medium |
| UI | 60%+ | Low |

### Quick Test Example

```dart
test('Provider loads items successfully', () async {
  // Arrange
  final mockRepo = MockRepository();
  when(mockRepo.fetchItems()).thenAnswer((_) async => [item1, item2]);
  
  final provider = MyProvider(mockRepo);
  
  // Act
  await provider.load();
  
  // Assert
  expect(provider.items, hasLength(2));
  expect(provider.isLoading, isFalse);
  expect(provider.hasError, isFalse);
});
```

---

## 🎨 Part 13: Sticky Notes Design System

### Required Structure for ALL UI Screens:

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
                rotation: -0.02,
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

### Color Palette:
- **kStickyYellow** - Important info
- **kStickyPink** - Action buttons
- **kStickyGreen** - Success
- **kStickyBlue** - Information
- **kStickyCyan** - Input fields
- **kStickyOrange** - Warnings

**Rule:** Max 3 colors per screen

**📖 Full design guide:** See `DESIGN_GUIDE.md`

---

## 📊 Part 14: Quick Problem Solving

### Common Issues Table (30-second solutions):

| Problem | Solution | Reference |
|---------|----------|-----------|
| File not used | 5-step verification | Part 4 |
| Good code not used | 4-question framework | Part 5 |
| Provider not updating | addListener + removeListener | Part 7.4 |
| Timestamp errors | @TimestampConverter() | DEVELOPER_GUIDE |
| Auth race condition | Throw exception on error | DEVELOPER_GUIDE |
| Mock data in code | Connect to real Provider | DEVELOPER_GUIDE |
| Context after async | Save dialogContext separately | Part 11 |
| withOpacity deprecated | .withValues(alpha:) | Part 6.1 |
| Slow UI | Debouncing + Isolate | Part 9 |
| Slow save | Batch processing (50-100) | Part 9 |
| Missing empty state | 4 states required | Part 7.3 |
| Boring loading | Use Skeleton Screen | DESIGN_GUIDE |
| No animations | Add micro animations | DESIGN_GUIDE |
| Hardcoded values | Use constants from lib/core/ | Part 6.5 |
| Security issue | Check household_id + no sensitive logs | Part 8 |
| Poor performance | const + ListView.builder + caching | Part 9 |
| Accessibility issue | Sizes 44px+, contrast 4.5:1+ | Part 10 |

---

## 📁 Part 15: Project Structure

```
lib/
├── core/
│   ├── ui_constants.dart       # All UI constants
│   └── theme.dart              # App theme
├── models/
├── providers/
│   ├── user_context_provider.dart  # CRITICAL for household switching
│   └── ...
├── repositories/               # ONLY place for Firebase calls
├── screens/
├── widgets/
│   ├── sticky_note.dart
│   ├── sticky_button.dart
│   ├── sticky_note_logo.dart
│   └── notebook_background.dart
└── main.dart
```

---

## 🔗 Part 16: Documentation References

### The 5 Core Documents

| Document | Purpose | When to use |
|----------|---------|-------------|
| **AI_MASTER_GUIDE.md** | AI instructions | Every conversation start |
| **DEVELOPER_GUIDE.md** | Code patterns & best practices | Writing/reviewing code |
| **DESIGN_GUIDE.md** | UI/UX guidelines | Creating screens |
| **GETTING_STARTED.md** | Quick start | First time setup |
| **PROJECT_INFO.md** | Project overview | Understanding architecture |

### Quick Links

**Need help with:**
- Architecture patterns → DEVELOPER_GUIDE.md
- UI design → DESIGN_GUIDE.md
- Getting started → GETTING_STARTED.md
- Project info → PROJECT_INFO.md

---

## ⚠️ Part 17: Top 10 Common Mistakes

### 1. שכחת mounted check
**Symptom:** "setState called after dispose"  
**Fix:** See Part 6.3

### 2. withOpacity במקום withValues
**Symptom:** Deprecated warning  
**Fix:** See Part 6.1

### 3. Firebase ישירות במסך
**Symptom:** Tight coupling, hard to test  
**Fix:** See Part 7.1

### 4. חסר household_id
**Symptom:** Security vulnerability  
**Fix:** See Part 7.2

### 5. לא בדק async callback type
**Symptom:** Type error  
**Fix:** See Part 6.2

### 6. Context לא נשמר לפני await
**Symptom:** Invalid context error  
**Fix:** See Part 11

### 7. חסר 4 Empty States
**Symptom:** Poor UX  
**Fix:** See Part 7.3

### 8. const חסר
**Symptom:** Poor performance  
**Fix:** See Part 6.6

### 9. API keys בקוד
**Symptom:** Security vulnerability  
**Fix:** See Part 8

### 10. גובה כפתור < 44px
**Symptom:** Accessibility issue  
**Fix:** See Part 10

---

## 🎯 Part 18: TL;DR - 10-Second Reminder

**Every new conversation:**
1. ✅ All responses in Hebrew (except code)
2. ✅ Auto-fix: withOpacity → withValues
3. ✅ Auto-fix: Async callbacks wrapped
4. ✅ Auto-check: Sticky Notes Design
5. ✅ Auto-check: 5-step Dead Code verification
6. ✅ Auto-check: Security (household_id, no API keys)
7. ✅ Auto-check: Performance (const, ListView.builder)
8. ✅ Auto-check: Accessibility (sizes, contrast)
9. ✅ Use Filesystem:edit_file (not artifacts)
10. ✅ Fix tech errors WITHOUT asking
11. ✅ Ask before major changes only

**If in doubt → Check DEVELOPER_GUIDE.md**

---

## 📌 Critical Reminders

### Communication
- 🗣️ **Hebrew responses** - User is Hebrew speaker, beginner developer
- 🛠️ **edit_file preferred** - User dislikes unnecessary artifacts
- 📝 **Concise feedback** - Don't over-explain simple fixes

### Code Review
- 🔍 **5-step verification** - Before declaring code "dead"
- 🎨 **Sticky Notes mandatory** - For ALL UI screens
- 🔒 **Security first** - household_id, no sensitive logs
- ⚡ **Performance matters** - const, ListView.builder, caching
- ♿ **Accessibility required** - 44px buttons, 11px text, 4.5:1 contrast

### Architecture
- 🏗️ **4 rules never break:**
  1. Repository Pattern
  2. household_id in all queries
  3. 4 Loading States
  4. UserContext listeners cleanup

### Quality
- ✅ **Auto-fix when clear** - Don't ask permission for technical corrections
- 🧪 **Test coverage** - Models 90%+, Providers 80%+, Repositories 85%+
- 📖 **Documentation** - File headers + function docs
- 🐛 **Error handling** - try-catch + mounted checks

---

## 📈 Version History

### v2.0 - 18/10/2025
- ✅ **Major update:** Added Security, Performance, Accessibility, Testing, Error Handling
- ✅ **Unified documentation:** Single source of truth for AI
- ✅ **Top 10 mistakes:** Common pitfalls + solutions
- ✅ **Enhanced checklists:** More comprehensive coverage

### v1.0 - 18/10/2025
- 🎉 Initial unified guide
- Basic AI behavior instructions
- Code review guidelines
- Technical rules

---

**Version:** 2.0  
**Created:** 18/10/2025  
**Purpose:** Complete AI behavior guide - single source of truth  
**Made with ❤️ by Humans & AI** 👨‍💻🤖
