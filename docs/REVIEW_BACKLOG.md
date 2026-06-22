# Review Backlog

> 🧭 **מקור אמת למוצר:** [PRODUCT_DIRECTION.md](PRODUCT_DIRECTION.md). חלק מההחלטות למטה עברו supersede אחרי המיקוד לסופר: ניקוי 5 הקטלוגים שאינם-סופר, כרטיס "מה לבשל הערב?" (19/5), מסכי "מי מביא?"/צ'קליסט/אישור-בקשות, מנדט הפתקים בכל מסך, ומבנה מסך-הבית רב-הרשימות. **לא נמחקה היסטוריה** — רק סומן. כשמשהו כאן סותר את PRODUCT_DIRECTION, הוא מנצח.

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

## 🗓️ Session 31/5/2026 — Full-codebase audit (12 agents) + 8 fix phases

סקירת רוחב על כל 161 קבצי `lib/` ע"י 12 סוכנים מקבילים, ואז 8 פאזות תיקון
(8 commits, 478/478 טסטים, analyze נקי). סיכום ב-[AGENTS.md](../AGENTS.md) §3 Current State; היסטוריה מלאה ב-`git log`.

### ✅ Decisions Made (cross-cutting)
- **שגיאות providers → `userFriendlyError`**: כל `_errorMessage` בכל ה-providers
  עובר דרך `userFriendlyError(e, context:'op')` (מתורגם HE/EN). הוסר הפרמטר
  `errorMessagePrefix` מ-`_runAsync` (inventory + user_context). הפטרן הזה הוא
  עכשיו ה-standard — אין יותר קידומות עברית קשיחות ב-providers.
- **#13 `category_detection`**: longest-match-first על מילות מפתח משוטחות +
  `_flavorSignals` שפוסל התאמת פרי/ירק/קפה במוצר מעובד. יש טסט רגרסיה
  (`test/services/category_detection_service_test.dart`) — להוסיף לו מקרים בעתיד.
- **#14 סנכרון חי**: `active_shopping_screen` + `who_brings_screen` קוראים
  `provider.getById(widget.list.id)` (live) במקום `widget.list` קפוא. **הפטרן
  לחיקוי** למסכים תלויי-רשימה: `context.watch<ShoppingListsProvider>().getById()`
  ב-build, `context.read(...).getById()` בשיטות async. `shopping_summary_screen`
  היה ה-reference.
- **SnackBar dedup**: `removeCurrentSnackBar()` לפני `showSnackBar` הוא חובה —
  49 מקומות תוקנו. סריקה: כל `.showSnackBar(` ללא dedup ב-6 שורות שמעל.
- **שם בית ברירת מחדל**: `firebase_user_repository._defaultHouseholdName` →
  `MemoZap-XXXX` (לא "הבית של X"). אכיפת ה-Audience & Voice guardrail בשורש.

