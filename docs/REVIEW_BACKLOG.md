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
- `pending_invites_banner.dart` (245 שורות)
- `action_center_card.dart` (302)
- `last_chance_banner.dart` (348)
- `onboarding_tips_card.dart` (409)
- `active_shopper_banner.dart` (510)
- `household_activity_feed.dart` (500)
- `suggestions_today_card.dart` (999) — האחרון, הכי גדול

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
