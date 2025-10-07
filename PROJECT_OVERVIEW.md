# 📊 סקירת פרויקט Salsheli - מסמך עדכני מלא

> **תאריך:** 06/10/2025  
> **גרסה:** 1.0.0+1  
> **סטטוס:** ✅ Production Ready (למעט iOS configuration)

---

## 📱 מה זה Salsheli?

**אפליקציית Flutter מובייל** (Android & iOS) לניהול חכם של קניות, מזווה וקבלות עם שיתוף משפחתי.

### 🎯 המטרה

לפשט את החיים - מרשימת קניות ועד מעקב מלאי ותובנות כלכליות, הכל במקום אחד.

---

## ✨ פיצ'רים מרכזיים

### 🛒 רשימות קניות חכמות

- **21 סוגי רשימות** - סופר, פארם, ביגוד, משחקים, ועוד
- **תבניות מוכנות** - סופרמרקט, קנייה שבועית, ארוחה מיוחדת
- **קנייה פעילה** - מסך ליווי בזמן הקנייה
- **שיתוף משפחתי** - household_id מאפשר עבודה משותפת

### 🏠 ניהול מלאי חכם

- **10 מיקומי אחסון** - מזווה, מקרר, מקפיא, משטח, ועוד
- **מיקומים מותאמים** - הוסף מיקומים משלך
- **התראות חכמות** - מוצרים נמוכים/חסרים
- **ניהול תפוגה** - מעקב תאריכי תפוגה

### 🧾 קבלות ומחירים

- **שמירת קבלות** - מסד נתונים ב-Firestore
- **מעקב הוצאות** - סיכום חודשי ושנתי
- **השוואת מחירים** - בין חנויות שונות
- **OCR עתידי** - סריקת קבלות אוטומטית

### 📊 תובנות וסטטיסטיקות

- **הוצאות חודשיות** - תרשימים ומגמות
- **קטגוריות מובילות** - היכן הכסף הולך
- **דיוק רשימות** - כמה קניתי לפי הרשימה
- **הצעות חכמות** - על סמך היסטוריה

---

## 🏗️ ארכיטקטורה

### מבנה שכבות

```
┌─────────────────────────────────────────┐
│          UI Layer                       │
│  Screens, Widgets, Theme                │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│    State Management (Provider)          │
│  ChangeNotifier, ProxyProvider          │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│        Business Logic (Services)        │
│  AuthService, StatsService, etc.        │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│      Data Access (Repositories)         │
│  Firebase, Hive, SharedPreferences      │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│           Data Sources                  │
│  Firestore | Hive | SharedPrefs | API   │
└─────────────────────────────────────────┘
```

### עקרונות תכנון

1. **הפרדת אחריות** - כל שכבה ממוקדת בתפקיד אחד
2. **Dependency Injection** - דרך Provider system
3. **Repository Pattern** - הפשטה של גישה לנתונים
4. **Reactive State** - ChangeNotifier + Consumer
5. **Immutability** - Models עם `final` fields
6. **Type Safety** - שימוש ב-`@JsonSerializable`

---

## 🔧 טכנולוגיות ותלויות

### Core Framework

- **Flutter** - UI Framework
- **Dart 3.8.1+** - שפת תכנות
- **Material Design** - עיצוב UI

### State Management

- **Provider 6.1.2** - State management מומלץ
- **ChangeNotifier** - Reactive updates
- **ProxyProvider** - תלויות בין Providers

### Backend & Storage

- **Firebase Core 3.15.2** - פלטפורמה בענן
- **Firebase Auth 5.7.0** - אימות משתמשים
- **Cloud Firestore 5.4.4** - מסד נתונים בענן
- **Hive 2.2.3** - NoSQL מקומי מהיר
- **SharedPreferences 2.2.0** - אחסון קטן מקומי

### Serialization & Code Gen

- **json_annotation 4.9.0** - Annotations
- **json_serializable 6.8.0** - JSON ↔ Dart
- **build_runner 2.4.13** - Code generation
- **hive_generator 2.0.1** - Hive adapters

### UI & Animations

- **flutter_animate 4.5.0** - אנימציות
- **font_awesome_flutter 10.7.0** - אייקונים
- **fl_chart 0.69.0** - תרשימים

### Utilities

- **intl 0.20.2** - i18n + תאריכים
- **timeago 3.7.0** - "לפני 5 דקות"
- **http 1.2.2** - HTTP requests
- **xml 6.6.1** - פענוח XML
- **archive 4.0.7** - פענוח GZ
- **uuid 4.5.0** - מזהים ייחודיים

### Hardware Access

- **camera 0.11.0+2** - גישה למצלמה
- **image_picker 1.1.2** - בחירת תמונות
- **mobile_scanner 3.5.7** - סריקת ברקוד
- **path_provider 2.1.4** - נתיבי קבצים

---

## 📂 מבנה התיקיות המפורט

