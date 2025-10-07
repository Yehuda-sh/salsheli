# 🛒 סל שלי (Salsheli)

אפליקציית Flutter מובייל (Android & iOS) לניהול קניות, מלאי וקבלות.

> **⚠️ Mobile Only** - אין תמיכה ב-Web/Desktop

---

## ✨ פיצ'רים

- 📋 רשימות קניות + תבניות (21 סוגים!)
- 🏠 ניהול מלאי עם מיקומי אחסון מותאמים
- 🧾 קבלות ומחירים - **נשמר ב-Firestore!**
- 💰 מחירים אמיתיים מ-**Shufersal API** (prices.shufersal.co.il)
- 📊 תובנות וסטטיסטיקות חכמות
- 🌐 RTL מלא + תמיכה בעברית
- 🔐 **Firebase Authentication** - התחברות אמיתית
- ☁️ **Firestore** - סנכרון בענן
- 💾 Hybrid Storage - Hive (cache) + Firestore (cloud)

---

## 🚀 Quick Start למפתחים

### אם אתה מצטרף לפרויקט - קרא קודם:

| קובץ | זמן קריאה | מטרה |
|------|-----------|------|
| **📚 LESSONS_LEARNED.md** | 10 דק' | הלקחים החשובים והדפוסים הטכניים |
| **🤖 AI_DEV_GUIDELINES.md** | 5 דק' | הנחיות מקיפות למערכות AI (סוכנים בלבד) |

### התקנה:

```bash
# 1. Clone
git clone https://github.com/your-username/salsheli.git
cd salsheli

# 2. Install dependencies
flutter pub get

# 3. Generate code
dart run build_runner build --delete-conflicting-outputs

# 4. יצירת משתמשי דמו (אופציונלי)
cd scripts
npm install
npm run create-users

# 5. Run
flutter run
```

**דרישות:**

- Dart 3.8.1+ (ראה `pubspec.yaml`)
- Flutter SDK (גרסה תואמת)
- Node.js (ליצירת משתמשי דמו)

---

## 📚 תיעוד - מי צריך לקרוא מה?

### למפתח חדש (אנושי):

1. **LESSONS_LEARNED.md** ⭐ - הכי חשוב! קרא קודם
2. **README.md** (זה) - overview כללי
3. **WORK_LOG.md** - היסטוריה מפורטת (לדיבוג)

### לסוכני AI (Claude/ChatGPT/etc.):

1. **AI_DEV_GUIDELINES.md** ⭐ - הנחיות מקיפות (קרא בתחילת כל שיחה)
2. **WORK_LOG.md** - היסטוריה מלאה (קרא אוטומטית)

### לדיבוג בעיות:

1. **WORK_LOG.md** - חיפוש בהיסטוריה
2. **LESSONS_LEARNED.md** - בעיות נפוצות ופתרונות

---

## 🎓 לקחים מרכזיים (TL;DR)

> **לקריאה מלאה:** ראה `LESSONS_LEARNED.md`

### ⚡ 5 כללים מוזהב:

1. **Firebase Timestamps** - תמיד המר נכון:

   ```dart
   final timestamp = Timestamp.fromDate(dateTime);
   final dateTime = timestamp.toDate();
   ```

2. **3 Empty States חובה** - Loading/Error/Empty בכל widget שטוען data

3. **UserContext סטנדרטי**:

   ```dart
   void updateUserContext(UserContext ctx) {
     _listening?.cancel();
     _listening = _onUserChanged().listen((_) => notifyListeners());
   }
   ```

4. **Dead Code = מחק מיד** - 0 imports = הקובץ לא בשימוש

5. **Undo למחיקה** - SnackBar עם "בטל" (5 שניות)

---

## 🔥 Firebase - מוכן לשימוש!

### ✅ מה כבר מוגדר:

- ✅ Firebase Core 3.15.2
- ✅ Firebase Auth 5.7.0
- ✅ Cloud Firestore 5.4.4
- ✅ `firebase_options.dart` (Android + iOS)
- ✅ `android/app/google-services.json`
- ✅ AuthService מלא
- ✅ 4 Repositories (User/Receipt/Inventory/ShoppingList)
- ✅ Security Rules + Indexes
- ✅ Real-time sync עם `watchLists()` streams

### ⚠️ iOS Configuration

**סטטוס:** הגדרות iOS במקום, אבל לבנייה מקומית נדרש:

- ❌ `ios/Runner/GoogleService-Info.plist` - **חסר**

> **הערה:** נדרש רק לבנייה על iOS. עבודה עם Android תקינה.

### 📥 הוספת GoogleService-Info.plist:

```bash
# אופציה 1: FlutterFire CLI (מומלץ)
flutterfire configure

# אופציה 2: ידני
# 1. https://console.firebase.google.com
# 2. בחר Project: salsheli
# 3. לחץ על אייקון iOS → הורד GoogleService-Info.plist
# 4. העתק ל: ios/Runner/GoogleService-Info.plist
```

### 👥 משתמשי דמו:

```bash
cd scripts
npm install
npm run create-users
```

**משתמשים:**

- `yoni@demo.com` / `Demo123!`
- `sarah@demo.com` / `Demo123!`
- `danny@demo.com` / `Demo123!`

---

## 💰 Shufersal API - מחירים אמיתיים

הפרויקט משתמש ב-**ShufersalPricesService** לעדכון מחירים:

### איך זה עובד:

- 📥 הורדת קבצי XML מ-`prices.shufersal.co.il` (קבצים פומביים)
- 🗜️ פענוח GZ compressed files
- 🏪 3 סניפים (~15,000 מוצרים)
- 🔄 עדכון אוטומטי בהפעלה + כפתור ידני בהגדרות

### למה Shufersal ולא PublishedPrices?

- ✅ קבצים פומביים - אין SSL issues
- ✅ פשוט - ללא התחברות
- ✅ מהיר - עובד ב-production
- ❌ PublishedPrices - SSL problems, API מורכב

> **לקח:** SSL Override = Bad Practice. מצא API טוב במקום לעקוף SSL!

---

## 📂 מבנה הפרויקט

```
lib/
├── main.dart                 # Entry point + Firebase init
├── firebase_options.dart     # Firebase config
│
├── config/                   # Configurations
├── core/                     # Constants
├── l10n/                     # Localization (app_strings.dart)
├── layout/                   # App layout & navigation
├── utils/                    # Helpers
│
├── models/                   # Data models (@JsonSerializable)
│   ├── timestamp_converter.dart  # ⚡ Firestore Timestamp converter
│   ├── user_entity.dart
│   ├── shopping_list.dart
│   ├── receipt.dart
│   ├── inventory_item.dart
│   ├── product_entity.dart (Hive)
│   └── ...
│
├── providers/               # State management (ChangeNotifier)
│   ├── user_context.dart            # 👤 User + Auth
│   ├── shopping_lists_provider.dart # 🛒 Lists (Firestore!)
│   ├── receipt_provider.dart        # 🧾 Receipts (Firestore!)
│   ├── inventory_provider.dart      # 📦 Inventory (Firestore!)
│   ├── products_provider.dart       # 📦 Products (Hybrid)
│   └── ...
│
├── repositories/           # Data access layer
│   ├── firebase_user_repository.dart
│   ├── firebase_shopping_list_repository.dart  # ✅ (07/10/2025)
│   ├── firebase_receipt_repository.dart
│   ├── firebase_inventory_repository.dart
│   ├── hybrid_products_repository.dart         # Local + Firestore + API
│   └── ...
│
├── services/               # Business logic
│   ├── auth_service.dart               # 🔐 Firebase Auth
│   ├── shufersal_prices_service.dart   # 💰 Shufersal API
│   ├── home_stats_service.dart
│   └── ...
│
├── screens/                # UI screens
├── widgets/                # Reusable components
└── theme/                  # App theming
```

**פירוט מלא:** ראה `MOBILE_GUIDELINES.md`

---

## ✅ מה עובד היום (07/10/2025)

### 🔐 Firebase Authentication

- ✅ Email/Password
- ✅ 3 משתמשי דמו
- ✅ Persistent sessions
- ✅ authStateChanges listener

### ☁️ Firestore Integration

- ✅ **Shopping Lists** - real-time sync (07/10/2025)
- ✅ **Receipts** - נשמר בענן
- ✅ **Inventory** - נשמר בענן
- ✅ **Products** - 1,758 מוצרים
- ✅ **Users** - פרופילים
- ✅ Security Rules + Indexes
- ✅ `watchLists()` streams

### 📦 Hybrid Storage

- ✅ Hive: cache מקומי (1,758 מוצרים)
- ✅ Firestore: cloud storage
- ✅ Fallback strategy (Local → Firebase)

### 💰 Shufersal API

- ✅ עדכון מחירים אוטומטי בהפעלה
- ✅ כפתור עדכון ידני בהגדרות
- ✅ 3 סניפים, ~15,000 מוצרים

### 🎨 UI/UX

- ✅ 21 סוגי רשימות
- ✅ קנייה פעילה - מסך ליווי
- ✅ מיקומי אחסון מותאמים
- ✅ RTL מלא
- ✅ Dark/Light themes
- ✅ Undo pattern בכל המערכת
- ✅ 3 Empty States (Loading/Error/Empty)

---

## 📝 TODO - מה נשאר

### 🔴 גבוה

