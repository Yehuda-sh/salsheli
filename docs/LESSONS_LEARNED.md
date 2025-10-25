# 📘 LESSONS_LEARNED - MemoZap

> **Updated:** 25/10/2025 (Post Stage 3 Testing)  
> **Purpose:** Internal AI reference — mistakes to avoid and refined best practices.  
> **Context:** Project path → `C:\projects\salsheli\`

---

## 🔧 Code & Logic Patterns

### 1️⃣ File Editing

- ❌ Edited files without verifying original string → “no match” errors.  
  ✅ Always `read_text_file` → confirm → then `edit_file`.
- ❌ Used relative paths.  
  ✅ Always use **full Windows path** (e.g., `C:\projects\salsheli\lib\main.dart`).
- ❌ Overused `write_file` instead of `edit_file`.  
  ✅ Only use `edit_file` for surgical changes.

### 2️⃣ MCP & Terminal

- ❌ Tried `grep` with Windows path → failed (`ENOENT`).  
  ✅ Use `search_files` instead of `bash_tool` for search operations.
- ❌ Overreliance on Bash for short tasks.  
  ✅ Prefer Filesystem tools unless automation needed.

### 3️⃣ Project Logic

- ❌ Forgot to migrate data when changing repository pattern.  
  ✅ Always create `migrate_*` script in `scripts/`.
- ❌ Suggested logic outside MemoZap scope (e.g., receipt scanning).  
  ✅ Keep focus on pantry, shopping lists, tasks, and smart suggestions.

### 4️⃣ Stage Management

- ❌ Created too many files without checkpoints.  
  ✅ Save checkpoint after every 3-4 file modifications.
- ❌ Editing complex files without reading first.  
  ✅ Read large files (>500 lines) before any `edit_file` operation.
- ❌ Not tracking progress in session.  
  ✅ After each stage completion → save to Memory with % complete.

### 5️⃣ Memory Tool Issues

- ❌ `Tool execution failed` when using Memory tool  
  ✅ **Pattern (CRITICAL):**
  1. קודם `search_nodes` או `read_graph`
  2. אם entity קיים → `add_observations`
  3. אם entity לא קיים → `create_entities`
  4. **אסור** לנסות `add_observations` על entity שלא קיים
- ❌ Trying to add observations without checking entity exists.  
  ✅ Always verify entity existence before update.

---

## 🎯 Flutter Common Mistakes & Solutions

### 1️⃣ const Usage

- ❌ שמתי const על widget עם ארגומנטים דינמיים (variables, parameters)  
  ✅ const רק עם ערכים קבועים בזמן קומפילציה (literals, enum values)
- **דוגמה:** `const SizedBox(height: 16)` ✅ אבל `const _StatCard(value: count)` ❌

### 2️⃣ Color API Changes

- ❌ השתמשתי ב-withOpacity (deprecated מ-Flutter 3.22)  
  ✅ השתמש ב-withValues: `Colors.black.withValues(alpha: 0.5)`

### 3️⃣ Async Callbacks

- ❌ `onPressed: _asyncFunc` (טעות טיפוס - Future<void> במקום void)  
  ✅ `onPressed: () => _asyncFunc()` (חייב wrapper function)

### 4️⃣ Context After Await

- ❌ `await func(); Navigator.of(context).push(...)`  
  ✅ `final nav = Navigator.of(context); await func(); if (!mounted) return; nav.push(...)`
- **סיבה:** context יכול להיות invalid אחרי await

---

## 🧪 Testing & Integration

### 1️⃣ Widget Testing Best Practices

- ❌ `find.byWidgetPredicate(widget.decoration)` לא עובד!  
  ✅ השתמש ב-`find.bySemanticsLabel()` (גם מוסיף accessibility)
- **דוגמה:** `find.bySemanticsLabel(AppStrings.auth.emailLabel)`

- ❌ לא בודק Empty/Loading/Error states  
  ✅ כל widget צריך 3 states בסיסיים: Loading, Error, Empty/Content

- ❌ לא בודק animations  
  ✅ בדוק FadeIn, SlideIn וכו' עם `tester.pumpAndSettle()`

### 2️⃣ Mock & Stub Patterns

- ❌ לא רצתי build_runner לפני tests  
  ✅ תמיד: `flutter pub run build_runner build` לפני `flutter test`

- ❌ שגיאה: "The getter 'x' isn't defined for the type 'Mock'"  
  ✅ הוסף stub מפורש: `when(() => mockProvider.x).thenReturn(value);`
  
- **דוגמה מעשית:**
  ```dart
  // ❌ גורם לשגיאה:
  final mockProvider = MockSuggestionsProvider();
  // שימוש: mockProvider.pendingSuggestionsCount
  
  // ✅ נכון:
  final mockProvider = MockSuggestionsProvider();
  when(() => mockProvider.pendingSuggestionsCount).thenReturn(2);
  ```

### 3️⃣ Test File Naming

- ❌ שם פרויקט שגוי ב-imports (`package:salsheli/...`)  
  ✅ שם הפרויקט: `memozap` (בדוק pubspec.yaml)
- **הערה:** תיקיית העבודה `C:\projects\salsheli` אבל שם הפרויקט `memozap`

### 4️⃣ Testing Error Handling

- ❌ לא בודק error states כראוי  
  ✅ צריך לבדוק:
  - הודעת שגיאה מוצגת
  - כפתור Retry/Refresh קיים
  - State מתעדכן לאחר שגיאה

- ❌ שכחתי stub ל-properties של Mock  
  ✅ כל property שנגיש בטסט צריך stub מפורש

---

## 🏗️ MemoZap Architecture Rules

### 1️⃣ household_id Filter (CRITICAL!)

- ❌ שכחתי `.where('household_id', isEqualTo: ...)` בשאילתות  
  ✅ **בכל שאילתת Firestore חייב לסנן לפי household_id**
- **סיבה:** בעיית אבטחה קריטית - משתמש יכול לראות נתונים של אחרים!

### 2️⃣ Logging Best Practices

- ❌ יותר מ-15 debugPrint בקובץ אחד  
  ✅ מקסימום 15 logs למסך: lifecycle + שגיאות + פעולות קריטיות בלבד
- **מה להשאיר:** initState/dispose, try-catch errors, critical actions (logout, delete)
- **מה להסיר:** התחלות/סיומים רגילים, ניווטים פשוטים, לחצני UI

### 3️⃣ Model Updates

- ❌ שכחתי לרוץ build_runner אחרי שינויים ב-@JsonSerializable  
  ✅ אחרי כל שינוי במודל: רוץ build_runner, בדוק קומפילציה
- **פקודה:** `flutter pub run build_runner build --delete-conflicting-outputs`

### 4️⃣ Repository Pattern

- ❌ גישה ישירה ל-Firestore מ-Screens/Widgets  
  ✅ **תמיד** דרך Repository → Provider → Screen
- **סיבה:** ניתן לבדיקה, ניתן להחלפה, separation of concerns

### 5️⃣ UserContext Integration

- ❌ שכחתי removeListener() ב-dispose()  
  ✅ **Pattern חובה:**
  ```dart
  // Constructor
  _userContext.addListener(_onUserChanged);
  
  // dispose()
  _userContext.removeListener(_onUserChanged);
  ```
- **סיבה:** מניעת memory leaks

---

## 🎨 UI/UX & Structure

### 1️⃣ Hebrew & RTL

- ❌ Ignored RTL layout.  
  ✅ All UI text → align right + test with Hebrew labels.

### 2️⃣ Sticky Notes Design System

- ❌ Suggested random UI elements.  
  ✅ Always reference `DESIGN_GUIDE.md`.

### 3️⃣ User Flow

- ❌ Focused on features before UI skeleton.  
  ✅ Build UI first → then connect logic.

---

## 💬 Communication

### 1️⃣ With User

- ❌ Provided long code blocks.  
  ✅ Explain in **text**, simple Hebrew, real project context.
- ❌ Too many tokens → redundant phrasing.  
  ✅ Keep concise; one clear summary per topic.

### 2️⃣ User Preferences

- ❌ Artifacts (בכלל!)  
  ✅ תמיד `filesystem:edit_file` (מפורש מהמשתמש)
- ❌ הסברים טכניים ארוכים  
  ✅ תמציתי בעברית + מה השתנה (לא איך)
- ❌ קוד snippets להרצה ידנית  
  ✅ פשוט תסביר מה צריך לקרות

### 3️⃣ With Other AI Agents

- ❌ Missing shared memory for past issues.  
  ✅ Store lessons here, and update on each fix.

---

## 📚 Documentation Maintenance

### 1️⃣ ניקוי קבצים מיותרים

- ❌ קבצים כפולים עם תוכן דומה  
  ✅ לשמור קובץ אחד עם התוכן המעודכן
- ❌ הפניות לקבצים שלא קיימים  
  ✅ חפש ועדכן בכל הקבצים (`search_files`)
- ❌ שמות קבצים שונים לאותו תוכן  
  ✅ שמות עקביים ואחידים (LESSONS_LEARNED.md ✓)

### 2️⃣ עדכון הפניות בתיעוד

- ✅ **תהליך מלא:**
  1. חפש את שם הקובץ הישן בכל התיקיות (`search_files`)
  2. עדכן כל הפניה לשם החדש (`edit_file`)
  3. מחק את הקובץ הישן
  4. עדכן README.md ב-docs/
- **דוגמה:** MEMOZAP_LESSONS_AND_ERRORS.md → LESSONS_LEARNED.md (24/10/2025)
- **דוגמה 2:** MEMOZAP_INDEX.md → מוזג ל-README.md (25/10/2025)

### 3️⃣ שמירת סינכרון

- ✅ README.md חייב להשתקף את מצב הקבצים באמת
- ✅ עדכן תאריך + גרסה אחרי שינויים
- ✅ תעד ב-LESSONS_LEARNED.md את השינויים

---

## 🔄 Session Continuity

### 1️⃣ המשך מהשיחה האחרונה

- ❌ המשתמש כתב "המשך" ושאלתי שאלות  
  ✅ מיד `recent_chats(n=1)` → קרא 5-10 הודעות אחרונות → המשך אוטומטי
- **כלל:** "המשך" = continue from LAST chat, לא שאלות!

### 2️⃣ Token Management

- ⚠️ ב-70% טוקנים (133K/190K) → הצג התראה בסוף תשובה:  
  `⚠️ Token Alert: 70% - נותרו 30% מהשיחה`
- 🔴 ב-85% טוקנים → מצב ultra-concise + שמור הכל ב-Memory  
- 📝 "נעבור" מהמשתמש → עדכן Current Work Context + תן 4 משפטים אחרונים

### 3️⃣ Checkpoint Strategy

- ✅ שמור checkpoint אחרי כל 3-5 קבצים ששונו
- ✅ עדכן Current Work Context כל 10 הודעות
- ✅ שמור החלטות ארכיטקטורליות ב-Memory מיד

---

## 🧠 Meta Rules

| Keyword           | Meaning                                        |
| ----------------- | ---------------------------------------------- |
| **"תבונות"**      | Trigger to recall this file and apply lessons. |
| **"בדיקה חוזרת"** | Re-run same analysis, avoiding prior errors.   |
| **"שגיאה חוזרת"** | Append to this file under relevant section.    |

---

---

## 📊 Recent Learnings (Last 7 Days)

### 24/10/2025 (Evening)
- ✅ **מסלול 3 שלב 3.7 הושלם!** - הסרת סריקת קבלות מלאה
- 🗑️ 11 קבצים נמחקו: OCR, parsers, UI של קבלות, widgets
- 📝 3 קבצים עודכנו: main.dart, home_screen.dart, pubspec.yaml
- 💾 שמרנו Receipt models (לקבלות וירטואליות)
- 👀 Bottom Navigation: 5 טאבים → 4 טאבים

### 24/10/2025 (Morning)
- ✅ מסלול 2 (שיתוף משתמשים) הושלם - Security Rules + UI מלא
- 🔧 תיקון: const על widgets עם ארגומנטים דינמיים (active_shopping_screen.dart)
- 📝 עדכון: LESSONS_LEARNED.md עם Flutter best practices
- 🧹 ניקוי תיעוד: מחקנו MEMOZAP_LESSONS_AND_ERRORS.md (מיותר)
- ✅ עדכון MEMOZAP_CORE_GUIDE.md: Memory Tool Pattern + Checkpoint Protocol
- 📝 מיזוג MEMOZAP_INDEX.md לתוך README.md

### 25/10/2025 (ערב)
- 🧪 **Widget Testing Mastery!** - למדנו patterns נכונים לבדיקות
  - ✅ SmartSuggestionsCard: 15/15 טסטים עברו
  - ✅ LastChanceBanner: 12/12 טסטים עברו
  - 🔧 תיקון: stub patterns ל-Mock properties (pendingSuggestionsCount)
  - 📝 Testing 4 states: Loading, Error, Empty, Content
  - 🎬 Animation testing עם pumpAndSettle()

### 25/10/2025 (בוקר)
- ✅ **מסלול 3 שלב 3.6 הושלם!** - סיום קנייה + עדכון מלאי
  - 🛒 לוגיקה מלאה: עדכון אוטומטי + העברת פריטים
  - ➕ addStock() = חיבור (לא החלפה!)
  - 📦 3 חלב + 2 נקנו = 5 במזווה ✅

### 24/10/2025 (לילה)
- ✅ **מסלול 3 שלבים 3.3-3.5 הושלמו!**
  - 🎨 Dashboard חדש עם SmartSuggestionsCard + ActiveListsSection
  - ⚠️ LastChanceBanner במצב קנייה פעילה
  - 📋 shopping_lists_screen V5.0 - תצוגה מאוחדת

### 23/10/2025 (Evening)
- 🗑️ הסרת סריקת קבלות: 11 קבצים נמחקו
- ✅ שמרנו: ReceiptProvider + ReceiptRepository (לקבלות וירטואליות)
- 📝 Bottom Navigation: 5 טאבים → 4 טאבים

### 23/10/2025
- ✅ מסלול 1 (Tasks + Products) הושלם - UnifiedListItem + tests
- ✅ מסלול 2 (שיתוף משתמשים) הושלם - 4 הרשאות + Security Rules
- 🧪 למדתי: `find.bySemanticsLabel()` במקום `widget.decoration`
- 🏗️ למדתי: build_runner חובה לפני flutter test

---

## 🎯 Critical Patterns Summary

### Testing Checklist:
```dart
// ✅ תמיד בדוק 4 states:
1. Loading state (skeleton/shimmer)
2. Error state (message + retry)
3. Empty state (message + CTA)
4. Content state (data rendering)

// ✅ תמיד stub כל property:
when(() => mock.property).thenReturn(value);

// ✅ תמיד בדוק animations:
await tester.pumpAndSettle();
```

### Memory Tool Pattern:
```dart
// ✅ תמיד קודם:
1. search_nodes() או read_graph()
2. אם קיים → add_observations()
3. אם לא → create_entities()
```

### File Editing Pattern:
```dart
// ✅ תמיד:
1. read_text_file() - קרא קודם
2. אמת את הטקסט המדויק
3. edit_file() - ערוך
```

---

**Next Review:** 01/11/2025  
**Maintainer:** AI System (Claude)  
**Location:** `C:\projects\salsheli\docs\LESSONS_LEARNED.md`
