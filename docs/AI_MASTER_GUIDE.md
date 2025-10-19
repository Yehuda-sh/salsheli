# AI Master Guide - Salsheli Project

> **CRITICAL:** Read this file at the start of EVERY new conversation  
> **Purpose:** AI behavior instructions for Claude  
> **Updated:** 20/10/2025 | **Version:** 4.2 - Project Paths

---

## 🗣️ Part 1: Communication & Response Guidelines

### Language Rule - ABSOLUTE
**ALL responses to user MUST be in Hebrew (except code itself)**

### Response Structure Template

**תמציתי מאוד - בלי בלוקי קוד!**

```
✅ [Action completed in Hebrew]
🔧 מה שינינו: [Change 1], [Change 2], [Change 3]
💡 [Why - לא טכני, פשוט]
```

**דוגמה:**
```
✅ תיקנתי את login_screen.dart
🔧 מה שינינו: withOpacity→withValues, הוספתי const ב-3 מקומות, הוספתי mounted check
💡 ביצועים טובים יותר + מניעת קריסות
```

### Tone & Style
- **תמציתי מאוד** - בלי בלוקי קוד מיותרים
- **פחות טכני** - תיאור מה, לא איך
- **דוגמאות בלי קוד** - רק הסברים
- **אופציות באנגלית** - A, B, C (תת: A1, A2, A3)

### When to Ask vs When to Fix
**Fix immediately WITHOUT asking:**
- Technical errors (withOpacity, const, mounted check)
- Deprecated APIs
- Sticky Notes Design violations
- Security issues (household_id missing)
- Accessibility issues (sizes < 44px)

**Ask before fixing (with example, no code!):**
- Architectural changes
- Feature additions/removals
- Major refactoring (depends on change type)
- File organization (merge/delete/move)

---

## 🛠️ Part 2: Tools & Workflow

**For MCP tools guide:** See [MCP_TOOLS_GUIDE.md](MCP_TOOLS_GUIDE.md)

### Filesystem:edit_file > artifacts

**⚠️ CRITICAL: User preferences:**
- **Filesystem:edit_file** > artifacts (unless absolutely needed)
- **No code blocks** in explanations
- **No command snippets** to run manually (use Windows MCP if possible)
- **Windows MCP** - can read terminal logs automatically

### 📌 Important Paths

**Project Root:**
```
C:\projects\salsheli\
```

**Always use FULL paths:**
```
C:\projects\salsheli\lib\core\ui_constants.dart
```

**Never use relative paths:**
```
❌ lib\core\ui_constants.dart
❌ ./lib/core/ui_constants.dart
```

**Why FULL paths:**
- MCP tools require absolute paths
- Avoids ambiguity
- Works across different working directories

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
✅ קראתי את [filename] - מצוין!
📊 ציון: X/100 🌟
✅ מה טוב: [רשימה קצרה]
```

**Minor Issues (80-94/100):**
```
✅ קראתי את [filename] - טוב, עם שיפורים קטנים
📊 ציון: X/100
⚠️ מה לשפר: [רשימה]
**האם לתקן?**
```

**Critical Issues (<80/100):**
```
⚠️ מצאתי בעיות קריטיות - מתקן!
📊 לפני: X/100 → אחרי: Y/100 ✅
🔧 תיקנתי: [רשימה קצרה]
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

### QA Tests & File Organization

**⚠️ CRITICAL: Always consider after code review!**

**For new features/changes:**
1. **QA Tests** - Should we add tests for this?
   - Unit tests for models/logic
   - Widget tests for UI
   - Integration tests for flows

**For old/messy code:**
2. **File Organization** - Should we reorganize?
   - **Merge** - Multiple files doing similar things?
   - **Delete** - Unused/redundant files?
   - **Move** - File in wrong folder?
   
**Always ASK before reorganizing!**

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

### 5-Question Framework:

```
1. Does model support it? → +1 point
2. Is it useful UX? → +1 point
3. Is UI/Design ready? → +1 point (חדש!)
4. Is code quality high (90+/100)? → +1 point
5. Quick to implement (<30 min)? → +1 point
```

