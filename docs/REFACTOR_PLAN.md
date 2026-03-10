# 📋 תוכנית מלאה — MemoZap: מקוד לחנות

> נוצר: 8 מרץ 2026
> עודכן: 10 מרץ 2026
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
| 7 | מוניטיזציה | ⬜ טרם התחיל |
| 8 | בדיקות | ⬜ טרם התחיל |
| 9 | i18n + נגישות | ⬜ טרם התחיל |
| 10 | השקה | ⬜ טרם התחיל |

---

# 📍 Phase 1 — ניקוי ויציבות ✅
> הושלם 8 מרץ 2026

- [x] **1.1 מחיקת קוד מת** — 15 קבצים, -6,530 שורות. Commit `5671f0c`
- [x] **1.2 ניקוי קבועים מתים** — 22 קבועים/פונקציות, -118 שורות. Commits `8ec024d`, `401cea0`, `07fc19c`
- [x] **1.2 ניקוי debug prints** — 852 prints מ-59 קבצים, -929 שורות. רק kDebugMode-guarded נשארו. Commit `fe549cd`
- [x] **1.3 איחוד emoji** — `_getCategoryEmoji` → global `getCategoryEmoji`. Commit `cda0160`
- [x] **1.3 אופטימיזציית תמונות** — logo.png 4.7MB → logo.webp 127KB; snichel.png 822KB → snichel.webp 29KB (-97%). Commit `4e20ed1`
- [x] **l10n cleanup** — 233 מחרוזות מתות הוסרו מ-app_strings.dart (2,932→2,661 שורות)

---

# 📍 Phase 2 — מערכת עיצוב אחידה ✅
> הושלם 8 מרץ 2026

- [x] **2.1 Design Tokens** — `lib/theme/design_tokens.dart`. Commit `3129011`
- [x] **2.2 Context Extensions** — `lib/theme/context_extensions.dart`. Commit `3129011`
- [x] **2.3 Colors.xxx → theme** — 316→0 (רק 42 Colors.transparent נשארו — אין theme equivalent). Commits `f6335a0`→`da51a8d`
- [x] **2.4 Typography** — 134 hardcoded fontSize → 8 kFontSize constants. Commit `8b08d64`
- [x] **2.5 Border Radius** — 97 ערכים → 4 (Small/Default/Large/XLarge). Commit `c262f6a`
- [x] **2.6 Widgets משותפים** — AppSnackBar, EmptyState, SectionHeader. Commit `c94a363`

---

# 📍 Phase 3 — איחוד סגנון + ריפקטור מבני 🟡
> חלקי — בתהליך

### הושלם
- [x] **3.1 NotebookBackground** — הוסף ל-pantry, settings, manage_users — כעת 21/21 מסכים. Commit `a193602`
- [x] **3.2 פיצול active_shopping_screen** — 2,024→1,132 שורות. Commit `eabcd15`
  - `active_shopping_item_tile.dart`, `active_shopping_states.dart`, `shopping_summary_dialog.dart`
- [x] **3.2 פיצול login_screen** — 1,157→802 שורות. Commit `2c75131`
  - `quick_login_bottom_sheet.dart`, `social_login_button.dart`, `loading_overlay.dart`
- [x] **Header cleanup** — 15 widget files cleaned of outdated headers

### נשאר
- [ ] פיצול `my_pantry_screen.dart` (1,330 שורות)
- [ ] פיצול `settings_screen.dart` (1,222 שורות)
- [ ] פיצול `shopping_lists_screen.dart` (1,200 שורות)
- [ ] פיצול `shopping_list_details_screen.dart` (1,065 שורות)
- [ ] פיצול `shopping_lists_provider.dart` (1,520 שורות)
- [ ] פיצול `auth_service.dart` (1,159 שורות)
- [ ] העברת ~101 מחרוזות hardcoded ל-AppStrings (נדחה ל-Phase 8 i18n)

---

# 📍 Phase 4 — ליטוש UX מקצועי 🟡
> חלקי — בתהליך

### הושלם
- [x] **Page Transitions** — `lib/theme/app_transitions.dart`. Commit `eae0906`
- [x] **AppDialog** — `lib/widgets/common/app_dialog.dart`. Commit `eae0906`
- [x] **Welcome Screen redesign** — Carousel PageView + sticky CTA + Gemini illustrations (5.5→8/10). Commit `a269cab`
- [x] **Dashboard avatar** — באנר ברכה → avatar קומפקטי + bottom sheet. Commit `386a415`
- [x] **suggestions_today_card** — `_cleanProductName()` לניקוי שמות מוצרים
- [x] **Settings screen redesign** — gradient profile, theme cards, SectionHeaders, staggered animations, themed toggles. Commit `10273b9`
- [x] **History screen polish** — AnimatedCounter, themed chips, better empty state, rounded cards. Commit `1d8823e`
- [x] **Auth screens cleanup** — cancel handling, StatusType enum, shared widgets (-130 lines), constants. Commit `bf499e4`

