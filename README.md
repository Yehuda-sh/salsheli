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

**דרישות:** Flutter 3.8.1+, Dart 3.8.1+

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
├── main.dart
├── models/          # Data models + *.g.dart
├── providers/       # State Management
├── repositories/    # Data Layer
├── services/        # Business Logic
├── screens/         # UI Screens
└── widgets/         # Reusable Components
```

**פירוט מלא:** ראה MOBILE_GUIDELINES.md

---

## ✅ מה עובד

### שודרג לאחרונה (05/10/2025)
- ✅ **צמצום קבצי תיעוד** - חיסכון של 150k טוקנים!
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

**Made with ❤️ in Israel**
