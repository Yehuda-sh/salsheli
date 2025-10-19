# AI Master Guide - Salsheli Project

> **CRITICAL:** Read this file at the start of EVERY new conversation  
> **Purpose:** AI behavior instructions for Claude  
> **Updated:** 19/10/2025 | **Version:** 3.1 - Navigation Check Added 🎯

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

```
✅ [Action completed in Hebrew]

[Show code changes]

🔧 מה שינינו:
1. [Change 1]
2. [Change 2]
3. [Change 3]

💡 [Why these changes matter - brief explanation]
```

### Tone & Style
- ✅ Friendly but professional
- ✅ Technical but accessible (user is beginner)
- ✅ Concise - no unnecessary explanations
- ✅ Use emojis sparingly for emphasis

### When to Ask vs When to Fix
**Fix immediately WITHOUT asking:**
- Technical errors (withOpacity, const, mounted check)
- Deprecated APIs
- Sticky Notes Design violations
- Security issues (household_id missing)
- Accessibility issues (sizes < 44px)

**Ask before fixing:**
- Architectural changes
- Feature additions/removals
- Major refactoring (>100 lines)

---

## 🛠️ Part 2: Tools & Workflow

**📚 For comprehensive MCP tools guide:** See [**MCP_TOOLS_GUIDE.md**](MCP_TOOLS_GUIDE.md)

### Filesystem:edit_file > artifacts

**⚠️ CRITICAL: User prefers Filesystem:edit_file over artifacts!**

| Scenario | Tool | Why |
|----------|------|-----|
| Fix existing file | `Filesystem:edit_file` | ✅ Direct, fast, preferred |
| Create new file | `Filesystem:write_file` | ✅ Clean creation |
| Code examples | Only if user asks | ❌ Avoid unnecessary artifacts |

---

## 📂 Part 3: Default Behavior When User Sends Only File Path

**⚠️ CRITICAL: This is what you MUST do when user sends ONLY a file path with NO context!**

### The Scenario:
```
User sends: C:\projects\salsheli\lib\screens\auth\login_screen.dart
(No explanation, no question - just the path)
```

### Your Automatic Response Protocol:

```
1️⃣ READ THE FILE
   → Use Filesystem:read_file immediately

2️⃣ PERFORM COMPREHENSIVE CODE REVIEW (ALL 13 checks):
   ✅ Technical Errors (withOpacity → withValues, const, mounted)
   ✅ Sticky Notes Design (if UI screen)
   ✅ Security (household_id, API keys, sensitive logs)
   ✅ Performance (const, ListView.builder, caching)
   ✅ Accessibility (button sizes 44px+, text 11px+, contrast)
   ✅ Best Practices (docs, naming, error handling)
   ✅ Business Logic (validations: empty checks, ranges)
   ✅ State Management (notifyListeners, dispose listeners)
   ✅ Memory Leaks (Controllers, Streams, OCR cleanup)
   ✅ Firebase (batch size <500, limits, error handlers)
   ✅ API Integration (timeout, retry, proper errors)
   ✅ Production Readiness (debugPrint, TODOs, localhost)
   ✅ Navigation (screen accessible from UI? Orphan Screen check)

3️⃣ AUTO-FIX CRITICAL ISSUES (WITHOUT asking):
   → Technical errors (withOpacity → withValues)
   → Security issues (missing household_id)
   → Critical bugs (missing dispose, mounted checks)
   → Performance issues (missing const)

4️⃣ REPORT NON-CRITICAL ISSUES (ask before fixing):
   → Design violations (not Sticky Notes)
   → Minor performance issues
   → Accessibility improvements

5️⃣ PROVIDE STRUCTURED REPORT:
   📊 Quality Score: X/100
   ✅ What's Good (strengths)
   ⚠️ What to Improve (if any)
   💡 Recommendations (if relevant)
```

### Response Templates:

#### Perfect File (95-100/100)
```
## ✅ קראתי את הקובץ - נראה מצוין! 🎉

הקובץ `[filename]` **איכותי מאוד** ועומד בכל הסטנדרטים!

### 📊 ציון: X/100 🌟

## ✅ מה טוב:
- [List strengths]

**🎉 עבודה מצוינת!**
```

#### Minor Issues (80-94/100)
```
## ✅ קראתי את הקובץ - טוב, עם שיפורים קטנים

### 📊 ציון: X/100

## ⚠️ מה לשפר:
- [Issues]

**האם תרצה שאתקן?**

## ✅ מה כבר טוב:
- [Strengths]
```

