# Review Backlog

מעקב אחרי **החלטות שעשינו** ו-**רעיונות שדחינו** במהלך סקירות קבצים, מאורגן לפי מסך/area.

**מטרה:** לתת לסקירה הבאה זיכרון של מה כבר הוחלט ומה ממתין — כדי שלא נחליט סותרות ולא נפספס fixes שתלויים בקבצים שעוד לא הגענו אליהם.

**איך להשתמש:**
1. **תחילת סקירת קובץ:** לזהות לאיזה מסך הוא שייך → לקרוא את הסקציה המתאימה.
2. **במהלך הסקירה:** "מה שעשינו במסך הזה" כבר מוגדר, להיצמד לעקביות.
3. **סוף סקירה:**
   - פריטים חדשים שבוצעו → ✅ Decisions Made
   - רעיונות שנדחו ל-"לא עכשיו" → ⏸️ Deferred (עם trigger קישור)

**מבנה כל סקציית מסך:**
- **📂 Components** — אילו קבצים כבר נגענו ומשפיעים על המסך
- **✅ Decisions Made** — החלטות עיצוב/UX/ארכיטקטורה שכבר עשינו ושוקלות לאיחוד עם החלטות עתידיות
- **⏸️ Deferred** — רעיונות שדחינו, עם trigger (איזה קובץ עתידי יעיר אותם)

---

## Cross-Cutting Widgets

ויג'טים שמופיעים ב-30+ מסכים. החלטות עליהם משפיעות על **כל** האפליקציה.

### `notebook_background.dart`

**📂 Used in:** 30 מסכים — full variant ב-23, `subtle()` ב-7 (auth + welcome + index hint).

**✅ Decisions Made:**
- API פשוט: רק `NotebookBackground()` ו-`NotebookBackground.subtle()`. הוסרו 6 פרמטרים שאף caller לא הגדיר.
- Stroke width מקובע: `kNotebookLineStrokeWidth = 1.0` (סימטריה עם `kNotebookRedLineWidth = 2.0`).
- Subtle line opacity: `kNotebookSubtleLineOpacity = 0.10` (סימטריה עם `kNotebookLineOpacity = 0.5`).
- RTL-aware: הקו האדום עובר לימין ב-RTL, `shouldRepaint` כולל `isRtl`.
- Theme-aware: dark mode עם `kDarkPaperBackground`, `kNotebookBlueDark`, `kNotebookBlueSoftDark`.
- Performance: RepaintBoundary outside, ExcludeSemantics, shouldRepaint מלא על כל השדות.

**⏸️ Deferred:**
- אין — הקובץ עבר 12-category review מלא (כולל Design Polish + Blind Spots) ב-29/4/2026.

**🎯 Reference:** זה אחד הקבצים הראויים-לחיקוי באפליקציה לפי הצ'קליסט (RTL, Performance, A11y).

### `legal_content_dialog.dart`

**📂 Used in:** Welcome Screen + Settings Screen (Terms + Privacy links).

**✅ Decisions Made:**
- AppDialog.show wrapper (לא raw showDialog).
- כותרת ב-`scheme.primaryContainer` — **Material formal style מכוון**, לא notebook+sticky. הקשר משפטי דורש tone רשמי, לא משחקי.
- ShaderMask לפייד בתחתית — premium signal של "יש עוד תוכן".
- `maxHeight: 80%` של גובה המסך, `maxWidth: 500` לטאבלט.
- Line height 1.7 לטקסט המשפטי הארוך.
- 3 דרכים לסגור: X icon, "הבנתי" button, tap-outside (barrierDismissible של AppDialog).
- Theme extension reuse: `theme.extension<AppBrand>()` (לא re-fetch של `Theme.of(context).extension<AppBrand>()`).

**⏸️ Deferred:** אין.

**🎯 הערה עיצובית:** הדיאלוג הזה הוא **חריג מודע** משפת notebook+sticky. הקשר משפטי ⇒ tone Material formal. אם בעתיד יוחלט להחיל את שפת notebook+sticky גם פה — זה יהיה החלטה גלובלית של "כל הדיאלוגים יוצאים ל-highlighter" ולא תיקון נקודתי.

---

## Pending Invites Screen

### 📂 Components נגעו
- `pantry_merge_dialog.dart` — נסקר במנותק (לא במסגרת סקירה מלאה של המסך)

### ✅ Decisions Made
- **`pantry_merge_dialog`**: הומר ל-`AppDialog.show<bool>()` (היה raw `showDialog`).
- **Icon size semantics**: `kFontSizeDisplay` → `kIconSizeLarge` (font-size constant על icon היה שגוי סמנטית).
- **UX**: "ביטול" → "השאר אישי" — המשתמש לא **מבטל** את קבלת ההזמנה, הוא **בוחר** לשמור על המזווה האישי נפרד. מילה מדויקת = פחות בלבול.