```
C:\projects\salsheli\
│
├── lib/                              # קוד ראשי
│   ├── main.dart                     # ✅ Entry point + Firebase init
│   ├── firebase_options.dart         # ✅ Firebase configuration
│   │
│   ├── api/                          # API entities
│   │   └── entities/                 # @JsonSerializable models
│   │       ├── user.dart + .g.dart
│   │       └── shopping_list.dart + .g.dart
│   │
│   ├── config/                       # Configuration
│   │   ├── category_config.dart      # קטגוריות + צבעים
│   │   ├── filters_config.dart       # פילטרים (kCategories, kStatuses)
│   │   └── list_type_mappings.dart   # מיפוי סוגי רשימות
│   │
│   ├── core/                         # Constants
│   │   ├── constants.dart            # קבועים גלובליים
│   │   └── ui_constants.dart         # קבועי UI (kSpacing, kBorderRadius)
│   │
│   ├── data/                         # Demo & sample data
│   │   └── onboarding_data.dart      # נתוני onboarding
│   │
│   ├── l10n/                         # Localization
│   │   └── app_strings.dart          # מחרוזות באפליקציה
│   │
│   ├── layout/                       # App layout
│   │   └── app_layout.dart           # Bottom navigation + scaffold
│   │
│   ├── models/                       # Data models
│   │   ├── user_entity.dart + .g.dart
│   │   ├── shopping_list.dart + .g.dart
│   │   ├── receipt.dart + .g.dart
│   │   ├── inventory_item.dart + .g.dart
│   │   ├── suggestion.dart + .g.dart
│   │   ├── product_entity.dart + .g.dart  # Hive
│   │   ├── custom_location.dart + .g.dart
│   │   └── enums/
│   │       └── shopping_item_status.dart
│   │
│   ├── providers/                    # State management (7 providers)
│   │   ├── user_context.dart         # 👤 User + Firebase Auth
│   │   ├── shopping_lists_provider.dart # 🛒 Lists (Firebase!)
│   │   ├── receipt_provider.dart     # 🧾 Receipts (Firebase!)
│   │   ├── inventory_provider.dart   # 📦 Inventory (Firebase!)
│   │   ├── products_provider.dart    # 🔀 Products (Hybrid)
│   │   ├── suggestions_provider.dart # 💡 Smart suggestions
│   │   └── locations_provider.dart   # 📍 Storage locations
│   │
│   ├── repositories/                 # Data access (13 repositories)
│   │   ├── user_repository.dart              # Interface
│   │   ├── firebase_user_repository.dart     # ✅ Firebase
│   │   ├── firebase_receipt_repository.dart  # ✅ Firebase
│   │   ├── firebase_inventory_repository.dart # ✅ Firebase
│   │   ├── firebase_shopping_list_repository.dart # ✅ Firebase
│   │   ├── firebase_products_repository.dart # ✅ Firebase (1,758 מוצרים)
│   │   ├── hybrid_products_repository.dart   # 🔀 Local + Firebase + API
│   │   ├── local_products_repository.dart    # Hive
│   │   ├── local_shopping_lists_repository.dart # SharedPreferences
│   │   └── ... (interfaces)
│   │
│   ├── services/                     # Business logic (11 services)
│   │   ├── auth_service.dart         # 🔐 Firebase Authentication
│   │   ├── home_stats_service.dart   # 📊 Statistics
│   │   ├── shufersal_prices_service.dart # API מחירים
│   │   ├── receipt_service.dart      # Receipt processing
│   │   ├── onboarding_service.dart   # Onboarding logic
│   │   └── ... (more services)
│   │
│   ├── screens/                      # UI screens (25+ screens)
│   │   ├── auth/
│   │   │   ├── login_screen.dart     # 🔐 התחברות
│   │   │   └── register_screen.dart  # 📝 הרשמה
│   │   ├── home/
│   │   │   ├── home_screen.dart      # 🏠 מסך ראשי
│   │   │   └── home_dashboard_screen.dart # Dashboard
│   │   ├── shopping/
│   │   │   ├── shopping_lists_screen.dart # רשימות
│   │   │   ├── active_shopping_screen.dart # קנייה פעילה
│   │   │   ├── manage_list_screen.dart # ניהול רשימה
│   │   │   └── ... (7 מסכים נוספים)
│   │   ├── receipts/
│   │   │   ├── receipt_manager_screen.dart
│   │   │   └── receipt_view_screen.dart
│   │   ├── pantry/
│   │   │   └── my_pantry_screen.dart # מלאי
│   │   ├── insights/
│   │   │   └── insights_screen.dart  # תובנות
│   │   ├── settings/
│   │   │   └── settings_screen.dart  # הגדרות
│   │   ├── onboarding/
│   │   │   └── onboarding_screen.dart
│   │   └── ... (more screens)
│   │
│   ├── widgets/                      # Reusable components (30+ widgets)
│   │   ├── auth/
│   │   │   ├── auth_button.dart
│   │   │   └── demo_login_button.dart
│   │   ├── home/
│   │   │   ├── active_lists_card.dart
│   │   │   ├── smart_suggestions_card.dart
│   │   │   └── upcoming_shop_card.dart
│   │   ├── common/
│   │   │   ├── dashboard_card.dart
│   │   │   └── benefit_tile.dart
│   │   └── ... (many more)
│   │
│   ├── theme/                        # App theming
│   │   └── app_theme.dart            # Light + Dark themes
│   │
│   └── utils/                        # Utilities
│       ├── toast.dart                # Toast notifications
│       └── color_hex.dart            # Color helpers
│
├── android/                          # Android configuration
│   └── app/
│       └── google-services.json      # ✅ Firebase config
│
├── ios/                              # iOS configuration
│   └── Runner/
│       └── GoogleService-Info.plist  # ❌ חסר!
│
├── assets/                           # Assets
│   ├── data/
│   │   └── products.json             # 100+ מוצרים (fallback)
│   ├── fonts/
│   │   ├── Assistant-Regular.ttf
│   │   └── Assistant-Bold.ttf
│   ├── images/                       # תמונות
│   └── templates/                    # Templates
│
├── scripts/                          # Node.js scripts
│   ├── create_users.js               # יצירת משתמשי דמו
│   ├── upload_products.js            # העלאת מוצרים ל-Firestore
│   └── fetch_shufersal_products.dart # שליפת מחירים
│
├── docs/                             # תיעוד
│   └── ... (documentation files)
│
├── WORK_LOG.md                       # 📓 יומן עבודה (47 רשומות!)
├── CLAUDE_GUIDELINES.md              # 🤖 הוראות ל-AI
├── MOBILE_GUIDELINES.md              # 📱 הנחיות Flutter
├── CODE_REVIEW_CHECKLIST.md          # ✅ Checklist
├── ARCHITECTURE_SUMMARY.md           # 🏗️ סיכום ארכיטקטורה
├── README.md                         # 📖 README ראשי
│
├── pubspec.yaml                      # תלויות Flutter
├── analysis_options.yaml             # Dart linting
├── firebase.json                     # Firebase config
├── firestore.rules                   # 🛡️ Security rules
└── firestore.indexes.json            # Firestore indexes

```

