# סקריפט חלוקת מוצרים לפי קטגוריה

## מה הסקריפט עושה?

הסקריפט קורא את `assets/data/products.json` ומחלק את המוצרים לקבצי הקטגוריות הקיימים:

- `coffee_tea.json` - קפה ותה
- `dairy.json` - מוצרי חלב
- `fruits.json` - פירות
- `meat_fish.json` - בשר ודגים
- `other.json` - אחר
- `personal_hygiene.json` - היגיינה אישית
- `rice_pasta.json` - אורז ופסטה
- `spices_baking.json` - תבלינים ואפייה
- `sweets_snacks.json` - ממתקים וחטיפים
- `vegetables.json` - ירקות

## דרישות

- Dart SDK מותקן
- קובץ `products.json` קיים ב-`assets/data/`

## הרצה

מהתיקייה הראשית של הפרויקט:

```bash
dart run scripts/split_products_by_category.dart
```

## מיפוי קטגוריות

הסקריפט משתמש במיפוי בין שמות קטגוריות (עברית/אנגלית) לשמות קבצים:

| קטגוריה | קובץ |
|---------|------|
| פירות / fruits | fruits.json |
| ירקות / vegetables | vegetables.json |
| מוצרי חלב / dairy | dairy.json |
| בשר ודגים / meat_fish | meat_fish.json |
| אורז ופסטה / rice_pasta | rice_pasta.json |
| תבלינים ואפייה / spices_baking | spices_baking.json |
| ממתקים וחטיפים / sweets_snacks | sweets_snacks.json |
| קפה ותה / coffee_tea | coffee_tea.json |
| היגיינה אישית / personal_hygiene | personal_hygiene.json |
| אחר / other | other.json |

**הערה:** מוצרים עם קטגוריה לא ממופה יועברו אוטומטית ל-`other.json`

## פלט לדוגמה

```
🔄 מתחיל לחלק מוצרים לפי קטגוריה...

✅ נמצאו 350 מוצרים

📊 התפלגות מוצרים:

✅ fruits.json: 25 מוצרים
✅ vegetables.json: 30 מוצרים
✅ dairy.json: 20 מוצרים
✅ meat_fish.json: 15 מוצרים
✅ rice_pasta.json: 18 מוצרים
✅ spices_baking.json: 22 מוצרים
✅ sweets_snacks.json: 28 מוצרים
✅ coffee_tea.json: 12 מוצרים
✅ personal_hygiene.json: 10 מוצרים
✅ other.json: 5 מוצרים

📝 סיכום:
   • סה"כ מוצרים: 350
   • קטגוריות לא ממופות: 5 (הועברו ל-other.json)

🎉 הפיצול הושלם בהצלחה!
📂 הקבצים נמצאים ב: assets/data/categories/
```

## שימוש בקבצים

אחרי ההרצה, אפשר לטעון כל קטגוריה בנפרד בקוד:

```dart
// טעינת קטגוריה ספציפית
final fruitsJson = await rootBundle.loadString('assets/data/categories/fruits.json');
final fruits = jsonDecode(fruitsJson);
```

## הוספת קטגוריה חדשה

כדי להוסיף קטגוריה חדשה:

1. הוסף את המיפוי ב-`categoryMapping` בסקריפט
2. הריץ את הסקריפט מחדש
3. הקובץ החדש ייווצר אוטומטית ב-`categories/`
