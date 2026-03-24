# Scripts

## `rebuild_demo_data.js` (Main)
יצירת נתוני דמו מלאים ב-Firebase Production.
12 משתמשים, 7 בתים, ~27 רשימות, מזווה, קבלות, התראות.

```bash
node scripts/rebuild_demo_data.js
```

**חשוב:** כשמשנים מבנה נתונים באפליקציה (models, configs) — לעדכן גם את הסקריפט!

## `debug_token_server.js`
שרת debug ליצירת Firebase custom tokens (עוקף reCAPTCHA).
לשימוש עם emulator בלבד.

```bash
node scripts/debug_token_server.js
# ואז בדפדפן: http://localhost:9877/token?email=avi.cohen@demo.com
```

## `fix_supermarket_json.py`
ניקוי וקטגוריזציה אוטומטית של `assets/data/list_types/supermarket.json`.
להרצה כשמעדכנים את קטלוג המוצרים.

```bash
python scripts/fix_supermarket_json.py
```

## `fetch_new_products.py`
משיכת מוצרים חדשים מכל רשתות הסופר בישראל (Open Israeli Supermarkets).
משווה מול הקטלוג הקיים ושומר רק מוצרים עם ברקודים חדשים לקובץ נפרד.

```bash
# התקנה (פעם אחת)
pip install il-supermarket-scraper il-supermarket-parser pandas

# הרצה — כל הרשתות
python scripts/fetch_new_products.py

# רשתות ספציפיות
python scripts/fetch_new_products.py --chains SHUFERSAL RAMI_LEVY

# רשימת רשתות זמינות
python scripts/fetch_new_products.py --list-chains

# שימוש בנתוני Kaggle (אלטרנטיבה)
python scripts/fetch_new_products.py --kaggle scripts/kaggle_data/
```

**פלט:** `assets/data/list_types/new_products.json` — לא דורס את הקטלוג הקיים!

**הערה:** חלק מהרשתות חוסמות גישה מחוץ לישראל.

## קבצי תצורה

- `firebase-service-account.json` — credentials ל-Firebase (לא ב-git)
