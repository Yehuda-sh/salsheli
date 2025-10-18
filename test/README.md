# 🧪 מדריך הרצת בדיקות - Salsheli

> **מדריך מלא להרצת כל הבדיקות במערכת**  
> **עודכן:** 18/10/2025

---

## 📊 מבנה תיקיית הבדיקות

```
test/
├── helpers/
│   ├── test_helpers.dart       # פונקציות עזר משותפות
│   └── mock_data.dart          # נתונים מדומים
├── integration/
│   └── login_flow_test.dart    # בדיקות אינטגרציה מלאות
├── rtl/
│   └── rtl_layout_test.dart    # בדיקות Right-to-Left
├── offline/
│   └── offline_mode_test.dart  # בדיקות מצב לא מקוון
├── concurrent/
│   └── multi_user_test.dart    # בדיקות פעולות בו-זמניות
├── models/
│   └── ...                     # בדיקות מודלים
├── providers/
│   └── ...                     # בדיקות Providers
└── repositories/
    └── ...                     # בדיקות Repositories
```

---

## 🚀 הרצת בדיקות

### 1️⃣ כל הבדיקות

```bash
# הרצת כל הבדיקות במערכת
flutter test
```

### 2️⃣ בדיקות ספציפיות

```bash
# Integration Tests בלבד
flutter test test/integration/

# RTL Tests בלבד
flutter test test/rtl/

# Offline Tests בלבד
flutter test test/offline/

# Concurrent Users Tests בלבד
flutter test test/concurrent/

# קובץ בדיקה אחד
flutter test test/integration/login_flow_test.dart
```

### 3️⃣ בדיקה אחת ספציפית

```bash
# הרצת בדיקה עם שם מסוים
flutter test test/integration/login_flow_test.dart --plain-name "התחברות מוצלחת"
```

---

## 📝 יצירת Mocks (לפני הרצה ראשונה!)

לפני שמריצים את הבדיקות לראשונה, **חובה** ליצור את קבצי ה-Mocks:

```bash
# יצירת כל הmocks
flutter pub run build_runner build --delete-conflicting-outputs

# או בצורה מתמשכת (auto-regenerate)
flutter pub run build_runner watch
```

**💡 מתי צריך להריץ מחדש?**
- פעם ראשונה שמריצים בדיקות
- כשמוסיפים `@GenerateMocks([...])`
- כשמשנים חתימת פונקציה ב-repository/service

---

## 🎯 בדיקות לפי קטגוריה

### 🔐 Integration Tests (בדיקות אינטגרציה)

מבצעות בדיקות של **מסלולים מלאים** מתחילה לסוף:

```bash
flutter test test/integration/login_flow_test.dart
```

**מה נבדק:**
- ✅ התחברות מוצלחת (Login → Home)
- ✅ התחברות כושלת (סיסמה שגויה)
- ✅ רישום משתמש חדש
- ✅ שכחתי סיסמה (שליחת מייל)
- ✅ התחברות דמו מהירה
- ✅ Form validation
- ✅ Email validation

**⏱️ זמן ריצה:** ~20-30 שניות

---

### 🔤 RTL Tests (בדיקות Right-to-Left)

בודקות תמיכה מלאה ב**עברית** ו-RTL:

```bash
flutter test test/rtl/rtl_layout_test.dart
```

**מה נבדק:**
- ✅ כפתורים מיושרים לימין
- ✅ טקסטים מיושרים לימין
- ✅ אייקונים בצד הנכון
- ✅ Padding symmetric עובד נכון
- ✅ ListTile - leading/trailing נכונים
- ✅ מספרים נשארים LTR בתוך RTL

**⏱️ זמן ריצה:** ~10-15 שניות

---

### 📴 Offline Tests (בדיקות מצב לא מקוון)

בודקות עבודה **ללא חיבור לאינטרנט**:

```bash
flutter test test/offline/offline_mode_test.dart
```

**מה נבדק:**
- ✅ קריאת cache כשאין אינטרנט
- ✅ שגיאות מובנות לפעולות שצריכות רשת
- ✅ שמירת שינוי מקומי
- ✅ Retry מצליח כשחוזר חיבור
- ✅ Timeout על רשת איטית
- ✅ Cache expiration

**⏱️ זמן ריצה:** ~15-20 שניות

---

