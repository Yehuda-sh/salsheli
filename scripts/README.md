# 🔐 הוראות הגדרת Firebase Authentication

## 📝 סקירה כללית

המערכת עברה מ-Mock Authentication ל-**Firebase Authentication** אמיתי עם 3 משתמשי דמו מוכנים:

| משתמש | אימייל | סיסמה | UID |
|------|--------|-------|-----|
| יוני | yoni@demo.com | Demo123! | yoni_demo_user |
| שרה | sarah@demo.com | Demo123! | sarah_demo_user |
| דני | danny@demo.com | Demo123! | danny_demo_user |

---

## 🚀 צעדי הגדרה

### שלב 1: הורדת Service Account Key

1. פתח את [Firebase Console](https://console.firebase.google.com/)
2. בחר בפרוייקט שלך
3. לחץ על ⚙️ **Settings** → **Project Settings**
4. עבור ל-**Service Accounts**
5. לחץ על **Generate new private key**
6. שמור את הקובץ כ-`serviceAccountKey.json` בתיקיית הפרוייקט (root)

⚠️ **חשוב:** אל תשתף את הקובץ הזה! הוסף אותו ל-`.gitignore`

### שלב 2: התקנת תלויות

```bash
cd scripts
npm install
```

### שלב 3: יצירת משתמשי הדמו

```bash
npm run create-users
```

או ישירות:

```bash
node create_demo_users.js
```

### שלב 4: אימות הצלחה

אחרי הרצת ה-script, אתה אמור לראות:

```
✅ Created new user with UID: yoni_demo_user
💾 Creating Firestore document for: יוני
   ✅ Firestore document created
✅ Successfully created: יוני

...

🎉 All demo users created successfully!

You can now login with:
   • יוני: yoni@demo.com / Demo123!
   • שרה: sarah@demo.com / Demo123!
   • דני: danny@demo.com / Demo123!
```

---

## 🧪 בדיקת ההתחברות

### מ-האפליקציה

1. הרץ את האפליקציה: `flutter run`
2. במסך התחברות:
   - לחץ על **"בחר משתמש דמו"**
   - בחר יוני/שרה/דני
   - לחץ **"התחבר עם חשבון דמו"**

### התחברות ידנית

באפשרותך גם להתחבר ידנית:
- אימייל: `yoni@demo.com`
- סיסמה: `Demo123!`

---

## 🔧 פתרון בעיות

### בעיה: "User not found"

**פתרון:**
```bash
# וודא שהמשתמשים נוצרו ב-Firebase
cd scripts
npm run create-users
```

### בעיה: "Invalid credential"

**סיבות אפשריות:**
1. הסיסמה שגויה - וודא שהיא `Demo123!`
2. המשתמש לא קיים ב-Firebase Auth
3. Firebase לא מאותחל כראוי

**פתרון:**
```bash
# מחק משתמשים קיימים ב-Firebase Console
# הרץ מחדש את ה-script
cd scripts
npm run create-users
```

### בעיה: "Failed to initialize Firebase Admin"

**פתרון:**
1. וודא שהורדת את `serviceAccountKey.json`
2. שם אותו בתיקיית הפרוייקט (root)
3. וודא שהקובץ תקין (JSON)

---

## 📂 מבנה הקבצים

```
C:\projects\salsheli\
│
├── serviceAccountKey.json         # ⚠️ אל תעלה ל-Git!
│
├── lib/
│   ├── services/
│   │   └── auth_service.dart      # 🔐 שירות אימות
│   │
│   ├── repositories/
│   │   └── firebase_user_repository.dart  # 🔥 משתמשים ב-Firestore
│   │
│   ├── providers/
│   │   └── user_context.dart      # 👤 מנהל משתמש נוכחי
│   │
│   ├── screens/auth/
│   │   ├── login_screen.dart      # 🔐 מסך התחברות
│   │   └── register_screen.dart   # 📝 מסך הרשמה
│   │
│   └── widgets/auth/
│       └── demo_login_button.dart # 🚀 כפתור דמו
│
└── scripts/
    ├── package.json
    └── create_demo_users.js       # 🛠️ יצירת משתמשי דמו
```

---

## 🔒 אבטחה

### מה נשמר ב-Firebase:

**Authentication:**
- אימייל
- סיסמה מוצפנת (Firebase מטפל בזה)
- שם תצוגה
- תאריך יצירה

**Firestore (users collection):**
```json
{
  "id": "yoni_demo_user",
  "email": "yoni@demo.com",
  "name": "יוני",
  "avatar": null,
  "householdId": "house_demo",
  "createdAt": "2025-10-05T...",
  "lastLoginAt": "2025-10-05T..."
}
```

### חוקי אבטחה מומלצים:

```javascript
// Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // users - רק בעלים יכול לקרוא/לכתוב
    match /users/{userId} {
      allow read, write: if request.auth != null 
                          && request.auth.uid == userId;
    }
    
    // shopping_lists - רק חברי משק בית
    match /shopping_lists/{listId} {
      allow read, write: if request.auth != null 
                          && get(/databases/$(database)/documents/users/$(request.auth.uid))
                             .data.householdId 
                             == resource.data.householdId;
    }
  }
}
```

---

## 📚 תיעוד נוסף

- [Firebase Authentication Docs](https://firebase.google.com/docs/auth)
- [Firestore Docs](https://firebase.google.com/docs/firestore)
- [Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

---

## ✅ סטטוס השינויים

| קובץ | סטטוס | תיאור |
|------|-------|-------|
| `pubspec.yaml` | ✅ | הוספת firebase_auth |
| `auth_service.dart` | ✅ | שירות אימות חדש |
| `firebase_user_repository.dart` | ✅ | Repository ל-Firestore |
| `user_context.dart` | ✅ | עדכון לעבודה עם Firebase |
| `login_screen.dart` | ✅ | התחברות אמיתית |
| `register_screen.dart` | ✅ | רישום אמיתי |
| `demo_login_button.dart` | ✅ | כפתור דמו מעודכן |
| `main.dart` | ✅ | Providers מעודכנים |
| `create_demo_users.js` | ✅ | Script יצירת משתמשים |

---

## 🎯 הצעדים הבאים

1. ✅ הרץ את ה-script ליצירת משתמשים
2. ✅ בדוק התחברות באפליקציה
3. 🔜 הוסף חוקי אבטחה ב-Firestore
4. 🔜 בדוק תרחישי שימוש שונים
5. 🔜 הוסף אימות אימייל (אופציונלי)

---

עודכן: 05/10/2025 | גרסה: 1.0.0
