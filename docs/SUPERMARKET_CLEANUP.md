# 🧹 ניקוי "סופר בלבד" — מחיקת סוגי הרשימות שאינם-סופר

> **מה זה:** תוכנית ביצוע למחיקה מלאה (לא הסתרה) של כל מה שאינו-סופר, לפי [PRODUCT_DIRECTION.md](PRODUCT_DIRECTION.md).
> **סטטוס:** פאזות 1-6 ✅ בוצעו. פאזה 7 ⬜ ממתינה — **לבצע כשיש זמן.**
> **החלטות מפתח:** למחוק (לא להשאיר מוסתר); לשמור `supermarket` + `other` בלבד; לשמור את תבניות המזווה/השבועי; "אישור בקשות" + "פישוט תפקידים" — **מחוץ להיקף הזה** (עבודה נפרדת בעתיד).

זה מסמך **חד-פעמי** — כשכל הפאזות בוצעו, אפשר למחוק אותו (ההיסטוריה ב-git).

---

## למה
המיקוד לסופר ([PRODUCT_DIRECTION](PRODUCT_DIRECTION.md) §1) קבע: **אין בורר סוגים, כל רשימה היא רשימת סופר.** 8 הסוגים האחרים (בית מרקחת, ירקן, אטליז, מאפייה, שוק, משק בית, אירוע, [+ "מי מביא?"]) — נמחקים end-to-end. המסמך המקורי אמר "מוסתרים, הפיכים" — **ההחלטה עודכנה ל"נמחקים".** (לעדכן את המסמך בפאזה 7.)

**סדר המחיקה:** מ-callers/UI כלפי הגדרות/נתונים — כדי שהבילד לא יישבר באמצע.

**פרוטוקול אימות אחרי כל פאזה:** `dart analyze lib/` נקי → (אם נגעת במודל) `dart run build_runner build --delete-conflicting-outputs` → `flutter test` ירוק → commit + push. לנקות רעש CRLF מקבצי `.g.dart` שלא שונו תוכנית.

---

## ✅ בוצע

### פאזה 1 — בורר הסוגים (UI) · commit `4fedbf57`
- `create_list_screen.dart`: הוסרו `_buildTypeSelector`/`_buildTypeGridItem`/`_buildEventModeSelector`/`_buildEventModeOption` + הבלוקים ב-build. `_type` מקובע ל-`'supermarket'`.
- `shopping_lists_screen.dart`: הוסר ספרד צ'יפי הסוגים (`...ListTypes.all.map(...)`). **נשאר צ'יפ "all" בודד — לנקות בפאזה 4.**
- ‎-289 שורות. analyze נקי.

### פאזה 2 — מצב אירוע + "מי מביא?" · commit `d50a0f81`
- נמחק `who_brings_screen.dart` (677 שורות).
- `shopping_list.dart`: הוסר השדה `eventMode` + הקבועים `eventModeWhoBrings/Shopping/Tasks` + plumbing ב-factories/copyWith. `.g.dart` רוענן.
- `notification.dart`: הוסר `whoBringsVolunteer` (13→12 סוגים) + כל ה-switch arms. `.g.dart` רוענן. הטסט עודכן.
- ניווט: `shopping_list_details` + `shopping_lists` תמיד פותחים `ActiveShoppingScreen` (מיון חכם); `shopping_list_tile` משתמש בברירת מחדל. גם ענף ה-checklist הוסר.
- הוסר `eventMode` מ-provider, מ-create-list submit, ומ-`TemplateService.getEventModeForTemplate`.
- ‎-841 שורות. analyze נקי, 479 טסטים עוברים.

**הקשור: הסתרת כרטיס "מה לבשל"** (`ffd0dbae`) — הוסר מהרינדור; הקוד + `filters_data` food-logic סומנו DORMANT. `url_launcher` תלוי כעת רק בו (יהפוך למיותר אם הכרטיס יימחק לגמרי).

### פאזה 3 — תבניות אירוע · commit `0a9f6dd`
- נמחקו 8 תבניות `event_*.json` (bbq/birthday/friends/hanukkah/passover/picnic/rosh_hashana/shabbat).
- נשמרו `pantry_basic.json` + `shopping_weekly.json` (המזווה משתמש בהן).
- `list_templates.json` עודכן — נשארה רק קטגוריית "קניות שוטפות".
- `template_service.dart`: הוסר `isEventTemplate` + לוגיקת event. `getListTypeForTemplate` מחזיר תמיד `'supermarket'`.
- `template_picker_dialog` / `template_preview_dialog`: אין refs ל-event.

