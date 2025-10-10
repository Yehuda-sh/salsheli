// file: README.md

# 🛒 סל שלי (Salsheli)

אפליקציית Flutter מובייל (Android & iOS) לניהול קניות, מלאי וקבלות עם סנכרון בענן.

> **⚠️ Mobile Only** - אין תמיכה ב-Web/Desktop

---

## ✨ פיצ'רים

- 📋 **רשימות קניות** - 21 סוגי תבניות + קנייה פעילה
- 📝 **תבניות רשימות** - מערכת + אישיות + משותפות (חדש!)
- 🏠 **ניהול מלאי** - מיקומי אחסון מותאמים + קטגוריות
- 🧾 **קבלות** - OCR מקומי (ML Kit) + מחירים
- 💰 **מחירים אמיתיים** - Shufersal API (~15,000 מוצרים)
- 🧠 **הרגלי קנייה** - למידה ממועדפים + תובנות חכמות
- 📊 **תובנות וסטטיסטיקות** - ניתוח הוצאות
- 🔐 **Firebase Auth** - התחברות מאובטחת
- ☁️ **Firestore Sync** - סנכרון real-time בין מכשירים
- 🌐 **RTL מלא** - תמיכה בעברית

---

## 🚀 Quick Start

### למפתח חדש - קרא קודם:

| קובץ                        | מה זה                                |
| --------------------------- | ------------------------------------ |
| **📚 LESSONS_LEARNED.md**   | לקחים חשובים + דפוסים טכניים (חובה!) |
| **🤖 AI_DEV_GUIDELINES.md** | הנחיות לסוכני AI (אם רלוונטי)        |
| **📓 WORK_LOG.md**          | שינויים אחרונים + היסטוריה           |

### התקנה:

```bash
# Clone
git clone https://github.com/your-username/salsheli.git
cd salsheli

# Install & Generate
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# משתמשי דמו + נתונים (מומלץ!)
cd scripts && npm install && npm run setup-demo

# Run
flutter run
```

**דרישות:** Dart 3.8.1+ | Flutter SDK | Node.js (לסקריפטים)

---

## 🔥 Firebase Configuration

### ✅ מה מוגדר:

- Firebase Core 3.15.2
- Firebase Auth 5.7.0 (Email/Password)
- Cloud Firestore 5.4.4 (Real-time sync)
- `firebase_options.dart` + `android/app/google-services.json` ✅

### ⚠️ iOS Setup:

**חסר:** `ios/Runner/GoogleService-Info.plist`

```bash
# הורד מ-Firebase Console:
# 1. https://console.firebase.google.com → Project: salsheli
# 2. iOS App → הורד GoogleService-Info.plist
# 3. העתק ל: ios/Runner/GoogleService-Info.plist

# או השתמש ב-CLI:
flutterfire configure
```

### 👥 משתמשי דמי + נתונים:

```bash
cd scripts && npm run setup-demo
```

**משתמשים:**

- `yoni@demo.com` / `Demo123!`
- `sarah@demo.com` / `Demo123!`
- `danny@demo.com` / `Demo123!`

**נתונים שיוצרו (עם מוצרים אמיתיים!):**

- ✅ 3 רשימות קניות (2 פעילות + 1 הושלמה) - **מוצרים מ-Firestore**
- ✅ ~15 פריטים במלאי - **מוצרים אמיתיים**
- ✅ 2 קבלות נוספות - **מחירים אמיתיים מהמערכת**
- ✅ 6 תבניות מערכת - **תבניות מוכנות לשימוש**
- ✅ סטטיסטיקות אמיתיות ב-Settings

> **💡 חשוב:** הסקריפט החדש (v2) משתמש במוצרים אמיתיים מ-Firestore, לא Mock Data!
> אם רוצה להשתמש בסקריפט הישן: `npm run setup-demo-old`

---

## 💰 Shufersal API

השירות מוריד מחירים אמיתיים מ-**prices.shufersal.co.il**:

