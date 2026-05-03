# 📋 תוכנית מלאה — MemoZap: מקוד לחנות

> נוצר: 8 מרץ 2026
> עודכן: 30 אפריל 2026
> מטרה: **אפליקציה מוכנה להפצה ב-App Store + Google Play**

---

## 📊 סטטוס כללי

| פאזה | תיאור | סטטוס |
|------|--------|--------|
| 1 | ניקוי ויציבות | ✅ הושלם |
| 2 | מערכת עיצוב | ✅ הושלם |
| 3 | איחוד סגנון + ריפקטור | 🟡 חלקי |
| 4 | ליטוש UX | ✅ הושלם |
| 5 | הכנה ל-Store | 🟡 חלקי |
| 6 | Push Notifications (FCM) | ⬜ טרם התחיל |
| 6.5 | ניהול משפחה מלא | ✅ הושלם |
| 7 | מוניטיזציה | ⬜ טרם התחיל |
| 8 | בדיקות | ✅ הושלם (396 tests) |
| 9 | i18n + נגישות | 🟡 חלקי (~97% extracted + a11y sweep) |
| 10 | השקה | ⬜ טרם התחיל |

---

# 📍 Phase 1 — ניקוי ויציבות ✅
> הושלם 8 מרץ 2026

- [x] מחיקת קוד מת — 15 קבצים, -6,530 שורות
- [x] ניקוי קבועים מתים — 22 קבועים/פונקציות, -118 שורות
- [x] ניקוי debug prints — 852 prints מ-59 קבצים, -929 שורות
- [x] איחוד emoji — `_getCategoryEmoji` → global
- [x] אופטימיזציית תמונות — logo 4.7MB→127KB, snichel 822KB→29KB (-97%)
- [x] l10n cleanup — 233 מחרוזות מתות הוסרו
- [x] הסרת flow onboarding מלא — -3,258 שורות, 7 קבצים נמחקו

---

# 📍 Phase 2 — מערכת עיצוב אחידה ✅
> הושלם 8 מרץ 2026

- [x] Design Tokens, Context Extensions
- [x] Colors.xxx → theme (316→0)
- [x] Typography — 134 hardcoded → 8 kFontSize constants
- [x] Border Radius — 97 ערכים → 4
- [x] Widgets משותפים — AppSnackBar, AppErrorState, SectionHeader

---

# 📍 Phase 3 — איחוד סגנון + ריפקטור מבני 🟡

### הושלם
- [x] NotebookBackground ב-21/21 מסכים
- [x] פיצול active_shopping_screen (2,024→1,132)
- [x] פיצול login_screen (1,157→802)
- [x] Full code review — 149 files, ~57,000 lines, score 9/10
- [x] Architecture cleanup — AuthUser/SocialLoginResult DTOs
- [x] BaseProvider mixin patterns identified

### נשאר (Post-launch)
- [ ] פיצול קבצים גדולים: my_pantry (1,477), settings (1,471), shopping_lists_screen (1,187), shopping_list_details (1,136), shopping_lists_provider (1,196), auth_service (1,001)
- [ ] BaseProvider mixin — ~50 שורות כפולות ב-5 providers
- [ ] notifications_service refactor — `_createNotification()` helper

---

# 📍 Phase 4 — ליטוש UX ✅
> הושלם 16 מרץ 2026

- [x] Page Transitions, AppDialog
- [x] Welcome Screen redesign — Carousel + sticky CTA + Gemini illustrations
- [x] Dashboard — avatar, quick actions, monthly summary
- [x] Pantry — summary strip, professional item rows, category strips
- [x] Settings — gradient profile, theme cards, staggered animations
- [x] History — כרטיסים מחודשים, empty state, AnimatedCounter
- [x] Auth screens cleanup
- [x] Tutorial — 8 detailed steps
- [x] 8 Gemini watercolor illustrations
- [x] StatusColors → theme-aware
- [x] Empty state illustrations
- [x] **11 full-screen spinners → AppLoadingSkeleton** (22 button spinners kept)
- [x] **Unified notification hub** — AppBar bell = invites + notifications + low stock
- [x] **Active shopping upgrade** — Wake Lock, redesigned tiles, quantity picker, haptics
- [x] **List details redesign** — planning screen with inline catalog search + dual FABs
- [x] **Shopping summary redesign** — celebration animations, dynamic emoji
- [x] **Back-button confirmation** — PopScope in active shopping
- [x] **Last Chance Banner** — horizontal chips layout (270 lines, was 470)
- [x] **Barcode scanner** — mobile_scanner, catalog lookup, auto-mark
- [x] **PendingRequestsSection** — compact inline rows (was 458 lines → 240)

