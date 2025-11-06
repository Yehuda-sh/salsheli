# 🤖 הנחיות עבודה עם Claude - MemoZap

> **גרסה:** 1.0 Clean | **תאריך:** 04/11/2025  
> **מטרה:** כללי עבודה פשוטים ויעילים

---

## 🎯 עקרונות יסוד

### 1️⃣ תקשורת
- **עברית** - כל הסברים והתשובות
- **אנגלית** - קוד בלבד
- **קצר וממוקד** - לא essays
- **שאל רק אם חוסם** - אחרת תמשיך

### 2️⃣ עבודה עם קבצים
- **תמיד full paths** - `C:\projects\salsheli\...`
- **קרא לפני עריכה** - אל תשנה בעיוורון
- **קטע אחר קטע** - קבצים ארוכים במנות

### 3️⃣ Code Review
- **פורמט אחיד:**
  ```
  📄 קובץ: [שם]
  סטטוס: [✅/⚠️/❌]
  סיכום: [משפט אחד]
  
  🚨 בעיות קריטיות:
  - [רשימה]
  
  🔧 צעדים:
  1. [מה לעשות]
  ```

---

## 🛠️ פקודות מהירות

| פקודה | פעולה |
|-------|-------|
| **"המשך"** | המשך מהצעד האחרון |
| **"תבדוק [קובץ]"** | Code review מלא |
| **"תקן [בעיה]"** | תקן ישירות |
| **"תחפש [דבר]"** | חיפוש בפרויקט |
| **"תסביר [מה]"** | הסבר קצר |

---

## 📁 מבנה פרויקט

```
C:\projects\salsheli\
├── lib/
│   ├── models/           # Data classes
│   ├── providers/        # State management
│   ├── repositories/     # Firebase CRUD
│   ├── screens/          # UI screens
│   ├── widgets/          # Reusable widgets
│   ├── services/         # Business logic
│   └── main.dart         # Entry point
├── test/                 # Tests
└── docs/                 # Documentation
    ├── MCP_GUIDE.md      # 👈 MCP tools guide
    └── [others]
```

---

## ⚡ טיפים מהירים

### כתיבת קוד
```dart
✅ נכון:
- package:memozap/... imports
- const על widgets סטטיים
- notifyListeners() אחרי שינוי
- dispose() מנקה הכל

❌ לא נכון:
- ../../../ imports
- context אחרי await (ללא mounted)
- לשכוח removeListener
```

### חיפוש
```dart
✅ טוב:
- חפש שם קובץ: searchType="files"
- חפש בתוכן: searchType="content"
- הוסף filePattern="*.dart"

❌ לא טוב:
- לא לציין searchType
- pattern רחב מדי
```

### הרצת פקודות
```powershell
✅ עובד:
cd C:\projects\salsheli; flutter test

❌ לא עובד:
bash_tool עם C:\...
```

---

## 🎨 קונבנציות UI

### צבעים (Sticky Notes)
- `kStickyYellow` - כפתורים ראשיים
- `kStickyGreen` - הוספה/הצלחה
- `kStickyPink` - מחיקה/התראה
- `kStickyCyan` - מידע משני

### Components מוכנים
```dart
// במקום ElevatedButton:
StickyButton(text: 'שמור', onPressed: ...)

// במקום GestureDetector + AnimatedScale:
SimpleTappableCard(onTap: ..., child: ...)

// במקום CircularProgressIndicator:
SkeletonLoading(type: SkeletonType.list)
```

---

## 🔒 אבטחה (חובה!)

```dart
// ✅ כל query חייב:
.where('household_id', isEqualTo: householdId)

// ❌ ללא household_id = חשיפת מידע!
```

---

## 🧪 Testing

```dart
// 4 מצבים חובה:
- Loading: CircularProgressIndicator
- Error: Icon + Message + Retry
- Empty: Icon + Message + CTA
- Content: הנתונים

// Finders:
find.bySemanticsLabel('שם המשתמש')  // ✅
find.byWidgetPredicate(...)          // ❌
```

---

## 📊 ניהול זיכרון

