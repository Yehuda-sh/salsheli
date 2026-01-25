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

## סקריפטי ניקוי

- `run_clean.ps1` / `run_clean.sh` - ניקוי הפרויקט
- `run_filtered.bat` - הרצה מסוננת

## קבצי תצורה

- `firebase-service-account.json` - credentials ל-Firebase
