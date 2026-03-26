# דוח Code Review — MemoZap
**תאריך:** 12 מרץ 2026 | עודכן: 26 מרץ 2026
**סוקר:** ראפטור
**גרסה:** 4.0

---

## ציון כללי: 8.5/10 — קוד נקי, ארכיטקטורה מוצקה, יש מה לשפר

---

## חוזקות

### ארכיטקטורה
- **Repository Pattern** — abstract interfaces + Firebase implementations
- **Provider + ChangeNotifier** — single source of truth דרך `UserContext`
- **Typed exceptions** — `AuthException`, `ShoppingListRepositoryException`
- **ConfigValidation mixin** — validation אחיד ב-3 config files
- **Immutable models** — `copyWith`, `List.unmodifiable`, sentinel pattern
- **AuthUser/SocialLoginResult DTOs** — providers don't import firebase_auth
- **Generation counter** — race condition protection ב-InventoryProvider

### Design System
- **Design Tokens** — `kSpacing*`, `kFontSize*`, `kIconSize*`, `kBorderRadius*` via `ui_constants.dart`
- **NotebookBackground** — 21/21 screens
- **Dark Mode** — צבעים מופחתי רוויה
- **RepaintBoundary** — שימוש עקבי בווידג'טים עם אנימציות
- **Haptic feedback** — `unawaited()` עם רמות מגע מותאמות

### אבטחה
- **Firestore Rules v4.4** — schema validation, audit trail, anti-spam, inventory hasOnly
- **Role-based access** — Owner/Admin/Editor/Viewer with approval flow
- **AuthException typed** — enum לסוגי שגיאות

---

## מה בוצע (24 מרץ 2026 — סשן 3: Code Review מעמיק)

### סריקה מלאה
סרקתי **138 קבצי Dart** (~54,000 שורות) ב-8 תחומים: ארכיטקטורה, מודלים, repositories, services, providers, UI/UX, אבטחה, בדיקות.

### תיקוני אבטחה (Firestore Rules v4.2 → v4.3)
| תיקון | חומרה | פירוט |
|--------|--------|-------|
| Household delete | **Critical** | כל חבר יכל למחוק household → רק `created_by` |
| Receipts validation | **High** | `allow read, write` ללא הגבלה → created_by enforcement + CRUD מפוצל |
| Group update fields | **High** | כל חבר יכל לשנות `created_by`/`members` → רק היוצר |
| pending_invites create | **Medium** | אין validation → `requester_id == auth.uid` + `request_data is map` |

### תיקוני Providers
| תיקון | חומרה | קובץ |
|--------|--------|------|
| `addStock` ignores household mode | **High** | `inventory_provider.dart:614` — תמיד שמר לנתיב אישי, גם כש-mode=household |
| `ReceiptProvider` missing `_isDisposed` | **High** | `receipt_provider.dart` — crash אחרי dispose. הוסף `_isDisposed` + `_notifySafe()` |
| `ShoppingListsProvider` identity check | **Medium** | `shopping_lists_provider.dart:161` — `updateUserContext` ללא `== newContext` guard |

### תיקוני Models (4 קבצים)
| תיקון | חומרה | פירוט |
|--------|--------|-------|
| `copyWith` nullable clearing | **High** | `SmartSuggestion`, `SharedUser`, `SavedContact`, `AppNotification` — לא ניתן היה לאפס שדות nullable ל-null (חסם undismiss, reset readAt). יושם sentinel pattern |

### תיקוני Repositories
| תיקון | חומרה | פירוט |
|--------|--------|-------|
| `deleteAllUserItems` batch overflow | **Medium** | `firebase_inventory_repository.dart` — batch יחיד ללא הגבלה → חלוקה ל-batches של 500 |
| Silent catch logging | **Medium** | 3 repositories — catch blocks שבלעו שגיאות ללא logging → `debugPrint` |

### תיקוני Theme
| תיקון | חומרה | פירוט |
|--------|--------|-------|
| Missing `stickyOrange` | **Medium** | `AppBrand` — חסר `stickyOrange` → הוסף field, constructor, copyWith, lerp, light+dark values |
| Butcher dark mode | **Medium** | `list_types_config.dart` — `kStickyOrange` hardcoded → `brand.stickyOrange` |

