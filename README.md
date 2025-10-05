# 🛒 סל שלי (Salsheli)

אפליקציית Flutter מובייל (Android & iOS) לניהול קניות, מלאי וקבלות.

> **⚠️ Mobile Only** - אין תמיכה ב-Web/Desktop

---

## ✨ פיצ'רים

- 📋 רשימות קניות + תבניות (21 סוגים!)
- 🏠 ניהול מלאי עם מיקומי אחסון מותאמים
- 🧾 קבלות ומחירים - **נשמר ב-Firestore!**
- 📊 תובנות וסטטיסטיקות חכמות
- 🌐 RTL מלא + תמיכה בעברית
- 🔐 **Firebase Authentication** - התחברות אמיתית
- ☁️ **Firestore** - סנכרון בענן
- 💾 Hybrid Storage - Hive (מוצרים) + Firestore (קבלות/מלאי)

---

## 🚀 התקנה מהירה

```bash
# 1. Clone
git clone https://github.com/your-username/salsheli.git
cd salsheli

# 2. Install dependencies
flutter pub get

# 3. Generate code
dart run build_runner build --delete-conflicting-outputs

# 4. Run
flutter run
```

**דרישות:**
- Dart 3.8.1+ (ראה `pubspec.yaml`)
- Flutter SDK (גרסה תואמת ל-Dart 3.8.1+)
- Node.js (ליצירת משתמשי דמו)

---

## 🔥 Firebase - מוכן לשימוש!

הפרויקט משתמש ב-Firebase מלא:

### ✅ מה כבר מוגדר:
- ✅ `firebase_core: ^3.15.2`
- ✅ `firebase_auth: ^5.7.0` - אימות משתמשים
- ✅ `cloud_firestore: ^5.4.4` - מסד נתונים בענן
- ✅ `lib/firebase_options.dart` - תצורה ל-Android/iOS
- ✅ `android/app/google-services.json` - Project: `salsheli`
- ✅ `AuthService` - שירות אימות מלא
- ✅ `FirebaseUserRepository` - משתמשים ב-Firestore
- ✅ `FirebaseReceiptRepository` - קבלות ב-Firestore
- ✅ `FirebaseInventoryRepository` - מלאי ב-Firestore
- ✅ Security Rules + Indexes

### ⚠️ חסר - צריך להוסיף:
- ❌ `ios/Runner/GoogleService-Info.plist` - **הורד מ-Firebase Console**

**ללא הקובץ הזה, האפליקציה לא תעבוד על iOS!**

### 📥 הוספת GoogleService-Info.plist:

```bash
# אופציה 1: FlutterFire CLI (מומלץ)
flutterfire configure

# אופציה 2: ידני
# 1. כנס ל: https://console.firebase.google.com
# 2. בחר Project: salsheli
# 3. לחץ על אייקון iOS
# 4. הורד את GoogleService-Info.plist
# 5. העתק ל: ios/Runner/GoogleService-Info.plist
```

### 👥 יצירת משתמשי דמו:

```bash
cd scripts
npm install
npm run create-users
```

זה ייצור 3 משתמשים:
- yoni@demo.com (Demo123!)
- sarah@demo.com (Demo123!)
- danny@demo.com (Demo123!)

---

## 📚 תיעוד חובה לקריאה

| קובץ                      | מטרה                          | מתי לקרוא                |
| ------------------------- | ----------------------------- | ------------------------ |
| **WORK_LOG.md**           | 📓 יומן עבודה                 | תחילת כל שיחה            |
| **CLAUDE_GUIDELINES.md**  | 🤖 הוראות ל-Claude/AI        | עבודה עם AI tools       |
| **MOBILE_GUIDELINES.md**  | הנחיות טכניות + ארכיטקטורה   | לפני כתיבת קוד חדש       |
| **CODE_REVIEW_CHECKLIST** | בדיקת קוד מהירה               | לפני כל commit           |

---

## 📂 מבנה הפרויקט

```
lib/
├── main.dart                 # Entry point + Firebase initialization
├── firebase_options.dart     # Firebase configuration
│
├── api/entities/            # API models (@JsonSerializable)
│   ├── user.dart + user.g.dart
│   └── shopping_list.dart + shopping_list.g.dart
│
├── config/                  # Configuration files
│   ├── category_config.dart
│   ├── filters_config.dart
│   └── list_type_mappings.dart
│
├── core/                    # Constants
│   └── constants.dart       # App-wide constants
│
├── data/                    # Demo & sample data
│   ├── demo_shopping_lists.dart
│   ├── rich_demo_data.dart
│   └── onboarding_data.dart
│
├── helpers/                 # Helper utilities
│   └── product_loader.dart  # JSON product loading
│
├── models/                  # Data models (@JsonSerializable)
│   ├── user_entity.dart + .g.dart
│   ├── shopping_list.dart + .g.dart
│   ├── receipt.dart + .g.dart
│   ├── inventory_item.dart + .g.dart
│   ├── suggestion.dart + .g.dart
│   ├── product_entity.dart + .g.dart (Hive)
│   └── enums/               # Enum types
│
├── providers/               # State management (ChangeNotifier)
│   ├── user_context.dart            # 👤 User state + Firebase Auth
│   ├── shopping_lists_provider.dart # 🛒 Shopping lists
│   ├── receipt_provider.dart        # 🧾 Receipts (Firebase!)
│   ├── inventory_provider.dart      # 📦 Inventory (Firebase!)
│   ├── products_provider.dart       # 📦 Products (Hybrid)
│   ├── suggestions_provider.dart    # 💡 Smart suggestions
│   └── locations_provider.dart      # 🏺 Storage locations
│
├── repositories/           # Data access layer
│   ├── user_repository.dart
│   ├── firebase_user_repository.dart       # ✅ Firebase
│   ├── firebase_receipt_repository.dart    # ✅ Firebase
│   ├── firebase_inventory_repository.dart  # ✅ Firebase
│   ├── firebase_products_repository.dart   # ✅ Firebase
│   ├── hybrid_products_repository.dart     # 🔀 Local + Firestore + API
│   ├── local_shopping_lists_repository.dart
│   └── ... (interfaces)
│
├── services/               # Business logic
│   ├── auth_service.dart           # 🔐 Firebase Authentication
│   ├── home_stats_service.dart     # 📊 Home statistics
│   ├── local_storage_service.dart
│   └── ...
│
├── screens/                # UI screens
│   ├── auth/               # Login, Register
│   ├── home/               # Dashboard
│   ├── shopping/           # Lists, Active shopping
│   ├── receipts/           # Receipt management
│   ├── pantry/             # Inventory
│   ├── insights/           # Analytics
│   └── ...
│
├── widgets/                # Reusable components
│   ├── auth/               # Auth widgets
│   ├── home/               # Home cards
│   ├── common/             # Shared widgets
│   └── ...
│
└── theme/                  # App theming
    └── app_theme.dart
```

