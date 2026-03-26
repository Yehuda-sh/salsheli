# AGENTS.md — Claude Code Session Summary
## MemoZap — Code Review, Optimization & Feature Development
**Date:** March 26, 2026
**Branch:** `claude/dev`
**Total Commits:** ~55+

---

## 🔍 What Was Done

### Phase 1: Full Codebase Review (17 Categories × 141 Files)

Every Dart file in the project was reviewed against 17 quality categories:

| # | Category | Type |
|---|----------|------|
| 1 | Style — constants, imports, dead code | Code |
| 2 | Cross-file logic — data keys, caller/callee alignment | Code |
| 3 | Performance — rebuilds, const, RepaintBoundary | Code |
| 4 | Accessibility — Semantics, touch targets ≥48px | UI |
| 5 | Edge cases — null safety, overflow, invalid values | Code |
| 6 | Memory leaks — dispose, listeners, streams | Code |
| 7 | UX — feedback, error states, loading | UI |
| 8 | Security — data exposure, injection | Code |
| 9 | State Management — watch vs read, rebuild scope | Architecture |
| 10 | Async — race conditions, cancellation, swallowed errors | Architecture |
| 11 | DRY — duplicate patterns | Architecture |
| 12 | RTL/LTR — directional widgets, chevrons | UI |
| 13 | Responsive — overflow, small screens, keyboard | UI |
| 14 | Dark Mode — hardcoded colors, contrast | UI |
| 15 | Text Scaling — accessibility font sizes | UI |
| 16 | Animation lifecycle — dispose, cancel | UI |
| 17 | Image/Asset safety — errorBuilder, paths | UI |

---

### Phase 2: Critical Bugs Fixed

| # | Bug | File(s) | Severity |
|---|-----|---------|----------|
| 1 | **location 'general' doesn't exist** — pantry suggestions saved items with invalid location | my_pantry_screen.dart | 🔴 Data corruption |
| 2 | **isGroupMode not passed** — badge always showed "personal" even in group mode | pantry_empty_state.dart → my_pantry_screen.dart | 🔴 Logic |
| 3 | **AppStrings wrong class** — `sharing.listFallback` → `pendingInvitesScreen.listFallback` | pending_invites_banner.dart | 🔴 Compile error |
| 4 | **FCM stream no onError** — unhandled error crashes app | push_notification_service.dart | 🔴 Crash |
| 5 | **void async init** — errors silently lost | suggestions_provider.dart | 🔴 Silent failure |
| 6 | **6 TextEditingController leaks** — dialogs without dispose | settings_screen, invite_users, pending_requests, shopping_lists | 🟠 Memory leak |
| 7 | **6 NotificationsService DI bypasses** — created instances instead of using Provider | 5 screens | 🟠 Architecture |
| 8 | **2 firstWhere crash risk** — no orElse on list lookup | shopping_list_details_screen.dart | 🟠 Crash |
| 9 | **13 hardcoded dark mode colors** — _getCategoryColor not theme-aware | my_pantry_screen.dart | 🟠 Dark mode |
| 10 | **14+ RTL chevron/alignment bugs** — wrong direction in LTR | settings_screen, home_dashboard, shopping_list_details, my_pantry | 🟠 RTL |
| 11 | **2 kPaperBackground in dark mode** — light color on dark background | shopping_summary, invite_users | 🟠 Dark mode |
| 12 | **Build timestamp in production** — debug info visible to users | welcome_screen.dart | 🟡 Security |
| 13 | **Operator precedence ambiguity** — `||` vs `&&` without parentheses | inventory_provider.dart | 🟡 Logic |
| 14 | **18 error messages exposed** — `e.toString()` shown to users | 8 screen files | 🟡 UX/Security |
| 15 | **Missing Firestore index** — pending_invites query would crash | firestore.indexes.json | 🔴 Runtime crash |
| 16 | **Auth buttons green instead of primary** — login/register used `brand?.success` | login_screen, register_screen | 🟠 Branding |
| 17 | **photoURL not saved from Google Sign-In** — profile image lost | auth_service, user_context, user_entity | 🟠 Feature |
| 18 | **Auth error codes exposed** — raw Firebase codes in default cases | auth_service.dart | 🟡 UX |

