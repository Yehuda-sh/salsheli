# 🤖 הנחיות עבודה עם Claude - MemoZap

> **גרסה:** 2.0 | **תאריך:** 20/11/2024
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
├── assets/
│   ├── data/             # JSON data files
│   │   └── list_types/   # Product lists (bakery, butcher, etc.)
│   ├── images/           # Product images
│   └── templates/        # Templates
├── test/                 # Tests
└── docs/                 # Documentation
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

## 📊 ניהול Barcodes

### קונבנציה:
```
BAKERY-001, BAKERY-002, ...    # מאפייה
BUTCHER-001, BUTCHER-002, ...  # קצב
GREENGROCER-001, ...           # ירקן
SUPERMARKET-001, ...           # סופר
```

### שדות מוצר:
```json
{
  "name": "בורקס גבינה",
  "category": "מאפים",
  "icon": "🥐",
  "price": 6.5,
  "barcode": "BAKERY-001",
  "brand": "",
  "unit": "יחידה",
  "store": "כללי",
  "imageUrl": "https://..."  // אופציונלי
}
```

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

### נתונים:
- [ ] Barcodes ייחודיים
- [ ] Categories נכונים
- [ ] Units סטנדרטיים (יחידה, ק"ג, 100 גרם)
- [ ] imageUrl או null

---

## 🎯 דוגמה מלאה: תיקון Bug

```markdown
👤 משתמש: "יש bug ב-shopping_lists_provider - לא מנקה listener"

🤖 Claude:
1. אקרא את הקובץ
2. אאתר את הבעיה
3. אתקן
4. אסביר מה תיקנתי

[קורא את הקובץ]
[מוצא את הבעיה - חסר removeListener]
[מתקן]

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
3. **household_id חובה** - אבטחה לא מתפשרת
4. **dispose מנקה הכל** - memory leaks זה רע
5. **4 מצבי UI** - אל תשכח Empty/Error
6. **const חוסך rebuilds** - performance חשוב
7. **Barcodes ייחודיים** - שמור על קונבנציה
8. **Categories עקביים** - בדוק שהכל נכון

---

**📍 סיום**

זה הכל! מסמך פשוט ויעיל.

**🎯 זכור:** Simple > Complex. Working > Perfect.
