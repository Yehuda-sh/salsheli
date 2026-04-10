# MemoZap — QA Analysis Report

**Date:** March 9, 2026 (Updated)  
**Project:** MemoZap — Family Shopping List Manager  
**Version:** 1.0.0  
**Analyst:** ראפטור 🦖

---

## Executive Summary

MemoZap is a well-structured Flutter app with a unified **Notebook + Sticky Notes** design system, clean architecture (Repository → Provider → UI), and comprehensive Firestore security rules. Recent refactoring eliminated all hardcoded colors, unified typography and border radius, and removed ~8,000 lines of dead code.

**dart analyze:** 0 errors, 0 warnings (825 info-level hints)

---

## 1. Test Coverage

### Current State
- **Test Files:** 10
- **Test Count:** ~100
- **Coverage:** Low — models and 1 service only

### Existing Tests
| File | Area | Tests |
|------|------|-------|
| `models/inventory_item_test.dart` | InventoryItem | ~25 |
| `models/smart_suggestion_test.dart` | SmartSuggestion | ~20 |
| `models/shopping_list_test.dart` | ShoppingList | ~30 |
| `models/shopping_list_permissions_test.dart` | Permissions | ~15 |
| `models/active_shopper_test.dart` | ActiveShopper | ~10 |
| `services/suggestions_service_test.dart` | Suggestions | ~25 |
| `providers/user_context_test.dart` | UserContext | ~10 |
| `screens/widget_tests_integration.dart` | Widgets | ~5 |

### Needed Tests (Priority Order)
1. `providers/shopping_lists_provider_test.dart` — CRUD, sharing, search
2. `providers/inventory_provider_test.dart` — stock, alerts
3. `services/auth_service_test.dart` — login flows
4. `services/notifications_service_test.dart` — all notification types
5. `services/pending_requests_service_test.dart` — approve/reject
6. Widget tests for shared components
7. Integration tests for shopping flow

---

## 2. Known Bugs

### 🔴 Critical

#### B1. Pending Requests — Approve/Reject Not Wired
**Location:** `lib/widgets/common/pending_requests_section.dart:360,398`  
**Status:** ⚠️ OPEN  
**Impact:** Buttons do nothing — users can't approve/reject requests  
**Fix:** Call `PendingRequestsService.approveRequest()` / `rejectRequest()`

#### B2. Notification Navigation Broken
**Location:** `lib/screens/notifications/notifications_center_screen.dart:360`  
**Status:** ⚠️ OPEN  
**Impact:** Tapping notification doesn't navigate to relevant list  
**Fix:** Add `Navigator.push` to `ShoppingListDetailsScreen` with `listId`

### 🟡 Medium

#### B3. SavedContactsService Swallows Errors
**Location:** `lib/services/saved_contacts_service.dart` (5 catch blocks)  
**Status:** ⚠️ OPEN  
**Impact:** Save/delete contacts can fail silently  
**Fix:** Return Result type or throw for UI to catch

#### B4. Race Condition in Collaborative Shopping
**Location:** `lib/providers/shopping_lists_provider.dart`  
**Status:** ⚠️ OPEN  
**Impact:** Concurrent `startCollaborativeShopping` calls not atomic  
**Fix:** Use Firestore transactions

---

## 3. Resolved Issues (Since Dec 2025)

| Issue | Status | Details |
|-------|--------|---------|
| ~~Debug prints in production~~ | ✅ Fixed | 852 prints removed, only kDebugMode remains |
| ~~No input sanitization~~ | ✅ Exists | Household names: trim, max 40, strip HTML |
| ~~No Firestore rules~~ | ✅ Fixed | v4.1 with schema validation, audit trail, anti-spam |
| ~~Hardcoded colors~~ | ✅ Fixed | 316 → 0 `Colors.xxx` |
| ~~Inconsistent design~~ | ✅ Fixed | 5 styles → 1 (Notebook) on all 21 screens |
| ~~Large files~~ | ✅ Partial | active_shopping split (1898→1132), login split (1157→802) |
| ~~Dead code~~ | ✅ Fixed | 15 files deleted, 233 dead strings removed |
| ~~Missing loading states~~ | ✅ Exists | SkeletonLoader used consistently |
| ~~Missing confirmation dialogs~~ | ✅ Exists | AppDialog with adaptive confirm/info/choose |
| ~~Error messages not localized~~ | ⏳ Phase 8 | 101 hardcoded Hebrew strings deferred to i18n |

---

## 4. Code Quality

### Strengths ✅
- Clean Repository → Provider → UI architecture
- Unified Design System (tokens, extensions, constants)
- 0 hardcoded colors, 8 font sizes, 4 border radius values
- Comprehensive Firestore rules with role-based access
- Good error handling (`_runAsync`, `_notifySafe`, 167 `mounted` checks)
- Well-documented files with JSDoc-style comments
- Strict lint rules (avoid_print=error, unawaited_futures, etc.)

### Needs Improvement 🟡
- `ShoppingListsProvider` 1,520 lines — needs mixin split
- `NotificationsService` — 9 near-identical methods (copy-paste)
- `Provider.of<>` mixed with `context.read<>` in pending_requests
- No rate limiting on client side (debounce/throttle)
- No pagination in repository layer

### Performance 🟡
- `loadLists()` after every CRUD — use optimistic updates
- Suggestion generation iterates all items — cache needed
- No Firestore offline persistence configured

---

## 5. Security

| Area | Status |
|------|--------|
| Firestore Rules | ✅ v4.1 — schema validation, audit trail |
| Role-based Access | ✅ Owner/Admin/Editor/Viewer |
| Input Sanitization | ✅ Household names |
| Anti-spam | ✅ Notification type enum, 500 char limit |
| Rate Limiting (server) | ⚠️ Needs Cloud Functions |
| Rate Limiting (client) | ⚠️ kDoubleTapTimeout exists, not applied everywhere |

---

## 6. Production Readiness

| Item | Status |
|------|--------|
| Package name | ✅ `com.memozap.app` |
| Firebase config | ✅ google-services.json updated |
| iOS permissions | ✅ Contacts, camera, photos |
| dart analyze | ✅ 0 errors, 0 warnings |
| Design system | ✅ Unified |
| Release keystore | ❌ Not created |
| App icons | ❌ Default Flutter icon |
| Splash screen | ❌ Not configured |
| Privacy policy | ❌ Not written |
| ProGuard | ❌ Not configured |
| i18n | ❌ 101 hardcoded Hebrew strings |

---

## 7. Priority Actions

1. **B1+B2** — Fix broken approve/reject + notification navigation
2. **Release keystore** — Required for Play Store
3. **App icons** — Replace default Flutter icon
4. **Privacy policy** — Required for both stores
5. **Tests** — Increase coverage (providers, services)
6. **i18n** — Phase 8

---

*🦖 ראפטור — QA Report | Updated March 8, 2026*
