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

### ⏳ Files of this screen — pending review
- ~~`pending_invites_banner.dart`~~ ✅ **נסקר** ב-29/4/2026 — Reference quality, אין ממצאים
- ~~`action_center_card.dart`~~ ✅ **נסקר** ב-29/4/2026 (r1: chevron RTL + bottom sheet theme cleanup; r2: Hebrew plurals + Row→Wrap + context.select)
- ~~`last_chance_banner.dart`~~ ✅ **נסקר** ב-29/4/2026 — **הועבר** ל-`shopping/active/widgets/` (היה ב-`home/dashboard/widgets/` בטעות) + `kMinTapTarget` cleanup
- ~~`active_shopper_banner.dart`~~ ✅ **נסקר** ב-29/4/2026 (context.select + uncheckedCount==0 CTA + snackbar dedup + copywriting)
- ~~`onboarding_tips_card.dart`~~ ✅ **נסקר** ב-30/4/2026 (tooltip clarity + RTL slide + opacity rationale)
- ~~`household_activity_feed.dart`~~ ✅ **נסקר** ב-30/4/2026 (tab nav fix + context.select + bidi + decorative image)
- ~~`suggestions_today_card.dart`~~ ✅ **נסקר** ב-30/4/2026 (loading height + a11y dedup + RTL slide + dot constants + alpha rationale)

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

### 🎯 `pending_invites_banner.dart` — Reference Decisions
- **`static final _service = PendingInvitesService()`** — instance singleton, לא נוצר מחדש כל build.
- **`context.select<UserContext, String?>((u) => u.userId)`** — minimal rebuild, רק על userId change.
- **StreamBuilder עם initialData** + silent hide on stream error (debugPrint רק ב-kDebugMode).
- **Type-aware UI** (list vs household): `titleListInvite` / `titleHouseholdInvite` + 3-tier groupName fallback (household_name → group_name → list_name) עם הערה מסבירה buggy histroy.
- **Composed A11y**: `Semantics(button: true, label: composed)` סביב הבאנר + `ExcludeSemantics` על Icon + Column הפנימי. Single announcement במקום 3.
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

**✅ Decisions Made:**
- **A11y**: `Semantics(label: loadingLabel, excludeSemantics: true)` סביב ה-Loading Indicator — מונע מקורא מסך לקרוא את ה-cycling messages כל 2 שניות. אותו pattern של `loading_overlay.dart`.
- **Token alignment**: 2× alpha → kOpacity:
  - Logo shadow: 0.2 → `kOpacityLow`
  - Error card border: 0.3 → `kOpacityLight`
- **Native splash → Flutter handoff** מטופל: ה-bg color תואם בדיוק את הקובץ של flutter_native_splash.
- **5 layers of animation** (logo elastic + pulse + shimmer + wave + message rotation) עם RepaintBoundary לבידוד.
- **WavePainter optimization**: `_kWaveStepPx = 2.0` עם הערה "1px is overkill, 2px is identical visually".

**⏸️ Deferred:**
- **Cross-file: cycling messages duplicates `loading_overlay.dart` pattern** — פרמטרים שונים (2000ms vs 1500ms, אנימציה שונה). לא דחוף לאיחוד. **Trigger:** sweep של auth-bootstrap loading widgets.

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

### ⏸️ Deferred
- **`_showStatus` כפילות עם register_screen** — שני העתקים כמעט זהים של snackbar configuration. **Trigger:** סקירה ייעודית של auth shared utilities. **היקף:** קטן (extract ל-`auth_snackbar_utils.dart` או דומה).
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

---

## Auth Screens (Register)

### 📂 Components נגעו
- `register_screen.dart` (885 שורות) — סקירה מלאה של 12 קטגוריות

### ✅ Decisions Made
- **Inclusive copy**: `registerSubtitle` (Hebrew) — "קניות משפחתיות" → "ניהול הקניות". האנגלית כבר הייתה ניטרלית ("Join the smarter way to shop"), לא נגענו.
- **Snackbar dedup**: `_showStatus` עכשיו מסיר snackbar קודם לפני שמציג חדש — אותו pattern של 5+ קבצים אחרים בסשן.
- **Token alignment**: alpha 0.3 על shadow של register button → `kOpacityLight`.
- **Source-vs-Symptom**: `_askHouseholdName` כבר מתקן את "ללא שם" ב-source (auto-name `MemoZap-XXXX` על Skip — בוצע בסשן קודם).

### ⏸️ Deferred
- **`_askHouseholdName` משתמש ב-raw `showDialog`** במקום `AppDialog.show`. כל שאר הדיאלוגים באפליקציה כבר עברו ל-AppDialog. **שאלה עיצובית פתוחה:** האם לאחד עם `showEditHouseholdNameDialog` (ה-shared dialog שעבדנו עליו) — הם דומים אבל ב-intent שונה (post-register עם Skip vs edit עם Cancel). **Trigger:** סקירה של edit_household_name_dialog או דיון מודע על איחוד הדיאלוגים. **היקף:** קטן-בינוני.
- **`_phoneRegex` Israeli-only** (`^05[0-9]-?[0-9]{7}$`). בסדר ל-launch בעברית, אבל אם האפליקציה תתרחב ל-locales אחרים — צריך לוקאל-aware. **Trigger:** הוספת locale חדש או דרישות בינ"ל. **היקף:** קטן.
- **`textDirection: TextDirection.rtl` מקובע ב-`_askHouseholdName`** (שורה 135). משתמש דובר אנגלית שמקליד "Smith family" יראה את זה RTL. **Trigger:** locale-awareness sweep. **היקף:** קטן.
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