---

## 🔥 Firebase Integration - מפורט

### Authentication (Firebase Auth 5.7.0)

```dart
// AuthService - wrapper ל-Firebase Auth
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // התחברות
  Future<UserCredential> signIn(String email, String password);

  // הרשמה
  Future<UserCredential> signUp(String email, String password, String name);

  // יציאה
  Future<void> signOut();

  // איפוס סיסמה
  Future<void> resetPassword(String email);

  // Real-time listener
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // משתמש נוכחי
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => currentUser?.uid;
}
```

**✅ יתרונות:**

- Persistent sessions - המשתמש נשאר מחובר
- Real-time updates - authStateChanges
- Security - סיסמאות מוצפנות
- Reset password - איפוס דרך email

### Firestore Collections

#### 1. Users Collection

```javascript
users/{userId}
{
  id: "user_abc123",
  email: "yoni@demo.com",
  name: "יוני",
  household_id: "house_demo",  // ← שיתוף משפחתי!
  joined_at: "2025-10-05T10:00:00Z",
  last_login_at: "2025-10-06T09:30:00Z"
}
```

#### 2. Receipts Collection

```javascript
receipts/{receiptId}
{
  id: "receipt_20251006_001",
  household_id: "house_demo",  // ← Security!
  user_id: "user_abc123",
  store_name: "שופרסל",
  store_location: "ראשון לציון",
  date: Timestamp(2025, 10, 6),
  total_amount: 456.78,
  items: [
    {
      name: "חלב 3%",
      quantity: 2,
      price: 7.90,
      category: "dairy"
    },
    // ...
  ],
  created_at: Timestamp,
  updated_at: Timestamp
}
```

#### 3. Inventory Collection

```javascript
inventory/{itemId}
{
  id: "inv_milk_001",
  household_id: "house_demo",  // ← Security!
  product_name: "חלב 3%",
  category: "dairy",
  location: "refrigerator",
  quantity: 3,
  expiry_date: "2025-10-15",
  added_at: Timestamp,
  updated_at: Timestamp
}
```

#### 4. Products Collection

```javascript
products/{productId}
{
  barcode: "7290000000001",
  name: "חלב 3% תנובה 1 ליטר",
  brand: "תנובה",
  category: "dairy",
  price: 7.90,
  store: "שופרסל",
  last_updated: Timestamp
}
```

**📊 סטטיסטיקה:** 1,758 מוצרים ב-Firestore!

### Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users - רק קריאה/עדכון עצמי
    match /users/{userId} {
      allow read, write: if request.auth != null &&
                           request.auth.uid == userId;
    }

    // Receipts - רק לפי household
    match /receipts/{receiptId} {
      allow read: if request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid))
          .data.household_id == resource.data.household_id;

      allow write: if request.auth != null &&
        request.resource.data.household_id ==
        get(/databases/$(database)/documents/users/$(request.auth.uid))
          .data.household_id;
    }

    // Inventory - רק לפי household
    match /inventory/{itemId} {
      allow read: if request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid))
          .data.household_id == resource.data.household_id;

      allow write: if request.auth != null &&
        request.resource.data.household_id ==
        get(/databases/$(database)/documents/users/$(request.auth.uid))
          .data.household_id;
    }

    // Products - קריאה לכולם, כתיבה רק ל-Admin
    match /products/{productId} {
      allow read: if true;
      allow write: if false;  // רק Admin SDK
    }
  }
}
```

**🛡️ עקרונות אבטחה:**

1. Authentication required - רק משתמשים מחוברים
2. Household isolation - כל משתמש רואה רק את הבית שלו
3. Read-only products - מוצרים נגישים לכולם, לא ניתנים לשינוי
4. User ownership - משתמש יכול לעדכן רק את הפרופיל שלו

### Firestore Indexes

```json
{
  "indexes": [
    {
      "collectionGroup": "receipts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "household_id", "order": "ASCENDING" },
        { "fieldPath": "date", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "inventory",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "household_id", "order": "ASCENDING" },
        { "fieldPath": "category", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "shopping_lists",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "household_id", "order": "ASCENDING" },
        { "fieldPath": "updated_date", "order": "DESCENDING" }
      ]
    }
  ]
}
```

**⚡ למה Indexes חשובים?**

- שאילתות מורכבות (where + orderBy) דורשות composite index
- משפרים ביצועים דרמטית
- Firebase מזהה אוטומטית indexes חסרים בזמן שאילתה

---

## 📦 State Management - מפורט

### Provider Hierarchy

```dart
MultiProvider(
  providers: [
    // 1. Services
    Provider<AuthService>(),

    // 2. Repositories
    Provider<UserRepository>(),

    // 3. User Context (תלוי ב-Auth + Repository)
    ChangeNotifierProxyProvider2<AuthService, UserRepository, UserContext>(),

    // 4. Data Providers (תלויים ב-UserContext)
    ChangeNotifierProxyProvider<UserContext, ProductsProvider>(),
    ChangeNotifierProxyProvider<UserContext, ShoppingListsProvider>(),
    ChangeNotifierProxyProvider<UserContext, InventoryProvider>(),
    ChangeNotifierProxyProvider<UserContext, ReceiptProvider>(),

    // 5. Computed Providers (תלויים בdata providers)
    ChangeNotifierProxyProvider2<InventoryProvider,
                                  ShoppingListsProvider,
                                  SuggestionsProvider>(),

    // 6. UI Providers
    ChangeNotifierProvider<LocationsProvider>(),
  ],
)
```

### Providers מפורטים

#### 1. UserContext

```dart
// ✅ Firebase Authentication integration
class UserContext with ChangeNotifier {
  final UserRepository _repository;
  final AuthService _authService;

  UserEntity? _user;
  User? _firebaseUser;

  // Real-time listener
  StreamSubscription? _authSubscription;

  UserContext({required repository, required authService}) {
    _authSubscription = _authService.authStateChanges.listen((firebaseUser) {
      _firebaseUser = firebaseUser;
      if (firebaseUser != null) {
        _loadUserFromFirestore(firebaseUser.uid);
      } else {
        _user = null;
      }
      notifyListeners();
    });
  }

  // Getters
  bool get isLoggedIn => _firebaseUser != null;
  UserEntity? get user => _user;
  String? get userId => _user?.id;
  String? get householdId => _user?.householdId;

  // Methods
  Future<void> signIn(String email, String password);
  Future<void> signUp(String email, String password, String name);
  Future<void> signOut();
}
```

**✅ למה ProxyProvider?**

- מקשיב לשינויים ב-AuthService
- מעדכן אוטומטית כש-authStateChanges משתנה
- מטעין נתוני משתמש מ-Firestore

#### 2. ProductsProvider (Hybrid!)

```dart
// 🔀 Hybrid Repository - Local + Firebase + API
class ProductsProvider with ChangeNotifier {
  final HybridProductsRepository _repository;

  List<ProductEntity> _products = [];
  bool _hasInitialized = false;

  // Constructor with skipInitialLoad
  ProductsProvider({
    required repository,
    bool skipInitialLoad = false,
  }) {
    if (!skipInitialLoad) {
      initializeAndLoad();
    }
  }

  // אתחול + טעינה
  Future<void> initializeAndLoad() async {
    if (_hasInitialized) return;

    debugPrint('🏗️ ProductsProvider: מאתחל ו-טוען מוצרים...');

    await _repository.initialize();
    _products = await _repository.getAllProducts();

    _hasInitialized = true;
    debugPrint('✅ ProductsProvider: נטענו ${_products.length} מוצרים');
    notifyListeners();
  }

