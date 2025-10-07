# 🛒 סל שלי (Salsheli)

אפליקציית Flutter מובייל (Android & iOS) לניהול קניות, מלאי וקבלות עם סנכרון בענן.

> **⚠️ Mobile Only** - אין תמיכה ב-Web/Desktop

---

## ✨ פיצ'רים

- 📋 **רשימות קניות** - 21 סוגי תבניות + קנייה פעילה
- 🏠 **ניהול מלאי** - מיקומי אחסון מותאמים
- 🧾 **קבלות** - OCR מקומי (ML Kit) + מחירים
- 💰 **מחירים אמיתיים** - Shufersal API (~15,000 מוצרים)
- 📊 **תובנות וסטטיסטיקות** - ניתוח הוצאות
- 🔐 **Firebase Auth** - התחברות מאובטחת
- ☁️ **Firestore Sync** - סנכרון real-time בין מכשירים
- 🌐 **RTL מלא** - תמיכה בעברית

---

## 🚀 Quick Start

### למפתח חדש - קרא קודם:

| קובץ | מה זה |
|------|-------|
| **📚 LESSONS_LEARNED.md** | לקחים חשובים + דפוסים טכניים (חובה!) |
| **🤖 AI_DEV_GUIDELINES.md** | הנחיות לסוכני AI (אם רלוונטי) |

### התקנה:

```bash
# Clone
git clone https://github.com/your-username/salsheli.git
cd salsheli

# Install & Generate
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# משתמשי דמו (אופציונלי)
cd scripts && npm install && npm run create-users

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

### 👥 משתמשי דמו:

```bash
cd scripts && npm run create-users
```

- `yoni@demo.com` / `Demo123!`
- `sarah@demo.com` / `Demo123!`
- `danny@demo.com` / `Demo123!`

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
├── main.dart                   # Entry + Firebase init
├── firebase_options.dart       # Firebase config
│
├── models/                     # Data models (@JsonSerializable)
│   ├── timestamp_converter.dart    # ⚡ Firestore Timestamp helper
│   ├── user_entity.dart
│   ├── shopping_list.dart
│   ├── receipt.dart
│   └── inventory_item.dart
│
├── providers/                  # State (ChangeNotifier)
│   ├── user_context.dart           # 👤 User + Auth
│   ├── shopping_lists_provider.dart # 🛒 Lists (Firestore)
│   ├── receipt_provider.dart       # 🧾 Receipts
│   ├── inventory_provider.dart     # 📦 Inventory
│   └── products_provider.dart      # 📦 Products (Hybrid)
│
├── repositories/              # Data access
│   ├── firebase_*_repository.dart  # Firestore CRUD
│   └── hybrid_products_repository.dart # Hive + Firestore + API
│
├── services/                  # Business logic
│   ├── auth_service.dart              # 🔐 Firebase Auth
│   ├── shufersal_prices_service.dart  # 💰 API
│   ├── ocr_service.dart               # 📸 ML Kit
│   └── receipt_parser_service.dart    # 🧾 Regex Parser
│
├── screens/                   # UI
├── widgets/                   # Components
└── theme/                     # Theming
```

---

## 📝 מה עובד היום (07/10/2025)

### ☁️ Firestore + Authentication

- ✅ Email/Password auth + persistent sessions
- ✅ Shopping Lists - real-time sync
- ✅ Receipts, Inventory, Products (1,758 מוצרים)
- ✅ Security Rules + Indexes
- ✅ Hybrid Storage: Hive (cache) + Firestore (cloud)

### 💰 Shufersal API + OCR

- ✅ עדכון מחירים אוטומטי + ידני
- ✅ OCR מקומי (ML Kit) לסריקת קבלות
- ✅ זיהוי חנויות: שופרסל, רמי לוי, מגה
- ✅ חילוץ פריטים + סכומים

### 🎨 UI/UX

- ✅ 21 סוגי רשימות + מסך קנייה פעילה
- ✅ Undo למחיקה (5 שניות)
- ✅ 3 Empty States: Loading/Error/Empty
- ✅ RTL מלא + Dark/Light themes
- ✅ מיקומי אחסון מותאמים

---

## 📊 סטטיסטיקות

- **קבצי Dart:** 108 בlib/
- **שורות קוד:** ~10,500 (אחרי ניקוי 3,000+ Dead Code)
- **מוצרים:** 1,758 (Hive + Firestore)
- **סוגי רשימות:** 21
- **משתמשי דמו:** 3

---

## 🎯 TODO

### 🔴 גבוה
- [ ] iOS GoogleService-Info.plist
- [ ] Collaborative shopping (שיתוף real-time)
- [ ] Receipt OCR improvements

### 🟡 בינוני
- [ ] Offline mode מלא (Hive cache)
- [ ] Smart notifications
- [ ] Price tracking מתקדם

### 🟢 נמוך
- [ ] Tests (Unit/Widget/Integration)
- [ ] i18n (English)
- [ ] Performance optimization

### ✅ הושלם לאחרונה
- ~~Shopping Lists → Firestore~~
- ~~Shufersal API~~
- ~~OCR מקומי (ML Kit)~~
- ~~Dead Code cleanup (3,000+ שורות)~~

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
npm run create-users    # משתמשי דמו
npm run upload          # מוצרים ל-Firestore
```

---

## 🐛 בעיות נפוצות

| בעיה | פתרון |
|------|--------|
| **iOS קורס** | GoogleService-Info.plist חסר |
| **Android קורס** | בדוק google-services.json |
| **רשימות לא נטענות** | בדוק snake_case ב-Firestore (@JsonKey) |
| **Race condition בהתחברות** | Firebase Auth אסינכרוני - המתן לSignIn |

> **עוד פתרונות:** ראה `LESSONS_LEARNED.md` חלק "בעיות נפוצות"

---

## 🤝 תרומה

1. **Fork + Branch**
2. **קרא תיעוד:** `LESSONS_LEARNED.md` (חובה!)
3. **כתוב קוד:**
   - עקוב אחר דפוסים ב-LESSONS_LEARNED
   - 3 Empty States בwidgets חדשים
   - Logging בכל method
4. **לפני commit:**
   - `flutter analyze`
   - `dart format lib/ -w`
   - ✅ בדיקת איכות (AI_DEV_GUIDELINES.md חלק C)
5. **Commit + PR**

---

## 🎓 הישגים אחרונים (06-07/10/2025)

- ✅ Firebase Integration מלא
- ✅ Shufersal API למחירים אמיתיים
- ✅ OCR מקומי (ML Kit)
- ✅ ניקוי 3,000+ שורות Dead Code
- ✅ Code Review מקיף (22 קבצים → 100/100)
- ✅ Providers עקביים (Error Handling + Logging + Recovery)
- ✅ תיעוד מקיף (LESSONS_LEARNED + AI_DEV_GUIDELINES)

---

## 📄 רישיון

MIT License - ראה LICENSE

---

**עדכון:** 07/10/2025 | **גרסה:** 1.0.0+1 | **Made with ❤️ in Israel** 🇮🇱

> 💡 **למפתחים:** התחל עם `LESSONS_LEARNED.md` - הכי חשוב!  
> 💡 **לסוכני AI:** קרא `AI_DEV_GUIDELINES.md` בתחילת כל שיחה
