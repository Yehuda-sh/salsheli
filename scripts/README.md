# 🔥 העלאת מוצרים ל-Firebase

## הוראות שימוש

### פעם ראשונה - העלאת מוצרים

```powershell
# הרץ את הסקריפט
dart run scripts/upload_products_to_firebase.dart
```

הסקריפט:
1. ✅ מתחבר ל-Firebase
2. ⬇️ מוריד את כל המוצרים מה-API
3. 🔄 מסיר כפילויות
4. ☁️ מעלה ל-Firestore (collection: `products`)

**זמן ריצה:** כ-5-10 דקות (תלוי בכמות המוצרים)

---

## עדכון מוצרים בעתיד

אפשר להריץ את הסקריפט שוב כדי לעדכן את כל המוצרים:

```powershell
dart run scripts/upload_products_to_firebase.dart
```

---

## מבנה המוצרים ב-Firestore

```
products/
  └── {barcode}/
      ├── name: string
      ├── category: string
      ├── brand: string
      ├── unit: string
      ├── icon: string
      ├── price: number
      ├── store: string
      └── lastUpdate: timestamp
```

---

## פתרון בעיות

**שגיאת הרשאות:**
- וודא ש-Firebase מוגדר נכון
- בדוק כללי אבטחה ב-Firestore Console

**API לא עובד:**
- בדוק את `published_prices_service.dart`
- וודא שיש חיבור לאינטרנט
