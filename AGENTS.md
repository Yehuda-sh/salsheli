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

### Last Session (April 18-22, 2026) — UX Polish + Lint Cleanup + Catalog Sanitization

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
1. **Enable Google Sign-In** in Firebase Console (user action)
2. **Deploy Firestore indexes**: `firebase deploy --only firestore:indexes`
3. **Deploy Cloud Functions**: `firebase deploy --only functions` (requires Blaze plan)
4. **Run demo data** via GitHub Actions → "Rebuild Demo Data" → type `yes`
5. **Manual testing** of all 16 demo users
6. **Implement pantry merge logic** (dialog result currently ignored — `pending_invites_screen.dart:164`)
7. **Refactor SocialAuthMixin** — login/register duplicate social auth logic inline
8. **Verify W1** (`use_build_context_synchronously` in settings_screen) — analyzer run pending

### Currently Blocking
- Google/Apple Sign-In requires Firebase Console configuration (not code)
- Cloud Functions require Blaze plan for deployment (currently Spark)

---

## 5. Known Issues (Not Fixed)

| # | Issue | Reason Not Fixed |
|---|-------|------------------|
| 1 | **Google/Apple Sign-In providers not enabled** in Firebase Console | Config change, not code — user must enable in Console |
| 2 | **Pantry merge dialog result ignored** — user clicks "merge" but nothing happens | Feature not implemented — TODO in `pending_invites_screen.dart:164` |
| 3 | **SocialAuthMixin is dead code** — login/register duplicate the logic inline | Refactor needed — both screens work, just not DRY |
| 4 | **Phone validation too strict** — only accepts `05X-XXXXXXX`, rejects `+972`, international | Design decision needed from user |
| 5 | ~~**~25 `kSticky*` colors in SnackBars**~~ | ✅ Fixed — all 40+ SnackBars use `brand?.sticky*` fallback |
| 6 | **Cloud Functions not deployed** — GDPR deletion + FCM push defined but not live | Requires `firebase deploy --only functions` + Blaze plan |
| 7 | **Onboarding images show English text** on phone mockup | Need new Hebrew images (design work) |
| 8 | ~~**0 tests**~~ | ✅ Fixed — 15 test files, 6,627 lines |
| 9 | **`use_build_context_synchronously` warnings** in settings_screen (2 locations) | Known W1 issue — has `mounted` guards, likely fixed but needs analyzer verify |
| 10 | **`app_locale` stored in Firestore but read from SharedPreferences** | Firestore field is metadata only — locale switch is local |

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
| `firestore.rules` | Security rules v4.3+ (includes activity_log) — affects all data access |
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
