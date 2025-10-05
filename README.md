# 🛒 סל שלי (Salsheli)

אפליקציית Flutter מובייל (Android & iOS) לניהול קניות, מלאי וקבלות.

> **⚠️ Mobile Only** - אין תמיכה ב-Web/Desktop

---

## ✨ פיצ'רים

- 📋 רשימות קניות + תבניות
- 🏠 ניהול מלאי עם מיקומי אחסון מותאמים
- 🧾 קבלות ומחירים
- 📊 תובנות וסטטיסטיקות
- 🌐 RTL מלא
- 💾 Hive (מוצרים) + SharedPreferences (העדפות)

---

## 🚀 התקנה מהירה

```bash
# 1. Clone
git clone https://github.com/your-username/salsheli.git
cd salsheli

# 2. Install
flutter pub get

# 3. Generate code
dart run build_runner build --delete-conflicting-outputs

# 4. Run
flutter run
```

**דרישות:**
- Dart 3.8.1+ (ראה `pubspec.yaml`)
- Flutter SDK (גרסה תואמת ל-Dart 3.8.1+)

---

## 🔥 Firebase Setup

הפרויקט משתמש ב-Firebase Core (מוכן לעתיד: Auth, Firestore, Storage).

### ✅ קבצי קונפיגורציה קיימים:
- `lib/firebase_options.dart` - נוצר ע"י FlutterFire CLI
- `android/app/google-services.json` - תואם ל-Project ID: `salsheli`

### ❌ חסר - צריך להוסיף:
- `ios/Runner/GoogleService-Info.plist` - **הורד מ-Firebase Console**

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

### 🔍 בדיקת תקינות:

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
| **"Project not found"** | ProjectId לא תואם (צריך להיות `salsheli`) |
| **"Configuration error"** | הרץ `flutterfire configure` מחדש |

### 📦 חבילות Firebase מותקנות:

```yaml
# pubspec.yaml
firebase_core: ^4.1.1        # ✅ בשימוש
cloud_firestore: ^6.0.2      # ⚠️ מותקן, לא בשימוש כרגע
```

**הערה:** `cloud_firestore` מותקן אבל לא משמש כרגע בקוד. אם לא מתכנן להשתמש - כדאי להסיר כדי להקטין את גודל האפליקציה.

---

## 📚 תיעוד חובה לקריאה

| קובץ                      | מטרה                          | מתי לקרוא                |
| ------------------------- | ----------------------------- | ------------------------ |
| **WORK_LOG.md**           | 📓 יומן עבודה                 | תחילת כל שיחה            |
| **CLAUDE_GUIDELINES.md**  | 🤖 הוראות ל-Claude/AI        | עבודה עם AI tools       |
| **MOBILE_GUIDELINES.md**  | הנחיות טכניות + ארכיטקטורה   | לפני כתיבת קוד חדש       |
| **CODE_REVIEW_CHECKLIST** | בדיקת קוד מהירה               | לפני כל commit           |

---

## 📂 מבנה

```
lib/
├── main.dart                 # Entry point
├── api/                      # API Entities
│   └── entities/
├── config/                   # קבצי תצורה
│   ├── category_config.dart
│   └── filters_config.dart
├── core/                     # קבועים
│   └── constants.dart
├── data/                     # נתוני דמו
│   ├── demo_shopping_lists.dart
│   ├── rich_demo_data.dart
│   ├── demo_users.dart
│   └── ...
├── gen/                      # Generated files (build_runner)
│   ├── assets.gen.dart
│   └── fonts.gen.dart
├── helpers/                  # Helper functions
│   └── product_loader.dart
├── layout/                   # App layout
│   └── app_layout.dart
├── models/                   # Data models + *.g.dart
├── providers/                # State Management (ChangeNotifier)
├── repositories/             # Data Access Layer
├── services/                 # Business Logic
├── screens/                  # UI Screens
├── theme/                    # ערכות נושא
│   └── app_theme.dart
├── utils/                    # כלי עזר
│   ├── toast.dart
│   └── color_hex.dart
└── widgets/                  # Reusable Components
```

