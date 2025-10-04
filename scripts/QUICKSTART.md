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

ערוך את `scripts/fetch_published_products.dart` בשורות 14-26:

```dart
// שם רשת
const String? chainName = 'רמי לוי';  // או 'שופרסל', או null

// מספר מוצרים מקסימלי
const int? maxProducts = 5000;  // או null לכל המוצרים

// מחיר מינימלי
const double minPrice = 0.5;  // סינון מוצרים זולים
```

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

### "Permission denied"
```powershell
# הרץ PowerShell כמנהל
# (לחיצה ימנית על PowerShell -> "Run as Administrator")
```

---

## 💾 גיבוי לפני הרצה

```powershell
# צור גיבוי אוטומטי
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
Copy-Item assets\data\products.json "products_backup_$timestamp.json"

# הרץ את הסקריפט
dart run scripts\fetch_published_products.dart

# אם הצליח - מחק גיבוי
Remove-Item "products_backup_$timestamp.json"
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
  },
  ...
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

## ✅ זהו!

הסקריפט מוכן לשימוש ישירות.
