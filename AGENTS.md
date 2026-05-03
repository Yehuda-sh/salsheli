# AGENTS.md — Permanent Working Guide for Claude Instances

> **Every Claude instance MUST read this file at the start of every session.**
> This is not a session summary — it is a living operational guide.

---

## 1. Project Overview

| Field | Value |
|-------|-------|
| **App Name** | MemoZap |
| **Package** | `com.memozap.app` |
| **Tech Stack** | Flutter 3.8+ / Dart 3.8.1+, Firebase (Auth, Firestore, Storage, Analytics, Crashlytics, Messaging), Provider + ChangeNotifier |
| **UI** | Hebrew RTL-first, Material 3, Dark Mode, Notebook + Sticky Notes design system |
| **Stage** | Pre-beta (not yet published to store) |
| **Working Branch** | `claude/dev` |
| **Repo** | `Yehuda-sh/salsheli` (GitHub) |
| **Firebase Project** | `memozap-5ad30` (Spark plan, europe-west2) |

---

## 2. Working Rules

### Hard Rules — Always Follow

1. **Always read a file before editing it.** Never guess file contents.
2. **Run `dart analyze lib/` before every commit** — but **ONLY in Cowork environment**. Never attempt in Cloud session (no SDK). See section 3.
3. **Commit messages must describe what changed and why.** Use clear, concise language matching the repo style.
4. **RTL-first in all UI decisions.** Use `EdgeInsetsDirectional`, `AlignmentDirectional`, `TextDirection`-aware chevrons. Never hardcode `Icons.chevron_left` — always check directionality.
5. **Never expose `e.toString()` to users.** Use `userFriendlyError(e, context: 'operationName')` from `lib/core/error_utils.dart`.
6. **Never use `package:memozap/` imports** in lib/ files. Use relative imports (`../../`). Only `main.dart` uses package imports.
7. **Use design system constants.** No hardcoded `fontSize`, `BorderRadius`, `EdgeInsets`, `Icon size`, or `spacing`. Use `kFontSize*`, `kBorderRadius*`, `kSpacing*`, `kIconSize*` from `lib/core/ui_constants.dart`.
8. **No hardcoded Hebrew strings in UI.** Use `AppStrings.*` from `lib/l10n/app_strings.dart`.
9. **Wrap `HapticFeedback.*()` with `unawaited()`.** Import from `dart:async`.
10. **Add `const` where possible** to `SizedBox`, `EdgeInsets`, `Duration`, `Icon`.
11. **Dispose all controllers** — `TextEditingController`, `AnimationController`, `FocusNode`, `Timer`, `StreamSubscription` must be disposed/cancelled.
12. **Use `context.read<T>()` before async gaps**, not after. Never use `context.watch<T>()` outside `build()`.
13. **Guard `setState` after async** with `if (mounted)`.
14. **Use Provider for services** — never create `NotificationsService(FirebaseFirestore.instance)` directly. Use `context.read<NotificationsService>()`.
15. **Colors from Theme only** — `Theme.of(context).colorScheme.*` or `brand?.sticky*`. Exception: `Colors.transparent`.

---

## 3. Environment Awareness

Claude operates in **two different environments**. Identify which one at session start.

### Cowork (Local Machine / Claude Code CLI)
- **Full access**: Flutter SDK, `dart analyze`, `flutter build`, emulators, file system, MCP servers, skills
- **Can run**: `dart analyze lib/` before commits
- **Can run**: `flutter test`, `flutter build apk`
- **Has**: Git with push access to `claude/dev`

### Cloud Session (claude.ai/code)
- **Code read/write and git only** — no Flutter SDK, no build tools
- **Cannot run**: `dart analyze`, `flutter build`, `flutter test`
- **Can**: Read files, edit files, search code, commit, push
- **Must**: Rely on CI (GitHub Actions) for build verification
- **Must**: Ask user to run analyze/build locally if needed

**How to detect**: Run `which flutter`. If "NOT FOUND" → Cloud session.

