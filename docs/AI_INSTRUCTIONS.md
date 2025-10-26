# 🎯 MemoZap AI Instructions
> **תוכנית הוראות עבודה מעודכנת - אוקטובר 2025 v4.0**

---

## 📍 מיקום הפרוייקט

**נתיב בסיס:** `C:\projects\salsheli\`  
**תיקיית תיעוד:** `C:\projects\salsheli\docs\`  
**פלטפורמה:** Flutter (iOS/Android)  
**שפה ראשית:** עברית (RTL)

---

## 🚀 פרוטוקול התחלת שיחה

### קריאה אוטומטית בכל שיחה:
**בסדר זה בדיוק:**

1. **GUIDE.md** - נקודת כניסה מרכזית (Project + Files + Memory + MCP)
2. **CHANGELOG.md** - בדוק אם יש `[In Progress]`

### אם צריך מידע נוסף:
- **CODE.md** - לפני כתיבת/סקירת קוד
- **DESIGN.md** - לפני עבודת UI/UX
- **TECH.md** - לפני עבודה עם Firebase/Security
- **LESSONS_LEARNED.md** - לפני שינויים מסוכנים

---

## 📚 מסמכי התיעוד (6 קבצים)

| קובץ | תוכן | גודל | מתי לקרוא |
|------|------|------|-----------|
| **GUIDE.md** | Project info, Files, Memory, MCP tools | 400 | 🔴 תמיד ראשון |
| **CODE.md** | Architecture, Patterns, Testing, Mistakes | 500 | לפני קוד |
| **DESIGN.md** | Sticky Notes, RTL, Components, States | 300 | לפני UI |
| **TECH.md** | Firebase, Security, Models, Dependencies | 400 | לפני Backend |
| **LESSONS_LEARNED.md** | Common mistakes & solutions | - | ⚠️ לפני שינויים מסוכנים |
| **CHANGELOG.md** | Project history + `[In Progress]` | - | בדוק סטטוס נוכחי |

---

## 🎯 מתי לקרוא איזה מסמך?

### 📝 כתיבת קוד / רפקטורינג
```
1. GUIDE.md (הקשר כללי)
2. CODE.md (דפוסי קוד)
3. LESSONS_LEARNED.md (אל תטעה!)
```

### 🎨 עיצוב UI/UX
```
1. GUIDE.md (הקשר כללי)
2. DESIGN.md (Sticky Notes system)
3. CODE.md (widget patterns)
```

### 🔧 Firebase / Security / Models
```
1. GUIDE.md (הקשר כללי)
2. TECH.md (Firestore structure, rules)
3. CODE.md (repository pattern)
```

### 🔨 כלי MCP
```
1. GUIDE.md (פרוטוקול MCP מלא)
2. LESSONS_LEARNED.md (טעויות נפוצות)
```

### ✨ פיצ'ר חדש
```
1. GUIDE.md (הקשר)
2. CODE.md (ארכיטקטורה)
3. DESIGN.md (UI requirements)
4. TECH.md (Firebase/Models)
5. CHANGELOG.md (עדכן אחרי)
```

---

## 💾 פרוטוקול Checkpoints והמשכיות

### כללי שמירה אוטומטית
✅ צור checkpoint לאחר כל **2-3 שינויי קבצים**  
✅ עדכן CHANGELOG.md עם סעיף `[In Progress]`  
✅ השתמש בכלי memory לשמירת מצב הסשן  
✅ עדכן Current Work Context כל **2 הודעות**

### פורמט Checkpoint
```markdown
## [In Progress] - 2025-10-25

### Session #N - Feature: [שם הפיצ'ר]
**Files Modified:**
1. `lib/models/task.dart` - Added reminder field
2. `lib/providers/tasks_provider.dart` - Implemented save logic

**Status:** 60% complete

**Next Steps:**
- [ ] Add UI for reminder selection
- [ ] Test on Android emulator