- 📥 הורדת קבצי XML (פומביים, ללא SSL issues)
- 🗜️ פענוח GZ compressed
- 🏪 3 סניפים, ~15,000 מוצרים
- 🔄 עדכון אוטומטי בהפעלה + כפתור ידני בהגדרות

> **למה Shufersal?** קבצים פומביים, פשוט, ללא התחברות. PublishedPrices יצר SSL problems.

---

## 📂 מבנה הפרויקט

```
lib/
├── main.dart                   # Entry + Firebase init + Providers
├── firebase_options.dart       # Firebase config
│
├── models/                     # Data models (@JsonSerializable)
│   ├── timestamp_converter.dart    # ⚡ Firestore Timestamp helper
│   ├── user_entity.dart            # User model
│   ├── shopping_list.dart          # Shopping list + items
│   ├── receipt.dart                # Receipt + items
│   ├── inventory_item.dart         # Pantry item
│   ├── product_entity.dart         # Product (Shufersal)
│   ├── template.dart               # 📋 List template + items (חדש!)
│   ├── suggestion.dart             # Smart suggestions
│   ├── habit_preference.dart       # 🧠 User habits
│   ├── custom_location.dart        # Storage locations
│   └── enums/                      # Enums (status, etc.)
│
├── providers/                  # State (ChangeNotifier)
│   ├── user_context.dart           # 👤 User + Auth
│   ├── shopping_lists_provider.dart # 🛒 Lists (Firestore)
│   ├── templates_provider.dart     # 📋 Templates (חדש!)
│   ├── receipt_provider.dart       # 🧾 Receipts
│   ├── inventory_provider.dart     # 📦 Inventory
│   ├── products_provider.dart      # 💰 Products (Hybrid)
│   ├── suggestions_provider.dart   # 💡 Smart suggestions
│   ├── habits_provider.dart        # 🧠 User habits
│   └── locations_provider.dart     # 📍 Custom locations
│
├── repositories/              # Data access
│   ├── firebase_*_repository.dart  # Firestore CRUD (8 repos)
│   ├── hybrid_products_repository.dart # Hive + Firestore + API
│   ├── local_products_repository.dart  # Hive cache
│   └── *_repository.dart           # Interfaces (5 interfaces)
│
├── services/                  # Business logic
│   ├── auth_service.dart              # 🔐 Firebase Auth
│   ├── shufersal_prices_service.dart  # 💰 API
│   ├── ocr_service.dart               # 📸 ML Kit
│   ├── receipt_parser_service.dart    # 🧾 Regex Parser
│   ├── home_stats_service.dart        # 📊 Dashboard stats
│   ├── onboarding_service.dart        # 🎓 User onboarding
│   └── prefs_service.dart             # 💾 SharedPreferences
│
├── screens/                   # UI (30+ screens)
│   ├── auth/                   # Login, Register
│   ├── home/                   # Dashboard + Home
│   ├── shopping/               # Lists, Active shopping (8 screens)
│   ├── lists/                  # Templates, Populate (3 screens)
│   ├── receipts/               # Manager, View (2 screens)
│   ├── pantry/                 # Inventory screen
│   ├── price/                  # Price comparison
│   ├── habits/                 # My habits
│   ├── insights/               # Statistics
│   ├── settings/               # Settings
│   ├── onboarding/             # Welcome flow
│   ├── index_screen.dart       # Splash + Router
│   └── welcome_screen.dart     # First screen
│
├── widgets/                   # Reusable components (25+ widgets)
│   ├── common/                 # Dashboard card, Benefit tile
│   ├── home/                   # Suggestions, Upcoming shop
│   ├── auth/                   # Auth button, Demo login
│   └── *.dart                  # Item card, Filters, etc.
│
├── config/                    # Configuration files (חדש!)
│   ├── household_config.dart       # 11 household types
│   ├── list_type_mappings.dart     # Type → Categories (140+ items)
│   ├── list_type_groups.dart       # 3 groups (Shopping/Specialty/Events)
│   ├── filters_config.dart         # Filter options
│   ├── stores_config.dart          # Store names + variations
│   └── receipt_patterns_config.dart # OCR Regex patterns
│
├── core/                      # Constants (חדש!)
│   ├── constants.dart              # ListType, categories, collections
│   ├── ui_constants.dart           # Spacing, sizes, durations
│   └── status_colors.dart          # Status colors
│
├── l10n/                      # Localization (חדש!)
│   ├── app_strings.dart            # Main strings (i18n ready)
│   └── strings/                    # Additional strings
│       └── list_type_mappings_strings.dart
│
├── data/                      # Static data (חדש!)
│   └── onboarding_data.dart        # Onboarding steps
│
├── layout/                    # Layout (חדש!)
│   └── app_layout.dart             # App shell
│
└── theme/                     # Theming
    └── app_theme.dart              # Light + Dark themes
```

