# 🔥 העלאת מוצרים ל-Firebase

## 📋 תהליך מלא

### שלב 1: הורדת Service Account Key

1. פתח [Firebase Console](https://console.firebase.google.com)
2. בחר פרויקט **salsheli**
3. לחץ על הגלגל השיניים ⚙️ → **Project Settings**
4. לך לטאב **Service accounts**
5. לחץ **Generate new private key**
6. שמור את הקובץ בתיקייה `scripts/` עם השם **firebase-service-account.json**

⚠️ **חשוב:** אל תשתף את הקובץ הזה! הוא מכיל גישה מלאה לפרויקט.

---

### שלב 2: התקנת Dependencies

```powershell
cd C:\projects\salsheli\scripts
npm install
```

---

### שלב 3: הורדת מוצרים

```powershell
npm run download
```

זה יוצר קובץ `products.json` עם 20 מוצרים דמה.

**תוצאה:**
```
✅ הצלחה!
📁 הקובץ נשמר ב: C:\projects\salsheli\scripts\products.json
📊 סה"כ מוצרים: 20
```

---

### שלב 4: העלאה ל-Firestore

```powershell
npm run upload
```

זה מעלה את כל המוצרים מ-`products.json` ל-Firestore.

**תוצאה:**
```
🚀 מתחיל העלאה ל-Firestore...
📦 נמצאו 20 מוצרים
   📤 הועלו 20 / 20 מוצרים...
✅ הצלחה! הועלו 20 מוצרים ל-Firestore
```

---

### שלב 5: בדיקה באפליקציה

```powershell
cd ..
flutter run
```

המוצרים יופיעו באפליקציה אוטומטית! ✨

---

## 🔧 פתרון בעיות

### ❌ "Cannot find module 'firebase-admin'"
```powershell
npm install
```

### ❌ "הקובץ products.json לא נמצא"
```powershell
npm run download
```

### ❌ "firebase-service-account.json not found"
חזור לשלב 1 והורד את ה-Service Account Key.

---

## 📊 מבנה הקובץ products.json

```json
{
  "generated": "2025-01-04T10:30:00.000Z",
  "count": 20,
  "products": [
    {
      "barcode": "7290000000001",
      "name": "חלב 3%",
      "category": "מוצרי חלב",
      "brand": "תנובה",
      "unit": "ליטר",
      "icon": "🥛",
      "price": 7.9,
      "store": "רמי לוי"
    }
  ]
}
```

---

## 🎯 הוספת מוצרים נוספים

ערוך את `download_products.js` והוסף מוצרים ל-`DEMO_PRODUCTS`:

```javascript
{
  barcode: '7290000000999',
  name: 'מוצר חדש',
  category: 'קטגוריה',
  brand: 'מותג',
  unit: 'יחידה',
  icon: '🛒',
  price: 10.0,
  store: 'רמי לוי'
}
```

אחר כך הרץ שוב:
```powershell
npm run download
npm run upload
```

---

## ✅ סיימת!

המוצרים עכשיו ב-Firestore והאפליקציה עובדת איתם! 🎉
