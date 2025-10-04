# 🔒 כללי אבטחה ל-Firestore

העתק את הכללים האלה ל-Firebase Console → Firestore → Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // 📦 קולקציית מוצרים - קריאה לכולם, כתיבה רק למנהלים
    match /products/{productId} {
      allow read: if true;  // כולם יכולים לקרוא
      allow write: if false; // אף אחד לא יכול לכתוב (רק דרך Admin SDK)
    }
    
    // 🛒 רשימות קניות - רק המשתמש עצמו
    match /shopping_lists/{listId} {
      allow read, write: if request.auth != null && 
                           request.auth.uid == resource.data.userId;
    }
    
    // 👤 משתמשים - רק המשתמש עצמו
    match /users/{userId} {
      allow read, write: if request.auth != null && 
                           request.auth.uid == userId;
    }
    
    // 🏠 משקי בית - רק חברי המשק בית
    match /households/{householdId} {
      allow read, write: if request.auth != null && 
                           request.auth.uid in resource.data.memberIds;
    }
  }
}
```

---

## 📝 הסבר

- **products** - כולם יכולים לקרוא, אין כתיבה (רק דרך סקריפט Admin)
- **shopping_lists** - רק המשתמש שיצר את הרשימה
- **users** - רק המשתמש עצמו
- **households** - רק חברי משק הבית

---

## 🚀 יישום

1. פתח [Firebase Console](https://console.firebase.google.com)
2. בחר את הפרויקט **salsheli**
3. לך ל-**Firestore Database** → **Rules**
4. העתק והדבק את הכללים למעלה
5. לחץ **Publish**