### פאזה 4 — config: הגדרות הסוגים
- `list_type_keys.dart`: הוסרו `pharmacy/greengrocer/butcher/bakery/market/household/event` מ-`all` ומהקבועים. נשמרו `supermarket` + `other`.
- `list_types_config.dart`: הוסרו 7 ה-`ListTypeConfig` המתאימים (נשמרו supermarket + other). `performValidation` מאמת 1:1 מול `ListTypeKeys.all`.
- `shopping_list.dart`: הוסרו הקבועים `typePharmacy`...`typeEvent` (נשמרו `typeSupermarket` + `typeOther`). `shouldUpdatePantry` כבר לא מתייחס ל-`typeEvent`.
- `shopping_lists_screen.dart`: הוסר כל בורר סינון-הסוג (צ'יפ "all" בודד, sheet, tag, `_getTypeLabel`) — כל הרשימות הן סופר. נשארו חיפוש + מיון.
- הטסטים ב-`shopping_list_test.dart` עודכנו לשני הסוגים שנשארו.

### פאזה 5 — קטלוגים
- נמחקו 5 קבצי JSON: `pharmacy.json`, `market.json`, `butcher.json`, `greengrocer.json`, `bakery.json`. נשמר `supermarket.json`.
- `local_products_repository.dart`: `_supportedTypes` צומצם ל-`{supermarket}` בלבד (כל סוג אחר, כולל `other`, נופל ל-supermarket).
- `template_service.dart`: רשימת ה-`sources` צומצמה ל-`['supermarket']` (טען רק קטלוג אחד).
- `scripts/fetch_new_products.py`: `CATALOG_FILES` צומצם ל-`supermarket.json` (מניעת אזהרות "not found" בכל הרצה).
- `assets/data/README.md`: עץ + סטטיסטיקה עודכנו לקטלוג יחיד.
- ניקוי comments מיותמים: `products_provider`, `products_repository`, `firebase_products_repository`.
- **pubspec — לא שונה**: ההצהרה `assets/data/list_types/` היא ברמת תיקייה (supermarket.json נשאר).

### פאזה 6 — מחרוזות + stickers + נתוני דמו
- `app_strings_he.dart` + `app_strings_en.dart`: הוסרו `typePharmacy`...`typeEvent` (+ ה-`*Short`), `eventMode*`, `whoBrings*`, וגם `allTypesLabel`/`filterByTypeLabel`/`filterByTypeTitle` (חוב מפאזה 4). נשמרו `typeSupermarket`+`typeOther`.
- **stickers:** נמחקו 6 PNG (`pharmacy/greengrocer/butcher/bakery/market/event`). `household.png` לא היה קיים מלכתחילה. נשמרו `supermarket.png` + `other.png`.
- `scripts/rebuild_demo_data.js`: `loadProducts` טוען רק supermarket. 8 רשימות הדמו שהיו סוגים אחרים (greengrocer/bakery/butcher/household/market/pharmacy ×2) הומרו ל-`supermarket` עם סינון לפי קטגוריות אמיתיות (פירות וירקות / לחם ומאפים / בשר ודגים / היגיינה אישית וכו'). שמות הרשימות נשמרו (גיוון). `list_type` באירועי הפעילות יושר ל-supermarket.
- **חוב מפאזה 2 — נשאר במכוון:** ה-helpers של `whoBrings` ב-`unified_list_item.dart` + `volunteerName` ב-`notification.dart` עדיין שזורים בזרימת **אישור-הבקשות** (מחוץ להיקף). יש לנקות אותם רק כשאישור-הבקשות יימחק.

---

## ⬜ נשאר לביצוע

### פאזה 7 — מסמכים (סיכון נמוך)
- `PRODUCT_DIRECTION.md`: לשנות את §1 ואת טבלת ה-superseded מ"מוסתרים, הפיך" ל**"נמחקו"**.
- `AGENTS.md`, `REFACTOR_PLAN.md`, `REVIEW_BACKLOG.md`, `assets/data/README.md`, `store-listing.md`: ליישר.
- **לתעד כעבודה עתידית** (לא בוצעה): מחיקת "אישור בקשות" (עורך→מנהל) + "פישוט תפקידים". ראה למטה.

---

## 🚫 מחוץ להיקף (עבודה נפרדת בעתיד)
המסמך הראשי מסמן אותם כנחתכים, אבל **המשתמש בחר להשאיר אותם לעת עתה** (יוני 2026):
- **אישור בקשות** ("עורך מציע → מנהל מאשר") — שזור ב-`unified_list_item.fromRequestData` + ה-helpers של whoBrings.
- **פישוט תפקידים** (4 רמות → בעלים + חבר) — במסמך זה מסומן "מומלץ, לאישור סופי" (טרם הוחלט סופית).

## 📝 הערה צדדית
3 אזהרות `override_on_non_overriding_member` על `existsUser` בקבצי טסט (`inventory_provider_test`, `shopping_lists_provider_test`, `user_context_test`) — mock של מתודה שהוסרה. לא קשור, אבל מרעיש כל analyze. תיקון של דקה.