**פירוט מלא:** ראה MOBILE_GUIDELINES.md

---

## ✅ מה עובד היום

### 🔐 Firebase Authentication
- ✅ Email/Password authentication
- ✅ 3 משתמשי דמו מוכנים
- ✅ AuthService מלא
- ✅ authStateChanges listener
- ✅ Persistent sessions

### ☁️ Firestore Integration
- ✅ Users collection
- ✅ Receipts collection - **נשמר בענן!**
- ✅ Inventory collection - **נשמר בענן!**
- ✅ Products collection (1,778 מוצרים)
- ✅ Security Rules
- ✅ Firestore Indexes

### 📦 Hybrid Storage
- ✅ Hive: 1,778 מוצרים מקומיים (cache)
- ✅ Firestore: Products + Receipts + Inventory
- ✅ SharedPreferences: Shopping lists (זמני)
- ✅ Fallback strategy מלאה

### 🎨 UI/UX
- ✅ 21 סוגי רשימות
- ✅ קנייה פעילה - מסך ליווי בקנייה
- ✅ מיקומי אחסון מותאמים
- ✅ RTL מלא
- ✅ Dark/Light themes
- ✅ Undo pattern בכל המערכת

### 📊 נתוני דמו
- ✅ 100+ מוצרים אמיתיים מ-JSON
- ✅ 7 רשימות קניות דינמיות
- ✅ 3 קבלות עם מוצרים אמיתיים
- ✅ מלאי חכם (מזווה, מקרר, וכו')

---

## 📝 TODO - מה נשאר

### 🔴 גבוה
- [ ] iOS configuration (GoogleService-Info.plist)
- [ ] העברת Shopping Lists ל-Firestore
- [ ] Real-time sync לרשימות

### 🟡 בינוני
- [ ] Receipt OCR
- [ ] Smart notifications
- [ ] Barcode scanning improvements
- [ ] Price tracking מתקדם

### 🟢 נמוך
- [ ] Tests (Unit/Widget/Integration)
- [ ] Performance optimization
- [ ] i18n (English)
- [ ] Accessibility improvements

---

## 🛠 פקודות שימושיות

```bash
# Development
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run

# Analysis & Formatting
flutter analyze
dart fix --apply
dart format lib/ -w

# Build for Production
flutter build apk --release
flutter build appbundle --release  # Google Play
flutter build ios --release

# Firebase
cd scripts
npm run create-users  # יצירת משתמשי דמו
npm run upload        # העלאת מוצרים ל-Firestore
```

---

## 🔍 בדיקת תקינות Firebase

```bash
# בדוק שהקבצים קיימים:
ls lib/firebase_options.dart                    # ✅
ls android/app/google-services.json             # ✅
ls ios/Runner/GoogleService-Info.plist          # ❌ חסר!

# אחרי הוספת הקובץ:
flutter clean
flutter pub get
flutter run
```

### 🐛 בעיות נפוצות:

| בעיה | פתרון |
|------|-------|
| **iOS קורס באתחול** | GoogleService-Info.plist חסר |
| **Android קורס באתחול** | בדוק google-services.json |
| **"Project not found"** | ProjectId לא תואם (צריך `salsheli`) |
| **"Configuration error"** | הרץ `flutterfire configure` |

---

## 📊 סטטיסטיקות

- **שורות קוד:** ~15,000
- **מוצרים:** 1,778 (Firestore + Hive)
- **משתמשי דמו:** 3
- **רשימות זמינות:** 7
- **סוגי רשימות:** 21
- **קבלות:** 3 (דמו)

---

## 🤝 תרומה לפרויקט

1. Fork + Branch
2. **קרא MOBILE_GUIDELINES.md** 📚
3. **קרא CLAUDE_GUIDELINES.md** 🤖
4. Commit עם תיאור ברור
5. **בדוק CODE_REVIEW_CHECKLIST.md** ✅
6. PR

---

## 📄 רישיון

MIT License - ראה LICENSE לפרטים

---

**עדכון אחרון:** 05/10/2025  
**גרסה:** 1.0.0+1  
**Made with ❤️ in Israel** 🇮🇱
