# 🔧 MemoZap MCP Tools Guide
> **מדריך כלי MCP לשימוש AI - מעודכן אוקטובר 2025**

**📌 מסמך זה:** למערכות AI בלבד - פרוטוקולים וכללי שימוש בכלים  
**🎯 מטרה:** מקסום יעילות, מניעת כשלים, המשכיות מושלמת

---

## 🎛️ מצב הכלים הפעילים

| כלי | סטטוס | שימוש עיקרי | קריטיות | מתי להשתמש |
|-----|-------|-------------|----------|------------|
| **Filesystem** | 🟢 Active | קריאה/כתיבה/עריכת קבצים | 🔴 קריטי | תמיד לפני שינויים |
| **Memory** | 🟢 Active | זיכרון בין-סשן | 🟡 חשוב | checkpoints, context |
| **Bash** | 🟢 Active | פקודות PowerShell | 🟠 לפי צורך | אוטומציה, בדיקות |
| **GitHub** | 🟢 Active | גרסאות, commits | 🟡 חשוב | sync, PRs |
| **Sequential Thinking** | 🟢 Active | חשיבה מורכבת | 🟢 אופציונלי | תכנון, audit |
| **Brave Search** | 🟢 Active | חיפוש תיעוד | 🟢 אופציונלי | מידע חיצוני |

---

## 📁 Filesystem Tools - כלי קבצים

### 🎯 עקרון יסוד
**קרא לפני כל שינוי. תמיד. ללא יוצא מן הכלל.**

### 🔑 כללים קריטיים

```yaml
✅ חובה:
  - נתיבים מוחלטים של Windows: C:\projects\salsheli\...
  - קריאה לפני עריכה: read_text_file → edit_file
  - שימוש ב-edit_file לשינויים כירורגיים
  - שמירת פורמט מדויק (emojis, RTL, רווחים)

❌ אסור:
  - נתיבים יחסיים (../lib או ./src)
  - write_file על קבצים קיימים (רק לחדשים!)
  - ניחושים אם אין התאמה מדויקת
  - grep/find בפקודות bash (השתמש ב-search_files)
```

### 🛠️ ארגז הכלים

#### 1️⃣ `read_text_file` - קריאת קובץ
**מתי:** תמיד לפני כל עריכה, לסקירת קוד

```python
# דוגמה
read_text_file(
    path="C:\\projects\\salsheli\\lib\\models\\task.dart"
)

# עם הגבלת שורות
read_text_file(
    path="C:\\projects\\salsheli\\lib\\main.dart",
    head=50  # רק 50 שורות ראשונות
)
```

#### 2️⃣ `edit_file` - עריכה כירורגית
**מתי:** שינויים מדויקים בקבצים קיימים

```python
# ⚠️ חובה - התאמה מדויקת של old_str
edit_file(
    path="C:\\projects\\salsheli\\lib\\models\\task.dart",
    edits=[{
        "oldText": "  final String title;\n  final String? description;",
        "newText": "  final String title;\n  final String? description;\n  final DateTime? reminder;"
    }]
)
```

**🚨 שגיאה נפוצה:** "Could not find exact match"  
**✅ פתרון:** 
1. קרא את הקובץ מחדש
2. העתק את הטקסט המדויק (כולל רווחים!)
3. נסה שוב עם ההתאמה המדויקת

#### 3️⃣ `write_file` - יצירת קובץ חדש
**מתי:** רק לקבצים חדשים, **אף פעם** לא לעדכונים

```python
write_file(
    path="C:\\projects\\salsheli\\lib\\utils\\reminder_helper.dart",
    content="""import 'package:flutter/material.dart';

class ReminderHelper {
  static Future<void> scheduleReminder(DateTime time) async {
    // Implementation
  }
}
"""
)
```

#### 4️⃣ `search_files` - חיפוש קבצים
**מתי:** מציאת קבצים לפי תבנית (במקום grep)

```python
search_files(
    path="C:\\projects\\salsheli\\lib",
    pattern="task",  # מחפש כל קובץ שמכיל "task"
    excludePatterns=["test", "*.g.dart"]  # לא לחפש בקבצים אלו
)
```

#### 5️⃣ `list_directory` - רשימת תוכן תיקייה
```python
list_directory(
    path="C:\\projects\\salsheli\\lib\\screens"
)
```

#### 6️⃣ `directory_tree` - מבנה עץ רקורסיבי
```python
directory_tree(
    path="C:\\projects\\salsheli\\lib"
)
```

### 📋 פרוטוקול עריכת קבצים (חובה!)

