# 🛒 סל שלי (Salsheli) — אפליקציית קניות חכמה

📱 **אפליקציית מובייל** (Android & iOS) בנויה ב-**Flutter** לניהול רשימות קניות, מלאי, קבלות והרגלי צריכה.  
עם תמיכה מלאה ב־RTL, תבניות חכמות ותובנות.

הפרויקט בנוי בשכבות ברורות: **Models → Repositories → Providers → UI**, עם היערכות לחיבור עתידי ל־Firebase / REST API.

> **⚠️ שים לב:** אפליקציה זו מיועדת **למכשירי מובייל בלבד** (Android & iOS). אין תמיכה ב-Web או Desktop.

---

## 📋 תוכן עניינים

- [פיצ'רים עיקריים](#-פיצרים-עיקריים)
- [דרישות מוקדמות](#-דרישות-מוקדמות)
- [התקנה והגדרה](#-התקנה-והגדרה)
- [📚 הנחיות למפתחים](#-הנחיות-למפתחים)
- [ארכיטקטורה](#-ארכיטקטורה-layers)
- [מבנה הפרויקט](#-מבנה-פרוייקט-מפורט)
- [זרימת משתמש](#-זרימת-משתמש-flow)
- [מצב נוכחי](#-מה-עובד-היום)
- [משימות לביצוע](#-משימות-לביצוע-todo)
- [פקודות שימושיות](#-פקודות-שימושiות)
- [בדיקות](#-בדיקות-testing)

---

## ✨ פיצ'רים עיקריים

- 📋 **רשימות קניות** – יצירה/עריכה/מחיקה, תבניות מוכנות ותצוגת סטטוס
- 🤝 **שיתוף משפחתי** _(בפיתוח)_ – רשימות משותפות בין בני הבית
- 🧾 **קבלות** – מודל Receipt + תצוגה/סריקה (כולל Mock), המרות JSON
- 🏠 **מזווה / מלאי** – ניהול Inventory למניעת קניות כפולות
  - 📍 **ניהול מיקומי אחסון** _(חדש!)_ – ארגון פריטים לפי מיקומים (מקרר, מזווה, מקפיא וכו')
  - ➕ **מיקומים מותאמים** – הוספה, עריכה ומחיקה של מיקומים אישיים
  - 🔍 **חיפוש וסינון** – מציאת פריטים לפי מיקום, שם או קטגוריה
  - 📊 **סטטיסטיקות** – סה"כ פריטים, אזהרות מלאי נמוך ועוד
- 📊 **תובנות ותקציב** – מגמות וחיזוי _(מתפתח)_
- 🔔 **התראות חכמות** – תוקף מוצרים/רכישות צפויות _(בתכנון)_
- 🌐 **RTL מלא** – תמיכה מלאה בעברית
- 🎨 **Theme אחיד** – מצב Light/Dark מותאם למותג
- 🧠 **Smart Suggestions** – המלצות חכמות למוצרים על בסיס מזווה והיסטוריית קניות

---

## 🔧 דרישות מוקדמות

לפני התחלת העבודה, וודא שיש לך:

- **Flutter SDK** >= 3.8.1
- **Dart SDK** >= 3.8.1
- **מכשיר/אמולטור מובייל** (Android או iOS)

> **💾 אחסון מקומי:** הפרויקט משתמש ב-**Hive** לאחסון מקומי של מוצרים ו-**SharedPreferences** למיקומים מותאמים

### כלי פיתוח

- **Android Studio** (לפיתוח Android)
  - Android SDK
  - Android Emulator
- **Xcode** (לפיתוח iOS - macOS בלבד)
  - iOS Simulator
- **VS Code** עם תוסף Flutter (אופציונלי)
- **Git** לניהול גרסאות

> **📱 חשוב:** אפליקציה זו מיועדת למובייל בלבד. פקודות build ל-Web/Desktop לא נתמכות.

### בדיקת סביבה

```bash
flutter doctor
```

---

## 📥 התקנה והגדרה

### 1. שכפול הפרוייקט

```bash
git clone https://github.com/your-username/salsheli.git
cd salsheli
```

### 2. התקנת תלויות

```bash
flutter pub get
```

### 3. יצירת קבצי קוד אוטומטיים

הפרוייקט משתמש ב-`build_runner` ליצירת קבצי `*.g.dart`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. הרצת האפליקציה

```bash
# הרצה על אמולטור או מכשיר מחובר
flutter run

# הרצה במצב debug עם hot reload
flutter run --debug

# הרצה במצב release (ביצועים מיטביים)
flutter run --release
```

### 5. בניית APK לאנדרואיד

```bash
flutter build apk --release
```

### 6. בניית IPA ל-iOS

```bash
flutter build ios --release
```

---

## 📚 הנחיות למפתחים

לפני שמתחילים לעבוד על הפרויקט, **חובה לקרוא** את מסמכי ההנחיות:

### 📄 מסמכים חשובים

#### 0. [WORK_LOG.md](./WORK_LOG.md) 📓 **חדש!**

יומן תיעוד עבודה של הפרויקט - תיעוד כל משימה ומשימה:

- 📅 תאריכים ומשימות
- ✅ מה הושלם בכל שלב
- 📂 קבצים שהושפעו
- 🔄 מה נותר לעתיד
- 💡 הערות חשובות לזכור

**👉 קרא את זה בתחילת כל שיחה חדשה כדי להמשיך מהנקודה הנכונה!**

#### 1. [MOBILE_GUIDELINES.md](./MOBILE_GUIDELINES.md)

מסמך מקיף עם הנחיות טכניות לפיתוח אפליקציית מובייל:

- ✅ כללי זהב למובייל
- ❌ מה אסור בהחלט (Web APIs, Desktop packages)
- 🏗️ ארכיטקטורה ומבנה
- 🚀 **Splash & Initial Navigation** - איך לבנות מסכי אתחול נכון
- 🎨 UI/UX למובייל
- 🔄 State Management
- 🧭 Navigation Patterns
- 🛡️ Error Handling
- ⚡ Performance
- 💾 Storage & Persistence
- ✅ Code Review Checklist

**👉 חובה לקרוא לפני כתיבת קוד חדש!**

#### 2. [CODE_REVIEW_CHECKLIST.md](./CODE_REVIEW_CHECKLIST.md)

Checklist מהיר לבדיקת קבצים לפי סוג:

- ✅ Providers - מה לבדוק
- ✅ Screens - מה לבדוק
- ✅ Models - מה לבדוק
- ✅ Repositories - מה לבדוק
- 🔍 טיפים לבדיקה מהירה
- 📊 זמני בדיקה משוערים

**👉 השתמש בזה לפני כל commit!**

#### 3. [FULL_REPORT.md](./FULL_REPORT.md)

דוח מקיף של שיפורים אפשריים:

- 📱 ניתוח מפורט לפי מסך
- 🔄 זיהוי רכיבים כפולים
- 📂 המלצות לארגון קבצים
- 🎨 עקביות בעיצוב

**👉 שימושי לתכנון שיפורים עתידיים**

### 🎯 כללים חשובים

1. **מובייל בלבד** - אין תמיכה ב-Web/Desktop
2. **תיעוד חובה** - כל קובץ חייב הערת תיעוד בראש
3. **RTL תמיכה** - השתמש ב-`symmetric` ולא `only`
4. **Error Handling** - תמיד `try-catch` + `mounted` checks
5. **No hardcoded values** - צבעים/גדלים דרך Theme

### 🤖 לעבודה עם AI Tools

אם אתה משתמש ב-Claude Code או כלי AI אחר:

- תמיד תן לכלי לקרוא את `MOBILE_GUIDELINES.md` קודם
- תן לו לבדוק את הקוד לפי `CODE_REVIEW_CHECKLIST.md`
- הפנה אותו ל-`FULL_REPORT.md` לרעיונות שיפור

---

## 🏗 ארכיטקטורה (Layers)

הפרוייקט בנוי בארכיטקטורת שכבות נקייה:

```
UI Layer (Screens/Widgets)
    ↓
State Management (Providers)
    ↓
Business Logic (Services)
    ↓
Data Layer (Repositories)
    ↓
Data Sources (Local/API)
```

### שכבות עיקריות

#### 1. Models (`lib/models/`)

מודלי הדאטה של האפליקציה:

- `UserEntity` - משתמש
- `ShoppingList` - רשימת קניות
- `Receipt` - קבלה
- `ReceiptItem` - פריט ברשימה/קבלה
- `InventoryItem` - פריט במלאי
- `CustomLocation` - מיקום אחסון מותאם _(חדש!)_
- `ProductEntity` - מוצר (עם Hive)
- `PriceData` - מידע על מחירים
- `Suggestion` - הצעה חכמה

כולל `*.g.dart` באמצעות `json_serializable` ו-Hive adapters.

#### 2. Repositories (`lib/repositories/`)

שכבת גישה לנתונים:

**Products - ארכיטקטורה היברידית:**
- `products_repository.dart` - ממשק
- `hybrid_products_repository.dart` - משלב local (Hive) + API
- `local_products_repository.dart` - אחסון מקומי ב-Hive
- `published_prices_service.dart` - API משרד הכלכלה

**אחרים:**
- `user_repository.dart` - ניהול משתמשים
- `shopping_lists_repository.dart` - ממשק לרשימות
- `local_shopping_lists_repository.dart` - מימוש לוקאלי
- `inventory_repository.dart` - ניהול מלאי
- `receipt_repository.dart` - ניהול קבלות
- `price_data_repository.dart` - מחירים
- `suggestions_repository.dart` - הצעות

#### 3. Providers (`lib/providers/`)

State Management באמצעות ChangeNotifier:

- `UserContext` - מצב המשתמש הגלובלי
- `ShoppingListsProvider` - ניהול רשימות
- `InventoryProvider` - ניהול מלאי
- `LocationsProvider` - ניהול מיקומי אחסון מותאמים _(חדש!)_
- `ReceiptProvider` - ניהול קבלות
- `PriceDataProvider` - מחירים
- `SuggestionsProvider` - הצעות
- `NotificationsProvider` - התראות

#### 4. Services (`lib/services/`)

לוגיקה עסקית ושירותים:

- `user_service.dart` - שירותי משתמש
- `local_storage_service.dart` - אחסון מקומי
- `prefs_service.dart` - העדפות
- `receipt_service.dart` + `receipt_service_mock.dart` - קבלות
- `price_updater.dart` - עדכון מחירים
- `home_stats_service.dart` - סטטיסטיקות

#### 5. UI

- **Layout**: `app_layout.dart` – AppBar/Drawer/Bottom Nav + Offline banner
- **Screens**: Auth, Onboarding, Home, Shopping, Receipts, Pantry, Insights, Profile, Settings
- **Widgets**: רכיבים לשימוש חוזר
  - `StorageLocationManager` - ווידג'ט מתקדם לניהול מיקומי אחסון _(חדש!)_

---

## 📂 מבנה פרוייקט מפורט

```
salsheli/
├── android/                    # קונפיגורציה אנדרואיד
├── ios/                        # קונפיגורציה iOS
├── lib/
│   ├── main.dart              # נקודת הכניסה
│   ├── api/
│   │   └── entities/          # ישויות API
│   ├── config/                # קונפיגורציות
│   ├── core/
│   │   └── constants.dart    # קבועים גלובליים (כולל מיקומי אחסון)
│   ├── data/                  # נתוני דמו/Onboarding
│   ├── gen/                   # קבצים שנוצרו אוטומטית
│   ├── helpers/               # פונקציות עזר
│   ├── layout/
│   │   └── app_layout.dart   # Layout ראשי
│   ├── models/                # מודלי דאטה
│   │   ├── *.dart
│   │   ├── *.g.dart          # קבצים שנוצרו
│   │   ├── custom_location.dart  # מודל מיקום מותאם (חדש!)
│   │   └── mappers/          # מיפוי בין שכבות
│   ├── providers/             # State Management
│   │   ├── locations_provider.dart  # ניהול מיקומים (חדש!)
│   │   └── ...
│   ├── repositories/          # שכבת דאטה
│   ├── screens/               # מסכים
│   │   ├── auth/             # התחברות/הרשמה
│   │   ├── home/             # מסך הבית
│   │   ├── shopping/         # רשימות קניות
│   │   ├── receipts/         # קבלות
│   │   ├── pantry/           # מזווה (עם טאבים!)
│   │   │   └── my_pantry_screen.dart  # מסך מזווה משודרג
│   │   ├── insights/         # תובנות
│   │   └── settings/         # הגדרות
│   ├── services/              # שירותים
│   ├── theme/
│   │   └── app_theme.dart    # עיצוב אחיד
│   ├── utils/                 # כלי עזר
│   └── widgets/               # Widgets לשימוש חוזר
│       ├── common/           # רכיבים כלליים
│       ├── auth/             # רכיבי אימות
│       ├── shopping/         # רכיבי קניות
│       ├── home/             # רכיבי דף הבית
│       └── storage_location_manager.dart  # ניהול מיקומים (חדש!)
├── assets/
│   ├── data/
│   │   ├── products.json     # מוצרים לדמו
│   │   └── inventory.json    # מלאי לדמו
│   ├── templates/            # תבניות JSON
│   ├── fonts/                # פונטים (Assistant)
│   └── images/               # תמונות
├── WORK_LOG.md               # 📓 יומן עבודה (חדש!)
├── MOBILE_GUIDELINES.md      # 📚 הנחיות פיתוח למובייל
├── CODE_REVIEW_CHECKLIST.md # ✅ Checklist לבדיקת קוד
├── FULL_REPORT.md            # 📊 דוח שיפורים מקיף
├── pubspec.yaml              # תלויות הפרוייקט
└── README.md                 # הקובץ הזה
```

---

## 🧭 זרימת משתמש (Flow)

### תרשים זרימה ראשי

```
IndexScreen (מסך פתיחה)
    ↓
    ↓ [בודק מצב משתמש]
    ↓
    ├─→ (יש userId?) → YES → HomeScreen ✅
    │
    └─→ NO → (ראה Onboarding?)
              ├─→ NO → WelcomeScreen → OnboardingScreen → LoginScreen
              └─→ YES → LoginScreen / RegisterScreen
                         ↓
                         ↓ (לאחר התחברות)
                         ↓
                      HomeScreen
                         ↓
         ┌───────────────┼───────────────┐
         ↓               ↓               ↓
    Dashboard      Shopping Lists    Pantry 📦
         ↓               ↓               ↓
    Insights        Settings         Profile
```

### 🔄 זרימת IndexScreen (מעודכן!)

**סדר בדיקות קריטי:**

1. **קודם:** בדיקת `userId` (האם מחובר?)

   - אם **כן** → ישר ל-HomeScreen ✅
   - אם **לא** → ממשיך לבדיקה הבאה

2. **שנית:** בדיקת `seenOnboarding` (האם ראה ברכה?)
   - אם **לא** → WelcomeScreen
   - אם **כן** → LoginScreen

> **💡 למה הסדר חשוב?**  
> משתמש מחובר צריך להגיע **תמיד** לדף הבית, גם אם הוא מחק את ה-flag של onboarding!

### 📍 זרימת מסך המזווה (Pantry) - חדש!

```
MyPantryScreen
    ↓
    ├─→ טאב 1: "רשימה" 📋
    │   ├── חיפוש פריטים
    │   ├── סטטיסטיקות (סה"כ, מלאי נמוך, מיקומים)
    │   ├── פריטים מקובצים לפי מיקום
    │   └── הוספה/עריכה/מחיקה של פריטים
    │
    └─→ טאב 2: "מיקומים" 📍
        ├── רשת מיקומים (ברירת מחדל + מותאמים)
        ├── לחיצה על מיקום → סינון פריטים
        ├── חיפוש פריטים
        ├── מיון (שם/כמות/קטגוריה)
        ├── הוספת מיקום חדש:
        │   └── בחירת אמוג'י + שם מיקום
        ├── עריכת מיקום מותאם:
        │   └── לחיצה על ✏️ → שינוי שם/אמוג'י
        └── מחיקת מיקום:
            └── לחיצה ארוכה → אישור → (Undo זמין ל-5 שניות)
```

### תרשים מסכים עיקריים

1. **IndexScreen** – נקודת כניסה, בודק:

   - האם המשתמש מחובר? (userId)
   - האם המשתמש ראה Onboarding? (seenOnboarding)
   - מנתב למסך המתאים לפי סדר נכון

2. **Home/Dashboard** – מסך ראשי עם:

   - רשימות פעילות
   - הצעות חכמות
   - סטטיסטיקות
   - פעולות מהירות

3. **Shopping Flow**:

   - רשימת הרשימות
   - פרטי רשימה (עריכה/הוספת פריטים)
   - מצב קניה פעיל (סימון פריטים)
   - סיכום קניה

4. **Receipts** – ניהול וצפייה בקבלות

5. **Pantry/Inventory** – ניהול המזווה עם 2 טאבים:
   - **טאב רשימה**: תצוגה מסורתית מקובצת לפי מיקום
   - **טאב מיקומים**: ניהול מיקומי אחסון מתקדם

6. **Insights** – תובנות וגרפים

7. **Settings/Profile** – הגדרות אישיות

---

## ✅ מה עובד היום

### ✨ שודרג לאחרונה (04/10/2025)

- ✅ **ניהול מיקומי אחסון מלא** (חדש!)
  - מיקומי ברירת מחדל (מקרר, מזווה, מקפיא וכו')
  - הוספה/עריכה/מחיקה של מיקומים מותאמים
  - בחירת אמוג'י לכל מיקום (20 אפשרויות)
  - Undo למחיקה (5 שניות)
  - שמירת מיקומים ב-SharedPreferences
  - LocationsProvider עם ChangeNotifier
  - CustomLocation Model
- ✅ **מסך מזווה עם טאבים**
  - טאב רשימה: תצוגה מסורתית
  - טאב מיקומים: ניהול מתקדם עם StorageLocationManager
- ✅ **חיפוש וסינון מתקדם**
  - חיפוש פריטים לפי שם/קטגוריה/מיקום
  - מיון: שם, כמות, קטגוריה
  - Cache לביצועים
- ✅ **סטטיסטיקות ואזהרות**
  - ספירת פריטים לפי מיקום
  - אזהרת מלאי נמוך (⚠️ icon)
  - אחוזי תפוסה
- ✅ **UX משופר**
  - תצוגת רשת/רשימה (נשמרת ב-SharedPreferences)
  - אייקוני עריכה ומחיקה ברורים
  - Tooltips עם הסברים

### קיים מקודם

- ✅ ניהול רשימות קניות מלא (יצירה, עריכה, מחיקה)
- ✅ **ניהול מוצרים עם Hive + Hybrid Repository**
  - אחסון מקומי קבוע של מוצרים
  - עדכון מחירים דינמי מ-API
  - הוספת מוצרים חדשים אוטומטית
- ✅ ניהול מלאי (Inventory) מחובר ל-Provider
- ✅ ניהול קבלות עם Mock Service
- ✅ ניהול משתמשים (UserContext)
- ✅ UI RTL מלא לעברית
- ✅ Theme Light/Dark מותאם
- ✅ Onboarding מלא
- ✅ ניווט בין מסכים (עם סדר נכון!)
- ✅ הודעות (Toast/Snackbar)
- ✅ מבנה נתונים סדור עם `json_serializable` + Hive
- ✅ Bottom Navigation עם Badges
- ✅ מסכי Settings ו-Profile מלאים
- ✅ טיפול בלחיצת Back (יציאה בלחיצה כפולה)
- ✅ Error Handling במסכי אתחול
- ✅ מסמכי הנחיות מקיפים

---

## 📝 משימות לביצוע (TODO)

### 🔥 עדיפות גבוהה (High Priority)

#### Backend & Data

- [ ] **Firebase Integration**

  - [ ] הגדרת Firebase Project
  - [ ] Firebase Authentication (Email/Password + Google Sign-in)
  - [ ] Cloud Firestore לאחסון נתונים
  - [ ] Firebase Storage להעלאת תמונות
  - [ ] Security Rules

- [ ] **API Layer**

  - [ ] מימוש Repository מול Firebase
  - [ ] Error Handling מקיף
  - [ ] Retry Logic
  - [ ] Cache Strategy

- [ ] **Offline Support**
  - [ ] שילוב Hive או SQLite
  - [ ] Sync Logic כשחוזרים Online
  - [ ] Conflict Resolution

#### Features

- [ ] **Shared Lists (רשימות משותפות)**

  - [ ] הוספת משתמשים לרשימה
  - [ ] Realtime Sync
  - [ ] הרשאות (Owner/Editor/Viewer)
  - [ ] התראות על שינויים

- [ ] **Receipt OCR**

  - [ ] שילוב ML Kit / Cloud Vision API
  - [ ] זיהוי אוטומטי של פריטים
  - [ ] עיבוד תמונות קבלות
  - [ ] חילוץ מחירים ותאריכים

- [ ] **Smart Notifications**
  - [ ] תזכורות לקניות
  - [ ] התראות על תוקף פריטים
  - [ ] הצעות בהתאם להרגלים
  - [ ] Local Notifications + Push

#### UI/UX

- [ ] **Shopping Mode Improvements**

  - [ ] מצב קניה מלא מסך
  - [ ] סימון מהיר בתנועות
  - [ ] חיפוש בזמן קניה
  - [ ] מיון לפי מדפים/קטגוריות

- [ ] **Dashboard Enhancements**
  - [ ] כרטיסים אינטראקטיביים
  - [ ] Quick Actions
  - [ ] Recent Activity
  - [ ] Weekly Summary

#### Code Quality

- [ ] **Refactoring לפי FULL_REPORT.md**
  - [ ] מחיקת קבצים כפולים
  - [ ] יצירת רכיבים משותפים חסרים
  - [ ] ארגון תיקיות
  - [ ] אחידות בעיצוב

### 📊 עדיפות בינונית (Medium Priority)

#### Analytics & Insights

- [ ] **Advanced Insights**

  - [ ] גרפים עם fl_chart
  - [ ] ניתוח הוצאות לפי קטגוריות
  - [ ] מגמות צריכה
  - [ ] השוואה בין חודשים
  - [ ] ניבוי הוצאות

- [ ] **Budget Management**
  - [ ] הגדרת תקציב חודשי
  - [ ] התראות על חריגה
  - [ ] מעקב יומי/שבועי
  - [ ] ויזואליזציות

#### Features - Storage Locations (הרחבות עתידיות)

- [ ] **Drag & Drop למיקומים**
  - [ ] סידור מחדש של כרטיסי מיקומים
  - [ ] גרירת פריטים בין מיקומים
  
- [ ] **Export/Import מיקומים**
  - [ ] ייצוא מיקומים מותאמים לJSON
  - [ ] שיתוף קובץ מיקומים
  - [ ] ייבוא מיקומים מקובץ
  
- [ ] **מיקומים מתקדמים**
  - [ ] צבעים מותאמים למיקום
  - [ ] תמונות במקום אמוג'י
  - [ ] תתי-מיקומים (היררכיה)
  - [ ] תגיות ותיאורים

#### Features - Inventory

- [ ] **Inventory Enhancements**

  - [ ] מעקב אחר תוקף
  - [ ] התראות על פריטים שנגמרים
  - [ ] Barcode Scanning
  - [ ] ניהול כמויות

- [ ] **Templates & Automation**

  - [ ] תבניות מוכנות מתקדמות
  - [ ] יצירה אוטומטית לפי היסטוריה
  - [ ] רשימות חוזרות (שבועיות)
  - [ ] AI Suggestions

- [ ] **Price Tracking**
  - [ ] מעקב היסטורי אחר מחירים
  - [ ] השוואת מחירים
  - [ ] התראות על הנחות
  - [ ] אינטגרציה עם API מחירונים

### 🎨 עדיפות נמוכה (Low Priority)

#### Polish & Quality

- [ ] **Testing**

  - [ ] Unit Tests למודלים
  - [ ] Unit Tests ל-Repositories
  - [ ] Widget Tests למסכים עיקריים
  - [ ] Integration Tests לזרימות
  - [ ] הגעה ל-70%+ Coverage

- [ ] **Performance**

  - [ ] אופטימיזציה של רשימות ארוכות
  - [ ] Lazy Loading
  - [ ] Image Caching
  - [ ] Bundle Size Optimization

- [ ] **Accessibility**

  - [ ] Semantic Labels
  - [ ] Screen Reader Support
  - [ ] Font Scaling
  - [ ] Color Contrast

- [ ] **Localization**
  - [ ] תמיכה באנגלית מלאה
  - [ ] ARB Files
  - [ ] Dynamic Localization

#### Nice to Have

- [ ] **Social Features**

  - [ ] שיתוף רשימות בקישור
  - [ ] ייצוא/ייבוא רשימות
  - [ ] המלצות קהילתיות

- [ ] **Advanced UI**

  - [ ] Animations מתקדמות
  - [ ] Custom Transitions
  - [ ] Haptic Feedback
  - [ ] Dark Mode Auto-switch

- [ ] **Export/Import**
  - [ ] ייצוא לCSV/Excel
  - [ ] גיבוי אוטומטי
  - [ ] ייבוא מקבלות אחרות

---

## 🛠 פקודות שימושיות

### Development

```bash
# התקנת תלויות
flutter pub get

# יצירת קבצי קוד אוטומטיים
dart run build_runner build --delete-conflicting-outputs

# יצירה רציפה (watch mode)
dart run build_runner watch --delete-conflicting-outputs

# הרצת האפליקציה
flutter run

# הרצה עם hot reload מהיר
flutter run --hot

# ניקוי build
flutter clean
```

### Analysis & Linting

```bash
# בדיקת בעיות בקוד
flutter analyze

# תיקון אוטומטי של בעיות
dart fix --apply

# בדיקת formatting
dart format lib/ --set-exit-if-changed

# תיקון formatting
dart format lib/ -w
```

### Building

```bash
# בניית APK (Debug)
flutter build apk --debug

# בניית APK (Release) - אנדרואיד
flutter build apk --release

# בניית APK מפוצל לפי ארכיטקטורה (מומלץ)
flutter build apk --split-per-abi

# בניית App Bundle לGoogle Play (מומלץ להעלאה לחנות)
flutter build appbundle --release

# בניית iOS (דורש macOS + Xcode)
flutter build ios --release

# הרצה ישירות על מכשיר מחובר
flutter install
```

> **💡 טיפ:** השתמש ב-`--split-per-abi` כדי ליצור APK נפרדים לכל ארכיטקטורה (גודל קובץ קטן יותר).

### Assets & Code Generation

```bash
# יצירת קבצי assets
flutter pub run flutter_gen_runner

# עדכון אייקונים
flutter pub run flutter_launcher_icons:main

# עדכון splash screen
flutter pub run flutter_native_splash:create
```

---

## 🧪 בדיקות (Testing)

### הרצת בדיקות

```bash
# הרצת כל הבדיקות
flutter test

# הרצה עם coverage
flutter test --coverage

# הצגת דוח coverage (לאחר התקנת lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### מבנה הבדיקות

```
test/
├── models/              # בדיקות למודלים
├── repositories/        # בדיקות ל-repositories
├── providers/           # בדיקות ל-providers
├── services/            # בדיקות לשירותים
├── widgets/             # Widget tests
└── integration/         # Integration tests
```

### כתיבת בדיקות חדשות

```dart
// דוגמה לבדיקת מודל
import 'package:flutter_test/flutter_test.dart';
import 'package:salsheli/models/shopping_list.dart';

void main() {
  group('ShoppingList', () {
    test('should calculate total correctly', () {
      final list = ShoppingList(
        id: '1',
        name: 'Test',
        items: [/* ... */],
      );

      expect(list.totalAmount, equals(100.0));
    });
  });
}
```

---

## 🤝 Contributing

רוצה לתרום לפרוייקט? מעולה!

### Process

1. Fork את הפרוייקט
2. צור branch חדש (`git checkout -b feature/AmazingFeature`)
3. **קרא את MOBILE_GUIDELINES.md** 📚
4. Commit את השינויים (`git commit -m 'Add some AmazingFeature'`)
5. **השתמש ב-CODE_REVIEW_CHECKLIST.md** לפני commit ✅
6. Push ל-branch (`git push origin feature/AmazingFeature`)
7. פתח Pull Request

### Guidelines

- עקוב אחר `MOBILE_GUIDELINES.md`
- השתמש ב-`CODE_REVIEW_CHECKLIST.md` לפני commit
- הוסף בדיקות לפיצ'רים חדשים
- עדכן documentation בהתאם
- וודא ש-`flutter analyze` עובר ללא שגיאות
- הוסף הערת תיעוד בראש כל קובץ חדש
- עדכן את `WORK_LOG.md` עם המשימה החדשה

---

## 📄 License

הפרוייקט תחת רישיון MIT - ראה `LICENSE` לפרטים.

---

## 📞 יצירת קשר

יש שאלות? בעיות? רעיונות?

- 📧 Email: your-email@example.com
- 🐛 Issues: [GitHub Issues](https://github.com/your-username/salsheli/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/your-username/salsheli/discussions)

---

## 🙏 תודות

תודה לכל התורמים והספריות המעולות שעוזרות לפרוייקט!

- [Flutter](https://flutter.dev/)
- [Provider](https://pub.dev/packages/provider)
- [json_serializable](https://pub.dev/packages/json_serializable)
- [Hive](https://pub.dev/packages/hive)
- [fl_chart](https://pub.dev/packages/fl_chart)
- וכל שאר הספריות המעולות!

---

**Made with ❤️ in Israel**
