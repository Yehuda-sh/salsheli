# 🔒 כללי אבטחה ל-Firestore - מעודכן עם Templates

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
    
    // 📋 תבניות (Templates) - מערכת + משתמשים
    match /templates/{templateId} {
      // קריאה:
      // - תבניות מערכת (is_system: true) - כולם יכולים לקרוא
      // - תבניות משתמש - רק בעלים + חברי משק בית
      allow read: if request.auth != null && (
        resource.data.is_system == true ||
        request.auth.uid == resource.data.user_id ||
        (resource.data.household_id != null && 
         exists(/databases/$(database)/documents/households/$(resource.data.household_id)) &&
         request.auth.uid in get(/databases/$(database)/documents/households/$(resource.data.household_id)).data.memberIds)
      );
      
      // יצירה - רק משתמשים מחוברים (תבניות משתמש)
      allow create: if request.auth != null && 
                       request.resource.data.user_id == request.auth.uid &&
                       request.resource.data.is_system == false;
      
      // עדכון/מחיקה - רק בעלים (לא תבניות מערכת!)
      allow update, delete: if request.auth != null && 
                               resource.data.is_system == false &&
                               resource.data.user_id == request.auth.uid;
    }
    
    // 🛒 רשימות קניות - רק המשתמש + חברי משק בית
    match /shopping_lists/{listId} {
      allow read, write: if request.auth != null && (
        request.auth.uid == resource.data.user_id ||
        (resource.data.household_id != null && 
         exists(/databases/$(database)/documents/households/$(resource.data.household_id)) &&
         request.auth.uid in get(/databases/$(database)/documents/households/$(resource.data.household_id)).data.memberIds)
      );
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
    
    // 🧾 קבלות - רק המשתמש + חברי משק בית
    match /receipts/{receiptId} {
      allow read, write: if request.auth != null && (
        request.auth.uid == resource.data.user_id ||
        (resource.data.household_id != null && 
         exists(/databases/$(database)/documents/households/$(resource.data.household_id)) &&
         request.auth.uid in get(/databases/$(database)/documents/households/$(resource.data.household_id)).data.memberIds)
      );
    }
    
    // 📦 מלאי - רק המשתמש + חברי משק בית
    match /inventory/{itemId} {
      allow read, write: if request.auth != null && (
        request.auth.uid == resource.data.user_id ||
        (resource.data.household_id != null && 
         exists(/databases/$(database)/documents/households/$(resource.data.household_id)) &&
         request.auth.uid in get(/databases/$(database)/documents/households/$(resource.data.household_id)).data.memberIds)
      );
    }
  }
}
```

---

## 📝 הסבר לTemplates Rules

### קריאה (Read):
```javascript
allow read: if request.auth != null && (
  resource.data.is_system == true ||           // תבניות מערכת - כולם
  request.auth.uid == resource.data.user_id || // תבנית שלי
  // תבנית של חבר במשק בית שלי
)
```

### יצירה (Create):
```javascript
allow create: if request.auth != null && 
                 request.resource.data.user_id == request.auth.uid &&
                 request.resource.data.is_system == false;  // רק תבניות משתמש!
```

### עדכון/מחיקה (Update/Delete):
```javascript
allow update, delete: if request.auth != null && 
                         resource.data.is_system == false &&  // לא תבניות מערכת!
                         resource.data.user_id == request.auth.uid;  // רק בעלים
```

---

## 🎯 תכונות

✅ **תבניות מערכת (System Templates)**:
- is_system: true
- קריאה: כולם
- כתיבה: רק Admin SDK (לא דרך rules!)

✅ **תבניות משתמש (User Templates)**:
- is_system: false
- יצירה: כל משתמש מחובר
- קריאה: בעלים + חברי משק בית
- עדכון/מחיקה: רק בעלים

✅ **שיתוף תבניות**:
- format: 'shared' = זמין לכל משק הבית
- format: 'assigned' = לחבר ספציפי
- format: 'personal' = רק לי

---

## 🚀 יישום

1. פתח [Firebase Console](https://console.firebase.google.com)
2. בחר את הפרויקט **salsheli**
3. לך ל-**Firestore Database** → **Rules**
4. העתק והדבק את הכללים למעלה
5. לחץ **Publish**

---

## 🔍 Indexes הנדרשים

### Index #1: Templates - System + Sort
```
Collection: templates
Fields:
  - is_system (Ascending)
  - sort_order (Ascending)
```

### Index #2: Templates - Household + Sort
```
Collection: templates
Fields:
  - household_id (Ascending)
  - sort_order (Ascending)
```

**ליצור ב-Firebase Console:**
Firestore → Indexes → Create Index

---

**עדכון:** 10/10/2025 - נוספו rules ל-templates + שאר הקולקציות
