# מבנה תיקיית `assets/`

תיקייה זו מכילה את כל ה-assets של האפליקציה: מוצרים, תבניות, תמונות ופונטים.

---

## מבנה התיקיות

```
assets/
├── data/
│   ├── list_types/          קבצי מוצרים לפי סוג רשימה
│   │   ├── supermarket.json   (~112,000 מוצרים, 24MB — מנופה ומסווג)
│   │   ├── pharmacy.json      (1,026 מוצרים)
│   │   ├── market.json        (996 מוצרים)
│   │   ├── butcher.json       (834 מוצרים)
│   │   ├── greengrocer.json   (592 מוצרים)
│   │   └── bakery.json        (472 מוצרים)
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

| קובץ | מוצרים | קטגוריות |
|------|--------|----------|
| supermarket.json | ~112,000 | 27 (מנופה ומסווג, ~22% עדיין "כללי" — fallback) |
| pharmacy.json | 1,026 | 12 |
| market.json | 996 | 5 |
| butcher.json | 834 | 8 (כולל "נקניקים ובשרים מעובדים" אחרי אודיט Apr-27) |
| greengrocer.json | 592 | 4 |
| bakery.json | 472 | 6 (לחמים, עוגות, מאפים מזרחיים, מאפים מתוקים, מלוחים, fallback) |
| **סה"כ** | **~116,000** | |

> הקטלוג מתעדכן אוטומטית מ-API של רשתות הסופר הישראליות (`scripts/fetch_new_products.py`) דרך GitHub Action `fetch-new-products.yml`. שינויים ידניים (סיווג, ניקוי) — דרך הסקריפטים ב-`scripts/`.

---

## עדכון מוצרים

```bash
# אוטומטי (CI / GitHub Actions)
.github/workflows/fetch-new-products.yml   # workflow_dispatch — Run from browser

# ידני (Python)
python scripts/fetch_new_products.py --merge --yes
```

הסקריפט משווה מוצרים חדשים מול הקטלוג הקיים, מסיר כפילויות לפי `barcode`, ויוצר גיבוי ב-`scripts/backups/` לפני שינויים. מזהה מוצרים לפי `barcode` (מפתח ייחודי).

ראה [`scripts/README.md`](../../scripts/README.md) לפירוט מלא.

---

**תאריך עדכון:** 30.04.2026
