# 📖 סיכום ארכיטקטורה - Salsheli

> **תאריך:** 05/10/2025  
> **עדכון אחרון:** 05/10/2025  
> **סטטוס:** ✅ Firebase מלא מיושם

---

## 🎯 התשובה הקצרה

**האם הפרויקט עובד?**  
✅ **כן** - האפליקציה פועלת באופן מלא!

**האם Firebase מחובר?**  
✅ **כן!** - Auth, Firestore, Security Rules - הכל עובד!

**איך משתמשים מנוהלים?**  
✅ **Firebase Authentication** - אימות אמיתי + 3 משתמשי דמו

**איך נתונים נשמרים?**  
✅ **Hybrid Storage:**
- Firestore: Receipts, Inventory, Users
- Hive: Products (cache)
- SharedPreferences: Shopping Lists (זמני)

---

## 📱 מה נשמר איפה?

### Hive Database (מקומי)
```
✅ products.hive - 1,778 מוצרים (cache מקומי)
```

### SharedPreferences (מקומי - JSON)
```
✅ userId - מזהה המשתמש
✅ seenOnboarding - האם ראה onboarding
✅ shopping_lists.house_demo - רשימות קניות (זמני)
```

### Firestore (ענן - מסונכרן!)
```
✅ users - פרטי משתמשים
✅ receipts - קבלות (לפי household)
✅ inventory - מלאי (לפי household)
✅ products - 1,778 מוצרים (מקור אמת)
```

---

## 🔄 איך המערכת עובדת

### 1. התחברות משתמש

```
משתמש → LoginScreen
    ↓
UserContext.signIn(email, password)
    ↓
AuthService.signIn() → Firebase Auth
    ↓
authStateChanges listener מזהה שינוי
    ↓
FirebaseUserRepository.fetchUser(uid)
    ↓
UserContext עם נתוני משתמש
    ↓
Navigator → HomeScreen
```

**✅ בטוח!** Firebase Auth + Firestore

---

### 2. טעינת מוצרים (Hybrid)

```
ProductsProvider.initializeAndLoad()
    ↓
HybridProductsRepository
    ├─ נסה: Firestore (1,778 מוצרים)
    ├─ נסה: Local JSON (assets/data/products.json)
    ├─ נסה: API (אם זמין)
    └─ Fallback: products מוכנים
    ↓
שמירה ב-Hive (cache מקומי)
    ↓
ProductsProvider מעודכן
```

**✅ מהיר + אמין!** תמיד יש מוצרים

---

### 3. יצירת קבלה

```
משתמש → ReceiptManagerScreen
    ↓
"הוסף קבלה" → CreateReceiptDialog
    ↓
ReceiptProvider.createReceipt(receipt)
    ↓
FirebaseReceiptRepository.saveReceipt()
    ↓
Firestore: households/{household_id}/receipts/{receipt_id}
    ↓
Security Rules: בדיקת household_id
    ↓
Success → UI מתעדכן
```

**✅ נשמר לצמיתות!** הקבלות בענן

---

### 4. יצירת רשימת קניות

```
משתמש → ShoppingListsScreen
    ↓
"רשימה חדשה" → CreateListDialog
    ↓
ShoppingListsProvider.createList()
    ↓
LocalShoppingListsRepository.saveList()
    ↓
SharedPreferences.setString(key, json)
    ↓
UI מתעדכן
```

**⚠️ מקומי בלבד!** לא מסונכרן בין מכשירים (עדיין)

---

## 🏗️ ארכיטקטורה

```
UI Layer (Screens/Widgets)
    ↓
State Management (Providers - ChangeNotifier)
    ↓
Business Logic (Services)
    ↓
Data Access (Repositories)
    ↓
Data Sources
    ├─ Firebase (Auth, Firestore)
    ├─ Hive (Local NoSQL)
    └─ SharedPreferences (Local JSON)
```

---

## 🔐 Firebase Authentication

### AuthService
```dart
class AuthService {
  // ✅ מיושם
  Future<UserCredential> signIn(email, password);
  Future<UserCredential> signUp(email, password, name);
  Future<void> signOut();
  Future<void> resetPassword(email);
  Stream<User?> get authStateChanges; // Real-time!
}
```

### 👥 משתמשי דמו

| שם | Email | סיסמה | UID |
|----|-------|-------|-----|
| יוני | yoni@demo.com | Demo123! | yoni_demo_user |
| שרה | sarah@demo.com | Demo123! | sarah_demo_user |
| דני | danny@demo.com | Demo123! | danny_demo_user |

כולם ב-`householdId: 'house_demo'`

---

## ☁️ Firestore Collections

### 1. Users
```javascript
users/{userId} {
  id: "user_abc",
  email: "yoni@demo.com",
  name: "יוני",
  household_id: "house_demo",
  joined_at: "2025-10-05T10:00:00Z",
  last_login_at: "2025-10-05T12:00:00Z"
}
```

### 2. Receipts
```javascript
receipts/{receiptId} {
  id: "receipt_123",
  household_id: "house_demo",  // ← Security!
  store_name: "שופרסל",
  date: Timestamp,
  total_amount: 123.45,
  items: [...]
}
```

### 3. Inventory
```javascript
inventory/{itemId} {
  id: "inv_123",
  household_id: "house_demo",  // ← Security!
  product_name: "חלב 3%",
  category: "dairy",
  location: "refrigerator",
  quantity: 3
}
```

