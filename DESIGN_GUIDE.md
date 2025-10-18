# 📝 Sticky Notes Design System

## מדריך עיצוב מלא - סל שלי

---

## 🎨 סקירה כללית

מערכת עיצוב בהשראת פתקים צבעוניים (Post-it) ומחברות בית ספר.  
העיצוב יוצר חוויה חמה, ידידותית ונגישה עם מגע של נוסטלגיה.

### עקרונות עיצוב ליבה

1. **חום ונגישות** - צבעים עדינים ופסטליים
2. **מגע אנושי** - סיבובים קלים וצללים מציאותיים
3. **בהירות** - תוכן קריא על כל רקע
4. **עקביות** - שימוש בקבועים בכל האפליקציה
5. **קומפקטיות** - מקסימום תוכן במינימום גלילה 📐 (חדש!)

---

## 🎨 פלטת צבעים

### צבעי בסיס

#### רקע

```dart
kPaperBackground = Color(0xFFFAF8F3) // נייר קרם
```

צבע רקע ראשי - נייר מחברת בגוון קרם חם.

#### קווי מחברת

```dart
kNotebookBlue = Color(0xFF9FC5E8)    // קווים כחולים
kNotebookRed = Color(0xFFE57373)     // קו אדום משמאל
```

### פתקים צבעוניים

| צבע     | קוד                                 | שימוש מומלץ          |
| ------- | ----------------------------------- | -------------------- |
| 🟨 צהוב | `kStickyYellow = Color(0xFFFFF59D)` | לוגו, פעולות ראשיות  |
| 🌸 ורוד | `kStickyPink = Color(0xFFF8BBD0)`   | תזכורות, התראות רכות |
| 🟩 ירוק | `kStickyGreen = Color(0xFFC5E1A5)`  | הצלחות, אישורים      |
| 🔵 תכלת | `kStickyCyan = Color(0xFF80DEEA)`   | מידע, עזרה           |
| 🟣 סגול | `kStickyPurple = Color(0xFFCE93D8)` | יצירתיות, חדש        |

---

## 📐 גדלים ומידות

### פתקים

```dart
// גודל פתק לוגו
kStickyLogoSize = 120.0

// אייקון בפתק לוגו
kStickyLogoIconSize = 60.0

// רדיוסי פינות
kStickyNoteRadius = 2.0      // פתקים רגילים
kStickyButtonRadius = 4.0    // כפתורים
```

### כפתורים

```dart
kButtonHeight = 48.0         // גובה סטנדרטי (נגישות)
kButtonHeightSmall = 36.0    // כפתור קטן
kButtonHeightLarge = 56.0    // כפתור גדול

// 📐 לעיצוב compact:
height: 44.0                 // גובה מצומצם (עדיין נגיש)
```

### מחברת

```dart
kNotebookLineSpacing = 40.0      // מרווח בין שורות
kNotebookRedLineOffset = 60.0    // מיקום קו אדום
kNotebookRedLineWidth = 2.5      // עובי קו אדום
```

---

## 🌑 צללים ועומק

### צללי פתקים רגילים

```dart
// צל ראשי - אפקט הדבקה
BoxShadow(
  color: Colors.black.withValues(alpha: 0.2),  // ⚠️ השתמש ב-withValues!
  blurRadius: 10.0,                             // kStickyShadowPrimaryBlur
  offset: Offset(2.0, 6.0),                    // X, Y
)

// צל משני - עומק
BoxShadow(
  color: Colors.black.withValues(alpha: 0.1),  // ⚠️ השתמש ב-withValues!
  blurRadius: 20.0,                             // kStickyShadowSecondaryBlur
  offset: Offset(0, 12.0),                     // Y בלבד
)
```

**⚠️ חשוב:** בגרסאות חדשות של Flutter, `withOpacity` deprecated. השתמש תמיד ב-`withValues(alpha: ...)` במקום!

### צללי לוגו (חזקים יותר)

