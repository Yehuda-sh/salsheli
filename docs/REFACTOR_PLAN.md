# 📋 תוכנית מלאה — MemoZap: מקוד לחנות

> נוצר: 8 מרץ 2026
> עודכן: 16 מרץ 2026
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
| 8 | בדיקות | ✅ הושלם (335 tests) |
| 9 | i18n + נגישות | 🟡 חלקי (~85% extracted) |
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
- [x] Widgets משותפים — AppSnackBar, EmptyState, SectionHeader

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
- [x] Demo data — **12 users** in production Firebase (all edge cases)
- [x] Store listing draft
- [x] Firestore security rules v4.2 — 4 security fixes deployed

### נשאר
- [ ] 🔑 Release keystore (needs Windows — יהודה)
- [ ] 🎨 App icons (1024×1024 — יהודה)
- [ ] 📱 Store screenshots (needs device — יהודה)
- [ ] 📜 Privacy policy URL (GitHub Pages deploy)

---

# 📍 Phase 6 — Push Notifications (FCM) ⬜
> טרם התחיל — **אפשר להשיק בלי**

- [ ] Firebase Cloud Messaging setup
- [ ] Cloud Functions for triggers
- [ ] Notification channels (Android)
- [ ] Deep links from notifications
- [ ] Settings toggles connected to FCM topics

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

---

# 📍 Phase 7 — מוניטיזציה ⬜
> Post-launch

- [ ] google_mobile_ads integration
- [ ] Rewarded ads before shopping start
- [ ] Ad placement strategy

---

# 📍 Phase 8 — בדיקות ✅
> הושלם 15 מרץ 2026

- [x] **335 unit tests passing** — models, services, providers, performance
- [x] 3 demo personas (FamilyShopper, HeavyOrganizer, UnstableConnection)
- [x] Hand-written mocks (no mockito)
- [x] E2E test guide: `docs/E2E_TEST_GUIDE.md`
- [x] **12 demo users** covering all edge cases
- [ ] Widget tests (0) — post-launch
- [ ] Integration tests (0) — post-launch

---

# 📍 Phase 9 — i18n 🟡
> ~85% complete

- [x] i18n infrastructure — AppStrings proxy, HE base, EN extends HE
- [x] LocaleManager with SharedPreferences persistence
- [x] Language toggle in Settings (🇮🇱/🇺🇸)
- [x] ~85% of strings extracted to AppStrings (~100+ strings in this sprint alone)
- [ ] ~84 hardcoded Hebrew strings remain in ~15 files
- [ ] Full English mode testing

### קבצים עם strings חסרים (לפי כמות):
| קובץ | ~strings | סוג |
|-------|----------|-----|
| household_members_screen | ~15 | screen |
| who_brings_screen | ~8 | screen |
| household_activity_feed | ~8 | widget |
| pending_invites_screen | ~5 | screen |
| pantry_suggestions | ~12 | widget (emoji map) |
| invite_users_screen | ~3 | screen |
| home_dashboard_screen | ~2 | screen |
| checklist_screen | ~2 | screen |
| loading_overlay | ~3 | auth (debug only) |
| quick_login_bottom_sheet | ~3 | auth (debug only) |
| pending_invites_banner | ~2 | widget (unused) |

---

# 📍 Phase 10 — השקה ⬜

- [ ] Build APK (release keystore needed)
- [ ] Dog-fooding on real device
- [ ] Beta testing
- [ ] Google Play submission
- [ ] Crash rate monitoring

---

# 🐛 באגים פתוחים

| ID | תיאור | חומרה |
|----|--------|--------|
| W1 | `use_build_context_synchronously` ×2 in settings_screen | 🟢 |

*כל שאר הבאגים (B1-B17) נפתרו.*

---

# 🔑 החלטות מפתח

- **Colors.transparent נשאר** — אין theme equivalent
- **Package name:** `com.memozap.app`
- **Proxy pattern for i18n** — 0 changes at 724+ call sites
- **`@JsonKey(defaultValue: '')` over nullable** — non-nullable models
- **Hand-written mocks** — no mockito dependency
- **supermarket.json cleaned** — 7,250 items, 29 categories, no duplicates
- **Firestore rules v4.2** — 4 security fixes deployed
- **Single-class large files deferred** — post-launch
- **FCM push not required for launch** — in-app notifications work
- **12 demo users** — including fresh user for empty states
- **Onboarding removed** — -3,258 lines, welcome screen still works via seenOnboarding

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