### 4. Products
```javascript
products/{productId} {
  barcode: "7290000000001",
  name: "חלב 3%",
  brand: "תנובה",
  category: "dairy",
  price: 7.90,
  store: "שופרסל"
}
```

---

## 🛡️ Security Rules

```javascript
// Receipts & Inventory - רק לפי household
match /receipts/{receiptId} {
  allow read, write: if request.auth != null &&
    get(/databases/$(database)/documents/users/$(request.auth.uid))
      .data.household_id == resource.data.household_id;
}

// Products - קריאה לכולם
match /products/{productId} {
  allow read: if true;
  allow write: if false; // רק Admin SDK
}
```

---

## 📊 Providers & State

### UserContext
```dart
// ✅ Firebase Integration
- User? _firebaseUser
- UserEntity? _user
- Stream authStateChanges
- signIn(), signUp(), signOut()
```

### ProductsProvider (ProxyProvider)
```dart
// ✅ Hybrid Repository
- HybridProductsRepository
  - Firestore → JSON → API → Fallback
- Cache ב-Hive
```

### ReceiptProvider
```dart
// ✅ Firebase Repository
- FirebaseReceiptRepository
- Real-time: watchReceipts()
- CRUD מלא
```

### InventoryProvider
```dart
// ✅ Firebase Repository
- FirebaseInventoryRepository
- Real-time: watchInventory()
- CRUD מלא
```

### ShoppingListsProvider
```dart
// ⚠️ Local Repository (בינתיים)
- LocalShoppingListsRepository
- SharedPreferences
- TODO: העבר ל-Firestore
```

---

## ✅ מה עובד היום

1. ✅ Firebase Authentication מלא
2. ✅ 3 משתמשי דמו מוכנים
3. ✅ Receipts ב-Firestore
4. ✅ Inventory ב-Firestore
5. ✅ Products ב-Firestore + Hive
6. ✅ Security Rules + Indexes
7. ✅ Real-time listeners
8. ✅ Persistent sessions
9. ✅ 21 סוגי רשימות
10. ✅ Active shopping screen
11. ✅ Undo pattern
12. ✅ RTL מלא

---

## 🔄 מה נשאר

### 🔴 קריטי
1. **iOS configuration**
   - הורד `GoogleService-Info.plist`
   - העתק ל-`ios/Runner/`

### 🟡 חשוב
2. **Shopping Lists ל-Firestore**
   - יצירת `FirebaseShoppingListsRepository`
   - Real-time sync
   - Security Rules

3. **Offline Support מלא**
   ```dart
   FirebaseFirestore.instance.settings = Settings(
     persistenceEnabled: true,
     cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED
   );
   ```

### 🟢 עתידי
4. Real-time sync לכל הנתונים
5. Receipt OCR
6. Smart notifications
7. Barcode scanning
8. Price tracking

---

## 🎓 מושגים חשובים

| מונח | משמעות |
|------|---------|
| **Hybrid Repository** | שילוב Local + Cloud + API |
| **ProxyProvider** | Provider שתלוי ב-Provider אחר |
| **authStateChanges** | Real-time listener לשינויי התחברות |
| **household_id** | מזהה בית - לשיתוף בין משתמשים |
| **Security Rules** | כללי אבטחה ב-Firestore |
| **Hive** | מסד נתונים מקומי מהיר |

---

## 📂 קבצים חשובים

```
lib/
├── main.dart                           # אתחול + Firebase
├── firebase_options.dart               # תצורת Firebase
│
├── providers/
│   ├── user_context.dart              # ✅ Firebase Auth
│   ├── receipt_provider.dart          # ✅ Firestore
│   ├── inventory_provider.dart        # ✅ Firestore
│   ├── products_provider.dart         # ✅ Hybrid
│   └── shopping_lists_provider.dart   # ⚠️  Local (זמני)
│
├── repositories/
│   ├── firebase_user_repository.dart     # ✅
│   ├── firebase_receipt_repository.dart  # ✅
│   ├── firebase_inventory_repository.dart # ✅
│   ├── hybrid_products_repository.dart   # ✅
│   └── local_shopping_lists_repository.dart # ⚠️
│
└── services/
    └── auth_service.dart               # ✅ Firebase Auth

android/app/
└── google-services.json                # ✅ קיים

ios/Runner/
└── GoogleService-Info.plist            # ❌ חסר!
```

---

## 🚀 Quick Start

```bash
# 1. התקנה
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# 2. יצירת משתמשי דמו
cd scripts
npm install
npm run create-users

# 3. הרצה
flutter run

# 4. התחברות
# במסך התחברות → "בחר משתמש דמו" → יוני
```

---

## 📊 סטטיסטיקות

| מדד | ערך |
|-----|-----|
| **שורות קוד** | ~15,000 |
| **Providers** | 9 |
| **Repositories** | 14 |
| **Screens** | 25+ |
| **Models** | 12 |
| **Services** | 11 |
| **משתמשי דמו** | 3 |
| **מוצרים** | 1,778 |
| **סוגי רשימות** | 21 |

---

## 🎉 סיכום

**המערכת מוכנה!**
- ✅ Firebase Authentication עובד
- ✅ Firestore עובד
- ✅ Hybrid Storage עובד
- ✅ Security Rules מוגדרים
- ✅ Real-time updates מוכנים
- ⏳ רק חסר iOS configuration

**הצעד הבא:**
1. הורד `GoogleService-Info.plist`
2. העבר Shopping Lists ל-Firestore
3. הפעל Real-time sync

---

**עדכון:** 05/10/2025 | **גרסה:** 2.0 | **סטטוס:** ✅ Production Ready