---

# 📍 Phase 5 — הכנה ל-Store 🟡

### הושלם
- [x] Package name: `com.memozap.app`
- [x] Firebase config + SHA keys
- [x] Privacy policy + Terms (Hebrew)
- [x] Demo data — **22 users** in production Firebase (all edge cases)
- [x] Store listing draft
- [x] Firestore security rules v4.5 — privilege-escalation holes patched (Apr-27 audit)

### נשאר
- [ ] 🔑 Release keystore (needs Windows — יהודה)
- [ ] 🎨 App icons (1024×1024 — יהודה)
- [ ] 📱 Store screenshots (needs device — יהודה)
- [ ] 📜 Privacy policy URL (GitHub Pages deploy)

---

# 📍 Phase 6 — Push Notifications (FCM) ⬜
> טרם התחיל — **אפשר להשיק בלי**

### 6.1 Android Setup
- [ ] הוספת `POST_NOTIFICATIONS` permission ל-AndroidManifest.xml (חובה Android 13+)
- [ ] הוספת notification channel ב-AndroidManifest (default channel + high priority)
- [ ] הוספת `<meta-data>` ל-default notification icon + color

### 6.2 FCM Token Management
- [ ] `FirebaseMessaging.instance.getToken()` — שמירת token ב-Firestore (`users/{uid}/fcmToken`)
- [ ] `onTokenRefresh` listener — עדכון token כשמשתנה
- [ ] מחיקת token ב-logout

### 6.3 Foreground / Background / Cold Start
- [ ] `onMessage` — הצגת local notification כשהאפליקציה פתוחה
- [ ] `onMessageOpenedApp` — ניווט למסך הנכון כשלוחצים על התראה (אפליקציה ברקע)
- [ ] `getInitialMessage` — ניווט כשהאפליקציה נפתחת מהתראה (cold start)
- [ ] `@pragma('vm:entry-point') onBackgroundMessage` — handler ל-background messages

### 6.4 Permission Flow
- [ ] בקשת permission מהמשתמש (popup) — אחרי onboarding, לא מיד
- [ ] fallback אם נדחה — הסבר למה חשוב + קישור להגדרות
- [ ] שמירת סטטוס permission ב-UserContext

### 6.5 Cloud Functions (Server-side triggers)
- [ ] Cloud Function: שליחת FCM כשנוצרת התראה חדשה ב-Firestore
- [ ] Triggers: הזמנה לבית, שינוי תפקיד, מלאי נמוך, רשימה שותפה עודכנה
- [ ] Batching — איחוד התראות (לא לשלוח 10 pushים ברצף)

### 6.6 Settings Integration
- [ ] Settings toggles מחוברים ל-FCM topics (השתקת סוגי התראות)
- [ ] Deep links from notifications — ניווט למסך הרלוונטי

> **הערה:** האפליקציה כבר תומכת בהתראות in-app (Firestore subcollection).
> FCM push הוא שדרוג — לא חוסם launch.

---

# 📍 Phase 6.5 — ניהול הבית ✅
> הושלם

- [x] "משפחה" → "בית" across all UI
- [x] Invite to household flow
- [x] Members screen with roles
- [x] Real-time sync (watchInventory stream)
- [x] Shared inventory per household
- [x] Firestore rules for household access
- [x] Permission hierarchy: Owner > Admin > Editor > Viewer
- [x] Editor approval flow (PendingRequests)

# 📍 Phase 6.6 — יומן פעילות (Activity Log) ✅
> הושלם 9 אפריל 2026