**Blocked By:** [אם יש חסימות]
```

### פקודות המשכיות

| פקודה | פעולה |
|-------|-------|
| **"תמשיך"** | טען checkpoint אחרון והמשך עבודה |
| **"שמור checkpoint"** | כפה שמירה מיידית |
| **"המשך"** | טען שיחות אחרונות והמשך מההודעה האחרונה |

### תהליך המשך עבודה:

1. **קרא** `CHANGELOG.md` → סעיף `[In Progress]`
2. **חפש** במערכת memory → `read_graph()` או `search_nodes("last checkpoint")`
3. **טען** מצב עבודה אחרון
4. **המשך** מנקודת העצירה המדויקת

---

## 🚫 MCP Anti-Patterns (אל תעשה!)

**דברים שגורמים לבעיות ושבור את זרימת העבודה:**

### ❌ 1. Artifacts במקום edit_file
**לעולם לא** תשתמש ב-artifacts לעריכת קוד בפרויקט הזה!
- **למה?** המשתמש מעדיף edit_file באופן מפורש
- **פתרון:** תמיד Filesystem:edit_file

### ❌ 2. Sequential Thinking לתיקונים פשוטים
**אל** תשתמש ב-Sequential Thinking לשינוי שורה אחת!
- **למה?** בזבוז טוקנים מיותר
- **פתרון:** רק לבעיות מורכבות רב-שלביות

### ❌ 3. Web Search למידע שקיים בתיעוד
**אל** תחפש ברשת מידע שכבר קיים ב-docs!
- **למה?** בזבוז זמן וטוקנים
- **פתרון:** קרא GUIDE.md/CODE.md קודם

### ❌ 4. Memory Entries לשיחות זמניות
**אל** תשמור ב-memory מידע זמני מהשיחה!
- **למה?** Memory רק לידע ארוך-טווח
- **פתרון:** Current Work Context בלבד

### ❌ 5. Auto-Commit בלי אישור
**לעולם לא** תעשה commit לגיטהאב בלי אישור!
- **למה?** המשתמש רוצה לבדוק קודם
- **פתרון:** הצג שינויים, חכה לאישור

### ❌ 6. קריאת קבצים מיותרת
**אל** תקרא קבצים אם המידע כבר בתיעוד!
- **למה?** בזבוז טוקנים
- **פתרון:** בדוק docs/ קודם

---

## 💬 Communication Protocol

**האופן המועדף של המשתמש לקבל תשובות:**

### ✅ מה המשתמש אוהב:
- תשובות **קצרות** בעברית
- אופציות כ-**A, B, C** (sub-options: A1, A2)
- **פחות הסברים טכניים** - מה, לא איך
- **ללא code blocks** אלא אם ממש מבקשים
- **ללא artifacts** - רק edit_file

### ❌ מה המשתמש לא אוהב:
- הסברים ארוכים וטכניים
- קוד snippets לריצה ידנית
- שאלות מיותרות - פשוט תעשה
- "האם תרצה ש..." - פשוט תעשה

### 📝 פורמט תשובה אידיאלי:
```
[סיכום קצר של מה נעשה]

שינויים:
- קובץ 1: מה שונה
- קובץ 2: מה שונה

[צעד הבא אם יש]

