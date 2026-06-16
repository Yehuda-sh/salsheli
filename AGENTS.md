# AGENTS.md — Project State for Claude Instances

> **What this file is:** the *current state* of the project — known issues, architecture, what's blocking.
> **What it is NOT:** the how-to-work guide (that's [CLAUDE.md](CLAUDE.md)) or the product vision (that's [docs/PRODUCT_DIRECTION.md](docs/PRODUCT_DIRECTION.md)).
>
> 🧭 **מקור אמת למוצר:** [docs/PRODUCT_DIRECTION.md](docs/PRODUCT_DIRECTION.md). אחרי המיקוד לסופר (יוני 2026): ריבוי סוגי רשימות/חנויות → **סופר בלבד**; "מי מביא?", מצב צ'קליסט, ותהליך אישור הבקשות → נחתכו; מנדט "NotebookBackground בכל מסך" → "נייר רגוע". סעיפים כאן שסותרים — המסמך ההוא מנצח.

---

## 1. Project Overview

| Field | Value |
|-------|-------|
| **App Name** | MemoZap |
| **Package** | `com.memozap.app` |
| **Tech Stack** | Flutter 3.8+ / Dart 3.8.1+, Firebase (Auth, Firestore, Storage, Analytics, Crashlytics, Messaging), Provider + ChangeNotifier |
| **UI** | Hebrew RTL-first, Material 3, Dark Mode, "calm paper" design (notebook + sticky-notes as accent) |
| **Stage** | Pre-beta (not yet published to store) |
| **Working Branch** | `claude/dev` |
| **Repo** | `Yehuda-sh/salsheli` (GitHub) |
| **Firebase Project** | `memozap-5ad30` (Spark plan, europe-west2) |

**Working rules + review checklist + design tokens → [CLAUDE.md](CLAUDE.md).** This file does not restate them.

---

## 2. Environment Awareness

Claude operates in **two environments**. Identify which at session start.

### Cowork (Local Machine / Claude Code CLI)
- **Full access**: Flutter SDK, `dart analyze`, `flutter build`, emulators, file system, MCP servers, skills.
- **Can run**: `dart analyze lib/` (before every commit), `flutter test`, `flutter build apk`.
- **Git**: push access to `claude/dev`.

### Cloud Session (claude.ai/code)
- **Code read/write and git only** — no Flutter SDK, no build tools.
- **Cannot run**: `dart analyze`, `flutter build`, `flutter test`.
- **Must**: rely on CI (GitHub Actions) for build verification; ask the user to run analyze/build locally if needed.

**How to detect**: run `which flutter`. If "NOT FOUND" → Cloud session.

**At session start, write one of:** "🖥️ Cowork — full Flutter SDK available" / "☁️ Cloud session — no SDK, code and git only".

---

## 3. Current State

### Latest session (May 31, 2026) — Full-codebase audit + fix phases
12 parallel sub-agents swept all 161 `lib/` files; critical security claims hand-verified.
**8 commits + a round-2 sweep, all pushed to `claude/dev`, 478/478 tests green, `dart analyze lib/` clean.**

