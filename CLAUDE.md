# MemoZap

## Project Overview

אפליקציית ניהול קניות משפחתית חכמה עם עיצוב **Notebook + Sticky Notes**.

**פיצ'רים עיקריים:**
- רשימות קניות משותפות בזמן אמת (9 סוגים)
- מזווה דיגיטלי עם התראות מלאי נמוך
- שיתוף רשימות עם תפקידים (Owner/Admin/Editor/Viewer)
- קנייה משותפת עם סנכרון בזמן אמת
- היסטוריית קניות וסיכומים
- יומן פעילות משפחתי (Activity Log)

**Package:** `com.memozap.app`

---

## Tech Stack

Flutter 3.8+ / Dart 3.8.1+ · Firebase (Auth/Firestore/Storage/Analytics/Crashlytics/Messaging) · Provider + ChangeNotifier · Hebrew RTL-first · Material 3 · Dark Mode.

---

## Design System

| Token | Values |
|-------|--------|
| Spacing | `kSpacing*` via `ui_constants.dart` (XTiny=4, Tiny=6, Small=8, SmallPlus=12, Medium=16, Large=24, XLarge=32) |
| Border Radius | `kBorderRadiusSmall(8)`, `Default(12)`, `Large(16)`, `XLarge(24)` |
| Typography | `kFontSizeTiny(10)` → `kFontSizeDisplay(34)` — 8 sizes |
| Icons | `kIconSizeSmall(16)`, `SmallPlus(20)`, `Medium(24)`, `MediumPlus(28)`, `Large(36)`, `XLarge(48)`, `XXLarge(64)` |
| Colors | **Theme only** — `Theme.of(context).colorScheme` |
| Background | `NotebookBackground()` on all 21 screens |
| Imports | **Relative** in lib/ (`../../core/...`) — `package:memozap/` only in `main.dart` |

**Rules:**
- ❌ No `Colors.xxx` (except `Colors.transparent`)
- ❌ No hardcoded `fontSize:` — use `kFontSize*` constants
- ❌ No hardcoded `BorderRadius` — use `kBorderRadius*` constants
- ❌ No hardcoded icon `size:` — use `kIconSize*` constants
- ❌ No hardcoded spacing/padding — use `kSpacing*` constants
- ❌ No hardcoded Hebrew strings — use `AppStrings`
- ✅ Wrap `HapticFeedback.*()` calls with `unawaited()`
- ✅ Add `const` to `SizedBox`, `EdgeInsets`, `Duration`, `Icon` where possible

---

## Project Guardrails (DO NOT CHANGE WITHOUT EXPLICIT APPROVAL)

### Review Workflow
- 3-5 שאלות הבהרה עם אפשרויות א/ב/ג
- **בלי קטעי קוד בשאלות**
- בכל שאלה להוסיף **"המלצת הסוכן"**
- ניתוח לפי **File Review Checklist** למטה (לא רק היגיינת קוד)
- תגובות לפי **Response Style** למטה

### Welcome Screen
- מופיע **רק** עד יצירת חשבון
- **Logout רגיל לא מחזיר** Welcome
- **מחיקת נתונים כן מחזירה** Welcome

### seenOnboarding
- נדלק אחרי login/register הצלחה (כולל Google/Apple)
- **נשמר אחרי Logout** (לא מתאפס)

### Auth Screens
- **נקיים, לא Sticky Notes** — עיצוב מינימליסטי
- `NotebookBackground.subtle()` **מותר** (רקע עדין בלבד, לא full notebook)

### Pending Invites
- בדיקה אחרי register/login (כולל Google/Apple)
- guard אם אין email/phone

### IDs/Keys (Config)
- כל ID/key חייב **resolve()** עם fallback:
  - **"other"** — למשתמש (UI-safe)
  - **"unknown"** — לדיבאג בלבד
- **ensureValid()** בקונפיגים (via `ConfigValidation` mixin)
- **Backward compatible** — aliases לערכים ישנים

### AnimatedButton
- **אפקט בלבד** — הפעולה ב-parent
- haptic רק ל-CTA (לא לניווט)
- scale: **0.97–0.98**
- אנימציה מתחילה ב-**tap-down**

---

## File Review Checklist

בכל ניתוח קובץ, לעבור על **כל** הסעיפים. לא רק היגיינת קוד.