### ⏸️ Deferred
- **🚨 קריטי: `showPantryMergeDialog` הוא stub כרגע** — `pending_invites_screen.dart:154` יש `// TODO: implement actual merge logic when user confirms`. הדיאלוג מחזיר `bool` אבל ה-caller **מתעלם מהתוצאה**. המשתמש לוחץ "העבר למזווה הבית" → כלום לא קורה. **Trigger:** סקירה של `pending_invites_screen.dart` או של `inventory_provider.dart`. **היקף:** בינוני — צריך method חדש ב-`InventoryProvider` שמעביר items מ-personal scope ל-household scope.
- **שאר הקבצים של המסך** — לא נסקרו ב-12-category checklist. **Trigger:** סקירה רשמית של Pending Invites Screen.

---

## Welcome Screen

### 📂 Components נגעו
- `welcome_screen.dart` — onboarding ראשי (carousel + benefits + CTA)
- `app_strings_he.dart` / `app_strings_en.dart` — strings ספציפיים ל-welcome

### ✅ Decisions Made
- **Inclusive language בנקודת הכניסה** — "לכל המשפחה" → "לכל הבית", "המשפחה מסונכרנת" → "כולם מסונכרנים" (he+en). זה הסתום ראשון של המשתמש — חייב להיות נכון לפני ה-L1 sweep הכללי.
- **PageView reverse לפי locale** — `reverse: isRtl` במקום קבוע `true`. תואם את ה-WormDotIndicator שכבר היה locale-aware.
- **Parallax direction לפי locale** — `offset * intensity * (isRtl ? -1 : 1)`. הרקע נע נגד כיוון ה-swipe בשתי השפות.
- **shouldRepaint מלא ב-_WormPainter** — כולל `inactiveColor` ו-`count`, לא רק `pageOffset` ו-`activeColor`. תואם להחלפת theme.
- **Token alignment** — `alpha: 0.5` ב-bodyMedium → `kOpacityMedium`.
- **Theme extension reuse** — `brand?.success` משומש מתוך scope, לא re-fetch של `Theme.of(context).extension<AppBrand>()`.

### ⏸️ Deferred
- **Style-on-style ב-`_SimpleFeatureCard`** — `theme.textTheme.titleLarge?.copyWith(fontSize: kFontSizeTitle, fontWeight: FontWeight.w800)`. דפוס שחוזר באפליקציה (ראה גם `suggestions_today_card.dart`, `section_header.dart` שתוקן). **Trigger:** typography sweep מתוכנן או סקירה של הקובץ הזה. **היקף:** קטן בקובץ, בינוני בכלל האפליקציה.
- **Magic alphas רבים ב-`_BottomSection`** — `0.87`, `0.45`, `0.6`, `0.25`, `0.92`, `0.06`, `0.35`. כל אחד מהם premium marker מכוון. **Trigger:** sweep חוצה-קבצים אם נראה ש-0.45/0.6 מופיעים בכמה מקומות. **היקף:** קטן.

---

## Settings Screen

### 📂 Components נגעו
- `section_header.dart` (משמש 5×) — sectional headers ב-Settings

### ✅ Decisions Made
- **SectionHeader → highlighter style**: צבע רק מאחורי הטקסט (כמו טוש סימון על מחברת), לא Container על כל הרוחב.
- **Default highlight color**: `brand?.stickyYellow ?? kStickyYellow` (תואם sticky-notes language).
- **Highlight opacity**: `kHighlightOpacity` (0.3) — לא `kOpacityLight` למרות שהערך זהה. השם מספר את הסיפור ("מסמנים בטוש").
- **Typography**: `titleMedium + bold` (לא `titleSmall + bold` שזה style-on-style).
- **Count badge**: `kOpacityLight` (0.3, היה `kOpacitySoft` — נחבא מדי).
- **Layout**: title pill + Spacer + trailing (לא Expanded title שגרם לרוחב מלא).

### ⏸️ Deferred
- **Toggles בסגנון notebook** — כרגע ה-toggle items ב-Settings בסגנון Material רגיל. ה-header עכשיו on-brand אבל הסקציה עצמה לא. **Trigger:** סקירת `settings_screen.dart` או ה-toggle widget. **היקף:** refactor גדול של כל המסך.
- **Highlighter color variation per section** — היום כל הכותרות צהובות. אפשר להעביר color לכל caller (notifications=yellow, household=cyan, וכו') כמו tabs במחברת. **Trigger:** סקירת `settings_screen.dart`. **היקף:** קטן.
- **3 מימושים של section header** — `shopping_lists_screen.dart:807` ו-`product_selection_bottom_sheet.dart:890` בנו לעצמם. אחרי ה-redesign של SectionHeader, אפשר לאחד. **Trigger:** סקירת `shopping_lists_screen.dart`. **היקף:** בינוני.

---

## Conventions

- **Trigger** — איזה קובץ עתידי יחזיר את הפריט הזה לדיון.
- **היקף** — קטן (פחות מ-20 שורות), בינוני (מספר קבצים), גדול (refactor מסך מלא).
- **מקור** — אופציונלי, אם רוצים לקשר ל-commit ספציפי.