#### Critical Issues (<80/100)
```
## ⚠️ מצאתי בעיות קריטיות - מתקן אוטומטית!

### 📊 ציון לפני: X/100

## 🔧 תיקונים קריטיים:
[Use Filesystem:edit_file to fix]

1. [Fix 1]
2. [Fix 2]
3. [Fix 3]

### 📊 ציון אחרי: Y/100 ✅

**💡 הקובץ עכשיו בטוח ויציב!**
```

---

## 🔍 Part 4: Auto Code Review - Quick Reference

### Technical Errors (Fix immediately!)

| Error | Fix | Why |
|-------|-----|-----|
| `withOpacity(0.5)` | `withValues(alpha: 0.5)` | Deprecated API |
| `value` (Dropdown) | `initialValue` | API change |
| Async in onPressed | Wrap: `() => func()` | Type safety |
| No const | Add `const` | Performance |
| No mounted after await | Add `if (!mounted) return;` | Prevent crashes |

### Sticky Notes Design (UI screens)

**Required:**
- ✅ `NotebookBackground()` + `kPaperBackground`
- ✅ `StickyNote()` for content
- ✅ `StickyButton()` for buttons
- ✅ Rotations: -0.03 to 0.03
- ✅ Max 3 colors per screen

### Security Checks

| Check | Action if missing |
|-------|-------------------|
| household_id in queries | **Add immediately** |
| API keys in code | **Report as CRITICAL** |
| Sensitive data in logs | **Remove immediately** |

### Performance Checks

| Check | Action |
|-------|--------|
| `const` for static widgets | Add |
| `ListView.builder` for lists | Convert |
| Image caching | Add CachedNetworkImage |

### Accessibility Checks

| Check | Action |
|-------|--------|
| Button height < 44px | Increase to 44px |
| Text size < 11px | Increase to 11px |
| Poor contrast | Fix colors |

### State Management

| Check | Action | Priority |
|-------|--------|----------|
| `notifyListeners()` missing | Add after updates | 🔴 High |
| `removeListener()` missing | Add in dispose() | 🔴 Critical |
| Race condition | Add `if (_isLoading) return;` | 🟡 Medium |

### Memory Leaks

| Resource | Action | Priority |
|----------|--------|----------|
| `TextEditingController` | Dispose | 🟡 Medium |
| `TextRecognizer` (OCR) | Call `.close()` | 🔴 Critical |
| `StreamSubscription` | Cancel | 🔴 Critical |
| UserContext listeners | Remove | 🔴 Critical |

### Firebase Best Practices

| Check | Action | Priority |
|-------|--------|----------|
| Batch > 500 operations | Split batches | 🔴 Critical |
| Query without limit | Add `.limit(50)` | 🟡 Medium |
| No error handler | Add `onError` | 🔴 High |

### API Integration

| Check | Fix | Priority |
|-------|-----|----------|
| No timeout | Add `.timeout(10s)` | 🔴 High |
| No retry | Retry 3x with backoff | 🔴 High |
| Generic errors | Differentiate 401/404/500 | 🟡 Medium |

### Production Readiness

| Check | Command |
|-------|---------|  
| debugPrint | `grep -r "debugPrint" lib/` |
| TODO comments | `grep -r "TODO" lib/` |
| Hardcoded localhost | `grep -r "localhost" lib/` |
| API keys | `grep -r "api_key" lib/` |

### 🧭 Navigation & Accessibility (Anti-Pattern: Orphan Screen)

**⚠️ CRITICAL:** When reviewing any screen file, verify users can actually reach it!

#### The Orphan Screen Problem:
```dart
// ❌ Orphan Screen Anti-Pattern
// Screen exists: InsightsScreen ✅
// Route defined: '/insights' in main.dart ✅  
// Navigation: NONE ❌
// → User CANNOT reach this screen!
```

#### 5-Step Navigation Check:

```bash
1️⃣ Check route exists in main.dart
   → '/screen-name': (context) => const ScreenName()

2️⃣ Search for navigation calls  
   → grep -r "'/screen-name'" lib/screens/
   → Should find: Navigator.pushNamed(context, '/screen-name')

3️⃣ Check Bottom Navigation (if applicable)
   → lib/screens/home/home_screen.dart
   → Look for screen in _pages list

4️⃣ Check Dashboard cards (common entry point)
   → lib/screens/home/home_dashboard_screen.dart  
   → Look for Navigator.pushNamed calls

5️⃣ Check Settings menu (for config screens)
   → lib/screens/settings/settings_screen.dart
   → Look for ListTile with onTap navigation
```

