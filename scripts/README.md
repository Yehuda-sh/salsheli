# 🔧 Scripts Directory

סקריפטים עזר לפיתוח ו-setup של Firebase.

---

## 📋 רשימת סקריפטים

### 1. `create_demo_users.js` - יצירת משתמשי דמו

**מה זה עושה:**
- יוצר 3 משתמשי דמו ב-Firebase Auth
- יוצר רשומות Firestore ל-3 משתמשים
- כולם שייכים ל-household_id: `house_demo`

**משתמשים:**
- `yoni@demo.com` / `Demo123!` (יוני)
- `sarah@demo.com` / `Demo123!` (שרה)
- `danny@demo.com` / `Demo123!` (דני)

**שימוש:**
```bash
cd scripts
npm run create-users
```

---

### 2. `create_demo_data.js` - יצירת נתוני דמו

**מה זה עושה:**
- יוצר 3 רשימות קניות:
  - "קניות שבועיות" (8 פריטים, active)
  - "יום הולדת לילדים" (6 פריטים, active)
  - "ביקור בסופר פארם" (4 פריטים, completed)
- יוצר 15 פריטים במלאי:
  - מוצרי מזווה (קמח, סוכר, אורז...)
  - מוצרי ניקיון
  - כולל התראות על מלאי נמוך (מיונז, שמן זית)
- יוצר 2 קבלות נוספות:
  - שופרסל (לפני 3 ימים, 287.50 ₪)
  - רמי לוי (לפני שבוע, 195.80 ₪)

**שימוש:**
```bash
cd scripts
npm run create-data
```

---

### 3. `upload_to_firebase.js` - העלאת מוצרים ל-Firestore

**מה זה עושה:**
- מעלה את `assets/data/products.json` ל-Firestore
- מעלה בבאצ'ים של 500 מוצרים

**שימוש:**
```bash
# קודם הרץ:
dart run scripts/fetch_shufersal_products.dart

# אחר כך:
cd scripts
node upload_to_firebase.js
```

---

### 4. `fetch_shufersal_products.dart` - הורדת מוצרים מ-API

**מה זה עושה:**
- מוריד מוצרים מ-Shufersal API
- שומר ל-`assets/data/products.json`

**שימוש:**
```bash
dart run scripts/fetch_shufersal_products.dart
```

---

## 🚀 Quick Setup - התקנה מלאה

אם אתה מתחיל מאפס, הרץ את זה **אחרי** שהגדרת Firebase:

```bash
cd scripts

# 1. התקנת dependencies
npm install

# 2. יצירת משתמשים + נתונים
npm run setup-demo
```

זה יריץ **אוטומטית**:
1. `create_demo_users.js` - יצירת 3 משתמשים
2. `create_demo_data.js` - יצירת רשימות + מלאי + קבלות

---

## ⚙️ הגדרת Firebase Admin (דרוש פעם אחת)

לפני הרצת הסקריפטים, צריך Service Account Key:

### שלבים:
1. כנס ל-[Firebase Console](https://console.firebase.google.com)
2. בחר את הפרויקט `salsheli`
3. ⚙️ **Project Settings** → **Service Accounts**
4. 📥 **Generate new private key**
5. 💾 שמור את הקובץ כ-`firebase-service-account.json` בתיקיית `scripts/`

**⚠️ חשוב:** הקובץ הזה **לא** צריך להיות ב-Git! (`firebase-service-account.json` כבר ב-.gitignore)

---

## 📊 מה יקרה אחרי ההרצה?

### לפני:
```
Users: 3 (empty data)
Lists: 1 (completed)
Inventory: 0
Receipts: 6
```

### אחרי:
```
Users: 3 (with realistic data)
Lists: 4 (3 new: 2 active + 1 completed)
Inventory: 15 (with low stock warnings)
Receipts: 8 (2 new)
```

---

## 🎯 תוצאות בממשק

אחרי הרצת `create_demo_data.js`, האפליקציה תראה הרבה יותר "חיה":

### 🏠 Home Dashboard:
- **2 רשימות פעילות** (במקום 0)
- **סטטיסטיקות אמיתיות**
- **8 קבלות** (במקום 6)

### ⚙️ Settings Screen:
- **סטטיסטיקות** - 2 רשימות פעילות, 8 קבלות, 15 פריטים במלאי
- **נראה כמו משתמש אמיתי**

### 📦 Inventory:
- **15 פריטים** (במקום 0)
- **התראות** על מלאי נמוך (מיונז, שמן זית)

### 💡 Suggestions:
- **המלצות** מבוססות היסטוריה ומלאי

---

## 🐛 Troubleshooting

### שגיאה: "Failed to initialize Firebase Admin"
**פתרון:** הוסף את `firebase-service-account.json` (ראה הוראות למעלה)

### שגיאה: "User already exists"
**פתרון:** זה בסדר! הסקריפט מעדכן את המשתמש הקיים

### שגיאה: "Document already exists"
**פתרון:** הסקריפט משתמש ב-`set()` שדורס אוטומטית

---

## 🔗 קישורים מהירים

- [Firebase Console](https://console.firebase.google.com)
- [Firestore Database](https://console.firebase.google.com/project/salsheli/firestore)
- [Authentication](https://console.firebase.google.com/project/salsheli/authentication)

---

**עדכון אחרון:** 08/10/2025  
**Version:** 2.0