### נשאר
- [ ] AnimatedList (רשימת קניות)
- [ ] Slivers / Collapsing AppBar
- [ ] Splash screen (`flutter_native_splash`)
- [ ] Lottie animations (confetti, empty cart, error)
- [ ] Hero animations
- [ ] Micro-interactions (bounce, strikethrough animation)

---

# 📍 Phase 5 — הכנה ל-Store 🟡
> חלקי — בתהליך

### הושלם
- [x] **שם חבילה** — `com.example.memozap` → `com.memozap.app`. Commit `bd8d772`
- [x] **iOS Permissions** — NSContactsUsageDescription + NSCameraUsageDescription. Commit `bd8d772`
- [x] **Firebase config** — google-services.json עם שני package names. Commits `3f1ecc2`, `0426be5`
- [x] **Demo data** — households + members + user docs מתוקנים. Commit `e1523d2`

### נשאר
- [ ] 🔑 Release keystore (חתימה לפרודקשן)
- [ ] 🎨 App icons (flutter_launcher_icons, 1024×1024)
- [ ] 🖼️ Splash screen (flutter_native_splash)
- [ ] 🛡️ ProGuard/R8 rules
- [x] 📜 Privacy policy + Terms — תוכן מקצועי מלא (Hebrew). Commit `93c799f`
- [ ] 📜 Privacy policy + Terms — URL נגיש (דף נחיתה / GitHub Pages)
- [ ] 📱 Store listing (screenshots, descriptions, feature graphic)
- [x] 🔄 Firebase config — SHA-1 + SHA-256 added, google-services.json updated. Commit `0db1ad7`
- [x] 🔧 `/pending-invites` route added. Commit `93c799f`
- [x] 🔧 About dialog — "MemoZap" + app icon. Commit `93c799f`
- [x] 🔧 3 analyzer errors fixed (0 errors project-wide). Commit `93c799f`

---

# 📍 Phase 6 — Push Notifications (FCM) ⬜
> טרם התחיל — **נדרש לפני השקה**

### 6.1 תשתית FCM
- [ ] הגדרת FCM ב-Firebase Console (Android + iOS)
- [ ] הוספת `firebase_messaging` package
- [ ] שמירת FCM token של כל משתמש ב-Firestore (`users/{uid}/fcm_tokens`)
- [ ] רענון token אוטומטי (onTokenRefresh)
- [ ] טיפול ב-foreground / background / terminated notifications

### 6.2 Cloud Functions — שליחת התראות
- [ ] **התראות קנייה** — Cloud Function על שינוי `status` ב-`shopping_lists` → שולח push לכל חברי הקבוצה
- [ ] **התראות מלאי** — Scheduled Function (יומי) שבודק `inventory` items עם `quantity <= threshold` → push לבעל המזווה
- [ ] **התראות קבוצה** — Cloud Function על הוספת member ל-`households/{id}/members` → push לכל החברים הקיימים

### 6.3 חיבור המתגים בהגדרות
- [ ] חיבור `_notifyShopping` / `_notifyInventory` / `_notifyGroup` ל-FCM topics
- [ ] Subscribe/unsubscribe לפי topic כשהמתג משתנה
- [ ] שמירת העדפות גם ב-Firestore (לסנכרון בין מכשירים)

### 6.4 UX התראות
- [ ] Notification channels ב-Android (קנייה / מלאי / קבוצה)
- [ ] Deep links — לחיצה על התראה פותחת מסך רלוונטי
- [ ] Badge count ב-app icon
- [ ] בדיקה על מכשיר פיזי (אמולטור לא תומך FCM)

---

# 📍 Phase 7 — מוניטיזציה ⬜
> טרם התחיל

- [ ] google_mobile_ads integration
- [ ] Rewarded ads לפני תחילת רשימה
- [ ] Ad placement strategy

---

# 📍 Phase 8 — בדיקות ואיכות ⬜
> טרם התחיל