**If ALL 5 checks fail = Orphan Screen! 🚨**

#### Action Protocol:

```markdown
**When Orphan Screen detected:**

1. REPORT to user:
   "מצאתי מסך [ScreenName] אבל אין דרך להגיע אליו מהממשק.
    איפה המשתמש צריך לגשת למסך הזה?"

2. SUGGEST solutions based on importance:
   - Critical/Important → Dashboard card (most visible)
   - Always needed → Bottom Nav tab (always accessible)  
   - Configuration → Settings option (organized)
   - Related flow → Deep link from related screen

3. IMPLEMENT chosen solution
```

#### Example Fix - Dashboard Card:

```dart
// Add to home_dashboard_screen.dart:

const _MyFeatureCard()
  .animate()
  .fadeIn(duration: 600.ms, delay: 400.ms)
  .slideY(begin: 0.15, end: 0),

class _MyFeatureCard extends StatelessWidget {
  const _MyFeatureCard();
  
  @override
  Widget build(BuildContext context) {
    return StickyNote(
      color: kStickyPurple,
      rotation: 0.01,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/my-feature'),
        child: Column(
          children: [
            // Icon + Title + Description
            Icon(Icons.feature_icon),
            Text('Feature Name'),
            Text('Feature description'),
          ],
        ),
      ),
    );
  }
}
```

#### Priority Matrix:

| Screen Type | Best Navigation | Why |
|-------------|----------------|-----|
| Analytics/Insights | Dashboard card | High visibility |
| Core feature | Bottom Nav | Always accessible |
| Settings/Config | Settings menu | Organized location |
| Flow step | Deep link | Natural progression |
| Admin/Debug | No UI needed | Dev-only access |

**Golden Rule:**  
> "Every screen with a route MUST be accessible through at least 1 UI path!"

---

## 🗑️ Part 5: Dead Code Detection

**⚠️ NEVER delete based on 0 imports alone!**

### 5-Step Verification:

1. Full import search: `"import.*file_name.dart"`
2. **Relative import:** `"folder_name/file_name"` ← CRITICAL!
3. Class name search: `"ClassName"`
4. Check related files
5. Read file itself

**Safe to delete:**
- ✅ After ALL 5 checks = 0 usage
- ✅ Marked "EXAMPLE ONLY"
- ✅ Marked "DO NOT USE"

**DO NOT delete:**
- ⚠️ Any doubt → ASK USER

---

## 🟡 Part 6: Dormant Code

**Good code not currently used - activate or delete?**

### 4-Question Framework:

```
1. Does model support it? → +1 point
2. Is it useful UX? → +1 point
3. Is code quality high (90+/100)? → +1 point
4. Quick to implement (<30 min)? → +1 point
```

**Result:**
- **4/4 points** → 🚀 Activate
- **0-3 points** → 🗑️ Delete

---

## 🏗️ Part 7: Architectural Rules (NEVER Violate!)

### 1. Repository Pattern - Mandatory
```dart
// ❌ FORBIDDEN
FirebaseFirestore.instance.collection('items').get()

// ✅ REQUIRED
_repository.fetchItems()
```

### 2. household_id Filter - Always Required
```dart
// ❌ SECURITY ISSUE
firestore.collection('lists').get()

// ✅ SECURE
firestore.collection('lists')
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
    _userContext.removeListener(_onUserChanged); // ✅ Critical!
    super.dispose();
  }
}
```

---

## 📚 Part 8: Documentation References

**For detailed info, check:**

| Need | Document |
|------|----------|
| **Code patterns** | [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) |
| **UI/UX** | [DESIGN_GUIDE.md](DESIGN_GUIDE.md) |
| **MCP Tools** | [MCP_TOOLS_GUIDE.md](MCP_TOOLS_GUIDE.md) |
| **Quick start** | [GETTING_STARTED.md](GETTING_STARTED.md) |
| **Project info** | [PROJECT_INFO.md](PROJECT_INFO.md) |

---

## 🎯 Part 9: TL;DR - 10-Second Reminder

**Every new conversation:**

1. ✅ **Hebrew responses** (except code)
2. 📂 **File path only?** → Auto code review + quality score + auto-fix critical
3. ✅ **Auto-fix immediately:**
   - withOpacity → withValues
   - Async callbacks: `() => func()`
   - Missing const
   - Missing mounted check
   - Missing household_id
   - Missing notifyListeners
   - Memory leaks (dispose)
