# 🎯 MemoZap AI Instructions
> **תוכנית הוראות עבודה מעודכנת - אוקטובר 2025 v3.0**

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

### פרוטוקול כשל כלי
```
כש-ANY tool נכשל:

1. PAUSE - אל תנסה שוב באופן עיוור
2. READ - קרא מחדש את המצב האחרון הידוע
3. ANALYZE - זהה גורם שורש
4. FIX - תקן את הבעיה
5. RETRY - רק פעם אחת אחרי אימות
6. LOG - אם עדיין נכשל → LESSONS_LEARNED.md
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
```

**📖 רשימה מלאה:** ראה LESSONS_LEARNED.md

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
**📅 Last Updated:** 25/10/2025  
**🔄 Version:** 3.0  
**📝 Notes:** מבנה תיעוד חדש - 6 קבצים ממוקדים

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

**סוף מסמך** ✨

*זכור: התיעוד מתפתח. עדכן כשאתה מגלה דפוסים חדשים.*
