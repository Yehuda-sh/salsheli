# 🛒 סל שלי (Salsheli)

אפליקציית Flutter מובייל (Android & iOS) לניהול קניות, מלאי וקבלות עם סנכרון בענן.

> **⚠️ Mobile Only** - אין תמיכה ב-Web/Desktop  
> **📱 Platforms:** Android 6.0+ (API 23+) | iOS 12.0+

---

## 📖 תוכן עניינים

- [✨ פיצ'רים](#-פיצרים)
- [🚀 Quick Start](#-quick-start)
- [🔥 Firebase Configuration](#-firebase-configuration)
- [💰 Shufersal API](#-shufersal-api)
- [📂 מבנה הפרויקט](#-מבנה-הפרויקט)
- [📝 מה עובד היום](#-מה-עובד-היום-15102025)
- [📊 סטטיסטיקות](#-סטטיסטיקות)
- [🎯 TODO](#-todo)
- [🛠 פקודות שימושיות](#-פקודות-שימושיות)
- [🐛 בעיות נפוצות](#-בעיות-נפוצות)
- [🤝 תרומה](#-תרומה)
- [🎓 הישגים אחרונים](#-הישגים-אחרונים-06-15102025)
- [🔒 פרטיות ואבטחה](#-פרטיות-ואבטחה)
- [👨‍💻 שולחן עבודה למפתחים](#-שולחן-עבודה-למפתחים)

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
- 🌐 **RTL מלא** - תמיכה בעברית מלאה | אנגלית: TODO (v1.1)
- 🎨 **Sticky Notes Design** - עיצוב ייחודי בהשראת פתקים ומחברות ⭐ (חדש!)

---

## 🚀 Quick Start

### ⚙️ דרישות מוקדמות

| רכיב | גרסה נדרשת | הערות |
|------|-----------|-------|
| **Flutter SDK** | `3.27.0+` | ❗ חובה - גרסאות ישנות לא יעבדו |
| **Dart SDK** | `3.8.1+` | נכלל ב-Flutter |
| **Android Studio** | `2024.1+` | או VS Code עם Flutter extension |
| **Xcode** | `15.0+` (macOS) | ל-iOS builds בלבד |
| **Node.js** | `18.0+` | לסקריפטי Firebase בלבד |

**בדיקת גרסה:**
```bash
flutter doctor -v  # שמור פלט לפתרון בעיות עתידיות
```

### 📚 למפתח חדש - קרא קודם:

| קובץ | מה זה | מתי לקרוא |
| --- | --- | --- |
| **📚 LESSONS_LEARNED.md** | לקחים חשובים + דפוסים טכניים | ⭐ חובה לפני עבודה! |
| **💡 BEST_PRACTICES.md** | Best practices לקוד ועיצוב | ⭐ חובה לכל מפתח! |
| **🎨 STICKY_NOTES_DESIGN.md** | מדריך מלא למערכת העיצוב | לפני עבודה על UI |
| **🤖 AI_QUICK_START.md** | הוראות מהירות לסוכני AI + Code Review אוטומטי ⚡ | ⭐ תן לסוכן בתחילת כל שיחה! |
| **🤖 AI_DEV_GUIDELINES.md** | הנחיות מפורטות לסוכני AI | אם עובד עם AI |  
| **📓 WORK_LOG.md** | שינויים אחרונים + היסטוריה | בתחילת כל יום עבודה |

**🎯 סדר קריאה מומלץ:**
1. **LESSONS_LEARNED.md** - הבסיס הטכני 🏗️
2. **BEST_PRACTICES.md** - איך לכתוב קוד נכון 💻
3. **STICKY_NOTES_DESIGN.md** - איך לעצב UI יפה 🎨
4. **AI_QUICK_START.md** - לסוכן AI (משפט אחד!) ⚡ **← תן לסוכן בתחילת כל שיחה!**
5. **AI_DEV_GUIDELINES.md** - מדריך מפורט ל-AI 🤖

### 🤖 עבודה עם סוכן AI

**📌 תן לסוכן את המשפט הזה בתחילת כל שיחה:**
```
📌 קרא תחילה: C:\projects\salsheli\AI_QUICK_START.md - הוראות חובה לפני עבודה
```

**✨ מה הסוכן עושה אוטומטית:**
- 🔍 **Code Review מלא** - בדיקה וזיהוי של שגיאות טכניות
- 🔧 **תיקון אוטומטי** - withOpacity, async callbacks, const, imports, deprecated APIs
- 🎨 **בדיקת עיצוב** - Sticky Notes Design compliance (מסכי UI חייבים!)
- 📋 **Best Practices** - תיעוד, naming, קוד נקי, constants
- ⚠️ **זיהוי TODO/FIXME** - דיווח על בעיות שצריך לטפל בהן
- ✅ **דיווח תמציתי** - "✅ תיקנתי X, Y, Z - הכל עובד!"

> **🔴 כלל זהב:** הסוכן מתקן שגיאות טכניות מיידית **ללא שאלות**!  
> **📋 Best Practices** - מסך UI ללא Sticky Notes? → החלף מלא! 🎨  
> **✅ רק לשאול:** החלטות עיצוביות משמעותיות או דו-משמעיות

### 📥 התקנה:

```bash
# 1. Clone
git clone https://github.com/Yehuda-Sh/salsheli.git
cd salsheli

# 2. Install Dependencies
flutter pub get

# 3. Generate Code
dart run build_runner build --delete-conflicting-outputs

# 4. משתמשי דמו + נתונים (מומלץ!)
cd scripts
npm install
npm run setup-demo

# 5. Run
flutter run
```

> **💡 טיפ:** אם יש שגיאות build, נקה ונסה שוב:
> ```bash
> flutter clean
> flutter pub get
> dart run build_runner build --delete-conflicting-outputs
> ```

---

## 🔥 Firebase Configuration

### ✅ מה כבר מוגדר:

- **Firebase Core** `3.15.2` - אתחול Firebase
- **Firebase Auth** `5.7.0` - Email/Password authentication
- **Cloud Firestore** `5.4.4` - Real-time database
- **Android:** `android/app/google-services.json` ✅
- **Config:** `lib/firebase_options.dart` ✅

### 📱 iOS Setup (חובה ל-iOS builds):

**חסר:** `ios/Runner/GoogleService-Info.plist`

```bash
# אופציה 1: Firebase Console (מומלץ)
# 1. https://console.firebase.google.com → Project: salsheli
# 2. iOS App → הורד GoogleService-Info.plist
# 3. גרור ל-Xcode: ios/Runner/ (וודא "Copy items if needed")

# אופציה 2: Firebase CLI
flutterfire configure
```

**צעדים נוספים ל-iOS:**
```bash
cd ios
pod install  # התקנת CocoaPods dependencies
cd ..

# ב-Xcode:
# 1. פתח ios/Runner.xcworkspace
# 2. Signing & Capabilities → הוסף Apple ID
# 3. iCloud: לא צריך! (אלא אם רוצה sync עם iCloud)
```

### 👥 משתמשי דמו + נתונים:

```bash
cd scripts && npm run setup-demo
```

**משתמשים:**
- `yoni@demo.com` / `Demo123!` - Household: משפחת כהן
- `sarah@demo.com` / `Demo123!` - Household: רווקה
- `danny@demo.com` / `Demo123!` - Household: שותפים

**מה הסקריפט יוצר ב-Firestore:**

| Collection | מה נוצר | פרטים |
|-----------|--------|-------|
| `users` | 3 משתמשים | Email, household_id, preferences |
| `households` | 3 households | Types: family, single, roommates |
| `shopping_lists` | 3 רשימות | 2 פעילות + 1 הושלמה (מוצרים אמיתיים!) |
| `templates` | 6 תבניות מערכת | סופר, בית מרקחת, יום הולדת, אירוח, משחקים, קמפינג |
| `inventory` | ~15 פריטים | מלאי במוצרים אמיתיים |
| `receipts` | 2 קבלות | OCR parsed + מחירים |

> **💡 חשוב:** הסקריפט החדש (v2) משתמש במוצרים אמיתיים מ-Firestore, לא Mock Data!  
> **🔙 סקריפט ישן:** `npm run setup-demo-old` (אם צריך Mock Data)

### 🔒 Security Rules

**נתיבים חשובים:**
- `firestore.rules` - Firestore Security Rules (household-based)
- `firestore.indexes.json` - Composite indexes
- `scripts/create_system_templates.js` - רק Admin SDK יכול ליצור `is_system: true`

**בדיקת Rules:**
```bash
firebase emulators:start --only firestore  # Test locally
```

---

## 💰 Shufersal API

השירות מוריד מחירים אמיתיים מ-**prices.shufersal.co.il**:

- 📥 **הורדת קבצי XML** - קבצים פומביים, ללא authentication
- 🗜️ **פענוח GZ compressed** - אוטומטי
- 🏪 **3 סניפים** - ~15,000 מוצרים ייחודיים
- 🔄 **עדכון אוטומטי** - בהפעלה + כפתור ידני בהגדרות

**מדיניות שימוש:**
- 🕐 **קצב רענון:** פעם בשעה (מטמון Hive למשך 24 שעות)
- 📊 **כמות בקשות:** מקסימום 10 ליום (limit במערכת)
- 💾 **מטמון:** Hive local cache למשך 7 ימים

> **למה Shufersal?** קבצים פומביים, פשוט, ללא SSL issues.  
> PublishedPrices API יצר SSL certification problems בעבר.

---

## 📂 מבנה הפרויקט

```
lib/
├── main.dart                   # Entry + Firebase init + Providers
├── firebase_options.dart       # Firebase config (auto-generated)
│
├── models/                     # Data models (@JsonSerializable)
│   ├── timestamp_converter.dart    # ⚡ Firestore Timestamp ↔ DateTime
│   ├── user_entity.dart            # User model
│   ├── shopping_list.dart          # Shopping list + items
│   ├── receipt.dart                # Receipt + items
│   ├── inventory_item.dart         # Pantry item
│   ├── product_entity.dart         # Product (Shufersal)
│   ├── template.dart               # 📋 List template + items ⭐ (חדש!)
│   ├── suggestion.dart             # Smart suggestions
│   ├── habit_preference.dart       # 🧠 User habits
│   ├── custom_location.dart        # Storage locations (Firestore) ⭐
│   └── enums/                      # Enums (status, etc.)
│
├── providers/                  # State Management (ChangeNotifier)
│   ├── user_context.dart           # 👤 User + Auth + Household
│   ├── shopping_lists_provider.dart # 🛒 Lists (Firestore)
│   ├── templates_provider.dart     # 📋 Templates ⭐ (חדש!)
│   ├── receipt_provider.dart       # 🧾 Receipts
│   ├── inventory_provider.dart     # 📦 Inventory
│   ├── products_provider.dart      # 💰 Products (Hybrid: Hive + Firestore + API)
│   ├── suggestions_provider.dart   # 💡 Smart suggestions
│   ├── habits_provider.dart        # 🧠 User habits
│   └── locations_provider.dart     # 📍 Custom locations ⭐ (Firestore migration!)
│
├── repositories/              # Data Access Layer (Repository Pattern)
│   ├── firebase_*_repository.dart  # Firestore CRUD (8 repos)
│   ├── templates_repository.dart   # Templates interface ⭐
│   ├── firebase_templates_repository.dart # Templates Firebase impl ⭐
│   ├── locations_repository.dart   # Locations interface ⭐
│   ├── firebase_locations_repository.dart # Locations Firebase impl ⭐
│   ├── hybrid_products_repository.dart # Hive + Firestore + API combo
│   ├── local_products_repository.dart  # Hive cache only
│   └── *_repository.dart           # Interfaces (7 interfaces total)
│
├── services/                  # Business Logic
│   ├── auth_service.dart              # 🔐 Firebase Auth wrapper
│   ├── shufersal_prices_service.dart  # 💰 API client
│   ├── ocr_service.dart               # 📸 ML Kit OCR
│   ├── receipt_parser_service.dart    # 🧾 Regex Parser for receipts
│   ├── home_stats_service.dart        # 📊 Dashboard statistics
│   ├── onboarding_service.dart        # 🎓 User onboarding flow
│   └── prefs_service.dart             # 💾 SharedPreferences wrapper
│
├── screens/                   # UI Screens (30+)
│   ├── auth/                   # Login, Register (2) ⭐ Sticky Notes Design!
│   ├── home/                   # Dashboard + Home (3)
│   ├── shopping/               # Lists, Active shopping (8)
│   ├── lists/                  # Templates, Populate (3)
│   ├── receipts/               # Manager, View (2)
│   ├── pantry/                 # Inventory screen (1)
│   ├── price/                  # Price comparison (1)
│   ├── habits/                 # My habits (1)
│   ├── insights/               # Statistics (1)
│   ├── settings/               # Settings (1)
│   ├── onboarding/             # Welcome flow (2)
│   ├── index_screen.dart       # Splash + Router
│   └── welcome_screen.dart     # First screen
│
├── widgets/                   # Reusable UI Components (25+)
│   ├── common/                 # Dashboard card, Benefit tile, Sticky Notes ⭐
│   ├── home/                   # Suggestions, Upcoming shop
│   ├── auth/                   # Auth button, Demo login
│   └── *.dart                  # Item card, Filters, etc.
│
├── config/                    # Configuration Files ⭐ (Business Logic)
│   ├── household_config.dart       # 11 household types
│   ├── list_type_mappings.dart     # Type → Categories (140+ items)
│   ├── list_type_groups.dart       # 3 groups (Shopping/Specialty/Events)
│   ├── filters_config.dart         # Filter options (11 categories)
│   ├── stores_config.dart          # Store names + variations
│   ├── receipt_patterns_config.dart # OCR Regex patterns
│   ├── pantry_config.dart          # Units, Categories, Locations ⭐
│   └── storage_locations_config.dart # 5 מיקומים (❄️🧊🏠📦📍) ⭐
│
├── core/                      # Core Constants ⭐ (UI + System)
│   ├── constants.dart              # ListType, categories, Firestore collections
│   ├── ui_constants.dart           # Spacing, sizes, durations, borders, Sticky Notes ⭐
│   └── status_colors.dart          # Status colors (theme-aware)
│
├── l10n/                      # Localization (i18n Ready)
│   ├── app_strings.dart            # Main UI strings (עברית)
│   └── strings/                    # Additional string files
│       └── list_type_mappings_strings.dart
│
├── data/                      # Static Data
│   └── onboarding_data.dart        # Onboarding steps data
│
├── layout/                    # Layout Components
│   └── app_layout.dart             # Main app shell
│
└── theme/                     # Theming
    └── app_theme.dart              # Light + Dark themes + Sticky Notes ⭐
```

### 💡 ארכיטקטורה - נקודות מרכזיות

**🎯 Config vs Core:**
- **`lib/config/`** - Business rules, mappings, patterns (140+ items, 8 קבצים)
- **`lib/core/`** - UI constants, system constants (spacing, colors, 3 קבצים)

> **💡 SSOT:** כל ערכי UI קשיחים מגיעים מ-`core/ui_constants.dart`!  
> **💡 Business Logic:** כל patterns/mappings ב-`config/` - לא hardcoded!

**🏗️ Repository Pattern:**
- Interface (`*_repository.dart`) + Implementation (`firebase_*_repository.dart`)
- הפרדת Data Access מ-State Management
- household_id filtering בכל השאילתות

**🎨 Sticky Notes Design System:**
- רכיבים: NotebookBackground, StickyNote, StickyNoteLogo, StickyButton
- קבועים: צבעים, צללים, רווחים, סיבובים
- מדריך מלא: `STICKY_NOTES_DESIGN.md`

**☁️ Firebase Collections:**
```
firestore/
├── users                    # User profiles
├── households               # Household data
├── shopping_lists           # Lists + items
├── templates                # Templates (system + user)
├── inventory                # Pantry items
├── receipts                 # Receipts + parsed items
├── products                 # Products (Shufersal)
├── custom_locations         # Storage locations ⭐
└── user_habits              # Habit preferences
```

---

## 📝 מה עובד היום (15/10/2025)

### ☁️ Firestore + Authentication

- ✅ Email/Password auth + persistent sessions
- ✅ Shopping Lists - real-time sync בין מכשירים
- ✅ **Templates System** - system/personal/shared/assigned ⭐ (חדש!)
- ✅ Receipts, Inventory, Products (1,758 מוצרים)
- ✅ Habits tracking - למידה מהעדפות משתמש
- ✅ **Custom locations** - Cloud storage (Firestore) + household sharing ⭐ (חדש!)
- ✅ Security Rules + Composite Indexes
- ✅ Hybrid Storage: Hive (cache) + Firestore (cloud)

### 💰 Shufersal API + OCR

- ✅ עדכון מחירים אוטומטי (כל שעה) + כפתור ידני
- ✅ OCR מקומי (ML Kit) - offline, ללא API calls
- ✅ זיהוי חנויות: שופרסל, רמי לוי, מגה (regex patterns)
- ✅ חילוץ אוטומטי: פריטים + מחירים + סכום

### 📋 Templates System ⭐ (חדש! 10/10/2025)

- ✅ **6 תבניות מערכת:** סופר, בית מרקחת, יום הולדת, אירוח, משחקים, קמפינג
- ✅ **66 פריטים** בתבניות מערכת (10-12 פריטים לכל תבנית)
- ✅ **4 formats:** system, personal, shared, assigned
- ✅ **Security:** רק Admin SDK יכול ליצור `is_system: true`
- ✅ **Collaborative editing:** כל household יכול לערוך shared templates

### 🎨 UI/UX

- ✅ **Sticky Notes Design System** - עיצוב ייחודי בהשראת פתקים ⭐ (חדש! 15/10/2025)
- ✅ **מסך התחברות** - Sticky Notes Design מלא ⭐ (חדש! 15/10/2025)
- ✅ 21 סוגי רשימות + מסך קנייה פעילה
- ✅ Undo למחיקה (5 שניות עם SnackBar)
- ✅ 3-4 Empty States: Loading/Error/Empty/Initial
- ✅ RTL מלא (עברית) + Dark/Light themes
- ✅ מיקומי אחסון מותאמים (5: מקרר, מקפיא, מזווה, ארונות, מותאם)
- ✅ Modern Design - gradients, shadows, elevation
- ✅ Compact layouts - מסכים ללא גלילה עם צמצום חכם ⭐

---

## 📊 סטטיסטיקות

| קטגוריה | כמות | הערות |
|---------|------|-------|
| **קבצי Dart** | 100+ | ב-lib/ (ללא .g.dart) |
| **Models** | 11 | כולל Template + CustomLocation |
| **Providers** | 9 | כולל Templates + Locations (Firestore) |
| **Repositories** | 17 | 8 Firebase + 7 interfaces + 2 special |
| **Services** | 7 | Auth, Shufersal, OCR, Parser, Stats, Onboarding, Prefs |
| **Screens** | 30+ | מסכים מלאים עם routing |
| **Widgets** | 25+ | רכיבי UI לשימוש חוזר + Sticky Notes |
| **Config Files** | 8 | Business rules + patterns |
| **Core Constants** | 3 | UI + System constants + Sticky Notes |
| **תבניות מערכת** | 6 | 66 פריטים סה"כ |
| **מוצרים** | 1,758 | Hive cache + Firestore |
| **סוגי רשימות** | 21 | עם 140+ פריטים מוצעים |
| **משתמשי דמו** | 3 | Yoni, Sarah, Danny |
| **מסמכי תיעוד** | 6 | README, LESSONS, BEST_PRACTICES, DESIGN, AI_QUICK_START, AI_GUIDELINES |

---

## 🎯 TODO

### 🔴 גבוה (Priority 1)

- [ ] iOS GoogleService-Info.plist + pod setup
- [ ] Collaborative shopping - שיתוף real-time של רשימה פעילה
- [ ] Receipt OCR improvements - דיוק גבוה יותר
- [ ] Template sharing - העברת תבניות בין משתמשים
- [ ] **Sticky Notes Design** - מסך הרשמה (Register screen) ⭐

### 🟡 בינוני (Priority 2)

- [ ] Offline mode מלא - Hive cache עם sync queue
- [ ] Smart notifications - תזכורות לקנייה
- [ ] Price tracking - גרפים + השוואה היסטורית
- [ ] Template categories + search - ארגון טוב יותר
- [ ] **Sticky Notes Design** - מסכי shopping lists + מסכים נוספים ⭐

### 🟢 נמוך (Priority 3)

- [ ] Tests - Unit/Widget/Integration (coverage 80%+)
- [ ] i18n - אנגלית מלאה (כרגע רק עברית)
- [ ] Performance optimization - profiling + optimization
- [ ] Custom template icons - אייקונים מותאמים אישית

### ✅ הושלם לאחרונה (06-15/10/2025)

- ~~**Sticky Notes Design System** - מסך התחברות~~ (15/10) ⭐
- ~~**BEST_PRACTICES.md** + **STICKY_NOTES_DESIGN.md**~~ (15/10) ⭐
- ~~**AI_QUICK_START.md** - Code Review אוטומטי~~ (15/10) ⭐
- ~~LocationsProvider → Firebase Migration~~ (13/10) ⭐
- ~~Batch Processing Pattern - 100+ items~~ (13/10) ⭐
- ~~InventoryProvider Error Recovery~~ (13/10) ⭐
- ~~Templates System - Foundation + 6 תבניות~~ (10/10) ⭐
- ~~Shopping Lists → Firestore~~ (09/10)
- ~~Shufersal API integration~~ (08/10)
- ~~OCR מקומי (ML Kit)~~ (08/10)
- ~~Dead Code cleanup (5,000+ שורות)~~ (07-08/10)
- ~~140+ suggested items (21 קטגוריות)~~ (08/10)
- ~~Config Files Pattern (8 קבצים)~~ (08/10)

---

## 🛠 פקודות שימושיות

### 🔧 Development

```bash
# התקנת dependencies
flutter pub get

# יצירת קוד אוטומטי (.g.dart files)
dart run build_runner build --delete-conflicting-outputs

# הרצה (Debug mode)
flutter run

# הרצה עם device ספציפי
flutter devices
flutter run -d <device-id>

# Hot reload - קיצור מקלדת
# r - reload
# R - hot restart
# q - quit
```

### ✅ Quality & Analysis

```bash
# ניתוח קוד (0 issues = ✅)
flutter analyze

# פורמט קוד
dart format lib/ -w

# בדיקת dependencies
flutter pub outdated

# בדיקת environment
flutter doctor -v
```

### 📦 Build (Production)

```bash
# Android APK
flutter build apk --release

# Android App Bundle (לGoogle Play)
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release

# ⚠️ לא תריץ! (Mobile only)
# flutter build web  # ❌ לא נתמך
# flutter build windows  # ❌ לא נתמך
```

### 🔥 Firebase Scripts

```bash
cd scripts

# התקנת npm dependencies (פעם ראשונה)
npm install

# יצירת 3 משתמשי דמו
npm run create-users

# העלאת 1,758 מוצרים ל-Firestore
npm run upload-products

# יצירת 6 תבניות מערכת (Admin SDK)
npm run create-system-templates

# יצירת נתוני דמו - מוצרים אמיתיים (מומלץ!)
npm run create-data-real

# יצירת נתוני דמו - Mock Data (ישן)
npm run create-data

# הכל ביחד! (users + templates + data)
npm run setup-demo

# בדיקת Firestore Rules
firebase emulators:start --only firestore
```

---

## 🐛 בעיות נפוצות

| בעיה | פתרון | קישור |
|------|-------|-------|
| **iOS קורס בהרצה** | `GoogleService-Info.plist` חסר → הורד מFirebase Console | [iOS Setup](#-ios-setup-חובה-ל-ios-builds) |
| **Android קורס בהרצה** | בדוק `google-services.json` בנתיב הנכון | [Firebase Config](#-firebase-configuration) |
| **רשימות לא נטענות** | בדוק snake_case ב-Firestore (@JsonKey בmodels) | [LESSONS_LEARNED](LESSONS_LEARNED.md#timestamp-management) |
| **Templates לא נטענות** | הרץ `npm run create-system-templates` | [Templates](#-templates-system--חדש-10102025) |
| **Race condition בהתחברות** | Firebase Auth אסינכרוני - ה-IndexScreen מחכה ל-`isLoading: false` | [LESSONS_LEARNED](LESSONS_LEARNED.md#race-condition-firebase-auth) |
| **Build runner fails** | מחק `build/` + `*.g.dart`, הרץ `flutter clean` ואז build runner שוב | - |
| **שגיאת "Access denied"** | נתיב קובץ לא מלא → השתמש ב-`C:\projects\salsheli\...` | [AI_DEV_GUIDELINES](AI_DEV_GUIDELINES.md#file-paths) |
| **CircularProgressIndicator איטי** | השתמש ב-Batch Processing (50-100 items) לשמירה/טעינה | [LESSONS_LEARNED](LESSONS_LEARNED.md#batch-processing-pattern) |
| **Deprecated API warnings** | `.withOpacity()` → `.withValues(alpha:)` | [BEST_PRACTICES](BEST_PRACTICES.md#שימוש-נכון-ב-withvalues) |
| **Async callback errors** | עטוף Future functions בלמבדה: `() => _asyncFunc()` | [BEST_PRACTICES](BEST_PRACTICES.md#עבודה-עם-async-functions) |
| **Sticky Notes לא נראים** | בדוק שיש `NotebookBackground` + `kPaperBackground` | [STICKY_NOTES_DESIGN](STICKY_NOTES_DESIGN.md#notebookbackground) |
| **AI סוכן לא עוקב הוראות** | תן לו: `📌 קרא תחילה: AI_QUICK_START.md` | [AI Quick Start](#-עבודה-עם-סוכן-ai) |

> **💡 עוד פתרונות:** ראה [LESSONS_LEARNED.md](LESSONS_LEARNED.md) חלק "Troubleshooting"  
> **💡 Best Practices:** ראה [BEST_PRACTICES.md](BEST_PRACTICES.md) לדפוסי קוד נכונים

---

## 🤝 תרומה

רוצה לתרום לפרויקט? מעולה! 🎉

### 📋 תהליך התרומה:

1. **Fork + Branch**
   ```bash
   git checkout -b feature/my-amazing-feature
   ```

2. **📚 קרא תיעוד (חובה!)**
   - `LESSONS_LEARNED.md` - דפוסים טכניים + לקחים
   - `BEST_PRACTICES.md` - Best practices לקוד ועיצוב
   - `STICKY_NOTES_DESIGN.md` - מערכת העיצוב (אם עובד על UI)
   - `AI_DEV_GUIDELINES.md` - הנחיות פיתוח
   - `WORK_LOG.md` - שינויים אחרונים

3. **✍️ כתוב קוד איכותי:**
   - עקוב אחר דפוסים ב-LESSONS_LEARNED
   - קרא את BEST_PRACTICES לפני כתיבה
   - השתמש ב-Sticky Notes Design System לUI
   - 3-4 Empty States בwidgets חדשים
   - Logging מפורט בכל method (🗑️ ✏️ ➕ 🔄 ✅ ❌)
   - Constants לכל hardcoded values
   - Repository Pattern לdata access

4. **✅ לפני commit:**
   ```bash
   # ניתוח קוד
   flutter analyze  # 0 issues!
   
   # פורמט
   dart format lib/ -w
   
   # בדיקת איכות
   # עבור על BEST_PRACTICES Code Review Checklist
   ```

5. **🚀 Commit + PR**
   ```bash
   git commit -m "feat: הוספת [feature]"
   git push origin feature/my-amazing-feature
   # צור Pull Request ב-GitHub
   ```

### 📝 Convention:

**Commit Messages:**
- `feat: הוספת תכונה חדשה`
- `fix: תיקון באג`
- `refactor: שיפור קוד קיים`
- `docs: עדכון תיעוד`
- `style: שינויי UI/UX`
- `design: עיצוב Sticky Notes`

---

## 🎓 הישגים אחרונים (06-15/10/2025)

### ⭐ תשתית ופיצ'רים חדשים

- ✅ **AI Quick Start + Code Review אוטומטי** (15/10)
  - AI_QUICK_START.md - הוראות מהירות לסוכן
  - Code Review אוטומטי בקריאת קובץ
  - תיקון שגיאות טכניות מיידי
  - בדיקת Sticky Notes Design
  - תיקון Best Practices

- ✅ **Sticky Notes Design System** (15/10)
  - מערכת עיצוב מלאה בהשראת פתקים
  - רכיבים: NotebookBackground, StickyNote, StickyButton
  - מסך התחברות מעוצב מחדש
  - מדריך מלא: STICKY_NOTES_DESIGN.md

- ✅ **Best Practices Documentation** (15/10)
  - BEST_PRACTICES.md - מדריך מקיף
  - דפוסי קוד נכונים
  - עיצוב Compact למסכים
  - טיפים לביצועים ונגישות

- ✅ **LocationsProvider → Firebase Migration** (13/10)
  - מעבר מ-SharedPreferences ל-Firestore
  - household sharing + collaborative editing
  - Real-time sync בין מכשירים

- ✅ **Batch Processing Pattern** (13/10)
  - ביצועים: 100+ items בחבילות של 50-100
  - UI responsive + Progress tracking
  - מניעת UI blocking

- ✅ **InventoryProvider Error Recovery** (13/10)
  - `retry()` + `clearAll()` methods
  - Error handling מלא

- ✅ **Templates System מלא** (10/10)
  - 6 תבניות מערכת (66 פריטים)
  - 4 formats: system/personal/shared/assigned
  - Security: Admin SDK only לsystem templates

### 🏗️ ארכיטקטורה

- ✅ Firebase Integration מלא - Auth + Firestore + Security Rules
- ✅ Repository Pattern - 17 repositories (8 Firebase + 7 interfaces)
- ✅ Config Files Pattern - 8 קבצי config לbusiness logic
- ✅ UserContext Integration - Listener pattern בכל Providers

### 🚀 ביצועים ואיכות

- ✅ Dead Code cleanup - 5,000+ שורות נמחקו (08/10)
- ✅ Code Review מקיף - 100/100 בכל Providers
- ✅ Providers עקביים - Error Handling + Logging + Recovery
- ✅ תיקון ביצועים - 0 Skipped Frames
- ✅ OCR מקומי (ML Kit) - offline, ללא API calls

### 📚 תיעוד

- ✅ **AI_QUICK_START.md** - הוראות מהירות לסוכן AI ⭐
- ✅ LESSONS_LEARNED.md - 15 עקרונות זהב + דפוסים מפורטים
- ✅ BEST_PRACTICES.md - Best practices מקיפים ⭐
- ✅ STICKY_NOTES_DESIGN.md - מדריך עיצוב מלא ⭐
- ✅ AI_DEV_GUIDELINES.md - v8.0 + Modern UI/UX patterns
- ✅ WORK_LOG.md - תיעוד שינויים + לקחים

### 🎨 UI/UX

- ✅ Sticky Notes Design System - עיצוב ייחודי ⭐
- ✅ 140+ פריטים מוצעים - 21 קטגוריות רשימות
- ✅ Modern Design - gradients, shadows, elevation
- ✅ 3-4 Empty States - בכל widget
- ✅ RTL מלא - תמיכה בעברית מושלמת
- ✅ Compact layouts - צמצום חכם של רווחים ⭐

### 💰 אינטגרציות

- ✅ Shufersal API - 1,758 מוצרים + מחירים אמיתיים
- ✅ ML Kit OCR - סריקת קבלות offline
- ✅ Hybrid Storage - Hive cache + Firestore cloud

---

## 🔒 פרטיות ואבטחה

### 🛡️ מה אנחנו שומרים:

| נתון | איפה | מטרה |
|------|------|------|
| **Email** | Firebase Auth | התחברות + זיהוי |
| **household_id** | Firestore | קישור למשק בית |
| **רשימות קניות** | Firestore | סנכרון בין מכשירים |
| **מחירי מוצרים** | Hive (local) | cache למהירות |
| **העדפות משתמש** | Firestore | הרגלי קנייה |

### 🔐 אבטחה:

- ✅ **Security Rules** - Firestore מסנן לפי household_id
- ✅ **No passwords** - Firebase Auth מטפל בהצפנה
- ✅ **Local cache** - Hive מוצפן במכשיר
- ✅ **Templates** - רק Admin SDK יכול ליצור system templates

### 🗑️ מחיקת נתונים:

```
Settings → חשבון → מחק חשבון
↓
מוחק: Auth + כל נתוני Firestore + Local cache
```

> **💡 Demo users:** נתוני דמו נמחקים אוטומטית כל שבועיים.

---

## 👨‍💻 שולחן עבודה למפתחים

### 📚 מדריכים מרכזיים

| מסמך | מה בפנים | קישור |
|------|----------|-------|
| **LESSONS_LEARNED** | דפוסים טכניים + ארכיטקטורה | [📖](LESSONS_LEARNED.md) |
| **BEST_PRACTICES** | Best practices לקוד ועיצוב ⭐ | [💡](BEST_PRACTICES.md) |
| **STICKY_NOTES_DESIGN** | מדריך מלא למערכת העיצוב ⭐ | [🎨](STICKY_NOTES_DESIGN.md) |
| **AI_QUICK_START** | הוראות מהירות לסוכני AI ⚡ | [🤖](AI_QUICK_START.md) |
| **AI_DEV_GUIDELINES** | הנחיות מפורטות לסוכני AI | [🤖](AI_DEV_GUIDELINES.md) |
| **WORK_LOG** | שינויים אחרונים | [📓](WORK_LOG.md) |

### 🎯 קישורים מהירים ל-LESSONS_LEARNED

#### 🏗️ ארכיטקטורה

| נושא | קישור |
|------|-------|
| **Firebase Integration** | [→](LESSONS_LEARNED.md#-מעבר-ל-firebase) |
| **Timestamp Management** | [→](LESSONS_LEARNED.md#-timestamp-management) |
| **household_id Pattern** | [→](LESSONS_LEARNED.md#-householdid-pattern) |
| **Repository Pattern** | [→](LESSONS_LEARNED.md#%EF%B8%8F-repository-pattern) |
| **Templates System** | [→](LESSONS_LEARNED.md#-templates-security-model) |

#### 💻 דפוסי קוד

| נושא | קישור |
|------|-------|
| **UserContext Pattern** | [→](LESSONS_LEARNED.md#-usercontext-pattern) |
| **Provider Structure** | [→](LESSONS_LEARNED.md#-provider-structure) |
| **Batch Processing** | [→](LESSONS_LEARNED.md#-batch-processing-pattern) |
| **Constants Organization** | [→](LESSONS_LEARNED.md#-constants-organization) |

#### 🎨 UI/UX

| נושא | קישור |
|------|-------|
| **3-4 Empty States** | [→](LESSONS_LEARNED.md#-3-4-empty-states) |
| **Undo Pattern** | [→](LESSONS_LEARNED.md#%EF%B8%8F-undo-pattern) |
| **Modern Design** | [→](LESSONS_LEARNED.md#-modern-design-principles) |

### 💡 קישורים מהירים ל-BEST_PRACTICES

| נושא | קישור |
|------|-------|
| **עיצוב Compact** | [→](BEST_PRACTICES.md#עיצוב-מסכים-compact-) |
| **Async Functions** | [→](BEST_PRACTICES.md#עבודה-עם-async-functions) |
| **withValues** | [→](BEST_PRACTICES.md#שימוש-נכון-ב-withvalues) |
| **Context Management** | [→](BEST_PRACTICES.md#context-management-בפונקציות-אסינכרוניות) |
| **Loading States** | [→](BEST_PRACTICES.md#state-management-עם-loading-states) |
| **UX Best Practices** | [→](BEST_PRACTICES.md#-ux-best-practices) |

### 🎨 קישורים מהירים ל-STICKY_NOTES_DESIGN

| נושא | קישור |
|------|-------|
| **סקירה כללית** | [→](STICKY_NOTES_DESIGN.md#-סקירה-כללית) |
| **רכיבים** | [→](STICKY_NOTES_DESIGN.md#-רכיבים-משותפים) |
| **עיצוב Compact** | [→](STICKY_NOTES_DESIGN.md#-עיצוב-compact---מסכים-ללא-גלילה) |
| **דוגמאות** | [→](STICKY_NOTES_DESIGN.md#-דוגמאות-שימוש-מלאות) |
| **פתרון בעיות** | [→](STICKY_NOTES_DESIGN.md#-פתרון-בעיות-נפוצות) |

### 🤖 קישורים מהירים ל-AI_QUICK_START

| נושא | קישור |
|------|-------|
| **Code Review אוטומטי** | [→](AI_QUICK_START.md#-code-review-אוטומטי---מול-תיעוד-הפרויקט) |
| **קישור לקובץ - מה לעשות** | [→](AI_QUICK_START.md#-קישור-לקובץ-בתחילת-שיחה---מה-לעשות) |
| **כללי עבודה** | [→](AI_QUICK_START.md#-כללי-עבודה---קרא-וזכור) |
| **ניהול Tokens** | [→](AI_QUICK_START.md#-ניהול-tokens---חשוב-מאוד-) |
| **TL;DR** | [→](AI_QUICK_START.md#-tldr---תזכורת-של-10-שניות) |

### 📊 מדדי איכות

```
✅ flutter analyze  # 0 issues
✅ Code Review      # 100/100
✅ Dead Code        # 0 files
✅ Providers        # Error Recovery + Logging
✅ Constants        # lib/core/ + lib/config/
✅ Empty States     # 3-4 בכל widget
✅ Design System    # Sticky Notes מלא
✅ Documentation    # 6 מדריכים מקיפים ⭐
✅ AI Integration   # Code Review אוטומטי ⭐
```

---

## 📄 רישיון

MIT License - ראה [LICENSE](LICENSE)

---

**עדכון:** 15/10/2025 | **גרסה:** 1.2.0 | **Made with ❤️ in Israel** 🇮🇱

> 💡 **למפתחים:** התחל עם [LESSONS_LEARNED.md](LESSONS_LEARNED.md) - הכי חשוב!  
> 💡 **Best Practices:** קרא [BEST_PRACTICES.md](BEST_PRACTICES.md) לפני כתיבת קוד  
> 💡 **עיצוב UI:** השתמש ב-[STICKY_NOTES_DESIGN.md](STICKY_NOTES_DESIGN.md) למערכת העיצוב  
> 💡 **לסוכני AI:** תן את המשפט: `📌 קרא תחילה: AI_QUICK_START.md` ⚡  
> 💡 **פיתוח עם AI:** קרא [AI_DEV_GUIDELINES.md](AI_DEV_GUIDELINES.md) למדריך מפורט  
> 💡 **Templates System:** מערכת חדשה - ראה [WORK_LOG.md](WORK_LOG.md) רשומה 10/10/2025
