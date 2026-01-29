# MemoZap PRD Builder

מסמך זה מגדיר את התבנית והכללים ליצירת PRD (Product Requirements Document) עבור פרויקט MemoZap.

---

## Overview

### מטרת המסמך
- להגדיר תבנית אחידה לכל פיצ'ר/אפיק חדש
- לשמור על עקביות בכל השינויים בפרויקט
- לוודא שכל ההחלטות שננעלו (guardrails) נשמרות

### איך להשתמש
1. לפני תחילת עבודה על פיצ'ר - לקרוא את ה-Guardrails
2. למלא את תבנית ה-PRD לפיצ'ר החדש
3. לעדכן את `progress.txt` במהלך העבודה
4. לוודא שכל ה-Acceptance Criteria מתקיימים לפני סיום

---

## Project Guardrails (Must Not Change Without Explicit Approval)

### Product Style
- **WhatsApp-like, keep it simple**
- לא להוסיף מורכבות מיותרת
- UI נקי וברור

### Review Workflow
- 3-5 שאלות הבהרה עם אפשרויות א/ב
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
- הזמנות לרשימות קניות (לא קבוצות - הוסר)

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

## Dependency-First Ordering

סדר העבודה ל-Flutter/Firebase:

| # | שלב | תיאור | דוגמה |
|---|-----|-------|-------|
| 1 | **Model/Schema/Converters** | מודלים, JSON converters, enums | `unified_list_item.dart` |
| 2 | **Repository/Service** | גישה לנתונים, Firebase | `firebase_*_repository.dart` |
| 3 | **Provider/State** | ניהול state | `shopping_lists_provider.dart` |
| 4 | **UI** | מסכים וwidgets | `*_screen.dart`, `*_widget.dart` |
| 5 | **Strings (AppStrings)** | טקסטים ותרגומים | `app_strings.dart` |
| 6 | **Tests & analyze** | בדיקות ואימות | `flutter test`, `flutter analyze` |

**חשוב:** לא לדלג על שלבים! תלויות חייבות להיות מוכנות לפני שממשיכים.

---

## PRD Layout (תבנית לפיצ'ר)

```markdown
# [שם הפיצ'ר]

## Summary
תיאור קצר של מה הפיצ'ר עושה ולמה הוא נדרש.

## Clarification Questions (שאלות הבהרה)

ברירת מחדל א/ב. אם צריך, אפשר ג (אחר/לא רלוונטי).

| # | שאלה | א | ב | ג (אופציונלי) | תשובה | המלצת הסוכן |
|---|------|---|---|---------------|-------|-------------|
| 1 | [שאלה] | [א] | [ב] | [ג/אחר] | [א/ב/ג] | [המלצה + נימוק קצר] |
| 2 | [שאלה] | [א] | [ב] | - | [א/ב] | [המלצה + נימוק קצר] |

## User Stories
רשימת הסיפורים (ראה תבנית למטה)

## Technical Notes
- Dependencies
- קבצים שישתנו
- APIs נדרשים

## Out of Scope (חובה!)
מה **לא** כלול בפיצ'ר הזה - חובה למלא כדי למנוע scope creep

## Acceptance Criteria
קריטריונים לסיום (כולל הקבועים)
```

---

## User Story Template

```markdown
### Story [#]: [כותרת קצרה]

**As a** [סוג משתמש]
**I want** [מה רוצה]
**So that** [למה/ערך]

#### Tasks
- [ ] Task 1 (Model/Schema)
- [ ] Task 2 (Repository)
- [ ] Task 3 (Provider)
- [ ] Task 4 (UI)
- [ ] Task 5 (Strings)

#### Acceptance Criteria
**קבועים (תמיד):**
- [ ] `flutter analyze passes`
- [ ] `flutter test passes`
- [ ] Guardrails preserved (no regressions to Welcome/Auth/Invites/AnimatedButton/IDs rules)

**ל-UI stories:**
- [ ] Verify UI works on Android emulator (RTL) for: [screen/flow to verify]
- [ ] iOS simulator (if relevant): [screen/flow]

**ל-data/IDs stories:**
- [ ] resolve() with fallback ("other" for UI, "unknown" for debug only)
- [ ] ensureSanity() debug checks added
- [ ] Backward compatible (aliases for old values)
- [ ] No "unknown" values shown in UI

**ספציפיים לסיפור:**
- [ ] [קריטריון 1]
- [ ] [קריטריון 2]
```

---

## Output Requirements

### לכל PR/שינוי

| דרישה | פקודה | חובה? |
|-------|-------|-------|
| **Static analysis** | `flutter analyze` | תמיד |
| **Tests** | `flutter test` | תמיד |
| **UI verification** | Android emulator (RTL) | UI changes |
| **iOS verification** | iOS simulator | אם רלוונטי |
| **Backward compatibility** | בדיקה ידנית | data/IDs changes |
| **resolve() + ensureSanity()** | בדיקת קוד | config/IDs changes |

### Checklist לפני סיום

```
[ ] flutter analyze passes
[ ] flutter test passes
[ ] No new warnings introduced (existing warnings OK)
[ ] RTL verified on emulator for: [screens/flows]
[ ] Guardrails preserved (no regressions)
[ ] Out of Scope documented
[ ] progress.txt updated
```

---

## Progress Tracking

### קובץ progress.txt

מיקום: `docs/progress.txt`

תפקיד: מעקב התקדמות בזמן אמת על פיצ'ר/אפיק פעיל.

### איך לעדכן
1. בתחילת עבודה - לעדכן Epic ו-Status
2. בכל סיום story - לסמן ולהוסיף הערות
3. בסיום - לאפס לפיצ'ר הבא

### תבנית progress.txt

```
# MemoZap PRD Progress

## Current Epic: [שם האפיק]
## Status: [ ] Planning / [x] In Progress / [ ] Review / [ ] Done

### Stories
| # | Story | Status | Notes |
|---|-------|--------|-------|
| 1 | [שם] | [x] Done | |
| 2 | [שם] | [ ] In Progress | [הערה] |
| 3 | [שם] | [ ] Pending | |

### Blockers
- [אם יש חסימות]

### Last Updated: [תאריך]
```

---

## Quick Reference

### פקודות נפוצות

```bash
# בדיקות
flutter analyze
flutter test
flutter test --coverage

# Build
flutter build apk --debug
flutter build ios --debug

# Run
flutter run
```

### קבצי Config חשובים

| קובץ | תפקיד |
|------|-------|
| `lib/config/list_types_config.dart` | סוגי רשימות |
| `lib/config/stores_config.dart` | חנויות |
| `lib/config/filters_config.dart` | פילטרים |
| `lib/config/storage_locations_config.dart` | מיקומי אחסון |
| `lib/l10n/app_strings.dart` | טקסטים |

### תיקיית Models

| קובץ | תפקיד |
|------|-------|
| `lib/models/shopping_list.dart` | רשימת קניות |
| `lib/models/unified_list_item.dart` | פריט (מוצר/משימה) |
| `lib/models/user_entity.dart` | משתמש |
| `lib/models/inventory_item.dart` | פריט במזווה |
| `lib/models/receipt.dart` | קבלה/היסטוריה |

---

## Related Documents

- [MASTER-TODO.md](./MASTER-TODO.md) - רשימת משימות כללית
- [firebase-schema.md](./technical/firebase-schema.md) - סכמת Firebase
- [providers-flow.md](./technical/providers-flow.md) - זרימת Providers

---

**נוצר:** ינואר 2026
**עודכן לאחרונה:** ינואר 2026