**פירוט מלא:** ראה MOBILE_GUIDELINES.md

---

## ✅ מה עובד

### שודרג לאחרונה (05/10/2025)
- ✅ **נתוני דמו חכמים** - טעינת 100+ מוצרים אמיתיים מ-JSON
- ✅ **רשימות דינמיות** - 7 רשימות קניות + 3 קבלות עם מוצרים אמיתיים
- ✅ **Logging מפורט** - ב-Models, Providers, Services (ראה WORK_LOG.md)
- ✅ **תיעוד מקיף** - auth_button, config files, CODE_REVIEW_CHECKLIST

### עבודות קודמות
- ✅ **צמצום קבצי תיעוד** - חיסכון של 150k טוקנים
- ✅ **Undo Pattern** - מחיקה עם ביטול בכל המערכת
- ✅ **HomeStatsService** - חיבור למערכות אמיתיות
- ✅ **ניהול מיקומי אחסון** - הוספה/עריכה/מחיקה + Undo
- ✅ **מסך מזווה עם טאבים** - רשימה + מיקומים

### קיים
- ✅ CRUD רשימות/מלאי/קבלות
- ✅ Hybrid Products (Hive + API)
- ✅ RTL + Theme Light/Dark
- ✅ Onboarding + ניווט

---

## 💾 נתוני דמו

### מוצרים אמיתיים
- 📦 **100+ מוצרים** מקובץ `assets/data/products.json`
- 🏪 נתונים אמיתיים מ"שופרסל" (מחירים, ברקודים, קטגוריות)
- 🎯 בחירה חכמה לפי קטגוריות (מוצרי חלב, ניקיון, וכו')
- 💾 Cache חכם - טעינה פעם אחת
- ⚠️ Fallback - תמיד יש תוכנית B

### דמו עשיר (demo_login_button)
- 👤 **משתמש:** יוני (householdId: 'house_demo')
- 📋 **7 רשימות קניות** - סופר, בית מרקחת, חומרי ניקיון...
- 🧾 **3 קבלות** - עם מוצרים אמיתיים ומחירים
- 🏠 **מלאי חכם** - מזווה, מקרר, מקפיא, אמבטיה
- 🔄 **Providers אוטומטיים** - ProductsProvider ו-SuggestionsProvider

**קוד:** `lib/data/demo_shopping_lists.dart`, `lib/data/rich_demo_data.dart`

---

## 📊 Logging

הפרויקט כולל logging מפורט לצורכי debug:

- **Models:** `debugPrint` ב-`fromJson`/`toJson`
- **Providers:** logging ב-`notifyListeners()`
- **ProxyProvider:** logging ב-`update()`
- **Services:** logging תוצאות + fallbacks
- **User state:** login/logout changes

**פורמט:** ✅ הצלחה | ⚠️ אזהרה | ❌ שגיאה

**ראה:** CLAUDE_GUIDELINES.md, MOBILE_GUIDELINES.md

---

## 📝 TODO

### 🔥 גבוה
- [ ] Firebase (Auth + Firestore + Storage)
- [ ] Shared Lists + Realtime Sync
- [ ] Receipt OCR
- [ ] Smart Notifications

### 📊 בינוני
- [ ] גרפים (fl_chart)
- [ ] Budget Management
- [ ] Barcode Scanning
- [ ] Price Tracking

### 🎨 נמוך
- [ ] Tests (Unit/Widget/Integration)
- [ ] Performance Optimization
- [ ] Accessibility
- [ ] i18n (אנגלית)

---

## 🛠 פקודות

```bash
# Development
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run

# Analysis
flutter analyze
dart fix --apply
dart format lib/ -w

# Build
flutter build apk --release
flutter build appbundle --release  # Google Play
flutter build ios --release
```

---

## 🤝 Contributing

1. Fork + Branch
2. **קרא MOBILE_GUIDELINES.md** 📚
3. Commit
4. **בדוק CODE_REVIEW_CHECKLIST.md** ✅
5. PR

---

**עדכון אחרון:** 05/10/2025  
**גרסה:** 1.0.0+1  
**Made with ❤️ in Israel**