```
1. read_text_file → קרא את הקובץ
2. זהה את הבלוק המדויק לשינוי
3. העתק טקסט בדיוק (כולל רווחים/emojis)
4. edit_file עם ההתאמה המדויקת
5. אם נכשל → חזור לשלב 1
```

---

## 🧠 Memory Tools - כלי זיכרון

### 🎯 מטרה
שמירת הקשר בין סשנים - **לא** לקוד גולמי!

### 🚨 פרוטוקול קריטי (חובה לעקוב!)

```
תמיד תעקוב אחר רצף זה:

1. search_nodes("query") או read_graph()
   ↓
2. IF entity exists:
      → add_observations(entity_name, [new_observations])
   
   IF entity doesn't exist:
      → create_entities([{name, entityType, observations}])

3. ⛔ לעולם לא להפעיל add_observations על entity שלא קיים!
```

### 🛠️ ארגז הכלים

#### 1️⃣ `read_graph` - קריאת כל הזיכרון
**מתי:** בתחילת סשן, כשצריך סקירה כללית

```python
read_graph()
# מחזיר את כל ה-entities והקשרים
```

#### 2️⃣ `search_nodes` - חיפוש entities
**מתי:** לפני כל שינוי, כדי לבדוק קיום

```python
search_nodes(query="last checkpoint")
search_nodes(query="MemoZap project")
search_nodes(query="voice notes feature")
```

#### 3️⃣ `create_entities` - יצירת entities חדשים
**מתי:** רק אחרי אימות שלא קיימים!

```python
create_entities(entities=[
    {
        "name": "Checkpoint_2025-10-25",
        "entityType": "WorkSession",
        "observations": [
            "עבדתי על פיצ'ר תזכורות",
            "שינויים: task.dart, tasks_provider.dart, app_he.arb",
            "הבא: ליישם UI לבחירת תזכורת",
            "סטטוס: 60% הושלם"
        ]
    }
])
```

#### 4️⃣ `add_observations` - הוספת תצפיות ל-entity קיים
**מתי:** לעדכון סטטוס, הוספת מידע

```python
add_observations(observations=[
    {
        "entityName": "MemoZap",
        "contents": [
            "הוחלט: להשתמש ב-flutter_local_notifications לתזכורות",
            "רפקטורינג: הועבר TasksProvider ל-Riverpod 2.0"
        ]
    }
])
```

#### 5️⃣ `delete_entities` - מחיקת entities
**מתי:** ניקוי checkpoints ישנים

```python
delete_entities(entityNames=["Checkpoint_2025-10-20"])
```

### 📦 מה לשמור ב-Memory?

```yaml
✅ שמור:
  - החלטות ארכיטקטוניות
  - סטטוס פיצ'רים
  - checkpoints עבודה
  - לקחים התנהגותיים
  - בעיות ידועות
  - צעדים הבאים

❌ אל תשמור:
  - קוד גולמי (מעולם!)
  - תוכן קבצים שלם
  - מידע שמשתנה מהר
```

### 🔥 כשל נפוץ והפתרון

```
❌ שגיאה: "Tool execution failed"
🔍 סיבה: ניסית add_observations על entity שלא קיים
✅ פתרון: 
   1. search_nodes("entity_name")
   2. אם לא קיים → create_entities
   3. אם קיים → add_observations
```

---

## 💻 Bash Tool - פקודות מסוף

### 🎯 סביבה
PowerShell בתוך VS Code על Windows 11

### 🔑 כללים קריטיים

```yaml
⚠️ חשוב:
  - המשתמש מריץ את כל הפקודות ידנית
  - אתה מציע ומאמת, לא מריץ אוטומטית
  - העדף Filesystem tools לפני Bash

❌ אסור:
  - grep, find (לא עובדים טוב ב-Windows)
  - פקודות ארוכות שעלולות להקפיא
  - פקודות מסוכנות ללא אישור

✅ מותר:
  - flutter run
  - flutter pub get
  - dart format
  - git status
```

### 🛠️ דוגמאות שימוש

```bash
# הרצת אמולטור
flutter run

# עדכון dependencies
flutter pub get

# פורמט קוד
dart format lib/

# בדיקת סטטוס git
git status
```

### ⚠️ טיפול בבעיות

| בעיה | סיבה | פתרון |
|------|------|-------|
| Timeout | פרוצס ארוך | פצל לפקודות קטנות יותר |
| ENOENT | נתיב שגוי | השתמש בנתיב Windows מלא |
| Permission Denied | הרשאות | הרץ כמנהל או שנה הרשאות |

---

## 🐙 GitHub Tools

### 🎯 שימוש
ניהול גרסאות, commits, sync

### 🔑 כללים