  // Getters
  List<ProductEntity> get products => _products;
  int get totalProducts => _products.length;
  bool get hasInitialized => _hasInitialized;
}
```

**🔀 HybridProductsRepository Flow:**

```
1. נסה: Firestore (1,758 מוצרים)
   └─ אם הצליח → cache ב-Hive + return
2. נסה: Local JSON (assets/data/products.json)
   └─ אם הצליח → cache ב-Hive + return
3. נסה: Shufersal API
   └─ אם הצליח → cache ב-Hive + return
4. Fallback: products מוכנים מראש
```

#### 3. ReceiptProvider

```dart
// 🧾 Receipts ב-Firestore
class ReceiptProvider with ChangeNotifier {
  final FirebaseReceiptRepository _repository;
  final UserContext _userContext;

  List<Receipt> _receipts = [];
  bool _isLoading = false;

  // Real-time listener
  Future<void> startListening() async {
    if (_userContext.householdId == null) return;

    _repository.watchReceipts(_userContext.householdId!).listen((receipts) {
      _receipts = receipts;
      notifyListeners();
    });
  }

  // CRUD operations
  Future<void> createReceipt(Receipt receipt);
  Future<void> updateReceipt(Receipt receipt);
  Future<void> deleteReceipt(String receiptId);
}
```

#### 4. ShoppingListsProvider

```dart
// 📋 Shopping Lists ב-Firebase!
class ShoppingListsProvider with ChangeNotifier {
  final FirebaseShoppingListRepository _repository;

  List<ShoppingList> _lists = [];
  UserContext? _userContext;

  // מעדכן את ה-UserContext
  void updateUserContext(UserContext userContext) {
    _userContext = userContext;
    if (userContext.isLoggedIn) {
      loadLists();
    }
  }

  // טעינת רשימות
  Future<void> loadLists() async {
    if (_userContext?.householdId == null) return;

    _lists = await _repository.fetchLists(_userContext!.householdId!);
    notifyListeners();
  }
}
```

---

## 💾 אחסון נתונים - Hybrid Strategy

### סטרטגיה כוללת

```
┌─────────────────────────────────────────┐
│         Firebase Firestore              │
│  - Users (profiles)                     │
│  - Receipts (1 household)               │
│  - Inventory (1 household)              │
│  - Products (1,758 source of truth)     │
└──────────────┬──────────────────────────┘
               │
               │ Sync
               ▼
┌─────────────────────────────────────────┐
│           Hive Database                 │
│  - Products (cache מהיר)                │
│  - 1,778 מוצרים מקומיים                 │
└──────────────┬──────────────────────────┘
               │
               │ Fallback
               ▼
┌─────────────────────────────────────────┐
│       SharedPreferences                 │
│  - userId                               │
│  - seenOnboarding                       │
│  - Shopping Lists (זמני!)               │
└─────────────────────────────────────────┘
```

### מה נשמר איפה?

| נתון               | Firestore | Hive     | SharedPreferences |
| ------------------ | --------- | -------- | ----------------- |
| **Users**          | ✅ Source | ❌       | ❌                |
| **Receipts**       | ✅ Source | ❌       | ❌                |
| **Inventory**      | ✅ Source | ❌       | ❌                |
| **Products**       | ✅ Source | ✅ Cache | ❌                |
| **Shopping Lists** | ✅ עתידי  | ❌       | ✅ זמני           |
| **userId**         | ❌        | ❌       | ✅                |
| **seenOnboarding** | ❌        | ❌       | ✅                |

### למה Hybrid?

**יתרונות:**

1. **מהירות** - Hive מהיר מאוד (NoSQL מקומי)
2. **Offline** - עובד בלי אינטרנט
3. **Sync** - Firestore מסנכרן בין מכשירים
4. **Reliability** - תמיד יש fallback

**אסטרטגיה:**

- **Firestore** = Source of truth
- **Hive** = Cache מהיר למוצרים
- **SharedPreferences** = הגדרות + temporary data

---

## 🎨 UI/UX Design

### Theme System

**2 Themes מלאים:**

- **Light Theme** - צבעים בהירים
- **Dark Theme** - צבעים כהים
- **System Theme** - אוטומטי לפי המכשיר

```dart
// AppTheme.lightTheme
ThemeData(
  colorScheme: ColorScheme.light(
    primary: Color(0xFF2196F3),    // כחול
    secondary: Color(0xFFFFC107),  // צהוב
    surface: Color(0xFFF5F5F5),    // אפור בהיר
  ),
  // ... more
)

// AppTheme.darkTheme
ThemeData(
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF64B5F6),    // כחול בהיר
    secondary: Color(0xFFFFD54F),  // צהוב בהיר
    surface: Color(0xFF1E1E1E),    // אפור כהה
  ),
  // ... more
)
```

### RTL Support מלא

```dart
// Localization
MaterialApp(
  locale: const Locale('he', 'IL'),
  supportedLocales: [Locale('he', 'IL')],
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
)

// Padding symmetric (תומך RTL)
padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)