✅ [סטטוס אם רלוונטי]
```

---

## 🎯 עקרונות ליבה

### ✅ תמיד עשה
- קרא GUIDE.md בתחילת כל שיחה
- קרא קבצים לפני עריכה
- השתמש בנתיבים מוחלטים: `C:\projects\salsheli\...`
- בדוק תצוגת RTL לעברית
- עדכן CHANGELOG.md מיד אחרי שינויים
- שמור checkpoints כל 2-3 שינויים
- חפש ב-memory לפני יצירת entities חדשים
- אמת פקודות לפני הרצה

### ❌ אל תעשה
- נתיבים יחסיים
- עריכה ללא קריאה מקדימה
- הנחה ש-entity קיים ב-memory
- התעלמות מ-LESSONS_LEARNED.md
- ערבוב LTR/RTL ללא Directionality
- מחרוזות קשיחות (השתמש ב-l10n)
- דילוג על עדכוני CHANGELOG
- retry עיוור על כלים שנכשלו
- שימוש ב-context אחרי await ללא בדיקת mounted
- שכחת const על widgets סטטיים
- שכחת removeListener ב-dispose()

---

## 🔥 Critical Patterns (קריטי ביותר!)

**3 דפוסים שחובה לדעת - גורמים ל-95% מהבאגים!**

### 1️⃣ Context After Await (מונע קריסות!)

**הבעיה:** Widget יכול להיעלם במהלך await → context לא תקף → 💥 CRASH!

```dart
// ❌ WRONG - עלול לקרוס!
await _save(); // משתמש יוצא כאן
Navigator.of(context).push(...); // CRASH!

// ✅ CORRECT - בטוח!
final nav = Navigator.of(context);     // שמור לפני
await _save();                          // async operation
if (!mounted) return;                  // בדוק אם עדיין חי
nav.push(...);                         // השתמש בשמור
```

**חובה לשמור לפני await:**
- `Navigator.of(context)`
- `ScaffoldMessenger.of(context)`

**אל תשמור:** `Theme.of(context)`, `MediaQuery.of(context)` (משתנים)

---

### 2️⃣ Provider Cleanup (מונע memory leaks!)

**5 דברים שחובה לנקות ב-dispose():**

```dart
@override
void dispose() {
  // 1. UserContext listener (הדליפה הנפוצה ביותר!)
  _userContext.removeListener(_onUserChanged);
  
  // 2. Controllers
  _textController.dispose();
  _animationController.dispose();
  
  // 3. Timers
  _timer?.cancel();
  
  // 4. Streams
  _subscription?.cancel();
  
  // 5. ML Kit resources
  _recognizer?.close();
  
  super.dispose(); // תמיד אחרון!
}
```

**מה קורה אם שוכחים?**
- 💀 Memory leak - אובייקטים לא משתחררים
- 🔋 בטריה נגמרת (timers ממשיכים)
- 🐌 האפליקציה מאטה
- 💥 קריסות אפשריות

---

### 3️⃣ const Optimization (שיפור ביצועים!)

**חוסר const = 5-10% rebuilds מיותרים!**

```dart
// ✅ עם literals - הוסף const
const SizedBox(height: 16)
const EdgeInsets.all(8)
const Text('טקסט קבוע')
const Icon(Icons.add)

// ❌ עם משתנים - אל תוסיף const
SizedBox(height: spacing)      // spacing משתנה!
_Card(data: item)              // item משתנה!
Text(userName)                 // userName משתנה!
```

**איפה להוסיף const:**
- SizedBox עם גובה/רוחב קבוע
- EdgeInsets עם מספרים
- Icon/Text עם string literals
- Duration עם מספרים
- PopScope/AlertDialog סטטי

---

## 🧠 ניהול Memory (קריטי!)

### תבנית שימוש ב-Memory Tools

**תמיד עקוב אחר רצף זה:**

```
1. search_nodes("query") OR read_graph()
   ↓
2. IF entity exists:
   → add_observations(entity_name, [new_observations])
   
   IF entity doesn't exist:
   → create_entities([{name, entityType, observations}])

3. NEVER call add_observations on non-existent entity
   → זה יגרום לכשל בכלי!
```

### מה לשמור

```yaml
Entities מומלצים:
  
  - Project: "MemoZap"
    Type: "Project"
    Observations:
      - החלטות ארכיטקטוניות
      - רפקטורינגים גדולים
      - שינויים שוברים

  - Feature: "Voice Notes", "Tasks", "Reminders"
    Type: "Feature"
    Observations:
      - סטטוס מימוש
      - בעיות ידועות
      - תלויות

  - Session: "Current Work Context"
    Type: "WorkSession"
    Observations:
      - קבצים ששונו
      - צעדים הבאים
      - משימות ממתינות
