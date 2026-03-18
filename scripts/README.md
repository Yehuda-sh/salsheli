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

## קבצי תצורה

- `firebase-service-account.json` — credentials ל-Firebase (לא ב-git)