Headline fixes: 8 crash/data-integrity guards (background-load generation guard,
lenient timestamp_converter, null-safe item parsing, neutral `MemoZap-XXXX` default
household name); 49 SnackBar dedups across 14 files; every provider error routes
through `userFriendlyError` (localized HE/EN); `category_detection` longest-match-first
+ flavor-signal guard (#13); `active_shopping` + `who_brings` now read the live provider
list (#14); cross-user notifications un-broken via a `_writeWithSender` helper that
injects `senderId` (#18 client-side).

> Full per-session history lives in `git log` — not duplicated here.

### Next Priorities
0. 🧹 **Supermarket-only cleanup (in progress)** — deleting all non-supermarket list
   types end-to-end. Phases 1-2 done; phases 3-7 (templates, config, catalogs, strings,
   docs) pending. Full plan + checklist: [docs/SUPERMARKET_CLEANUP.md](docs/SUPERMARKET_CLEANUP.md).
1. 🔴 **Security gate (before any public release)** — the v4.5/4.6 rules broke core
   flows. Needs: (a) a callable `acceptHouseholdInvite` Cloud Function (Admin SDK) so
   users can actually join a household (#17); (b) `senderId`/`senderName` already set
   client-side (#18) — verify against deployed rules; (c) constrain `group_ids` in the
   `users` update rule (#19); (d) restrict `activity_log` + household `inventory` deletes
   to admin (#20); (e) `private_lists` shared-read rule + "lists shared with me" query (#22).
   Requires Blaze for the Function.
2. **#12 remainder** — `notifications_service` titles/messages still hardcoded Hebrew
   (entangled with #18); service-layer throws collapse to generic — fix with typed
   exceptions / result enums.
3. **#23** — editor/owner-added barcode + price dropped on shopping lists (owner-path plumbing).
4. **Directionality(rtl) cleanup** (#21) — ~13 redundant wrappers; cosmetic + visual-layout
   risk → do on-device. Intentional LTR wrappers (+/- controls, main.dart global) must stay.
5. **Dead l10n cleanup** — 4 unreachable string groups (priceComparison, templates,
   selectList, recurring) + dead getters. Verify zero callers, then delete.
6. **#2 pantry merge** — `pending_invites_screen` still discards `showPantryMergeDialog`;
   needs an InventoryProvider merge method.
7. **Enable Google/Apple Sign-In** (Console config) + **deploy indexes/functions** (Blaze).

### Currently Blocking
- Google/Apple Sign-In requires Firebase Console configuration (not code).
- Cloud Functions require Blaze plan for deployment (currently Spark).

---

## 4. Known Issues (Not Fixed)

| # | Issue | Reason Not Fixed |
|---|-------|------------------|
| 1 | **Google/Apple Sign-In providers not enabled** in Firebase Console | Config change, not code — user must enable in Console |
| 2 | **Pantry merge dialog result ignored** — user clicks "merge" but nothing happens | Feature not implemented — TODO in `pending_invites_screen.dart` |
| 4 | **Phone validation too strict** — only accepts `05X-XXXXXXX`, rejects `+972`, international | Design decision needed from user |
| 6 | **Cloud Functions not deployed** — GDPR deletion + FCM push defined but not live | Requires `firebase deploy --only functions` + Blaze plan |
| 7 | **Onboarding images show English text** on phone mockup | Need new Hebrew images (design work) |
| 9 | **`use_build_context_synchronously` warnings** in settings_screen (2 locations) | Has `mounted` guards, likely fixed but needs analyzer verify |
| 10 | **`app_locale` stored in Firestore but read from SharedPreferences** | Firestore field is metadata only — locale switch is local |
| 11 | 🔴 **`firestore.rules` v4.5/4.6 — over-corrected into shipping-blockers** | Original privilege-escalation holes are closed, BUT see #17 (household-join impossible client-side) + #19/#20. Client/Functions must be updated to match. |
| 12 | **i18n1: hardcoded Hebrew error strings** | ✅ Providers fixed (route through userFriendlyError). ⏳ Remaining: `notifications_service` titles/messages (entangled with #18) + service-layer throws (need typed exceptions). |
| 14 | **active_shopping cross-user same-item status** | Live list re-watch fixed (#14). Remaining limitation: each shopper tracks own `_itemStatuses`, so two shoppers toggling the SAME item don't see each other. |
| 15 | **75 short Israeli barcodes (7290 prefix)** in supermarket.json | 14 auto-fixed via EAN-13 checksum. Remaining 60 didn't validate — likely not simple leading-zero strips. |
| 17 | 🔴 **Joining a household is impossible** (verified May 31) | `pending_invites_service._addUserToHousehold` runs a client batch that v4.5 rules deny for a non-creator/non-admin; no Cloud Function compensates. Likely masked by Admin-SDK-seeded demo data. **Fix:** callable `acceptHouseholdInvite` Cloud Function (Blaze). |
| 18 | **Cross-user notification text still Hebrew-only** | ✅ Client fixed May 31 — `_writeWithSender` injects `senderId` so notifications pass the v4.5 rule. Remaining: notification text is hardcoded Hebrew (#12) — needs read-time localization for cross-locale recipients. |
| 19 | 🔴 **`group_ids` self-grant escalation** | The `users` update rule guards only `household_id`, not `group_ids`; `isGroupMember`/`custom_locations` trust the client array → self-grant. Authorize via the group doc's members, not the user array. |
| 20 | 🟠 **Audit log + shared inventory deletable by any member** | `activity_log` delete + household `inventory` delete are `isHouseholdMember`-only → any member (even viewer) can wipe the "tamper-proof" log or shared inventory. Restrict to admin / item author. |
| 21 | 🟡 **~13 redundant `Directionality(rtl)` wrappers** | Cosmetic (app is globally RTL); removal carries visual-layout risk → deferred to a dedicated on-device pass. Intentional LTR wrappers must stay. |
| 22 | 🔴 **"Share with specific contacts" lists are invisible to those contacts** | `create_list` "shared" → `isPrivate:true`; saved to owner's `private_lists`, contact added via `shared_users` map. But `private_lists` read rule is owner-only, and watchLists doesn't query others' private_lists → contacts never see it. **Don't "fix" by routing to household-wide `shared_lists`** (over-shares to everyone). Needs a `private_lists` shared-read rule + a "lists shared with me" query. |

> **Resolved-issue ledger** (numbers kept stable — code/tests still cite them): **#3** SocialAuthMixin deleted · **#5** kSticky colors → `brand?.sticky*` fallback · **#8** test suite added · **#13** category-detection substring traps (cited in `category_detection_service_test.dart`) · **#16** `product_selection_bottom_sheet._failedImageUrls` Set bounded to 200 (cited in that file) · **#23** shopping-list scan now preserves the scanned barcode + catalog price (threaded through `addItemToList` + the editor requestData). These rows were dropped from the table above; open issues are referenced cross-doc, so numbers are never reused.

---

## 5. Architecture Notes

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
| **Activity log** | model `lib/models/activity_event.dart` (ActivityType enum, 9 types) · service `activity_log_service.dart` (fire-and-forget) · repo `activity_log_repository.dart` (read + cleanup) · provider `activity_log_provider.dart` |
| **Demo data** | `scripts/rebuild_demo_data.js` (22 users, all edge cases) · CI `.github/workflows/rebuild-demo-data.yml` (workflow_dispatch) |

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
  → ActivityLogProvider (depends on UserContext)
  → InventoryProvider (depends on UserContext)
    → SuggestionsProvider (depends on InventoryProvider)
```

### Import Convention
- **All lib/ files**: relative imports (`../../core/ui_constants.dart`).
- **Only `main.dart`**: package imports (`package:memozap/...`).
- **Never mix** package and relative in the same file.

### AppStrings Structure
`AppStrings.common` / `.shopping` / `.inventory` / `.auth` / `.household` / `.sharing` / `.activityLog` — each a Hebrew base class with an English `extends` override.

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
  ├── activity_log/{eventId}
  └── shared_lists/{listId}

/pending_invites/{inviteId}  (top-level)
/custom_locations/{locationId}
/templates/{templateId}
```

---

## 6. Do Not Touch

The following must NOT be changed without **explicit user confirmation**:

| Item | Reason |
|------|--------|
| `firestore.rules` | Security rules v4.5. Affects all data access. Touch only with an explicit task; re-audit before public release. |
| `firebase_options.dart` | Generated by FlutterFire CLI |
| `pubspec.yaml` dependency versions | May break builds — upgrade only when asked |
| `android/app/google-services.json` | Firebase config — user manages manually |
| `lib/models/*.g.dart` | Generated by build_runner — never edit manually |
| Welcome screen guardrails | Welcome only before account creation; logout doesn't show Welcome |
| `seenOnboarding` logic | Set after login/register, preserved after logout |
| Auth screen design | Clean, not Sticky Notes style |
| `AnimatedButton` behavior | Effect only, action in parent, scale 0.97-0.98 |
| IDs/Keys resolve() pattern | "other" for user fallback, "unknown" for debug |

---

## 7. Maintaining This File

At the end of every **Cowork session** (or when the user types **"SAVE"**):

1. Update **§3 Current State** — replace the latest-session summary; move completed items out of Next Priorities.
2. Add/close **§4 Known Issues** (remove resolved rows, keep numbers stable).
3. Run `dart analyze lib/` (Cowork only).
4. Commit + push: `"עדכון AGENTS.md — סיום סשן [date]"`.
5. Reply with a short summary of what was saved.

Keep this file **current**, not historical — the narrative belongs in `git log`.
