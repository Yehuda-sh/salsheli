# 🧪 Quick Testing Guide - Salsheli

## 🚀 הרצה מהירה

### 1️⃣ הכנה (פעם ראשונה)

```bash
# יצירת Mocks
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2️⃣ הרצת בדיקות

```bash
# כל הבדיקות
flutter test

# רק בדיקות RTL (הכי פשוטות)
flutter test test/rtl/

# רק בדיקות Integration
flutter test test/integration/

# בדיקה אחת ספציפית
flutter test test/rtl/rtl_layout_test.dart
```

## 📝 בדיקות שנוצרו

| קטגוריה | קובץ | בדיקות | סטטוס |
|---------|------|---------|-------|
| **RTL** | `rtl/rtl_layout_test.dart` | 7 | ✅ מוכן |
| **Offline** | `offline/offline_mode_test.dart` | 6 | ✅ מוכן |
| **Concurrent** | `concurrent/multi_user_test.dart` | 6 | ✅ מוכן |
| **Integration** | `integration/login_flow_test.dart` | 7 | 🔧 נדרש תיקון קל |

## 🔧 תיקונים אפשריים

אם יש שגיאות:

1. **Missing Mocks:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Import errors:**
   - בדוק ש-`pubspec.yaml` מעודכן
   - הרץ `flutter pub get`

3. **Timeout:**
   - הגדל timeout בבדיקה

## 📖 מדריך מלא

ראה `test/README.md` למדריך מלא!
