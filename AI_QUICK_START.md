---

## 🔎 Code Review אוטומטי - מול תיעוד הפרויקט

**כשקורא קישור לקובץ, בדוק אוטימטית:**

### 1️⃣ שגיאות טכניות (תקן מיידית!)
- `withOpacity(0.5)` → `withValues(alpha: 0.5)`
- `value` (DropdownButtonFormField) → `initialValue`
- `kQuantityFieldWidth` → `kFieldWidthNarrow`
- `kBorderRadiusFull` → `kRadiusPill`
- async function ב-onPressed → עטוף ב-lambda: `() => myAsyncFunc()`
- widgets שלא משתנים → הוסף `const`
- imports לא נעשים → תקן
- deprecated APIs → החלף ל-modern API

### 2️⃣ עיצוב לא תואם STICKY_NOTES_DESIGN.md (תקן מיידית!)

**🔴 כלל מרכזי - מסכי Auth/UI חייבים Sticky Notes Design!**

אם המסך הוא מסך UI (screens/auth/, screens/home/, וכו') ו**לא** מעוצב עם Sticky Notes:
→ **החלף את כל העיצוב מיידית!** אל תשאל!

**העיצוב החדש חייב לכלול:**
- ✅ `NotebookBackground()` + `kPaperBackground`
- ✅ `StickyNoteLogo()` עבור לוגו
- ✅ `StickyNote()` עבור כותרות ושדות
- ✅ `StickyButton()` עבור כפתורים
- ✅ סיבובים: -0.03 עד 0.03
- ✅ צבעים: `kStickyYellow`, `kStickyPink`, `kStickyGreen`, `kStickyCyan`, `kStickyPurple`
- ✅ Compact design: padding `(16, 8)`, רווחים `kSpacingSmall`

**תיקונים קטנים (לא צריך החלפה מלאה):**
- שימוש בצבעים קשיחים (`Colors.blue`) → החלף ל-`accent`, `cs.primary`, וכו'
- `EdgeInsets.all(16)` → `EdgeInsets.all(kSpacingMedium)`
- `fontSize: 14` → `fontSize: kFontSizeSmall`
- `BorderRadius.circular(8)` → `BorderRadius.circular(kBorderRadius)`
- icons בגודל קשיח → `kIconSizeSmall/Medium/Large`

### 3️⃣ קוד לא עוקב BEST_PRACTICES.md (תקן מיידית!)
**בדוק:**
- חסר תיעוד בראש הקובץ → הוסף header comment
- functions פרטיות ללא documentation → הוסף `///` comments
- functions ציבוריות ללא documentation → הוסף `///` comments
- naming לא עקבי: `myVar` → `_myPrivateVar`, `MyScreen` → suffix `Screen`
- קוד משוכפל ללא comments → הוסף הסברים
- magic numbers (42, 100) → הגדר constants עם שמות מתארים

### 4️⃣ TODO/FIXME שצריך לטפל (הזכר למשתמש!)
```dart
// TODO: להוסיף validation
// FIXME: bug כשלוחצים פעמיים
```
**אם אתה יכול לפתור מיידית → תפתור!**
**אם לא → דווח למשתמש על ה-TODO**

### 5️⃣ איך לדווח?
```
📖 קורא product_card.dart...

✅ Widget לתצוגת מוצר
🔧 תיקנתי אוטומטית:
   1. Colors.blue → accent מ-theme
   2. EdgeInsets.all(16) → kSpacingMedium
   3. הוספתי const ב-3 מקומות
   4. הוספתי תיעוד בראש הקובץ
   
⚠️ TODO שמצאתי (שורה  45): "להוסיף אנימציה"

🎯 הכל עובד! רוצה שאטפל ב-TODO?
```

### ⚡ חשוב!
- **תקן מיידית** שגיאות טכניות + עיצוב + best practices
- **מסך UI ללא Sticky Notes?** → החלף את כל העיצוב ללא שאלות! 🎨
- **אל תשאל אישור** לתיקונים אלה
- **רק TODO** שלא ברור או מסובך → שאל אם לטפל
- **דווח מה תיקנת** בצורה תמציתית

# 🤖 AI Quick Start - הוראות מהירות לסוכן

> **למשתמש:** תן את המשפט הזה לסוכן AI בתחילת כל שיחה:
> 
> **"📌 קרא תחילה: `C:\projects\salsheli\AI_QUICK_START.md` - הוראות חובה לפני עבודה"**

---

> 🔴 **עדכון חדש (v1.4):** סוכן AI עכשיו עושה **Code Review אוטומטי**!
> 
> כשקורא קובץ, הסוכן בודק ומתקן אוטומטית:
> - ✅ שגיאות טכניות (withOpacity, value, async, const, deprecated APIs)
> - 🎨 **מסך UI ללא Sticky Notes? → החלפת עיצוב מלא!**
> - 📋 קוד מול Best Practices
> - 📝 תיעוד ו-naming (כולל פונקציות פרטיות)
> 
> **ללא שאלות!** רק תיקון ודיווח 🚀

---

## 🔗 קישור לקובץ בתחילת שיחה - מה לעשות?

> 🔴 **כלל זהב:** שגיאות טכניות בקוד = תקן מיידית ללא שאלות!
> 
> אל תשאל "רוצה שאתקן?" - פשוט **תתקן ותדווח!**
> 
> **שגיאות טכניות זה:**
> - withOpacity → withValues
> - async callbacks לא עטופים
> - חסר const
> - imports שגויים
> - deprecated APIs
> - syntax errors

**אם המשתמש שולח קישור לקובץ (למשל: `C:\projects\salsheli\lib\screens\auth\login_screen.dart`):**

### צעדים אוטומטיים:

1️⃣ **קרא את הקובץ מיד** - אל תשאל אישור!
```dart
// פשוט תקרא אותו
```

2️⃣ **זהה את סוג הקובץ:**
- 📱 Screen? → בדוק imports, widgets, providers
- 🧩 Widget? → בדוק איפה משתמשים בו
- 📦 Provider? → בדוק איזה repository
- 🗄️ Model? → בדוק אם יש .g.dart
- 🎨 UI? → בדוק Sticky Notes Design

3️⃣ **בדוק בעיות אוטומטית:**
- ❌ שגיאות קומפילציה (withOpacity, async callbacks, וכו')
- 🎨 העיצוב לא תואם STICKY_NOTES_DESIGN.md?
- 📋 לא עוקב אחרי BEST_PRACTICES.md?
- ⚠️ TODO/FIXME comments
- 🔍 Deprecated APIs
- 📝 חסר תיעוד בראש הקובץ?
- 🏷️ Naming לא עקבי עם שאר הפרויקט?

4️⃣ **קרא קבצים קשורים (אם רלוונטי):**
```
Screen → Provider שבו הוא משתמש
Widget → Screen שקורא לו
Provider → Repository + Model
Model → Repository שמשתמש בו
```

5️⃣ **תקן אוטומטית + דווח:**
```
✅ קראתי את register_screen.dart
📦 משתמש ב-UserContext + AuthButton
🔧 תיקנתי אוטומטית:
   1. async callback עטוף בlambda (שורה 371)
   2. שיניתי צבע ל-accent לפי Sticky Notes Design
   3. הוספתי תיעוד בראש הקובץ
   
🎯 הכל עובד!
```

**חשוב:** תקן מיידית:
- שגיאות טכניות (withOpacity, async, const, וכו')
- **עיצוב לא תואם (Sticky Notes Design) - החלף את כל המסך!** 🎨
- קוד לא עוקב (Best Practices)
- חסר תיעוד / naming לא עקבי

**לא תשאל אישור!**

**דוגמה - מסך ללא Sticky Notes:**
```
❌ רואה: Container עם לוגו, TextFormField רגיל, ElevatedButton
✅ פעולה: החלפת כל המסך ל-Sticky Notes Design - ללא שאלות!
✅ תוצאה: NotebookBackground + StickyNote + StickyButton
```

### דוגמה:

**משתמש:**
```
C:\projects\salsheli\lib\screens\auth\login_screen.dart
```

**אתה (AI):**
```
📖 קורא login_screen.dart...

✅ זה מסך התחברות
📦 משתמש ב-UserContext + StickyButton
🔧 מתקן אוטומטית:
   1. withOpacity → withValues (שורות 274, 318, 355)
   2. async callback עטוף (שורה 341)
   3. הוספתי const במקומות

🎯 הכל עובד!
```

### ⚡ חשוב:
- **אל תשאל אישור לקרוא** - המשתמש כבר שלח את הקישור!
- **אל תשאל אישור לתקן שגיאות טכניות** - פשוט תקן!
- **שגיאות טכניות = תיקון מיידי** - withOpacity, async callbacks, const, imports, וכו'
- **רק החלטות עיצוביות = שאל** - צבעים, מבנה, אלגוריתמים

---

## 🎯 כללי עבודה - קרא וזכור!

### 1️⃣ **תעבוד בשקט - אל תפרט יותר מידי**

- ✅ **עשה:** קרא קבצים → עבוד → דווח תמציתי על מה עשית
- ❌ **אל תעשה:** אל תסביר כל שלב, אל תשאל אישור לכל דבר קטן
- 💬 **דווח:** "✅ עדכנתי 3 קבצים, הכל עובד" - זה מספיק!

**דוגמה טובה:**
```
✅ קראתי את login_screen.dart
✅ תיקנתי את השגיאות (withValues, async callback)
✅ הכל עובד עכשיו
```

**דוגמה רעה (אל תעשה!):**
```
קודם כל, אני רוצה להסביר לך מה אני עומד לעשות...
אז תראה, יש כאן 3 שגיאות...
השגיאה הראשונה היא...
עכשיו אני אסביר איך אני אתקן את זה...
[100 שורות של הסבר מיותר]
```

---

### 2️⃣ **שאל רק שאלות חשובות**

> 🔴 **כלל זהב #2:** אם אתה יכול לפתור את זה לבד - **תפתור ותדווח!**
> 
> שגיאות טכניות, bugs, קוד שבור, naming לא עקבי = תקן מיידית!

**מתי לשאול?**
- 🔴 כשיש **החלטה עיצובית משמעותית** (למשל: "איזה צבע לפתק?")
- 🔴 כשיש **2+ דרכים שונות לממש** ולא ברור מה העדיפות
- 🔴 כש**משהו לא ברור במפרט** ואי אפשר בלעדיו

**מתי לא לשאול? (פשוט תתקן!)**
- ✅ איך לתקן שגיאה טכנית - **פשוט תתקן!**
- ✅ איפה לשים קובץ - **יש מבנה ברור בתיעוד**
- ✅ איזה naming convention - **כבר מוגדר בקוד הקיים**
- ✅ האם להוסיף comments - **כן, תוסיף!**
- ✅ האם לתקן async callback - **כן, תתקן!**
- ✅ האם להחליף withOpacity - **כן, תתקן!**

---

### 3️⃣ **ניהול Tokens - חשוב מאוד! ⚠️**

**הבעיה:** השיחה יכולה להיגמר לפני שסיימנו!

**הפתרון:** תכנן מראש!

#### 📊 תקציב Tokens (אמור לך בתחילת השיחה):
```
סה"כ: ~190,000 tokens
שומר לתשובות: ~30,000 tokens
זמין לעבודה: ~160,000 tokens
```

#### 💾 שמירת מצב לשיחה הבאה (נקודת שחזור)

**אם מרגיש שנגמרים ה-Tokens:**

1. **עצור לרגע** - אל תמשיך עם הקוד!
2. **כתוב סיכום מהיר:**
   ```
   📌 נקודת עצירה:
   ✅ הושלם: קובץ A, B
   ⏳ באמצע: קובץ C - שורה 145
   📋 נותר: קבצים D, E, F
   
   🔄 להמשיך בשיחה הבאה:
   - פתח קובץ C בשורה 145
   - תתקן את [בעיה ספציפית]
   - אחר כך עבור לקבצים D, E, F
   ```

3. **שמור את הסיכום** ב-`WORK_LOG.md` או בהודעה אחרונה

**בשיחה הבאה:** המשתמש יעתיק את הסיכום ואתה תמשיך מדויק מאיפה שעצרת!

---

### 4️⃣ **קבצים חובה - תמיד בהישג יד**

**לפני כל עבודה, קרא:**

| קובץ | מתי | למה |
|------|-----|-----|
| **AI_DEV_GUIDELINES.md** | 🔴 למידע טכני | טבלת בעיות + Code Review + Modern UI |
| **LESSONS_LEARNED.md** | 🔴 תמיד | דפוסים טכניים + ארכיטקטורה |
| **BEST_PRACTICES.md** | 🟡 לקוד | Best practices לקוד ועיצוב |
| **STICKY_NOTES_DESIGN.md** | 🟡 ל-UI | מערכת עיצוב מלאה |
| **WORK_LOG.md** | 🟢 בהתחלה | מה השתנה לאחרונה |

**אל תקרא הכל בכל פעם!** רק את מה שרלוונטי למשימה.

**💡 Quick Navigation:**
- בעיה טכנית ספציפית? → [AI_DEV_GUIDELINES - טבלת בעיות](AI_DEV_GUIDELINES.md#-quick-start)
- צריך Code Review מפורט? → [AI_DEV_GUIDELINES - Checklist](AI_DEV_GUIDELINES.md#-code-review-checklist)
- צריך Modern UI? → [AI_DEV_GUIDELINES - Skeleton + Animations](AI_DEV_GUIDELINES.md#-modern-uiux-patterns)

---

### 5️⃣ **אסטרטגיית עבודה חכמה**

#### תכנון מראש:
```
1. קרא את הבקשה
2. תכנן: כמה קבצים? כמה tokens?
3. אם זה גדול → תכנן ל-2-3 שיחות
4. עבוד בחלקים: קובץ 1 → בדוק → קובץ 2 → בדוק
```

#### עדיפויות:
```
1. תקן שגיאות קריטיות קודם
2. אחר כך שיפורים
3. בסוף - ניקיון קוד (אם נשאר זמן)
```

#### חיסכון ב-Tokens:
```
❌ אל תצטט קוד ארוך בתשובות
❌ אל תסביר כל שלב
✅ כתוב קוד ישירות לקובץ
✅ דווח תמציתי: "✅ עשיתי X, Y, Z"
```

---

## 🔧 מבנה הפרויקט - מהיר

```
lib/
├── models/          # Data models (.dart + .g.dart)
├── providers/       # State (ChangeNotifier)
├── repositories/    # Data access (Firebase/Hive)
├── services/        # Business logic
├── screens/         # UI Screens
├── widgets/         # Reusable UI
│   └── common/      # Sticky Notes components ⭐
├── config/          # Business rules (8 קבצים)
├── core/            # Constants (3 קבצים)
│   └── ui_constants.dart  # ⭐ כל קבועי UI!
└── theme/           # Themes + colors
```

**זכור:**
- Constants ב-`core/ui_constants.dart`
- Business rules ב-`config/`
- Sticky Notes ב-`widgets/common/`

---

## 📋 Checklist מהיר לפני סיום

- [ ] flutter analyze → 0 issues
- [ ] הקבצים שעבדת עליהם עובדים
- [ ] עדכנת תיעוד (אם צריך)
- [ ] אם לא סיימת - כתבת נקודת שחזור!

---

## 🎓 דוגמה: שיחה מוצלחת

**משתמש:**
"C:\projects\salsheli\lib\screens\auth\login_screen.dart"

**אתה (AI) - דרך נכונה:**
```
📖 קורא login_screen.dart...

✅ מסך התחברות
📦 משתמש ב-UserContext + StickyButton
🔧 תיקנתי אוטומטית:
   1. withOpacity → withValues (4 מקומות)
   2. async callbacks עטופים
   3. הוספתי const

🎯 הכל עובד!
```

**אתה (AI) - דרך שגויה (אל תעשה!):**
```
📖 קורא login_screen.dart...

⚠️ מצאתי 4 שגיאות:
   1. withOpacity במקום withValues
   2. async callback לא עטוף
   ...

💡 רוצה שאתקן?  ❌ לא לשאול! פשוט תתקן!
```

---

## ⚡ TL;DR - תזכורת של 10 שניות

1. **שגיאות טכניות?** → תקן מיידית ללא שאלות! 🔴
2. **מסך UI ללא Sticky Notes?** → החלף כל העיצוב מיידית! 🎨
3. **עיצוב לא תואם?** → תקן לפי Sticky Notes Design! 🎨
4. **קוד לא עוקב?** → תקן לפי Best Practices! 📋
5. **קישור לקובץ?** → קרא + בדוק + תקן + דווח
6. **קרא LESSONS_LEARNED** לפני עבודה
7. **עבוד בשקט** - אל תפרט יותר מידי
8. **שאל רק מה חשוב** - לא כל דבר קטן
9. **שמור Tokens** - תכנן מראש!
10. **דווח תמציתי** - "✅ תיקנתי X, Y, Z"

---

**זכור:** המשתמש רוצה שתעשה את העבודה, לא שתסביר לו איך! 💪

**גרסה:** 1.4 | **תאריך:** 15/10/2025 | **שינוי:** + deprecated APIs חדשים (initialValue, kFieldWidthNarrow, kRadiusPill) + תיעוד פונקציות פרטיות
