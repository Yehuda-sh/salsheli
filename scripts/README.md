# סקריפטים

## `demo_data_cohen_family.dart`
יצירת נתוני דמו למשפחת כהן ב-Firebase Emulator.

```bash
dart run scripts/demo_data_cohen_family.dart           # יוצר נתונים
dart run scripts/demo_data_cohen_family.dart --clean   # מוחק ויוצר מחדש
```

## `update_products.dart`
עדכון מוצרים ומחירים מ-Shufersal.

```bash
dart run scripts/update_products.dart
```

## סקריפטי הרצה עם לוגים נקיים
הרצת `flutter run` עם סינון רעשי Android (GoogleApiManager, Choreographer וכו').

| מערכת הפעלה | סקריפט | הרצה |
|-------------|--------|------|
| Windows (PowerShell) | `run_clean.ps1` | `.\run_clean.ps1` |
| Windows (CMD) | `run_filtered.bat` | `run_filtered.bat` |
| Linux/Mac | `run_clean.sh` | `./run_clean.sh` |

## קבצי תצורה

- `firebase-service-account.json` - credentials ל-Firebase