---

## 📝 מה עובד היום (10/10/2025)

### ☁️ Firestore + Authentication

- ✅ Email/Password auth + persistent sessions
- ✅ Shopping Lists - real-time sync
- ✅ Templates System - system/personal/shared/assigned (חדש!)
- ✅ Receipts, Inventory, Products (1,758 מוצרים)
- ✅ Habits tracking - learning user preferences
- ✅ Custom locations - personalized storage
- ✅ Security Rules + Indexes
- ✅ Hybrid Storage: Hive (cache) + Firestore (cloud)

### 💰 Shufersal API + OCR

- ✅ עדכון מחירים אוטומטי + ידני
- ✅ OCR מקומי (ML Kit) לסריקת קבלות
- ✅ זיהוי חנויות: שופרסל, רמי לוי, מגה
- ✅ חילוץ פריטים + סכומים

### 📋 Templates System (חדש!)

- ✅ 6 תבניות מערכת (סופר, בית מרקחת, יום הולדת, אירוח, משחקים, קמפינג)
- ✅ תבניות אישיות (personal)
- ✅ תבניות משותפות (shared) - כל ה-household
- ✅ תבניות מוקצות (assigned) - למשתמשים ספציפיים
- ✅ 66 פריטים בתבניות מערכת

### 🎨 UI/UX

- ✅ 21 סוגי רשימות + מסך קנייה פעילה
- ✅ Undo למחיקה (5 שניות)
- ✅ 3-4 Empty States: Loading/Error/Empty/Initial
- ✅ RTL מלא + Dark/Light themes
- ✅ מיקומי אחסון מותאמים
- ✅ Modern Design - gradients, shadows, elevation

---

## 📊 סטטיסטיקות

- **קבצי Dart:** 100+ בlib/ (ללא .g.dart)
- **מודלים:** 11 (כולל Templates)
- **Providers:** 9 (כולל Templates + Habits)
- **Repositories:** 15 (8 Firebase + interfaces)
- **Services:** 7
- **Screens:** 30+
- **Widgets:** 25+
- **Config Files:** 6 (חדש!)
- **תבניות מערכת:** 6 (66 פריטים)
- **מוצרים:** 1,758 (Hive + Firestore)
- **סוגי רשימות:** 21
- **פריטים מוצעים:** 140+ (לכל סוג רשימה)
- **משתמשי דמו:** 3

---

## 🎯 TODO

### 🔴 גבוה

- [ ] iOS GoogleService-Info.plist
- [ ] Collaborative shopping (שיתוף real-time)
- [ ] Receipt OCR improvements
- [ ] Template sharing advanced features

### 🟡 בינוני

- [ ] Offline mode מלא (Hive cache)
- [ ] Smart notifications
- [ ] Price tracking מתקדם
- [ ] Template categories + search

### 🟢 נמוך

- [ ] Tests (Unit/Widget/Integration)
- [ ] i18n (English)
- [ ] Performance optimization
- [ ] Custom template icons