- [x] **Model**: `ActivityEvent` — 9 types (8 active + `unknown`), JsonSerializable
- [x] **Service**: `ActivityLogService` — fire-and-forget writes to Firestore
- [x] **Repository**: `ActivityLogRepository` — reads + cleanup
- [x] **Provider**: `ActivityLogProvider` — state management, registered in main.dart
- [x] **8 injection points**: shopping_completed/started/joined, list_created, stock_updated, member_left, role_changed (×2)
- [x] **Dashboard feed**: household_activity_feed.dart — 5 latest events + receipts fallback
- [x] **History screen**: TabBar with Receipts + Activity Log tabs
- [x] **Firestore rules**: `activity_log/{eventId}` subcollection
- [x] **AppStrings**: 9 event descriptions + UI strings (HE + EN)
- [x] **Demo data**: 27 events across 4 households (all 9 types covered)
- [x] **GitHub Action**: `rebuild-demo-data.yml` — run script from browser/phone

---

# 📍 Phase 6.8 — Screen-by-screen Review (Apr 27-30, 2026) ✅
> Continuous quality cycle — every file goes through a 12-category checklist (CLAUDE.md).

**What's been reviewed end-to-end:**
- **Cross-cutting widgets**: notebook_background, post_auth_navigation, quick_login_bottom_sheet, loading_overlay, social_login_button, legal_content_dialog, dev_banner.
- **Auth screens**: login_screen + register_screen + the new social_auth flow.
- **Bootstrap chain**: main.dart, index_screen, index_view, main_navigation_screen, app_layout, app_theme.
- **Home Dashboard (all 7 child widgets)**: pending_invites_banner, action_center_card, last_chance_banner, active_shopper_banner, onboarding_tips_card, household_activity_feed, suggestions_today_card.
- **Welcome screen** + **pantry_merge_dialog** (deferred merge logic still TODO).
- **Settings folder (Apr 30)**: edit_household_name_dialog, household_members_screen, manage_users_screen, settings_screen rounds 1-2 (round 3 = `_NotificationToggle`/`_ThemeCard` pending).

**Cross-cutting wins from this cycle:**
- New `kOpacitySoft` constant + 36 call-site sweep across 17 files.
- `SectionHeader` redesigned to highlighter style + `kHighlightOpacity` constant added.
- `last_chance_banner` relocated to its actual usage screen (`shopping/active/widgets/`).
- 9 user-perspective UX improvements applied across 4 settings screens (logout reassurance copy, delete-account shared-list impact, snackbar action button, edit-household-name subtitle, removeMemberConfirm explanation, role-toggle subtitles, role filter chips, viewer-only banner, 30s timeout on destructive awaits).
- Animation interval bug fixed in `settings_screen` — last sections were clamping to 1.0 with only 0.04s of animation; corrected math + section count.
- `docs/REVIEW_BACKLOG.md` is the cross-session memory of decisions and deferred items per screen.

# 📍 Phase 6.7 — UX Polish + A11y Sweep ✅
> הושלם 22 אפריל 2026 (סשן 6)

- [x] **Settings overhaul** — 7 commits: haptic, animations, tappable avatar + camera badge, colored icon hierarchy, pull-to-refresh, Semantics labels
- [x] **History overhaul** — 6 commits: BiDi, staggered entrance, color-coded icons, relative dates, stats gradient, receipt totals, a11y
- [x] **Welcome a11y** — staggered benefits, card semantics, chip a11y, blur token
- [x] **Auth a11y** — haptic, 44dp touch targets, Semantics
- [x] **Pantry UX** — collapsible locations, low-stock pulse, pull-to-refresh, animated quantity counter
- [x] **Global haptic choreography** + category collapse animation
- [x] **Touch targets ≥44dp** across 5 interactive areas
- [x] **Catalog sanitization** — 273+3 brand names, 2,320 stuck numbers, 327 trailing asterisks
- [x] **Lint cleanup** — 1030 `@override`, sort imports ×31, curly braces, deprecated APIs — resolves W2

---

# 📍 Phase 7 — מוניטיזציה ⬜
> Post-launch

