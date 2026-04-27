# Scripts

סקריפטים לתחזוקת הפרויקט: יצירת נתוני דמו, עדכון קטלוג מוצרים, ניקוי וסיווג.

---

## 📦 נתוני דמו

### `rebuild_demo_data.js` (הראשי)

יצירה מחדש של כל נתוני הדמו ב-Firebase Production. **מוחק** הכל לפני יצירה.

**מה נוצר:**
- 22 משתמשים (כולל edge cases: Google/Apple sign-in, שם ארוך, אנגלית, geresh, removed user, elderly, roommates)
- 15 בתים
- ~57 רשימות (כל 9 הסוגים, statuses שונים, who-brings, templates, target dates)
- ~110 פריטי מזווה
- ~76 קבלות
- ~51 events ב-activity_log (כל 9 סוגי האירועים)
- ~34 התראות (כל ה-types כולל edge cases)
- 4 הזמנות ממתינות

**הרצה:**
```bash
node scripts/rebuild_demo_data.js
```

**Credentials:** הסקריפט מנסה קודם `scripts/firebase-service-account.json` (פיתוח מקומי), ובוחר fallback ל-`GOOGLE_APPLICATION_CREDENTIALS` (CI / GitHub Actions).

**אופטימיזציות אחרונות:**
- כל ה-timestamps נשמרים כ-`Timestamp.fromDate()` (תומך ב-`where()` עם `DateTime` באפליקציה)
- כתיבות מקבילות ב-`Promise.all` במקום סדרתי (~5-10× יותר מהיר)

**⚠️ חשוב:** כשמשנים מבנה נתונים באפליקציה (models, configs) — לעדכן גם את הסקריפט!

**GitHub Action:** ניתן להריץ דרך `.github/workflows/rebuild-demo-data.yml` (workflow_dispatch).

---

## 🛒 ניהול קטלוג

### `fetch_new_products.py`

משיכת מוצרים חדשים מ-API של רשתות הסופר הישראליות, השוואה מול הקטלוג הקיים ושמירה רק של מוצרים עם ברקודים/שמות חדשים.

```bash
# התקנה (פעם אחת)
pip install il-supermarket-scraper il-supermarket-parser pandas

# הרצה — כל 34 הרשתות
python scripts/fetch_new_products.py

# רשתות ספציפיות (UPPERCASE — שמות enum, לא display names!)
python scripts/fetch_new_products.py --chains SHUFERSAL RAMI_LEVY

# רשימת רשתות זמינות
python scripts/fetch_new_products.py --list-chains

# מיזוג ישיר לקטלוג (--merge), עם אישור אוטומטי (--yes לשימוש ב-CI)
python scripts/fetch_new_products.py --merge --yes

# שימוש בנתוני Kaggle (אלטרנטיבה אם ה-scraper נחסם)
python scripts/fetch_new_products.py --kaggle scripts/kaggle_data/
```

**שמות רשתות חוקיים** (חלקי): `SHUFERSAL`, `RAMI_LEVY`, `YOHANANOF`, `VICTORY`, `OSHER_AD`, `SUPER_PHARM`, `GOOD_PHARM`, `TIV_TAAM`, `KESHET`, `KING_STORE`, `WOLT`, `YELLOW`, `BAREKET`, `HAZI_HINAM`, `NETIV_HASED`. ⚠️ לא: `Yes`, `Shufersal`, `RamiLevy` — הסקריפט מוודא וזורק שגיאה ברורה אם השם לא תקין.

**פלט:**
- ללא `--merge`: `assets/data/list_types/new_products.json` (סקירה ידנית)
- עם `--merge`: עדכון ישיר של `supermarket.json` + גיבוי ב-`scripts/backups/`

**Geo-blocking:** רוב ה-APIs חסומים מחוץ לישראל. ב-`--yes` mode (CI) הסקריפט יוצא בהצלחה (`exit 0`) ומדפיס הודעה. בריצה אינטראקטיבית — `exit 1` כדי שתזהה שמשהו נשבר.

**GitHub Action:** `.github/workflows/fetch-new-products.yml`.

---

### `fix_supermarket_json.py` + `fix_supermarket_step{2..6}.py`

