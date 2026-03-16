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
| 4 | ליטוש UX | 🟡 חלקי |
| 5 | הכנה ל-Store | 🟡 חלקי |
| 6 | Push Notifications (FCM) | ⬜ טרם התחיל |
| 6.5 | ניהול משפחה מלא | ✅ הושלם |
| 7 | מוניטיזציה | ⬜ טרם התחיל |
| 8 | בדיקות | ✅ הושלם (335 tests) |
| 9 | i18n + נגישות | 🟡 חלקי (~80% strings extracted) |
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
- [x] Architecture cleanup — AuthUser/SocialLoginResult DTOs, removed firebase_auth from providers

### נשאר
- [ ] פיצול קבצים גדולים: my_pantry (1,477), settings (1,471), shopping_lists_screen (1,187), shopping_list_details (1,136), shopping_lists_provider (1,196), auth_service (1,001)

---

# 📍 Phase 4 — ליטוש UX 🟡

### הושלם
- [x] Page Transitions, AppDialog
- [x] Welcome Screen redesign — Carousel + sticky CTA + Gemini illustrations
- [x] Dashboard — avatar, quick actions, monthly summary
- [x] Pantry — summary strip, professional item rows, category strips
- [x] Settings — gradient profile, theme cards, staggered animations
- [x] History — AnimatedCounter, themed chips
- [x] Auth screens cleanup
- [x] Tutorial — 8 detailed steps
- [x] 8 Gemini watercolor illustrations
- [x] StatusColors → theme-aware
- [x] Empty state illustrations

### נשאר
- [ ] AnimatedList, Slivers, Hero animations
- [ ] Lottie animations (confetti, empty cart, error)

---

# 📍 Phase 5 — הכנה ל-Store 🟡

### הושלם
- [x] Package name: `com.memozap.app`
- [x] Firebase config + SHA keys
- [x] Privacy policy + Terms (Hebrew)
- [x] Demo data — 11 users in production Firebase
- [x] Store listing draft

### נשאר
- [ ] 🔑 Release keystore (needs Windows)
- [ ] 🎨 App icons (1024×1024)
- [ ] 📱 Store screenshots
- [ ] 📜 Privacy policy URL (GitHub Pages)

---

# 📍 Phase 6 — Push Notifications (FCM) ⬜
> טרם התחיל — נדרש לפני השקה

- [ ] Firebase Cloud Messaging setup
- [ ] Cloud Functions for triggers (shopping activity, household changes)
- [ ] Notification channels (Android)
- [ ] Deep links from notifications
- [ ] Settings toggles connected to FCM topics

---

# 📍 Phase 6.5 — ניהול הבית ✅
> הושלם

- [x] "משפחה" → "בית" across all UI
- [x] Invite to household flow
- [x] Members screen with roles
- [x] Real-time sync (watchInventory stream)
- [x] Shared inventory per household
- [x] Firestore rules for household access

---

# 📍 Phase 7 — מוניטיזציה ⬜

- [ ] google_mobile_ads integration
- [ ] Rewarded ads before shopping start
- [ ] Ad placement strategy

---

# 📍 Phase 8 — בדיקות ✅
> הושלם 15 מרץ 2026

- [x] **335 unit tests passing** — models, services, providers, performance
- [x] 3 demo personas (FamilyShopper, HeavyOrganizer, UnstableConnection)
- [x] Hand-written mocks (no mockito)
- [ ] Widget tests (0) — nice to have
- [ ] Integration tests (0) — nice to have
- [x] E2E test guide: `docs/E2E_TEST_GUIDE.md`

---

# 📍 Phase 9 — i18n 🟡
> בתהליך

- [x] i18n infrastructure — AppStrings proxy, HE base, EN extends HE
- [x] LocaleManager with SharedPreferences persistence
- [x] Language toggle in Settings (🇮🇱/🇺🇸)
- [x] ~80% of strings extracted to AppStrings
- [ ] ~20% remaining hardcoded Hebrew in screens
- [ ] Full English mode testing

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
| B16 | Hardcoded Hebrew in pantry dialogs | 🟢 i18n |

*כל שאר הבאגים (B1-B15, B17) נפתרו.*

---

# 🔑 החלטות מפתח

- **Colors.transparent נשאר** — אין theme equivalent
- **Package name:** `com.memozap.app`
- **Proxy pattern for i18n** — 0 changes at 724+ call sites
- **`@JsonKey(defaultValue: '')` over nullable** — non-nullable models
- **Hand-written mocks** — no mockito dependency
- **supermarket.json cleaned** — 7,250 items, 29 categories, no duplicates
- **Firestore rules v4.2** — 4 security fixes deployed
- **Single-class large files deferred** — pantry, settings, providers
