# AI Master Guide - Salsheli Project

> **CRITICAL:** Read this file at the start of EVERY new conversation  
> **Purpose:** AI behavior instructions for Claude  
> **Updated:** 19/10/2025 | **Version:** 3.2 - Cleaned & Optimized

---

## 🗣️ Part 1: Communication & Response Guidelines

### Language Rule - ABSOLUTE
**ALL responses to user MUST be in Hebrew (except code itself)**

### Response Structure Template

```
✅ [Action completed in Hebrew]
[Show code changes]
🔧 מה שינינו:
1. [Change 1]
2. [Change 2]
💡 [Why these changes matter]
```

### Tone & Style
- Friendly but professional
- Technical but accessible (user is beginner)
- Concise - no unnecessary explanations

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

**For MCP tools guide:** See [MCP_TOOLS_GUIDE.md](MCP_TOOLS_GUIDE.md)

### Filesystem:edit_file > artifacts

**⚠️ CRITICAL: User prefers Filesystem:edit_file over artifacts!**

---

## 📂 Part 3: Default Behavior When User Sends Only File Path

**⚠️ CRITICAL: Auto code review when receiving file path only!**

### Your Automatic Response Protocol:

```
1️⃣ READ THE FILE → Use Filesystem:read_file immediately

2️⃣ PERFORM COMPREHENSIVE CODE REVIEW (13 checks):
   ✅ Technical Errors
   ✅ Sticky Notes Design
   ✅ Security
   ✅ Performance
   ✅ Accessibility
   ✅ Best Practices
   ✅ Business Logic
   ✅ State Management
   ✅ Memory Leaks
   ✅ Firebase
   ✅ API Integration
   ✅ Production Readiness
   ✅ Navigation (Orphan Screen check)

3️⃣ AUTO-FIX CRITICAL ISSUES (WITHOUT asking)

4️⃣ REPORT NON-CRITICAL ISSUES (ask before fixing)

5️⃣ PROVIDE STRUCTURED REPORT:
   📊 Quality Score: X/100
   ✅ What's Good
   ⚠️ What to Improve
   💡 Recommendations
```

### Response Templates:

**Perfect File (95-100/100):**
```
## ✅ קראתי את הקובץ - נראה מצוין! 🎉
הקובץ `[filename]` איכותי מאוד ועומד בכל הסטנדרטים!
### 📊 ציון: X/100 🌟
## ✅ מה טוב: [List strengths]
```

**Minor Issues (80-94/100):**
```
## ✅ קראתי את הקובץ - טוב, עם שיפורים קטנים
### 📊 ציון: X/100
## ⚠️ מה לשפר: [Issues]
**האם תרצה שאתקן?**
```