```dart
// צל ראשי
BoxShadow(
  color: Colors.black.withValues(alpha: 0.25), // kStickyLogoShadowPrimaryOpacity
  blurRadius: 12.0,                             // kStickyLogoShadowPrimaryBlur
  offset: Offset(2.0, 8.0),
)

// צל משני
BoxShadow(
  color: Colors.black.withValues(alpha: 0.12), // kStickyLogoShadowSecondaryOpacity
  blurRadius: 24.0,                             // kStickyLogoShadowSecondaryBlur
  offset: Offset(0, 16.0),
)
```

---

## 🔄 סיבובים (Rotation)

פתקים מסתובבים קלות ליצירת מראה אורגני ואותנטי.

```dart
kStickyMaxRotation = 0.03  // ±0.03 רדיאנים (כ-1.7 מעלות)
```

### המלצות שימוש:

- **לוגו**: `-0.03` (שמאלה)
- **פתק 1**: `0.01` (ימינה קלה)
- **פתק 2**: `-0.015` (שמאלה קלה)
- **פתק 3**: `0.01` (ימינה קלה)
- **כותרת**: `-0.02` (שמאלה בינונית)

**💡 טיפ:** שנה כיוון סיבוב בין פתקים סמוכים למראה טבעי יותר!

---

## 🧩 רכיבים משותפים

### 1. NotebookBackground

רקע מחברת עם קווים כחולים וקו אדום.

```dart
import 'package:flutter/material.dart';
import 'package:salsheli/widgets/common/notebook_background.dart';

Scaffold(
  backgroundColor: kPaperBackground, // ⚠️ חובה!
  body: Stack(
    children: [
      NotebookBackground(), // רקע מחברת
      SafeArea(
        child: YourContent(),
      ),
    ],
  ),
)
```

**מתי להשתמש:**

- מסכי קבלת פנים (Welcome)
- מסכי הרשמה/התחברות (Auth)
- מסכי הסבר וחינוך
- דשבורדים עם אווירה נעימה

---

### 2. StickyNote

פתק צבעוני עם תוכן.

```dart
import 'package:salsheli/widgets/common/sticky_note.dart';

StickyNote(
  color: kStickyPink,
  rotation: -0.02,
  child: Column(
    children: [
      Text('כותרת', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('תוכן הפתק'),
    ],
  ),
)
```

**מתי להשתמש:**

- כרטיסי מידע
- יתרונות/פיצ'רים
- הודעות חשובות
- טיפים והסברים
- עטיפה לשדות טקסט (TextFormField)

**טיפים:**

- השתמש בצבעים שונים להבחנה בין סוגי תוכן
- הוסף `Icon` בחלק העליון לזיהוי מהיר
- שמור על טקסט קצר וקריא

---

### 3. StickyNoteLogo

פתק מיוחד ללוגו או אייקון מרכזי.

```dart
import 'package:salsheli/widgets/common/sticky_note.dart';

StickyNoteLogo(
  color: kStickyYellow,
  icon: Icons.shopping_basket_outlined,
  iconColor: Colors.green,
  rotation: -0.03,
)
```

**💡 טיפ לעיצוב compact:** השתמש ב-`Transform.scale` להקטנה:

```dart
Transform.scale(
  scale: 0.85, // הקטנה ב-15%
  child: StickyNoteLogo(
    color: kStickyYellow,
    icon: Icons.shopping_basket_outlined,
    iconColor: accent,
  ),
)
```

**מתי להשתמש:**

- לוגו האפליקציה במסך פתיחה
- אייקונים מרכזיים
- סמלי קטגוריות

---

### 4. StickyButton

כפתור בסגנון פתק.

```dart
import 'package:salsheli/widgets/common/sticky_button.dart';

StickyButton(
  color: Colors.green,
  label: 'התחל',
  icon: Icons.play_arrow,
  onPressed: () => Navigator.push(...),
)
```

**⚠️ חשוב - עבודה עם async callbacks:**

`StickyButton` מקבל רק `VoidCallback` רגיל, לא `Future<void>`. אם יש לך פונקציה אסינכרונית, עטוף אותה:

```dart
// ❌ לא נכון:
StickyButton(
  onPressed: _handleLogin, // _handleLogin הוא Future<void>
  label: 'התחבר',
)

// ✅ נכון:
StickyButton(
  onPressed: () => _handleLogin(), // עוטפים בלמבדה
  label: 'התחבר',
)

// ✅ עם loading state:
StickyButton(
  onPressed: _isLoading ? () {} : () => _handleLogin(),
  label: 'התחבר',
)
```