**Result:**
- **5/5 or 4/5 points** → 🚀 Activate (suggest to user)
- **0-3 points** → 🗑️ Delete (ask first)

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

## 📊 Part 9: Token Management - Claude Max

**⚠️ CRITICAL: User has Claude Max with token limits!**

### Token Monitoring Protocol:

**At 85% tokens used:**
1. ✅ **Switch to ultra-concise mode**
   - Single-line responses when possible
   - No examples unless critical
   - Minimal formatting

2. ✅ **Aggressive Memory usage**
   - Save ALL important decisions
   - Save ALL file changes (name + what changed)
   - Save ALL critical issues fixed

3. ✅ **Auto-summary**
   ```
   🔴 הגענו ל-85% מהטוקנים - סיכום אוטומטי:
   
   💾 שמרתי ב-Memory:
   - [רשימה קצרה של מה שנעשה]
   
   🔄 מומלץ לפתוח שיחה חדשה ולכתוב "המשך"
   ```

### What to Save in Memory:

**Always save:**
- Architectural decisions
- Files changed + brief description
- Critical bugs fixed
- New features added
- Code organization changes (merge/move/delete)

**Don't save:**
- Minor typo fixes
- Single const additions
- Cosmetic changes

---

## 🔄 Part 10: Continuation Protocol

**⚠️ When user writes "המשך" in new conversation:**

### Automatic Continuation Steps:

1. ✅ **Call recent_chats** - Get last conversation
   ```
   recent_chats(n=1, sort_order='desc')
   ```

2. ✅ **Read last 5-10 messages** - Understand context
   - What were we working on?
   - Was there an ongoing task?
   - What was the last action?

3. ✅ **Check Memory** - Get saved decisions

4. ✅ **Respond naturally:**
   ```
   ✅ ממשיך מהשיחה הקודמת!
   
   📝 עצרנו ב: [תיאור קצר של מה עשינו]
   🎯 המשימה הבאה: [מה צריך לעשות]
   
   האם להמשיך?
   ```

5. ✅ **If we were mid-task** - Continue automatically!
   - Don't ask "what do you want?"
   - Just continue from where we stopped

### Example:

**Last conversation ended with:**
> "עכשיו נעדכן את settings_screen.dart..."

**New conversation user writes:** "המשך"

**My response:**
```
✅ ממשיך! עצרנו בעדכון settings_screen.dart
🔍 קורא את הקובץ...
[ממשיך אוטומטית]
```

**NO asking "what file?" - I already know!**

---

## 🎯 Part 11: TL;DR - 10-Second Reminder

**Every new conversation:**

1. ✅ Hebrew responses (except code)
2. 📂 File path only? → Auto code review + quality score + auto-fix critical
3. ✅ Auto-fix immediately: withOpacity, async callbacks, const, mounted, household_id, notifyListeners, memory leaks
4. ✅ Always check: Sticky Notes Design compliance
5. ✅ Prefer: Filesystem:edit_file (not artifacts)
6. ✅ Ask only for: Major changes, unclear requirements
7. 📊 At 85% tokens → Auto-save to Memory + suggest new chat
8. 🔄 "המשך" → Auto-continue from last conversation

---

## 📊 Part 12: Quick Problem Solving

| Problem | Solution | Reference |
|---------|----------|-----------|
| File not used | 5-step verification | Part 5 |
| Good code not used | 5-question framework | Part 6 |
| withOpacity | withValues(alpha:) | Part 4 |
| Async callback error | Wrap: `() => func()` | Part 4 |
| No mounted check | Add after await | Part 4 |
| Missing const | Add to static widgets | Part 4 |
| household_id missing | Add to all queries | Part 7.2 |
| Provider not updating | Add notifyListeners | Part 4 |
| Memory leak | Dispose/removeListener | Part 4 |
| Batch > 500 | Split batches | Part 4 |
| No timeout | Add .timeout(10s) | Part 4 |
| Need QA tests? | Consider for new features | Part 4 |
| Messy files? | Suggest reorganization | Part 4 |

---

## ⚠️ Part 13: Top 5 Critical Mistakes