**At session start, always write one of these:**
- "🖥️ Cowork — full Flutter SDK available"
- "☁️ Cloud session — no SDK, code and git only"

---

## 4. Current State

### Latest Session (April 30, 2026) — Settings Folder Review + UX Deep-Dive

**4 settings files reviewed end-to-end:**
- `edit_household_name_dialog.dart`: dropped hardcoded RTL on the input, added haptic on save, added `onSubmitted` so the keyboard "Done" key saves, hoisted `maxLength: 40` into `_kMaxHouseholdNameLength` with rationale, and added a subtitle line explaining the change is multiplayer.
- `household_members_screen.dart`: leave-button now disabled-with-tooltip for owners (instead of letting them tap and getting a "you can't" snackbar after the fact), added `_showSnackBar` dedup helper for 5 snack callsites, haptic feedback on remove/role-change/leave (calibrated by destructiveness), bare error text replaced with `AppErrorState` + retry, slide animations now flip with locale, decorative house emoji wrapped in `ExcludeSemantics`, avatar size composition `kIconSizeLarge + kSpacingXTiny` simplified to `kIconSizeXLarge`, magic `vertical: 2` on badges hoisted to `_kBadgeVerticalPadding`. Watch → select on UserContext for just `householdName`.
- `manage_users_screen.dart`: removed two hardcoded `Directionality(rtl)` wrappers (CLAUDE.md violation), renamed `isOwner` → `canManage` (the gate also lets admins through), added the same `_showSnackBar` helper + viewer-only banner + role filter chips (All/Owners/Admins/Editors/Viewers), card entry animations matching `household_members`, magic alphas mapped to `kOpacityLight/Medium`, and `context.watch<UserContext>` → `context.select(userId)`.
- `settings_screen.dart` rounds 1+2 (lines 1-1480; round 3 = `_NotificationToggle` + `_ThemeCard` still pending): removed hardcoded RTL on delete-account confirm + display-name TextField, added `_showSnackBar(SnackBar, {messenger?})` helper used in 11 places, 30s timeouts on signOut/signOutAndClearAllData/deleteAccount with localized error copy, haptic on logout (light) and delete actions (medium), `_kErrorBgAlpha`/`_kErrorBorderAlpha`/`_kCardBgAlpha`/`_kCardBorderAlpha`/`_kProfileAvatarSize`/`_kHandleBarWidth`/`_kDisplayNameMaxLength` hoisted, parallel `Future.wait` for the two role/household reads in `_loadSettings`, and the **animation interval bug** fixed (`_sectionCount` was 9 with stagger 0.12 + duration 0.4 = 1.36 → last sections clamped to 1.0 with only 0.04s of animation; now 8 sections × 0.08 + 0.3 = 0.86 ≤ 1.0 — every section fully animates). Camera badge in the main settings card switched from `Positioned(right: 0)` to `PositionedDirectional.end` so it stays start-side in RTL, matching the profile bottom sheet's badge. The hardcoded English `'v$version copied'` snackbar string is now `AppStrings.settings.versionCopied(version)`, properly localized.

**UX deep-dive on the settings folder (9 of 10 user-perspective improvements applied; Q2 deferred to login_screen):**
- Logout dialog now reassures: "Your data (lists, pantry, history) stays. You can log in again with the same account." Replaces the bare "Are you sure?".
- Delete-account warning lists shared-list impact: "Lists you own — other members will lose access."
- "Re-auth required" snackbar gained a `SnackBarAction("Log in now")` that signs out and routes to `/login`.
- Edit-household-name dialog gained a subtitle: "The name is visible to everyone in your home, updates instantly."
- `removeMemberConfirm` explains the consequence: "X will no longer see shared lists. Lists they created will remain available."
- Role-toggle popup menu now shows subtitles ("Can add/remove members" vs "Can edit lists, not manage members").
- `manage_users_screen` got role filter chips for large lists, plus a viewer-only banner explaining why no actions menu is visible.
- 30-second timeouts on the destructive awaits — `takingTooLong` snackbar instead of an infinite spinner.

