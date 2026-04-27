# דוח Code Review — MemoZap
**תאריך:** 12 מרץ 2026 | עודכן: 27 אפריל 2026
**סוקר:** ראפטור
**גרסה:** 7.0

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
| W1 | `use_build_context_synchronously` (2) | `settings_screen.dart` | Warning | ⏳ deferred — יש `mounted` guards, ממתין לאימות analyzer |
| ~~W2~~ | ~~`directives_ordering` infos~~ | 31 files | Info | ✅ תוקן (סשן 6) — sort imports in 31 files |
| ~~W3~~ | ~~`deprecated_member_use` — RadioListTile~~ | `contact_selector_dialog.dart` | Warning | ✅ תוקן (סשן 4) — הוחלף ב-Radio + GestureDetector |

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
| קבצי Dart | ~168 |
| שורות קוד (lib/) | ~58,000 |
| Errors | **0** |
| Warnings | **1** (W1 — has `mounted` guards, pending verify) |
| Tests | 15 test files, 396 passing |
| i18n coverage | ~97% |
| Firestore Rules | v4.4 (כולל activity_log subcollection) |
| Firestore indexes | עודכן — 3 אינדקסים חסרים הוספו (סשן 6) |
| Android permissions | `CAMERA` הוסף (עבור barcode scanner) |

---

## היסטוריה

### סשן 7 (27 אפריל 2026) — סריקה רוחבית מעמיקה (15 סוכנים מקבילים)

**מטרה:** סריקה צולבת של כל ספריות הקוד הראשיות (`lib/core`, `lib/l10n`, `lib/models`, `lib/providers`, `lib/repositories`, `lib/services`, `lib/screens`, `lib/widgets`, `lib/theme`, `lib/layout`) + אודיט קטלוג מוצרים, עם 5 סבבים עמוקים לכל קובץ.

#### באגים אמיתיים שתוקנו
| תיקון | חומרה | קובץ |
|--------|--------|------|
| `'‎\${item.quantity} \${item.unit}'` — escape sequences שגויים גרמו להצגת `${item.quantity}` כטקסט במקום הערכים | **High (UI)** | `my_pantry_screen.dart:1592` |
| FCM token race ב-`clearToken()` — `_tokenSub` לא בוטל לפני `deleteToken()`, ה-SDK refresh callback יכל לכתוב טוקן חדש ל-Firestore doc של המשתמש הקודם | **High (privacy)** | `push_notification_service.dart` |
| `LimitStatus get status` ב-InventoryItem — שימוש הפוך של `getLimitStatus`. פריט ריק (`quantity=0`) החזיר `SAFE` במקום critical | **High (logic)** | `inventory_item.dart` |
| `TextEditingController` leak ב-`_askHouseholdName` (ללא dispose) | **Medium** | `register_screen.dart` |
| 8 באגי RTL — `EdgeInsets.only(left:/right:)` במקום `EdgeInsetsDirectional` (shopping screens, home dashboard, pantry chips) | **Medium** | `active_shopping_*`, `shopping_summary_dialog`, `shopping_list_details`, `suggestions_today_card`, `pantry_product_selection_sheet` |
| `_errorMessage = 'load_activity_failed'` (snake_case key) — מוצג ל-UI verbatim במקום מתורגם | **Medium (UX)** | `activity_log_provider.dart` |
| `if (url != null)` — מחרוזת ריקה הייתה עוברת ונכשלת ב-Image.network | **Low** | `app_layout.dart` |

#### קוד מת שנמחק
| מודול | פירוט |
|-------|-------|
| `core/constants.dart` | `kMaxSharedUsersPerList`, `kMaxLocationsPerHousehold` (ללא קוראים) |
| `l10n/app_strings.dart` | 5 namespaces ללא קוראים: `priceComparison`, `listTypeGroups`, `templates`, `selectList`, `recurring` |
| `l10n/locale_manager.dart` | `displayName`, `locale`, `isRtl`, `setLocaleByCode`, `toggleLocale` |
| Models (5 קבצים) | `saved_contact.copyWith`, `custom_location` (6 איברים), `user_entity` (4 factories), `shared_user` (2 factories + 6 permission getters), `active_shopper.isHelper`, `activity_event` (3 getters), `notification.inviterName + defaultColor`, `shopping_list` (5 getters), `receipt` (4 getters), `pending_request` (7 איברים) |
| Providers (6 קבצים) | `loadMore`, getters רבים מ-products, methods מ-shopping_lists ו-suggestions, `inventory.checkExpiryAndNotify` (40 שורות), `clearAll` ב-activity_log |
| Services | `home_widget.initialize` (אבל הסוכן זיהה שזה היה באג חבוי ל-iOS — תוקן באמצעות inline lazy init), `template.clearCache`, `notifications.createExpiryNotification`, `share_list.inviteUser/canUserEdit`, `pending_requests` (8 methods) |
| Repositories | `firebase_inventory` (6 מתודות), `firebase_products.clearCache`, `local_products.clearCache*`, `InventoryLocation` enum, dead branches ב-`firebase_user_repository`, 5 collections + 18 fields ב-`repository_constants` |
| Screens | `pantry_item_dialog.showAddDialog`, `social_auth_mixin.dart` (קובץ שלם), `CompactStat`/`buildDivider` ב-active_shopping_states |