**וריאציות:**

```dart
// כפתור ראשי
StickyButton(
  color: Colors.green,  // או kStickyGreen
  label: 'התחברות',
  icon: Icons.login,
  onPressed: () => _handleLogin(),
)

// כפתור משני
StickyButton(
  color: Colors.white,
  textColor: Colors.green,
  label: 'הרשמה',
  icon: Icons.app_registration_outlined,
  onPressed: () => _handleRegister(),
)

// כפתור קטן
StickyButtonSmall(
  label: 'ביטול',
  icon: Icons.close,
  onPressed: () => Navigator.pop(context),
)

// כפתור compact (למסכים צפופים)
StickyButton(
  label: 'המשך',
  icon: Icons.arrow_forward,
  onPressed: () => _handleNext(),
  height: 44, // גובה מצומצם
)
```

**נגישות:**

- גובה מינימלי 48px (או 44px למסכים compact)
- `Semantics` אוטומטי
- ניגודיות אוטומטית בין טקסט לרקע

---

## 🎭 אנימציות

כל הרכיבים כוללים אנימציות מובנות:

### StickyNote & StickyNoteLogo

```dart
.animate()
.fadeIn(duration: Duration(milliseconds: 400))
.slideY(begin: 0.1, curve: Curves.easeOut)
```

### StickyNoteLogo (נוסף)

```dart
.animate()
.fadeIn(duration: Duration(milliseconds: 600))
.scale(begin: Offset(0.8, 0.8), curve: Curves.elasticOut)
```

### StickyButton

אנימציית לחיצה אוטומטית דרך `AnimatedButton`.

---

## 📐 עיצוב Compact - מסכים ללא גלילה

### עקרונות לעיצוב קומפקטי

כשרוצים להכניס הכל במסך אחד ללא גלילה, יש לצמצם בחוכמה:

#### 1️⃣ **Padding וריווחים**

```dart
// ❌ רווחים גדולים מדי:
padding: EdgeInsets.all(24),
SizedBox(height: 32),

// ✅ רווחים מצומצמים:
padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
SizedBox(height: 8), // או 12 בין אלמנטים חשובים
```

**מדרגות רווחים מומלצות למסך compact:**

- בין אלמנטים קטנים: `4-6px`
- בין אלמנטים רגילים: `8px` (kSpacingSmall)
- בין סקציות: `12-16px` (kSpacingMedium)
- מקסימום: `24px` (רק לפני/אחרי אלמנט מרכזי)

#### 2️⃣ **גדלי טקסט**

```dart
// ❌ גדול מדי:
fontSize: 32,
fontSize: 18,

// ✅ מצומצם אבל קריא:
fontSize: 24, // כותרות
fontSize: 14, // טקסט רגיל (kFontSizeSmall)
fontSize: 11, // טקסט קטן (kFontSizeTiny)
```

#### 3️⃣ **הקטנת אלמנטים גרפיים**

```dart
// לוגו - השתמש ב-Transform.scale:
Transform.scale(
  scale: 0.85, // או 0.8 להקטנה יותר משמעותית
  child: StickyNoteLogo(...),
)

// כפתורים - גובה מצומצם:
StickyButton(
  height: 44, // במקום 48
  label: '...',
  onPressed: () {},
)
```

#### 4️⃣ **צמצום Padding פנימי**

```dart
// TextFormField עם padding מצומצם:
TextFormField(
  decoration: InputDecoration(
    contentPadding: EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8, // במקום 12-16
    ),
  ),
)

// Buttons עם padding מצומצם:
TextButton(
  style: TextButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  ),
  child: Text('...'),
)
```

#### 5️⃣ **ScrollView גמיש**

תמיד השתמש ב-`SingleChildScrollView` גם אם המטרה להכניס הכל במסך - למקרה של מסכים קטנים:

```dart
SafeArea(
  child: Center( // ⚠️ חשוב - למרכוז אנכי!
    child: SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [...],
      ),
    ),
  ),
)
```

### דוגמה: מסך התחברות Compact 📱