// לא:
padding: EdgeInsets.only(left: 16, right: 8) // ❌ לא RTL
```

### UI Constants

```dart
// lib/core/ui_constants.dart
const kSpacingSmall = 8.0;
const kSpacingMedium = 16.0;
const kSpacingLarge = 24.0;
const kButtonHeight = 48.0;
const kBorderRadius = 12.0;
const kBorderRadiusSmall = 8.0;
const kBorderRadiusLarge = 20.0;
const kIconSize = 24.0;
const kBorderWidth = 1.0;
```

### Touch Targets

- **מינימום 48x48 dp** - תקן Material Design
- **כפתורים:** 48x48 מינימום
- **אייקונים:** 24x24 רגילים
- **Padding:** symmetric לRTL

---

## 👥 משתמשי דמו

### 3 משתמשים מוכנים

| שם       | Email          | סיסמה    | UID             | householdId |
| -------- | -------------- | -------- | --------------- | ----------- |
| **יוני** | yoni@demo.com  | Demo123! | yoni_demo_user  | house_demo  |
| **שרה**  | sarah@demo.com | Demo123! | sarah_demo_user | house_demo  |
| **דני**  | danny@demo.com | Demo123! | danny_demo_user | house_demo  |

**כולם ב-household_id: `house_demo`** → שיתוף נתונים!

### יצירת משתמשים

```bash
cd scripts
npm install
npm run create-users
```

**מה זה עושה:**

1. מתחבר ל-Firebase Admin SDK
2. יוצר 3 משתמשים ב-Firebase Auth
3. יוצר מסמכים ב-Firestore users collection
4. מדפיס UID של כל משתמש

---

## 📊 נתונים ודמו

### מוצרים

- **1,778 מוצרים** ב-Hive (cache)
- **1,758 מוצרים** ב-Firestore (source)
- **100+ מוצרים** ב-JSON (fallback)

### רשימות קניות (דמו)

- **7 רשימות זמינות** (SharedPreferences)
- **21 סוגי רשימות** (categories)

### קבלות (דמו)

- **3 קבלות** ב-Firestore
- עם פריטים אמיתיים
- תאריכים שונים

### מלאי (דמו)

- **פריטי מזווה** - 15 פריטים
- **מקרר** - 8 פריטים
- **מקפיא** - 5 פריטים

---

## 🚀 התקנה והרצה

### דרישות מקדימות

```bash
# בדוק גרסאות
flutter --version  # Flutter SDK
dart --version     # Dart 3.8.1+
node --version     # Node.js (לסקריפטים)
```

### שלבי התקנה

```bash
# 1. Clone הפרויקט
git clone https://github.com/your-username/salsheli.git
cd salsheli

# 2. התקנת תלויות Flutter
flutter pub get

# 3. יצירת קוד (json_serializable + hive_generator)
dart run build_runner build --delete-conflicting-outputs

# 4. יצירת משתמשי דמו (Firebase)
cd scripts
npm install
npm run create-users
cd ..

# 5. הרצת האפליקציה
flutter run

# או - build לייצור
flutter build apk --release           # Android APK
flutter build appbundle --release     # Google Play
flutter build ios --release           # iOS
```

### ⚠️ iOS Configuration

**חסר:** `ios/Runner/GoogleService-Info.plist`

```bash
# אופציה 1: FlutterFire CLI (מומלץ)
dart pub global activate flutterfire_cli
flutterfire configure

