# תוכנית עבודה — MemoZap Code Review Session 3 Follow-up

> נוצר: 24 מרץ 2026
> מטרה: **תיקון כל הממצאים מסקירת הקוד + תיעוד + TODO עתידי**
> סוקר: Claude Opus 4.6
> branch: `claude/code-review-analysis-7Lvp2`

---

## סטטוס כללי

| פאזה | תיאור | משימות | סטטוס |
|------|--------|--------|--------|
| A | באגים קריטיים | 3 | ⬜ טרם התחיל |
| B | באגי UI/UX — Size Regressions | 4 | ⬜ טרם התחיל |
| C | באגי UI/UX — Hardcoded Dimensions | 3 | ⬜ טרם התחיל |
| D | שיפורי קוד | 4 | ⬜ טרם התחיל |
| E | תיעוד — File Headers | 5 | ⬜ טרם התחיל |
| F | תיעוד — עדכון Docs | 3 | ⬜ טרם התחיל |
| G | TODO עתידי (Post-launch) | 15 | ⬜ תיעוד בלבד |

---

# Phase A — באגים קריטיים (חובה לפני merge)

### A1. ReceiptProvider — spinner נתקע
- **קובץ:** `lib/providers/receipt_provider.dart:126-132`
- **בעיה:** `_loadReceipts()` — early return כשאין login/householdId לא מאפס `_isLoading`. אם היה `true` מקריאה קודמת, ה-UI יציג spinner לנצח
- **תיקון:** הוסף `_isLoading = false;` לפני ה-early return
- **בדיקה:** logout → login → verify no infinite spinner

### A2. Active Shopping Item — Size Regression (28→24)
- **קובץ:** `lib/screens/shopping/active/widgets/active_shopping_item_tile.dart:132`
- **בעיה:** `size: 28` הוחלף ב-`kIconSizeMedium` (=24). ירידה של 4px באייקון status — שובר visual hierarchy
- **תיקון:** הגדר `kIconSizeMediumPlus = 28` ב-`ui_constants.dart`, או השתמש ב-`kIconSizeLarge` (36) אם מתאים
- **בדיקה:** השווה UI לפני/אחרי — האייקון צריך להיראות כמו לפני השינוי

### A3. Pantry Empty State — Size Regression (20→16)
- **קובץ:** `lib/widgets/inventory/pantry_empty_state.dart:262,283`
- **בעיה:** `size: 20` הוחלף ב-`kIconSizeSmall` (=16). ירידה של 4px באייקונים של badges
- **תיקון:** הגדר `kIconSizeSmallPlus = 20` ב-`ui_constants.dart`, או בדוק אם 16 נראה מספיק טוב
- **בדיקה:** visual comparison של pantry empty state badges

---

# Phase B — באגי UI/UX — Touch Targets & Accessibility

### B1. Pantry Item Dialog — Touch Targets קטנים מדי
- **קובץ:** `lib/widgets/inventory/pantry_item_dialog.dart:175-229`
- **בעיה:** כפתורי +/- עם `padding: EdgeInsets.all(kSpacingXTiny)` = 4dp. Material guideline minimum = 48dp
- **תיקון:** עטוף ב-`SizedBox(width: 48, height: 48)` או הגדל padding ל-`kSpacingSmallPlus`
- **בדיקה:** נסה ללחוץ על +/- במכשיר פיזי — צריך להיות נוח

### B2. Household Activity Feed — Hardcoded Font Sizes
- **קובץ:** `lib/screens/home/dashboard/widgets/household_activity_feed.dart`
- **בעיה:** `fontSize: 16` (line 307), `fontSize: 18` (line 355) — hardcoded במקום tokens
- **תיקון:**
  - `fontSize: 16` → `kFontSizeBody` (אם קיים) או `kFontSizeMedium`
  - `fontSize: 18` → `kFontSizeSubtitle` (אם קיים) או הגדר constant חדש
- **בדיקה:** visual comparison

### B3. Household Activity Feed — Hardcoded Dimensions
- **קובץ:** `lib/screens/home/dashboard/widgets/household_activity_feed.dart`
- **בעיה:**
  - Avatar `width: 40, height: 40` (line 347-348) — hardcoded
  - Image `width: 32, height: 32` (line 88) — hardcoded
  - `indent: 64` (line 134) — fragile, depends on avatar size
  - `SizedBox(width: 6)` (line 286) — micro-spacing, not tokenized
  - `Icon(... size: 16)` (lines 114, 328) — should be `kIconSizeSmall`
- **תיקון:** הגדר constants או השתמש בקיימים
- **בדיקה:** visual comparison + RTL

### B4. Manage Users Screen — Hardcoded Icon Size
- **קובץ:** `lib/screens/settings/manage_users_screen.dart:405`
- **בעיה:** `Icon(Icons.group, size: 24)` — hardcoded דווקא בקוד ששונה. וגם `SizedBox(width: kSpacingSmall)` (line 406) חסר `const`
- **תיקון:** `size: kIconSizeMedium` + הוסף `const`
- **בדיקה:** verify no visual change (24 == kIconSizeMedium)

