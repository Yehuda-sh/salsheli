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

### ⚠️ iOS Configuration

**סטטוס:** `firebase_options.dart` כולל הגדרות iOS מלאות, אבל לבנייה מקומית על iOS עדיין נדרש:

- ❌ `ios/Runner/GoogleService-Info.plist` - **חסר**

> **הערה:** הקובץ נדרש רק לבנייה מקומית על מכשירי iOS. אם אתה עובד רק עם Android, הפרויקט יעבוד ללא בעיות.

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
│   └── onboarding_data.dart     # Onboarding flow data
│
├── l10n/                    # Localization
│   └── app_strings.dart         # String resources
│
├── layout/                  # App layout
│   └── app_layout.dart          # Main navigation & structure
│
├── utils/                   # Utility functions
│   └── ...                      # Helper utilities
│
├── models/                  # Data models (@JsonSerializable)
│   ├── user_entity.dart + .g.dart
│   ├── shopping_list.dart + .g.dart
│   ├── receipt.dart + .g.dart
│   ├── inventory_item.dart + .g.dart
│   ├── suggestion.dart + .g.dart
│   ├── product_entity.dart + .g.dart (Hive)
│   ├── custom_location.dart + .g.dart
│   ├── timestamp_converter.dart  # Firestore Timestamp converter
│   ├── enums/                    # Enum types
│   └── mappers/                  # Data mappers
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
│   ├── firebase_user_repository.dart           # ✅ Firebase
│   ├── firebase_receipt_repository.dart        # ✅ Firebase
│   ├── firebase_inventory_repository.dart      # ✅ Firebase
│   ├── firebase_products_repository.dart       # ✅ Firebase
│   ├── firebase_shopping_list_repository.dart  # ✅ Firebase (06/10/2025)
│   ├── hybrid_products_repository.dart         # 🔀 Local + Firestore + API
│   ├── local_shopping_lists_repository.dart    # 📂 Local fallback
│   └── ... (interfaces)
│
├── services/               # Business logic
│   ├── auth_service.dart               # 🔐 Firebase Authentication
│   ├── home_stats_service.dart         # 📊 Home statistics
│   ├── shufersal_prices_service.dart   # 💰 Price updates from API
│   ├── receipt_service.dart            # 🧾 Receipt processing
│   ├── onboarding_service.dart         # 👋 User onboarding
│   ├── local_storage_service.dart      # 💾 Local storage
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
- ✅ **Shopping Lists** - **נשמרות בענן!** (06/10/2025)
- ✅ Receipts collection - **נשמר בענן!**
- ✅ Inventory collection - **נשמר בענן!**
- ✅ Products collection (1,758 מוצרים)
- ✅ Real-time sync עם `watchLists()` stream
- ✅ Security Rules
- ✅ Firestore Indexes

### 📦 Hybrid Storage
- ✅ Hive: 1,758 מוצרים מקומיים (cache)
- ✅ Firestore: **Shopping Lists** + Receipts + Inventory + Products
- ✅ Fallback strategy מלאה (Local → Firebase)

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
- [ ] iOS configuration (GoogleService-Info.plist לבנייה מקומית)
- [x] ~~העברת Shopping Lists ל-Firestore~~ ✅ הושלם 06/10/2025
- [x] ~~Real-time sync לרשימות~~ ✅ הושלם 06/10/2025

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
ls lib/firebase_options.dart                    # ✅ (אנדרואיד + iOS)
ls android/app/google-services.json             # ✅
ls ios/Runner/GoogleService-Info.plist          # ❌ חסר (נדרש לבנייה iOS)

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
- **מוצרים:** 1,758 (Firestore + Hive)
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

**עדכון אחרון:** 07/10/2025  
**גרסה:** 1.0.0+1  
**Made with ❤️ in Israel** 🇮🇱