### Memory Entities (10 מקסימום):
1. Current Work Context
2. Recent Sessions (3-5 last)
3. Active Issues
4. Feature Progress
5. Learning from Mistakes
6. Project Info
7. Standards
8. Critical Protocols
9. Tool Errors
10. Environment

**עדכון:** אחרי 3-5 קבצים או לפני החלפת נושא

---

## 🚦 Token Management

| רמה | פעולה |
|-----|-------|
| **70%** | התראה - שאל אם להמשיך או checkpoint |
| **85%** | Checkpoint אוטומטי + מצב תמציתי |
| **90%** | שמירת חירום + סיום |

---

## 🎓 למידה מטעויות

### דוגמה:
```yaml
טעות: שכחתי removeListener ב-dispose
סיבה: Provider ממשיך להאזין אחרי dispose
תיקון: הוספתי removeListener
לקח: תמיד בדוק dispose - checklist חובה
```

---

## 📝 Changelog מומלץ

```markdown
## Session X - [תאריך]

**מה עשינו:**
- ✅ [משימה 1]
- ⚠️ [בעיה שנתקלנו]
- 🔄 [מה נשאר]

**קבצים שונו:**
- file1.dart: [מה]
- file2.dart: [מה]

**Next Steps:**
1. [צעד 1]
2. [צעד 2]
```

---

## 🔧 פתרון בעיות מהיר

### "הקובץ לא נוצר"
→ בדוק שלא השתמשת ב-`create_file`  
→ השתמש ב-`write_file`

### "לא מוצא את הקובץ"
→ בדוק full path  
→ רץ `list_directory` לאימות

### "PowerShell לא רץ בפרויקט"
→ הוסף `cd C:\projects\salsheli;` לפני הפקודה

### "חיפוש לא מצא כלום"
→ בדוק searchType (files vs content)  
→ נסה pattern יותר רחב

---

## ✅ Checklist לפני Commit

### קוד:
- [ ] household_id בכל query
- [ ] dispose() מנקה הכל
- [ ] const על widgets סטטיים
- [ ] package imports
- [ ] bySemanticsLabel בטסטים

### UI:
- [ ] 4 מצבים (Loading/Error/Empty/Content)
- [ ] NotebookBackground עם Stack
- [ ] StickyButton (לא Elevated)
- [ ] RTL + EdgeInsetsDirectional

### תיעוד:
- [ ] עדכון WORK_PLAN.md אם רלוונטי
- [ ] עדכון memory entities
- [ ] Next Steps ברור

---

## 🎯 דוגמה מלאה: תיקון Bug

```markdown
👤 משתמש: "יש bug ב-shopping_lists_provider - לא מנקה listener"

🤖 Claude:
1. אקרא את הקובץ
2. אאתר את הבעיה
3. אתקן עם edit_block
4. אסביר מה תיקנתי

[מריץ read_file]
[מוצא את הבעיה - חסר removeListener]
[מריץ edit_block]

תיקנתי! הוספתי:
```dart
@override
void dispose() {
  _userContext.removeListener(_onUserChanged);
  super.dispose();
}
```

הבעיה: הייתה memory leak - Provider המשיך להאזין
אחרי dispose.

Next: לבדוק Providers נוספים עם אותה בעיה?
```

---

## 🚀 העקרונות החשובים ביותר

1. **Full paths תמיד** - אל תסתמך על working directory
2. **קרא לפני שינוי** - אל תנחש מה בקובץ
3. **write_file בלבד** - create_file שבור
4. **PowerShell דרך start_process** - לא bash_tool
5. **household_id חובה** - אבטחה לא מתפשרת
6. **dispose מנקה הכל** - memory leaks זה רע
7. **4 מצבי UI** - אל תשכח Empty/Error
8. **const חוסך rebuilds** - performance חשוב

---

**📍 סיום**

זה הכל! מסמך פשוט ויעיל.  
כל השאר - ב-`MCP_GUIDE.md` למידע טכני מפורט.

**🎯 זכור:** Simple > Complex. Working > Perfect.