#### l10n + תרגומים
| תיקון | פירוט |
|--------|-------|
| 25 פערי parity HE↔EN | overrides EN חסרים סומנו ונוצרו עם TODO markers |
| 31 תרגומים אנגלית | התרגומים הזמניים מ-`c5168496` הוחלפו בטקסט אנגלי מתאים (locations, pantry empty-state, reject request, invite family, וכו') |
| 22 `@override` שורות מיותרות | הוסרו מ-`app_strings_en.dart` |

#### אודיט קטלוג מוצרים (`assets/data/list_types/`)
| קובץ | תיקון |
|-------|--------|
| `butcher.json` | "אחר" ירד מ-278 ל-26. נוספה קטגוריה חדשה "נקניקים ובשרים מעובדים" (230 פריטים: נקניקיות, סלמי, פסטרמה, קבב). 22 פריטים נוספים סווגו לפי species (עוף/בקר/הודו) |
| `bakery.json` | "מאפים" ירד מ-175 ל-7. הפריטים חולקו ל-לחמים ולחמניות (60), עוגות (82), מאפים מזרחיים (20), מתוקים (4), מלוחים (2) |
| `pharmacy.json` | הוסרו 15 פריטים שלא שייכים (6 ניקיון, 9 מזון בריאות). אוחדה כפילות "אביזרי שיער" → "טיפוח שיער" |

#### דווח (לא תוקן — דורש scope גדול)
- **Pending invites guard לא מחווט** ב-login + register screens (CLAUDE.md דורש post-auth check כולל Google/Apple) — בעיית flow logic
- **~50 מחרוזות עברית קשיחות** ב-services + providers (Hebrew error prefixes, notification titles) — דורש הרחבת AppStrings
- **~30 שמות שדות Firestore קשיחים** ב-services שצריכים `FirestoreFields.*`
- **`active_shopping_screen` + `who_brings_screen`** לא re-watching ל-provider — שינויים בו-זמנית מקונים אחרים לא מתעדכנים live (פרה-קיים, ארכיטקטוני)
- **`category_detection_service`** — מלכודות substring: `'מנגו'`/`'מנגולד'`, `'תפוז'` לפני `'מיץ '` (מיץ תפוזים מסווג כפרי), `'תמר'` ללא רווח עוקב
- **`product_selection_bottom_sheet._failedImageUrls`** — Set גדל ללא הגבלה (memory leak פוטנציאלי בסשנים ארוכים)

#### סיכום כמותי (סשן 7)
| מדד | ערך |
|------|-----|
| Commits | **~24** |
| סוכנים מקבילים שהופעלו | **15** (3 גלים) |
| באגים אמיתיים שתוקנו | **8** (1 UI display, 1 privacy, 1 logic, 1 leak, 4+ RTL) |
| מתודות/מחלקות שנמחקו | **~80** (קוד מת) |
| תרגומים אנגליים שהושלמו | **31** |
| פערי parity HE↔EN שנסגרו | **25** |
| פריטי קטלוג שסווגו מחדש | **~395** (butcher 252 + bakery 168 + pharmacy 25) |

---

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
---

## מה בוצע (9 אפריל 2026 — סשן 5: Activity Log + CI Fixes + Deep Scan)

### Activity Log Feature (Complete)
- **Model**: `ActivityEvent` — 9 types (8 active + `unknown`), JsonSerializable
- **Service**: `ActivityLogService` — fire-and-forget writes to Firestore
- **Repository**: `ActivityLogRepository` — reads + cleanup (orderBy + deleteOldEvents)
- **Provider**: `ActivityLogProvider` — state management, registered in main.dart
- **8 injection points**: shopping_completed, shopping_started, shopping_joined, list_created, stock_updated, member_left, role_changed (×2 paths)
- **Dashboard**: `household_activity_feed.dart` — shows 5 latest events, fallback to receipts
- **History**: `shopping_history_screen.dart` — TabBar with Receipts + Activity Log tabs
- **Firestore rules**: `activity_log/{eventId}` subcollection under households
- **AppStrings**: 9 event descriptions + UI strings in Hebrew + English

### CI/Build Fixes
- Fixed merge conflict marker in `suggestions_today_card.dart:695`
- Fixed bracket mismatch in `shopping_history_screen.dart:549`
- Build #346 passed on `claude/dev`

### Demo Data Fixes
- `created_at`: changed from `.toISOString()` to `admin.firestore.Timestamp.fromDate()`
- Added missing `list_id` to 3 `shopping_started` events
- Added `member_left` event — all 9 types covered (27 events total)
- Added GitHub Action (`rebuild-demo-data.yml`) for running script from browser

### Deep Scan — Issues Resolved
- ~~B3~~ SavedContactsService — all 3 methods now rethrow properly ✅
- ~~kSticky colors~~ — all 40+ SnackBars use `brand?.sticky* ?? kSticky*` ✅

---

*Code Review v5.0 — Activity Log feature + deep scan | 9 April 2026*

---

## מה בוצע (18–22 אפריל 2026 — סשן 6: UX Polish + Lint Cleanup + Catalog Sanitization)

### UX/A11y overhaul (21 commits)
| מסך | שיפורים |
|------|---------|
| **Settings** (7 commits) | haptic throughout, theme card animation, tappable avatar + camera badge, logout card tint, colored icon hierarchy, animated delete card, section count fix, RTL camera badge, pull-to-refresh, version copy, Semantics labels |
| **History** (6 commits) | BiDi fixes, empty state animation, color-coded activity icons, staggered entrance, receipt haptic, filter scale animation, relative dates, stats gradient, receipt total summary, item+event a11y |
| **Welcome** (2 commits) | staggered benefits, card semantics, chip a11y, blur token, shadow match, carousel a11y |
| **Auth** (2 commits) | haptic, touch targets ≥44dp, semantics, design tokens, login_screen Semantics wrapper fix |
| **Pantry** (2 commits) | collapsible locations, notes indicator, low-stock pulse, pull-to-refresh, animated quantity counter |
| **Global UX** (3 commits) | premium haptic choreography, animated category collapse, haptic on 3 more screens, touch targets ≥44dp across 5 files |

### Lint Cleanup (10 commits) — resolves W2
| תיקון | היקף |
|--------|------|
| `@override` annotations | 1030 English string members + 32 more |
| `sort_imports` | **31 files** (resolves W2) |
| `prefer_is_empty` | כל המופעים |
| Curly braces, single quotes, underscores, final fields | רב |
| Deprecated APIs, unnecessary const, const assert, build context | 5 analyzer errors |
| `redundant_args`, `const`, `tearoff` ב-history screen | ניקוי נקודתי |

### תיקוני באגים
| תיקון | חומרה | פירוט |
|--------|--------|-------|
| Unsafe type casts | **High** | 4 casts שקרסו על Firestore data לא תקין |
| Self-invite guard | **Medium** | משתמש יכל להזמין את עצמו לבית |
| Empty household name | **Medium** | validation חסר — התאפשר בית ללא שם |
| Image upload cooldown | **Medium** | cooldown היה גלובלי → per-user |
| Missing Firestore indexes | **Medium** | 3 אינדקסים הוספו — compound queries |
| Android CAMERA permission | **High** | חסרה ב-AndroidManifest — barcode scanner נפל |
| BiDi numbers | **Low** | `fixBidiNumbers` יושם ב-4 display paths נוספים |

### i18n progress
- 5 hardcoded Hebrew fallbacks → AppStrings
- `'הבית'` fallback → `AppStrings.household.defaultName`
- i18n coverage: ~95% → ~97%

### Catalog sanitization (4 commits)
| תיקון | היקף |
|--------|------|
| שמות מותגים ארגוניים | 273 + 3 שמות נוקו מקטלוג מוצרים |
| מספרים דבוקים | 2,320 מספרים תוקנו |
| Trailing asterisks | 324 + 3 ב-butcher.json |
| Sanitization helper | חולץ + skip redundant rebuilds (5-role audit) |

### תיעוד
- **Dart file headers**: 154 קבצי Dart קיבלו header אחיד באנגלית
- **`.gitignore`**: `firebase_options.dart` נוסף (auto-generated)
- **CLAUDE.md**: תוקן typo `Flutter 3.38+` → `3.8+`

### סיכום כמותי (סשן 6)
| מדד | ערך |
|------|-----|
| Commits | **50** |
| קבצים ששונו | **~200+** (כולל lint על רב הקוד) |
| Warning שנפתר | **W2** (directives_ordering) |
| באגי type safety שתוקנו | **4** |
| אינדקסים חסרים שנוספו | **3** |
| הפרות design tokens שתוקנו | **~20** (7 files sized + 9 files const + 5 files 44dp) |
| Haptic/a11y improvements | **21** מסכים/ווידג'טים |

---

*Code Review v6.0 — UX polish + lint cleanup + catalog sanitization | 22 April 2026*