# אופציה 2: ידני
# 1. כנס ל: https://console.firebase.google.com
# 2. בחר Project: salsheli
# 3. לחץ על אייקון iOS
# 4. הורד את GoogleService-Info.plist
# 5. העתק ל: ios/Runner/GoogleService-Info.plist
```

**בלי הקובץ הזה, האפליקציה לא תעבוד על iOS!**

---

## ✅ מה עובד היום?

### 🟢 פועל מלא

- ✅ Firebase Authentication (Email/Password)
- ✅ 3 משתמשי דמו מוכנים
- ✅ Receipts ב-Firestore (Real-time!)
- ✅ Inventory ב-Firestore (Real-time!)
- ✅ Products ב-Firestore (1,758 מוצרים)
- ✅ Hybrid Repository (Firestore + Hive + JSON)
- ✅ Security Rules מלאים
- ✅ Firestore Indexes
- ✅ 21 סוגי רשימות
- ✅ Active Shopping Screen
- ✅ Undo Pattern בכל המערכת
- ✅ RTL מלא
- ✅ Dark/Light Themes
- ✅ Persistent sessions

### 🟡 עובד חלקית

- ⚠️ Shopping Lists - SharedPreferences (זמני)

  - עובד מקומית בלבד
  - לא מסונכרן בין מכשירים
  - TODO: העברה ל-Firestore

- ⚠️ iOS - חסר GoogleService-Info.plist
  - Android עובד מלא ✅
  - iOS צריך configuration

### 🔴 לא מיושם

- ❌ Receipt OCR - סריקת קבלות אוטומטית
- ❌ Smart Notifications - התראות חכמות
- ❌ Real-time Collaborative Shopping
- ❌ Price Tracking מתקדם
- ❌ Tests (Unit/Widget/Integration)

---

## 📈 TODO & Roadmap

### 🔴 קריטי (גבוה)

1. **iOS Configuration**

   - הורדת GoogleService-Info.plist
   - העתקה ל-ios/Runner/
   - בדיקת build על iOS

2. **Shopping Lists ל-Firestore**

   - יצירת FirebaseShoppingListRepository
   - Real-time sync
   - Security Rules לrules לrules
   - Migration מ-SharedPreferences

3. **Offline Support מלא**
   ```dart
   FirebaseFirestore.instance.settings = Settings(
     persistenceEnabled: true,
     cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED
   );
   ```

### 🟡 בינוני (חשוב)

4. **Receipt OCR**

   - שימוש ב-ML Kit או Google Vision
   - זיהוי טקסט מתמונות קבלות
   - פרסור אוטומטי לפריטים

5. **Smart Notifications**

   - Firebase Cloud Messaging
   - התראות על תפוגה
   - התראות על מוצרים נמוכים

6. **Price Tracking**
   - מעקב אחר שינויי מחירים
   - השוואת מחירים בין חנויות
   - התראות על הנחות

### 🟢 נמוך (Nice to have)

7. **Tests**

   - Unit tests לlogic
   - Widget tests ל-UI
   - Integration tests לflows

8. **Performance Optimization**

   - Lazy loading
   - Image caching improvements
   - Database query optimization

9. **i18n - English**

   - תרגום מלא לאנגלית
   - flutter_localizations

10. **Accessibility**
    - Screen reader support מלא
    - Contrast improvements
    - Font size adjustments

---

## 🛠 פקודות שימושיות

### Development

```bash
# התקנת תלויות
flutter pub get

# יצירת קוד
dart run build_runner build --delete-conflicting-outputs

# watch mode (יצירה אוטומטית)
dart run build_runner watch

# הרצה
flutter run

# הרצה עם hot reload
flutter run --hot
```

### Analysis & Quality

```bash
# בדיקת קוד
flutter analyze

# תיקונים אוטומטיים
dart fix --apply

# פורמט
dart format lib/ -w
```

### Build

```bash
# Android
flutter build apk --release           # APK file
flutter build appbundle --release     # Google Play

# iOS
flutter build ios --release

# Clean
flutter clean
flutter pub get
```

### Firebase

```bash
# יצירת משתמשי דמו
cd scripts
npm run create-users

# העלאת מוצרים ל-Firestore
npm run upload

# פיתוח Firebase functions
cd functions
npm run serve
```

### Debugging

```bash
# לוגים
flutter logs

# בדיקת מכשירים
flutter devices

# בדיקת doctor
flutter doctor -v
```

---

## 🔍 בעיות נפוצות ופתרונות

### 1. iOS קורס באתחול

**בעיה:** `[VERBOSE-2:platform_configuration.cc(365)] Unhandled Exception`

**פתרון:**

```bash
# GoogleService-Info.plist חסר!
# הורד מ-Firebase Console → iOS App
# העתק ל: ios/Runner/GoogleService-Info.plist
```

### 2. Android קורס באתחול

**בעיה:** `Firebase initialization failed`

**פתרון:**

```bash
# בדוק google-services.json
ls android/app/google-services.json

# ProjectId צריך להיות: salsheli
# אם לא - הורד מחדש מ-Firebase Console
```

### 3. "Project not found"

**בעיה:** Firebase לא מוצא את הפרויקט

**פתרון:**

```bash
# ProjectId צריך להיות: salsheli
# בדוק ב-firebase_options.dart:
grep projectId lib/firebase_options.dart

# צריך להיות:
# projectId: 'salsheli'
```

### 4. "Configuration error"

**בעיה:** תצורת Firebase לא נכונה

**פתרון:**

```bash
# הרץ FlutterFire CLI
dart pub global activate flutterfire_cli
flutterfire configure

# בחר project: salsheli
# בחר platforms: Android, iOS
```

### 5. \*.g.dart files חסרים

**בעיה:** `Error: Part '...g.dart' not found`

**פתרון:**

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 6. Products לא נטענים

**בעיה:** 0 מוצרים מוצגים

**פתרון:**

```bash
# בדוק Firestore
# צריך להיות products collection עם 1,758 מוצרים