---

# Phase C — שיפורי קוד (Medium Priority)

### C1. Loading Overlay — Getter מייצר List בכל גישה
- **קובץ:** `lib/screens/auth/widgets/loading_overlay.dart:16-20`
- **בעיה:** שינוי מ-`static const` ל-getter `get _messages =>` מייצר list חדש בכל קריאה. אמנם 3 items, אבל זה anti-pattern
- **תיקון:** שנה ל-`late final List<String> _messages = [...]` או cache ב-initState
- **בדיקה:** compile + verify loading overlay still cycles messages

### C2. ShoppingListsProvider — Identity Check
- **קובץ:** `lib/providers/shopping_lists_provider.dart:161`
- **בעיה:** `if (_userContext == newContext) return;` — תלוי ב-`==` operator של `UserContext`. אם `UserContext` לא מגדיר `==`, ההשוואה היא by reference — עלולה לגרום ל-infinite loop או skip של updates
- **תיקון:** וודא ש-`UserContext` מגדיר `==` ו-`hashCode`, או השתמש ב-`identical()` אם by-reference מכוון
- **בדיקה:** login → switch household → verify lists update

### C3. Pending Invites — Email Auth Concern
- **קובץ:** `lib/services/pending_invites_service.dart:578-580`
- **בעיה:** אם `invitedUserId` הוא email (invite לפני הרשמה), ה-auth check מבוסס רק על email match. זה עובד, אבל צריך לוודא שה-email מגיע מ-Firebase Auth (verified) ולא מ-user input
- **תיקון:** הוסף comment שמסביר את הלוגיקה + verify ש-`acceptingUserEmail` מגיע מ-`userContext.userEmail` (Firebase Auth verified)
- **בדיקה:** send email invite → register with that email → accept → verify success

### C4. Firestore Compound Query Index
- **קובץ:** `lib/services/pending_invites_service.dart:358-363`
- **בעיה:** 4 where clauses = compound query שדורש Firestore index
- **תיקון:** וודא שהindex קיים ב-`firestore.indexes.json`
- **בדיקה:** run the query in Firebase Emulator / check console for missing index errors

---

# Phase D — תיעוד — File Headers (5 קבצים חסרים)

הוסף file header documentation בפורמט הקיים בפרויקט:

```dart
// 📄 File: path/to/file.dart
//
// 🎯 Purpose: [תיאור]
//
// 📋 Features:
// - Feature 1
// - Feature 2
//
// 🔗 Related: other_file.dart
```

### D1. `lib/screens/auth/widgets/loading_overlay.dart`
- **Purpose:** Overlay עם spinner + הודעות מתחלפות בזמן טעינת auth
- **Features:** Timer-based message cycling, localized strings, dispose safety

### D2. `lib/screens/auth/widgets/social_login_button.dart`
- **Purpose:** כפתור כניסה חברתית (Google/Apple) עם loading state
- **Features:** Disabled state, icon + text, loading spinner, haptic feedback

### D3. `lib/screens/shopping/active/widgets/active_shopping_item_tile.dart`
- **Purpose:** שורת פריט בקנייה פעילה עם 3 זונות (pending/in-cart/done)
- **Features:** Status-based colors, animated transitions, swipe actions

### D4. `lib/screens/shopping/active/widgets/shopping_summary_dialog.dart`
- **Purpose:** דיאלוג סיכום קנייה עם אפשרות לשמור קבלה
- **Features:** Store selection, rating, pending items options, receipt creation

### D5. `lib/widgets/common/barcode_scanner_sheet.dart`
- **Purpose:** Bottom sheet לסריקת ברקוד עם mobile_scanner
- **Features:** Camera permission, scan overlay, catalog lookup, error handling

---

# Phase E — עדכון Docs קיימים

### E1. עדכון CODE_REVIEW.md
- הוסף section "בעיות שנמצאו בסקירה חוזרת (24 מרץ 2026)"
- תעד את כל ממצאי Phase A-D
- עדכן ציון אחרי תיקונים

### E2. עדכון CLAUDE.md
- הוסף `kIconSizeSmallPlus` ו-`kIconSizeMediumPlus` לטבלת Design System (אם נוצרו)
- עדכן i18n coverage ל-~95%

### E3. עדכון REFACTOR_PLAN.md
- עדכן Phase 9 (i18n) סטטוס ל-~95%
- הוסף ממצאי code review session 3

---

# Phase F — TODO עתידי (תיעוד בלבד, לא לבצע עכשיו)