### ⏸️ Deferred (trigger → AGENTS.md Next Priorities)
- 🔴 **שער אבטחה** (#11/#17–20): הצטרפות לבית שבורה (צריך Cloud Function),
  `senderId` חסר בהתראות, `group_ids` escalation, מחיקת log/inventory ע"י כל חבר.
- **#12 שאריות**: `notifications_service` (כרוך ב-senderId), service typed-exceptions.
- **Directionality(rtl)** (~13 מקומות): קוסמטי + סיכון ויזואלי → סבב on-device.
- **Dead l10n**: 4 קבוצות מחרוזות + getters לא-נגישים (verify zero callers → מחיקה).
- **#2 מיזוג מזווה**: `pending_invites_screen` עדיין זורק את תוצאת הדיאלוג.

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

### `post_auth_navigation.dart`

**📂 Used in:** `register_screen.dart` (3 mathchas — Email/Google/Apple) + `login_screen.dart` (3 קריאות).

**✅ Decisions Made:**
- אין שינויים נדרשים — הקובץ עבר 12-category review מלא ב-29/4/2026 ללא ממצאים.
- DI-ready: `service ?? PendingInvitesService()` מאפשר טסטים.
- `Navigator.of(context)` נלכד לפני `await` — הפטרן הנכון להימנעות מ-`use_build_context_synchronously` warning.
- Error handling שקול: failure ב-Firestore לא חוסם, ממשיך ל-`/`. ה-banner בדאשבורד יטפל ברקע.
- Email-less guard (phone-only auth): ישר ל-`/`, לא תקלה.

**⏸️ Deferred:** אין.

**🎯 Reference:** ראוי לחיקוי — pattern של post-auth navigation עם DI, error handling, ולכידת navigator.

---

### `quick_login_bottom_sheet.dart`

**📂 Used in:** `login_screen.dart:366` (DEV mode only — gated visually ב-`if (kDebugMode)`, אבל ה-5-tap gesture חשוף).

**✅ Decisions Made:**
- **Token alignment**: `roleColor.withValues(alpha: 0.2)` (avatar bg) → `kOpacityLow`.
- **Magic alphas שנשארו inline**: `0.92` (sheet bg, premium tuning), `0.1` (role badge, custom value נמוך מ-kOpacitySubtle).
- **Hardcoded English strings** ("Quick Login — DEV", "Select demo user") — DEV-only, **מודע**, לא דרך AppStrings.
- **IconButton(close) ללא tooltip** — תואם CLAUDE.md A11y policy ("❌ לא — Tooltip על כל IconButton").

**⏸️ Deferred:** אין.

**🎯 Pattern**: `titleMedium + bold` (אותו pattern של section_header redesign) — דוגמה לטיפוגרפיה נכונה.

---

### `loading_overlay.dart`

**📂 Used in:** `register_screen.dart` + `login_screen.dart` — overlay טעינה במהלך auth.

**✅ Decisions Made:**
- **A11y: `Semantics(liveRegion + excludeSemantics + label: AppStrings.common.loading)`** — overlay דינמי שצץ באמצע auth, צריך להכריז פעם אחת. ה-`excludeSemantics` חוסם את ה-cycling messages (theatrical) מלהיקרא **כל 1500ms** ולהפוך לרעש בקורא מסך.
- **Cycling messages הם theatrical, לא state-driven**: הם מתחלפים בטיימר (1500ms) ולא לפי auth-state אמיתי. דקלרטיבי — עובד לויזואל, לא לקוראי מסך.
- **Performance**: `setState` כל 1500ms rebuild את כל הוויג'ט, אבל overlay חולף — over-engineering לאופטם עם ValueNotifier.

**⏸️ Deferred:** אין.

**🎯 Pattern:** דוגמה ל-liveRegion עם excludeSemantics — `theatrical UI עם הכרזה אחת**. כשיש cycling/animated text שלא משקף state אמיתי, להחריג מה-semantics tree ולתת label סטטי.

---

### `social_login_button.dart`

**📂 Used in:** `register_screen.dart` (×2 — Google/Apple) + `login_screen.dart` (×2 — Google/Apple).

**✅ Decisions Made:**
- **Refactor: עוטף עכשיו `AnimatedButton`** במקום press-tracking ידני. הרוויח: ValueNotifier (לא setState rebuild), RepaintBoundary, didUpdateWidget reset על mid-press disable, kMinTapTarget enforcement.
- **StatefulWidget → StatelessWidget** — אין יותר `_isPressed` state פנימי.
- **scaleTarget: 0.97** — תואם ה-"heavier press" preset שמתועד ב-AnimatedButton.
- **Token alignment**: 3× `alpha: 0.5` (disabled bg/icon/text) → `kOpacityMedium`.
- **Magic alpha שנשאר**: `0.1` ב-dark mode shadow — ערך תכן ספציפי, single use.
- **Theme-aware shadow**: dark mode משתמש ב-`surfaceContainerLowest` (לא `cs.shadow` שנעלם בכהה).

**⏸️ Deferred:** אין.

**🎯 Pattern**: דוגמה לאיך לעטוף widget קיים שיש לו press feedback ידני — לחלץ את ה-press logic ל-AnimatedButton ולשמור על הוויזואל הייחודי.

---

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

### `edit_household_name_dialog.dart`

**📂 Used in:** `settings_screen.dart:1204` (admin edit) + `household_invite_dialog.dart:40` (guard לפני שליחת הזמנה כשאין שם בית).

**✅ Decisions Made (30/4/2026):**
- **Removed hardcoded `textDirection: TextDirection.rtl` + `textAlign: TextAlign.right`**: שמות באנגלית ("Smith family") הוצגו הפוך. ה-app RTL גלובלית — TextField בוחר אוטומטית. אותו pattern flagged ב-`register_screen._askHouseholdName` Backlog deferred.
- **Added `HapticFeedback.lightImpact()` on save success**: עקביות עם שאר ה-CRUD באפליקציה (suggestions/onboarding/social_login).
- **Added `onSubmitted` + `textInputAction: TextInputAction.done`**: מקלדת "Done" שומרת. צמצום חיכוך mobile.
- **Extracted local `trySave()` function**: shared בין `onSubmitted` ל-`onPressed` של FilledButton — DRY.
- **Magic `40` → `_kMaxHouseholdNameLength`**: file-level const עם הערה "Firestore field size + UI readability".

**⏸️ Deferred:**
- **AlertDialog בתוך AppDialog — possible double-chrome**: AppDialog.show כבר מספק wrapper (barrier + animation). AlertDialog בפנים מוסיף card שלו. שאר הדיאלוגים באפליקציה (`pantry_merge_dialog`, `household_invite_dialog`) משתמשים בcontent מותאם בתוך AppDialog. **Trigger:** refactor כללי של הדיאלוגים. **היקף:** קטן בקובץ, אבל החלטה ארכיטקטונית רחבה.

**🎯 Pattern**: דוגמה ל-dialog פשוט עם state local (StatefulBuilder), shared submit (button + keyboard Done), graceful error handling, ו-Source-vs-Symptom עם caller שני שמטפל ב-"no name" ב-source במקום dead-end.

---

### `dev_banner.dart`

**📂 Used in:** `main.dart:207, 210` — global mount ב-`MaterialApp.builder`. מופיע על כל מסך באפליקציה כש-`AppConfig.isProduction == false`.

**✅ Decisions Made:**
- **חריגים מודעים מ-design tokens — תועדו במפורש בדוקסטרינג:**
  - `Positioned(right: 0)` פיזי, לא directional — DEV badges top-right ב-LTR וב-RTL כאחד (קונבנציה universal).
  - `Colors.orange/black/white` hardcoded — DEV ribbon הוא signal של "כלי debug, לא chrome". theming יבלבל אותו עם UI elements.
  - הסטייל glassmorphic הוא **breakdown מכוון** משפת notebook+sticky — דווקא אי-תאימות מסמלת "אני לא חלק מהמוצר".
- **קבועים סמנטיים:** `_kRibbonSize = 88.0` (file-level) + `_kAnimationDuration = Duration(milliseconds: 2400)` — ה-duration משותף ל-pulse ו-shimmer (single source of truth, שינוי באחד דורש שינוי בשני).
- **Performance**: RepaintBoundary סביב האנימציה האינסופית, IgnorePointer (לא אינטראקטיבי), ExcludeSemantics (debug visual, לא להכריז).
- **Cross-file fix**: header של `app_layout.dart:1` תוקן — הסיר את הטענה השגויה "NotebookBackground + DevBanner wrapper" (שניהם לא ב-AppLayout).

**⏸️ Deferred:** אין.

**🎯 Pattern**: דוגמה ל-widget שמתעד **למה** הוא מפר את design tokens (orange/black/white, physical right) — לא ניסיון להסוות חריגה אלא להצדיק אותה בדוקסטרינג.

---

## Welcome Screen

### 📂 Components נגעו
- `welcome_screen.dart` — onboarding carousel (auto-play) + bottom CTA section. מוצג רק עד יצירת חשבון.
- `app_strings_he.dart` / `app_strings_en.dart` — `WelcomeStrings` (he base) + `WelcomeStringsEn` (override).

### ✅ Decisions Made (סבב 3, 22/6/2026 — סקירת צילומים)
- **🎯 Header חזר ל-tagline אחד (de-dup)**: ה-`subtitle` הקבוע מעל הקרוסלה היה "סורקים ברקוד והמלאי מתעדכן, רואים מה חסר, וקונים יחד בזמן אמת" — שלושת הפילרים verbatim, כך שכל עמוד בקרוסלה רק חזר על חלק ממנו (spoiler + שתי כותרות מתחרות). קוצר ל-umbrella promise: "המזווה יודע מה חסר — אתם רק קונים" (en: "Your pantry knows what's missing — you just shop"). עכשיו כל עמוד מגלה פילר בלי חזרה.
- **סדר עמודים אושר**: מזווה → רשימה → שיתוף (= הסדר בקוד: `onboarding_pantry`→`shopping`→`sharing`). הצילום שהראה "שיתוף ראשון" יוחס להחלקה ידנית, לא לבאג. אין שינוי.
- **תמונות onboarding — מקובל**: הטלפונים בצילומי הסטוק מציגים טקסט אנגלי ("Grocery List", "SPAGHETTI/PANTRY") ועמוד השיתוף בלי אפליקציה. המשתמש אישר שזה מקובל — אין החלפת נכסים.
- **🎯 אייקון CTA: `person_add` → חץ קדימה locale-aware**: ה-`person_add` (דמות+) שידר "הזמן מישהו" ולא "צור חשבון". הוחלף ל-`isRtl ? arrow_back_rounded : arrow_forward_rounded` (אותה קונבנציה כמו onboarding_tips_card / pending_actions_card — בעברית RTL "קדימה" = חץ שמאלה).
- **♿ A11y: הסרת תיוג כפול ב-trust chips**: כל `_BenefitChip` היה עטוף ב-`Semantics(label: text)` סביב Row שכבר מכיל את אותו `Text`, והאייקון הדקורטיבי לא הוחרג. הוסר ה-wrapper המיותר + `ExcludeSemantics` על ה-FaIcon (הטקסט עצמו נושא את ה-label).
- **🟢 Social login — נשאר רק במסך ההרשמה (החלטה)**: שקלנו להוסיף Google/Apple למסך הפתיחה (נגיעה אחת). המשתמש בחר להשאיר את מסך הפתיחה מינימלי — Google/Apple צעד אחד פנימה במסך ההרשמה. אין שינוי.
- **♿ Worm-dot RTL**: הצילום הראה נקודה ימנית פעילה לצד העמוד האחרון — יוחס להחלקה ידנית, לא לבאג. אומת מול הקוד: `pageOffset: isRtl ? (count-1-pageOffset) : pageOffset` תקין. אין שינוי.

### ✅ Decisions Made (סבב 1-2, 2/6/2026)
- **Carousel = 3 pillars מובחנים**: עמוד 1 היה "שיתוף" (כפילות עם עמוד 3). שונה ל-"רשימות חכמות" (lists/catalog). עכשיו lists / pantry / sharing — בלי חזרה.
- **Copy rewrite — value-prop accurate (2/6/2026)**: המשתמש הבהיר שהייחודיות היא **לולאה**: מזווה (מעקב מלאי) → רשימה נבנית אוטומטית מהחוסרים → חוויה בסופר (מוצר מדויק בלי פתק מבלבל + קנייה משותפת בזמן אמת). הקופי הישן היה generic ("חכם/מסונכרנים"). שוכתב לסיפור בית→רשימה→סופר עם קול חד/אישי: עמוד 1 "המזווה זוכר במקומכם", עמוד 2 "הרשימה כותבת את עצמה" (הלב — auto מהמלאי), עמוד 3 "סוף לניחושים בסופר" (בהירות + split בזמן אמת). תת-כותרת: "המזווה יודע מה חסר — אתם רק קונים". סדר התמונות: pantry→shopping→sharing. he+en.
- **🐛 כיוון קרוסלה ב-RTL (BUG fix)**: ל-`PageView` היה `reverse: isRtl` — אבל PageView **כבר** מכבד Directionality (RTL → עמוד 1 מימין). ה-reverse ביטל את זה והפך בחזרה ל-LTR, כך שהתוכן זז הפוך מנקודות ה-worm (שמטופלות ידנית). הוסר ה-`reverse` → התוכן, הנקודות וה-parallax עקביים. הנקודות/parallax נשארים עם isRtl ידני (canvas/Transform לא מכבדים Directionality לבד).
- **Bottom chips = trust signals, לא feature repeats**: היו 3 שבבים שחזרו על הקרוסלה (שיתוף/רשימות/מזווה). הוחלפו ל-trust: 🎁 חינמי לגמרי · 🛡️ פרטי ומאובטח · ⚡ מוכן תוך דקה. אייקונים: gift / shieldHalved / bolt.
- **Auto-play עוצר במגע + בעמוד האחרון**: היה loop אינסופי עם `% wrap` שגרם ל-backward sweep מבלבל (עמוד 3→1). עכשיו מתקדם קדימה, נעצר בעמוד האחרון, ו-`_isAutoAdvancing` flag מבדיל swipe ידני מ-auto-advance (עוצר לתמיד במגע ראשון).
- **הוסר BackdropFilter blur** מהחלון התחתון — ב-~92% opacity הטשטוש כמעט לא נראה אבל עלה GPU pass לכל frame. עכשיו פאנל נייר אטום.
- **Entrance slide 0.1/0.15 → 0.2** — כניסה נוכחת יותר (לוגו, שבבים, חלון תחתון).
- **🧹 מחיקת ~21 מחרוזות יתומות** משלד עיצוב ישן ("טלפון דמו"): emojis, group features, demo items/pantry, status, benefit subtitles, unused buttons. כללו דמו **לא-מכליל** (אבא/אמא/דני + 👨‍👩‍👧‍👦) — נמחק לפי Audience & Voice. he base == en override (16 getters כל אחד).
- **Perf/robustness**: `cacheWidth: 256` ללוגו (מקור 1533px), `errorBuilder` fallback ללוגו + 3 איורים, `RepaintBoundary` סביב worm-dot CustomPaint.
- **RTL מטופל נכון**: parallax direction + worm-dot `count-1-pageOffset` לפי locale.

### ✅ Decisions Made (סבב קודם — היסטורי)
- **Inclusive language בנקודת הכניסה** — "לכל המשפחה" → "לכל הבית", "המשפחה מסונכרנת" → "כולם מסונכרנים" (he+en). הסתום הראשון של המשתמש — חייב להיות נכון לפני ה-L1 sweep הכללי.
- **PageView reverse לפי locale** — `reverse: isRtl` במקום קבוע `true`. תואם ל-WormDotIndicator שכבר היה locale-aware.
- **shouldRepaint מלא ב-`_WormPainter`** — כולל `inactiveColor` ו-`count`, לא רק `pageOffset`/`activeColor`. תואם להחלפת theme.
- **Token alignment** — `alpha: 0.5` ב-bodyMedium → `kOpacityMedium`. **Theme extension reuse** — `brand?.success` מתוך scope, בלי re-fetch.

> 📝 שני ה-Deferred של הסבב הקודם **נפתרו** בסבב 2/6: ה-style-on-style ב-`_SimpleFeatureCard` תועד בהערה (titleLarge נושא רק font; size/weight נדרסים במכוון), וה-magic alphas ב-`_BottomSection` קיבלו הערות או הוסרו (ה-`0.92`/blur ירדו עם הסרת ה-BackdropFilter).

### ⏸️ Deferred
- **🛡️ "פרטי ומאובטח" מול תוכנית הפרסומות**: המשתמש מתכנן להוסיף פרסומות. אם רשת הפרסום עוקבת אחרי משתמשים — הטענה "פרטי ומאובטח" נחלשת. **Trigger:** לפני שמשיקים פרסומות — לוודא שזו אמת (רשת פרטית / בלי מכירת דאטה) או לרכך copy.
- **🎁 "חינמי לגמרי" מול monetization עתידי**: נכון כל עוד המודל = פרסומות בלבד. אם ייכנס מנוי פרימיום → לשנות ל-"חינם להתחלה". **Trigger:** הוספת paid tier.
- **⚡ Timer רץ ברקע**: אין `AppLifecycleState` שמשהה auto-play כשהאפליקציה ברקע. זניח למסך פתיחה. **Trigger:** אם נמדד battery/jank.
- **🖼️ Parallax edge bleed**: הרקע זז עד 60px, עלול לחשוף שוליים בלי קווי-מחברת. כמעט בלתי-נראה (רקע subtle). **Trigger:** אם נראה במסכים צרים.

---

## Home Dashboard Screen

### 📂 Components נגעו
- `home_dashboard_screen.dart` (788 שורות) — orchestrator של כל ה-Home: 6+ סקציות

### ✅ Decisions Made
- **Inclusive copy**: `inviteFamilyTitle` (he+en) — "הזמן את המשפחה" → "הזמן את הבית". האנגלית גם: "Invite your family" → "Invite your home". (subtitle + action כבר היו ניטרליים.) שלישי בסבב ה-inclusive sweep אחרי welcome + register.
- **Stagger animation flag**: `_hasAnimated` נהפך ל-true ב-postFrameCallback → stagger רץ רק בטעינה ראשונה. הערה מפורטת מסבירה למה ה-tutorial dialog דחוי 700ms (כדי שהוא לא יבוא תוך כדי הסטאגר).
- **FAB hide-when-empty**: כשאין רשימות פעילות, ה-empty state כבר מציג CTA "Create first list", אז ה-FAB מוסתר כדי לא לכפול.
- **Single-pass count of checked items** עם הערה על perf.
- **Pull-to-refresh** עם error handling חלק: `Future.wait([loadLists, loadReceipts])` נכשל → `hadError = true`. `refreshSuggestions` נפרד, נכשל בשקט (non-critical). `removeCurrentSnackBar` לפני show.
- **`messenger` נלכד לפני await** — pattern עקבי.
- **`mounted` checks** אחרי כל await.
- **RepaintBoundary** סביב ActionCenter, Suggestions, ActiveLists, ActivityFeed.
- **A11y חזק**: `Semantics(header: true)` על activeListsTitle, `Semantics(button: true, label: composed)` על list cards (label = name + progress + done state).
- **RTL**: `isRtl` flips accent bar border radius + chevron direction.
- **Hero animation** על list icons → details screen.
- **Empty list shows CTA** (not dead-end) — `emptyListCta` "הוסף פריט" עם accent color.

### ⏸️ Deferred
- **Function name `_buildInviteFamilyBanner` + keys `inviteFamily*`** — internal naming עדיין משתמש ב-"family". refactor של naming הוא רחב (קובץ + l10n + callers). **Trigger:** sweep של naming inclusive. **היקף:** בינוני.
- **Single-use magic alphas** (0.05 gradient, 0.8 errorMessage, 0.25 card border) ו-`size: 13` (progress icon off kIconSize* scale) — premium tuning, לא דחוף.
- **Style-on-style typography** — דפוס פרויקט-wide (typography sweep ב-Backlog Theme).

### סבב 2 (17/5/2026) — Decisions
סבב 1 לא תפס בעיית a11y קריטית ב-`_buildInviteFamilyBanner` ושני פטרני magic-number מוסווים. הסבב הזה מתקן אותם.

- **♿ White-on-cyan button (CRITICAL fix)**: `_buildInviteFamilyBanner` בנה `FilledButton` עם `backgroundColor: stickyCyan` (`#80DEEA` — פסטל בהיר) ו-`foregroundColor: cs.onPrimary` (לבן ב-default theme). לבן על ציאן בהיר = WCAG AA fail. תוקן ל-`cs.onSurface` (שחור) — עומד בקונטרסט. אותו תיקון שבוצע ב-SnackBars של `suggestions_today_card`. הערה מסבירה למה ה-onPrimary לא מתאים פה.
- **📐 `kSpacingXTiny / 2` → `_kErrorTitleGap = 2.0`**: error banner gap בין title ל-message. אנטי-פטרן של "magic via division of a token" שתועד ב-CLAUDE.md. שינוי לקבוע מקומי עם הערה ("title/subtitle pair, not paragraph break").
- **📐 `kSpacingSmallPlus + 2` → `_kListCardVerticalPadding = 14.0`**: אנטי-פטרן של "magic via addition". 14px = tuned (12 too tight, 16 too loose); קבוע מקומי עם הערה.
- **📐 `Duration(milliseconds: 300)` → `_kRefreshAnimationGrace`**: refresh delay לא מתועד. עכשיו constant עם הערה למה (UX perception of "deliberate refresh").

**🎯 Pattern**: דוגמה לעקביות פטרן cross-file. ה-SnackBar contrast fix שבוצע ב-`suggestions_today_card` חזר על עצמו פה ב-FilledButton. **כלל אצבע:** בכל מקום עם sticky color כרקע + foreground צבע "default theme" — לבדוק קונטרסט ידנית.

### סבב 4 (19/5/2026) — Architectural pruning + WhatsForDinnerCard
> ⚠️ **כרטיס "מה לבשל הערב?" מוסתר** אחרי המיקוד-לסופר ([PRODUCT_DIRECTION](PRODUCT_DIRECTION.md) §6 — הקוד נשאר). ההחלטה הארכיטקטונית והמחקר נשמרים כהיסטוריה; **אודיט הקטלוג בהמשך הסבב חי** (supermarket.json הוא הקטלוג הפעיל).

המשתמש שאל בכנות "האם בכלל צריך את הפיד הזה?". סקירה מקיפה גילתה שה-`household_activity_feed.dart` (במסך הבית) משכפל מידע שכבר זמין ב-3 מקומות: היסטוריה, פעמון התראות, ו-Action Center. נדרשה החלטה ארכיטקטונית.

**מחקר API מתכונים (פרי-decision):** בוצעו 7 חיפושי web יסודיים על קיום API חופשי למתכונים בעברית. תוצאות:
- אין API חופשי בעברית — Spoonacular/Edamam/TheMealDB כולם English-only עם מתכונים מערביים
- אין dataset ב-Kaggle/HF — NNLP-IL/Hebrew-Resources לא מכיל recipes corpus
- Mako/Walla/Ynet/Hashulchan — אין API ציבורי
- OpenCulinary/RecipeRadar — FOSS אבל אנגלית
- Spoonacular בעצמם מתעדים: *"the API only recognizes English names for ingredients, which requires an extra translation step"*

**ההחלטה:** במקום לבנות feature recipe-matching עם content engineering (~50+ שעות תוכן ראשוני + תחזוקה), להחליף ב-**External Google search** — חינמי, מקסימום ערך, אפס תחזוקה.

**מימוש (מתומצת — הכרטיס מוסתר):** `HouseholdActivityFeed` הוסר ממסך הבית (הקובץ נשמר, משמש ב-`shopping_history_screen`). נוסף `WhatsForDinnerCard` (sticky-orange, preview 5 פריטי מזווה, כפתור "חפש מתכונים" → Google חיצוני). תלות חדשה **`url_launcher: ^6.3.1`** (שימוש ראשון בפרויקט — תקדים ל-external links). Strings תחת `AppStrings.whatsForDinner`.

**🎯 Pattern נשמר:** "smart link" widget — ערך לוקאלי (preview מהמזווה) + action חיצוני, אפס תחזוקת תוכן. רלוונטי לכל external-link עתידי גם אם הכרטיס הזה לא יחזור.

#### Hotfix מיידי (אותו יום, 19/5)
המשתמש צילם screenshot עם demo data של naama — ה-preview הציג: "יש לך: אולטאסול ספריי שקוף · בגד ים חליפה בנות · בדין מרכך כיבסה מרוכז · בצל מטוגן במשקל · דגני בוקר אורינגל לי". 3 מתוך 5 לא היו אוכל. ה-pantry במזווה (סופרסל catalog) כולל ניקיון/ביגוד/כביסה.

- **🆕 `CategoriesData.foodCategoryKeys` + `isFoodCategory()`**: Set של 28 קטגוריות אכילות ב-`filters_data.dart`. **לא כולל בכוונה** את `other` (uncategorized = high non-food risk), `vitamins`/`otc_medicine`/`first_aid` (consumed, לא cooked), `pet_food`, `baby_products` (mixed), `hygiene`/`cosmetics`/`cleaning`.
- **🔧 Filter ב-WhatsForDinnerCard**: `.where((i) => CategoriesData.isFoodCategory(i.category))` לפני ה-`.take(5)`. תופס פריטים שאינם אוכל לפני שמגיעים ל-Google.
- **תחת `_kMinPantryItemsForSearch = 3` אחרי הסינון**: אם מזווה מלא בניקיון בלבד → הכרטיס מסתתר.

**🎯 Lesson**: pantry במזווה ≠ "what's in the kitchen". משתמש שמשתמש ב-MemoZap כ-household inventory מנהל גם kits-של-ניקיון. כל feature שמתבסס על pantry items כ-"food" חייב לסנן לפי category.

#### Catalog deep audit (19/5/2026) — 4 parallel agents
המשתמש ביקש "תריץ עוד הרבה סוכנים על הקטלוג". הופעלו 4 סוכנים במקביל ל-`supermarket.json` (111,654 פריטים, 1MB).

**Agent 1 — Miscategorization patterns**:
- 3 קטגוריות הכי "רועשות": **"מוצרי חלב"** (7-10% noise — keyword "לבן" מושך LED bulbs, swimsuits, USB cables), **"תבלינים ואפייה"** (5-8% — "אבקה" מושך powders של ויטמינים/שיער), **"ממתקים וחטיפים"** (3-5%, נפח גבוה)
- 15 מונחי לא-אוכל חדשים זוהו: בלון, אוזניות, בובה, טבק, אסלה, לרצפה, נייר אפיה, ועוד
- Highlights: iPhone Pro Max ב-₪6,539 בקטגוריה כלשהי, טבק לנרגילה ב-"פירות וירקות", מברשת אסלה ב-"מוצרי חלב"

**Agent 2 — Duplicate detection**:
- 100% unique by raw barcode ✓
- 195 collisions אחרי normalization של leading zeros (data integrity bug)
- 1,143 קבוצות "same name+brand+cat, different barcode" — כנראה pack-size variants legit
- Quality: 98% unique by name, 100% by barcode
- **Recommendation**: light dedup (~195 rows), not rebuild

**Agent 3 — Data quality (62% overall)**:
- 🔴 87% null `brand` — שדה כמעט בלתי שמיש
- 🔴 70 distinct unit values (יח'/יחידה/יחידות/יח/י"ח — כולם "unit") — צריך normalization map
- 🔴 iPhones/TVs/Vacuums מסתננים ב-₪1000-6500
- 🟡 25 שמות שבורים (<3 chars: "5", "FA", "אץ", "OB")
- ✅ Encoding clean, no mojibake
- ✅ Names not stuffed (max 75 chars)

**Agent 4 — "כללי" bucket (22% of catalog)**:
- 24,494 פריטים uncategorized — 22% מהקטלוג!
- **60-70% recoverable** דרך keyword classification
- 30-40% junk אמיתי (coupons, English brand stubs, store SKUs)
- **Recommendation**: build-time classifier להעביר recoverable items לקטגוריות נכונות

**Action taken**:
- ✅ Blocklist הורחב מ-37 ל-55 מילים, כולל additions של Agent 1 (בלון, אוזניות, בובה, טבק, אסלה, לרצפה, אייפון, מסך טלוויזיה, וכו')
- ✅ Coverage עלה מ-703 hits ל-963 hits (1.10% → 1.50% של food categories)
- ✅ Audit scripts זמניים נוקו

**⏸️ Deferred (catalog-level fixes, לא קריטי ל-WhatsForDinnerCard)**:
- 🔄 Unit normalization (70 variants → ~7 canonical) — biggest impact, mechanical
- 🔄 "כללי" build-time classifier — recover 14-16K items
- 🔄 Filter non-grocery price outliers (iPhones, TVs)
- 🔄 Strip address-strings from brand field
- 🔄 Barcode leading-zero dedup (~195 rows)

**🎯 Lesson (cross-catalog)**: open-israeli-supermarkets feed הוא תוצר scraping אוטומטי עם איכות נמוכה. **כל פיצ'ר שמסתמך על הקטלוג כ-ground truth** חייב שכבת sanity check. ה-`CategoriesData.isFoodCategory` + `looksLikeNonFood` הוא pattern reference לעתיד.

---

### סבב 3 (17/5/2026) — Visual design polish (post-screenshot review)
המשתמש שיתף screenshot של מצב fresh user וביקש "מה אפשר לעצב יותר טוב". בעיניים חדשות נמצאו 4 ממצאי polish שלא נתפסו בסבב 2.

- **🎨 "הזמן" button blending into banner** (CRITICAL CTA fix): הציאן+ציאן יצר button שלא בולט. שונה ל-`brand.accent` (Amber #FFC107) — צבע ה-CTA הראשי באפליקציה. גם FilledButton → ElevatedButton כדי להוסיף elevation שמרים את הכפתור מהבאנר. `cs.onSurface` כצבע טקסט נשאר (amber + dark ink = ה-onAccent convention של ה-theme).
- **📝 Sticky-note language for invite banner**: היה Container פלאט עם gradient. נוסף `Transform.rotate(-0.005)` (כ-0.3°) + `boxShadow` (offset 1,2 blur 4). הבאנר עכשיו מרגיש "מודבק לעמוד" במקום "embedded into the page" — תואם את שפת המחברת של שאר המסך.
- **🎨 Type-tinted list card**: ה-list card היה `cs.surface` נטראלי, ניגוד צורם לפתקיות הצבעוניות מסביב. עכשיו `Color.alphaBlend(accentColor * 0.05, cs.surface)` — רמז עדין לסוג הרשימה (סופר=ירוק, מאפייה=חום) בלי להפוך לצעקני.
- **📊 Progress ring visibility at 0%**: `accentColor.withValues(alpha: kOpacitySoft)` (0.15) → `kOpacityLight` (0.3) — ב-0/N הטבעת הייתה כמעט בלתי-נראית, מה שגרם לרשימה טריה להראות "חסרת ring" במקום "מוכנה להתחיל".

**Cross-file**:
- `onboarding_tips_card.dart`: → arrow button → background מ-`accentBg` (cs.scrim subtle) ל-`tip.color` מלא. ה-× נשאר אפור עדין. עכשיו ה-→ (פעולה ראשית) בולט חזותית מה-× (פעולה משנית) — היררכיה ברורה. הצבע של ה-→ "מהדהד" את ה-card color בסטורציה גבוהה יותר, יוצר קוהרנטיות.

**🎯 Pattern lesson**: כאשר 2 כפתורי פעולה צמודים (primary + secondary), צבע זהה = "אותו משקל ויזואלי" = משתמש לא יודע מה ראשי. שונות-צבע פותרת מיד.

### סבב 6 (22/6/2026) — התאמת מסך הבית למודל "רשימה אחת חיה"

- **🔄 כותרת יחיד לסקציית הרשימות**: במודל "רשימה אחת חיה" הסקציה הציגה "🛍️ רשימות פעילות **1**" — כותרת ברבים + מונה "1" שנשמע מוזר בעברית ומיותר. עכשיו: רשימה אחת → "הרשימה הפעילה" בלי מונה; ≥2 → "רשימות פעילות N" כקודם. String חדש `singleActiveListTitle` (he+en).
- **🎉 Empty state חגיגי (החלטת המשתמש 22/6)**: רשימה חיה ריקה = הכל נקנה. במקום CTA "מת" ("הקש להוספת פריטים") → "הכל נקנה! 🎉" (✓ ירוק) + שורת משנה "נמלא כאן מה שייגמר במזווה". Strings חדשים `emptyListAllBought` + `emptyListAutoFillHint`. (`emptyListCta` הפך ל-string יתום — נשמר, לא מזיק.)
- **✅ פריטים שנקנו לא מוצגים יותר (החלטת המשתמש 22/6)**: שאלנו אם להוסיף copy "מה קרה לפריטים" אחרי קנייה. המשתמש אישר שהתנהגות `finishShoppingKeepListActive` (הסרת הנקנו מהרשימה, בלי איזכור) היא **הרצויה** — אין צורך בהסבר. סגור, אין שינוי.
- **🧹 ניקוי header מיושן**: תגובת הקובץ ציינה "activity feed" שכבר לא במסך (ה-`HouseholdActivityFeed` עבר ל-`shopping_history_screen`). עודכנה לרשימת הסקציות בפועל.

### ⏸️ Deferred (סבב 6)
- **🔒 נעילה מלאה למודל רשימה-אחת (פתוח — דורש החלטה)**: המשתמש ביקש "תמיד Hero יחיד" בהנחה שאי-אפשר ליצור יותר מרשימה אחת. **אבל הקוד עדיין מאפשר עד 30** (`kMaxActiveListsPerUser = 30`), ויש נתיבי יצירה חיים (`createNewListButton`, `createListsTitle`). לכן יושם "יחיד כשיש 1, מונה כש-2+" (בטוח גם בריבוי רשימות). **כדי ש"תמיד יחיד" יהיה נכון** צריך: (1) `kMaxActiveListsPerUser = 1`, (2) הסתרת כל נתיבי "צור רשימה חדשה", (3) הסרת חיפוש/מיון/"ראה הכל" במסך כל-הרשימות. **היקף: בינוני-גדול, חוצה מסכים.** Trigger: אישור המשתמש לנעילה.

---

## Notifications Center Screen

### 📂 Components נגעו
- `notifications_center_screen.dart` (542 שורות) — מסך מרכז ההתראות, גישה דרך 🔔 ב-AppBar

### 🎯 Decisions (סקירה ראשונה, 17/5/2026)
- **🔄 Split load vs refresh**: `_loadNotifications` שימש גם את ה-RefreshIndicator → ב-pull-to-refresh הרשימה הוחלפה ב-skeleton flash. עכשיו: `_loadNotifications` (initial — flips `_isLoading`) + `_refreshNotifications` (delegate ל-`_fetchNotifications` בלי לגעת ב-skeleton). הרשימה נשארת על המסך בזמן הרענון, רק spinner של RefreshIndicator עצמו נע.
- **✨ Shimmer one-shot במקום infinite repeat**: `.animate(onPlay: c.repeat()).shimmer(...)` יצר N controllers infinite ל-N התראות לא-נקראות. עם 10 unread = 10 אנימציות במקביל לנצח. תוקן ל-`.animate().shimmer(...)` חד-פעמי — pass של 1.2s אחרי delay 3s, ואז שקט. הנקודה הכחולה ממשיכה לאותת "unread" סטטית.
- **🖼️ Empty state image errorBuilder**: `Image.asset('empty_notifications.webp')` חסר fallback. נוסף fallback ל-`Icons.notifications_none_outlined`. תואם פטרן של `home_dashboard_screen`.
- **⏬ Pull-to-refresh ב-empty state**: היה רק כשיש items. משתמש עם 0 התראות לא יכל לרענן. עכשיו עוטף את ה-empty state ב-RefreshIndicator + ListView + AlwaysScrollableScrollPhysics. ה-Center נשמר בתוך `SizedBox(height: 70% of screen)`.
- **⏱️ Future.delayed → Map<String, Timer> + dispose**: ה-6-second commit window של ה-undo היה fire-and-forget. עכשיו Timer-per-id ב-state Map, נקנסל ב-dispose ובunsubscribe. גם undo מקנסל מיד.
- **📐 `kSpacingXLarge + kSpacingLarge` → `_kListBottomClearance = 56.0`**: anti-pattern של "magic via addition".
- **📐 Magic numbers → local constants**: 44/10/120/2000ms/1.05/3000ms/1200ms/40 → `_kLeadingIconSize`, `_kUnreadDotSize`, `_kEmptyImageSize`, `_kEmptyPulseDuration/Scale`, `_kShimmerDelay/Duration`, `_kStaggerStepMs`, `_kUndoSnackBarDuration`, `_kUndoCommitDelay`. ה-alphas (0.2/0.3/0.5) הוחלפו ב-`kOpacityLow/Light/Medium`. ה-0.08 הוחלף ב-`kOpacitySubtle` (0.12) — הקרוב ביותר עם שם semantic.

### ⏸️ Deferred
- **`_getTypeColor` cross-file dedup** — דומה ל-`_iconForType` של `household_activity_feed`. **Trigger:** sweep גלובלי של "type → visual" mapping. **היקף:** קטן-בינוני.

**🎯 Pattern**: דוגמה ל-Gmail-style undo עם Timer cancellable + cache providers לפני async gap. ה-Timer-Map pattern מאפשר multiple-undo במקביל (משתמש מוחק 3 → 3 snackbars → יכול לבטל בכל סדר).

### ⏳ Files of this screen — pending review
- ~~`pending_invites_banner.dart`~~ ✅ **נסקר** ב-29/4/2026 + סבב 2 ב-17/5/2026 (r2: ✓ button כפול הוסר + Tooltip→Semantics + Gmail-undo pattern + service dedup + animation extract + chevron על +N badge)
- ~~`action_center_card.dart`~~ ✅ **נסקר** ב-29/4/2026 + סבב 3 ב-17/5/2026 (r3: Hebrew "אחד"/"אחת" bug + urgency-coded colors + sticky-note chip style + dead param + method dedup + single-pass count)
- ~~`last_chance_banner.dart`~~ ✅ **נסקר** ב-29/4/2026 — **הועבר** ל-`shopping/active/widgets/` (היה ב-`home/dashboard/widgets/` בטעות) + `kMinTapTarget` cleanup
- ~~`active_shopper_banner.dart`~~ ✅ **נסקר** ב-29/4/2026 + סבב 2 ב-17/5/2026 (r2: header doc fix + fixBidiNumbers + AlignmentDirectional gradient + isWaitingAtCheckout substate + _PulsingIcon Stateful + rename backgroundColor→tintColor)
- ~~`onboarding_tips_card.dart`~~ ✅ **נסקר** ב-30/4/2026 + סבב 2 ב-17/5/2026 (r2: Gmail-undo dismiss + sync PrefsCache + arrow icon CTA + 🎉 celebration on threshold crossing)
- ~~`household_activity_feed.dart`~~ ✅ **נסקר** ב-30/4/2026 + סבב 3 ב-17/5/2026 (r3: DD/MM/YY date format + receipt subtitle dedup + remove double Semantics + magic-number constants + _kAvatarSize naming + Icons.history→timeline)
- ~~`suggestions_today_card.dart`~~ ✅ **נסקר** ב-30/4/2026 + סבב 2 ב-17/5/2026 (r2: RTL gradient + SnackBar contrast + processing semantic state + ValueKey for card identity + shadow constants + active dot full opacity)

### 🎯 `action_center_card.dart` — Decisions

**סבב 1 (29/4/2026):**
- **chevron RTL-aware**: `Icons.chevron_left` היה hardcoded — שובר ב-English locale (chevron מצביע אחורה במקום קדימה). תוקן עם `isRtl ? chevron_left : chevron_right`.
- **bottom sheet theme cleanup**: הוסרו `backgroundColor: cs.surface` ו-`shape` מ-`showModalBottomSheet` — היו override ל-theme שכבר מגדיר זאת (וב-`surfaceContainerHigh` יותר מתאים מ-`cs.surface`). אותו pattern שעשינו ב-`barcode_helpers.dart`, `active_shopping_screen.dart`.
- **Single-pass loop** על lists לbucketing pending vs overdue ✅
- **Smart fast-path**: tap על chip עם 1 פריט → ישר אליו; multi-item → bottom sheet. מונע modal מיותר.
- **`Semantics(button: true, label: '$label, $count')`** על `_StatusChip` ✅

**סבב 2 (29/4/2026):**
- **Hebrew plural bug תוקן**: `criticalStock` ו-`pendingRequests` החזירו תמיד plural form ("1 מוצרים נגמרו", "1 בקשות ממתינות"). היה אי-עקביות עם overdue (שכבר טיפל ב-singular). נוספו `criticalStockSingle` ו-`pendingRequest` (he+en) + ternary בקוד עבור 3 ה-chips באופן אחיד.
- **Row → Wrap לקצוץ-טקסט במכשירים צרים**: כש-3 chips נדלקים יחד במכשיר 360dp, Flexible+ellipsis היה מקצץ את ה-label ("5 ⚠️ ..."). Wrap (עם spacing+runSpacing) נופל לשורה שנייה במקום לקצוץ. הוסרו ה-`Expanded`s — chips עכשיו sizes-to-content (אופייני יותר ל-Wrap, לא 1/3 כל אחד). RTL מטופל אוטומטית דרך Directionality.
- **`context.watch<UserContext>` → `context.select<UserContext, bool>((u) => u.isLoggedIn)`**: רק `isLoggedIn` מעניין את הוויג'ט — שינוי ב-themeMode/displayName לא צריך לרנדר את ActionCenter. אותו pattern של `pending_invites_banner.dart`.

**סבב 3 (17/5/2026)** — נחשף ב-screenshot: סבב 2 פספס את הבאג של "1 מוצר אחד נגמר" + היררכיית צבעים הפוכה + הקובץ לא מדבר את שפת sticky-notes של המסך.
- **Hebrew "אחד"/"אחת" duplication bug** (חשוף בעין): chip מציג `count` + `label`, אבל singular strings כללו את "אחד"/"אחת" — יוצא "1 מוצר אחד נגמר", "1 בקשה אחת ממתינה". תיקון ב-strings: הסרת המילים מהסינגולר (`'מוצר אחד נגמר'` → `'מוצר נגמר'`, `'בקשה אחת ממתינה'` → `'בקשה ממתינה'`). אותו pattern באנגלית: `'1 item out of stock'` → `'item out of stock'`. עכשיו chip מציג "1 מוצר נגמר" / "1 pending request" נקי. הערה במקור מסבירה למה.
- **Urgency-coded colors (vs sticky aesthetics)**: היה critical=stickyPink, overdue=cs.error, pending=stickyOrange — היררכיה חזותית הפוכה ל-urgency האמיתי. ה-critical (אזל לגמרי, צריך לקנות עכשיו) היה הכי "שקט" ויזואלית. תוקן ל: critical=`cs.error` (אדום), overdue=`brand.stickyOrange` (כתום סטיקי), pending=`brand.stickyYellow` (צהוב רך). **הערה לעתיד:** ניסיון ראשון השתמש ב-`brand.warning` (Material Orange 700) לכתום אבל ב-`kOpacityLight` (0.3) שני הצבעים (cs.error + warning) נשטפים לוורוד דומה — `stickyOrange` נבדל יותר ב-alpha נמוך. דחיפות נראית עכשיו = דחיפות בפועל.
- **Sticky-note styling ל-`_StatusChip`**: היה generic Material chip — לא תאם את שפת ה-notebook+sticky-notes של המסך (suggestions cards למטה כן sticky). תיקון: `kOpacitySubtle` (0.12) → `kOpacityLight` (0.3, צבע נראה יותר), `kBorderRadius` (12) → `kBorderRadiusLarge` (16, יותר sticky), `elevation: 1` + `shadowColor` tinted (lift עדין).
- **`Icons.schedule` → `Icons.event_busy`**: שעון רגיל היה ambiguous ("scheduled"/"overdue"). `event_busy` (לוח שנה עם X) semantic clearer לרשימה באיחור.
- **`Wrap.alignment: center`**: כש-3 chips הופכים ל-2+1 (chip בודד בשורה השנייה), הוא היה תלוי לבד בצד start. עכשיו ממורכז — נראה מאוזן.
- **Dead param `items` ב-`_openCriticalStock`**: הפונקציה קיבלה `List<InventoryItem>` שלא בשימוש. הוסר + הוסר import `InventoryItem`. הספירה עברה ל-`.length` ישיר במקום `.toList()` (חוסך allocation).
- **Method dedup**: `_openOverdueLists` + `_openPendingRequests` היו כמעט זהים (haptic → fast-path 1 → sheet). אוחדו ל-`_openListsAction({lists, title, icon})`. חסכון של ~15 שורות.
- **Single-pass count**: `_countPendingRequests` עברה על `pendingLists` שוב. ספירה משולבת ב-loop הראשי, חוסכת pass.

### 🎯 `last_chance_banner.dart` — Decisions
- **File relocation**: היה ב-`home/dashboard/widgets/` למרות שמשמש רק ב-`active_shopping_screen`. הועבר ל-`shopping/active/widgets/`. מיקום פיזי תואם עכשיו לשימוש האמיתי. caller import מ-`'../../home/dashboard/widgets/last_chance_banner.dart'` ל-`'widgets/last_chance_banner.dart'` — קצר ומובן יותר.
- **`_kAddButtonMinHeight` → `kMinTapTarget`**: הקבוע המקומי שכפל את `kMinTapTarget = 44.0` הגלובלי. השם הגלובלי גם סמנטית נכון יותר (Material spec: minimum tap target).
- **`_kSnackBarDuration = 2s` נשאר מקומי** — ערך **שונה** מ-`kSnackBarDuration` הגלובלי (3s). קצר במכוון: toasts בתוך active shopping flow לא צריכים להישאר. הוספה הערה מסבירה.
- **שאר הקבועים המקומיים** (`_kCriticalBgAlpha`, `_kRegularBgAlpha`, etc.) — חלקם exact matches ל-`kOpacity*` אבל נשארים מקומיים. ה-comment "Card surface — alphas tuned for 'soft inline alert'" מתעד שהם tuned set. אותו pattern של `pending_invites_banner.dart`.
- **A11y composition**: `Semantics(explicitChildNodes: true, label: composed)` עם `ExcludeSemantics` על Icon + Column. `explicitChildNodes` שונה מ-`pending_invites_banner` (שמזרים הכל לlabel) — פה ה-buttons (Add/Next/Skip) נשארים semantic nodes נפרדים כי הם עצמאיים.
- **3 actions עם UI hierarchy ברורה**: FilledButton.tonal Add > IconButton Next > IconButton dimmed Skip.
- **Skip = `notifications_off_outlined`** (לא X) — semantic ברורה: "we'll stop nagging".
- **Loading spinner מחליף את כל הכפתורים בזמן עיבוד** — מונע double-tap.
- **`fixBidiNumbers`** על שם המוצר — RTL/LTR mixed text handling.
- **Try/catch מעולה** בכל 3 ה-action methods: `messenger` cached, `mounted` check, `removeCurrentSnackBar` proactive.

### ⏸️ Deferred — Style-on-style typography ב-`_StatusChip`
- **Inline TextStyle** ב-שורות 281-296 (`fontSize: kFontSizeMedium`, `kFontSizeTiny`) במקום `theme.textTheme.labelLarge/labelSmall`. נכלל ב-typography sweep הגלובלי (ראה `app_theme.dart` Deferred) — תיקון נקודתי פה ייצור אי-עקביות.
- **Trigger:** typography sweep גלובלי. **היקף:** קטן בקובץ, גדול חוצה-קבצים.

### ⏸️ Deferred — `ExcludeSemantics` על drag handle
- ה-`Container` של drag handle (שורות 197-204) הוא pure decoration אבל אין `ExcludeSemantics`. אותו pattern חוזר ב-`app_layout.dart`, `barcode_helpers.dart`, ועוד bottom sheets. תיקון נקודתי = drift.
- **Trigger:** sweep ייעודי של drag handles באפליקציה. **היקף:** קטן (~5-7 קבצים).

### ⏸️ Deferred — `MyPantryScreen.pendingStockFilter` static field
- **Static mutable field** משמש כ-intent passing בין מסכים: ActionCenter קובע → switching לטאב מזווה → המזווה צורך ומאפס.
- **Smell**: global state, hard to test, unclear ownership, race conditions אפשריות.
- **אלטרנטיבות**: Provider/state injection, route arguments, event bus.
- **Trigger**: סקירה של `my_pantry_screen.dart` או refactor ארכיטקטוני של intent passing.
- **היקף**: בינוני-גדול (refactor cross-screen).

### 🎯 `active_shopper_banner.dart` — Decisions
- **`context.watch<UserContext>().userId` → `context.select<UserContext, String?>((u) => u.userId)`**: רק `userId` מעניין את הוויג'ט. אותו pattern של `action_center_card.dart` ו-`pending_invites_banner.dart`.
- **`uncheckedCount == 0` UX state**: כש-`isBeingShopped == true` אבל כל הפריטים סומנו, הבאנר היה אומר "0 פריטים · המשך" — מצב לא ברור. תיקון: copy מתחלף ל-"הכל מסומן · סיים" + icon `check_circle`. נביגציה נשארת ל-`/active-shopping` (שם נמצא ה-`finishShopping()` flow האמיתי שיוצר receipt + מעדכן inventory). 2 strings חדשים: `myActiveCompactDone`, `finishButton`.
- **Snackbar dedup ב-`_onJoin`**: ה-defense-in-depth check (viewer לוחץ Join למרות שה-CTA מוסתר) הציג snackbar בלי `removeCurrentSnackBar()`. תוקן ל-pattern של `messenger..removeCurrentSnackBar()..showSnackBar()`.
- **Copywriting fix — כפילות "קונה"**: title `othersActiveTitle` כבר אומר "X **קונה** עכשיו". subtitle `othersActiveSingle` אמר "**קונה** מ-Y" (כפילות באותו banner). תוקן ל-"מ-Y" בלבד. הערה ב-strings מסבירה: "the verb already lives in the title". 2 strings (he+en).
- **IconButton view + InkWell tap-anywhere — נשאר**: ה-IconButton הוא הסיגנל היחיד שאפשר **גם לצפות** ולא רק להצטרף. בלעדיו, viewers (שלא רואים Join) יחשבו "אין מה לעשות פה". affordance שווה את הכפילות.

**⏸️ Deferred:**
- **Inline TextStyle ב-`continueButton` ו-`_ActionButton.textStyle`** — נכלל ב-typography sweep הגלובלי.

**סבב 2 (17/5/2026)** — סבב 1 התמקד ב-context.select + copywriting. סבב 2 חשף 7 ממצאים שלא נתפסו אז.

- **🐛 Header comment שגוי**: שורה 1 אמרה "green bar showing current shopping session" — בפועל ה-Mine banner צבעו amber (`brand.accent` = `#FFC107`) וה-Others banner ירוק. תוקן ל-"amber pill for my own session, green card for someone else's (with done-waiting-at-checkout substate)".
- **🐛 `isWaitingAtCheckout` substate**: כשרונית מסמנת את כל הפריטים אבל לא לוחצת "סיים קנייה" — לפני התיקון אצלך הבאנר אמר "רונית קונה עכשיו" כאילו היא עדיין באמצע. עכשיו: title מתחלף ל-"רונית ממתינה בקופה", אייקון `shopping_cart` → `receipt_long`. 3 strings חדשים: `othersWaitingTitle`, `othersWaitingTitleMultiple`, `someoneWaiting`. ה-isDone state אצל "Mine" כבר היה מטופל מסבב 1 — סבב 2 השלים את הפער ב-Others.
- **📱 `fixBidiNumbers` חסר**: השכנים (`household_activity_feed`, `last_chance_banner`) משתמשים. פה לא. רשימה בשם "Walmart 2025" תרנדר את "2025" הפוך ב-RTL. הוסף לכל ה-Text של mainText/title/subtitle.
- **🌍 `Alignment.topLeft/bottomRight` → `AlignmentDirectional.topStart/bottomEnd`**: ה-gradient זרם תמיד שמאל-לימין פיזית, לא לפי כיוון הקריאה. ב-RTL — היה רץ בכיוון שגוי ביחס לטקסט. תוקן ב-2 ה-gradients.
- **⚡ `_PulsingIcon` → StatefulWidget**: היה `.animate(onPlay: c.repeat)` שיוצר controller חדש בכל rebuild של ההורה (Provider notify / AnimatedSwitcher swap). עכשיו `SingleTickerProviderStateMixin` + `AnimationController` + `ScaleTransition` — controller יחיד, dispose בטוח. אותו pattern fix כמו `_MailShimmerIcon` ב-`pending_invites_banner`.
- **🎯 `backgroundColor` → `tintColor`**: הפרמטר היה bg + foreground icon color יחד — השם "background" היה מטעה. שונה ל-`tintColor` שמשקף את המהות (גוון יחיד שמשמש בשני המקומות).
- **🎯 `icon` parameter ל-`_PulsingIcon`**: היה hardcoded `Icons.shopping_cart`. עכשיו ניתן להעביר `icon` (default = shopping_cart) כדי לתמוך ב-isWaitingAtCheckout phase. ערך ברירת מחדל מסוגנן כך שה-call sites הקיימים שאינם מעבירים icon משאירים את ה-cart.

**🎯 Pattern**: דוגמה ל-pulsing icon עם vanilla AnimationController (לא flutter_animate). יציב יותר ל-rebuild patterns של provider-heavy widgets.

### 🎯 `onboarding_tips_card.dart` — Decisions

**סבב 1 (30/4/2026):**
- **Tooltip wording — clear permanence**: `dismissTooltip` "הסתר טיפ" → "אל תציע יותר" (he), "Hide tip" → "Don't show again" (en). הdismiss הוא לתמיד (`prefs.setBool(...true)`), המילה הקודמת השתמעה לזמני. Source-vs-Symptom: המחרוזת לא תיארה את המציאות.
- **RTL-aware slide direction**: `slideX(begin: 0.1)` היה hardcoded direction. עכשיו `0.1 * (isRtl ? -1 : 1)` תואם פטרן `welcome_screen` ("Parallax direction לפי locale").
- **Local opacity constants documented**: `_kSubtleTextAlpha = 0.6` ו-`_kIconTintAlpha = 0.7` נשארים לוקאליים (לא ב-`kOpacity*`) עם הערה מפורשת — "tuned as a unit to read as ink on yellow paper". פטרן עקבי עם `pending_invites_banner.dart` ו-`last_chance_banner.dart`.
- **Sticky-note design language ✓**: rotation `±0.01`, gradient (folded paper), shadow with offset (pinned). On-brand premium markers.
- **Strong A11y composition**: `Semantics(explicitChildNodes: true, button: true, label: '$title, $subtitle, $progress')` עם `ExcludeSemantics` על icon container/text Column/CTA pill. IconButton dismiss נשאר semantic node נפרד.
- **Graceful prefs fallback**: load fails → `dismissed = false` (user יראה את הtip), save fails → debugPrint רק. UX לא נשבר במצבי קצה.

**⏸️ Deferred:**
- **Inline TextStyle ב-`_StickyNoteTip`** (3 רצפים: title/subtitle/progress) — `TextStyle(fontSize: kFontSizeBody/Small/Tiny, ...)` במקום `theme.textTheme.bodyMedium/bodySmall/labelSmall`. נכלל ב-typography sweep הגלובלי (ראה `app_theme.dart` Deferred). תיקון נקודתי = drift.
- **No exit animation on dismiss**: ה-card נחתך מיד ב-`setState`. הכניסה premium (fade+slide+stagger) — היציאה חתוכה. **החלטה מודעת**: "סיימתי איתך, עוף" — חיתוך מהיר תואם לכוונה. אם בעתיד יוחלט להוסיף — `AnimatedSwitcher` עם fadeOut+slide.
- **`_kEnterSlideOffset = 0.1` נשאר**: Lessons Learned מציין "0.1 כמעט בלתי-נראה — 0.2 יבליט", אבל sticky notes צריכים להרגיש "מודבקים" — 0.1 תואם לכוונה הסטיקית.

**🎯 Pattern**: דוגמה לprefs persistence עם graceful fallback + locale-aware slide animation. `context.select` ×3 (`isLoggedIn`, `pantryCount`, `listCount`) ל-rebuild מינימלי.

### 🎯 `tutorial_service.dart` — Decisions

**סבב 1 (17/5/2026)** — הטיוטוריאל המודאל של 8 שקופיות שמופיע ל-fresh users (`seenTutorial: false`). זוהה מ-screenshots של המשתמש.

- **Title emojis הוסרו — בעיית bidi wrap**: כותרות כללו אמוג'י בסוף ("ברוכים הבאים ל-MemoZap! 🎉"). כשיש Latin sub-run ("MemoZap!") בתוך מחרוזת RTL, ה-bidi seam לפני האמוג'י גרם לו לפעמים להישבר לשורה נפרדת. ה-icon container הגדול מעל הכותרת (Icons.waving_hand וכו') כבר נושא את הזהות הוויזואלית — האמוג'י היה כפילות. כל 8 הכותרות (welcome/shopping/activeShopping/pantry/household/history/navigation/ready) ניקו מאמוג'י סופי, גם `letsStart` בכפתור הסיום.
- **Description trimming**: כל ה-`*Desc` strings קוצרו ב-15-30% — סגנון conversational נשמר, מילים מיותרות הוסרו. עיקרון: tutorial של 8 שלבים = הרבה קריאה — חיתוך וורבליות מקצר את הזמן לעצמאות.
- **Magic numbers → constants**: `24/8/8/4` של dots → `_kDotActiveWidth/_kDotInactiveWidth/_kDotHeight/kSpacingXTiny`. `80×80` icon box → `_kIconBoxSize`. `340` maxWidth → `_kDialogMaxWidth`. `20/Offset(0,10)` shadow → `_kShadowBlur/_kShadowOffset`. כולם documented inline.
- **`kBorderRadiusSmall / 2` magic divide fix**: dot border radius `8/2 = 4` → `_kDotBorderRadius = 4.0` עם הערה "half of dot height → fully rounded". פטרן עקבי עם CLAUDE.md anti-pattern.
- **`Directionality(rtl)` hardcoded הוסר**: הקובץ עטף את ה-Dialog ב-`Directionality(textDirection: TextDirection.rtl)`. ה-app גלובלי-RTL — wrapper מקובע היה שובר English locale. הוסר.
- **`0.3` alphas → `kOpacityLight`**: dot inactive color + shadow alpha.
- **Back button נוסף**: היה רק "הבא" + "דלג". משתמש שדילג על שלב לא יכל לחזור. נוסף IconButton עם `arrow_forward_rounded` (RTL) / `arrow_back_rounded` (LTR), מוסתר בשלב 1. 1 string חדש: `back => 'חזור'`.
- **`ExcludeSemantics` על dots row**: קוראי מסך היו מקריאים "8 separate elements". עכשיו ה-step עצמו מקרא דרך title/description text. dots = decorative.
- **`AnimatedSwitcher.transitionBuilder`**: ברירת המחדל היא fade דרך FadeTransition — קוד היה משתמש בברירת המחדל implicitly. הפכתי ל-explicit + cached `kDialogTransitionDuration` במקום `Duration(300ms)` hardcoded.
- **Cached `theme` + `strings` references**: היו 4× `Theme.of(context)` ו-3× `AppStrings.tutorial.X` בתוך build. caching מפחית allocations.

**⏸️ Deferred:**
- **Description verbosity**: עדיין דחוס (3-4 שורות × 8 שלבים). הצעה ארוכת-טווח: להחליף ב-2-3 שלבים + interactive tooltips על כפתורי המסך הראשי. **Trigger:** שאיפת UX ל-tutorial activity-based. **היקף:** גדול.
- **Step `historyDesc` references "טאב היסטוריה"** — לא מדבר על "📜 היסטוריה" כמו ב-`navigationDesc`. בלי emoji זה פחות חזק חזותית. **Trigger:** sweep גלובלי על navigation icon vocabulary.

**🎯 Pattern**: דוגמה ל-modal multi-step tutorial עם ProgressDots + back/skip/next, RTL-aware navigation arrows, fade-cross-transition דרך AnimatedSwitcher עם ValueKey לכל step.

### 🎯 `household_activity_feed.dart` — Decisions

**סבב 1 (30/4/2026):**
- **Tab navigation fix (Source-vs-Symptom)**: ב-home dashboard, "ראה הכל" עשה `Navigator.push` במקום מעבר לטאב היסטוריה. תוקן ב-caller (home_dashboard:281) — עכשיו `onSeeAllHistory: () => widget.onTabSelected!(2)`. עקביות עם OnboardingTipsCard באותו מסך.
- **`context.watch` → `context.select`** ×2: `events` ו-`receipts` בלבד — minimal rebuilds. אותו פטרן עקבי עם `pending_invites_banner`, `action_center_card`, `onboarding_tips_card`.
- **Bidi handling on subtitle**: `fixBidiNumbers(subtitle)` על description (תוכן מעורב — שם חנות אנגלי + עברית). actor title נשאר ללא — לרוב מילה אחת ב-locale המשתמש. פטרן עקבי עם `last_chance_banner`.
- **Decorative image excludeFromSemantics**: `Image.asset(icon_home_activity.webp)` קיבל `excludeFromSemantics: true` — הטקסט "פיד פעילות הבית" לידו, image הוא decorative. per CLAUDE.md A11y policy.
- **Magic gap fix**: `kSpacingXTiny / 2` (2px) → `kSpacingXTiny` (4px). 2px צפוף מדי ל-mobile, magic number דרך חלוקה.

**סבב 2 (30/4/2026):**
- **`select<List<T>>` ביטול — תיקון round-1 שגוי**: `ActivityLogProvider.events` מחזיר `List.unmodifiable(_events)` — wrapper חדש בכל קריאה. `context.select` השווה reference → תמיד שונה → תמיד rebuild. כלומר, התיקון של round-1 היה no-op. הוחזר ל-`context.watch` עם הערה מפורשת. **Lesson:** `context.select` עוזר רק על פרימיטיבים (int/String/bool) או על אובייקטים עם value-equality מוגדרת. List/Map צריכים `select<int>(length)` או נשארים `watch`.

**⏸️ Deferred:**
- **🚨 Cross-file duplication: `_iconForType` ב-`shopping_history_screen.dart:1045`** — switch זהה לחלוטין על `ActivityType`. גם `_colorForType` שם (שונה — Color יחיד במקום bg+fg pair). פטרן עקבי: 2 מימושים = signal לחלץ ל-`lib/core/activity_visuals.dart` עם `iconForType` ו-`avatarColorsForType`. **Trigger:** סקירת `shopping_history_screen.dart`. **היקף:** קטן-בינוני (helpers + 2 callers).
- **🐛 Receipt tap = same bug as "see all"**: `_ReceiptFallbackTile.onTap` עושה `Navigator.push(MaterialPageRoute(builder: ShoppingHistoryScreen(initialReceiptId)))`. אותה בעיה שתיקנו ב-"ראה הכל" — bottom nav נעלם. אבל פה יותר מורכב: צריך גם להעביר receipt id לטאב היסטוריה (לא רק tab switch). דורש decision ארכיטקטוני על intent passing — אותו pattern של `MyPantryScreen.pendingStockFilter` smell. **Trigger:** sweep ייעודי של intent passing בין מסכים. **היקף:** בינוני.
- **Empty state design**: כשאין events ולא receipts → `SizedBox.shrink()`. **החלטה מודעת**: ה-OnboardingTipsCard באותו מסך כבר מטפל ב-onboarding (CTA "צור עוד רשימות"). empty state פה ייצור כפילות.
- **Sort on every build (line 172)**: `(List<Receipt>.from(allReceipts)..sort(...))` רץ כל build כשevents.isEmpty. רק על branch זה — לא קריטי אבל ניתן למזער.

**🎯 Pattern**: דוגמה ל-feed widget עם graceful fallback (events → receipts → SizedBox.shrink) + RTL-aware chevrons + theme.textTheme nesting (לא style-on-style).
**🎓 Lesson learned**: `context.select<List>` הוא no-op כש-getter עוטף ב-`List.unmodifiable` — נוצר reference חדש כל קריאה. רק `select<int>(length)` או `select<primitive>` עובדים באמת.

**סבב 3 (17/5/2026)** — סבב 1 ו-2 פספסו 6 ממצאים שעלו רק בקריאה זהירה. הסבב הזה ממחיש את העיקרון "כל סבב = lens אחר": סבב 1 התמקד בנביגציה, סבב 2 ב-provider semantics, סבב 3 ב-copywriting + a11y.
- **📅 DD/MM → DD/MM/YY**: `'${date.day}/${date.month}'` היה דו-משמעי. עברית RTL יכולה לקרוא "5/5" אבל דובר English עלול לקרוא MM/DD. הוספת `_year % 100` עם `padLeft(2,'0')` נותן "5/5/26" — חד-משמעי, שורה אחת בלבד, צפוף אפילו ל-feed. תואם ל-CLAUDE.md lesson "📅 תאריכים בעברית — חודש או יום?".
- **🏷️ Receipt subtitle dedup**: `title = receipt.storeName` ו-`subtitle = completedShoppingAt(receipt.storeName)` → "סופרסל • סיים קנייה ב-סופרסל". שם החנות הופיע פעמיים באותו tile. נוסף `homeDashboard.completedShopping` (no-arg) — subtitle עכשיו "סיימת קנייה" בלבד. הערה inline מסבירה למה.
- **♿ Double semantics על "ראה הכל"**: היה `Semantics(button: true, label: seeAll) > TextButton(child: Text(seeAll))`. TextButton כבר מוסיף Semantics(button) עם label-from-child. ה-wrapper גרם ל-screen readers להקריא פעמיים. נסיר. הערה ב-callsite מבהירה.
- **⚙️ Magic numbers 5 ו-3 → קבועים**: `events.take(5)` ו-`receipts.take(3)` → `_kMaxFeedEvents = 5` ו-`_kMaxFallbackReceipts = 3` עם הערה מסבירה למה fewer בfallback (visual differentiation מ-active mode).
- **📏 `_kAvatarSize` semantic naming**: היה `= kButtonHeightSmall` — סמנטית מטעה (avatar אינו button). שונה ל-`= 36.0` עם הערה מפורשת "Avatar circle diameter — semantically an avatar, not a button". אם button sizes ידריפו בעתיד, avatar לא יזחל איתם.
- **🎨 `Icons.history` → `Icons.timeline`**: ה-fallback של `icon_home_activity.webp` היה history. הוויג'ט הוא "activity feed" — timeline הולם יותר ("live/ongoing" vs "past-only"). מינורי אבל semantic.

### 🎯 `suggestions_today_card.dart` — Decisions

**סבב 1 (30/4/2026):**
- **Loading state height match**: `_LoadingState` היה `height: 80`, ה-carousel הטעון ~280px. תיקון לקפיצת layout — עכשיו `height: _kCarouselHeight` (200) עם הערה. UX חלק יותר.
- **A11y dedup על dismiss button**: היה `Tooltip(message) > Semantics(button + label) > InkWell` — Tooltip על button-like אסור per CLAUDE.md A11y policy ("❌ לא — Tooltip על כל IconButton"). הוסר Tooltip, נשאר Semantics(button + label) — pattern עקבי.
- **RTL-aware slide direction**: `slideX(begin: 0.2)` היה hardcoded. עכשיו `0.2 * (isRtl ? -1 : 1)` — אותו precedent מ-`welcome_screen` ו-`onboarding_tips_card`.
- **Dot indicator constants**: 16 / 6 / 6 / 3 קסם → `_kDotActiveWidth` / `_kDotInactiveWidth` / `_kDotHeight` / `_kDotMarginH`. השם מספר את הסיפור ("הנקודה הפעילה רחבה יותר").
- **Magic divides fix**: `kSpacingXTiny / 2` (2px) → `kSpacingXTiny` (4px) — אותו fix כמו ב-`household_activity_feed`. גם `kSpacingSmall + 2` (10) → `kSpacingSmallPlus` (12) — ערך קרוב מהמערכת.
- **Sticky-note alpha rationale**: 0.6 (×4 subtle text), 0.08 (×2 scrim shadow), 0.18 / 0.4 (error tints), 0.03 / 0.06 (gradient overlays) — נשארו inline עם הערת header אחת מסבירה "tuned as a unit for paper + ink appearance". פטרן עקבי עם `pending_invites_banner` ו-`onboarding_tips_card`.

**⏸️ Deferred:**
- **Inline TextStyle ב-3 מקומות**: urgency badge (line 605), AddAll label (line 982), product name `bodyMedium.copyWith(fontSize: kFontSizeSmall)` (line 642 — style-on-style). נכלל ב-typography sweep הגלובלי (אותה החלטה כמו `welcome_screen`, `register_screen`, `last_chance_banner`, `onboarding_tips_card`, `household_activity_feed`).
- **`_cleanProductName` runs every build**: 5 regex chain + split/dedupe + fixBidiNumbers, פעם לכל card לכל build. לא קריטי אבל ניתן למזער עם memoization. **Trigger:** אם performance profiling יראה bottleneck.
- **Consumer<SuggestionsProvider> wraps everything**: אותה בעיה כמו `household_activity_feed` — provider מחזיר `List.unmodifiable` (סביר). select<List> = no-op.

**🎯 Pattern**: דוגמה לכרטיסי sticky-notes premium עם entry animations (fade + slide + shake לcritical), AnimatedScale on press עם isolated ValueNotifier (לא rebuild הכרטיס), RepaintBoundary per card, ProductThumbnail integration.

**סבב 2 (17/5/2026)** — סבב 1 התמקד ב-layout + a11y dedup + RTL slide. סבב 2 חשף 6 ממצאים חדשים בקריאה זהירה.

- **🌍 RTL gradient direction**: `Alignment.topLeft/bottomRight` → `AlignmentDirectional.topStart/bottomEnd` על gradient של הכרטיס. אותו תיקון שעשינו ב-active_shopper_banner. ה-gradient עכשיו זורם לפי כיוון הקריאה (RTL: מימין-עליון לשמאל-תחתון).
- **♿ SnackBar contrast** (WCAG fix): 8 SnackBars השתמשו ב-sticky pastel backgrounds (`stickyOrange`, `stickyGreen`, `stickyPink`, `stickyCyan`) עם default white text מה-theme. לבן על פסטל בהיר = קונטרסט גבולי, לא עומד ב-WCAG AA. תיקון: כל ה-Text + Icons ב-content מקבלים `style: TextStyle(color: cs.onSurface)` — שחור על פסטל = ברור. `contentTextStyle` ב-SnackBar **לא קיים** ב-Flutter — הסטיילינג חייב להיות על ה-Text ישירות.
- **♿ Processing semantic state**: ה-`Semantics(value:)` תמיד אמר "במלאי: X". כשהמשתמש לחץ "+ הוסף", buttons נחבאים תחת spinner — קוראי מסך לא ידעו שמשהו קורה. עכשיו `_isProcessing == true` → value מתחלף ל-"מתבצעת פעולה". 1 string חדש: `suggestionsToday.processing`.
- **🎯 ValueKey לזהות הכרטיס**: `_StickyNoteCard` לא היה לו key מפורש ב-ListView.builder. אם ה-provider מסנן/מסדר מחדש, Flutter היה ממחזר state ל-suggestion אחר (entry animations + shake נדלקות לפריט הלא נכון). נוסף `key: ValueKey(suggestion.id)` — State + animations נעים יחד עם ה-suggestion הנכון. גם פותר את concern ה-shake animation rebuild מ-flutter_animate.
- **📐 Magic shadow numbers → constants**: 6 ערכי קסם של 2-layer shadow (8/2/4, 4/0/2, alpha 0.1) → `_kCardShadowOuterBlur/Offset`, `_kCardShadowInnerBlur/Offset`, `_kCardShadowInnerAlpha` עם הערה "tuned as a unit for sticky-note pressed-into-paper feel".
- **🎨 Active dot opacity 0.7 → 1.0**: `cs.primary.withValues(alpha: kOpacityStrong)` הוריד את ה-active dot ל-70%. inactive כבר ב-0.3 — הניגוד מ-0.7 ל-0.3 חלש. עכשיו active = `cs.primary` מלא, inactive = `cs.outline.withValues(alpha: kOpacityLight)`. "you are here" cue ברור יותר.

### 🎯 `pending_invites_banner.dart` — Reference Decisions
- **`static final _service = PendingInvitesService()`** — instance singleton, לא נוצר מחדש כל build.
- **`context.select<UserContext, String?>((u) => u.userId)`** — minimal rebuild, רק על userId change.
- **StreamBuilder עם initialData** + silent hide on stream error (debugPrint רק ב-kDebugMode).
- **Type-aware UI** (list vs household): `titleListInvite` / `titleHouseholdInvite` + 3-tier groupName fallback (household_name → group_name → list_name) עם הערה מסבירה buggy histroy.
- **Composed A11y**: `Semantics(button: true, label: composed)` סביב הבאנר + `ExcludeSemantics` על Icon + Column הפנימי. Single announcement במקום 3.

**סבב 2 (17/5/2026)** — סבב 1 סימן "Reference quality, אין ממצאים" אבל קריאה בעין חדשה חשפה 7 ממצאים אמיתיים. **לקח עצמי**: גם קובץ שנכתב כ-reference quality יכול להחביא חוסר-עקביות UX אחרי משך זמן שמחנו לב.

- **✓ button כפול הוסר**: ה-✓ ירוק עשה `Navigator.pushNamed('/pending-invites')` — בדיוק כמו ה-InkWell של הבאנר. שני tap targets עם אותה התנהגות = "שקר ויזואלי" (✓ נראה כמו 1-tap accept, בפועל 2-tap). נשאר רק × inline + tap על הבאנר → פתיחת מסך. ה-`_onAccept` method הוסר לחלוטין.
- **Tooltip → Semantics**: `_CircleActionButton` השתמש ב-Tooltip — לא עובד במובייל (אין hover) ולא נחשב label רשמי לקוראי מסך. הוחלף ל-`Semantics(button: true, label: ...)`. אותו pattern fix שבוצע ב-`household_activity_feed`. הוויג'ט שמיש כעת לכפתור decline בלבד — שמו שונה ל-`_DeclineButton`.
- **Gmail-style undo for decline**: `_isProcessing` הוחלף ב-`_pendingDeclineId` + `_declineTimer`. תאפ × → invite מסונן locally + snackbar עם "בטל" ל-5sec + Timer ל-actual API call. אם המשתמש לוחץ "בטל" — timer נמחק, ההזמנה חוזרת. אם 5sec עוברים — `declineInviteResult` נקרא לראשונה. **לא צריך service-level "undecline"**.
- **Service singleton dedup**: 2 instances של `PendingInvitesService` (אחת על `PendingInvitesBanner`, אחת על `_PendingInviteBannerContentState`). אוחדה לאחת ב-`PendingInvitesBanner._service`, המחלקה הפנימית ניגשת דרך `PendingInvitesBanner._service` (private access אפשרי באותה library).
- **`_MailShimmerIcon` extraction**: `Icons.mail_outline.animate().shimmer()` היה inline ב-`build`. בכל rebuild (Firestore stream events) ה-Animate widget נוצר מחדש → controller leak פוטנציאלי. ה-icon הוצא ל-`_MailShimmerIcon` StatelessWidget נפרד — stable widget identity, ה-State של Animate נשמר בין rebuilds.
- **`_MoreInvitesBadge` עם chevron**: ה-badge "+3 עוד" היה Container פשוט עם Text — נראה כמו metadata, לא כמו clickable. נוסף chevron RTL-aware (`chevron_left` ב-RTL, `chevron_right` ב-LTR) שמבטא "tap to see all". 3 strings חדשים: `declinePending`, `undoLabel`, `viewAllMore`.
- **`!result.isSuccess` במקום `result.isFailure`**: ה-InviteResult class חשף רק `isSuccess` getter — `isFailure` לא קיים. ניטרלי לטעות מי שמוודא לא נכון.

**⏸️ Deferred:**
- **Service-level undo**: undo דרך deferred-call עובד כי ה-API לא נקרא עד אחרי 5sec. **אבל** — אם המשתמש סוגר את האפליקציה תוך 5sec, ה-decline לא יקרה (Timer נמחק ב-dispose). זה בעצם feature לא בעיה — אבל אם רוצים to commit at-app-close, ייצור method `commitPendingDecline()` ב-service.
- **Magic alphas inline** (`_kBgAlpha=0.9`, `_kSubtitleAlpha=0.8`, etc.) — documented as "tuned as a unit". ✓ נשמרו.
- **Top-level alpha constants tuned כיחידה** (`_kBgAlpha`, `_kBorderAlpha`, etc.) — 3 מתוכם exact matches ל-`kOpacity*` אבל נשארים מקומיים בכוונה ("Banner appearance — alphas tuned to read as 'soft tertiary alert'").
- **AnimatedSwitcher כש-`invites.first.id` משתנה** — חלק במקום קופץ.
- **Shimmer animation** על אייקון המעטפה — attention-grabber מעודן.

**🎯 Reference**: דוגמה ל-orchestrator screen עם premium UX (stagger, Hero, RepaintBoundary, A11y), pull-to-refresh עם partial-fail handling.

---

## Bootstrap Entry (`main.dart`)

### 📂 Components נגעו
- `main.dart` (315 שורות) — Firebase init, Provider tree, Theme, Routing, Locale, error handlers

### ✅ Decisions Made
- **אין שינויים נדרשים בקובץ הזה** — נסקר ב-12 קטגוריות מלאות ב-29/4/2026.
- **Firebase init idempotent** — `Firebase.apps.isEmpty` check מונע double-init ב-hot restart.
- **Provider tree עקבי** — `ChangeNotifierProxyProvider` עם `updateUserContext` בכל caller.
- **Lazy loading של Products** — `lazy: false` + `Future.microtask(initializeAndLoad)` בעת login.
- **Global error handlers**: `FlutterError.onError` + `PlatformDispatcher.onError`. שניהם → Crashlytics רק ב-production.
- **Auth routes Shared Axis transition** — premium "notebook page flip" feel (400ms forward, 350ms reverse — אסימטרי בכוונה).
- **Locale + Directionality** — מ-`LocaleManager`, supportedLocales (he-IL, en-US) + 3 standard delegates.

### ⏸️ Deferred
- **🐛 Silent Firebase init failure בפרודקשן** (שורות 86-88) — אם init נכשל, ה-catch מדפיס debugPrint רק ב-kDebugMode. בפרודקשן השגיאה נבלעת בשקט והאפליקציה ממשיכה ב-broken state. תיקון לא קל:
  - לרשום ל-Crashlytics → chicken/egg (Crashlytics הוא Firebase)
  - להציג error UI → שובר bootstrap flow
  - לצאת — `SystemNavigator.pop()` קיצוני
  
  **Trigger:** החלטה DevOps/QA. **היקף:** קטן בקובץ אבל גדול בהשלכות UX.

**🎯 Reference:** דוגמה ל-Flutter app entry עם premium polish — Material You via DynamicColorBuilder, locale-aware Directionality, idempotent Firebase init, global error handlers gated by environment.

---

## App Layout (Chrome)

### 📂 Components נגעו
- `app_layout.dart` (382 שורות) — AppBar + Bottom Nav scaffold לכל המסכים תחת main_navigation

### ✅ Decisions Made
- **A11y**: Avatar GestureDetector → `Semantics(button: true, label: avatarSemanticLabel)` עם מחרוזת חדשה (he+en). הפכנו את ה-shortcut לסטטינגז למוכר ע"י קוראי מסך — קודם הוא היה decorative-only.
- **Tab 0 dedup pattern** — תג ה-bell ב-AppBar וה-tab badge בבוטומנב מציגים את אותו unread count. מודחק במכוון בבוטומנב כדי למנוע כפילות (הערה מסבירה).
- **`_AnimatedBadgeCount`** — counter animation מהערך הקודם לחדש (לא מ-0!). 400ms ease-out cubic.
- **Avatar fallback chain**: URL valid → Image.network → onError → initials. Empty/null → initials. Hebrew/Latin "?" אם אין שם.
- **`startsWith('http')` הגנה** מפני Image.network על אימוג'י (Firestore מאחסן URL וגם emoji באותו column — תועד בהערה).
- **`safeIndex.clamp(0, length-1)`** — defensive נגד deep-links עם index לא חוקי.

### ⏸️ Deferred
- אין.

**🎯 Reference**: דוגמה ל-AppBar + Bottom Nav עם premium polish (glassmorphism, animated badges, Caveat brand font, RTL-aware chevrons, RepaintBoundary).

---

## Theme

### 📂 Components נגעו
- `app_theme.dart` (650 שורות) — Material 3 light/dark + AppBrand extension + DynamicColors + harmonization

### ✅ Decisions Made
- **תיקון הערות שגויות** ב-`fillOnLight`/`fillOnDark` (שורות 337-340): הערות אמרו "6%/8% opacity" וש-Light "שקוף יותר", אבל הערכים האמיתיים 0.5/0.3 והכיוון הפוך. כתבנו מחדש כדי לתאר את המציאות + להסביר **למה** הערכים שונים בין light/dark (surfaceContainerHighest מתנהג שונה על paper-bg light vs dark).
- **Token alignment**: alphas 0.5 → `kOpacityMedium`, 0.3 → `kOpacityLight`.
- **Magic alpha שנשאר**: dialog bg 0.95 — premium tuning, single use, להשאיר inline.

### ⏸️ Deferred
- **🌱 Typography sweep גלובלי** — חוסר התאמה בין `kFontSize*` ל-M3 textTheme:
  - `kFontSizeDisplay = 34` vs `displaySmall = 36`, `displayMedium = 45`
  - `kFontSizeTitle = 20` vs `titleLarge = 22`
  - `kFontSizeXLarge = 24` ≈ `headlineSmall = 24` ✅
  - `kFontSizeBody = 14` ≈ `bodyMedium = 14` ✅

  זה גורם ל-"style-on-style" anti-pattern (`titleLarge.copyWith(fontSize: kFontSizeTitle)`) שזיהיתי ב:
  - `section_header.dart` (תוקן)
  - `suggestions_today_card.dart`
  - `welcome_screen.dart` (Backlog)
  - `register_screen.dart` (Backlog)
  - `quick_login_bottom_sheet.dart` (mild)

  **Trigger:** החלטה מערכתית — או ליישר את `kFontSize*` ל-textTheme, או למחוק `kFontSize*` ולעבור לחלוטין ל-textTheme. **היקף:** גדול (חוצה-קבצים, רבים).

**🎯 Reference:** ראוי לחיקוי — comments מסבירים **למה** כל החלטה (WCAG AA על amberText, AppBar nondominant, fillColor opacity rationale, harmonization formula).

---

## Main Navigation Screen

### 📂 Components נגעו
- `main_navigation_screen.dart` (247 שורות) — סקירה מלאה של 12 קטגוריות

### ✅ Decisions Made
- **Stream `onError` handler**: `service.watchUnreadCount(...).listen(onError: debugPrint)` — בלי זה, hiccup ב-Firestore (network/permissions) משתיק את ה-stream והבאדג' קופא. אותו pattern של `debugPrint` כמו `offline_banner.dart`.
- **OfflineBanner mounting** ב-main_nav (לא per-tab) — single source of truth.
- **IndexedStack שומר state** של כל 4 הטאבים — גלילה, חיפוש, פילטרים, נשמרים בעת מעבר.
- **`_subscribedUserId` guard** ב-stream subscription — מונע resubscribe מיותר ב-didChangeDependencies.
- **Double-tap to exit** עם `kDoubleTapTimeout` (2s), `messenger.clearSnackBars()` proactive.
- **Bounds check** ב-`_onItemTapped` — מונע RangeError מ-deep links.
- **Fade transition** (200ms) בין tabs + haptic selectionClick.

### ⏸️ Deferred:
אין.

**🎯 Reference**: דוגמה ל-navigation hub עם state preservation (IndexedStack) + stream subscription resilient ל-userId change.

---

## Bootstrap / Index Screen

### 📂 Components נגעו
- `index_screen.dart` (253 שורות) — סקירה מלאה של 12 קטגוריות

### ✅ Decisions Made
- **אין שינויים נדרשים** — הקובץ עבר 12-category review מלא ב-29/4/2026 ללא ממצאים.
- **Bootstrap state machine**: 3 מסלולים (logged in→home, seenOnboarding→login, אחרת→welcome) עם defensive guards.
- **3 race condition flags**: `_hasNavigated`, `_isChecking`, `_listenerAdded`.
- **2 timers**: `_delayTimer` (600ms initial fallback), `_syncTimeoutTimer` (8s for Firebase↔UserContext stuck state).
- **Single retry on timeout**: `userContext.retry()` ואז error screen אם נכשל.
- **Mounted check אחרי כל await** — שורות 41, 130, 178.
- **Navigator.of(context) נלכד לפני await** — אותו pattern של post_auth_navigation.
- **`_userContext` reference נשמר** ב-initState לשימוש בטוח ב-dispose.
- **`finally` block** מאפס `_isChecking` — מונע stuck state.

### ⏸️ Deferred
- אין.

### `index_view.dart` (Loading + Error views)

**📂 Used in:** `index_screen.dart` (IndexLoadingView + IndexErrorView).

**✅ Decisions Made (Round 1, 29/4/2026):**
- **A11y loading**: `Semantics(label: loadingLabel, excludeSemantics: true)` סביב ה-Loading Indicator — מונע מקורא מסך לקרוא את ה-cycling messages כל 2 שניות. אותו pattern של `loading_overlay.dart`.
- **Token alignment**: 2× alpha → kOpacity:
  - Logo shadow: 0.2 → `kOpacityLow`
  - Error card border: 0.3 → `kOpacityLight`
- **Native splash → Flutter handoff** מטופל: ה-bg color תואם בדיוק את הקובץ של flutter_native_splash.
- **5 layers of animation** (logo elastic + pulse + shimmer + wave + message rotation) עם RepaintBoundary לבידוד.
- **WavePainter optimization**: `_kWaveStepPx = 2.0` עם הערה "1px is overkill, 2px is identical visually".

**✅ Decisions Made (Round 2, 7/5/2026 — post premium-icon work):**
- **Logo size in loading circle**: `_kLogoIconSize` מ-36 ל-56 (יחס ~78% icon-to-circle). הקודם היה רך מדי בגלל הקרופ העדין יותר של ה-logo.png (95% fill).
- **Native splash icon_background_color**: revert ללבן→קרם (`#FFF8F0`). הסשן ה-בריך אותו ללבן בתחילת עבודת האייקון, מה ששבר את ההנחה של handoff invisible. **Lesson**: שינוי `icon_background_color` בלי לעדכן `kSplashBackground` או להפך = flash.
- **IndexErrorView redesign — same visual world as IndexLoadingView**: היה blue/purple/pink gradient + glassmorphism card; עכשיו cream bg + NotebookBackground.subtle + אותו logo container + Caveat header + softer cloud_off icon. זה מחליק את הקפיצה הוויזואלית כשטעינה נכשלת.
- **A11y error**: `Semantics(liveRegion: true)` סביב error column — TalkBack/VoiceOver יקריא title+message כשה-view מחליף את loading.
- **Token sweep**: `0.08` (×3 — pulse halo + 2 גלים) → `_kDecorativeTintAlpha` local; `0.04` → `_kDecorativeTintAlphaHalf`; `0.85` → `kOpacityHigh`; `150` → `_kWaveHeight`.
- **Rename**: `_buildGradientBackground` → `_buildSplashBackground` (החזיר `Container(color:)` בלבד, לא gradient — שאריות מגרסה קודמת).
- **Defensive**: `_startMessageRotation` skip אם `loadingMessages.isEmpty` (% 0 crash latent).
- **Removed unused constants** מ-`ui_constants.dart`: `kSplashGradientStart/Middle/End` + Dark variants. ה-error view היה הצרכן היחיד.

**⏸️ Deferred:**
- **Cross-file: cycling messages duplicates `loading_overlay.dart` pattern** — פרמטרים שונים (2000ms vs 1500ms, אנימציה שונה). לא דחוף לאיחוד. **Trigger:** sweep של auth-bootstrap loading widgets.
- **Loading timeout signal** — אין UI ל"לוקח יותר מהצפוי / Cancel" אחרי 5-10s. ה-8s timeout ב-`index_screen` קיים אבל invisible. **החלטה (7/5):** לא לטפל עכשיו, לחכות לדיווח משתמשים על stuck UI.
- **4 simultaneous logo animations** (elastic + rotation + pulse + shimmer) — possibly overproduced אבל בחירת עיצוב מודעת. לא לשנות בלי בקשה.

**🎯 Reference**: דוגמה ל-bootstrap visual layer עם premium animations + careful lifecycle (4 controllers + Timer, all disposed).

---

## Auth Screens (Login)

### 📂 Components נגעו
- `login_screen.dart` (818 שורות) — סקירה מלאה של 12 קטגוריות

### ✅ Decisions Made
- **Snackbar dedup ×2**: `_showStatus` ו-PopScope's `messenger.showSnackBar` שניהם עכשיו עם `removeCurrentSnackBar()`.
- **Token alignment**: 3× alpha → kOpacity:
  - DEV button bg: 0.12 → `kOpacitySubtle`
  - DEV button border: 0.3 → `kOpacityLight`
  - Login button shadow: 0.3 → `kOpacityLight`
- **brand reuse**: `brand?.success` משומש מתוך scope (Builder pattern) במקום re-fetch של `Theme.of(context).extension<AppBrand>()`.
- **5-tap dev gesture נשאר חשוף בפרודקשן** — **החלטה מודעת**: המשתמש עדיין בודק. בעצם לא עושה כלום בפרודקשן (אין `demo.com` accounts ב-Firebase production). אם יוחלט בעתיד שזה רע — לעטוף ב-`if (kDebugMode)` כמו הכפתור הוויזואלי בשורה 416.

### ✅ Decisions Made (סבב 4, 22/6/2026 — סנכרון עם register + חילוץ)
- **⏳ Timeout + Cancel + הגנת race — סונכרן עם register**: login היה עם overlay טעינה אינסופי (אותו באג שתוקן ב-register). נוסף דגל `_authAbandoned` + `_setLoading`/`_cancelLoading`, וכל בלוקי ה-UI שאחרי await (login/Google/Apple, success+catch) בודקים `mounted && !_authAbandoned`. forgot-password נשאר לא-מוגן במכוון (אין ניווט — רק snackbar).
- **🧩 חילוץ `TimedLoadingOverlay`**: ה-overlay-עם-timeout נדרש פעמיים (register+login) → חולץ ל-`widgets/timed_loading_overlay.dart`. ה-widget מחזיק את הטיימר בעצמו (mounted רק בזמן טעינה → ניהול אוטומטי). **register גם פושט** — נמחקו `_loadingTimeoutTimer`/`_loadingTakingLong` + הטיימר מ-`_setLoading`. שני המסכים משתמשים ב-`TimedLoadingOverlay(color, onCancel)`.
- **⚡ RepaintBoundary סביב הטופס**: היה ב-register, חסר ב-login (ה-shake צייר מחדש את כל הטופס בכל frame). נוסף ליישור.

### ⏸️ Deferred
- **`_showStatus` כפילות עם register_screen** — שני העתקים כמעט זהים של snackbar configuration. (ה-overlay כבר חולץ; זה הבא בתור.) **Trigger:** סקירה ייעודית של auth shared utilities. **היקף:** קטן (extract ל-`auth_snackbar_utils.dart` או דומה).
- **22 משתמשי דמו hardcoded ב-`_demoUsers`** — כפילות חלקית עם `scripts/rebuild_demo_data.js`. סכנת drift אם מישהו מעדכן את הסקריפט בלי לעדכן את המסך. **Trigger:** מי שמעדכן demo users. **היקף:** קטן (להפיק רשימה אחת מהקובץ של הסקריפט אם אפשר).
- **שורה 344: `'name': 'apple_user@icloud.com'`** — ה-name הוא אימייל, לא שם בעברית כמו השאר. בפועל מציג את הכתובת עצמה ב-bottom sheet. **Trigger:** סקירה של quick_login_bottom_sheet או demo data refresh. **היקף:** מינוסקולי.
- **Style-on-style typography** — `headlineLarge.copyWith(fontWeight: w800, fontSize: kFontSizeDisplay)`. אותו דפוס שכבר נרשם ב-Auth Screens (Register). **Trigger:** typography sweep גלובלי.

### ⏳ Files of this screen — pending review
- ~~`quick_login_bottom_sheet.dart`~~ ✅ **נסקר** ב-29/4/2026

### 🔍 Second-Round Findings (29/4/2026)

**✅ נסגרו בסבב השני:**
- **fillColor יישור login ל-0.4** — login עבר מ-`alpha: 0.6` ל-`alpha: 0.4` ליישור עם register ושפת notebook+sticky ("שקיפות עמוקה – דיו על נייר"). 2 שורות (אימייל + סיסמה).

**⏸️ נשאר ב-Deferred:**
- **🔁 Shake animation duplication** — `_shakeController` + `_shakeAnimation` עם אותו TweenSequence (0→10→-8→6→-4→0) קיים ב-login (400ms) וב-register (500ms). אותו ייעוד (form validation fail), אותה לוגיקה. **Trigger:** סקירה ייעודית לחילוץ `ShakeOnError` widget משותף. **היקף:** קטן-בינוני.

### 🔍 Third-Round Findings (2/6/2026) — login + register

**✅ נסגרו (gap-driven — פיצ'ר שהיה ב-register או היה אמור להיות, חסר ב-login):**
- **autofillHints + AutofillGroup** — היו **0 שימושים בכל `lib/`**. נוסף לשני המסכים: login (email=`username,email`; password=`password`), register (name/email/phone/password/confirm עם `newPassword`). + `TextInput.finishAutofillContext()` אחרי הצלחה → מערכת ההפעלה מציעה לשמור סיסמה. מנהלי סיסמאות (iCloud/Google/1Password) עכשיו ממלאים ושומרים.
- **Keyboard flow ב-login** — היה רק `_emailFocusNode` לא-בשימוש. נוסף `_passwordFocusNode` + `TextInputAction.next` (email) → focus לסיסמה → `.done` מפעיל login. (register כבר היה תקין — שורש: login פיגר אחרי register.)
- **השהיית הצלחה 1500ms → 800ms** (קבוע `_kSuccessRedirectDelay`) — פחות חיכוך למשתמש חוזר.
- **עקביות social** — Google/Apple עכשיו מציגים אותו משוב הצלחה + 800ms כמו אימייל (לפני כן ניווטו מיד בלי משוב).
- **קופי ספאם** — `resetEmailSentTo` עכשיו "(בדוק גם בתיבת הספאם)" — תואם את `verificationEmailSent` הקיים.
- **scrim alpha 0.25** — קיבל הערה מסבירה (single-use, literal עם הסבר במקום const).

**⏸️ נשאר ב-Deferred:**
- register success delay נשאר 1200ms (לא קוצר ל-800 — פעולה חד-פעמית, פחות חיכוך חוזר). **Trigger:** אם רוצים עקביות מלאה בין login ל-register.

---

## Auth Screens (Register)

### 📂 Components נגעו
- `register_screen.dart` (885 שורות) — סקירה מלאה של 12 קטגוריות

### ✅ Decisions Made
- **Inclusive copy**: `registerSubtitle` (Hebrew) — "קניות משפחתיות" → "ניהול הקניות". האנגלית כבר הייתה ניטרלית ("Join the smarter way to shop"), לא נגענו.
- **Snackbar dedup**: `_showStatus` עכשיו מסיר snackbar קודם לפני שמציג חדש — אותו pattern של 5+ קבצים אחרים בסשן.
- **Token alignment**: alpha 0.3 על shadow של register button → `kOpacityLight`.
- **Source-vs-Symptom**: `_askHouseholdName` כבר מתקן את "ללא שם" ב-source (auto-name `MemoZap-XXXX` על Skip — בוצע בסשן קודם).

### ✅ Decisions Made (סבב 2, 22/6/2026 — קריאת קוד מלאה)
- **📱 טלפון: חובה → אופציונלי (source-vs-symptom)**: השדה היה חובה בהרשמת אימייל אבל (א) לא נאסף מ-Google/Apple, (ב) `findByPhone` קיים עם **0 callers** — אין invite-by-phone. כלומר נדרש מידע שלא בשימוש ולא-עקבי מול social. הוסר ה-required מה-validator (ריק=תקין, אם מולא עדיין מאמת פורמט ישראלי), label קיבל `(אופציונלי)`, ו-`signUp` מקבל `null` כשריק. בנוסף: `phoneHelperText` הסיר הבטחה שגויה ("לקבלת עדכונים מהקבוצות" — לא קורה) → "מספר נייד ישראלי" (he+en).
- **⏳ Loading timeout + Cancel**: ה-overlay חסם את המסך ללא מוצא. נוסף `_setLoading()` מרכזי + טיימר 10ש' → מציג "הטעינה לוקחת יותר מהצפוי..." + כפתור ביטול (כל 3 מסלולי auth: email/Google/Apple). הודעה עטופה ב-`Semantics(liveRegion)`. String חדש `loadingTakingLong` (he+en).
- **🐛 RTL בדיאלוג שם הבית — תוקן** (היה Deferred): הוסר `textDirection: TextDirection.rtl` מקובע (שורה 135) ששבר שמות אנגליים. ה-app RTL גלובלית, TextField בוחר אוטומטית.
- **אימות סיסמה — נשאר**: שקלנו להסיר (יש הצג/הסתר), המשתמש בחר לשמור — טעות הקלדה ברישום = נעילה מהחשבון.

### ✅ Decisions Made (סבב 3, 22/6/2026 — תיקון race שהוכנס בסבב 2)
- **🐛 Cancel-during-loading race**: ה-escape hatch (Cancel) רק הסתיר את ה-overlay, אבל ה-Future של ה-auth המשיך ברקע — וכשהצליח, בלוק ה-`if (mounted)` בכל זאת פתח את דיאלוג שם-הבית וניווט את המשתמש פנימה, **נגד הביטול**. נוסף דגל `_authAbandoned` (מתאפס ב-`_setLoading(true)`, נדלק ב-`_cancelLoading()`); כל בלוקי ה-UI שאחרי ה-await (success + catch, בכל 3 המסלולים) בודקים `mounted && !_authAbandoned`. הבלוקים המקוננים נשארו `mounted` בלבד — שם ה-overlay כבר נעלם וה-Cancel לא נגיש.

### ⏸️ Deferred (סבב 3)
- **משתמש שביטל אחרי שההרשמה כבר הצליחה ברקע**: נשאר רשום ב-Firebase (auth persists) אך תקוע במסך ההרשמה. ניסיון הרשמה חוזר → "אימייל כבר בשימוש". **אפשרות שיפור:** לזהות את המצב ולהציע מעבר להתחברות. **Trigger:** דיון על recovery flows. **היקף:** קטן. (מקובל כרגע — השגיאה עצמה רמז שימושי.)

### ⏸️ Deferred
- **`_askHouseholdName` משתמש ב-raw `showDialog`** במקום `AppDialog.show`. כל שאר הדיאלוגים באפליקציה כבר עברו ל-AppDialog. **שאלה עיצובית פתוחה:** האם לאחד עם `showEditHouseholdNameDialog` (ה-shared dialog שעבדנו עליו) — הם דומים אבל ב-intent שונה (post-register עם Skip vs edit עם Cancel). **Trigger:** סקירה של edit_household_name_dialog או דיון מודע על איחוד הדיאלוגים. **היקף:** קטן-בינוני.
- **`_phoneRegex` Israeli-only** (`^05[0-9]-?[0-9]{7}$`). חל רק אם המשתמש בכלל מילא טלפון (עכשיו אופציונלי). בסדר ל-launch בעברית, אבל אם האפליקציה תתרחב ל-locales אחרים — צריך לוקאל-aware. **Trigger:** הוספת locale חדש או דרישות בינ"ל. **היקף:** קטן.
- **דיאלוג שם הבית קופץ לפני snackbar ההצלחה**: אחרי register → מיד דיאלוג "שם הבית" → ואז "נרשמת!". אין רגע "הצלחת!" לפני בקשת פעולה נוספת. **Trigger:** דיון UX על סדר ה-onboarding שאחרי register. **היקף:** קטן.
- **Style-on-style typography**: `headlineLarge.copyWith(fontSize: kFontSizeXLarge, fontWeight: w800)` — דפוס שחוזר באפליקציה (welcome, suggestions_today_card, section_header [תוקן]). **Trigger:** typography sweep גלובלי. **היקף:** בינוני (חוצה-קבצים).

### ⏳ Files of this screen — pending review
- ~~`loading_overlay.dart`~~ ✅ **נסקר** ב-29/4/2026 — Cross-Cutting Widgets
- ~~`social_login_button.dart`~~ ✅ **נסקר** ב-29/4/2026 — Cross-Cutting Widgets
- ~~`post_auth_navigation.dart`~~ ✅ **נסקר** ב-29/4/2026 — Cross-Cutting Widgets (אין ממצאים)

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

### 🎯 `household_members_screen.dart` — Decisions

**סבב 1 (30/4/2026):**
- **Owner-leave UX**: כפתור "עזוב בית" היה מוצג גם לבעלים → לחיצה הציגה snackbar "owner can't leave". עכשיו הכפתור מוצג כמבוטל לבעלים (`onPressed: null`, צבע מעומעם, tooltip "owner cannot leave...transfer ownership / delete household"). ה-defense-in-depth ב-`_leaveHousehold` נשאר כsafety.
- **Snackbar dedup helper**: 5 קריאות `ScaffoldMessenger.showSnackBar` בלי `removeCurrentSnackBar()` הפכו ל-`_showSnackBar(message)` private method ש מבצע dedup ב-source אחד.
- **Haptic feedback**: `lightImpact` על remove + toggle role, `mediumImpact` על leave (point-of-no-return). עקביות עם שאר ה-codebase.
- **Error state → AppErrorState**: היה bare `Text(_error!, style: cs.error)`. עכשיו `AppErrorState(message, onAction: _loadMembers, actionLabel: retry, actionIcon: refresh)` — אייקון + retry button.
- **RTL-aware slide animations** ×2: `slideX(begin: -0.1)` (header) ו-`slideX(begin: 0.05)` (member cards) → flip לפי `isRtl`. אותו precedent של welcome/onboarding/suggestions.
- **Decorative emoji ExcludeSemantics**: '🏠' עוטף ב-`ExcludeSemantics` — household name לידו נושא משמעות.
- **Avatar size composition fix**: `kIconSizeLarge + kSpacingXTiny` (40) → `kIconSizeXLarge` (48). הרכבת קבועים = magic via add (לפי הכלל החדש ב-CLAUDE.md). 48 תואם הקיים.
- **Magic `vertical: 2` ×2 → `_kBadgeVerticalPadding`**: file-level const עם הערה "tight padding for badges, 4px is too airy".
- **`context.watch<UserContext>` → `context.select<UserContext, String?>(householdName)`**: רק שם הבית רלוונטי — לא לrebuild על themeMode/displayName.

**⏸️ Deferred:**
- **Inline TextStyle ×2 (lines 442-447, 468-471)**: `TextStyle(fontSize: kFontSizeTiny, ...)` ב-"me" badge ו-role badge. נכלל ב-typography sweep הגלובלי.
- **PopupMenuButton בלי tooltip מותאם**: ברירת מחדל היא "Show menu" (לא ב-Hebrew). **Trigger:** A11y sweep למקרה שההכרזה לא ברורה לקוראי מסך.
- **`_loadMembers` reload אחרי כל פעולה**: יכול להיות optimistic update במקום round-trip ל-Firestore. **Trigger:** סקירה של `household_service.dart`.

**🎯 Pattern**: דוגמה למסך CRUD עם role-based UI (owner-only actions), defense-in-depth permission checks (UI gating + service-level guards), ו-snackbar dedup helper מקומי.

### 🎯 `manage_users_screen.dart` — Decisions

**סבב 1 (30/4/2026):**
- **🚨 Removed hardcoded `Directionality(rtl)` ×2**: שתי פעמים הקובץ עטף את כל הScaffold ב-`Directionality(rtl)` — הפרה מפורשת של CLAUDE.md ("בלי Directionality(rtl) מקובע — האפליקציה כבר RTL גלובלי"). משתמש דובר אנגלית קיבל מסך הפוך. הוסר.
- **`isOwner` → `canManage`**: שם משתנה היה מטעה — `ShareListService.canUserManage` מחזיר true גם ל-admin, לא רק owner. הצמדה בין שם ללוגיקה. גם פתר בלבול עם `isUserOwner` באותו scope.
- **Snackbar dedup helper unified**: 3 קריאות `ScaffoldMessenger.showSnackBar` + `_showError` הפכו ל-`_showSnackBar(message, isError: false)` יחיד עם opt-in לצבע אדום. `_showError` נשאר כ-thin wrapper.
- **Haptic feedback**: `mediumImpact` על remove (point-of-no-return בקונטקסט list משותף), `lightImpact` על role edit + invite navigation.
- **Card animations** ×N: `fadeIn(400ms) + slideX(begin: 0.05 * isRtl)` per card — עקביות עם `household_members_screen` (אותה תיקייה). RTL-aware.
- **Magic alphas → kOpacity***: `alpha: 0.5` (empty state icon) → `kOpacityMedium`. `alpha: 0.3` (avatar bg) → `kOpacityLight`. matches מדויקים לקבועים.
- **`context.watch<UserContext>` → `context.select<UserContext, String?>(userId)`**: רק userId רלוונטי — minimal rebuilds.

**⏸️ Deferred:**
- **Inline TextStyle ×6+**: הקובץ לא משתמש ב-`theme.textTheme.*` בשום מקום — כל Text עם `TextStyle(fontSize: kFontSize*, ...)` ידני. שורות 329, 352, 389, 439, 465, 515, 530, 543, 552. נכלל ב-typography sweep הגלובלי.
- **`Card(elevation: 2)`**: ערך magic, ושאר ה-cards באפליקציה (`household_members_screen`) עם elevation 0 + border. **שאלה ויזואלית**: לעבור לסגנון אחיד? לא תוקן ללא אישור מפורש (visual change). **Trigger:** sweep ויזואלי של cards.
- **Header Padding/Row repeated ×2**: אותו header בלוק מופיע פעם ב-`if (currentUserId == null)` ופעם ב-build הרגיל — extract ל-`_buildHeader()` private method.
- **`_getDisplayName` קורא `context.read<UserContext>()` לכל user**: אפשר לקבל userContext פעם אחת ב-`_buildBody` ולהעביר. micro-optimization.
- **PopupMenuButton בלי tooltip מותאם**: ברירת מחדל "Show menu". A11y minor.
- **Raw `showDialog` ×2** (remove + edit role): שאר האפליקציה משתמשת ב-`AppDialog.show`. אותו refactor שתועד ב-`edit_household_name_dialog`.

**🎯 Pattern**: דוגמה ל-list management UI עם role-based UX (owner sees menu, viewer sees label only), inline error/empty/loading states עם retry, ו-defense-in-depth permission checks.

### 🎯 `settings_screen.dart` — Decisions (Rounds 1-3 complete, 30/4/2026)

**Round 1 (30/4/2026) — Logic + Actions + Delete dialog:**
- **🚨 Removed hardcoded `textDirection: TextDirection.rtl`** (delete account confirm field, line 391). אותו pattern של `manage_users_screen` ו-`edit_household_name_dialog`.
- **`_showSnackBar(SnackBar, {messenger?})` helper**: 6 קריאות ראויות-לdedup (logout error, debug delete error, 3 delete account flows, success). תומך בהזרקת `ScaffoldMessengerState` חיצוני (לדיאלוגים שלא רואים את ה-Scaffold). pattern עקבי עם household_members + manage_users.
- **Haptic feedback**: `lightImpact` על logout (data שמורה), `mediumImpact` על debug delete + delete account success (point-of-no-return).
- **Magic alphas → file-level constants**: `_kErrorBgAlpha = 0.1` ו-`_kErrorBorderAlpha = 0.3` (×4 callers — debug delete + delete account warnings). 0.1 לא קיים ב-`kOpacity*`, ו-`_kError*` שמות סמנטיים מסבירים את השימוש.
- **`_loadSettings` Firestore reads parallel**: שתי קריאות sequential (member doc + household doc) → `Future.wait([...])`. שניהם תלויים רק ב-householdId, לא אחד בשני. ~50% חיסכון בזמן.

**🧠 UX Pass (30/4/2026) — 9 of 10 user-perspective findings applied:**
- **Q1: Logout reassurance copy** — `logoutMessage` now explicitly says "Your data (lists, pantry, history) stays. You can log in again with the same account" instead of just "Are you sure?". משתמשים שמהססים עכשיו יודעים שלא יאבדו דבר.
- **Q3: Delete account shared lists impact** — `deleteAccountWarning` got a new bullet: "Lists you own — other members will lose access". משתמשים מבינים שהמחיקה משפיעה גם על אחרים.
- **Q4: SnackBarAction "התחבר עכשיו"** ב-`requiresRecentLogin` — היה רק טקסט שנעלם. עכשיו כפתור פעולה ש logout + redirect ל-login.
- **Q5: Timeout 30s** על 3 ה-awaits הקריטיים (signOut, signOutAndClearAllData, deleteAccount). אם הרשת תקועה — ההמתנה נכשלת אחרי 30 שנייה עם הודעה ברורה ("הפעולה לוקחת יותר מהצפוי") במקום spinner ללא הגבלה.
- **Q6: Edit household name dialog subtitle** — "השם נראה לכל החברים בבית, מתעדכן מיד". הסבר על השפעה.
- **Q7: Remove member explanation** — `removeMemberConfirm` עכשיו מסביר: "X לא יוכל יותר לראות רשימות משותפות. הרשימות שיצר ימשיכו להיות זמינות". פחות פחד, יותר vמידע.
- **Q8: PopupMenu role subtitles** — "הפוך למנהל" קיבל subtitle "יוכל להוסיף ולהסיר חברים". "הפוך לחבר" עם הסבר על המגבלות.
- **Q9: Role filter chips** ב-manage_users — `ChoiceChip` row (All / Owners / Admins / Editors / Viewers) למסכי רשימות עם הרבה משתתפים.
- **Q10: Viewer-only banner** ב-manage_users — viewer רואה כעת "אתה צופה בלבד — לעריכה, פנה לבעל הרשימה" במקום להתבלבל מחוסר ה-actions menu.

**⏸️ Deferred — Q2: Login screen Google-hint after Settings logout** — משתמשי Google לא יודעים שההתחברות הבאה תהיה silent. דורש שינוי ב-`login_screen` (כבר reviewed Apr-29). **Trigger:** סקירה עתידית של `login_screen` או החלטה על account-switching feature. **היקף:** קטן-בינוני.

**Round 2 (30/4/2026) — Profile bottom sheet + 5 sections + main scaffold:**
- **🐛 Animation interval bug fixed**: היה `_sectionCount = 9` עם stagger 0.12 + duration 0.4 = 1.36 → סקציה 8 קלמפ ל-1.0 עם רק 0.04 שניות אנימציה (חוקי לפי הכלל החדש שהוספתי ל-CLAUDE.md). תוקן ל-8 sections × 0.08 + 0.3 = 0.86 ≤ 1.0. כל הסקציות מקבלות אנימציה מלאה.
- **🐛 `_sectionCount` off-by-one**: היו 9 controllers אבל רק 8 indices השתמשו (delete-account היה ב-`_sectionCount-1` = 8, ו-7 לא היה בשימוש). הורד ל-8.
- **🚨 Hardcoded RTL on display name field** (Profile bottom sheet) הוסר.
- **🚨 Hardcoded English snackbar** "v$version copied" → `AppStrings.settings.versionCopied(version)` (he+en).
- **Camera badge RTL fix** במסך ההגדרות הראשי: `Positioned(right: 0)` → `PositionedDirectional.end`. תאם ל-profile sheet שכבר השתמש ב-`PositionedDirectional`.
- **Snackbar dedup helper** מורחב ל-6 callers נוספים (profile bottom sheet ×5 + version copy).
- **Profile save haptic**: `lightImpact` אחרי הצלחה.
- **`_kCardBgAlpha = 0.85`/`_kCardBorderAlpha = 0.2`** קבועים ראש קובץ — 6 ה-section cards.
- **Composition-via-add fixes**: `kIconSizeXLarge + kSpacingXLarge` (80) → `_kProfileAvatarSize`. `kSpacingXLarge + kSpacingSmall` (40) → `_kHandleBarWidth`. magic `30` → `_kDisplayNameMaxLength`. **לפי הכלל החדש ב-CLAUDE.md** שאוסר חיבור קבועים.
- **Handle bar wrapped in `ExcludeSemantics`** (decorative drag affordance). Alpha 0.3 → `kOpacityLight`. Border width 2 → `kBorderWidthFocused`.
- **🌍 Comment**: "ניהול משפחה" → "ניהול בית".

**Round 3 (30/4/2026) — `_NotificationToggle` + `_ThemeCard` (~110 שורות):**
- **`_NotificationToggle`**: `activeTrackColor` alpha 0.3 → `kOpacityLight`. הקובץ עצמו תקין — SwitchListTile a11y מובנה, haptic מובדל (lightImpact ל-on, selectionClick ל-off).
- **`_ThemeCard`**: 3 magic alphas → `kOpacitySubtle` (0.12, selected bg) + `kOpacityMedium` (0.5, unselected bg) + `kOpacityLow` (0.2, unselected border). Border width 2 → `kBorderWidthFocused` (selected). 1 → literal עם הערה (Material default). AnimatedScale + AnimatedContainer premium feel ✅. Semantics(button + label + selected) ✅.

**Round 4 (19/5/2026) — FCM wiring + sticky-note visual unification + Logout/Delete hierarchy:**
- **🔔 FCM toggles now actually filter push** (was: TODO comment said toggles "save to SharedPreferences but not connected to FCM"):
  - 4 new fields on `users/{userId}` Firestore doc: `notify_shopping`, `notify_group`, `notify_reminders`, `notify_list_updates`.
  - `_saveNotificationSetting` writes BOTH SharedPreferences (UI cache) AND Firestore (server-truth) on every toggle change.
  - `_loadSettings` reads Firestore first, falls back to SharedPreferences for existing users.
  - **One-time auto-migration**: on first open after this change, missing Firestore fields are seeded from SharedPreferences values so existing users keep their preferences.
  - **Cloud Function `onNotificationCreated`** (functions/index.js) reads the user doc, maps `notification.type` to the matching `notify_*` field, and skips `getMessaging().send()` if the field is `false`. Missing fields default to `true` (fail-open — never silently drop an invite because of a missing toggle).
  - **Type → toggle mapping** (mirrors `NotificationType` enum):
    - `who_brings_volunteer` → `notify_shopping`
    - `invite` / `request_approved` / `request_rejected` / `role_changed` / `user_removed` / `member_left` → `notify_group`
    - `low_stock` / `expiry_expired` / `expiry_soon` → `notify_reminders`
- **🎨 6 sections migrated from Material Card → StickyNote** (matching the app's "Notebook + Sticky Notes" design language). Color palette per section, slight rotation each:
  - Section 0 (Profile): `stickyYellow` (-0.005°) — warm hero identity
  - Section 1 (Notifications): `stickyOrange` (+0.005°) — attention/alerts
  - Section 2 (General/Theme): `stickyCyan` (-0.008°) — cool configuration
  - Section 3 (Household): `stickyPink` (+0.008°) — warmth/people
  - Section 4 (Quick Links): `stickyPurple` (-0.005°) — secondary actions
  - Section 5 (Info): `stickyGreen` (+0.005°) — info/safe
  - StickyNote uses `padding: 0` + `animate: false` so the existing inner Padding and `_animatedSection` entrance animation are preserved.
  - Sections 6 (Logout) and 7 (Delete) stay as `Card` — see hierarchy fix below.
  - `_kCardBgAlpha` / `_kCardBorderAlpha` constants removed (no longer used after migration).
- **🚨 Logout / Delete-account visual hierarchy fixed** (mis-tap risk):
  - Logout was `errorContainer` red + red text + heavyImpact haptic — visually identical magnitude to Delete-Account.
  - Logout now: neutral `surfaceContainerHighest` background, `onSurfaceVariant` icon/chevron, regular `onSurface` text, **lightImpact** haptic (reversible action). Communicates "boring safe sign-out" rather than "danger".
  - Delete-Account now: deeper `errorContainer.withValues(alpha: 0.9)` + **bold title** + `kBorderWidthFocused` (2px) red border for emphasis. Distinct "danger zone" feel.
  - Spacing between them: `kSpacingMedium` (16) → `kSpacingXLarge` (32). Tells the eye "this is a separate zone".

**⏸️ Deferred (Rounds 1-3):**
- **🔗 Direct `cloud_firestore` imports + reads ב-`_loadSettings`** (lines 113-128): המסך קורא ישירות ל-`households/{id}/members/{userId}` ו-`households/{id}`. צריך לחלץ ל-`HouseholdService.getCurrentUserRole(householdId, userId)` או דומה. **Trigger:** סקירת `household_service.dart`. **היקף:** קטן-בינוני (service method + screen replacement).
- **Inline TextStyle ×6+ ב-`_NotificationToggle`, `_ThemeCard`, ב-dialogs ובהדר**: כל המקומות נכללים ב-typography sweep הגלובלי.
- **`elevation: 2` ב-debug delete card** — visual decision, נשאר.
- **Loading dialog משוכפל ×3** (logout, debug delete, delete account): כמעט-זהה Card+spinner+text. ניתן להמיר ל-helper `_showLoadingDialog(message)` או widget `_LoadingDialogContent`. **Trigger:** decision על dialogs refactor. **היקף:** קטן.
- **Inline TextStyle ×6+ ב-dialogs**: שורות 179, 261, 273, 357, 375, 381, 449. נכלל ב-typography sweep הגלובלי.
- **Raw `showDialog` ×3** (logout, debug, delete account): שאר האפליקציה עברה ל-`AppDialog.show`. אותו pattern שתועד ב-`edit_household_name_dialog`.
- **`_debugClearAllData` not gated by `kDebugMode`**: title אומר 🔧 DEBUG, אבל הfunction עצמה אינה נבדקת ב-`if (kDebugMode)`. צריך לוודא ב-Round 2 איפה ה-button קורא לה.

**⏸️ Deferred (Round 4, 19/5/2026) — Large security/GDPR/UX gaps:**
- **🔐 Biometric lock on destructive actions** — "Delete account" and (debug-only) "Clear all data" are protected by a typed-confirmation dialog, but an unlocked phone can still trigger them. Modern apps gate destructive ops behind Face ID / Touch ID. **What's needed**: `local_auth` package, iOS `NSFaceIDUsageDescription`, Android `USE_BIOMETRIC` permission, fallback to passcode, test on real devices (not emulator). **Trigger**: when a user reports an "accidental delete" or for an App Store review polish pass. **Size**: medium (single dialog wrap, but cross-platform permission boilerplate).
- **📦 GDPR data export** — "מחק חשבון" exists (`onUserDeleted` Cloud Function does cascading delete) but GDPR Article 20 also requires **portability**: the user must be able to download their data in a machine-readable format. **What's needed**: new Cloud Function that walks every collection touching the user (private_lists, inventory, notifications, household membership, shopping_patterns, saved_contacts), serializes to JSON, uploads to Storage with a signed link, emails the user. Settings UI = one button "📦 הורד את הנתונים שלי" → triggers the function → snackbar "התחלנו לאסוף, נשלח אליך מייל". **Trigger**: pre-launch in EU, or when a user requests it. **Size**: large (server-side feature, separate session).
- **✉️ Edit email / password from settings** — currently the user can edit name + avatar only. Email/password require Firebase Auth `reauthenticate*` before update (security). **What's needed**: new section "🔐 אבטחה" with two flows. (1) Edit email: re-auth → `updateEmail()` → send verification → snackbar. (2) Edit password: re-auth → `updatePassword()`. Both need careful handling of social-login users (Google/Apple — no password to change; show explanation instead). **Trigger**: user request, or 3rd-party auth onboarding pass. **Size**: medium (1 screen + 2 dialogs, plus error mapping for re-auth failures).
- **🔗 Linked accounts info** — if user signed up with Google/Apple, settings shows nothing about it. Should display "מחובר עם 🔵 Google" / "🍎 Apple" + an "unlink" affordance (with warning that the user will need a password). **Size**: small once edit-password flow exists.
- **🔕 Permission UX hint** — if user denied push permission at the OS level, the 4 toggles look functional but nothing arrives. Should show a hint banner above the toggles section: "התראות כבויות במכשיר → הפעל בהגדרות". Requires `Permission.notification.status` check (permission_handler package) + `openAppSettings()` deep link. **Size**: small.

---

## Pantry Screen

### 📂 Components נגעו
- `lib/screens/pantry/my_pantry_screen.dart` (~1,477 שורות) — נגענו נקודתית, **לא נסקר end-to-end ב-12 קטגוריות**.
- `lib/widgets/inventory/pantry_item_dialog.dart` (~1,178 שורות) — נסקר חלקית (תוספת barcode row + brand/size badges מסשן קודם).

### ✅ Decisions Made (3/5/2026)

**Quantity chip — locale-aware direction:**
- הצ'יפ של הכמות (`'${quantity} ${unit}'`) הציג "ליטר 3" / "יח' 3" — היחידה ראשונה והגרש בצד שגוי. הסיבה: ה-`Row` סביב הצ'יפ עטוף ב-`Directionality(LTR)` כדי לשמר את -/+ במקום קבוע, וה-LTR החיצוני דלף לטקסט בפנים.
- **תיקון:** הצ'יפ Text עוטף ב-`Directionality` משלו, מבוסס על `isRtl` מהסקופ העליון. ה-LTR לכפתורים נשאר. עכשיו: עברית "3 יח'", אנגלית "3 pcs".

**Edit dialog — barcode row:**
- הדיאלוג היה מציג brand+size מהקטלוג (read-only) אבל לא את הברקוד עצמו. 4 פערי UX (אימות סריקה, הבחנה בין מוצרים דומים, indicator לפריטים לא בקטלוג, share). הוספה שורה קטנה ומעומעמת מתחת לcatalog badges: `inventory.barcodeRow(code)` (he+en, LTR-locked).

**FAB tooltips — pair-symmetric:**
- 3 FABs (כתום: סריקה להורדה, כחול QR: סריקה להוספה, כחול +: ידני). ה-tooltip של ה-QR היה `'סרוק ברקוד'` — לא הבחין מהכתום.
- הוסף `inventory.scanToAddTooltip` = "סרוק להוספה למלאי" — קורא כצמד עם הכתום ("סרוק להורדת מלאי").
- מרווח בין FABs בילט מ-`kSpacingSmall` (8) ל-`kSpacingSmallPlus` (12) — לא יושבים אחד על השני.

**Demo data — real catalog products:**
- `'חטיף חלבון - תפוגה קרובה'` ב-PATCH 5c של `rebuild_demo_data.js` החליף ל-`'חטיף חלבון בטעם שוקולד'` (ברקוד אמיתי 7290110327798). הסטטוס "תפוגה קרובה" נגזר מ-`expiry_date` במקום להיכתב לתוך השם.
- שם ארוך ל-overflow test: 'שמנת מתוקה תנובה ... מארז חיסכון משפחתי 3 יחידות במחיר מיוחד' המומצא → 'ריזאלטס תמיסה - משמיד כינים ומסלק ביצי כינים ללא חומרי הדברה כימיים 200 מ״ל' (75 תווים, מהקטלוג).

### ⏸️ Deferred

- **🐛 3 FABs → Speed Dial** (option א מסשן 3/5): המשתמש בחר באיחוד ל-FAB יחיד שפותח תפריט. **Trigger:** session ייעודי לפני launch. **היקף:** בינוני (Stateful FAB עם expand/collapse).
- **🐛 Top-of-screen UX** (4 שיפורים שזוהו, לא יושמו):
  1. היררכיה הפוכה — "21 פריטים" בולט יותר מ-"2 התראות" (צריך הפוך).
  2. הצ'יפ "אכ"/"רכ" העגול הסגול לא ברור (avatar? filter?). צריך אייקון ברור או label מלא.
  3. כפתור הארכיון בצד ימין גדול מדי ל-AppBar action — אולי ב-overflow menu ⋮.
  4. אייקון החיפוש לא נראה כ-button (אין background/container) — tap target קטן.
- **🐛 Out-of-stock viz** — פריט עם `quantity == 0` מקבל רקע אדום מלא על כל הפריט (loud). אופציה עדינה: border אדום בלבד / icon ⚠️ קטן ליד השם / רק הצ'יפ של הכמות באדום.
- **📅 Date format** — `DD/MM` ("5/5", "11/05") דו-משמעי בעברית/אנגלית. עדיפות: `DD/MM/YY` או `DD בחודש`. **Trigger:** sweep רוחבי של תאריכים בכל האפליקציה (גם ב-history, receipts, וכו').
- **🐛 `MyPantryScreen.pendingStockFilter` static field** — pattern smell ל-intent passing בין מסכים. (תועד מסשן Apr-29, עדיין פתוח).

### ⏳ Pending — full 12-category review
- `my_pantry_screen.dart` (1,477 שורות) — נסקר נקודתית בסשן 3/5 (chip direction, FABs) אבל לא end-to-end בצ'קליסט מלא.
- `pantry_item_dialog.dart` (1,178 שורות) — נסקר חלקית.
- `pantry_starter_preview_dialog.dart`, `pantry_product_selection_sheet.dart`, `pantry_empty_state.dart`, `pantry_suggestions.dart` — לא נסקרו.

---

## Catalog (assets/data/list_types/)

> 🧭 אחרי המיקוד-לסופר: **supermarket.json הוא הקטלוג היחיד.** 5 הקטלוגים האחרים **נמחקו** (יוני 2026) — ניקוי/QA עליהם superseded. הלוגים והטבלאות למטה נשמרים כהיסטוריה בלבד.

### 🛒 Catalog Full Cleanup — 30/4/2026

**📊 Scope:** ~116,000 products across 6 list types. User confirmed only demo users on the system, so aggressive cleanup was approved.

**✅ מה בוצע (Phases 1-6, מתומצת):** ניקוי טקסט (681 trailing dots/asterisks, 12 leading punct, 30 garbage names); re-categorization (~5,800 פריטים מ-`'כללי'`, `'כללי'` 35,971→30,170, הוסרו ~1,375 non-products); dedup ברקודים (supermarket 64, market 2) + null- ל-placeholder/empty barcodes (greengrocer 113, butcher 114, bakery 59) ול-`price:0` (181+18); תיקון schema (3 ברקודים קוראפטיים, 204+8 שמות עם פיסוק חריג, 145 brand + 264 unit values nulled, 311+1 triplets deduped).

**📊 Final state:**
| File | Items | Duplicates | Null barcodes | Null prices |
|------|------:|-----------:|--------------:|------------:|
| supermarket | 110,720 | 0 | 3 | 181 |
| pharmacy    |   1,026 | 0 | 0 | 0   |
| market      |     994 | 0 | 0 | 0   |
| butcher     |     833 | 0 | 114 | 0 |
| greengrocer |     592 | 0 | 113 | 0 |
| bakery      |     472 | 0 | 77  | 18 |
| **Total**   | **114,637** | **0** | | |

**✅ Phase 4 — Deeper text cleanup (מתומצת):** 36 bidi marks (RLE/RLM) stripped; 976 backticks → apostrophe; 114 שמות עם רווחים כפולים; **87 non-products הוסרו** (department names, coupons, deposits/פיקדון, transit subs, delivery/recycling fees, generic items).

**⏸️ Deferred (rule-based limit):**
- ~~30,170 supermarket items in `'כללי'`~~ → **24,669 (22.3%)** after Phases 7-10 manual rules.
  - **Phases 7-10 added ~5,500 manual keyword rules** based on word-frequency analysis of the remaining `'כללי'` items: candy/snack patterns, beverage brands (Pepsi, Cola, Sprite, Fanta), alcohol (סמבוקה, שיראז, ויסקי, ביפיטר, אברפלדי), electronics (USB, Type C, סוללה), supplements (כמוסות ויטמין, מגנזיום, פרובי), pet food, eggs vs chocolate-eggs, hygiene brands (Colgate, Oral-B, Pampers, טמפקס), specific salads, vegetables (כרישה, לבבות חסה), and ~50 more.
  - **5,594 items moved out of 'כללי'** in manual classification rounds. Top categories assigned: ממתקים וחטיפים (3,162), מוצרי בית (613), אלכוהול (201), משקאות (287), תבלינים ואפייה (257), קפה ותה (183), מוצרי חלב (189), בשר ודגים (129), אורז ופסטה (59), תוספי תזונה (126), קפואים (39).
  - **Remaining 22.3%** are truly diverse — single-product entries with no shared keyword across the rest of `'כללי'`. Going further needs an embedding-based classifier or a per-brand lookup table (likely 100s of distinct Israeli/global brand names).
- **2,107 supermarket names with weird capitalization** (mostly legit English brand names like "AROY-D", "M&M HIPROTEIN") — left as-is.
- **806 same-name+category pairs in supermarket** — could be different sizes/variants of the same product, or true dupes. Needs heuristic to tell them apart.
- **303 supermarket items with brand prefix in name** (e.g., name="תנובה חלב", brand="תנובה") — could strip the brand, but might over-clean if some names legitimately start with the brand for clarity. Needs review.
- **2,465 barcodes appearing in multiple list-type files** (e.g., supermarket + market both carry "אורז בסמטי DAAWAT") — by design (supermarket is the superset), not a bug.

**🎯 Pattern:** with no real users on the system, aggressive cleanup is safe — reversible via git revert. Once real users land, dedup decisions need explicit review (some "duplicates" are different products with bad source-data barcodes; merging the wrong way deletes legitimate products from someone's list).

---

## Shopping Lists Screen

### 📂 Components נגעו
- `shopping_lists_screen.dart` (1201 שורות) — כל הרשימות: חיפוש/סינון/מיון, sections פעיל+היסטוריה, pagination, FAB.
- משתמש ב-`ShoppingListTile` (מחיקה owner-only דרך תפריט 3-נקודות).

### ✅ Decisions Made (סבב 1-2, 2/6/2026)
- **חיפוש בלחיצה אחת**: היה קבור 3 לחיצות (גלולה→תפריט→sheet). קודם לאייקון חיפוש ייעודי בסרגל. התפריט מחזיק עכשיו רק סינון+מיון+ניקוי.
- **כותרת מסך highlighter**: הסרגל העליון היה ריק (בלי הקשר כשמשמש כטאב). נוספה "כל הרשימות" בסגנון highlighter cyan.
- **היררכיית כותרת (סבב 2 — ביקורת עצמית)**: הכותרת החדשה הייתה `kFontSizeLarge` (20) — זהה ל-section headers, גם cyan. שונתה ל-`kFontSizeXLarge` (28) — magnitude ×1.4 שמבדיל "כותרת עמוד" מ"כותרת סקציה" בלי לשבור את שפת ה-highlighter.
- **Badge סינון מדויק**: ה-pill נדלק רק על סינון/מיון (`hasFilterOrSort`), לא על חיפוש — לחיפוש יש אייקון מואר משלו.
- **🔍 Source-vs-symptom — מחיקה ללא-בעלים**: לא נוסף snackbar. ה-`ShoppingListTile` כבר מסתיר את אפשרות המחיקה בתפריט כש-`onDelete=null`. אין כשל שקט.
- **Hygiene**: `errorBuilder` על איור ה-empty (כמו dashboard/notifications) + `_kEmptyIllustrationSize`; magic alphas→tokens (`0.6`→`onSurfaceVariant`, `0.5`→`kOpacityMedium`, `0.8`→`kOpacityHigh`, `0.12`→`kOpacitySubtle`); תיקון הערת כותרת מיושנת ("swipe-to-delete"→menu).

### ⏸️ Deferred
- **📊 מיון לא חל על היסטוריה**: `_getFilteredAndSortedCompletedLists` תמיד ממיין לפי `updatedDate`, מתעלם מ-`_sortBy`. מרוכך ע"י subtitle "(לפי עדכון אחרון)". **Trigger:** אם משתמש מתלונן שמיון "לפי שם/תקציב" לא משפיע על היסטוריה. **המלצה:** להשאיר (ה-subtitle מסביר).
- **⚡ `ListView(children:)` לא-עצל + רשימות פעילות ללא pagination**: כל הכרטיסים נבנים מיידית. תקין לשימוש טיפוסי (מעט רשימות). **Trigger:** אם משתמש עם 50+ רשימות פעילות חווה jank. **היקף:** בינוני (refactor ל-builder עם sections).
- **🗄️ `statusArchived` רדום**: המודל תומך ב-archived אבל אין פעולת ארכוב פעילה, והמסך מציג רק active/completed. **Trigger:** אם יוסיפו feature ארכוב — לוודא שהמסך לא מסתיר אותן בשקט.
- **💀 Skeleton בלי section headers**: `SkeletonListView` רשימה שטוחה; ה-layout הטעון מתחיל ב-header. קפיצה קלה (מרוכך ע"י fadeIn). **Trigger:** אם נראה קפיצה.

---

## Shopping List Details Screen

### 📂 Components נגעו
- `shopping_list_details_screen.dart` (1271 שורות) — הוספת/עריכת פריטים: חיפוש, סריקת ברקוד, הוספה חופשית, קיבוץ לפי קטגוריה, הרשאות, התחל-קנייה.
- נקרא מ-`/populate-list` + `/list-details` (יצירה, רשימות, התראות).

### ✅ Decisions Made (סבב 1, 2/6/2026)
- **🐛 הסרת `Directionality(rtl)` מקובע (BUG fix)**: שורה 474 כפתה RTL על כל המסך → שבר English/LTR layout, והפך את ה-chevron ב-`_buildPlanningCard` (`Directionality.of(context) == rtl ? ...`) לקוד מת (תמיד RTL). הוסר → ה-layout עוקב אחרי ה-locale הגלובלי, וה-chevron חזר לחיים. אושר ע"י המשתמש שהאפליקציה אמורה לתמוך ב-LTR.
- **🐛 הערת FAB מיושנת**: "לחיצה קצרה=מוצר, ארוכה=משימה" בעוד שיש 2 FABs נפרדים. תוקנה לתיאור הנכון.
- **⚡ O(n²) → O(n)**: `currentList.items.indexOf(item)` בתוך ה-builder של הקיבוץ הוחלף ב-`indexById` map שנבנה פעם אחת.
- **📏 רוחב strip עקבי**: `width: 3` (item) → `kSpacingXTiny` (=4, תואם ל-strip של כותרת הקטגוריה).
- **🎨 Token alignment**: `0.5`→`kOpacityMedium` (hero icon bg, allChecked text), `0.2`→`kOpacityLow` (title highlight).

### ⏸️ Deferred
- **🌍 CROSS-CUTTING: `Directionality(rtl)` מקובע ב-14 קבצים נוספים** — אותו באג. נמצא ב: `template_preview_dialog`, `contact_selector_dialog`, `template_picker_dialog`, `pending_invites_screen`, `invite_users_screen`, `my_pantry_screen`, `pantry_empty_state`, `pending_requests_screen`, `add_location_dialog`, `product_selection_bottom_sheet`, `pantry_item_dialog`, `pantry_starter_preview_dialog`, `pantry_product_selection_sheet`. **Trigger:** sweep מתואם (קובץ-קובץ, כל אחד דורש בדיקה שאין raw `right`/`left` שהסתמך על RTL). **היקף:** בינוני-גדול. **לא לעשות בבת אחת בלי הרצה.**
- **🎨 Colored glow shadows** (`0.35`/`0.4`/`0.3` alpha על FAB/CTA shadows) — premium tuning מכוון, לא tokens. נשמר.
- **🟡 שני FABs מוערמים** — מוצר (גדול צהוב) + משימה (קטן ציאן). אין תוויות גלויות; tooltip בלבד. סיכון מיס-טאפ קל. **Trigger:** אם משתמשים מתבלבלים. **המלצה:** לשקול label זעיר או הפרדה.
- **📂 קיבוץ קופץ ב-≥3 פריטים** — מעבר מרשימה שטוחה לקטגוריות. **Trigger:** אם המעבר מרגיש חד.

---

## Shopping List Details — Task Dialog

### 📂 Components נגעו
- `lib/widgets/shopping/add_edit_task_dialog.dart`
- `lib/l10n/app_strings_he.dart` / `app_strings_en.dart`

### ✅ Decisions Made (19/5/2026)
- **Priority labels: ordinal → semantic** — `low/medium/high` ("נמוכה/בינונית/גבוהה") was ambiguous; "בינונית" doesn't translate to an action. Renamed to **רגיל / חשוב / דחוף** (he) and **Normal / Important / Urgent** (en). Emoji prefix preserved (🟢/🟡/🔴).
- **Removed double visual indicator** — dropdown previously showed both a colored `Container(shape: circle)` and an emoji-prefixed label = the same signal twice. Container removed; emoji-in-string is the sole indicator.
- **Quick-pick chips for due date** — 4 `ChoiceChip`s (היום / מחר / סוף השבוע / השבוע הבא) above the calendar tile. Friday = end-of-week, Monday = next-week; if today is already past Friday, the chip rolls to next Friday.
- **Smart date display** — when the picked date is today or tomorrow, the tile renders "היום"/"מחר" instead of "10/05/2026" (digits-only kept the user doing mental math).
- **Date format trimmed** — `dd/MM/yyyy` → `d/M/yy` (matches the CLAUDE.md "5/5/26 over 5/5" lesson — shorter and the year disambiguates ordering).
- **Hygiene fixes applied (parity with `add_edit_product_dialog.dart`)**:
  - Hardcoded `import 'dart:ui'` + `textDirection: rtl` removed (broke English input).
  - Shared `_onFocusChange` split into per-node `_onFocusGained(node)` — Tab between fields fired haptic twice; now fires once.
  - `_showErrorSnackBar` added `..removeCurrentSnackBar()`.
  - Magic numbers → local constants (`_kMaxNameLength`, `_kFocusShadowBlur`, `_kFocusShadowOffset`, `_kInputFillAlpha`, `_kInputBorderAlpha`, `_kFocusedBorderWidth`, `_kStaggerStepMs`, `_kEntryAnimDuration`).
  - `Color(0xFF388E3C)` raw hex → `kStickyGreen`.
  - `withValues(alpha: 0.5/0.55/0.6/0.12)` → `kOpacity*` constants.
  - Double `Semantics(button: true)` on StickyButtons removed (StickyButton announces its own role).
  - `onSubmitted` chains name → notes for keyboard "next" arrow.
  - `maxLength: 80` + counter at ≥70 chars (matches product dialog).
  - Animation timing aligned with product dialog (300ms duration, 40ms stagger).

### ⏸️ Deferred (large items)
- **🔔 Reminders / Push Notifications for tasks** — biggest UX gap on the dialog. A task created today for 5/6 won't surface unless the user opens the list. Wiring `NotificationsService` (already exists, used for invites/low-stock/expiry) to also schedule a local notification for `dueDate - X hours` is the right move, but full feature includes: timezone math, snooze, dismiss, notification settings per task, deletion when the task completes. Touches `shopping_list_details_screen.dart`, `notifications_service.dart`, AndroidManifest permissions, iOS notification entitlements. **Trigger:** when a user complains about forgotten tasks, or when notification settings UI gets built. **Size:** large (multi-file feature, separate session).
- **Task duplication** — `isRecurring`-style toggle for "every week tidy the kitchen". Not in the current dialog; would be a new field on `UnifiedListItem` (task case). **Trigger:** user request, or pattern detection in shopping_patterns_service. **Size:** medium.

---

## Conventions

- **Trigger** — איזה קובץ עתידי יחזיר את הפריט הזה לדיון.
- **היקף** — קטן (פחות מ-20 שורות), בינוני (מספר קבצים), גדול (refactor מסך מלא).
- **מקור** — אופציונלי, אם רוצים לקשר ל-commit ספציפי.