### תיקוני Design System (Widgets + Screens)
| סוג | כמות | דוגמאות |
|------|------|---------|
| Hardcoded Hebrew → AppStrings | ~20 strings | `household_activity_feed`, `home_dashboard`, `household_members`, `loading_overlay`, `shopping_summary_dialog` |
| `Colors.xxx` → theme colors | 5 | `app_layout` (Colors.black→cs.scrim), `shopping_summary_dialog` (Colors.black→cs.shadow), `manage_users` (withOpacity→withValues) |
| Hardcoded sizes → design tokens | ~25 | `pantry_item_dialog`, `pantry_empty_state`, `active_shopping_item_tile`, `manage_users_screen`, `social_login_button`, `tutorial_service` |
| NotebookBackground missing | 1 | `manage_users_screen` logged-out state |
| Hardcoded blur → constant | 1 | `app_layout` (10→kGlassBlurMedium) |
| Shadowed variable fix | 1 | `shopping_summary_dialog._buildPendingOptionsDialog` |
| Deprecated API | 1 | `manage_users_screen` (withOpacity→withValues) |

### מחרוזות חדשות שנוספו ל-AppStrings
| מחלקה | מחרוזות |
|--------|---------|
| `CommonStrings` | `optional` |
| `AuthStrings` | `loadingCheckingDetails`, `loadingConnecting`, `loadingAlmostThere` |
| `HomeDashboardStrings` | `activityFeedTitle`, `youLabel`, `householdMember`, `completedShoppingAt()`, `plusItems()`, `minutesAgo()`, `hoursAgo()`, `activeListsSubtitle()`, `userFallback` |
| `HouseholdStringsEn` | English overrides for household strings |

### סיכום כמותי (סשן 3)
| מדד | ערך |
|------|-----|
| קבצים ששונו | **35** |
| שורות נוספו/שונו | **~370** |
| באגי אבטחה שתוקנו | **4** |
| באגי לוגיקה שתוקנו | **5** |
| הפרות design system שתוקנו | **~50** |

---

## בעיות פתוחות

### לתקן (עדיפות גבוהה)
| # | בעיה | מיקום | חומרה | סטטוס |
|---|-------|-------|--------|--------|
| W1 | `use_build_context_synchronously` (2) | `settings_screen.dart` | Warning | ⏳ deferred — פתוח |
| W3 | `deprecated_member_use` — RadioListTile | `contact_selector_dialog.dart` | Warning | ✅ תוקן — הוחלף ב-Radio + GestureDetector |

### לתקן (עדיפות בינונית)
| # | בעיה | מיקום | סטטוס |
|---|-------|-------|--------|
| ~~S6~~ | ~~`getUserHouseholdId()` — `get()` call budget~~ | `firestore.rules` | ✅ תוקן — single call via `isHouseholdMember()` |
| ~~S7~~ | ~~Inventory validation חלקית — חסר `hasOnly` על שדות~~ | `firestore.rules` | ✅ תוקן — `hasOnly(inventoryAllowedFields())` |
| M2 | `ShoppingList` — string-typed enums (`status`, `type`, `format`) | `shopping_list.dart` | פתוח |
| ~~M3~~ | ~~`FlexibleDateTimeConverter` — returns `DateTime.now()` on null/invalid~~ | `timestamp_converter.dart` | ✅ תוקן — fallback → epoch sentinel |
| ~~M6~~ | ~~`UnifiedListItem.checkedAt` — `String?` instead of `DateTime?`~~ | `unified_list_item.dart` | ✅ תוקן — `DateTime?` + sentinel copyWith |
| ~~M8~~ | ~~`ShoppingListsProvider._repository` cast to concrete type~~ | `shopping_lists_provider.dart` | ✅ כבר תקין — abstract interface |
| ~~M9~~ | ~~CRUD reloads full list + real-time updates → double fetch~~ | `shopping_lists_provider.dart` | ✅ תוקן — הוסר `loadLists()` מ-5 CRUD methods |
| ~~P1~~ | ~~`CategoryInfo.label` captured at init, doesn't update on locale switch~~ | `filters_data.dart` | ✅ כבר מיושם עם lazy `_labelFn()` |