# אם אין - הרץ:
cd scripts
npm run upload
```

---

## 📚 מסמכים נוספים

| מסמך                                                 | תיאור                            | מתי לקרוא                |
| ---------------------------------------------------- | -------------------------------- | ------------------------ |
| [WORK_LOG.md](WORK_LOG.md)                           | 📓 יומן עבודה מפורט (47 רשומות!) | תחילת כל שיחה על הפרויקט |
| [CLAUDE_GUIDELINES.md](CLAUDE_GUIDELINES.md)         | 🤖 הוראות ל-Claude/AI tools      | עבודה עם AI על הפרויקט   |
| [MOBILE_GUIDELINES.md](MOBILE_GUIDELINES.md)         | 📱 הנחיות Flutter טכניות         | לפני כתיבת קוד חדש       |
| [CODE_REVIEW_CHECKLIST.md](CODE_REVIEW_CHECKLIST.md) | ✅ בדיקות מהירות                 | לפני כל commit           |
| [ARCHITECTURE_SUMMARY.md](ARCHITECTURE_SUMMARY.md)   | 🏗️ סיכום ארכיטקטורה              | הבנת המבנה הכללי         |
| [README.md](README.md)                               | 📖 README ראשי                   | התחלה מהירה              |

---

## 🎓 למידה ופיתוח

### מושגים שימושיים

- **Provider** - State management pattern
- **ChangeNotifier** - Observable state
- **ProxyProvider** - Provider שתלוי באחר
- **Repository Pattern** - הפשטה של data access
- **Hybrid Storage** - שילוב local + cloud
- **household_id** - שיתוף בין משתמשים
- **Security Rules** - כללי אבטחה ב-Firestore
- **authStateChanges** - Real-time auth listener

### משאבים

- [Flutter Docs](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [Firebase for Flutter](https://firebase.google.com/docs/flutter/setup)
- [Hive Database](https://pub.dev/packages/hive)
- [Material Design](https://material.io/design)

---

## 📊 סטטיסטיקות הפרויקט

| מדד                      | ערך     |
| ------------------------ | ------- |
| **שורות קוד**            | ~15,000 |
| **קבצי Dart**            | 150+    |
| **Providers**            | 7       |
| **Repositories**         | 13      |
| **Screens**              | 25+     |
| **Widgets**              | 30+     |
| **Models**               | 12      |
| **Services**             | 11      |
| **Config Files**         | 5       |
| **משתמשי דמו**           | 3       |
| **מוצרים (Firestore)**   | 1,758   |
| **מוצרים (Hive)**        | 1,778   |
| **סוגי רשימות**          | 21      |
| **רשימות דמו**           | 7       |
| **קבלות דמו**            | 3       |
| **Firebase Collections** | 4       |
| **Security Rules**       | 5       |
| **Firestore Indexes**    | 3       |

---

## 🤝 תרומה לפרויקט

### תהליך תרומה

1. **Fork** את הפרויקט
2. **צור Branch** - `git checkout -b feature/amazing-feature`
3. **קרא תיעוד:**
   - MOBILE_GUIDELINES.md
   - CLAUDE_GUIDELINES.md
   - CODE_REVIEW_CHECKLIST.md
4. **כתוב קוד** - עם תיעוד מלא
5. **Commit** - `git commit -m 'Add amazing feature'`
6. **בדוק Checklist** - CODE_REVIEW_CHECKLIST.md
7. **Push** - `git push origin feature/amazing-feature`
8. **פתח PR** - Pull Request עם תיאור מפורט

### Code Style

```dart
// ✅ טוב
class MyWidget extends StatelessWidget {
  final String title;

  const MyWidget({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// ❌ רע
class bad_widget extends StatelessWidget {
  String title; // לא final

  bad_widget(this.title); // לא const

  Widget build(context) { // חסר @override
    return Container();
  }
}
```

---

## 📄 רישיון

**MIT License**

```
Copyright (c) 2025 Salsheli Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

ראה [LICENSE](LICENSE) לפרטים מלאים.

---

## 🙏 תודות

- **Flutter Team** - על framework מדהים
- **Firebase Team** - על backend מעולה
- **Provider Package** - State management פשוט
- **Hive** - Database מהיר
- **Community** - על תרומות והצעות

---

## 📞 צור קשר

- **Email:** support@salsheli.com (לא פעיל עדיין)
- **GitHub:** [github.com/your-username/salsheli](https://github.com/your-username/salsheli)
- **Issues:** [github.com/your-username/salsheli/issues](https://github.com/your-username/salsheli/issues)

---

## 🎉 סיכום

**Salsheli** הוא פרויקט Flutter מתקדם עם:

✅ **Firebase** מלא - Auth, Firestore, Security  
✅ **Hybrid Storage** - Local + Cloud  
✅ **State Management** - Provider מקצועי  
✅ **21 סוגי רשימות** - לכל צורך  
✅ **Real-time Sync** - עדכונים מיידיים  
✅ **RTL מלא** - תמיכה בעברית  
✅ **1,758 מוצרים** - קטלוג מלא

**הצעד הבא:**

1. ⚠️ הוסף iOS configuration
2. 🔄 העבר Shopping Lists ל-Firestore
3. 🚀 הוסף Real-time collaboration

---

**Made with ❤️ in Israel** 🇮🇱

**עדכון אחרון:** 06/10/2025  
**גרסה:** 1.0.0+1  
**סטטוס:** ✅ Production Ready (Android)
