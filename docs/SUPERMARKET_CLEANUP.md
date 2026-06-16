# 🧹 ניקוי "סופר בלבד" — מחיקת סוגי הרשימות שאינם-סופר

> **מה זה:** תוכנית ביצוע למחיקה מלאה (לא הסתרה) של כל מה שאינו-סופר, לפי [PRODUCT_DIRECTION.md](PRODUCT_DIRECTION.md).
> **סטטוס:** פאזות 1-2 ✅ בוצעו. פאזות 3-7 ⬜ ממתינות — **לבצע כשיש זמן.**
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

---

## ⬜ נשאר לביצוע

### פאזה 3 — תבניות אירוע (סיכון בינוני)
- **למחוק** 8 תבניות: `assets/templates/event_bbq.json`, `event_birthday.json`, `event_friends.json`, `event_hanukkah.json`, `event_passover.json`, `event_picnic.json`, `event_rosh_hashana.json`, `event_shabbat.json`.
- **לשמור:** `pantry_basic.json` + `shopping_weekly.json` (המזווה משתמש בהן — ראה `inventory_provider`, `my_pantry_screen`, `pantry_suggestions`).
- לעדכן את האינדקס `assets/templates/list_templates.json` — להסיר את רשומות האירוע.
- `template_service.dart`: לבדוק/לנקות `isEventTemplate` (נשאר ללא callers אחרי פאזה 2) + כל לוגיקת event שנותרה. `getListTypeForTemplate` — לוודא שלא מחזיר סוג שאינו-סופר.
- `template_picker_dialog.dart` / `template_preview_dialog.dart`: לוודא שלא מציגים תבניות אירוע.

### פאזה 4 — config: הגדרות הסוגים (סיכון נמוך)
- `list_type_keys.dart`: להסיר `pharmacy/greengrocer/butcher/bakery/market/household/event` מ-`all` ומהקבועים. **לשמור `supermarket` + `other`** (`other` = fallback חובה ל-resolve pattern).
- `list_types_config.dart`: להסיר את 7 ה-`ListTypeConfig` המתאימים (לשמור supermarket + other). `performValidation` תאמת אוטומטית 1:1 מול `ListTypeKeys.all`.
- `shopping_list.dart`: להסיר את הקבועים `typePharmacy`...`typeHousehold`, `typeEvent` (לשמור `typeSupermarket` + `typeOther`). לעדכן `shouldUpdatePantry` (היום מתייחס ל-`typeEvent` — הופך למיותר).
- `shopping_lists_screen.dart`: להסיר את צ'יפ ה-"all" הבודד שנשאר מפאזה 1 (כל הרשימות הן סופר → סינון סוג מיותר).

### פאזה 5 — קטלוגים (סיכון בינוני)
- **למחוק** 5 קבצי JSON: `assets/data/list_types/pharmacy.json`, `market.json`, `butcher.json`, `greengrocer.json`, `bakery.json`. **לשמור `supermarket.json`.**
- `local_products_repository.dart`: לעדכן את ה-loader שטוען לפי סוג — שייטען רק supermarket.
- **pubspec — אין צורך לשנות**: ההצהרה `assets/data/list_types/` היא ברמת תיקייה (supermarket.json נשאר). אותו דבר ל-`assets/templates/` ו-`assets/icons/list_types/`.
- לעדכן `assets/data/README.md` (סטטיסטיקה + עץ).

### פאזה 6 — מחרוזות + stickers + נתוני דמו (סיכון נמוך)
- `app_strings_he.dart` + `app_strings_en.dart`: להסיר `typePharmacy`...`typeEvent` (+ ה-`*Short`), `eventMode*`, `whoBrings*`.
- **stickers:** למחוק 7 PNG ב-`assets/icons/list_types/` (`pharmacy/greengrocer/butcher/bakery/market/event` + לבדוק household). **לשמור `supermarket.png` + `other.png`.**
- `scripts/rebuild_demo_data.js`: להסיר יצירת רשימות שאינן-סופר (event/who_brings/templates של אירוע) + התראות `who_brings_volunteer`.
- **חוב מפאזה 2 לסגור כאן:** ה-helpers של `whoBrings` ב-`unified_list_item.dart` (`isWhoBrings`, `neededCount`, `volunteers`, factory `whoBrings`, וכו') + ה-getter `volunteerName` ב-`notification.dart` — נשארו כי היו שזורים בזרימת אישור-הבקשות. אם אישור-הבקשות עדיין קיים → להשאיר; אם נמחק (עבודה נפרדת) → לנקות גם פה.

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
