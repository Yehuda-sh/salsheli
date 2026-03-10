# MemoZap

## Project Overview

אפליקציית ניהול קניות משפחתית חכמה עם עיצוב **Notebook + Sticky Notes**.

**פיצ'רים עיקריים:**
- רשימות קניות משותפות בזמן אמת (9 סוגים)
- מזווה דיגיטלי עם התראות מלאי נמוך
- שיתוף רשימות עם תפקידים (Owner/Admin/Editor/Viewer)
- קנייה משותפת עם סנכרון בזמן אמת
- היסטוריית קניות וסיכומים

**Package:** `com.memozap.app`

---

## Tech Stack

- **Framework:** Flutter 3.8+ / Dart 3.8.1+
- **Backend:** Firebase (Auth, Firestore, Storage, Analytics, Crashlytics, Messaging)
- **State:** Provider + ChangeNotifier
- **UI:** Hebrew RTL first, Material 3, Dark Mode

---

## Design System

| Token | Values |
|-------|--------|
| Spacing | 8-pt grid via `AppTokens` (4, 8, 12, 16, 24, 32) |
| Border Radius | `kBorderRadiusSmall(8)`, `Default(12)`, `Large(16)`, `XLarge(24)` |
| Typography | `kFontSizeTiny(10)` → `kFontSizeDisplay(34)` — 8 sizes |
| Colors | **Theme only** — `Theme.of(context).colorScheme` or `context.cs` |
| Background | `NotebookBackground()` on all 21 screens |
| Imports | `package:memozap/` — NOT `package:salsheli/` |

**Rules:**
- ❌ No `Colors.xxx` (except `Colors.transparent`)
- ❌ No hardcoded `fontSize:` — use `kFontSize*` constants
- ❌ No hardcoded `BorderRadius` — use `kBorderRadius*` constants
- ✅ Use `context.cs` / `context.tt` extensions for theme access

---

## Project Guardrails (DO NOT CHANGE WITHOUT EXPLICIT APPROVAL)

### Review Workflow
- 3-5 שאלות הבהרה עם אפשרויות א/ב/ג
- **בלי קטעי קוד בשאלות**
- בכל שאלה להוסיף **"המלצת הסוכן"**

### Welcome Screen
- מופיע **רק** עד יצירת חשבון
- **Logout רגיל לא מחזיר** Welcome
- **מחיקת נתונים כן מחזירה** Welcome

### seenOnboarding
- נדלק אחרי login/register הצלחה (כולל Google/Apple)
- **נשמר אחרי Logout** (לא מתאפס)

### Auth Screens
- **נקיים, לא Sticky Notes** — עיצוב מינימליסטי

### Pending Invites
- בדיקה אחרי register/login (כולל Google/Apple)
- guard אם אין email/phone

### IDs/Keys (Config)
- כל ID/key חייב **resolve()** עם fallback:
  - **"other"** — למשתמש (UI-safe)
  - **"unknown"** — לדיבאג בלבד
- **ensureSanity()** בקונפיגים
- **Backward compatible** — aliases לערכים ישנים

### AnimatedButton
- **אפקט בלבד** — הפעולה ב-parent
- haptic רק ל-CTA (לא לניווט)
- scale: **0.97–0.98**
- אנימציה מתחילה ב-**tap-down**

---

## Key Commands

```bash
dart analyze lib/    # חובה לפני כל commit
flutter test         # חובה לפני כל PR
flutter run          # הרצה
```

---

## Key Files

| תחום | קבצים |
|------|-------|
| **Theme** | `lib/theme/design_tokens.dart`, `app_theme.dart`, `context_extensions.dart`, `app_transitions.dart` |
| **Constants** | `lib/core/ui_constants.dart`, `status_colors.dart` |
| **Config** | `lib/config/list_types_config.dart`, `stores_config.dart`, `filters_config.dart` |
| **Models** | `lib/models/shopping_list.dart`, `unified_list_item.dart`, `user_entity.dart`, `inventory_item.dart` |
| **Providers** | `lib/providers/user_context.dart`, `shopping_lists_provider.dart`, `inventory_provider.dart` |
| **Shared Widgets** | `lib/widgets/common/` — NotebookBackground, StickyNote, EmptyState, AppSnackBar, AppDialog |
| **Strings** | `lib/l10n/app_strings.dart` |
| **Security** | `firestore.rules` (v4.1), `firestore.indexes.json` |

---

## Dependency-First Ordering

סדר עבודה:
1. Model / Schema
2. Repository / Service
3. Provider / State
4. UI / Widgets
5. Strings (AppStrings)
6. Tests & analyze

---

## Known Issues

- ~~**B1:** approve/reject בpending_requests~~ ✅ תוקן
- ~~**B2:** ניווט מהתראות~~ ✅ תוקן
- **B3:** SavedContactsService בולע שגיאות
- ~~**B4:** Firebase config~~ ✅ תוקן — google-services.json כולל שני package names

See [CODE_REVIEW.md](CODE_REVIEW.md) for full status.

---

## Related Docs

- [CODE_REVIEW.md](CODE_REVIEW.md) — דוח ריוויו + סטטוס תיקונים
- [docs/REFACTOR_PLAN.md](docs/REFACTOR_PLAN.md) — תוכנית ריפקטור 9 שלבים
