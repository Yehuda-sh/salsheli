# 🚀 הרצה מהירה - שליפת מוצרים ממחירון

## צעדים:

### 1. פתח PowerShell בתיקיית הפרויקט
```powershell
cd C:\projects\salsheli
```

### 2. הרץ את הסקריפט
```powershell
dart run scripts/fetch_published_products.dart
```

### 3. המתן (1-3 דקות)
הסקריפט יציג התקדמות:
```
🛒 מתחיל שליפת מוצרים...
🔐 מתחבר למערכת...
✅ התחברות הצליחה
⬇️  מוריד ומפענח מוצרים...
✓ פוענחו 12543 מוצרים
```

### 4. בדוק את הקובץ
```powershell
# הצג את הקובץ
Get-Content assets\data\products.json | Select-Object -First 50

# ספור מוצרים
(Get-Content assets\data\products.json | ConvertFrom-Json).Count
```

---

## ⚙️ שינוי הגדרות

ערוך את `scripts/fetch_published_products.dart` בשורות **16-29**:

```dart
// שם רשת (שורה 17)
const String? chainName = 'רמי לוי';  // או null לכל הרשתות

// מספר מוצרים מקסימלי (שורה 26)
const int? maxProducts = 5000;  // או null לכל המוצרים

// מחיר מינימלי (שורה 29)
const double minPrice = 0.5;  // סינון מוצרים זולים
```

**💡 טיפ:** הסיסמה (`_password`) ריקה כי הגישה לרמי לוי היא ציבורית.

---

## 🔄 מצב עדכון חכם

הסקריפט **לא מחליף** את הקובץ - הוא **מעדכן** אותו:
- ✅ מעדכן מחירים של מוצרים קיימים
- ➕ מוסיף מוצרים חדשים  
- ⏸️  שומר מוצרים שלא נמצאו בעדכון (לא מוחק אותם)

**אין צורך בגיבוי ידני** - הקובץ מעודכן בצורה חכמה!

---

## ❌ אם יש שגיאה

### "Not found" או "Cannot find"
```powershell
# וודא שאתה בתיקייה הנכונה
pwd  # צריך להיות: C:\projects\salsheli

# אם לא:
cd C:\projects\salsheli
```

### "Connection error"
- בדוק חיבור לאינטרנט
- נסה שוב מאוחר יותר (האתר עשוי להיות לא זמין)

### בעיות בחיפוש קבצים?
הסקריפט יוצר קובץ `debug_response.html` - פתח אותו לבדוק:
```powershell
# פתח את קובץ ה-debug בדפדפן
start debug_response.html
```
אם הקובץ ריק או מכיל שגיאת 404 - הבעיה בחיבור לשרת מחירון.

### "Permission denied"
```powershell
# הרץ PowerShell כמנהל
# (לחיצה ימנית על PowerShell -> "Run as Administrator")
```

---

## 📊 מה יהיה בקובץ?

```json
[
  {
    "name": "חלב 3% תנובה 1 ליטר",
    "category": "מוצרי חלב",
    "icon": "🥛",
    "price": 7.9,
    "barcode": "7290000066619",
    "brand": "תנובה",
    "unit": "ליטר",
    "store": "רמי לוי"
  }
]
```

**כל מוצר כולל:**
- שם מלא
- קטגוריה (מזוהה אוטומטית)
- אייקון מתאים
- מחיר עדכני
- ברקוד
- מותג
- יחידת מידה
- שם הרשת

---

## 💡 טיפים שימושיים

### רוצה לראות מה השתנה?
```powershell
# הצג את הסיכום שבסוף ההרצה
dart run scripts/fetch_published_products.dart | Select-String "עודכנו|נוספו"
```

### בעיות ביצועים?
הפחת את `maxProducts` ל-1000 או 2000 למשיכה מהירה יותר:
```dart
const int? maxProducts = 1000;  // במקום 5000
```

### רוצה למשוך מכל הרשתות?
```dart
const String? chainName = null;  // במקום 'רמי לוי'
```

---

## ✅ זהו!

הסקריפט מוכן לשימוש ישירות. העדכונים שומרים את הקובץ הקיים ומעדכנים רק מחירים.