```dart
// ראה את lib/screens/auth/login_screen.dart לדוגמה מלאה
```

**טכניקות שהוחלו:**

- ✅ Padding מצומצם: `16px` אופקי, `8px` אנכי
- ✅ לוגו מוקטן: `scale: 0.85`
- ✅ כותרת: גופן `24` במקום `28`
- ✅ רווחים: `8px` בין רוב האלמנטים
- ✅ כפתורים: גובה `44px` במקום `48px`
- ✅ טקסט קטן: `kFontSizeTiny (11px)` לקישורים
- ✅ Padding פנימי מצומצם בשדות טקסט

**תוצאה:** המסך נכנס במלואו ללא גלילה! 🎯

---

## 🎨 שימוש ברכיבים

### StickyButton

**📁 קוד מלא:** `lib/widgets/common/sticky_button.dart`

**שימוש:**

```dart
StickyButton(
  label: 'שמור',
  backgroundColor: kStickyGreen,
  rotation: -0.01,
  onPressed: () => _onSave(),
)
```

---

### StickyCard

**📁 קוד מלא:** `lib/widgets/common/sticky_card.dart`

**שימוש:**

```dart
StickyCard(
  backgroundColor: kStickyPink,
  rotation: -0.02,
  onTap: () => print('tapped!'),
  child: Text('פתק צבעוני'),
)
```

---

### StickyDialog

**📁 קוד מלא:** `lib/widgets/common/sticky_dialog.dart`

**שימוש:**

```dart
showDialog(
  context: context,
  builder: (context) => StickyDialog(
    title: '✓ הצלחה',
    content: 'הרשימה נשמרה!',
    backgroundColor: kStickyGreen,
  ),
);
```

---

## 📱 דוגמאות שימוש מלאות

### מסך התחברות (Login Screen) - Compact

**📁 קוד מלא:** `lib/screens/auth/login_screen.dart`

**טכניקות שהוחלו:**
- ✅ Padding מצומצם: `16px` אופקי, `8px` אנכי
- ✅ לוגו מוקטן: `scale: 0.85`
- ✅ כותרת: גופן `24` במקום `28`
- ✅ רווחים: `8px` בין רוב האלמנטים
- ✅ כפתורים: גובה `44px` במקום `48px`
- ✅ טקסט קטן: `kFontSizeTiny (11px)` לקישורים
- ✅ Padding פנימי מצומצם בשדות טקסט

**תוצאה:** המסך נכנס במלואו ללא גלילה! 🎯

---

### מסך Welcome

**📁 קוד מלא:** `lib/screens/welcome/welcome_screen.dart`

**עקרונות עיצוב:**
- ✅ רקע: `kPaperBackground + NotebookBackground()`
- ✅ לוגו מרכזי עם `Hero` animation
- ✅ StickyNote לכותרת ויתרונות
- ✅ צבעים שונים להבחנה (Yellow, Pink, Green)
- ✅ כפתורים ראשיים/משניים

### כרטיס מוצר

```dart
StickyNote(
  color: kStickyCyan,
  rotation: 0.005,
  child: ListTile(
    leading: Icon(Icons.shopping_cart, color: Colors.blue.shade700),
    title: Text('חלב 3%'),
    subtitle: Text('1 ליטר'),
    trailing: Text('₪5.90', style: TextStyle(fontWeight: FontWeight.bold)),
  ),
)
```

### הודעת הצלחה

```dart
StickyNote(
  color: kStickyGreen,
  rotation: -0.01,
  child: Row(
    children: [
      Icon(Icons.check_circle, color: Colors.green.shade700),
      SizedBox(width: kSpacingSmall),
      Expanded(child: Text('הרשימה נשמרה בהצלחה!')),
    ],
  ),
)
```

---

## ♿ נגישות

### בדיקת ניגודיות

כל הפתקים נבדקו עם WCAG 2.0:

- טקסט שחור (87%) על רקעים בהירים ✅
- טקסט כהה (54%) לטקסט משני ✅

### גדלי מגע

- כל הכפתורים: 48px מינימום (או 44px למסכים compact)
- אזורי לחיצה: 48x48px לפחות
- במסכים compact: 44px מקובל ועדיין נגיש