### 🚦 UX (חוויית משתמש)
- **מסע המשתמש** — מה הוא רואה ראשון? מה אחר כך? איפה הוא נעצר?
- **שאלת "ואז מה?"** — אחרי כל פעולה (snackbar הצלחה, סגירת דיאלוג, שמירה) — האם ברור מה הצעד הבא?
- **משוב בזמן אמת** — האפליקציה אומרת שמשהו קורה? לא רק "נשלח" אלא גם "בדוק תיבת דואר, כולל ספאם"?
- **מצבי קצה רגשיים** — מה הוא חושב כשהדבר נכשל / נטען לאט / ריק / לא נמצא?
- **חיכוך** — איפה הוא נעצר? מחפש כפתור? חוזר אחורה? לוחץ פעמיים?
- **היררכיה ויזואלית** — הדבר החשוב באמת בולט? סדר הצגה הגיוני?
- **עומס קוגניטיבי** — טקסט ברור? יותר מדי החלטות במסך אחד?
- **סיכון מיס-טאפ** — כפתורים מסוכנים (X, מחיקה) רחוקים מ-CTA?

### 🔗 Cross-File (חוצה קבצים)
- **מי קורא לקובץ?** — `grep` שם הפונקציה/הוויג'ט בכל ה-`lib/`
- **מה כל caller עושה עם התוצאה?** — לקרוא את הבלוק שמשתמש, לא רק את הקריאה
- **האם יש קוד כפול?** — callers שעוקפים את ה-API במקום להשתמש בו
- **האם ה-UX עקבי בין callers?** — snackbar dedup, haptic, error handling — באותו אופן בכל מקום

### 🎨 Visual & Design System
- מספרי קסם → `kSpacing*` / `kFontSize*` / `kIconSize*` / `kBorderRadius*` / `kOpacity*`
- צבעים → **רק** מ-`Theme.of(context).colorScheme` (לא `Colors.xxx`)
- מחרוזות עברית → **רק** `AppStrings`
- `const` איפה שאפשר (`SizedBox`, `EdgeInsets`, `Duration`)
- חריגים מותרים: ערכי תכן ספציפיים (`alpha: 0.4` לסקרים) — אך **עם הערה**
- כפילות עם `Theme` — לא להגדיר ערכים ש-Theme כבר קובע (`backgroundColor`, `shape` ב-bottom sheets)

### ⚡ Performance & Lifecycle
- `RepaintBoundary` סביב אנימציות / shimmer / scrolls כבדים
- `ValueNotifier<T>` + `ValueListenableBuilder` במקום `setState` אם רק חלק קטן ב-UI צריך לבנות מחדש
- `context.select` במקום `context.watch` אם הערך פרימיטיבי (`int`/`String`/`bool`)
- `dispose()` — `Controllers`, `Timers`, `AnimationControllers`, `Listeners`, `Streams`
- `if (mounted)` **רק** אחרי `await` (לא לפני שום await — קוד מת)

### 🐛 Async & Errors
- `unawaited(...)` ל-fire-and-forget (Haptic, Futures ב-callbacks סינכרוניים)
- `removeCurrentSnackBar()` **לפני** `showSnackBar` — מונע ערימת באנרים
- `userFriendlyError(e, context: 'flowName')` במקום `e.toString()`
- בדיקת `mounted` אחרי **כל** `await` שיגרור פעולה על UI/`context`
- אין race conditions: לא לקרוא ל-`context.read` אחרי await בלי לוודא שהוא עדיין בר-תוקף

### 📱 RTL & Hebrew
- **בלי** `Directionality(rtl)` מקובע — האפליקציה כבר RTL גלובלי
- `BorderRadiusDirectional` לפינות א-סימטריות (`start`/`end`)
- `EdgeInsetsDirectional` למרווחים א-סימטריים
- `TextDirection.ltr` **רק** לתוכן מעורב (URLs, מספרים, IDs)

### ♿ A11y — חסכוני בלבד
**עיקרון:** premium visual > תיוג קוראי מסך. נגישות חשובה אבל לא במחיר ויזואלי.

- ✅ **כן** — `liveRegion: true` במצבי טעינה ושגיאה (loading/error states שמופיעים דינמית)
- ✅ **כן** — `ExcludeSemantics` סביב decorative elements שמייצרים רעש כפול (handle bars, pure-decoration icons)
- ❌ **לא** — `Semantics(label: ...)` על כל אייקון/כפתור עם ייעוד ויזואלי ברור
- ❌ **לא** — להגדיל tap targets ל-`kMinTapTarget` אם זה שובר את ה-premium visual
- ❌ **לא** — `Tooltip` על כל IconButton

---

## Response Style (איך לענות)