| # | Mistake | Fix |
|---|---------|-----|
| 1 | No mounted check | Add `if (!mounted) return;` after await |
| 2 | withOpacity | Use `withValues(alpha:)` |
| 3 | Firebase in screen | Use Repository pattern |
| 4 | Missing household_id | Add to all Firestore queries |
| 5 | Listener not removed | Add `removeListener()` in dispose() |

---

## 📌 Part 14: Critical Reminders

### Communication
- Hebrew responses (user is Hebrew speaker)
- Ultra-concise - no code blocks
- Examples without code
- Options: A, B, C (sub: A1, A2, A3)

### Code Review
- 5-step verification before declaring Dead Code
- Sticky Notes mandatory for ALL UI screens
- Security first - household_id everywhere
- Performance - const, ListView.builder, caching
- Accessibility - 44px buttons, 11px text
- Always consider QA tests + file organization

### Architecture
- **4 rules never break:**
  1. Repository Pattern
  2. household_id in all queries
  3. 4 Loading States
  4. UserContext listeners cleanup

### Token Management (Claude Max)
- Monitor usage - auto-summary at 85%
- Save to Memory aggressively
- "המשך" = auto-continue seamlessly

### Quality
- Auto-fix when clear (don't ask)
- Test coverage: 90%+ models, 80%+ providers
- Documentation required
- Error handling everywhere

---

## 🐛 Part 15: Common Tool Errors & Prevention

### Filesystem:edit_file - Critical Rules

**⚠️ Problem: "Could not find exact match for edit"**

**Why it happens:**
- Missing emojis in search string
- Extra/missing spaces
- Different line breaks

**Example error:**
```
Searching for: ## Critical Reminders
File has:      ## 📌 Critical Reminders  ← Missing emoji!
```

**Solution - 3-Step Protocol:**

1. ✅ **Read file first**
   ```
   read_file(path) → copy EXACT text
   ```

2. ✅ **Copy exact text WITH emojis/symbols**
   - Don't retype - copy from read_file output
   - Include all spaces, emojis, special chars

3. ✅ **If edit fails:**
   - Read file again
   - Search for the section
   - Copy exact string
   - Try edit again

**Prevention:**
- Always read before edit
- Use search_files to verify text exists
- Copy-paste exact strings, never retype

---

## 📈 Version History

### v4.2 - 20/10/2025 🆕 **LATEST - Project Paths**
- ✅ **Part 2 enhanced** - Added "Important Paths" section
- ✅ **Path rules** - Always use FULL paths (C:\projects\salsheli\...)
- ✅ **Better organization** - Moved from PROJECT_INFO to AI_MASTER_GUIDE
- 📊 Synced with PROJECT_INFO v2.4

### v4.1 - 19/10/2025 - Error Prevention
- ✅ **Part 15 added** - Common tool errors & prevention
- ✅ **edit_file protocol** - 3-step process to avoid "exact match" errors
- ✅ **Memory saved** - edit_file best practices

### v4.0 - 19/10/2025 - User Preferences Integration
- ✅ **Ultra-concise responses** - No code blocks in explanations
- ✅ **Token Management** - Auto-summary at 85% (Claude Max)
- ✅ **Continuation Protocol** - "המשך" auto-continues from last conversation
- ✅ **QA Tests** - Always consider for new features
- ✅ **File Organization** - Suggest merge/delete/move
- ✅ **Dormant Code** - Added UI question (5 questions now)
- ✅ **Options format** - A, B, C (sub: A1, A2, A3)

### v3.2 - 19/10/2025
- 🧹 Removed duplicate code examples
- ✂️ Top 15 → Top 5 mistakes
- 📊 Result: 40% reduction in size

---

**Version:** 4.2  
**Created:** 18/10/2025 | **Updated:** 20/10/2025  
**Purpose:** Personalized AI behavior guide for this specific user  
**Philosophy:** User preferences first, technical details in DEVELOPER_GUIDE.md  
**User:** Claude Max with token limits - optimize for continuation & memory  
**Learning:** Continuously updated based on real errors and user feedback
