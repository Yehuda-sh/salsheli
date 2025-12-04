# MemoZap - מסמך זרימת נתונים

**גרסה:** 1.0
**תאריך:** דצמבר 2025
**שפה:** עברית

---

## תוכן עניינים

1. [סקירה כללית](#1-סקירה-כללית)
2. [ארכיטקטורת השכבות](#2-ארכיטקטורת-השכבות)
3. [זרימת נתונים - קריאה](#3-זרימת-נתונים---קריאה)
4. [זרימת נתונים - כתיבה](#4-זרימת-נתונים---כתיבה)
5. [מסלולי משתמש עיקריים](#5-מסלולי-משתמש-עיקריים)
6. [מבנה המידע ב-Firebase](#6-מבנה-המידע-ב-firebase)
7. [תרשים תלויות](#7-תרשים-תלויות)

---

## 1. סקירה כללית

### מה זה MemoZap?
אפליקציית ניהול רשימות קניות משפחתיות עם:
- רשימות קניות משותפות
- מזווה דיגיטלי (מעקב מלאי)
- המלצות חכמות לקנייה
- קנייה משותפת בזמן אמת

### טכנולוגיות
| רכיב | טכנולוגיה |
|------|-----------|
| צד לקוח | Flutter (Dart) |
| מסד נתונים | Firebase Firestore |
| אימות | Firebase Authentication |
| ניהול State | Provider Pattern |

---

## 2. ארכיטקטורת השכבות

האפליקציה בנויה ב-3 שכבות:

```
┌─────────────────────────────────────────────────────┐
│                    UI (מסכים)                        │
│         screens/, widgets/                          │
│    מה שהמשתמש רואה ומתקשר איתו                       │
└─────────────────────────────────────────────────────┘
                        ↓ ↑
┌─────────────────────────────────────────────────────┐
│               Providers (ניהול State)               │
│               providers/                            │
│    מחזיקים את המידע ומנהלים שינויים                  │
└─────────────────────────────────────────────────────┘
                        ↓ ↑
┌─────────────────────────────────────────────────────┐
│              Repositories (גישה לנתונים)            │
│              repositories/                          │
│    מתקשרים עם Firebase ומקורות מידע                 │
└─────────────────────────────────────────────────────┘
                        ↓ ↑
┌─────────────────────────────────────────────────────┐
│                Firebase Firestore                   │
│              (מסד הנתונים בענן)                      │
└─────────────────────────────────────────────────────┘
```

### הסבר פשוט:
- **UI** - מה שהמשתמש רואה (כפתורים, רשימות, טפסים)
- **Providers** - "המוח" שזוכר את המידע ואומר ל-UI מתי להתעדכן
- **Repositories** - "השליחים" שמביאים ושולחים מידע ל-Firebase
- **Firebase** - "המחסן" שבו כל המידע נשמר בענן

---

## 3. זרימת נתונים - קריאה

### איך מידע מגיע מ-Firebase למסך?

```
┌──────────────┐
│   Firebase   │  ← המידע נשמר כאן
└──────────────┘
       │
       ↓ שליפת נתונים
┌──────────────┐
│  Repository  │  ← שולף מידע + ממיר ל-Model
└──────────────┘
       │
       ↓ מעביר לProvider
┌──────────────┐
│   Provider   │  ← שומר במשתנה + קורא notifyListeners()
└──────────────┘
       │
       ↓ UI מתעדכן אוטומטית
┌──────────────┐
│    מסך/UI   │  ← מציג למשתמש
└──────────────┘
```

### דוגמה: טעינת רשימות קניות

**שלב 1:** המשתמש מתחבר → `UserContext` מקבל את פרטי המשתמש

**שלב 2:** `ShoppingListsProvider` מזהה שיש משתמש מחובר

**שלב 3:** Provider קורא ל-Repository:
```dart
final lists = await repository.fetchLists(householdId);
```

**שלב 4:** Repository שולף מ-Firestore:
```dart
firestore.collection('shopping_lists')
    .where('household_id', '==', householdId)
    .get()
```

**שלב 5:** Repository ממיר JSON למודלים:
```dart
ShoppingList.fromJson(doc.data())
```

**שלב 6:** Provider שומר ומעדכן UI:
```dart
_lists = fetchedLists;
notifyListeners(); // UI מתעדכן!
```

---

## 4. זרימת נתונים - כתיבה

### איך פעולת משתמש נשמרת ב-Firebase?

```
┌──────────────┐
│ משתמש לוחץ  │  → "צור רשימה חדשה"
└──────────────┘
       │
       ↓
┌──────────────┐
│    מסך/UI   │  → קורא ל-Provider
└──────────────┘
       │
       ↓
┌──────────────┐
│   Provider   │  → יוצר Model + שולח ל-Repository
└──────────────┘
       │
       ↓
┌──────────────┐
│  Repository  │  → מוסיף household_id + שומר
└──────────────┘
       │
       ↓
┌──────────────┐
│   Firebase   │  ← נשמר בענן!
└──────────────┘
       │
       ↓ רענון
┌──────────────┐
│   Provider   │  → טוען מחדש + notifyListeners()
└──────────────┘
       │
       ↓
┌──────────────┐
│    מסך/UI   │  ← מציג רשימה חדשה!
└──────────────┘
```

### דוגמה: יצירת רשימת קניות

**שלב 1:** משתמש ממלא טופס ולוחץ "צור"

**שלב 2:** המסך קורא ל-Provider:
```dart
await provider.createList(name: "קניות שבועיות", type: "supermarket");
```

**שלב 3:** Provider יוצר Model חדש:
```dart
final newList = ShoppingList.newList(
  id: uuid.v4(),
  name: name,
  createdBy: userId,
);
```

**שלב 4:** Provider שולח ל-Repository:
```dart
await repository.saveList(newList, householdId);
```

**שלב 5:** Repository שומר ב-Firebase:
```dart
firestore.collection('shopping_lists').doc(list.id).set(data);
```

**שלב 6:** Provider מרענן:
```dart
await loadLists(); // טוען מחדש מ-Firebase
notifyListeners(); // UI מתעדכן
```

---

## 5. מסלולי משתמש עיקריים

### 5.1 יצירת רשימת קניות

```
משתמש לוחץ "רשימה חדשה"
         │
         ↓
    פותח מסך יצירה
    (CreateListScreen)
         │
         ↓
ממלא: שם, סוג, תקציב
  (אופציונלי: בוחר תבנית)
         │
         ↓
    לוחץ "צור"
         │
         ↓
ShoppingListsProvider.createList()
         │
         ↓
    נשמר ב-Firebase
   (collection: shopping_lists)
         │
         ↓
עובר למסך פרטי רשימה
להוספת פריטים
```

**קבצים מעורבים:**
- `lib/screens/shopping/create/create_list_screen.dart`
- `lib/providers/shopping_lists_provider.dart`
- `lib/repositories/firebase_shopping_lists_repository.dart`

---

### 5.2 הוספת פריט לרשימה

```
משתמש במסך רשימה
         │
         ↓
  לוחץ "הוסף פריט"
         │
         ↓
    פותח דיאלוג
(AddEditProductDialog)
         │
         ↓
ממלא: שם, כמות, מחיר
         │
         ↓
    לוחץ "שמור"
         │
         ↓
ShoppingListsProvider.addUnifiedItem()
         │
         ↓
  מוסיף ל-items array
  של הרשימה ב-Firebase
         │
         ↓
  UI מתעדכן אוטומטית
  (פריט מופיע ברשימה)
```

---

### 5.3 קנייה משותפת (Collaborative Shopping)

```
משתמש א' לוחץ "התחל קנייה"
              │
              ↓
   startCollaborativeShopping()
   (יוצר ActiveShopper.starter)
              │
              ↓
      עובר למסך קנייה
    (ActiveShoppingScreen)
              │
              ↓
    משתמש ב' מצטרף
   joinCollaborativeShopping()
   (יוצר ActiveShopper.helper)
              │
              ↓
    שניהם רואים אותה רשימה!
    סימון פריט ע"י אחד →
    → מתעדכן אצל השני בזמן אמת
              │
              ↓
 משתמש א' לוחץ "סיים קנייה"
              │
              ↓
  finishCollaborativeShopping()
              │
       ┌──────┴──────┐
       ↓             ↓
  יוצר קבלה     מעדכן מלאי
  וירטואלית    (אופציונלי)
       │             │
       └──────┬──────┘
              ↓
    רשימה עוברת לסטטוס
       "הושלמה"
```

**קבצים מעורבים:**
- `lib/screens/shopping/active/active_shopping_screen.dart`
- `lib/providers/shopping_lists_provider.dart`
- `lib/models/active_shopper.dart`

---

### 5.4 המלצות חכמות (Smart Suggestions)

```
InventoryProvider טוען מלאי
              │
              ↓
  notifyListeners() מופעל
              │
              ↓
SuggestionsProvider מאזין
              │
              ↓
  קורא ל-SuggestionsService
              │
              ↓
    בודק כל פריט במזווה:
    "האם הכמות נמוכה מהסף?"
              │
              ↓
      יוצר המלצות:
    ┌─────────────────────┐
    │ חלב - נשארו 2 יח'   │ ← critical
    │ לחם - נשאר 1        │ ← high
    │ גבינה - 3 יח'       │ ← medium
    └─────────────────────┘
              │
              ↓
   ממיין לפי דחיפות
   (critical > high > medium > low)
              │
              ↓
    Dashboard מציג:
 ┌────────────────────────────┐
 │  💡 המלצה: קנה חלב!        │
 │  [הוסף לרשימה] [דחה]       │
 └────────────────────────────┘
              │
         ┌────┴────┐
         ↓         ↓
    "הוסף"     "דחה"
         │         │
         ↓         ↓
   מוסיף      מסתיר
   לרשימה    ל-7 ימים
```

**רמות דחיפות:**
| רמה | תנאי | צבע |
|-----|------|-----|
| critical | כמות = 0 | אדום |
| high | כמות < 20% מהסף | כתום |
| medium | כמות < 50% מהסף | צהוב |
| low | אחרת | ירוק |

---

### 5.5 ניהול מזווה (Inventory)

```
משתמש פותח מסך מזווה
    (MyPantryScreen)
              │
              ↓
InventoryProvider.loadItems()
              │
              ↓
   Firebase → Repository →
   → Provider → UI
              │
              ↓
    מציג רשימת פריטים:
 ┌────────────────────────────┐
 │ 🥛 חלב    │ 5 יח' │ ✓ OK  │
 │ 🍞 לחם    │ 1 יח' │ ⚠ LOW │
 │ 🧀 גבינה  │ 0     │ ❌ OUT│
 └────────────────────────────┘
              │
              ↓
  משתמש מוסיף/מעדכן פריט
              │
              ↓
  InventoryProvider.saveItem()
              │
              ↓
  SuggestionsProvider מתעדכן
  (אולי צריך להוסיף/להסיר המלצה)
```

---

## 6. מבנה המידע ב-Firebase

### Collections (אוספים)

```
Firestore Database
│
├── users/                    ← משתמשים
│   └── {userId}
│       ├── id
│       ├── email
│       ├── name
│       └── household_id      ← קישור למשק בית
│
├── households/               ← משקי בית
│   └── {householdId}
│       ├── id
│       ├── name
│       └── members[]         ← רשימת משתמשים
│
├── shopping_lists/           ← רשימות קניות
│   └── {listId}
│       ├── id
│       ├── household_id      ← חובה! לסינון
│       ├── name
│       ├── type              ← supermarket/pharmacy/etc
│       ├── status            ← active/completed/archived
│       ├── created_by
│       ├── budget
│       ├── items[]           ← פריטים ברשימה
│       │   └── {id, name, quantity, price, is_checked...}
│       ├── active_shoppers[] ← קונים פעילים
│       │   └── {user_id, role, is_active, joined_at}
│       └── shared_users[]    ← משתמשים משותפים
│           └── {user_id, role, shared_at}
│
├── inventory/                ← פריטי מזווה
│   └── {itemId}
│       ├── id
│       ├── household_id
│       ├── product_name
│       ├── category
│       ├── location          ← מקרר/מקפיא/ארון
│       ├── quantity
│       ├── min_quantity      ← סף להמלצות
│       └── unit
│
└── receipts/                 ← קבלות
    └── {receiptId}
        ├── id
        ├── household_id
        ├── linked_shopping_list_id
        ├── store_name
        ├── items[]
        └── total
```

### עיקרון חשוב: household_id

כל מידע מסונן לפי `household_id`:
- **בכתיבה:** Repository מוסיף אוטומטית
- **בקריאה:** Repository מסנן לפי המשתמש המחובר

```dart
// כל שליפה כוללת את הסינון:
firestore.collection('shopping_lists')
    .where('household_id', '==', currentUserHouseholdId)
```

---

## 7. תרשים תלויות

### איך ה-Providers תלויים זה בזה?

```
┌─────────────────┐
│   AuthService   │  ← שירות אימות (לא Provider)
└────────┬────────┘
         │
         ↓ מספק Stream של מצב התחברות
┌─────────────────┐
│   UserContext   │  ← "מי מחובר?"
│                 │     מחזיק פרטי משתמש + household_id
└────────┬────────┘
         │
         │ כל Provider תלוי ב-UserContext:
         │
    ┌────┴────────────────────────────────┐
    │                                     │
    ↓                                     ↓
┌─────────────────┐              ┌─────────────────┐
│ ShoppingLists   │              │   Inventory     │
│    Provider     │              │    Provider     │
│                 │              │                 │
│ רשימות קניות    │              │ פריטי מזווה     │
└─────────────────┘              └────────┬────────┘
                                          │
                                          ↓ תלוי במלאי
                                 ┌─────────────────┐
                                 │  Suggestions    │
                                 │    Provider     │
                                 │                 │
                                 │ המלצות חכמות    │
                                 └─────────────────┘
```

### רשימת כל ה-Providers

| Provider | תפקיד | תלוי ב- |
|----------|-------|---------|
| `UserContext` | מידע על משתמש מחובר | AuthService |
| `ShoppingListsProvider` | ניהול רשימות קניות | UserContext |
| `InventoryProvider` | ניהול מזווה | UserContext |
| `SuggestionsProvider` | המלצות חכמות | InventoryProvider |
| `ProductsProvider` | קטלוג מוצרים | UserContext |
| `LocationsProvider` | מיקומי אחסון | UserContext |
| `ReceiptProvider` | קבלות | UserContext |

---

## סיכום

### עקרונות מפתח

1. **הפרדת שכבות** - UI לא מדבר ישירות עם Firebase
2. **Provider כמקור אמת** - כל מידע עובר דרך Provider
3. **household_id בכל מקום** - מבטיח הפרדה בין משפחות
4. **notifyListeners()** - מעדכן UI אוטומטית
5. **Repository Pattern** - מאפשר להחליף מקור נתונים בקלות

### קבצים חשובים

| תיקייה | תוכן |
|--------|------|
| `lib/providers/` | ניהול State |
| `lib/repositories/` | גישה ל-Firebase |
| `lib/models/` | מבני נתונים |
| `lib/services/` | לוגיקה עסקית |
| `lib/screens/` | מסכי UI |
| `lib/widgets/` | רכיבי UI |

---

*מסמך זה מתאר את ארכיטקטורת הנתונים של MemoZap. לשאלות נוספות, עיין בקוד המקור או בתיעוד הטכני.*