סקריפטים מצטברים לסיווג מוצרים מ"כללי" לקטגוריות מתאימות. הופעלו פעם אחת בסדר (1→2→3→4→5→6), הורידו את `supermarket.json` מ-88K פריטי "כללי" ל-21K (-76%) והוסיפו 5 קטגוריות חדשות (אלכוהול, סיגריות וטבק, תוספי תזונה, צעצועים ומתנות, אלקטרוניקה).

```bash
# הצעד הראשון — keyword classification + dedupe
python scripts/fix_supermarket_json.py

# צעדים נוספים — הרץ בסדר אם נטען מחדש קטלוג גולמי
python scripts/fix_supermarket_step2.py
python scripts/fix_supermarket_step3.py
python scripts/fix_supermarket_step4.py
python scripts/fix_supermarket_step5.py
python scripts/fix_supermarket_step6.py
```

כל סקריפט שומר גיבוי `.bak`/`.bak2`/... לשחזור.

**מתי להריץ?** רק אחרי `fetch_new_products.py --merge` שהוסיף הרבה מוצרים חדשים. ברגיל — לא צריך להריץ שוב.

---

### `fix_catalog_audit.py`

אודיט חד-פעמי לקבצי הקטלוג הקטנים (`butcher`, `bakery`, `pharmacy`). הופעל בסשן 7 (27/4/2026).

**מה תוקן:**
- **butcher**: 230 פריטי בשר מעובד הוצאו מ-"אחר" לקטגוריה חדשה "נקניקים ובשרים מעובדים" (נקניקיות, סלמי, פסטרמה, קבב). 22 פריטים נוספים סווגו לפי species (עוף/בקר/הודו). "אחר" ירדה מ-278 ל-26.
- **bakery**: "מאפים" (175) חולקה ל-לחמים ולחמניות (60), עוגות (82), מאפים מזרחיים (20), מאפים מתוקים (4), מלוחים (2). ירדה ל-7 fallback genuine.
- **pharmacy**: הוסרו 15 פריטים שלא שייכים (6 ניקיון, 9 מזון בריאות). אוחדה כפילות "אביזרי שיער" → "טיפוח שיער".

```bash
python scripts/fix_catalog_audit.py
```

הסקריפט שומר `.bak` לכל קובץ לפני שינוי. ברגיל — לא צריך להריץ שוב.

---

### `fetch_product_images.py`

משיכת URLs של תמונות מוצרים מ-API של רמי לוי לפי ברקוד, ויצירת מפת `barcode → image_url` כקובץ Dart.

```bash
# נדרש Bearer token מ-rami-levy.co.il (ראה התחלת הקובץ להוראות מפורטות)
python3 scripts/fetch_product_images.py --token "Bearer YOUR_TOKEN_HERE"
```

הוראות מלאות לקבלת ה-token בהערה שבראש הסקריפט.

---

## 🔧 כלי פיתוח

### `debug_token_server.js`

שרת מקומי ליצירת Firebase custom tokens (עוקף reCAPTCHA / לוגין רגיל). **לשימוש עם emulator בלבד.**

```bash
node scripts/debug_token_server.js
# בדפדפן: http://localhost:9877/token?email=avi.cohen@demo.com
```

---

## 📁 תיקיות

- `backups/` — גיבויים אוטומטיים מ-`fetch_new_products.py --merge` (`supermarket.backup-{timestamp}.json`)
- `dumps/` — XML files מ-`il-supermarket-scraper` (זמני, לא ב-git)
- `kaggle_data/` — CSV files אם הורדו מ-Kaggle כ-fallback (לא ב-git)

---

## 🔑 Credentials

### `firebase-service-account.json`

Service account של Firebase לכתיבה ל-Firestore.

- **לא נשמר ב-git** (ב-`.gitignore`)
- **בפיתוח מקומי**: שים את הקובץ ב-`scripts/firebase-service-account.json`
- **ב-CI / GitHub Actions**: השתמש ב-secret `GOOGLE_APPLICATION_CREDENTIALS` שמצביע ל-path של הקובץ אחרי שחזור מ-secret

הסקריפטים יודעים להתמודד עם שתי האפשרויות.