```yaml
✅ תמיד:
  - אמת שינויים לפני commit
  - עדכן CHANGELOG.md עם כל commit
  - כתוב commit messages תיאוריים
  - sync לפני pull

❌ אף פעם:
  - commit ללא אימות
  - force push ללא אישור
  - עריכה ישירה של main branch
```

### 🛠️ פעולות נפוצות

```python
# קריאת קובץ מ-GitHub
get_file_contents(
    owner="username",
    repo="salsheli",
    path="lib/main.dart",
    branch="main"
)

# יצירת/עדכון קובץ
create_or_update_file(
    owner="username",
    repo="salsheli",
    branch="main",
    path="lib/models/task.dart",
    message="Add reminder field to Task model",
    content="...",
    sha="abc123"  # אם מעדכן קובץ קיים
)

# push מספר קבצים בcommit אחד
push_files(
    owner="username",
    repo="salsheli",
    branch="main",
    message="Implement reminder feature",
    files=[
        {"path": "lib/models/task.dart", "content": "..."},
        {"path": "lib/l10n/app_he.arb", "content": "..."}
    ]
)
```

---

## 🧩 Sequential Thinking Tool

### 🎯 מתי להשתמש
- תכנון מורכב
- audit קוד גדול
- רפקטורינג
- החלטות עם אי-ודאות

### 🛠️ דוגמה

```python
sequential_thinking(
    thought="מתכנן את ארכיטקטורת מערכת התזכורות",
    thoughtNumber=1,
    totalThoughts=5,
    nextThoughtNeeded=True
)
```

---

## 🔍 Brave Search Tool

