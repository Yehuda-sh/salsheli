# מבנה תיקיית `assets/`

תיקייה זו מכילה את כל ה-assets של האפליקציה: מוצרים, תבניות, תמונות ופונטים.

---

## מבנה התיקיות

```
assets/
├── data/
│   ├── list_types/          קבצי מוצרים לפי סוג רשימה
│   │   ├── supermarket.json   (23,362 מוצרים, 7.5MB)
│   │   ├── pharmacy.json      (1,059 מוצרים)
│   │   ├── market.json        (996 מוצרים)
│   │   ├── butcher.json       (835 מוצרים)
│   │   ├── greengrocer.json   (592 מוצרים)
│   │   └── bakery.json        (477 מוצרים)
│   ├── IMAGE_URLS.md        רשימת קישורי תמונות (Unsplash/Pexels)
│   └── README.md            תיעוד זה
│
├── templates/               תבניות רשימות מוכנות
│   ├── list_templates.json    אינדקס כל התבניות
│   ├── event_bbq.json         ברביקיו
│   ├── event_birthday.json    יום הולדת
│   ├── event_friends.json     אירוח חברים
│   ├── shopping_weekly.json   קניות שבועיות
│   └── pantry_basic.json      מזווה בסיסי
│
├── images/                  תמונות
│   ├── app_icon.png           אייקון האפליקציה
│   ├── app_icon_foreground.png  אייקון adaptive (Android)
│   ├── logo.png               לוגו
│   ├── default_avatar.webp    אווטאר ברירת מחדל
│   ├── empty_cart.webp        מצב ריק — עגלת קניות
│   ├── empty_history.webp     מצב ריק — היסטוריה
│   ├── empty_notifications.webp  מצב ריק — התראות
│   ├── empty_pantry.webp      מצב ריק — מזווה
│   ├── greeting_morning.webp  ברכת בוקר
│   ├── greeting_afternoon.webp  ברכת צהריים
│   ├── greeting_evening.webp  ברכת ערב
│   ├── greeting_night.webp    ברכת לילה
│   ├── icon_active_lists.webp   אייקון רשימות פעילות
│   ├── icon_bell.webp         אייקון התראות
│   ├── icon_home_activity.webp  אייקון פעילות
│   ├── icon_new_list.webp     אייקון רשימה חדשה
│   ├── onboarding_pantry.webp   אונבורדינג — מזווה
│   ├── onboarding_sharing.webp  אונבורדינג — שיתוף
│   ├── onboarding_shopping.webp אונבורדינג — קניות
│   ├── screenshot_frame.webp  מסגרת לצילומי מסך
│   └── shopping_cart_3d.webp  עגלת קניות תלת-ממדית
│
└── fonts/                   פונטים
    ├── Assistant-Regular.ttf  גוף טקסט
    ├── Assistant-Bold.ttf     כותרות
    └── Caveat-Variable.ttf    כתב יד (notebook feel)
```

---

## פורמט מוצר

כל קובץ JSON ב-`list_types/` מכיל מערך מוצרים:

```json
{
  "name": "חלב תנובה 3%",
  "category": "מוצרי חלב",
  "price": 6.90,
  "barcode": "7290000066318",
  "brand": "תנובה",
  "unit": "ליטר",
  "size": "1.00 ליטר",
  "isWeighted": false,
  "defaultUnit": "יח'",
  "defaultQty": 1
}
```

| שדה | חובה | תיאור |
|-----|------|--------|
| `name` | כן | שם המוצר |
| `category` | כן | קטגוריה |
| `price` | כן | מחיר בש"ח |
| `barcode` | כן | ברקוד (מזהה ייחודי) |
| `brand` | לא | מותג (לא קיים אם אין) |
| `unit` | כן | יחידת מידה |
| `size` | לא | גודל/משקל |
| `icon` | לא | אימוג'י קטגוריה |
| `source` | לא | מקור הנתון |
| `isWeighted` | כן | האם נמכר במשקל |
| `defaultUnit` | כן | יחידת ברירת מחדל |
| `defaultQty` | כן | כמות ברירת מחדל |

---

## סטטיסטיקה

| קובץ | מוצרים |
|------|--------|
| supermarket.json | 23,362 |
| pharmacy.json | 1,059 |
| market.json | 996 |
| butcher.json | 835 |
| greengrocer.json | 592 |
| bakery.json | 477 |
| **סה"כ** | **27,321** |

---

## עדכון מוצרים

```bash
dart run scripts/update_products.dart
```

הסקריפט מעדכן מחירים ומוסיף מוצרים חדשים מ-Shufersal (קבצי XML.gz פומביים).
מזהה מוצרים לפי barcode ויוצר גיבוי אוטומטי לפני שינויים.

---

**תאריך עדכון:** 29.03.2026