- [ ] Unit tests (יעד: 50 על providers + services)
- [ ] Widget tests (יעד: 20 על מסכים קריטיים)
- [ ] Integration tests (יעד: 3-5 flows)
- [ ] Firebase Performance Monitoring

---

# 📍 Phase 9 — i18n + נגישות ⬜
> טרם התחיל

- [ ] i18n infrastructure (l10n.yaml)
- [ ] עברית (he) + אנגלית (en)
- [ ] ~101 מחרוזות hardcoded → AppStrings
- [ ] Semantics labels
- [ ] WCAG AA contrast

---

# 📍 Phase 10 — השקה ⬜
> טרם התחיל

- [ ] Beta testing (Internal + TestFlight)
- [ ] ASO (App Store Optimization)
- [ ] Soft launch (ישראל בלבד)
- [ ] Crash rate < 1% → הרחבה

---

# 🐛 באגים ידועים

| ID | תיאור | חומרה | סטטוס |
|----|--------|--------|--------|
| B1 | pending_requests approve/reject | ✅ | נפתר — `3a1bf09` |
| B2 | notification navigation | ✅ | נפתר — `3a1bf09` |
| B3 | SavedContactsService silent errors | ✅ | נפתר — `f559312` |
| B4 | Firebase config mismatch | ✅ | נפתר |
| B5 | addStock ignores non-pantry products | ✅ | נפתר — `877a488` |
| B6 | shouldUpdatePantry blocks private lists | ✅ | נפתר — `877a488` |
| B7 | lastUpdatedBy missing → Firestore rules block | ✅ | נפתר — `877a488` |
| B8 | `/pending-invites` route missing → crash | ✅ | נפתר — `93c799f` |
| B9 | `cs` shadowed in history `_buildItemRow` | ✅ | נפתר — `1d8823e` |
| B10 | 3 analyzer errors (activeThumbColor, initialValue×2) | ✅ | נפתר — `93c799f` |
| B11 | `pending_invites` PERMISSION_DENIED on login | 🟡 | Firestore rules — collection may not exist |

---

# 📁 קבצים חדשים שנוצרו

```
lib/theme/
├── app_transitions.dart
├── design_tokens.dart
└── context_extensions.dart

lib/widgets/common/
├── app_snack_bar.dart
├── app_dialog.dart
├── empty_state.dart
└── section_header.dart

lib/screens/shopping/active/widgets/
├── active_shopping_item_tile.dart
├── active_shopping_states.dart
└── shopping_summary_dialog.dart

lib/screens/auth/widgets/
├── quick_login_bottom_sheet.dart
├── social_login_button.dart
└── loading_overlay.dart

assets/images/
├── onboarding_shopping.webp
├── onboarding_pantry.webp
└── onboarding_sharing.webp
```

---

# 🔑 החלטות מפתח

- **Colors.transparent נשאר** — 42 instances, אין theme equivalent
- **Debug prints:** הוסרו כולם; רק kDebugMode-guarded + debugPrintStack נשארו
- **Font sizes:** 9→Tiny, 11→Small, 13→Medium, 15→Body, 18/22/24→Title, 32/36→Display
- **Border radius:** 2-10→Small(8), 12-14→Default(12), 16-20→Large(16), 24→XLarge(24)
- **Carousel over scroll:** 3 feature cards in PageView — מפחית cognitive load
- **Sticky CTA:** Bottom bar with blur תמיד visible — קריטי ל-conversion
- **Package name:** `com.memozap.app` (display: MemoZap)
- **Hardcoded Hebrew strings (101) נדחו ל-Phase 8** (i18n)
- **Single-class large files נדחו** — pantry, settings, shopping_lists, details
- **Provider/service splitting נדחה** — shopping_lists_provider, auth_service
- **`avoid_print: error`** — enforced since all production prints cleaned

---

# ⏱️ לוח זמנים מעודכן

```
שבוע 1:   ✅ Phase 1 — ניקוי
שבוע 2:   ✅ Phase 2 — design system
שבוע 2-3: 🟡 Phase 3 — איחוד סגנון (חלקי)
שבוע 3-4: 🟡 Phase 4 — ליטוש UX (חלקי)
שבוע 4-5: 🟡 Phase 5 — Store prep (חלקי)
שבוע 5-6: ⬜ Phase 6 — Push Notifications (FCM) 🆕
שבוע 6-7: ⬜ Phase 7 — מוניטיזציה
שבוע 7-8: ⬜ Phase 8 — טסטים
שבוע 8-9: ⬜ Phase 9 — i18n
שבוע 9-10: ⬜ Phase 10 — השקה
```