- [ ] google_mobile_ads integration
- [ ] Rewarded ads before shopping start
- [ ] Ad placement strategy

---

# 📍 Phase 8 — בדיקות ✅
> הושלם 15 מרץ 2026, מתעדכן בכל סשן

- [x] **413 unit tests passing** — models, services, providers, performance
- [x] Hand-written mocks (no mockito)
- [x] **22 demo users** covering all edge cases (including Google/Apple/English/special chars)
- [ ] Widget tests (0) — post-launch
- [ ] Integration tests (0) — post-launch

---

# 📍 Phase 9 — i18n + נגישות 🟡
> ~97% complete (סשן 6: 18-22 אפריל 2026)

- [x] i18n infrastructure — AppStrings proxy, HE base, EN extends HE
- [x] LocaleManager with SharedPreferences persistence
- [x] Language toggle in Settings (🇮🇱/🇺🇸)
- [x] ~97% of strings extracted to AppStrings (+5 hardcoded fallbacks in סשן 6)
- [x] `@override` ל-1030 English string members (סשן 6)
- [x] **A11y sweep** (סשן 6): Semantics labels ב-settings, welcome, auth, history, carousel chips
- [x] **Touch targets ≥44dp** ב-5 קבצים (סשן 6)
- [x] **BiDi numbers**: `fixBidiNumbers` ב-4 display paths נוספים
- [ ] ~20 hardcoded Hebrew strings remain in ~8 files (post-launch)
- [ ] Full English mode manual testing

---

# 📍 Phase 10 — השקה ⬜

- [ ] Build APK (release keystore needed)
- [ ] Dog-fooding on real device
- [ ] Beta testing
- [ ] Google Play submission
- [ ] Crash rate monitoring

---

# 🐛 באגים פתוחים

| ID | תיאור | חומרה | סטטוס |
|----|--------|--------|--------|
| W1 | `use_build_context_synchronously` ×2 in settings_screen | 🟢 | יש `mounted` guards — ממתין לאימות analyzer |
| ~~W2~~ | ~~`directives_ordering` infos~~ | — | ✅ תוקן (סשן 6) — sort imports in 31 files |
| ~~B3~~ | ~~SavedContactsService בולע שגיאות~~ | — | ✅ תוקן — rethrow בכל 3 המתודות |

*כל שאר הבאגים (B1-B17) נפתרו. סשן 6 הוסיף 4 תיקוני type-safety ו-3 אינדקסי Firestore חסרים.*

---

# 🔑 החלטות מפתח

- **Colors.transparent נשאר** — אין theme equivalent
- **Package name:** `com.memozap.app`
- **Proxy pattern for i18n** — 0 changes at 724+ call sites
- **`@JsonKey(defaultValue: '')` over nullable** — non-nullable models
- **Hand-written mocks** — mockito removed from dev_dependencies
- **supermarket.json cleaned** — 7,250 items, 29 categories, no duplicates
- **Firestore rules v4.5** — Apr-27 audit fixes deployed (closed 3 privilege-escalation holes)
- **Single-class large files deferred** — post-launch
- **FCM push not required for launch** — in-app notifications work
- **16 demo users** — including Google/Apple sign-in, English user, special chars
- **Onboarding removed** — -3,258 lines, welcome screen still works via seenOnboarding
- **Activity Log** — full feature: model → service → repo → provider → UI (8 injection points)
- **GitHub Action for demo data** — `rebuild-demo-data.yml` runs from browser/phone

---

# 📋 מה צריך ל-Launch (MVP)

### חובה (blocking)
1. 🔑 Release keystore (יהודה — Windows)
2. 🎨 App icon 1024×1024 (יהודה)
3. 📱 Build APK/AAB
4. 📱 Dog-food on Galaxy S22
5. Fix critical bugs found in dog-fooding

### רצוי (nice-to-have)
1. i18n — extract remaining ~84 strings
2. Store screenshots
3. Privacy policy URL on GitHub Pages
4. Fix W1 (build_context_synchronously)

### Post-launch
1. FCM push notifications
2. File splitting (large files)
3. Widget/integration tests
4. Monetization (ads)
5. BaseProvider refactor