```

---

## 📝 פרוטוקול שינויי קבצים

### לפני כל שינוי
```
1. הצג סיכום ברור של השינוי
2. הסבר את ההיגיון מאחורי השינוי
3. שמור על דפוסים קיימים אלא אם נתבקש במפורש
```

### אחרי כל שינוי
```
1. עדכן CHANGELOG.md → [In Progress]
2. עדכן Current Work Context (כל 2 הודעות)
3. שמור checkpoint (כל 2-3 קבצים)
```

---

## 🔧 כלי MCP והשימוש בהם

### Filesystem Tools (80% מהשימוש)
- **read_text_file** - קריאת תוכן קובץ טקסט
- **write_file** - יצירה או שכתוב מלא
- **edit_file** - עריכות מבוססות שורות
- **list_directory** - רשימת תכנים
- **search_files** - חיפוש רקורסיבי

### Memory Tools
- **read_graph** - קריאת כל גרף הזיכרון
- **search_nodes** - חיפוש entities
- **create_entities** - יצירת entities חדשים
- **add_observations** - הוספת תצפיות ל-entities קיימים

### Bash Tools
- הרץ פקודות PowerShell בסביבת Windows
- תמיד אמת לפני הרצה
- שים לב לנתיבים של Windows

### GitHub Tools
- ניהול קוד מקור
- יצירת PRs
- ניהול issues

---

## 🌳 Tool Priority Decision Tree

**מתי להשתמש בכל כלי? עקוב אחרי העץ:**

```
צריך לתקן קוד?
├─ קובץ קיים? → Filesystem:edit_file
└─ קובץ חדש? → Filesystem:write_file

צריך מידע?
├─ מהתיעוד? → קרא GUIDE/CODE/DESIGN/TECH
├─ משיחה קודמת? → conversation_search
├─ מהזיכרון? → memory:search_nodes
└─ מהאינטרנט? → brave_search (אחרון!)

צריך להריץ פקודה?
├─ Flutter/Git? → bash_tool (PowerShell)
└─ צילום מסך? → Windows MCP

צריך לחשוב?
├─ בעיה פשוטה (1-2 שלבים)? → תשובה ישירה
└─ בעיה מורכבת (5+ שלבים)? → Sequential Thinking

צריך לשמור?
├─ מצב נוכחי? → memory:add_observations (Current Work Context)
├─ החלטה ארכיטקטונית? → memory:create_entities
└─ היסטוריה? → CHANGELOG.md
```

**📖 פרטים מלאים:** ראה GUIDE.md סעיף MCP Tools

---

## 🎨 תקני UI/UX

### תמיכה בעברית (RTL)
```dart
// ✅ תמיד לטקסט עברי
Directionality(
  textDirection: TextDirection.rtl,
  child: Text('טקסט בעברית'),
)

// ✅ זיהוי אוטומטי ב-AppLocalizations
Text(AppLocalizations.of(context)!.taskTitle)
```

### Sticky Notes Design System
- השתמש ב-`ColorScheme` מה-theme
- צבעי kSticky* קבועים (גם ב-Dark Mode)
- NotebookBackground תמיד עם Stack
- StickyButton (לא ElevatedButton!)

**📖 פרטים מלאים:** ראה DESIGN.md

---

## ⚠️ טיפול בשגיאות

### Enhanced Error Tracking Protocol

**כשכלי נכשל - תהליך מלא:**

```yaml
1. CAPTURE (תיעוד מיידי):
   - הודעת שגיאה מדויקת
   - שם הכלי + פרמטרים
   - הקשר - מה ניסיתי לעשות?

2. SEARCH (חיפוש בזיכרון):
   - memory:search_nodes("error type")
   - האם הדפוס הזה קיים?

3. ANALYZE (ניתוח שורש):
   - למה זה נכשל?
   - איזו הנחה הייתה שגויה?

