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

---

## 4. Current State

### Last Session (March 26, 2026)
- Full 17-category review of all 141 Dart files
- 18 critical bugs fixed, 55+ commits
- APK reduced from 127MB → 94.4MB
- Auth screens redesigned (Social Login first)
- CI/CD improved (analyze, NDK, service credentials)
- Demo data expanded to 16 users with 30+ edge cases
- `error_utils.dart` and `household_service.dart` created

### Next Priorities
1. **Enable Google Sign-In** in Firebase Console (user action)
2. **Deploy Firestore indexes**: `firebase deploy --only firestore:indexes`
3. **Deploy Cloud Functions**: `firebase deploy --only functions`
4. **Run demo data**: `node scripts/rebuild_demo_data.js`
5. **Manual testing** of all 16 demo users
6. **Implement pantry merge logic** (dialog result currently ignored)
7. **Add unit tests** for critical flows

### Currently Blocking
- Google/Apple Sign-In requires Firebase Console configuration (not code)
- Cloud Functions require Blaze plan for deployment (currently Spark)
- No Flutter SDK in Cloud environment — can't verify analyze locally

---

## 5. Known Issues (Not Fixed)

| # | Issue | Reason Not Fixed |
|---|-------|------------------|
| 1 | **Google/Apple Sign-In providers not enabled** in Firebase Console | Config change, not code — user must enable in Console |
| 2 | **Pantry merge dialog result ignored** — user clicks "merge" but nothing happens | Feature not implemented — TODO in `pending_invites_screen.dart:164` |
| 3 | **SocialAuthMixin is dead code** — login/register duplicate the logic inline | Refactor needed — both screens work, just not DRY |
| 4 | **Phone validation too strict** — only accepts `05X-XXXXXXX`, rejects `+972`, international | Design decision needed from user |
| 5 | **~25 `kSticky*` colors in SnackBars** without dark mode Theme variant | Systemic refactor across many files |
| 6 | **Cloud Functions not deployed** — GDPR deletion + FCM push defined but not live | Requires `firebase deploy --only functions` + possibly Blaze plan |
| 7 | **Onboarding images show English text** on phone mockup | Need new Hebrew images (design work) |
| 8 | **0 tests** — no unit, widget, or integration tests exist | Major effort — not in scope of review session |
| 9 | **`use_build_context_synchronously` warnings** in settings_screen (2 locations) | Known W1 issue — deferred per CLAUDE.md |
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
| **Demo data** | `scripts/rebuild_demo_data.js` — 16 users, all edge cases |

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
| `firestore.rules` | Security rules v4.2 — affects all data access |
| `firebase_options.dart` | Generated by FlutterFire CLI — auto-generated |
| `pubspec.yaml` dependency versions | May break builds — upgrade only when asked |
| `android/app/google-services.json` | Firebase config — user manages manually |
| `lib/models/*.g.dart` | Generated by build_runner — never edit manually |
| Welcome screen guardrails | Per CLAUDE.md: Welcome only before account creation, logout doesn't show Welcome |
| `seenOnboarding` logic | Per CLAUDE.md: set after login/register, preserved after logout |
| Auth screen design | Per CLAUDE.md: clean, not Sticky Notes style |
| `AnimatedButton` behavior | Per CLAUDE.md: effect only, action in parent, scale 0.97-0.98 |
| IDs/Keys resolve() pattern | Per CLAUDE.md: "other" for user fallback, "unknown" for debug |