**Home Dashboard fully reviewed (7 child widgets):**
`pending_invites_banner`, `action_center_card` (rounds 1+2), `last_chance_banner`, `active_shopper_banner`, `onboarding_tips_card`, `household_activity_feed`, `suggestions_today_card`. Two cross-file dups still deferred: `_iconForType` exists in both `household_activity_feed` and `shopping_history_screen:1045` (extract to `lib/core/activity_visuals.dart` next time we touch history); `_ReceiptFallbackTile.onTap` reproduces the "see all" tab-nav bug but needs an intent-passing mechanism for the receipt id (same family as `MyPantryScreen.pendingStockFilter`).

**Round-2 cross-file sweep caught 3 more `kSpacingXTiny / 2` magic divides** (in `pending_invites_banner` and `active_shopper_banner` — both Apr-29 "reference quality" reviews missed them). All fixed to `kSpacingXTiny`.

**CLAUDE.md additions from this session's lessons:**
- 🎨 Design Tokens: forbid `kSpacing*/2` (magic via divide).
- ⚡ Performance: warn that `select<List>` is a no-op when getter wraps in `List.unmodifiable`.
- 🔥 UX: dedicated destructive-actions sub-checklist (data preservation copy, action buttons in error snacks, cross-entity impact, email confirmations, third-party auth implications).
- ⏳ UX: loading-timeout escape hatches and account-switching as alternative.
- 🧮 Design Polish: animation interval math sanity check.
- 🔍 Lessons: cross-file grep after catching a pattern; `Navigator.push` of a tab screen is a code smell.

**Branch sync recovery:**
Discovered the local `claude/dev` had 50 unpushed commits (Apr 21-23) with NO common ancestor with `origin/claude/dev`. The local stream was orphaned by a force-push that happened in another session. Resolution: `git tag local-dev-apr21-23` + pushed as branch `claude/dev-archive-apr21-23` for safekeeping, then `reset --hard origin/claude/dev` and cherry-picked the CLAUDE.md fix on top. Catalog content was already in origin (different history, same end-state).

### Previous Session (April 29, 2026) — Apr-29 Review Cycle

**Cross-Cutting Widgets reviewed (5 files):**
- `notebook_background.dart`, `post_auth_navigation.dart`, `quick_login_bottom_sheet.dart`, `loading_overlay.dart`, `social_login_button.dart`, `legal_content_dialog.dart`, `dev_banner.dart` — all logged in REVIEW_BACKLOG.md as reference quality with full decisions captured.

**Auth screens (Login + Register) reviewed:**
- `login_screen.dart` (818 lines) and `register_screen.dart` (885 lines) — full 12-category review with snackbar dedup, token alignment, inclusive copy ("קניות משפחתיות" → "ניהול הקניות"), `fillColor` alignment between login and register.
- `loading_overlay.dart`, `social_login_button.dart` (now wraps `AnimatedButton`), and `post_auth_navigation.dart` (the new pending-invites guard).

**Misc:**
- `index_screen.dart` (state machine), `index_view.dart` (loading/error views), `main_navigation_screen.dart`, `app_layout.dart`, `app_theme.dart`, `main.dart`, `pantry_merge_dialog.dart`, `welcome_screen.dart` — all reviewed with decisions logged.
- `kOpacitySoft` (0.15) constant introduced + 36 call sites swept across 17 files.
- `SectionHeader` redesigned to highlighter style (color only behind text, not full-width container), and `kHighlightOpacity` (0.3) constant added — distinct intent from `kOpacityLight` despite the same numeric value.
- `last_chance_banner.dart` relocated from `home/dashboard/widgets/` to `shopping/active/widgets/` to match its actual usage.
- 3 docs added to `docs/`: `REVIEW_BACKLOG.md` is now the cross-session memory of decisions and deferred items per screen.
- CLAUDE.md restructured: 12-category File Review Checklist, Response Style, Lessons Learned (consolidated and de-duped on Apr 30).