### ✅ הושלם לאחרונה

- ~~Templates System - Foundation + Provider + Repo~~ (10/10/2025)
- ~~6 System Templates~~ (10/10/2025)
- ~~Shopping Lists → Firestore~~
- ~~Shufersal API~~
- ~~OCR מקומי (ML Kit)~~
- ~~Dead Code cleanup (5,000+ שורות)~~
- ~~140+ suggested items~~ (08/10/2025)

---

## 🛠 פקודות שימושיות

```bash
# Development
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run

# Quality
flutter analyze
dart format lib/ -w

# Build
flutter build apk --release
flutter build appbundle --release  # Google Play
flutter build ios --release

# Firebase Scripts
cd scripts
npm run create-users           # משתמשי דמו
npm run upload-products        # העלאת מוצרים ל-Firestore
npm run create-system-templates # 6 תבניות מערכת (חדש!)
npm run create-data-real       # נתוני דמו עם מוצרים אמיתיים (מומלץ!)
npm run create-data            # נתוני דמו ישן (Mock Data)
npm run setup-demo             # הכל ביחד (users + templates + real data)
```

---

## 🐛 בעיות נפוצות

| בעיה                        | פתרון                                  |
| --------------------------- | -------------------------------------- |
| **iOS קורס**                | GoogleService-Info.plist חסר           |
| **Android קורס**            | בדוק google-services.json              |
| **רשימות לא נטענות**        | בדוק snake_case ב-Firestore (@JsonKey) |
| **Templates לא נטענות**     | הרץ `npm run create-system-templates`  |
| **Race condition בהתחברות** | Firebase Auth אסינכרוני - המתן לSignIn |
| **Build runner fails**      | מחק build/ ו-\*.g.dart, הרץ שוב        |

> **עוד פתרונות:** ראה `LESSONS_LEARNED.md` חלק "בעיות נפוצות"

---

## 🤝 תרומה

1. **Fork + Branch**
2. **קרא תיעוד:** `LESSONS_LEARNED.md` (חובה!)
3. **כתוב קוד:**
   - עקוב אחר דפוסים ב-LESSONS_LEARNED
   - 3-4 Empty States בwidgets חדשים
   - Logging בכל method
   - Constants לכל hardcoded values
4. **לפני commit:**
   - `flutter analyze`
   - `dart format lib/ -w`
   - ✅ בדיקת איכות (AI_DEV_GUIDELINES.md)
5. **Commit + PR**

---

## 🎓 הישגים אחרונים (06-10/10/2025)

- ✅ Templates System מלא (10/10)
- ✅ 6 תבניות מערכת (10/10)
- ✅ Firebase Integration מלא
- ✅ Shufersal API למחירים אמיתיים
- ✅ OCR מקומי (ML Kit)
- ✅ ניקוי 5,000+ שורות Dead Code
- ✅ Code Review מקיף (100/100)
- ✅ Providers עקביים (Error Handling + Logging + Recovery)
- ✅ תיקון ביצועים - Batch Save Pattern (0 Skipped Frames)
- ✅ תיעוד מקיף (LESSONS_LEARNED + AI_DEV_GUIDELINES + WORK_LOG)
- ✅ 140+ פריטים מוצעים (21 קטגוריות)
- ✅ Config Files Pattern (6 קבצים)

---

## 📄 רישיון

MIT License - ראה LICENSE

---

**עדכון:** 10/10/2025 | **גרסה:** 1.0.0+1 | **Made with ❤️ in Israel** 🇮🇱

> 💡 **למפתחים:** התחל עם `LESSONS_LEARNED.md` - הכי חשוב!  
> 💡 **לסוכני AI:** קרא `AI_DEV_GUIDELINES.md` בתחילת כל שיחה
> 💡 **Templates System:** מערכת חדשה לתבניות רשימות - ראה WORK_LOG.md