### צורת התגובה
- **עברית בלבד** — לא לערבב אנגלית בהסברים
- **שפה פשוטה** — בלי מונחים טכניים בלי הסבר; להניח ידע נמוך
- **דוגמאות קוד קונקרטיות** — להראות "לפני / אחרי", לא הסברים מופשטים
- **אימוג'ים כותרת** — לסריקה מהירה: ✅🐛⚠️📦📐🎨♿🎯🔁📣🧠⚡🚦📱🔗
- **טבלאות** לסיכום ממצאים מרובים (סריקה קלה)
- **קצר ותמציתי** — בלי fluff, בלי מטא-הסברים
- **3–5 שאלות הבהרה** עם א/ב/ג + **"המלצת הסוכן"** בכל שאלה
- **בלי קטעי קוד בתוך שאלות** — רק תיאור ויזואלי/UX

### מבנה ניתוח קובץ
1. קריאת הקובץ + ה-callers + תלויות חיוניות
2. ממצאים מקובצים לפי קטגוריה (UX / Cross-File / Visual / Perf / Async / RTL / A11y)
3. הפרדה ברורה בין **"לתקן בטוח"** ל-**"שאלות לפני ביצוע"**
4. בסוף — סיכום שינויים בטבלה
5. הזכרה של "מוכן לקובץ הבא 📂"

### מה לא לעשות
- ❌ לא להוסיף a11y wrappers טהורים בלי ערך ויזואלי
- ❌ לא להגדיל tap targets / מרווחים אם זה שובר premium visual
- ❌ לא לחלץ קבועים אם הערך מופיע פעם אחת ושמו לא מוסיף הסבר
- ❌ לא להוסיף הערות שמסבירות **מה** הקוד עושה (רק **למה** ורק כשלא מובן מאליו)
- ❌ לא לבצע שינויים מסוכנים (גודל ויזואלי, התנהגות) בלי לשאול
- ❌ לא להציע שינויים בלי לבדוק את ה-callers קודם

### מה כן לעשות
- ✅ Cross-file analysis: לקרוא callers, לחפש כפילויות, לוודא עקביות UX
- ✅ לחשוב בעין משתמש (לא רק מפתח)
- ✅ לשאול לפני שינויים ויזואליים / שינויי התנהגות
- ✅ "המלצת הסוכן" עם **נימוק קצר** (לא רק "כן/לא")
- ✅ לאחר ביצוע — `git diff` ל-self-review לפני commit

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
| **Theme** | `lib/theme/app_theme.dart` (AppBrand extension, light/dark, dynamic colors) |
| **Constants** | `lib/core/ui_constants.dart`, `status_colors.dart` |
| **Config** | `lib/config/list_types_config.dart`, `filters_config.dart`, `storage_locations_config.dart` |
| **Models** | `lib/models/shopping_list.dart`, `unified_list_item.dart`, `user_entity.dart`, `inventory_item.dart`, `activity_event.dart` |
| **Providers** | `lib/providers/user_context.dart`, `shopping_lists_provider.dart`, `inventory_provider.dart`, `activity_log_provider.dart` |
| **Shared Widgets** | `lib/widgets/common/` — NotebookBackground, StickyNote, StickyButton, AppErrorState, AppLoadingSkeleton, AnimatedButton, TappableCard, OfflineBanner, SectionHeader, AppDialog, SkeletonLoader, BarcodeScannerSheet, EmailVerificationBanner, HouseholdInviteDialog (`showHouseholdInviteDialog()`) |
| **Strings** | `lib/l10n/app_strings.dart` |
| **Security** | `firestore.rules` (v4.5), `firestore.indexes.json` |

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

הרשימה המלאה (פתוחות, מתוקנות, vintage tracking) מנוהלת ב-[CODE_REVIEW.md](CODE_REVIEW.md).
ל-Claude AI כדאי להציץ גם ב-[AGENTS.md](AGENTS.md) שיש שם טבלה תפעולית של הבעיות הפעילות.

---

## Related Docs

- [CODE_REVIEW.md](CODE_REVIEW.md) — דוח Code Review מלא (עודכן 27/4/2026)
- [TEST_PLAN.md](TEST_PLAN.md) — תוכנית בדיקות (396 unit tests)
- [DESIGN_AUDIT.md](DESIGN_AUDIT.md) — סקירת עיצוב UI
- [docs/REFACTOR_PLAN.md](docs/REFACTOR_PLAN.md) — תוכנית ריפקטור 10 שלבים
- [docs/store-listing.md](docs/store-listing.md) — תוכן Store listing
- [docs/spec-home-screen.md](docs/spec-home-screen.md) — אפיון מסך הבית (כולל Activity Feed)
