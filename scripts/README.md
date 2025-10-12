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

### 2. `create_demo_data_v2.js` - יצירת נתוני דמו (מוצרים אמיתיים)

**מה זה עושה:**
- יוצר 3 רשימות קניות עם **מוצרים אמיתיים מ-Firestore**:
  - "קניות שבועיות" (active)
  - "יום הולדת לילדים" (active)
  - "ביקור בסופר פארם" (completed)
- יוצר ~15 פריטים במלאי עם **מוצרים אמיתיים**
- יוצר 2 קבלות עם **מחירים אמיתיים**

**⚠️ חשוב:** הרץ `upload_to_firebase.js` קודם להעלאת מוצרים!

**שימוש:**
```bash
cd scripts
npm run create-data-real
```

---

### 3. `create_system_templates.js` - יצירת תבניות מערכת 🆕

**מה זה עושה:**
- יוצר 6 תבניות מערכת ב-Firestore
- סה"כ 66 פריטים מוצעים
- זמין לכל המשתמשים

**תבניות:**
1. 🛒 סופרמרקט שבועי (12 פריטים)
2. 💊 בית מרקחת (9 פריטים)
3. 🎂 יום הולדת (11 פריטים)
4. 🍷 אירוח סוף שבוע (12 פריטים)
5. 🎮 ערב משחקים (10 פריטים)
6. 🏕️ קמפינג/טיול (12 פריטים)

**שימוש:**
```bash
cd scripts
npm run create-templates
```

---

### 4. `upload_to_firebase.js` - העלאת מוצרים ל-Firestore

**מה זה עושה:**
- מעלה את `assets/data/products.json` ל-Firestore
- מעלה בבאצ'ים של 500 מוצרים

**שימוש:**
```bash
# קודם הרץ:
dart run scripts/fetch_shufersal_products.dart

# אחר כך:
cd scripts
npm run upload-products
```

---

### 5. `fetch_shufersal_products.dart` - הורדת מוצרים מ-API

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

# 2. יצירת משתמשים + תבניות מערכת + נתונים
npm run create-users
npm run create-templates
npm run create-data-real
```

**או בפקודה אחת:**
```bash
npm run setup-demo
```

זה יריץ **אוטומטית**:
1. `create_demo_users.js` - יצירת 3 משתמשים
2. `create_demo_data_v2.js` - יצירת רשימות + מלאי + קבלות (מוצרים אמיתיים)

**💡 טיפ:** אם רוצה גם תבניות מערכת, הרץ בנפרד:
```bash
npm run create-templates
```

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
Templates: 0
Lists: 0
Inventory: 0
Receipts: 0
```

### אחרי (setup-demo):
```
Users: 3 (with realistic data)
Templates: 6 (system templates) ✨
Lists: 3 (2 active + 1 completed)
Inventory: ~15 items
Receipts: 2
```

**כל הנתונים עם מוצרים אמיתיים מ-Firestore!** 🎉

---

## 🎯 תוצאות בממשק

אחרי הרצת הסקריפטים, האפליקציה תראה "חיה" ומלאה:

### 🏠 Home Dashboard:
- **2 רשימות פעילות**
- **סטטיסטיקות אמיתיות**
- **2 קבלות אחרונות**

### 📋 Templates Screen:
- **6 תבניות מערכת מוכנות לשימוש** ✨
- כל תבנית עם פריטים מוצעים

### ⚙️ Settings Screen:
- **סטטיסטיקות** - 2 רשימות פעילות, 2 קבלות, ~15 פריטים במלאי
- **נראה כמו משתמש אמיתי**

### 📦 Inventory:
- **~15 פריטים** (מוצרים אמיתיים)
- **שמות מוצרים אמיתיים** מ-Shufersal

### 💡 Suggestions:
- **המלצות** מבוססות היסטוריה ומלאי

---

## 🐛 Troubleshooting

### שגיאה: "Failed to initialize Firebase Admin"
**פתרון:** הוסף את `firebase-service-account.json` (ראה הוראות למעלה)

### שגיאה: "User already exists"
**פתרון:** זה בסדר! הסקריפט מעדכן את המשתמש הקיים

### שגיאה: "No products found in Firestore"
**פתרון:** הרץ `npm run upload-products` קודם להעלאת מוצרים

### שגיאה: "Document already exists"
**פתרון:** הסקריפט משתמש ב-`set()` שדורס אוטומטית

---

## 🔗 קישורים מהירים

- [Firebase Console](https://console.firebase.google.com)
- [Firestore Database](https://console.firebase.google.com/project/salsheli/firestore)
- [Authentication](https://console.firebase.google.com/project/salsheli/authentication)

---

**עדכון אחרון:** 11/10/2025  
**Version:** 2.1 - תבניות מערכת ✨