### Semantics

- כל הכפתורים מכילים `Semantics` אוטומטית
- תוויות ברורות לקוראי מסך

---

## 🎯 עקרונות שימוש

### ✅ עשה

1. **השתמש בצבעים בעקביות**

   - צהוב ללוגו ופעולות ראשיות
   - ורוד להתראות רכות
   - ירוק להצלחות
   - תכלת למידע
   - סגול ליצירתיות/בחירות

2. **הוסף סיבובים קלים**

   - שנה כיוון בין פתקים סמוכים
   - שמור בטווח -0.03 עד 0.03

3. **שמור על קריאות**

   - טקסט כהה על רקעים בהירים
   - שורות קצרות (עד 60 תווים)
   - גודל טקסט מינימלי: 11px (kFontSizeTiny)

4. **הוסף אנימציות**

   - הרכיבים כוללים אנימציות מובנות
   - השתמש בהן!

5. **תכנן למסך אחד** 📐

   - צמצם רווחים בחכמה
   - השתמש ב-Transform.scale להקטנת אלמנטים
   - שמור על SingleChildScrollView לגיבוי

6. **השתמש ב-withValues** ⚠️

   - תמיד `withValues(alpha: ...)` ולא `withOpacity`
   - זה ה-standard החדש של Flutter

7. **עטוף async callbacks**
   - `onPressed: () => _asyncFunction()`
   - לא `onPressed: _asyncFunction`

### ❌ אל תעשה

1. **אל תשתמש ביותר מ-3 צבעי פתקים במסך אחד**

   - יותר מדי צבעים = בלגן ויזואלי

2. **אל תשתמש בסיבובים חזקים**

   - מעל 0.05 רדיאנים נראה לא טבעי

3. **אל תשכח נגישות**

   - שמור על גובה 48px לכפתורים (או 44px למסכים compact)
   - בדוק ניגודיות

4. **אל תערבב עם סגנונות אחרים**

   - פתקים + Material Cards = לא עקבי
   - בחר בסגנון אחד

5. **אל תצמצם יותר מדי** ⚠️

   - אל תרד מתחת ל-44px לכפתורים
   - אל תרד מתחת ל-11px לטקסט
   - אל תרד מתחת ל-4px לרווחים

6. **אל תשתמש ב-withOpacity** 🚫

   - זה deprecated - השתמש ב-withValues

7. **אל תשכח Stack עם NotebookBackground**
   - תמיד עטוף ב-Stack כשמשתמשים ברקע מחברת

---

## 🔄 עדכון מסכים קיימים

### צ'קליסט להמרה ל-Sticky Notes:

**1. רקע:**
```dart
✅ backgroundColor: kPaperBackground
✅ Stack + NotebookBackground()
```

**2. תוכן:**
```dart
❌ Card → ✅ StickyNote
❌ Container → ✅ StickyNote
```

**3. כפתורים:**
```dart
❌ ElevatedButton → ✅ StickyButton
❌ TextButton → ✅ StickyButton(color: Colors.white)
```

**4. Compact (אם צריך):**
```dart
✅ padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)
✅ Transform.scale(scale: 0.85) ללוגו
✅ height: 44 לכפתורים
✅ SizedBox(height: 8) רווחים
```

---

## 🐛 פתרון בעיות נפוצות

### שגיאה: "can't be assigned to VoidCallback"

```dart
// ❌ השגיאה:
StickyButton(
  onPressed: _handleLogin, // זה Future<void>
)

// ✅ הפתרון:
StickyButton(
  onPressed: () => _handleLogin(), // עטיפה בלמבדה
)
```

### שגיאה: "withOpacity is deprecated"

```dart
// ❌ ישן:
Colors.white.withOpacity(0.7)

// ✅ חדש:
Colors.white.withValues(alpha: 0.7)
```

### בעיה: הכל לא נכנס במסך

**פתרון:**

1. הקטן padding: `horizontal: 16, vertical: 8`
2. הקטן רווחים: רוב ל-`8px`
3. הקטן לוגו: `Transform.scale(scale: 0.85)`
4. הקטן כפתורים: `height: 44`
5. הקטן טקסטים: `fontSize: 24, 14, 11`
6. צמצם contentPadding בשדות טקסט