4. DOCUMENT (תיעוד):
   - אם חדש → הוסף Pattern #N ל-Tool Errors & Solutions
   - אם קיים → עדכן תדירות + תאריך אחרון

5. FIX (תיקון):
   - החל את הפתרון המתועד
   - אמת שעובד

6. LEARN (למידה):
   - תדירות 3+ = Red Alert (צריך מניעה אוטומטית!)
   - עדכן LESSONS_LEARNED.md
```

### פרוטוקול כשל כלי
```
כש-ANY tool נכשל:

1. PAUSE - אל תנסה שוב באופן עיוור
2. READ - קרא מחדש את המצב האחרון הידוע
3. ANALYZE - זהה גורם שורש
4. FIX - תקן את הבעיה
5. RETRY - רק פעם אחת אחרי אימות
6. LOG - אם עדיין נכשל → LESSONS_LEARNED.md + Memory
```

### דפוסי כשל נפוצים
```yaml
# Pattern 1: Memory Tool
Error: "Entity not found"
Fix: קרא search_nodes תחילה, אז add_observations

# Pattern 2: File Edit
Error: "old_str not found"
Fix: קרא מחדש את הקובץ, התאם רווחים/פורמט מדויק

# Pattern 3: Path Resolution
Error: "File not found"
Fix: השתמש בנתיב מוחלט Windows (C:\...)

# Pattern 4: RTL Rendering
Error: טקסט מופיע הפוך
Fix: עטוף ב-Directionality(textDirection: TextDirection.rtl)

# Pattern 5: household_id Missing (SECURITY BREACH!)
Error: Query returns data from other households
Fix: תמיד הוסף .where('household_id', isEqualTo: householdId)
Impact: ⚠️ CRITICAL - משתמשים רואים נתונים של אחרים!

# Pattern 6: Logging Overflow
Error: יותר מ-15 debugPrint בקובץ
Fix: השאר רק lifecycle + errors + critical actions
Tool: השתמש ב-logger package עם levels
```

**📖 רשימה מלאה:** ראה LESSONS_LEARNED.md

---

## ✅ Code Review Checklist

**לפני commit - וודא:**

### 🎯 Critical (חובה!):
- [ ] כל query ב-Firestore יש household_id filter
- [ ] כל Provider עם UserContext יש removeListener ב-dispose
- [ ] כל context אחרי await שמור מראש + בדיקת mounted
- [ ] מקסימום 15 debugPrint בקובץ
- [ ] בדיקות 4 states: Loading/Error/Empty/Content

### ⚡ Performance:
- [ ] const על כל widget סטטי (SizedBox, EdgeInsets, Icon, Text)
- [ ] Controllers disposed (Text, Animation, Scroll)
- [ ] Timers cancelled
- [ ] Streams cancelled

### 🎨 UI/UX:
- [ ] NotebookBackground עם Stack
- [ ] כל טקסט עברי ב-Directionality(RTL)
- [ ] StickyButton (לא ElevatedButton)
- [ ] Touch targets ≥ 44x44dp

### 📝 Documentation:
- [ ] CHANGELOG.md עודכן
- [ ] Current Work Context עודכן
- [ ] Checkpoint נשמר (כל 2-3 קבצים)

---

## 📋 סיכום מהיר - Quick Reference

### תחילת שיחה:
```
1. קרא GUIDE.md
2. בדוק CHANGELOG.md [In Progress]
3. טען memory: read_graph()
4. מוכן לעבודה!
```

### כתיבת קוד:
```
GUIDE → CODE → LESSONS_LEARNED → קודד → checkpoint
```

### עיצוב UI:
```
GUIDE → DESIGN → CODE (widgets) → עצב → checkpoint
```

### עבודה עם Firebase:
```
GUIDE → TECH → CODE (repository) → מימוש → checkpoint
```

---

## 🔗 קישורים מהירים

| צריך | קרא |
|------|-----|
| להתחיל | GUIDE.md |
| לקודד | CODE.md |
| לעצב | DESIGN.md |
| Firebase | TECH.md |
| לא לטעות | LESSONS_LEARNED.md |
| סטטוס | CHANGELOG.md |

---

## 💡 טיפים לשימוש יעיל

### למשתמש האנושי
1. **"תמשיך"** - המשך עבודה מהסשן הקודם
2. **"שמור checkpoint"** - שמור מצב לפני הפסקה
3. בדוק **CHANGELOG.md** `[In Progress]` למצב נוכחי
4. אם משהו נכשל - **LESSONS_LEARNED.md** יש פתרונות

### ל-AI Agent (Claude)
1. **תמיד** קרא GUIDE.md בתחילת שיחה
2. **תמיד** חפש ב-memory לפני יצירת entities
3. **תמיד** עדכן CHANGELOG.md אחרי שינויים
4. **לעולם לא** תערוך קבצים ללא קריאה מקדימה
5. **זכור** - נתיבים מוחלטים בלבד (`C:\projects\salsheli\...`)

---

**📌 Maintainer:** MemoZap AI System  
**📅 Last Updated:** 26/10/2025  
**🔄 Version:** 4.0  
**📝 Notes:** Added Critical Patterns, Anti-Patterns, Enhanced Protocols

---

## 🎯 מבנה התיעוד v3.0

```
docs/
  ├── GUIDE.md          (400) - Project + Files + Memory + MCP
  ├── CODE.md           (500) - Architecture + Patterns + Testing
  ├── DESIGN.md         (300) - Sticky Notes + RTL + Components
  ├── TECH.md           (400) - Firebase + Security + Models
  ├── LESSONS_LEARNED.md     - Common mistakes & solutions
  └── CHANGELOG.md           - Project history + [In Progress]
