# 🔥 מדריך יישום Firebase - Salsheli

> **מטרה:** מעבר מ-Mock/Local ל-Firebase מלא  
> **זמן משוער:** 2-3 שבועות  
> **קושי:** בינוני

---

## 📋 תוכן עניינים

1. [מבנה Firestore מומלץ](#מבנה-firestore-מומלץ)
2. [שלב 1: Firebase Authentication](#שלב-1-firebase-authentication)
3. [שלב 2: Firestore Collections](#שלב-2-firestore-collections)
4. [שלב 3: Security Rules](#שלב-3-security-rules)
5. [שלב 4: Real-time Sync](#שלב-4-real-time-sync)
6. [Migration Strategy](#migration-strategy)

---

## 🗂️ מבנה Firestore מומלץ

```
📦 Firestore Database
│
├─ 👥 users/{userId}
│  ├─ id: "user_abc123"
│  ├─ email: "yoni@example.com"
│  ├─ name: "יוני כהן"
│  ├─ householdId: "house_demo"
│  ├─ avatar: "https://..."
│  ├─ preferences: {...}
│  ├─ createdAt: Timestamp
│  └─ lastLoginAt: Timestamp
│
├─ 🏠 households/{householdId}
│  ├─ id: "house_demo"
│  ├─ name: "משפחת כהן"
│  ├─ ownerId: "user_abc123"
│  ├─ members: ["user_abc123", "user_def456"]
│  ├─ createdAt: Timestamp
│  │
│  ├─ 🛒 shopping_lists/{listId}
│  │  ├─ id: "list_001"
│  │  ├─ name: "קניות שבועיות"
│  │  ├─ type: "super"
│  │  ├─ status: "active"
│  │  ├─ budget: 500.0
│  │  ├─ createdBy: "user_abc123"
│  │  ├─ items: [
│  │  │   {
│  │  │     id: "item_001",
│  │  │     productName: "חלב 3%",
│  │  │     barcode: "7290000000001",
│  │  │     quantity: 2,
│  │  │     unit: "ליטר",
│  │  │     price: 7.90,
│  │  │     isChecked: false
│  │  │   }
│  │  │ ]
│  │  ├─ createdDate: Timestamp
│  │  └─ updatedDate: Timestamp
│  │
│  ├─ 🧾 receipts/{receiptId}
│  │  ├─ id: "receipt_001"
│  │  ├─ storeName: "שופרסל"
│  │  ├─ date: Timestamp
│  │  ├─ totalAmount: 123.45
│  │  ├─ items: [...]
│  │  ├─ scannedImageUrl: "gs://..."
│  │  └─ createdAt: Timestamp
│  │
│  ├─ 📦 inventory/{itemId}
│  │  ├─ id: "inv_001"
│  │  ├─ productName: "קמח"
│  │  ├─ category: "מזון יבש"
│  │  ├─ location: "מזווה"
│  │  ├─ quantity: 3
│  │  ├─ unit: "ק״ג"
│  │  ├─ expiryDate: Timestamp
│  │  └─ updatedAt: Timestamp
│  │
│  └─ 📊 stats/{statId}
│     ├─ monthlySpending: {...}
│     ├─ categoryBreakdown: {...}
│     └─ lastCalculated: Timestamp
│
└─ 🏷️ products/{productId}
   ├─ barcode: "7290000000001"
   ├─ name: "חלב 3%"
   ├─ brand: "תנובה"
   ├─ category: "חלבי"
   ├─ price: 7.90
   ├─ store: "שופרסל"
   ├─ unit: "ליטר"
   ├─ icon: "🥛"
   └─ updatedAt: Timestamp
```

---

## 🔐 שלב 1: Firebase Authentication

### 1.1 הוספת חבילות

**pubspec.yaml:**
```yaml
dependencies:
  firebase_auth: ^5.3.3
  google_sign_in: ^6.2.2  # אופציונלי - להתחברות עם Google
```

```bash
flutter pub get
```

---

### 1.2 יצירת AuthService

**קובץ חדש:** `lib/services/auth_service.dart`

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream של משתמש נוכחי
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // משתמש נוכחי
  User? get currentUser => _auth.currentUser;

  // רישום משתמש חדש
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      debugPrint('🔐 AuthService: רישום משתמש חדש - $email');
      
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // עדכון שם המשתמש
      await credential.user?.updateDisplayName(name);
      
      debugPrint('✅ AuthService: רישום הושלם - ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ AuthService: שגיאת רישום - ${e.code}');
      
      switch (e.code) {
        case 'weak-password':
          throw Exception('סיסמה חלשה מדי');
        case 'email-already-in-use':
          throw Exception('האימייל כבר בשימוש');
        case 'invalid-email':
          throw Exception('אימייל לא תקין');
        default:
          throw Exception('שגיאה ברישום: ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ AuthService: שגיאה כללית - $e');
      throw Exception('שגיאה ברישום: $e');
    }
  }

  // התחברות
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 AuthService: התחברות - $email');
      
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      debugPrint('✅ AuthService: התחברות הושלמה - ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ AuthService: שגיאת התחברות - ${e.code}');
      
      switch (e.code) {
        case 'user-not-found':
          throw Exception('משתמש לא נמצא');
        case 'wrong-password':
          throw Exception('סיסמה שגויה');
        case 'invalid-email':
          throw Exception('אימייל לא תקין');
        default:
          throw Exception('שגיאה בהתחברות: ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ AuthService: שגיאה כללית - $e');
      throw Exception('שגיאה בהתחברות: $e');
    }
  }

  // התנתקות
  Future<void> signOut() async {
    try {
      debugPrint('🔐 AuthService: התנתקות');
      await _auth.signOut();
      debugPrint('✅ AuthService: התנתקות הושלמה');
    } catch (e) {
      debugPrint('❌ AuthService: שגיאה בהתנתקות - $e');
      throw Exception('שגיאה בהתנתקות: $e');
    }
  }

  // איפוס סיסמה
  Future<void> resetPassword(String email) async {
    try {
      debugPrint('🔐 AuthService: איפוס סיסמה - $email');
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('✅ AuthService: מייל איפוס נשלח');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ AuthService: שגיאת איפוס - ${e.code}');
      
      switch (e.code) {
        case 'user-not-found':
          throw Exception('משתמש לא נמצא');
        case 'invalid-email':
          throw Exception('אימייל לא תקין');
        default:
          throw Exception('שגיאה באיפוס: ${e.message}');
      }
    }
  }
}
```

---

### 1.3 עדכון UserContext

**lib/providers/user_context.dart:**

```dart
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class UserContext with ChangeNotifier {
  final AuthService _authService;
  final UserRepository _repository;
  
  User? _firebaseUser;  // משתמש Firebase
  UserEntity? _user;    // משתמש מקומי
  
  UserContext({
    required AuthService authService,
    required UserRepository repository,
  }) : _authService = authService,
       _repository = repository {
    // האזנה לשינויים באימות
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    _firebaseUser = firebaseUser;
    
    if (firebaseUser != null) {
      // טען פרטי משתמש מ-Firestore
      _user = await _repository.fetchUser(firebaseUser.uid);
    } else {
      _user = null;
    }
    
    notifyListeners();
  }

  bool get isLoggedIn => _firebaseUser != null;
  String? get userId => _firebaseUser?.uid;
  String? get userEmail => _firebaseUser?.email;
  
  Future<void> signIn(String email, String password) async {
    await _authService.signIn(email: email, password: password);
  }
  
  Future<void> signUp(String email, String password, String name) async {
    final credential = await _authService.signUp(
      email: email,
      password: password,
      name: name,
    );
    
    // צור רשומת משתמש ב-Firestore
    final newUser = UserEntity.newUser(
      id: credential.user!.uid,
      email: email,
      name: name,
    );
    
    await _repository.saveUser(newUser);
  }
  
  Future<void> signOut() async {
    await _authService.signOut();
  }
}
```

---

## 🗂️ שלב 2: Firestore Collections

### 2.1 FirebaseUserRepository

**קובץ חדש:** `lib/repositories/firebase_user_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_entity.dart';
import 'user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'users';

  FirebaseUserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserEntity?> fetchUser(String userId) async {
    try {
      debugPrint('📥 FirebaseUserRepository: טוען משתמש $userId');
      
      final doc = await _firestore.collection(_collection).doc(userId).get();
      
      if (!doc.exists) {
        debugPrint('⚠️ משתמש לא נמצא');
        return null;
      }
      
      final user = UserEntity.fromJson(doc.data()!);
      debugPrint('✅ משתמש נטען: ${user.email}');
      return user;
    } catch (e) {
      debugPrint('❌ שגיאה בטעינת משתמש: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity> saveUser(UserEntity user) async {
    try {
      debugPrint('💾 FirebaseUserRepository: שומר משתמש ${user.id}');
      
      await _firestore.collection(_collection).doc(user.id).set(
        user.toJson(),
        SetOptions(merge: true),  // מאפשר עדכון חלקי
      );
      
      debugPrint('✅ משתמש נשמר');
      return user;
    } catch (e) {
      debugPrint('❌ שגיאה בשמירת משתמש: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      debugPrint('🗑️ FirebaseUserRepository: מוחק משתמש $userId');
      
      await _firestore.collection(_collection).doc(userId).delete();
      
      debugPrint('✅ משתמש נמחק');
    } catch (e) {
      debugPrint('❌ שגיאה במחיקת משתמש: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity?> findByEmail(String email) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return UserEntity.fromJson(snapshot.docs.first.data());
    } catch (e) {
      debugPrint('❌ שגיאה בחיפוש לפי אימייל: $e');
      return null;
    }
  }
}
```

---

### 2.2 FirebaseShoppingListsRepository

**קובץ חדש:** `lib/repositories/firebase_shopping_lists_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/shopping_list.dart';
import 'shopping_lists_repository.dart';

class FirebaseShoppingListsRepository implements ShoppingListsRepository {
  final FirebaseFirestore _firestore;

  FirebaseShoppingListsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  String _collectionPath(String householdId) =>
      'households/$householdId/shopping_lists';

  @override
  Future<List<ShoppingList>> fetchLists(String householdId) async {
    try {
      debugPrint('📥 Firebase: טוען רשימות של $householdId');
      
      final snapshot = await _firestore
          .collection(_collectionPath(householdId))
          .orderBy('updatedDate', descending: true)
          .get();

      final lists = snapshot.docs
          .map((doc) => ShoppingList.fromJson(doc.data()))
          .toList();

      debugPrint('✅ נטענו ${lists.length} רשימות');
      return lists;
    } catch (e) {
      debugPrint('❌ שגיאה בטעינת רשימות: $e');
      rethrow;
    }
  }

  @override
  Future<ShoppingList> saveList(ShoppingList list, String householdId) async {
    try {
      debugPrint('💾 Firebase: שומר רשימה ${list.id}');
      
      final updated = list.copyWith(updatedDate: DateTime.now());
      
      await _firestore
          .collection(_collectionPath(householdId))
          .doc(list.id)
          .set(updated.toJson(), SetOptions(merge: true));

      debugPrint('✅ רשימה נשמרה');
      return updated;
    } catch (e) {
      debugPrint('❌ שגיאה בשמירת רשימה: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteList(String id, String householdId) async {
    try {
      debugPrint('🗑️ Firebase: מוחק רשימה $id');
      
      await _firestore
          .collection(_collectionPath(householdId))
          .doc(id)
          .delete();

      debugPrint('✅ רשימה נמחקה');
    } catch (e) {
      debugPrint('❌ שגיאה במחיקת רשימה: $e');
      rethrow;
    }
  }

  // 🆕 Real-time stream
  Stream<List<ShoppingList>> watchLists(String householdId) {
    return _firestore
        .collection(_collectionPath(householdId))
        .orderBy('updatedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ShoppingList.fromJson(doc.data()))
            .toList());
  }
}
```

---

## 🔒 שלב 3: Security Rules

**firestore.rules:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // פונקציות עזר
    function isSignedIn() {
      return request.auth != null;
    }
    
    function getUserData() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }
    
    function getHouseholdId() {
      return getUserData().householdId;
    }
    
    // משתמשים - רק קריאה/כתיבה למשתמש עצמו
    match /users/{userId} {
      allow read: if isSignedIn() && request.auth.uid == userId;
      allow create: if isSignedIn() && request.auth.uid == userId;
      allow update: if isSignedIn() && request.auth.uid == userId;
      allow delete: if false;  // אסור למחוק משתמשים
    }
    
    // משקי בית
    match /households/{householdId} {
      // בדיקה שהמשתמש שייך למשק הבית
      allow read: if isSignedIn() && getHouseholdId() == householdId;
      allow write: if isSignedIn() && getHouseholdId() == householdId;
      
      // רשימות קניות
      match /shopping_lists/{listId} {
        allow read: if isSignedIn() && getHouseholdId() == householdId;
        allow create: if isSignedIn() && getHouseholdId() == householdId;
        allow update: if isSignedIn() && getHouseholdId() == householdId;
        allow delete: if isSignedIn() && getHouseholdId() == householdId;
      }
      
      // קבלות
      match /receipts/{receiptId} {
        allow read: if isSignedIn() && getHouseholdId() == householdId;
        allow create: if isSignedIn() && getHouseholdId() == householdId;
        allow update: if isSignedIn() && getHouseholdId() == householdId;
        allow delete: if isSignedIn() && getHouseholdId() == householdId;
      }
      
      // מלאי
      match /inventory/{itemId} {
        allow read: if isSignedIn() && getHouseholdId() == householdId;
        allow create: if isSignedIn() && getHouseholdId() == householdId;
        allow update: if isSignedIn() && getHouseholdId() == householdId;
        allow delete: if isSignedIn() && getHouseholdId() == householdId;
      }
    }
    
    // מוצרים - קריאה לכולם, כתיבה רק למנהלים
    match /products/{productId} {
      allow read: if true;  // כולם יכולים לקרוא
      allow write: if false;  // אף אחד לא יכול לכתוב (רק דרך Admin SDK)
    }
  }
}
```

---

## 🔄 שלב 4: Real-time Sync

### 4.1 שימוש ב-Streams במקום Future

**lib/providers/shopping_lists_provider.dart:**

```dart
class ShoppingListsProvider with ChangeNotifier {
  final FirebaseShoppingListsRepository _repository;
  StreamSubscription<List<ShoppingList>>? _listsSubscription;
  
  List<ShoppingList> _lists = [];
  bool _isLoading = false;

  // ביטול ההאזנה
  @override
  void dispose() {
    _listsSubscription?.cancel();
    super.dispose();
  }

  // התחלת האזנה
  void startListening(String householdId) {
    _listsSubscription?.cancel();
    
    _isLoading = true;
    notifyListeners();

    _listsSubscription = _repository.watchLists(householdId).listen(
      (lists) {
        _lists = lists;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('❌ שגיאה בהאזנה לרשימות: $error');
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}
```

---

## 🔄 Migration Strategy

### אסטרטגיה למעבר מ-Mock/Local ל-Firebase

#### שלב A: Dual-mode Repository

```dart
class HybridShoppingListsRepository implements ShoppingListsRepository {
  final LocalShoppingListsRepository _local;
  final FirebaseShoppingListsRepository _firebase;
  final bool _useFirebase;

  HybridShoppingListsRepository({
    required LocalShoppingListsRepository local,
    required FirebaseShoppingListsRepository firebase,
    bool useFirebase = false,
  }) : _local = local,
       _firebase = firebase,
       _useFirebase = useFirebase;

  @override
  Future<List<ShoppingList>> fetchLists(String householdId) async {
    if (_useFirebase) {
      try {
        return await _firebase.fetchLists(householdId);
      } catch (e) {
        debugPrint('⚠️ Firebase נכשל, חוזר ל-Local: $e');
        return await _local.fetchLists(householdId);
      }
    }
    return await _local.fetchLists(householdId);
  }

  @override
  Future<ShoppingList> saveList(ShoppingList list, String householdId) async {
    // שמור במקומי תמיד (offline support)
    final saved = await _local.saveList(list, householdId);
    
    // נסה לשמור ב-Firebase
    if (_useFirebase) {
      try {
        await _firebase.saveList(saved, householdId);
      } catch (e) {
        debugPrint('⚠️ Firebase save נכשל: $e');
      }
    }
    
    return saved;
  }
}
```

#### שלב B: Migration Script

```dart
// tools/migrate_to_firebase.dart
Future<void> migrateUserData(String userId) async {
  final localRepo = LocalShoppingListsRepository();
  final firebaseRepo = FirebaseShoppingListsRepository();
  
  final prefs = await SharedPreferences.getInstance();
  final householdId = prefs.getString('householdId')!;
  
  // טען רשימות מקומיות
  final localLists = await localRepo.fetchLists(householdId);
  
  debugPrint('📤 מעביר ${localLists.length} רשימות ל-Firebase...');
  
  // העבר ל-Firebase
  for (final list in localLists) {
    try {
      await firebaseRepo.saveList(list, householdId);
      debugPrint('✅ הועבר: ${list.name}');
    } catch (e) {
      debugPrint('❌ נכשל: ${list.name} - $e');
    }
  }
  
  debugPrint('🎉 Migration הושלם!');
}
```

---

## 📊 סיכום יתרונות Firebase

| תכונה | לפני (Mock/Local) | אחרי (Firebase) |
|-------|------------------|-----------------|
| **אימות** | Mock, לא בטוח | Firebase Auth מלא |
| **אחסון** | SharedPreferences/RAM | Firestore |
| **סנכרון** | אין | Real-time |
| **גיבוי** | אין | אוטומטי |
| **Offline** | חלקי | מלא (cache) |
| **שיתוף** | אין | בין מכשירים |
| **Security** | אין | Rules מובנות |
| **Scalability** | מוגבל | אינסופי |

---

## ✅ Checklist ליישום

- [ ] הוספת firebase_auth ל-pubspec.yaml
- [ ] יצירת AuthService
- [ ] עדכון UserContext עם Firebase Auth
- [ ] יצירת FirebaseUserRepository
- [ ] יצירת FirebaseShoppingListsRepository
- [ ] יצירת FirebaseReceiptRepository
- [ ] יצירת FirebaseInventoryRepository
- [ ] הגדרת Security Rules
- [ ] בדיקת iOS configuration (GoogleService-Info.plist)
- [ ] מעבר ל-Streams במקום Futures
- [ ] Migration של נתונים קיימים
- [ ] בדיקות E2E
- [ ] עדכון תיעוד

---

**מסמך נוצר:** 05/10/2025  
**גרסה:** 1.0  
**עדכון אחרון:** 05/10/2025