### בעיה: המסך נראה ריק מדי

**פתרון:**

- אל תרד מתחת ל-`8px` רווחים בין אלמנטים עיקריים
- אל תרד מתחת ל-`scale: 0.75` ללוגו
- שמור על `16px` padding אופקי מינימלי

---

## 📚 קבצים רלוונטיים

### קבצי קוד

- `lib/core/ui_constants.dart` - כל הקבועים כולל צבעי פתקים
- `lib/theme/app_theme.dart` - Theme configuration
- `lib/widgets/common/notebook_background.dart` - רקע מחברת
- `lib/widgets/common/sticky_note.dart` - פתקים
- `lib/widgets/common/sticky_button.dart` - כפתורים
- `lib/screens/auth/login_screen.dart` - דוגמה מלאה למסך compact ⭐
- `lib/widgets/auth/demo_login_button.dart` - דוגמה לרכיב compact ⭐

### מסמכים

- `DESIGN_GUIDE.md` - המדריך הזה
- `README.md` - מידע כללי על הפרויקט

---

## 🎓 טיפים מתקדמים

### 1. שימוש בקבועי צבעים

```dart
// הצבעים מוגדרים ב-ui_constants.dart
StickyNote(
  color: kStickyYellow, // צבע מהקבועים
  child: Text('פתק צבעוני'),
)
```

### 2. אנימציות מדורגות

```dart
Column(
  children: List.generate(3, (i) {
    return StickyNote(
      color: colors[i],
      child: Text('פתק ${i + 1}'),
    ).animate().fadeIn(
      delay: Duration(milliseconds: 100 * i), // עיכוב הדרגתי
    );
  }),
)
```

### 3. פתקים אינטראקטיביים

```dart
GestureDetector(
  onTap: () => print('נלחץ!'),
  child: StickyNote(
    color: kStickyPink,
    child: Text('לחץ עלי'),
  ),
)
```

### 4. שילוב עם Form Validation

```dart
StickyNote(
  color: kStickyCyan,
  rotation: 0.01,
  child: TextFormField(
    decoration: InputDecoration(
      labelText: 'אימייל',
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.7),
    ),
    validator: (value) {
      if (value?.isEmpty ?? true) return 'שדה חובה';
      return null;
    },
  ),
)
```

---

## 📞 תמיכה

יש שאלות על העיצוב? פנה למפתח הראשי או פתח issue ב-GitHub.

---

## 📝 Changelog

### v1.3 - 19/10/2025 🆕 **LATEST - Lean & Focused**

- ✅ **קיצוץ דוגמאות קוד** - הסרת ~200 שורות duplications
- ✅ **קיצוץ דוגמאות שימוש** - הסרת ~160 שורות duplications
- ✅ **קיצוץ עדכון מסכים** - הסרת ~50 שורות duplications
- ✅ **references במקום קוד** - קישורים לקבצים במקום שכפול
- 📊 **סה"כ הפחתה:** ~410 שורות (37%!)

### v1.2 - 16/10/2025

- ✅ **תיקון imports** - שינוי מ-`memozap` ל-`salsheli`
- ✅ **הסרת AppBrand** - שימוש בקבועים מ-`ui_constants.dart` בלבד
- ✅ **עדכון דוגמאות** - כל הקוד משתמש בקבועים הנכונים
- ✅ **הוספת const** - ל-SizedBox ורכיבים קבועים

### v1.1 - 15/10/2025

- ✅ הוספת מדריך לעיצוב Compact
- ✅ דוגמה מלאה למסך התחברות
- ✅ המלצות לצמצום רווחים
- ✅ טיפים לעבודה עם async callbacks
- ✅ עדכון ל-withValues במקום withOpacity
- ✅ פתרון בעיות נפוצות

### v1.0 - 15/10/2025

- 🎉 גרסה ראשונית
- מערכת עיצוב מלאה
- כל הרכיבים והקבועים

---

**גרסה:** 1.3 🎯  
**תאריך:** 19/10/2025  
**מעודכן לאחרונה:** 19/10/2025

🎨 **Happy Designing!** 📝