### April 27, 2026 — Multi-agent Sweep + Pantry Edit-Dialog UX

**15 parallel agents** swept every directory under lib/ (core, l10n, models,
providers, repositories, services, screens, widgets, theme, layout) plus
catalog audit + post-merge polish.

**Real bugs fixed:**
- Pantry tile rendered the literal string `${item.quantity} ${item.unit}` on
  every row (escape-sequence regression in pull-to-refresh patch).
- FCM token race in `clearToken()` — listener wasn't cancelled before
  `deleteToken()`, the SDK refresh callback could write a fresh token to
  the previous user's Firestore doc after logout (privacy leak).
- `LimitStatus get status` on InventoryItem used `getLimitStatus` inverted
  — a quantity=0 item reported SAFE, a 9.5/10 item reported CRITICAL. The
  getter was removed and the two callers cleaned up.
- TextEditingController leak in `register_screen._askHouseholdName`.
- 8 RTL bugs across shopping/home/pantry chips (`EdgeInsets.only(left/right)`
  → `EdgeInsetsDirectional`).
- Activity-log error displayed snake_case key verbatim — now localized.
- Avatar emoji disappeared in app bar after picking it (Image.network
  on emoji string, missing `startsWith('http')` branch).

**Cleanup:**
- ~80 dead methods/classes removed (providers, services, repos, models).
- l10n: 25 EN parity gaps closed + 31 TODO translations finalised.
- Catalog audit: butcher (278→26 in 'אחר' + new 'נקניקים' category),
  bakery ('מאפים' 175→7), pharmacy (15 misclassified items removed).
- 8,032 brand pollutants in supermarket.json (`'לא ידוע'`/`,`) → null.
- 14 short Israeli barcodes auto-repaired via EAN-13 checksum.

**Pantry edit-dialog UX overhaul (Phase 1 + 2):**
- Full-screen InteractiveViewer image with Hero animation + pinch-zoom.
- Title de-glared (cs.onSurface), category-emoji fallback, name counter
  appears only past 70 chars.
- Statistics: relative dates ("נקנה היום", "לפני 3 ימים"), exact date
  in Tooltip; clearer purchase-count phrasing.
- Empty expiry → CTA button instead of greyed "לא הוגדר".
- "Advanced settings" inline (no expand-tile cliff).
- Equal-width Cancel/Save (OutlinedButton + ElevatedButton).
- Hardware Enter saves, Escape cancels.
- **Brand + size badges** loaded async from product catalog (no schema
  change — read-only display from supermarket.json by barcode).
- **Auto-resync** stale category from catalog when opening edit (fixes
  the candy/sucariot items still tagged 'תבלינים' from before the
  catalog re-categorization).