### 🎯 שימוש
חיפוש תיעוד חיצוני (Flutter, Firebase, וכו')

### 📋 פרוטוקול

```
1. קודם חפש בתיעוד הפרויקט
2. אם לא נמצא → Brave Search
3. אמת את התוצאות
4. לא לסמוך על מידע מיושן
```

---

## 💾 פרוטוקול Checkpoints

### ⏰ מתי לשמור?

- ✅ כל 3-5 שינויי קבצים
- ✅ אחרי השלמת שלב
- ✅ לפני הגעה למגבלת tokens
- ✅ כשמשתמש אומר "שמור checkpoint"

### 📦 מה לשמור?

```yaml
בMemory:
  - Entity: "Checkpoint_<date>"
  - Type: "WorkSession"
  - Observations:
      - "קבצים ששונו: [רשימה]"
      - "סטטוס: X% הושלם"
      - "הבא: [משימה מדויקת]"
      - "בעיות: [אם יש]"

בCHANGELOG.md:
  - סעיף [In Progress]
  - רשימת שינויים
  - next steps
```

### 📝 פורמט Checkpoint

```markdown
✅ Checkpoint #5 saved (25/10/2025 14:30)

שינויים:
- ✏️ lib/models/task.dart - הוסף שדה reminder
- ✏️ lib/providers/tasks_provider.dart - logic לשמירה
- 🌐 lib/l10n/app_he.arb - מחרוזות עברית

סטטוס: 60% 🟡

הבא:
- [ ] UI לבחירת תזכורת
- [ ] אינטגרציה עם flutter_local_notifications
- [ ] בדיקה באמולטור
```

---

## 🔄 פרוטוקול המשכיות

### 🎯 כשמשתמש אומר "תמשיך"

```
1. read_graph() → טען את כל הזיכרון
2. search_nodes("last checkpoint") → מצא checkpoint אחרון
3. קרא CHANGELOG.md → סעיף [In Progress]
4. recent_chats(n=1) → טען הודעות אחרונות
5. המשך מהנקודה המדויקת
```

### 📋 רצף פעולות

```yaml
Phase 1: טעינת הקשר
  - read_graph()
  - search_nodes("Checkpoint")
  - קרא CHANGELOG.md

Phase 2: הבנת המצב
  - מה הושלם?
  - מה הבא?
  - יש חסימות?

Phase 3: המשך עבודה
  - המשך מהצעד הבא
  - ללא חזרה על עבודה שהושלמה
```

---

## ⚠️ טיפול בכשלים

### 🎯 פרוטוקול כשל כלי

```
כש-ANY tool נכשל:

1. ⏸️ PAUSE - עצור, אל תנסה שוב עיוור
2. 📖 READ - קרא את המצב האחרון
3. 🔍 ANALYZE - מצא את הבעיה:
   - נתיב שגוי?
   - Entity לא קיים?
   - תחביר פקודה?
   - timeout?
4. 🔧 FIX - תקן את הבעיה
5. 🔁 RETRY - נסה פעם אחת נוספת
6. 📝 LOG - אם עדיין נכשל → LESSONS_LEARNED.md
```

### 🔥 כשלים נפוצים

| כלי | שגיאה | סיבה | פתרון |
|-----|-------|------|--------|
| **edit_file** | "no match" | emoji/רווח לא מדויק | קרא מחדש, העתק בדיוק |
| **memory** | "failed" | Entity לא קיים | search_nodes קודם |
| **filesystem** | "ENOENT" | נתיב שגוי | השתמש בנתיב מוחלט |
| **bash** | timeout | פרוצס ארוך | פצל לפקודות קצרות |

---

## 📊 ניהול Token Budget

### 🎯 מגבלות

**סך הכל:** 190,000 tokens

### ⚠️ התראות

```yaml
70% (133K): 
  הודעה: "⚠️ Token Alert: 70% - נותרו 30%"
  פעולה: התחל לתכנן סיום

85% (161.5K):
  הודעה: "🚨 Token Critical: 85% - לסיים עכשיו"
  פעולה: 
    - מצב תמציתי במיוחד
    - שמור הכל ל-Memory
    - סכם וסיים

90%+:
  הודעה: "❌ Token Emergency"
  פעולה: סיים מיד עם checkpoint מלא
```

### 💾 פרוטוקול חירום

```
1. create_entities → Checkpoint_Emergency
2. עדכן CHANGELOG.md → [In Progress]
3. רשום "Next Steps" מפורט
4. סכם בהודעה אחרונה
```

---

## 🎯 Best Practices - תמצית

### ✅ תמיד עשה

```yaml
Filesystem:
  - קרא לפני עריכה
  - נתיבים מוחלטים בלבד
  - שמור על פורמט מדויק

Memory:
  - search_nodes לפני add_observations
  - checkpoints כל 3-5 שינויים
  - רק context, לא קוד

Bash:
  - אמת לפני הרצה
  - העדף Filesystem tools
  - פקודות קצרות

All:
  - עדכן CHANGELOG.md
  - תיעד ב-LESSONS_LEARNED.md
  - שמור המשכיות
```

### ❌ אף פעם אל תעשה

```yaml
- נתיבים יחסיים
- עריכה ללא קריאה
- add_observations ללא בדיקה
- ניסיונות חוזרים עיוורים
- התעלמות משגיאות
- דילוג על checkpoints
```

---

## 🔗 קישורים צולבים

| נושא | מסמך |
|------|------|
| נקודת כניסה מרכזית | `README.md` |
| הקשר ועקרונות | `MEMOZAP_CORE_GUIDE.md` |
| דפוסי קוד | `MEMOZAP_DEVELOPER_GUIDE.md` |
| תיעוד שגיאות | `LESSONS_LEARNED.md` |
| דרישות UI | `MEMOZAP_UI_REQUIREMENTS.md` |
| מערכת עיצוב | `MEMOZAP_DESIGN_GUIDE.md` |
| משימות ושיתוף | `MEMOZAP_TASKS_AND_SHARING.md` |
| אבטחה | `MEMOZAP_SECURITY_AND_RULES.md` |
| היסטוריה | `CHANGELOG.md` |
| תכנון | `IMPLEMENTATION_ROADMAP.md` |

---

## 📚 דוגמאות מעשיות

### 🎯 תרחיש 1: עריכת קובץ

```
1. read_text_file("C:\\projects\\salsheli\\lib\\models\\task.dart")
2. מצא בלוק מדויק:
   "  final String title;\n  final String? description;"
3. edit_file עם oldText מדויק
4. אם נכשל → חזור לשלב 1
```

### 🎯 תרחיש 2: Checkpoint

```
1. search_nodes("Checkpoint") → בדוק מה קיים
2. create_entities([{
     name: "Checkpoint_2025-10-25_15:00",
     type: "WorkSession",
     observations: [...]
   }])
3. עדכן CHANGELOG.md → סעיף [In Progress]
```

### 🎯 תרחיש 3: המשך עבודה

```
1. read_graph() → טען זיכרון מלא
2. search_nodes("last checkpoint")
3. קרא CHANGELOG.md
4. recent_chats(n=1)
5. המשך מהצעד הבא בדיוק
```

---

**📌 Version:** 3.0  
**📅 Updated:** 25/10/2025  
**🔧 Maintained by:** MemoZap AI System  
**📍 Location:** `C:\projects\salsheli\docs\ai\MEMOZAP_MCP_GUIDE.md`

---

**💡 זכור:**
- קרא לפני כל שינוי
- אמת לפני כל פעולה
- שמור checkpoints לעיתים קרובות
- תיעד כל שגיאה חוזרת
- שמור על המשכיות מושלמת

**✨ הצלחה!**