### Refactor עתידי (Post-launch)
| # | בעיה | היקף |
|---|-------|------|
| D1 | **BaseProvider mixin** — `_notifySafe()` + common getters ב-5 providers | ~50 שורות כפולות |
| D2 | **notifications_service** — 10 `createXNotification()` methods, 90% זהים | ~300 שורות |
| D3 | **SocialAuthMixin** — נוצר, לא יושם ב-login+register | `social_auth_mixin.dart` |
| D5 | **Dialog DRY** — `_confirmExit`, `_showErrorSnackBar` זהים ב-3 dialogs | ~40 שורות |
| F1 | **File splitting** — 6 קבצים מעל 1,000 שורות | pantry, settings, providers |
| R1 | **Receipt** — חסרים `==`/`hashCode` overrides + `copyWith` | `receipt.dart` |
| R2 | **Location dropdown** — duplicated in `pantry_item_dialog` + `pantry_product_selection_sheet` | ~80 שורות |
| R3 | **readValue helpers** — duplicated in `saved_contact` + `shared_user` | ~30 שורות |

### Dead code (נשאר — API עתידי)
| service | dead methods |
|---------|-------------|
| pending_requests_service | 6 methods |
| suggestions_service | 5 methods |
| shopping_patterns_service | 2 methods |

### בדיקות — פערים עיקריים
| פער | פירוט |
|------|-------|
| No Firebase service tests | ShoppingListsProvider, AuthService flows, NotificationsService |
| Screen tests = logic-only | בודקים פונקציות מקומיות, לא את הווידג'ט בפועל |
| InventoryProvider test חלקי | לא בודק CRUD operations או error states |
| No integration/golden tests | חסרים E2E flows + screenshots |
| test/ excluded from analyzer | `analysis_options.yaml` line 10 |

---

## סטטיסטיקות

| מדד | ערך |
|-----|-----|
| קבצי Dart | 155 |
| שורות קוד (lib/) | ~54,000 |
| Errors | **0** |
| Warnings | **2** (W1 — deferred, W3 resolved) |
| Tests | 15 test files, 323 passing |
| i18n coverage | ~95% |
| Firestore Rules | v4.4 |

---

## היסטוריה

### סשן 4 (24 מרץ 2026) — תיקוני Warnings + Data Quality + Performance
- W3: החלפת `RadioListTile` deprecated → `Radio` + `GestureDetector`
- M3: `FlexibleDateTimeConverter` fallback — `DateTime.now()` → epoch sentinel
- M6: `checkedAt` — `String?` → `DateTime?` + `NullableFlexibleDateTimeConverter` + sentinel copyWith
- M8: אומת — כבר תקין (abstract interface)
- M9: הוסר `loadLists()` מ-5 CRUD methods — stream listener מטפל בעדכונים
- S6: `getUserHouseholdId()` — single call במקום double (חיסכון ב-get() budget)
- S7: Inventory — `hasOnly(inventoryAllowedFields())` מונע שדות שרירותיים
- P1: אומת — כבר מיושם עם lazy `_labelFn()`
- תיקוני אימוג'י, קטגוריות, שמות מוצרים, RTL כפתורי +/-

### סשן 3 (24 מרץ 2026) — Code Review מעמיק + תיקונים
- סריקת כל 138 קבצים לעומק
- 4 תיקוני אבטחה קריטיים ב-Firestore rules
- 5 תיקוני באגי לוגיקה (providers, models)
- ~50 תיקוני design system
- ~20 מחרוזות עברית → AppStrings
- 35 קבצים ששונו

### סשן 2 (18 מרץ 2026)
- ~120 hardcoded sizes → design tokens
- ~20 Hebrew strings → AppStrings
- ~40 missing `const`
- PopScope, RTL fixes, dead code removal

### סשן 1 (12-16 מרץ 2026)
- ~4,490 שורות נמחקו (dead code, onboarding, duplicates)
- SocialAuthMixin, ConfigValidation mixin
- Active shopping, list details redesign
- Edge case demo data

---
*Code Review v4.3 — Updated stats + W1 status corrected | 26 March 2026*