---

### Phase 3: Architecture Improvements

| Improvement | Files |
|-------------|-------|
| **Created `error_utils.dart`** — `userFriendlyError()` utility replaces 18 `e.toString()` calls | lib/core/error_utils.dart + 8 screens |
| **Created `household_service.dart`** — extracted Firestore operations from screens | lib/services/household_service.dart |
| **Replaced all `package:memozap/` imports** — ~15 files changed to relative imports | Across lib/ |
| **Social Login moved to top** — Google/Apple buttons above email form (conversion optimization) | login_screen, register_screen |
| **Removed auto-focus on register** — keyboard doesn't open immediately | register_screen.dart |

---

### Phase 4: UI/UX Polish

| Change | Details |
|--------|---------|
| **Welcome screen** — Caveat font for brand name, improved benefits size/spacing | welcome_screen.dart |
| **Legal dialog** — larger text (16px), fade scroll hint, primary button, divider | legal_content_dialog.dart |
| **Auth link colors** — amber (WCAG fail) → primary (WCAG pass) | login_screen, register_screen |
| **Register layout tightened** — ~54px less scrolling | register_screen.dart |
| **Login layout** — removed Center wrapper, content starts from top | login_screen.dart |
| **Settings dialogs** — green/pink buttons → primary FilledButton | settings_screen.dart |
| **Admin emoji** — 🛡️ → ⭐ (cross-device consistency) | app_strings_he/en |
| **Owner SnackBar** — dark default → themed tertiaryContainer | household_members_screen.dart |
| **Dashboard avatar** — shows Google profile photo when available | home_dashboard_screen.dart |
| **Dark mode FABs** — hardcoded kSticky* → brand-aware colors | shopping_lists_screen, shopping_list_details |

---

### Phase 5: Text/Copy Improvements

| Before | After | Language |
|--------|-------|----------|
| "ניהול קניות חכם לכל המשפחה" | "קניות חכמות לכל המשפחה" | HE |
| "אף פעם לא ייגמר" | "מזווה שלא נגמר" | HE |
| "שיתוף פעולה חי" | "שיתוף בזמן אמת" | HE |
| "הצטרפו לדרך החכמה לנהל קניות" | "הדרך החכמה לקניות משפחתיות" | HE |
| "קרא/י אותם" | "קראו אותם" | HE (legal) |
| "המשתמש/ת מזין/ה" | "המשתמש מזין" | HE (legal) |
| "Smart grocery management" | "Smart shopping" | EN |

---

### Phase 6: APK Size Optimization

| Action | Savings |
|--------|---------|
| **Deleted 10 unused images** (including 6.9MB app_icon_new, 4.5MB logo_new) | ~12MB |
| **Converted 3 PNG → WebP** (onboarding images, quality 85) | ~19.7MB |
| **Total APK reduction** | **127MB → 94.4MB** (26% smaller) |

---

### Phase 7: CI/CD Improvements

| Change | Details |
|--------|---------|
| **Branch filter** — `'**'` → `main` + `claude/dev` only | Saves GitHub Actions minutes |
| **cancel-in-progress** — `false` → `true` | Only latest build matters |
| **dart analyze** — added before build step | Catches errors early |
| **token → serviceCredentialsFileContent** — deprecated auth method replaced | Future-proof |
| **NDK installation** — explicit sdkmanager step | Fixes build failure |
| **google-services.json** — updated with Google Sign-In config | Enables Google auth |

---

### Phase 8: Demo Data (`rebuild_demo_data.js`)

**16 test users** covering all edge cases:

| User | Tests |
|------|-------|
| אבי כהן (Owner) | Admin, shared lists, notifications, active shopping |
| רונית כהן (Creator) | List creator, active shopper, saved contacts |
| יובל כהן (Editor) | Editor permissions, request approval flow |
| נועה כהן (Editor) | Editor permissions, request rejection flow |
| אורי שלום (Viewer) | Read-only access |
| דן + מאיה לוי | Couple, shared household |
| תומר בר | Single user, pharmacy, private lists, active checklist |
| שירן גל | Pantry-only (no lists), empty list (0 items) |
| נעמה רוזן | Power user (50 items, 35 pantry, 25 receipts, 8 notifications) |
| ליאור דהן | Inactive 45+ days |
| יעל חדשה | Fresh user — total empty state |
| גיל גוגל | Google Sign-In (no phone, profile image, auth_provider) |
| apple_user | Apple Sign-In (email as name, no phone) |
| Mike Johnson | English name, EN locale, English list/item names |
| ג'ורג' חביב | Special chars (geresh), long product names, free items |

**Edge cases covered:**
- `target_date` past/today/tomorrow/future (urgency tags)
- `editItem` / `deleteItem` pending requests
- Expired inventory items + expiring tomorrow
- Custom storage locations (מקרר יין, מחסן בגראז')
- Saved contacts for invite screen
- Active list with 100% progress
- Large quantity (24 units)
- Budget = 0 vs null
- Template-based list
- Emoji in product names
- Unknown notification type (forward compatibility)
- Who Brings full item (all volunteers joined)
- Inventory items with notes

---

## ⚠️ Known Issues (Not Fixed — Require Decision)

| # | Issue | Why Not Fixed |
|---|-------|---------------|
| 1 | **Google/Apple Sign-In not enabled in Firebase Console** | Config change, not code |
| 2 | **Pantry merge dialog result ignored** | Feature not implemented yet (TODO) |
| 3 | **SocialAuthMixin dead code** | Refactor needed — login/register duplicate logic |
| 4 | **Phone validation too strict** (`05X` only, no +972) | Design decision needed |
| 5 | **~25 kSticky* colors in SnackBars** without dark mode variant | Systemic refactor |
| 6 | **Cloud Functions not deployed** (GDPR + FCM) | Requires `firebase deploy --only functions` |
| 7 | **Onboarding images show English** on phone screen | Need new Hebrew images |
| 8 | **0 tests** — no unit, widget, or integration tests | Major effort |

---

## 📋 Post-Session Checklist

### Must Do Before Production:
- [ ] Enable Google Sign-In in Firebase Console
- [ ] Deploy Firestore indexes: `firebase deploy --only firestore:indexes`
- [ ] Deploy Cloud Functions: `firebase deploy --only functions`
- [ ] Run demo data: `node scripts/rebuild_demo_data.js`
- [ ] Test all 16 demo users manually

### Should Do:
- [ ] Create Hebrew onboarding images
- [ ] Implement pantry merge logic
- [ ] Add unit tests for critical flows
- [ ] Widen phone validation to accept +972 format

---

## 🛠️ Files Created

| File | Purpose |
|------|---------|
| `lib/core/error_utils.dart` | User-friendly error message utility |
| `lib/services/household_service.dart` | Household management service (extracted from screens) |

## 🗑️ Files Deleted

| File | Size | Reason |
|------|------|--------|
| `assets/images/app_icon_new.png` | 6.9MB | Unused |
| `assets/images/logo_new.png` | 4.5MB | Unused |
| `assets/images/logo_old.png` | 152KB | Unused |
| `assets/images/logo.webp` | 128KB | Unused |
| `assets/images/onboarding_*.webp` | 164KB | Replaced by PNG→WebP |
| `assets/images/shopping_success.webp` | 40KB | Unused |
| `assets/images/snichel.webp` | 32KB | Unused |
| `assets/images/onboarding_*.png` | 20.5MB | Converted to WebP |
| `.claude/` | — | Session files |