**Splash → loading transition unified:**
- IndexLoadingView dropped the purple gradient; now uses `kSplashBackground`
  (#FFF8F0) — exact match with `flutter_native_splash` config so the
  Android splash → Flutter handoff has no visible flash.
- Loading-screen icon switched from generic Material basket to actual
  `assets/images/logo.png`.
- App-name typography now matches the AppBar (Caveat font, primary colour).

**Index/main_navigation cleanups:**
- index_screen: extracted `_completeNavigation` helper, wrapped
  `_isChecking` in try/finally to prevent stuck state.
- index_view: WavePainter stride 1px → 2px (halves per-frame path
  cost, identical visually); ~15 magic numbers hoisted to file-level
  consts; cached phase/widthInv inside the painter loop.
- main_navigation: tab-fade `Duration(200ms)` extracted to a const.

**Welcome screen perf:**
- PageController listener was driving a full-screen rebuild ~60fps.
  Now the offset lives in a ValueNotifier with two scoped
  ValueListenableBuilders (parallax + worm dots only). Magic numbers
  (page count, autoplay interval, dot dimensions) hoisted to consts.

**Storage rules:**
- Removed dead `/groups/` write-anyone rule (DoS vector).
- Profile filename pinned to `avatar.(jpg|jpeg|png|webp)`.
- Last-Updated stamp bumped to 27/04/2026.

**Docs:**
- WORK_PLAN.md deleted (stale March-24 snapshot, fully superseded by
  CODE_REVIEW.md).
- README.md: platform badge fixed, Quick-Start added, docs index added.
- CODE_REVIEW.md bumped to v7.0 with full session 7 history.
- CLAUDE.md Known-Issues refreshed (RTL1 partial fix, i18n1 + AUTH1 +
  CAT1 added).

### Previous Session (April 18-22, 2026) — UX Polish + Lint Cleanup + Catalog Sanitization

**Settings screen overhaul (7 commits):**
- Haptic feedback throughout + theme card scale animation
- Tappable avatar with camera badge + logout card tint
- Colored icon hierarchy + animated delete card + section count fix
- RTL camera badge + household hint + emoji haptic/scale
- Comprehensive dividers + icon color hierarchy
- Pull-to-refresh + version copy + onboarding haptic
- Semantics labels on all interactive elements

**History screen overhaul (6 commits):**
- BiDi fixes + empty state animation + defaultProductName fallback
- Color-coded activity icons + relative time + filter scale animation
- Staggered activity entrance + receipt haptic + filter hint
- Relative receipt dates + stats gradient + BiDi counter
- Receipt total summary + item/event a11y + lint
- Lint cleanup (redundant args, const, tearoff)

**Pantry improvements:**
- Collapsible locations + notes indicator + low-stock pulse
- Pull-to-refresh + animated quantity counter

**Auth/Welcome a11y + design tokens:**
- Welcome: staggered benefits, card semantics, chip a11y
- Welcome: blur token, shadow match, carousel a11y, dead code removal
- Auth: haptic, touch targets, semantics, design tokens
- login_screen Semantics wrapper paren nesting fix

**Catalog sanitization (4 commits):**
- 273 + 3 corporate brand names cleaned from product names
- 2,320 stuck numbers + 324 trailing asterisks fixed
- butcher.json final cleanup (last 3 trailing asterisks)
- Extract sanitization helper + skip redundant rebuilds (5-role audit)

**Lint cleanup (major):**
- Added `@override` to 1030 English string members
- Sorted imports in 31 files (resolves **W2: directives_ordering**) ✅
- 32 more `@override` annotations + error/warning resolves
- `prefer_is_empty` — `.length > 0` → `.isNotEmpty`
- Curly braces, single quotes, underscores, final fields
- Deprecated APIs, unnecessary const, const assert, build context
- 5 analyzer errors + warnings resolved

**Bug fixes:**
- 4 unsafe type casts that crash on malformed Firestore data
- Self-invite guard + empty household name validation
- Per-user image upload cooldown (was global) + hardcoded Hebrew + BiDi
- 3 missing Firestore indexes + Android CAMERA permission
- BiDi fixes on 4 more product name displays
- 5 hardcoded Hebrew fallbacks → AppStrings (i18n coverage bump)

**UX:**
- Touch targets increased to 44dp minimum across 5 files
- Premium haptic choreography + animated category collapse
- Haptic feedback on 3 remaining screens
- Hardcoded UI values → design tokens across 7 files
- Missing const on EdgeInsets/margin across 9 files

**Docs/infra:**
- Standardized all 154 Dart file headers with English descriptions
- `firebase_options.dart` added to `.gitignore`

### Previous Sessions
- April 9, 2026: Activity Log feature + CI fixes + demo data + deep scan
- March 26, 2026: Full 17-category review, 18 critical bugs fixed, 55+ commits, APK 127→94.4MB
- March 24, 2026: Code review session 3 — 4 security fixes, 5 logic bugs, ~50 design system fixes

### Next Priorities
1. **Continue Settings folder review** — `settings_screen.dart` Round 3 covers `_NotificationToggle` + `_ThemeCard` (lines 1483-end, ~100 lines).
2. **Verify `firestore.rules`** — current file is v4.5 (audit fixes from Apr-27 deployed), but the in-app docs still flag the spam vector on `users/X/notifications/*`. Re-audit before public release.
3. **Implement pantry merge logic** — dialog result still ignored at `pending_invites_screen.dart:164` (TODO from Apr-27).
4. **`shopping_history_screen` review** — would unblock the deferred `_iconForType` extraction (`household_activity_feed` and the screen each have their own copy) and the receipt-tile tab-nav fix (intent-passing mechanism, same family as `MyPantryScreen.pendingStockFilter`).
5. **Login-screen Q2 follow-up** — Google/Apple users don't realize the next sign-in will be silent after a Settings-driven logout. Logged in REVIEW_BACKLOG.md under `settings_screen` UX deferred.
6. **Phase 3 of pantry catalog dialog** — "אחרונים" tab + "+" new-product button + barcode-not-found flow (carry-over from Apr-27).
7. **Enable Google Sign-In** in Firebase Console (user action; not code).
8. **Deploy Firestore indexes**: `firebase deploy --only firestore:indexes` (carry-over).
9. **Deploy Cloud Functions**: `firebase deploy --only functions` (requires Blaze plan; carry-over).

### Currently Blocking
- Google/Apple Sign-In requires Firebase Console configuration (not code)
- Cloud Functions require Blaze plan for deployment (currently Spark)

---

## 5. Known Issues (Not Fixed)

| # | Issue | Reason Not Fixed |
|---|-------|------------------|
| 1 | **Google/Apple Sign-In providers not enabled** in Firebase Console | Config change, not code — user must enable in Console |
| 2 | **Pantry merge dialog result ignored** — user clicks "merge" but nothing happens | Feature not implemented — TODO in `pending_invites_screen.dart:164` |
| 3 | ~~**SocialAuthMixin is dead code**~~ | ✅ Fixed (session 7) — file deleted, login/register handle social inline |
| 4 | **Phone validation too strict** — only accepts `05X-XXXXXXX`, rejects `+972`, international | Design decision needed from user |
| 5 | ~~**~25 `kSticky*` colors in SnackBars**~~ | ✅ Fixed — all 40+ SnackBars use `brand?.sticky*` fallback |
| 6 | **Cloud Functions not deployed** — GDPR deletion + FCM push defined but not live | Requires `firebase deploy --only functions` + Blaze plan |
| 7 | **Onboarding images show English text** on phone mockup | Need new Hebrew images (design work) |
| 8 | ~~**0 tests**~~ | ✅ Fixed — 15 test files, 6,627 lines |
| 9 | **`use_build_context_synchronously` warnings** in settings_screen (2 locations) | Known W1 issue — has `mounted` guards, likely fixed but needs analyzer verify |
| 10 | **`app_locale` stored in Firestore but read from SharedPreferences** | Firestore field is metadata only — locale switch is local |
| 11 | 🔴 **`firestore.rules` privilege-escalation holes** (session 7 audit) | (a) `users/{uid}` write is field-unrestricted — user can self-set `household_id` to any household and `isHouseholdMember()` trusts the field. (b) `members/{memberId}` create allows `memberId == request.auth.uid` — self-add to any household. (c) Any auth user can write to `/users/X/notifications/*` with `sender_id: null` — spam vector. Needs a security pass before public release. |
| 12 | **i18n1**: ~50 hardcoded Hebrew error strings in providers/services | Found session 7. Needs new AppStrings entries for error prefixes (createItem, updateItem, addStock, etc.) |
| 13 | **CAT1**: substring traps in `category_detection_service.dart` | `'מנגו'` matches `'מנגולד'`; `'תפוז'` matches before `'מיץ '` (orange juice → fruit); `'תמר'` not anchored. Found session 7. |
| 14 | **active_shopping_screen + who_brings_screen** don't re-watch provider — concurrent edits by other shoppers don't appear live | Pre-existing architectural choice. Found session 7. |
| 15 | **75 short Israeli barcodes (7290 prefix)** in supermarket.json | 14 auto-fixed via EAN-13 checksum (session 7). Remaining 60 didn't validate — likely not simple leading-zero strips. |
| 16 | ~~**`product_selection_bottom_sheet._failedImageUrls`** Set grows unbounded~~ | ✅ Fixed — bounded to 200 entries with auto-clear; resets when full. |

---

## 6. Architecture Notes

### Key Files

| Purpose | Path |
|---------|------|
| **Error utility** | `lib/core/error_utils.dart` — `userFriendlyError()` classifies errors (network/permission/not-found) |
| **Household service** | `lib/services/household_service.dart` — extracted from screens, uses `FirestoreCollections` constants |
| **UI constants** | `lib/core/ui_constants.dart` — all spacing, colors, sizes, durations |
| **Status colors** | `lib/core/status_colors.dart` — semantic colors via `StatusColors.getColor(StatusType, context)` |
| **App strings** | `lib/l10n/app_strings.dart` — locale proxy, delegates to `_he.dart` or `_en.dart` |
| **Theme** | `lib/theme/app_theme.dart` — `AppBrand` ThemeExtension with sticky note colors |
| **Config** | `lib/config/` — `ListTypeKeys`, `ListTypes`, `FiltersConfig`, `StorageLocationsConfig` with `ConfigValidation` mixin |
| **Repository constants** | `lib/repositories/constants/repository_constants.dart` — Firestore collection/field names |
| **Activity log model** | `lib/models/activity_event.dart` — ActivityType enum (9 types) + ActivityEvent model |
| **Activity log service** | `lib/services/activity_log_service.dart` — fire-and-forget write to Firestore |
| **Activity log repo** | `lib/repositories/activity_log_repository.dart` — read + cleanup |
| **Activity log provider** | `lib/providers/activity_log_provider.dart` — state management |
| **Demo data** | `scripts/rebuild_demo_data.js` — 16 users, all edge cases, 27 activity events |
| **Demo data CI** | `.github/workflows/rebuild-demo-data.yml` — run from GitHub Actions (workflow_dispatch) |

### Provider Tree (from `main.dart`)

```
AuthService
NotificationsService
UserRepository → FirebaseUserRepository
UserContext (depends on AuthService + UserRepository)
  → ProductsProvider (depends on UserContext)
  → LocationsProvider (depends on UserContext)
  → ShoppingListsProvider (depends on UserContext)
  → ReceiptProvider (depends on UserContext)
  → ActivityLogProvider (depends on UserContext)    ← NEW
  → InventoryProvider (depends on UserContext)
    → SuggestionsProvider (depends on InventoryProvider)
```

### Import Convention
- **All lib/ files**: relative imports (`../../core/ui_constants.dart`)
- **Only `main.dart`**: package imports (`package:memozap/...`)
- **Never mix** package and relative in the same file

### AppStrings Structure
- `AppStrings.common` — shared strings (cancel, close, retry, errors)
- `AppStrings.shopping` — shopping list screens
- `AppStrings.inventory` — pantry screens
- `AppStrings.auth` — login/register
- `AppStrings.household` — household management
- `AppStrings.sharing` — invite/sharing screens
- `AppStrings.activityLog` — activity feed descriptions (9 types) + UI strings
- Each has Hebrew base class + English `extends` override

### Firestore Structure
```
/users/{userId}/
  ├── private_lists/{listId}
  ├── notifications/{notifId}
  ├── pending_invites/{inviteId}
  ├── saved_contacts/{contactId}
  └── inventory/{itemId}

/households/{householdId}/
  ├── members/{memberId}
  ├── inventory/{itemId}
  ├── receipts/{receiptId}
  ├── activity_log/{eventId}        ← NEW: household activity feed
  └── shared_lists/{listId}

/pending_invites/{inviteId}  (top-level)
/custom_locations/{locationId}
/templates/{templateId}
```

---

## 7. Do Not Touch

The following must NOT be changed without **explicit user confirmation**:

| Item | Reason |
|------|--------|
| `firestore.rules` | Security rules v4.5 (Apr-27 audit fixes deployed). Affects all data access. Touch only with an explicit task; re-audit before public release. |
| `firebase_options.dart` | Generated by FlutterFire CLI — auto-generated |
| `pubspec.yaml` dependency versions | May break builds — upgrade only when asked |
| `android/app/google-services.json` | Firebase config — user manages manually |
| `lib/models/*.g.dart` | Generated by build_runner — never edit manually |
| Welcome screen guardrails | Per CLAUDE.md: Welcome only before account creation, logout doesn't show Welcome |
| `seenOnboarding` logic | Per CLAUDE.md: set after login/register, preserved after logout |
| Auth screen design | Per CLAUDE.md: clean, not Sticky Notes style |
| `AnimatedButton` behavior | Per CLAUDE.md: effect only, action in parent, scale 0.97-0.98 |
| IDs/Keys resolve() pattern | Per CLAUDE.md: "other" for user fallback, "unknown" for debug |

---

## 8. Common Bug Patterns (Check When Scanning Code)

When reading or reviewing any file, check for these recurring patterns found in previous sessions:

### Error Handling
- **`e.toString()` exposed to user** — Must use `userFriendlyError(e, context: '...')` from `core/error_utils.dart`
- **Hardcoded Hebrew in error messages** — Provider `_errorMessage` must use AppStrings, not inline Hebrew
- **Missing `mounted` check after await** — Every `setState` or `context` use after async must be guarded

### Design System
- **`kSticky*` colors used directly** — Must go through `brand?.stickyX ?? kStickyX` for Dark Mode support
- **Hardcoded `size:`, `fontSize:`, `width:`, `height:`** — Must use `kIconSize*`, `kFontSize*`, `kSpacing*`, `kBorderRadius*`
- **Missing `const`** on `SizedBox`, `EdgeInsets`, `Icon`, `Duration`, `Spacer`
- **`Colors.xxx`** — Only `Colors.transparent` allowed. Everything else from `Theme.of(context).colorScheme`

### Architecture
- **Services created with `new`** — Must use `context.read<Service>()` via Provider (e.g., `HouseholdService()` → `context.read<HouseholdService>()`)
- **`NotebookBackground()` without `const`** — Always `const NotebookBackground()`
- **AppBar without glass blur** — All push-screens with AppBar must have `flexibleSpace: ClipRect(child: BackdropFilter(...))`

### Data
- **Product `unit` vs `defaultUnit`** — Catalog `unit` is Shufersal's measurement (מיליליטר). For user display/inventory, use `defaultUnit` (יח')
- **Product names with English suffix** — Clean with `_cleanProductName()` before display
- **Firestore notification types** — Must be in `isValidNotificationType()` enum in `firestore.rules`

### UI/UX
- **Bottom sheet height** — With many items, add `maxHeight` constraint (85% screen height)
- **RTL** — Use `EdgeInsetsDirectional`, `AlignmentDirectional`, check chevron direction
- **Tap targets** — Minimum 44x44dp for interactive elements
- **`HapticFeedback.*()` must be wrapped in `unawaited()`**

---

## 9. How to Update This File

At the end of every **Cowork session**:

1. **Update "Current State"** (section 4) with what was done
2. **Move completed items** out of "Next Priorities"
3. **Add new Known Issues** (section 5) if found
4. **Commit** with message: `"עדכון AGENTS.md — סיום סשן [date]"`

This file must always reflect the **current** state of the project — not historical.

### Save Command

When the user types **"SAVE"**, it means the session is ending.
Claude must immediately:

1. Update section 4 (Current State) with everything done this session
2. Add any new Known Issues to section 5
3. Run `dart analyze lib/` (Cowork only)
4. Commit and push AGENTS.md with message: `"עדכון AGENTS.md — סיום סשן [date]"`
5. Reply with a short summary of what was saved
