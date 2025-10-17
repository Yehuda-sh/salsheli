# AI Master Guide - Salsheli Project

> **CRITICAL:** Read this file at the start of EVERY new conversation  
> **Purpose:** Complete AI behavior instructions + technical rules  
> **Updated:** 18/10/2025

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

#### 3️⃣ Best Practices

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

## 🎨 Part 8: Sticky Notes Design System

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

---

## 📊 Part 9: Quick Problem Solving

### Common Issues Table (30-second solutions):

| Problem | Solution | Reference |
|---------|----------|-----------|
| File not used | 5-step verification | Part 4 |
| Good code not used | 4-question framework | Part 5 |
| Provider not updating | addListener + removeListener | Part 7.4 |
| Timestamp errors | @TimestampConverter() | LESSONS_LEARNED.md |
| Auth race condition | Throw exception on error | LESSONS_LEARNED.md |
| Mock data in code | Connect to real Provider | LESSONS_LEARNED.md |
| Context after async | Save dialogContext separately | LESSONS_LEARNED.md |
| withOpacity deprecated | .withValues(alpha:) | Part 6.1 |
| Slow UI | .then() in background | LESSONS_LEARNED.md |
| Slow save | Batch processing (50-100) | LESSONS_LEARNED.md |
| Missing empty state | 4 states required | Part 7.3 |
| Boring loading | Use Skeleton Screen | STICKY_NOTES_DESIGN.md |
| No animations | Add micro animations | STICKY_NOTES_DESIGN.md |
| Hardcoded values | Use constants from lib/core/ | Part 6.5 |

---

## 📁 Part 10: Project Structure

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

## 🔗 Part 11: Related Documentation

**When you need more details:**

| Question | File | Section |
|----------|------|---------|
| How async callbacks work? | BEST_PRACTICES.md | Async |
| Sticky Notes full spec? | STICKY_NOTES_DESIGN.md | Complete |
| Firebase connection? | SECURITY_GUIDE.md | Auth |
| How to test? | TESTING_GUIDE.md | All types |
| Dead Code process? | QUICK_REFERENCE.md | 30-sec answer |
| Architecture patterns? | LESSONS_LEARNED.md | Deep dives |
| User beginner tips? | AI_DEVELOPER_INTERACTION_GUIDE.md | For user |

---

## 🎯 TL;DR - 10-Second Reminder

**Every new conversation:**
1. ✅ All responses in Hebrew (except code)
2. ✅ Auto-fix: withOpacity → withValues
3. ✅ Auto-fix: Async callbacks wrapped
4. ✅ Auto-check: Sticky Notes Design
5. ✅ Auto-check: 5-step Dead Code verification
6. ✅ Use Filesystem:edit_file (not artifacts)
7. ✅ Fix tech errors WITHOUT asking
8. ✅ Ask before major changes only

**If in doubt → Check BEST_PRACTICES.md**

---

## 📌 Critical Reminders

- 🗣️ **Hebrew responses** - User is Hebrew speaker, beginner developer
- 🛠️ **edit_file preferred** - User dislikes unnecessary artifacts
- 🔍 **5-step verification** - Before declaring code "dead"
- 🎨 **Sticky Notes mandatory** - For ALL UI screens
- 🏗️ **4 rules never break** - Repository, household_id, 4 states, listeners
- 📝 **Concise feedback** - Don't over-explain simple fixes
- ✅ **Auto-fix when clear** - Don't ask permission for technical corrections

---

**Version:** 1.0  
**Created:** 18/10/2025  
**Purpose:** Complete AI behavior guide - replaces 3 separate files  
**Made with ❤️ by Humans & AI** 👨‍💻🤖