4. ✅ **Always check:** Sticky Notes Design compliance
5. ✅ **Prefer:** Filesystem:edit_file (not artifacts)
6. ✅ **Ask only for:** Major changes, unclear requirements

---

## 📊 Quick Problem Solving

| Problem | Solution | Reference |
|---------|----------|-----------|
| File not used | 5-step verification | Part 5 |
| Good code not used | 4-question framework | Part 6 |
| withOpacity | withValues(alpha:) | Part 4 |
| Async callback error | Wrap: `() => func()` | Part 4 |
| No mounted check | Add after await | Part 4 |
| Missing const | Add to static widgets | Part 4 |
| household_id missing | Add to all queries | Part 7.2 |
| Provider not updating | Add notifyListeners | Part 4 |
| Memory leak | Dispose/removeListener | Part 4 |
| Batch > 500 | Split into 500-item batches | Part 4 |
| No timeout | Add .timeout(10s) | Part 4 |

**📖 For details:** See DEVELOPER_GUIDE.md

---

## ⚠️ Top 10 Common Mistakes

| # | Mistake | Fix | Reference |
|---|---------|-----|-----------|
| 1 | No mounted check | Add after await | Part 4 |
| 2 | withOpacity | withValues(alpha:) | Part 4 |
| 3 | Firebase in screen | Use Repository | Part 7.1 |
| 4 | Missing household_id | Add to queries | Part 7.2 |
| 5 | Async callback | Wrap: `() => func()` | Part 4 |
| 6 | Context after await | Save before | DEVELOPER_GUIDE |
| 7 | Missing 4 states | Add all 4 | Part 7.3 |
| 8 | No const | Add to static widgets | Part 4 |
| 9 | API keys in code | Use environment | Part 4 |
| 10 | Button < 44px | Increase size | Part 4 |
| 11 | No notifyListeners | Add after state change | Part 4 |
| 12 | Listener not removed | Add removeListener | Part 4 |
| 13 | Batch > 500 | Split batches | Part 4 |
| 14 | No API timeout | Add timeout | Part 4 |
| 15 | debugPrint in prod | Remove before release | Part 4 |

---

## 📌 Critical Reminders

### Communication
- 🗣️ Hebrew responses (user is Hebrew speaker, beginner)
- 🛠️ edit_file preferred over artifacts
- 📝 Concise - no over-explaining

### Code Review
- 🔍 **5-step verification** before declaring Dead Code
- 🎨 **Sticky Notes mandatory** for ALL UI screens
- 🔒 **Security first** - household_id everywhere
- ⚡ **Performance** - const, ListView.builder, caching
- ♿ **Accessibility** - 44px buttons, 11px text, 4.5:1 contrast

### Architecture
- 🏗️ **4 rules never break:**
  1. Repository Pattern
  2. household_id in all queries
  3. 4 Loading States
  4. UserContext listeners cleanup

### Quality
- ✅ Auto-fix when clear (don't ask)
- 🧪 Test coverage targets (90%+ models, 80%+ providers)
- 📖 Documentation required
- 🐛 Error handling everywhere

---

## 📈 Version History

### v3.1 - 19/10/2025 🆕 **LATEST - Navigation Check Added**
- ✅ **Added 13th check:** Navigation/Orphan Screens detection
- ✅ **Updated:** DEVELOPER_GUIDE.md with Navigation section
- 🎯 **Result:** Complete coverage of all code quality aspects

### v3.0 - 19/10/2025 **Lean & Focused**
- 🎯 **Massive reduction:** 1500 → 500 lines
- 🗑️ **Removed:** Parts 4-17 duplicates (all in DEVELOPER_GUIDE.md)
- ✅ **Kept:** Only what AI needs at conversation start
- 📚 **Added:** Clear references to detailed guides
- 🚀 **Result:** Faster loading, easier to maintain

### v2.3 - 18/10/2025
- ✅ Added Part 2.5 (Default Behavior for file paths)
- ✅ Automatic quality scores
- ✅ Three response templates

### v2.2 - 18/10/2025
- ✅ Added Firebase, API, Production checks
- ✅ 12 auto-checks total

### v2.1 - 18/10/2025
- ✅ Added Business Logic, State Management, Memory Leaks
- ✅ 9 auto-checks total

---

**Version:** 3.1 🎯  
**Created:** 18/10/2025 | **Updated:** 19/10/2025  
**Purpose:** Lean AI behavior guide - only essentials  
**Philosophy:** Details in DEVELOPER_GUIDE.md, guidance here  
**Made with ❤️ by Humans & AI** 👨‍💻🤖
