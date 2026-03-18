# 🔍 דוח Code Review — MemoZap
**תאריך:** 12 מרץ 2026 | עודכן: 18 מרץ 2026
**סוקר:** ראפטור 🦖
**גרסה:** 3.1

---

## 📊 ציון כללי: 9/10 — קוד נקי, ארכיטקטורה מוצקה

---

## ✅ חוזקות

### ארכיטקטורה
- **Repository Pattern** — abstract interfaces + Firebase implementations
- **Provider + ChangeNotifier** — single source of truth דרך `UserContext`
- **Typed exceptions** — `AuthException`, `ShoppingListRepositoryException`
- **ConfigValidation mixin** — validation אחיד ב-3 config files
- **Immutable models** — `copyWith`, `List.unmodifiable`, sentinel pattern
- **AuthUser/SocialLoginResult DTOs** — providers don't import firebase_auth

### Design System
- **0 Colors.xxx** — הכל דרך theme
- **NotebookBackground** — 21/21 screens
- **Design Tokens** — `kSpacing*`, `kFontSize*`, `kIconSize*`, `kBorderRadius*` via `ui_constants.dart`
- **Dark Mode** — צבעים מופחתי רוויה

### אבטחה
- **Firestore Rules v4.2** — schema validation, audit trail, anti-spam, 4 security fixes
- **Role-based access** — Owner/Admin/Editor/Viewer with approval flow
- **AuthException typed** — enum לסוגי שגיאות
- **Null-safe models** — all 10 models with `@JsonKey(defaultValue: '')`

---

## ⚠️ בעיות פתוחות

### 🔴 לתקן
| # | בעיה | מיקום |
|---|-------|-------|
| W1 | `use_build_context_synchronously` (2) | `settings_screen.dart:566,1285` |
| W2 | `directives_ordering` infos | כמה קבצים (cosmetic) |
| W3 | `deprecated_member_use` — RadioListTile | `contact_selector_dialog.dart` (Flutter 3.33+) |

### 🟡 Refactor עתידי (Post-launch)
| # | בעיה | היקף |
|---|-------|------|
| D1 | **BaseProvider mixin** — `_notifySafe()` + common getters ב-5 providers | ~50 שורות כפולות |
| D2 | **notifications_service** — 10 `createXNotification()` methods, 90% זהים | ~300 שורות |
| D3 | **SocialAuthMixin** — נוצר, לא יושם ב-login+register | `social_auth_mixin.dart` |
| D5 | **Dialog DRY** — `_confirmExit`, `_showErrorSnackBar` זהים ב-3 dialogs (PopScope added to product+task dialogs) | ~40 שורות remaining |
| F1 | **File splitting** — 6 קבצים מעל 1,000 שורות | pantry, settings, providers... |

### 🟢 Dead code (נשאר — API עתידי)
| service | dead methods |
|---------|-------------|
| pending_requests_service | 6 methods |
| suggestions_service | 5 methods |
| shopping_patterns_service | 2 methods |

---

## 📈 מה בוצע (18 מרץ 2026 — סשן 2)

### קבצים שנסקרו ותוקנו
| קובץ | תיקונים עיקריים |
|------|-----------------|
| `pantry_suggestions.dart` | dismiss bug, RTL, tap targets, didUpdateWidget |
| `dev_banner.dart` | fontSize token |
| `add_edit_product_dialog.dart` | PopScope, deprecated fix, async signature |
| `add_edit_task_dialog.dart` | PopScope, deprecated fix, DRY dropdown, tap target |
| `shopping_list_urgency.dart` | removed dead `sortWeight` |
| `shopping_list_tile.dart` | division guard, RTL, tap targets, tokens |
| `shopping_list_tags.dart` | fontSize tokens, hardcoded string → AppStrings |
| `product_selection_bottom_sheet.dart` | ~40 tokens, AppStrings, RTL, tap targets, dead code |
| `main_navigation_screen.dart` | clean ✅ |
| `index_view.dart` | shadowed vars, const, hardcoded size |
| `index_screen.dart` | clean ✅ |
| `welcome_screen.dart` | tokens, cancelable timers, const |
| `shopping_summary_screen.dart` | tokens |
| `who_brings_screen.dart` | 7 AppStrings, tokens, tap targets, empty catch |
| `shopping_lists_screen.dart` | tokens, unawaited, const, tap target |
| `shopping_list_details_screen.dart` | AppStrings, tokens, hardcoded Hebrew |
| `contact_selector_dialog.dart` | tokens, AppStrings, const, debugPrint |
| `create_list_screen.dart` | tokens, const, RTL fix |
| `template_picker_dialog.dart` | tokens, const |
| `checklist_screen.dart` | tokens, const, Hebrew string |
| `active_shopping_screen.dart` | tokens, const, silent catch |
| `active_shopping_item_tile.dart` | tokens, shadowed var fix |
| `CLAUDE.md` | fix stale refs, add rules |

### סוגי תיקונים
| סוג | כמות |
|-----|------|
| Hardcoded sizes → design tokens | ~120 |
| Hardcoded Hebrew → AppStrings | ~20 strings |
| Missing `const` | ~40 |
| Missing `unawaited()` | ~10 |
| RTL fixes (BorderRadiusDirectional) | 5 |
| PopScope back-button guards | 2 dialogs |
| Tap targets < 44px | ~10 |
| Silent catch → debugPrint | 4 |
| Dead code removed | `sortWeight`, empty if/else |
| Shadowed variables | 4 |
| Deprecated API fixes | `value:` → `initialValue:` (2) |
| `Future.delayed` → cancelable Timer | 3 |

---

## 📈 מה בוצע (12-16 מרץ 2026 — סשן 1)

### שורות שנמחקו
| סוג | שורות |
|-----|-------|
| Empty `kDebugMode` blocks | ~700 |
| Onboarding flow (7 files) | ~3,258 |
| Dead getters/methods/imports | ~70 |
| Duplicate widgets | 194 |
| Dead color constants | ~50 |
| PendingRequestsSection rewrite | ~218 |
| **סה"כ נמחק** | **~4,490** |

### קוד שנוצר/שודרג
| קובץ/פיצ'ר | תפקיד |
|-------------|--------|
| `SocialAuthMixin` | DRY — shared Google/Apple login |
| `ConfigValidation` mixin | DRY — shared config validation |
| `AppErrorState/AppLoadingSkeleton/SectionHeader` | Reusable UI |
| Active shopping screen | Wake Lock, 3-zone tiles, quantity picker, haptics |
| List details screen | Planning redesign, inline search, dual FABs |
| Shopping summary | Celebration animations |
| Last Chance Banner | Horizontal chips layout |
| Barcode scanner | mobile_scanner + catalog lookup |
| PopScope back-button | Confirmation dialog in active shopping |
| Edge case demo data | 12 users, all scenarios |

---

## 📊 סטטיסטיקות

| מדד | ערך |
|-----|-----|
| קבצי Dart | ~142 |
| שורות קוד (lib/) | ~54,000 |
| Errors | **0** |
| Warnings | **2** (known W1, deferred) |
| Tests | **335/335** pass |
| Demo users | **12** |
| i18n coverage | ~90% (+20 strings in session 2) |

---
*🦖 ראפטור — Full lib/ Code Review | March 2026*