**Critical Issues (<80/100):**
```
## ⚠️ מצאתי בעיות קריטיות - מתקן אוטומטית!
### 📊 ציון לפני: X/100
## 🔧 תיקונים קריטיים: [List fixes]
### 📊 ציון אחרי: Y/100 ✅
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
- `NotebookBackground()` + `kPaperBackground`
- `StickyNote()` for content
- `StickyButton()` for buttons
- Rotations: -0.03 to 0.03
- Max 3 colors per screen

### Security Checks

| Check | Action if missing |
|-------|-------------------|
| household_id in queries | Add immediately |
| API keys in code | Report as CRITICAL |
| Sensitive data in logs | Remove immediately |

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

### 🧭 Navigation & Accessibility

**⚠️ CRITICAL:** Verify users can reach screen from UI!

#### 5-Step Navigation Check:

```bash
1️⃣ Check route exists in main.dart
2️⃣ Search for navigation calls: grep -r "'/screen-name'" lib/
3️⃣ Check Bottom Navigation: lib/screens/home/home_screen.dart
4️⃣ Check Dashboard cards: lib/screens/home/home_dashboard_screen.dart
5️⃣ Check Settings menu: lib/screens/settings/settings_screen.dart
```

**If ALL 5 checks fail = Orphan Screen! 🚨**

#### Action Protocol:
1. REPORT: "מצאתי מסך [ScreenName] אבל אין דרך להגיע אליו מהממשק"
2. SUGGEST: Dashboard card / Bottom Nav / Settings / Deep link
3. IMPLEMENT chosen solution

#### Priority Matrix:

| Screen Type | Best Navigation |
|-------------|----------------|
| Analytics/Insights | Dashboard card |
| Core feature | Bottom Nav |
| Settings/Config | Settings menu |
| Flow step | Deep link |
| Admin/Debug | No UI needed |

**Golden Rule:** Every screen with a route MUST be accessible through at least 1 UI path!

---

## 🗑️ Part 5: Dead Code Detection

**⚠️ NEVER delete based on 0 imports alone!**

### 5-Step Verification:

1. Full import search: `"import.*file_name.dart"`
2. Relative import: `"folder_name/file_name"` ← CRITICAL!
3. Class name search: `"ClassName"`
4. Check related files
5. Read file itself

**Safe to delete:**
- After ALL 5 checks = 0 usage
- Marked "EXAMPLE ONLY"
- Marked "DO NOT USE"

**DO NOT delete:**
- Any doubt → ASK USER

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
- ❌ Never use Firebase directly in screens
- ✅ Always use Repository abstraction
- See: DEVELOPER_GUIDE.md for implementation

### 2. household_id Filter - Always Required
- ❌ Never query without household_id filter
- ✅ Add `.where('household_id', isEqualTo: userHouseholdId)` to all queries

### 3. Loading States - All 4 Required
- Loading, Error, Empty, Data states mandatory
- See: DEVELOPER_GUIDE.md for pattern

### 4. UserContext Listeners - Must Dispose
- Always add listener in constructor
- Always remove listener in dispose()
- See: DEVELOPER_GUIDE.md for implementation

---

## 📚 Part 8: Documentation References

| Need | Document |
|------|----------|
| **Code patterns** | DEVELOPER_GUIDE.md |
| **UI/UX** | DESIGN_GUIDE.md |
| **MCP Tools** | MCP_TOOLS_GUIDE.md |
| **Project info** | PROJECT_INFO.md |

---

## 🎯 Part 9: TL;DR - 10-Second Reminder

**Every new conversation:**

1. ✅ Hebrew responses (except code)
2. 📂 File path only? → Auto code review + quality score + auto-fix critical
3. ✅ Auto-fix immediately: withOpacity, async callbacks, const, mounted, household_id, notifyListeners, memory leaks
4. ✅ Always check: Sticky Notes Design compliance
5. ✅ Prefer: Filesystem:edit_file (not artifacts)
6. ✅ Ask only for: Major changes, unclear requirements

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
| Batch > 500 | Split batches | Part 4 |
| No timeout | Add .timeout(10s) | Part 4 |

---

## ⚠️ Top 5 Critical Mistakes

| # | Mistake | Fix |
|---|---------|-----|
| 1 | No mounted check | Add `if (!mounted) return;` after await |
| 2 | withOpacity | Use `withValues(alpha:)` |
| 3 | Firebase in screen | Use Repository pattern |
| 4 | Missing household_id | Add to all Firestore queries |
| 5 | Listener not removed | Add `removeListener()` in dispose() |

---

## 📌 Critical Reminders

### Communication
- Hebrew responses (user is Hebrew speaker, beginner)
- edit_file preferred over artifacts
- Concise - no over-explaining

### Code Review
- 5-step verification before declaring Dead Code
- Sticky Notes mandatory for ALL UI screens
- Security first - household_id everywhere
- Performance - const, ListView.builder, caching
- Accessibility - 44px buttons, 11px text

### Architecture
- **4 rules never break:**
  1. Repository Pattern
  2. household_id in all queries
  3. 4 Loading States
  4. UserContext listeners cleanup

### Quality
- Auto-fix when clear (don't ask)
- Test coverage: 90%+ models, 80%+ providers
- Documentation required
- Error handling everywhere

---

## 📈 Version History

### v3.2 - 19/10/2025 🆕 **LATEST - Cleaned & Optimized**
- 🧹 Removed duplicate code examples
- ✂️ Top 15 → Top 5 mistakes
- ✂️ Version history: 5 → 2 versions
- ✂️ Removed marketing fluff
- 📊 Result: 40% reduction in size

### v3.1 - 19/10/2025
- ✅ Added 13th check: Navigation/Orphan Screens detection
- ✅ Complete coverage of all code quality aspects

---

**Version:** 3.2  
**Created:** 18/10/2025 | **Updated:** 19/10/2025  
**Purpose:** Lean AI behavior guide - only essentials  
**Philosophy:** Rules here, details in DEVELOPER_GUIDE.md
