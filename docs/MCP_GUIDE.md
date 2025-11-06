# 🤖 MCP Guide - הנחיות עבודה עם Claude Desktop

> **גרסה:** 1.0 | **תאריך:** 04/11/2025  
> **מטרה:** הנחיות מדויקות מבוססות בדיקה אמיתית של כלי MCP  
> **מערכת:** Windows 11 + Desktop Commander v0.2.20

---

## 📋 תוכן עניינים

1. [סקירת כלים](#סקירת-כלים)
2. [Desktop Commander - העיקרי](#desktop-commander)
3. [כלים נוספים](#כלים-נוספים)
4. [דוגמאות שימוש](#דוגמאות-שימוש)
5. [מלכודות נפוצות](#מלכודות-נפוצות)

---

## 🎯 סקירת כלים

### כלים פעילים במערכת:

| קטגוריה | כלי | סטטוס | שימוש |
|----------|-----|-------|-------|
| **קבצים** | Desktop Commander | ✅ פעיל | קריאה/כתיבה/חיפוש |
| **קבצים** | create_file | ⚠️ שבור | **אל תשתמש!** |
| **Terminal** | bash_tool | ⚠️ חלקי | רק Linux paths |
| **Terminal** | Desktop Commander:start_process | ✅ פעיל | PowerShell מלא |
| **חיפוש** | Desktop Commander:start_search | ✅ פעיל | מהיר ועוצמתי |
| **אינטרנט** | web_search | ✅ פעיל | Brave Search |
| **אינטרנט** | web_fetch | ✅ פעיל | טעינת דפים |
| **זיכרון** | memory:* | ✅ פעיל | גרף ידע |
| **היסטוריה** | conversation_search | ✅ פעיל | שיחות קודמות |

---

## 🔧 Desktop Commander

**הכלי המרכזי לעבודה עם קבצים ופקודות.**

### הגדרות מערכת (מאומתות):

```yaml
מערכת_הפעלה: Windows
shell_ברירת_מחדל: powershell.exe
working_directory: C:\Users\Lunix\AppData\Local\AnthropicClaude\app-1.0.211
הגבלות_קריאה: 1000 שורות לקריאה
הגבלות_כתיבה: 50 שורות לכתיבה (עם אזהרה)
תיקיות_מותרות: [] (ריקה = גישה מלאה)
```

---

## 📁 פעולות קבצים

### 1️⃣ קריאת קובץ: `read_file`

**שימוש בסיסי:**
```dart
read_file(
  path: "C:\\projects\\salsheli\\lib\\main.dart"
)
```

**קריאה חלקית:**
```dart
// קריאת 30 שורות ראשונות
read_file(
  path: "...",
  length: 30
)

// קריאת 20 שורות אחרונות
read_file(
  path: "...",
  offset: -20
)

// קריאה מאמצע הקובץ
read_file(
  path: "...",
  offset: 100,
  length: 50
)
```

**הגבלות:**
- מקסימום 1000 שורות בקריאה אחת
- אם הקובץ ארוך יותר - קרא בחלקים
- תמונות מוחזרות כ-viewable images

---

### 2️⃣ כתיבת קובץ: `write_file`

**יצירת קובץ חדש או החלפה:**
```dart
write_file(
  path: "C:\\projects\\salsheli\\test.txt",
  content: "תוכן הקובץ",
  mode: "rewrite"  // ברירת מחדל
)
```

**הוספה לקובץ קיים:**
```dart
write_file(
  path: "...",
  content: "שורות נוספות",
  mode: "append"
)
```

**⚠️ הגבלת 50 שורות:**
- מעל 50 שורות: תקבל אזהרת performance
- הקובץ ייווצר בכל זאת!
- פתרון: חלק לחלקים (rewrite + append + append...)

**דוגמה - קובץ ארוך:**
```dart
// שלב 1: 50 שורות ראשונות
write_file(path: "...", content: lines_1_50, mode: "rewrite")

// שלב 2: 50 שורות נוספות
write_file(path: "...", content: lines_51_100, mode: "append")

// שלב 3: שאר השורות
write_file(path: "...", content: lines_101_end, mode: "append")
```

---

### 3️⃣ עריכה כירורגית: `edit_block`

**מתי להשתמש:**
- תיקון bug קטן
- שינוי פונקציה אחת
- החלפת טקסט ספציפי

**שימוש:**
```dart
edit_block(
  file_path: "C:\\projects\\salsheli\\lib\\main.dart",
  old_string: "void main() {\n  runApp(MyApp());\n}",
  new_string: "void main() {\n  WidgetsFlutterBinding.ensureInitialized();\n  runApp(MyApp());\n}",
  expected_replacements: 1  // ברירת מחדל
)
```

**⚠️ חשוב:**
- `old_string` חייב להיות **זהה בדיוק** (כולל רווחים!)
- אם לא מוצא התאמה → תקבל diff של מה שלא תואם
- `expected_replacements`: אם > 1 יחליף כמה מופעים

---

### 4️⃣ סריקת תיקייה: `list_directory`

**שימוש:**
```dart
list_directory(
  path: "C:\\projects\\salsheli\\lib",
  depth: 2  // רמות עומק
)
```

**פלט:**
```
[DIR] providers
[FILE] main.dart
[DIR] models
[FILE] models\shopping_list.dart
[WARNING] node_modules: 2940 items hidden (100/3040)
```

**הגבלות:**
- תיקייה ראשית: כל הקבצים
- תיקיות מקוננות: **מקסימום 100 items**
- אם יותר → תקבל warning

---

## 🔍 חיפוש קבצים

### כלי החיפוש המתקדם: `start_search`

**2 סוגי חיפוש:**

#### 📄 חיפוש לפי שם קובץ:
```dart
start_search(
  path: "C:\\projects\\salsheli\\lib",
  pattern: "shopping_list",
  searchType: "files"
)
```

#### 📝 חיפוש בתוך קבצים:
```dart
start_search(
  path: "C:\\projects\\salsheli\\lib",
  pattern: "ShoppingList",
  searchType: "content"
)
```

**אפשרויות מתקדמות:**
```dart
start_search(
  path: "...",
  pattern: "class.*Provider",
  searchType: "content",
  filePattern: "*.dart",  // רק קבצי Dart
  ignoreCase: true,       // התעלם מאותיות
  literalSearch: false,   // false = regex, true = מילולי
  maxResults: 100
)
```

**קבלת תוצאות:**
```dart
// החיפוש מחזיר session_id
// קבל תוצאות עם:
get_more_search_results(
  sessionId: "search_1_...",
  offset: 0,
  length: 10
)
```

---

## 💻 הרצת פקודות: PowerShell

### `start_process` - הכלי העיקרי

**שימוש בסיסי:**
```dart
start_process(
  command: "Get-ChildItem C:\\projects\\salsheli",
  timeout_ms: 5000
)
```

**⚠️ חשוב - Working Directory:**
- התהליך מתחיל ב: `C:\Users\...\AppData\Local\AnthropicClaude\...`
- **לא** בפרויקט שלך!
- פתרון: השתמש ב-full paths או cd בתוך הפקודה

**דוגמאות נכונות:**
```powershell
# אופציה 1: full path
Get-ChildItem C:\projects\salsheli\lib

# אופציה 2: cd בתוך הפקודה
cd C:\projects\salsheli; Get-ChildItem lib

# אופציה 3: פקודה מרובת שורות
cd C:\projects\salsheli
flutter pub get
flutter test
```

---

### `interact_with_process` - תהליכים אינטראקטיביים

**מתי להשתמש:**
- Python REPL
- Node.js
- פקודות שצריכות input

**דוגמה:**
```dart
// הפעל Python
start_process(command: "python -i", timeout_ms: 3000)
// PID: 12345

// שלח פקודות
interact_with_process(
  pid: 12345,
  input: "print('Hello')",
  wait_for_prompt: true
)

// סיים
force_terminate(pid: 12345)
```

---

## 🌐 כלי Web

### `web_search` - חיפוש ב-Brave

```dart
web_search(
  query: "Flutter Provider pattern best practices"
)
```

### `web_fetch` - טעינת דף מלא

```dart
web_fetch(
  url: "https://docs.flutter.dev/..."
)
```

---

## 🧠 כלי Memory

### יצירת entities:
```dart
memory:create_entities(
  entities: [
    {
      name: "Current Task",
      entityType: "task",
      observations: ["Working on Phase 3B", "Status: 85%"]
    }
  ]
)
```

### קריאת גרף:
```dart
memory:read_graph()
```

---

## 💣 מלכודות נפוצות

### 1️⃣ **create_file - FALSE POSITIVE מסוכן!**

```yaml
סטטוס: ⚠️ אל תשתמש!
בעיה: מחזיר "success" אבל לא יוצר קובץ
תוצאה: אתה חושב שהצלחת אבל הקובץ לא קיים
פתרון: השתמש ב-write_file בלבד
```

**דוגמה:**
```dart
// ❌ לא תעבוד!
create_file(path: "...", content: "...")
// תקבל: "File created successfully"
// אבל: read_file יחזיר "ENOENT: no such file"

// ✅ נכון:
write_file(path: "...", content: "...", mode: "rewrite")
```

---

### 2️⃣ **bash_tool עם Windows paths**

```yaml
סטטוס: ⚠️ לא עובד
בעיה: bash_tool = Linux shell (/bin/sh)
שגיאה: "can't cd to C:projectssalsheli"
פתרון: השתמש ב-start_process + PowerShell
```

**דוגמה:**
```dart
// ❌ לא יעבוד:
bash_tool(command: "cd C:\\projects\\salsheli && ls")
// שגיאה: /bin/sh: can't cd to C:projects...

// ✅ נכון:
start_process(command: "Get-ChildItem C:\\projects\\salsheli")
```

---

### 3️⃣ **Working Directory - הפתעה!**

```yaml
בעיה: start_process מתחיל ב-AppData של Claude
לא ב: C:\projects\salsheli
פתרון: תמיד השתמש ב-full paths
```

---

### 4️⃣ **list_directory - הגבלת 100**

```yaml
בעיה: תיקיות מקוננות מוגבלות ל-100 items
דוגמה: node_modules עם 3000 קבצים → רק 100 יוצגו
פתרון: שימו לב ל-WARNING בפלט
```

---

## 📊 כלים מתקדמים (בונוס)

### `get_usage_stats` - סטטיסטיקות
```dart
get_usage_stats()
// מחזיר: כמות שימוש, success rate, כלים פופולריים
```

### `get_recent_tool_calls` - היסטוריה
```dart
get_recent_tool_calls(maxResults: 50)
// מחזיר: רשימת קריאות אחרונות
```

### `list_searches` - חיפושים פעילים
```dart
list_searches()
// מראה איזה חיפושים רצים כרגע
```

### `stop_search` - עצירת חיפוש
```dart
stop_search(sessionId: "search_1_...")
```

---

## ✅ Checklist לכל פעולה

### לפני כתיבת קובץ:
- [ ] השתמשתי ב-`write_file` (לא create_file)
- [ ] בדקתי אם הקובץ > 50 שורות (צריך לחלק)
- [ ] השתמשתי ב-full path (לא relative)

### לפני חיפוש:
- [ ] בחרתי סוג נכון (files/content)
- [ ] הגדרתי pattern ברור
- [ ] הוספתי filePattern אם רלוונטי

### לפני הרצת פקודה:
- [ ] בדקתי שלא bash_tool עם Windows path
- [ ] השתמשתי ב-full path או cd בפקודה
- [ ] הגדרתי timeout סביר

---

## 🎯 דוגמאות מעשיות

### דוגמה 1: מצא וקרא קובץ Provider
```dart
// שלב 1: חפש את הקובץ
start_search(
  path: "C:\\projects\\salsheli\\lib",
  pattern: "shopping_list.*provider",
  searchType: "files"
)
// תוצאה: lib\providers\shopping_lists_provider.dart

// שלב 2: קרא את הקובץ
read_file(
  path: "C:\\projects\\salsheli\\lib\\providers\\shopping_lists_provider.dart",
  length: 50
)
```

---

### דוגמה 2: תקן bug בקובץ
```dart
// שלב 1: קרא את הקובץ
read_file(path: "lib\\main.dart")

// שלב 2: מצא את הבעיה
// נניח: חסר WidgetsFlutterBinding

// שלב 3: תקן עם edit_block
edit_block(
  file_path: "C:\\projects\\salsheli\\lib\\main.dart",
  old_string: "void main() {\n  runApp(MyApp());",
  new_string: "void main() {\n  WidgetsFlutterBinding.ensureInitialized();\n  runApp(MyApp());",
  expected_replacements: 1
)
```

---

### דוגמה 3: הרץ Flutter tests
```dart
start_process(
  command: "cd C:\\projects\\salsheli; flutter test",
  timeout_ms: 60000  // דקה
)
```

---

### דוגמה 4: חפש כל השימושים ב-class
```dart
// מצא איפה משתמשים ב-ShoppingList
start_search(
  path: "C:\\projects\\salsheli\\lib",
  pattern: "ShoppingList",
  searchType: "content",
  filePattern: "*.dart"
)

// קבל תוצאות
get_more_search_results(
  sessionId: "...",
  length: 20
)
```

---

## 📝 סיכום

### כלים שצריך להכיר:
1. ✅ **read_file** - קריאת קבצים
2. ✅ **write_file** - כתיבת קבצים (בלבד!)
3. ✅ **edit_block** - עריכה כירורגית
4. ✅ **start_search** - חיפוש מתקדם
5. ✅ **start_process** - PowerShell

### כלים שאסור להשתמש:
1. ❌ **create_file** - false positive
2. ❌ **bash_tool** - לא עובד עם Windows

### עקרונות מנחים:
- 🔹 תמיד full paths
- 🔹 חלק קבצים ארוכים
- 🔹 בדוק הגבלות (100 items, 50 lines וכו')
- 🔹 השתמש ב-PowerShell דרך start_process

---

**📍 קובץ:** `C:\projects\salsheli\docs\MCP_GUIDE.md`  
**📅 גרסה:** 1.0 - נקי מאפס  
**✍️ נוצר:** 04/11/2025  
**🎯 מבוסס על:** בדיקה אמיתית של Desktop Commander v0.2.20