```

**סה"כ:** 6 קבצים, ~1,600 שורות תיעוד ממוקד

---

---

## 🆕 What's New in v4.0? (26/10/2025)

### 🔥 Major Additions:

**1. MCP Anti-Patterns** 🚫
- 6 דברים שאסור לעשות (artifacts, sequential thinking, web search)
- למה הם גורמים לבעיות
- מה לעשות במקום

**2. Communication Protocol** 💬
- האופן המועדף של המשתמש לקבל תשובות
- פורמט אידיאלי: קצר, עברית, A/B/C
- מה המשתמש לא אוהב

**3. Critical Patterns** 🔥
- **Context After Await** - מונע 90% מהקריסות!
- **Provider Cleanup** - 5 דברים שחובה לנקות
- **const Optimization** - 5-10% שיפור ביצועים

**4. Tool Priority Decision Tree** 🌳
- עץ החלטות ויזואלי
- מתי להשתמש בכל כלי
- סדר עדיפויות ברור

**5. Enhanced Error Tracking** 📝
- תהליך 6 שלבים לטיפול בשגיאות
- תיעוד אוטומטי של דפוסים
- למידה מתמשכת

**6. Code Review Checklist** ✅
- 15 בדיקות לפני commit
- Critical/Performance/UI/Documentation
- פורמט checklist מעשי

### 📊 Statistics:
- **Before:** 3.0 - 850 lines
- **After:** 4.0 - ~1,200 lines (+40%)
- **New Content:** 6 major sections
- **Focus:** Practical patterns, not theory

### 🎯 Why This Update?

על סמך **80+ entities** בזיכרון ו-**26 sessions** עבודה משותפת, זיהיתי:
- 10 דפוסים קריטיים שחוזרים
- 6 anti-patterns שגורמים לבעיות
- 3 patterns שמונעים 95% מהבאגים

**Result:** תיעוד **יותר מעשי**, **פחות תיאורטי**, **יותר אוטומטי**.

---

**סוף מסמך v4.0** ✨

*מעודכן על סמך למידה מתמשכת מ-26 sessions ו-80+ entities בזיכרון.*