### 👥 Concurrent Users Tests (בדיקות פעולות בו-זמניות)

בודקות **מספר משתמשים** בו-זמנית:

```bash
flutter test test/concurrent/multi_user_test.dart
```

**מה נבדק:**
- ✅ שני משתמשים מוסיפים פריט בו-זמנית
- ✅ Race condition: סימון פריט
- ✅ עריכה + מחיקה בו-זמנית
- ✅ 100 משתמשים בו-זמנית
- ✅ Real-time sync
- ✅ שינוי household

**⏱️ זמן ריצה:** ~30-60 שניות

---

## 📊 כיסוי בדיקות (Coverage)

### הפקת דוח כיסוי

```bash
# הרצה עם כיסוי
flutter test --coverage

# הצגת דוח ב-HTML
genhtml coverage/lcov.info -o coverage/html

# פתיחת הדוח
# Windows:
start coverage/html/index.html

# macOS:
open coverage/html/index.html

# Linux:
xdg-open coverage/html/index.html
```

### יעדי כיסוי

| קטגוריה | יעד | מצב נוכחי |
|---------|-----|-----------|
| Models | 90%+ | ✅ |
| Providers | 80%+ | 🟡 |
| Repositories | 85%+ | 🟡 |
| Services | 75%+ | 🟡 |
| UI | 60%+ | ❌ |

---

## 🔧 פתרון בעיות נפוצות

### ❌ "Cannot find Mocks"

```bash
# פתרון:
flutter pub run build_runner build --delete-conflicting-outputs
```

### ❌ "Test timeout"

הגדל את ה-timeout:

```dart
test('my test', () async {
  // ...
}, timeout: Timeout(Duration(seconds: 60)));
```

### ❌ "Context was used after being disposed"

וודא שיש `if (!mounted) return;` אחרי כל `await`:

```dart
await operation();
if (!mounted) return;  // ✅
setState(() {});
```

### ❌ "Duplicate mock files"

```bash
# מחק קבצים ישנים ויצור מחדש
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 🎓 טיפים לכתיבת בדיקות

### 1️⃣ השתמש בהוספת Helpers

```dart
import '../helpers/test_helpers.dart';
import '../helpers/mock_data.dart';

// במקום:
await tester.enterText(find.byType(TextField), 'test@test.com');

// השתמש ב:
await fillTextField(tester, 'אימייל', 'test@test.com');
```

### 2️⃣ הוסף Logging

```dart
debugPrint('📝 Test: My test name');
debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
// ... test code ...
debugPrint('✅ Test passed!');
```

### 3️⃣ נקה משאבים

```dart
tearDown(() {
  controller.dispose();
  provider.dispose();
});
```

### 4️⃣ בדוק Edge Cases

```dart
// ✅ טוב - בדיקת edge cases
test('Empty list name', () { ... });
test('Very long name (1000 chars)', () { ... });
test('Special characters', () { ... });
```

---

## 📚 משאבים נוספים

- 📖 **Flutter Testing Docs:** https://docs.flutter.dev/testing
- 📖 **Mockito Guide:** https://pub.dev/packages/mockito
- 📖 **DEVELOPER_GUIDE.md** - מדריך המפתח הפנימי
- 📖 **BEST_PRACTICES.md** - Best practices לפיתוח

---

## 🎯 Checklist לפני Commit

- [ ] כל הבדיקות עוברות (`flutter test`)
- [ ] Coverage > 80% למודולים חדשים
- [ ] אין שגיאות Lint (`flutter analyze`)
- [ ] הקוד מעוצב (`dart format lib/ test/`)
- [ ] Mocks מעודכנים (אם נדרש)
- [ ] Documentation עודכן (אם נדרש)

---

## 🏆 תוצאות צפויות

כאשר הכל עובד כמו שצריך:

```
✓ test/integration/login_flow_test.dart (passed in 25.2s)
✓ test/rtl/rtl_layout_test.dart (passed in 12.5s)
✓ test/offline/offline_mode_test.dart (passed in 18.7s)
✓ test/concurrent/multi_user_test.dart (passed in 45.3s)

All tests passed! 🎉
```

---

**Made with ❤️ by Humans & AI** 👨‍💻🤖  
**Version:** 1.0 | **Updated:** 18/10/2025  
**Purpose:** Complete testing guide for Salsheli project
