# MemoZap (סלשלי)

## Project Overview

אפליקציית ניהול קניות משפחתית חכמה.

**פיצ'רים עיקריים:**
- רשימות קניות משותפות בזמן אמת (9 סוגים)
- מזווה דיגיטלי עם התראות מלאי נמוך
- שיתוף רשימות עם משתמשים אחרים
- קנייה משותפת עם סנכרון בזמן אמת
- היסטוריית קניות

**סגנון:** WhatsApp-like - פשוט ונקי

---

## Tech Stack

- **Framework:** Flutter 3.8.1+ / Dart 3.8.1+
- **Backend:** Firebase (Auth, Firestore, Storage, Analytics)
- **State:** Provider + ChangeNotifier
- **UI:** Hebrew RTL first, Material You support

---

## Project Guardrails (DO NOT CHANGE WITHOUT EXPLICIT APPROVAL)

### Product Style
- **WhatsApp-like, keep it simple**
- לא להוסיף מורכבות מיותרת
- UI נקי וברור

### Review Workflow
- 3-5 שאלות הבהרה עם אפשרויות א/ב/ג
- **בלי קטעי קוד בשאלות**
- בכל שאלה להוסיף סעיף **"המלצת הסוכן"**

### Welcome Screen
- מופיע **רק** עד יצירת חשבון
- **Logout רגיל לא מחזיר** Welcome
- **מחיקת נתונים כן מחזירה** Welcome

### seenOnboarding
- נדלק אחרי login/register הצלחה (כולל Google/Apple)
- **נשמר אחרי Logout** (לא מתאפס)

### Auth Screens
- **נקיים, לא Sticky Notes**
- עיצוב מינימליסטי ומקצועי

### Pending Invites (שיתוף רשימות)
- בדיקה אחרי register/login (כולל Google/Apple)
- guard אם אין email/phone (לא לקרוס)

### IDs/Keys (Config)
- כל ID/key חייב **resolve()** עם fallback:
  - **"other"** - למשתמש (UI-safe, מוצג כ"אחר")
  - **"unknown"** - לדיבאג בלבד (לא להציג ב-UI!)
- **ensureSanity()** בקונפיגים - בדיקות debug לעקביות
- **Backward compatible** - aliases לערכים ישנים
- לא לשנות IDs קיימים בלי migration plan

### AnimatedButton
- **אפקט בלבד** - לא מפעיל פעולה (הפעולה ב-parent)
- שומר ripple ונגישות (Semantics, Tooltip)
- **haptic רק ל-CTA** (לא לניווט רגיל)
- disabled שקט (לא אפקטים)
- scale עדין: **0.97–0.98** (כמעט לא מורגש)
- אנימציה מתחילה ב-**tap-down** (לא אחרי הפעולה)

---

## Key Commands

```bash
flutter analyze    # חובה לפני כל PR
flutter test       # חובה לפני כל PR
flutter run        # הרצה
```

---

## Key Files

| תחום | קבצים |
|------|-------|
| **Config** | `lib/config/list_types_config.dart`, `stores_config.dart`, `filters_config.dart`, `storage_locations_config.dart` |
| **Models** | `lib/models/shopping_list.dart`, `unified_list_item.dart`, `user_entity.dart`, `inventory_item.dart`, `receipt.dart` |
| **Providers** | `lib/providers/user_context.dart`, `shopping_lists_provider.dart`, `inventory_provider.dart`, `receipt_provider.dart` |
| **Strings** | `lib/l10n/app_strings.dart` |

---

## Dependency-First Ordering

סדר עבודה ל-Flutter:
1. Model/Schema/Converters
2. Repository/Service
3. Provider/State
4. UI
5. Strings (AppStrings)
6. Tests & analyze

---

## Related Docs

- [docs/PRD_BUILDER.md](docs/PRD_BUILDER.md) - תבנית PRD + guardrails מפורטים + acceptance criteria
- [docs/MASTER-TODO.md](docs/MASTER-TODO.md) - משימות ובאגים לפי עדיפות
- [docs/progress.txt](docs/progress.txt) - מעקב התקדמות אפיק נוכחי