## אבטחה
| # | תיאור | מיקום | עדיפות |
|---|--------|-------|--------|
| T1 | `getUserHouseholdId()` — `get()` call budget (10 per rule eval). שקול caching | `firestore.rules` | Medium |
| T2 | Inventory validation חלקית — חסר `hasOnly` על שדות | `firestore.rules` | Medium |
| T3 | Email regex too restrictive — לא תומך TLDs ארוכים, plus addressing | `pending_invites_service.dart:227` | Low |

## ארכיטקטורה
| # | תיאור | מיקום | עדיפות |
|---|--------|-------|--------|
| T4 | **BaseProvider mixin** — `_notifySafe()` + `_isDisposed` + common getters ב-5 providers | 5 providers | High |
| T5 | **notifications_service** — 10 `createXNotification()` methods, 90% זהים → factory pattern | `notifications_service.dart` | Medium |
| T6 | **SocialAuthMixin** — נוצר, לא יושם ב-login+register | `social_auth_mixin.dart` | Low |
| T7 | **Dialog DRY** — `_confirmExit`, `_showErrorSnackBar` זהים ב-3 dialogs | 3 dialog files | Low |
| T8 | **File splitting** — 6 קבצים מעל 1,000 שורות | pantry, settings, providers | Medium |

## מודלים
| # | תיאור | מיקום | עדיפות |
|---|--------|-------|--------|
| T9 | `ShoppingList` — string-typed enums (`status`, `type`, `format`) → proper enums | `shopping_list.dart` | Medium |
| T10 | `FlexibleDateTimeConverter` — returns `DateTime.now()` on null/invalid → should return null | `timestamp_converter.dart` | Medium |
| T11 | `UnifiedListItem.checkedAt` — `String?` instead of `DateTime?` | `unified_list_item.dart` | Low |
| T12 | `Receipt` — חסרים `==`/`hashCode` overrides + `copyWith` | `receipt.dart` | Low |
| T13 | `CategoryInfo.label` captured at init, doesn't update on locale switch | `filters_data.dart` | Low |

## בדיקות
| # | תיאור | עדיפות |
|---|--------|--------|
| T14 | No Firebase service tests — ShoppingListsProvider, AuthService, NotificationsService | High |
| T15 | Screen tests = logic-only — בודקים פונקציות, לא widgets | Medium |
| T16 | InventoryProvider test חלקי — לא בודק CRUD/error states | Medium |
| T17 | No integration/golden tests — חסרים E2E flows + screenshots | Medium |
| T18 | `test/` excluded from analyzer — `analysis_options.yaml` line 10 | Low |

## UI/UX
| # | תיאור | עדיפות |
|---|--------|--------|
| T19 | Location dropdown duplicated in `pantry_item_dialog` + `pantry_product_selection_sheet` (~80 שורות) | Low |
| T20 | `readValue` helpers duplicated in `saved_contact` + `shared_user` (~30 שורות) | Low |
| T21 | `ShoppingListsProvider._repository` cast to concrete type | Low |
| T22 | CRUD reloads full list + real-time updates → double fetch | Medium |

## Known Warnings (Deferred)
| # | תיאור | מיקום |
|---|--------|-------|
| W1 | `use_build_context_synchronously` (2) | `settings_screen.dart` |
| W3 | `deprecated_member_use` — RadioListTile | `contact_selector_dialog.dart` (Flutter 3.33+) |

## Existing TODOs in Code
| # | TODO | מיקום |
|---|------|-------|
| E1 | Implement household-based low stock notifications | `my_pantry_screen.dart:551` |
| E2 | FCM — buttons saved in SharedPreferences but not connected to FCM | `settings_screen.dart:73` |
| E3 | GDPR — Cloud Function to delete Firestore data on account deletion | `settings_screen.dart:495` |
| E4 | `package_info_plus` — version display | `settings_screen.dart:1328` |

---

# סדר ביצוע מומלץ

```
Phase A (באגים קריטיים)     → 30 דקות
  A1 → A2 → A3

Phase B (UI/UX touch targets) → 45 דקות
  B1 → B2 → B3 → B4

Phase C (שיפורי קוד)         → 30 דקות
  C1 → C2 → C3 → C4

Phase D (File Headers)        → 20 דקות
  D1 → D2 → D3 → D4 → D5

Phase E (Docs)                → 15 דקות
  E1 → E2 → E3

dart analyze lib/              → verify 0 errors
```

**סה"כ: ~2.5 שעות עבודה**

---

# Acceptance Criteria

- [ ] `dart analyze lib/` — 0 errors, max 2 warnings (W1, W3)
- [ ] No size regressions — visual comparison of changed screens
- [ ] All 34 key files have documentation headers
- [ ] CODE_REVIEW.md updated with session 3 follow-up findings
- [ ] All Phase A fixes verified manually
- [ ] No hardcoded `fontSize:`, `size:`, `BorderRadius` in changed files
- [ ] Touch targets >= 44dp on interactive elements
- [ ] No `Colors.xxx` (except `Colors.transparent`)

---
*Work Plan v1.0 — MemoZap Code Review Session 3 Follow-up | 24 March 2026*