- [ ] iOS GoogleService-Info.plist לבנייה מקומית
- [ ] Collaborative shopping (real-time עם users אחרים)
- [ ] Receipt OCR

### 🟡 בינוני

- [ ] Smart notifications
- [ ] Barcode scanning improvements
- [ ] Price tracking מתקדם
- [ ] Offline mode עם Hive cache

### 🟢 נמוך

- [ ] Tests (Unit/Widget/Integration)
- [ ] Performance optimization
- [ ] i18n (English)
- [ ] Accessibility improvements

### ~~✅ הושלם~~ (07/10/2025)

- ~~[x] העברת Shopping Lists ל-Firestore~~
- ~~[x] Real-time sync לרשימות~~
- ~~[x] Shufersal API למחירים~~
- ~~[x] ניקוי Dead Code (4,500+ שורות)~~
- ~~[x] Code Review מקיף (22 קבצים → 100/100)~~

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
npm run upload        # העלאת מוצרים ל-Firestore (אופציונלי)

# Code Generation
dart run build_runner watch  # watch mode לפיתוח
```

---

## 🔍 בדיקת תקינות Firebase

```bash
# בדוק קבצים:
ls lib/firebase_options.dart                    # ✅
ls android/app/google-services.json             # ✅
ls ios/Runner/GoogleService-Info.plist          # ❌ חסר (iOS only)

# אחרי הוספת GoogleService-Info.plist:
flutter clean
flutter pub get
flutter run
```

### 🐛 בעיות נפוצות:

| בעיה                        | פתרון                                  |
| --------------------------- | -------------------------------------- |
| **iOS קורס באתחול**         | GoogleService-Info.plist חסר           |
| **Android קורס**            | בדוק google-services.json              |
| **"Project not found"**     | ProjectId צריך להיות `salsheli`        |
| **"Configuration error"**   | `flutterfire configure`                |
| **Race condition בהתחברות** | סבלנות - Firebase Auth אסינכרוני       |
| **רשימות לא נטענות**        | בדוק snake_case ב-Firestore (@JsonKey) |

> **טיפ:** ראה `LESSONS_LEARNED.md` לבעיות נפוצות נוספות

---

## 📊 סטטיסטיקות (07/10/2025)

- **שורות קוד:** ~10,500 (אחרי ניקוי 4,500 שורות Dead Code)
- **מוצרים בHive:** 1,758 (cache מקומי)
- **מוצרים בFirestore:** 1,758
- **משתמשי דמו:** 3
- **רשימות זמינות:** 7
- **סוגי רשימות:** 21
- **קבלות:** 3 (דמו)
- **קבצים נמחקו:** 12 (Dead Code cleanup)
- **קבצים שודרגו:** 22 → 100/100 (Code Review)

---

## 🎯 הישגים אחרונים (06-07/10/2025)

- ✅ Firebase Integration מלא
- ✅ Shopping Lists → Firestore + real-time sync
- ✅ Shufersal API למחירים אמיתיים
- ✅ ניקוי 4,500+ שורות Dead Code
- ✅ Code Review מקיף - 22 קבצים
- ✅ Localization system (lib/l10n/)
- ✅ UX Patterns (Undo, Clear, 3 States)
- ✅ תיעוד מקיף (LESSONS_LEARNED.md)

---

## 🤝 תרומה לפרויקט

### תהליך:

1. **Fork + Branch**
2. **קרא תיעוד:**
   - `LESSONS_LEARNED.md` ⭐ (חובה!)
   - `AI_DEV_GUIDELINES.md` (אם עובד עם AI סוכן)
3. **כתוב קוד:**
   - עקוב אחר הדפוסים ב-LESSONS_LEARNED
   - 3 Empty States בwidgets חדשים
   - Logging בכל method
4. **לפני commit:**
   - ✅ בדיקת איכות (ראה `AI_DEV_GUIDELINES.md` חלק C)
   - ✅ `flutter analyze`
   - ✅ `dart format lib/ -w`
5. **Commit:**
   - הודעה ברורה
   - רשום ב-`WORK_LOG.md` אם משמעותי
6. **PR**

---

## 📄 רישיון

MIT License - ראה LICENSE לפרטים

---

## 🙏 תודות

- Firebase לinfrastructure מעולה
- Shufersal למחירים פומביים
- הקהילה של Flutter

---

**עדכון אחרון:** 07/10/2025  
**גרסה:** 1.0.0+1  
**Made with ❤️ in Israel** 🇮🇱

---

> 💡 **Tip למפתחים:** התחל עם `LESSONS_LEARNED.md` - זה החשוב ביותר!
>
> 💡 **Tip לסוכני AI:** קרא את `AI_DEV_GUIDELINES.md` בתחילת כל שיחה על הפרויקט. היומן (`WORK_LOG.md`) ייקרא אוטומטית.
