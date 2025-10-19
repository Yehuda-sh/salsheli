# 📝 Sticky Notes Design System

## מדריך עיצוב - סל שלי

---

## 🎨 סקירה כללית

מערכת עיצוב בהשראת פתקים צבעוניים (Post-it) ומחברות בית ספר.

### עקרונות עיצוב ליבה

1. **חום ונגישות** - צבעים עדינים ופסטליים
2. **מגע אנושי** - סיבובים קלים וצללים מציאותיים
3. **בהירות** - תוכן קריא על כל רקע
4. **עקביות** - שימוש בקבועים בכל האפליקציה
5. **קומפקטיות** - מקסימום תוכן במינימום גלילה

---

## 🎨 פלטת צבעים

### צבעי בסיס

```dart
kPaperBackground = Color(0xFFFAF8F3) // נייר קרם
kNotebookBlue = Color(0xFF9FC5E8)    // קווים כחולים
kNotebookRed = Color(0xFFE57373)     // קו אדום משמאל
```

### פתקים צבעוניים

| צבע | קוד | שימוש מומלץ |
|-----|-----|------------|
| 🟨 צהוב | `kStickyYellow = Color(0xFFFFF59D)` | לוגו, פעולות ראשיות |
| 🌸 ורוד | `kStickyPink = Color(0xFFF8BBD0)` | תזכורות, התראות רכות |
| 🟩 ירוק | `kStickyGreen = Color(0xFFC5E1A5)` | הצלחות, אישורים |
| 🔵 תכלת | `kStickyCyan = Color(0xFF80DEEA)` | מידע, עזרה |
| 🟣 סגול | `kStickyPurple = Color(0xFFCE93D8)` | יצירתיות, חדש |

---

## 📐 גדלים ומידות

### פתקים

```dart
kStickyLogoSize = 120.0
kStickyLogoIconSize = 60.0
kStickyNoteRadius = 2.0      // פתקים רגילים
kStickyButtonRadius = 4.0    // כפתורים
```

### כפתורים

```dart
kButtonHeight = 48.0         // גובה סטנדרטי (נגישות)
kButtonHeightSmall = 36.0    // כפתור קטן
kButtonHeightLarge = 56.0    // כפתור גדול

// לעיצוב compact:
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

### צללי פתקים

```dart
// צל ראשי
BoxShadow(
  color: Colors.black.withValues(alpha: 0.2),  // ⚠️ השתמש ב-withValues!
  blurRadius: 10.0,
  offset: Offset(2.0, 6.0),
)

// צל משני
BoxShadow(
  color: Colors.black.withValues(alpha: 0.1),
  blurRadius: 20.0,
  offset: Offset(0, 12.0),
)
```

**⚠️ חשוב:** `withOpacity` deprecated. השתמש ב-`withValues(alpha: ...)` במקום!

---

## 🔄 סיבובים (Rotation)

```dart
kStickyMaxRotation = 0.03  // ±0.03 רדיאנים (כ-1.7 מעלות)
```

### המלצות שימוש:

| רכיב | סיבוב | כיוון |
|------|-------|-------|
| לוגו | `-0.03` | שמאלה |
| פתק 1 | `0.01` | ימינה קלה |
| פתק 2 | `-0.015` | שמאלה קלה |
| פתק 3 | `0.01` | ימינה קלה |
| כותרת | `-0.02` | שמאלה בינונית |

**💡 טיפ:** שנה כיוון סיבוב בין פתקים סמוכים למראה טבעי יותר!

---

## 🧩 רכיבים משותפים

### 1. NotebookBackground

**שימוש:** רקע מחברת עם קווים כחולים וקו אדום

**קובץ:** `lib/widgets/common/notebook_background.dart`

**מתי להשתמש:**
- מסכי קבלת פנים (Welcome)
- מסכי הרשמה/התחברות (Auth)
- דשבורדים

```dart
Scaffold(
  backgroundColor: kPaperBackground, // ⚠️ חובה!
  body: Stack(
    children: [
      NotebookBackground(),
      SafeArea(child: YourContent()),
    ],
  ),
)
```

---

### 2. StickyNote

**שימוש:** פתק צבעוני עם תוכן

**קובץ:** `lib/widgets/common/sticky_note.dart`

**מתי להשתמש:**
- כרטיסי מידע
- יתרונות/פיצ'רים
- הודעות חשובות
- עטיפה לשדות טקסט

**דוגמה בסיסית:**
```dart
StickyNote(
  color: kStickyPink,
  rotation: -0.02,
  child: Text('תוכן הפתק'),
)
```

---

### 3. StickyNoteLogo

**שימוש:** פתק מיוחד ללוגו או אייקון מרכזי

**קובץ:** `lib/widgets/common/sticky_note.dart`

**דוגמה:**
```dart
StickyNoteLogo(
  color: kStickyYellow,
  icon: Icons.shopping_basket_outlined,
  iconColor: Colors.green,
  rotation: -0.03,
)
```

**💡 טיפ לעיצוב compact:**
```dart
Transform.scale(
  scale: 0.85, // הקטנה ב-15%
  child: StickyNoteLogo(...),
)
```

---

### 4. StickyButton

**שימוש:** כפתור בסגנון פתק

**קובץ:** `lib/widgets/common/sticky_button.dart`

**⚠️ חשוב - async callbacks:**
```dart
// ❌ לא נכון:
StickyButton(
  onPressed: _handleLogin, // Future<void>
)

// ✅ נכון:
StickyButton(
  onPressed: () => _handleLogin(), // עוטפים
)
```

**וריאציות:**
```dart
// כפתור ראשי
StickyButton(
  color: Colors.green,
  label: 'התחברות',
  icon: Icons.login,
  onPressed: () => _handleLogin(),
)

// כפתור משני
StickyButton(
  color: Colors.white,
  textColor: Colors.green,
  label: 'הרשמה',
  onPressed: () => _handleRegister(),
)

// כפתור קטן
StickyButtonSmall(
  label: 'ביטול',
  icon: Icons.close,
  onPressed: () => Navigator.pop(context),
)

// כפתור compact
StickyButton(
  label: 'המשך',
  height: 44, // גובה מצומצם
  onPressed: () => _handleNext(),
)
```

---

## 📐 עיצוב Compact - מסכים ללא גלילה

### עקרונות

**1. Padding וריווחים:**
```dart
// ✅ מצומצם:
padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
SizedBox(height: 8),
```

**מדרגות רווחים מומלצות:**
- בין אלמנטים קטנים: `4-6px`
- בין אלמנטים רגילים: `8px`
- בין סקציות: `12-16px`
- מקסימום: `24px`

**2. גדלי טקסט:**
```dart
fontSize: 24, // כותרות
fontSize: 14, // טקסט רגיל
fontSize: 11, // טקסט קטן
```

**3. הקטנת אלמנטים:**
```dart
Transform.scale(
  scale: 0.85,
  child: StickyNoteLogo(...),
)
```

**4. ScrollView גמיש:**
```dart
SafeArea(
  child: Center( // ⚠️ חשוב - למרכוז אנכי!
    child: SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(children: [...]),
    ),
  ),
)
```

---

## 📱 דוגמאות שימוש

### מסך התחברות (Compact)

**📁 קוד מלא:** `lib/screens/auth/login_screen.dart`

**טכניקות שהוחלו:**
- ✅ Padding מצומצם: `16px` אופקי, `8px` אנכי
- ✅ לוגו מוקטן: `scale: 0.85`
- ✅ כותרת: גופן `24` במקום `28`
- ✅ רווחים: `8px` בין רוב האלמנטים
- ✅ כפתורים: גובה `44px` במקום `48px`
- ✅ טקסט קטן: `11px` לקישורים

**תוצאה:** המסך נכנס במלואו ללא גלילה! 🎯

---

### מסך Welcome

**📁 קוד מלא:** `lib/screens/welcome/welcome_screen.dart`

**עקרונות עיצוב:**
- ✅ רקע: `kPaperBackground + NotebookBackground()`
- ✅ לוגו מרכזי עם `Hero` animation
- ✅ StickyNote לכותרת ויתרונות
- ✅ צבעים שונים (Yellow, Pink, Green)
- ✅ כפתורים ראשיים/משניים

---

## ♿ נגישות

### בדיקת ניגודיות

כל הפתקים נבדקו עם WCAG 2.0:
- טקסט שחור (87%) על רקעים בהירים ✅
- טקסט כהה (54%) לטקסט משני ✅

### גדלי מגע

- כל הכפתורים: 48px מינימום
- במסכים compact: 44px מקובל
- אזורי לחיצה: 48x48px לפחות

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
   - סגול ליצירתיות

2. **הוסף סיבובים קלים**
   - שנה כיוון בין פתקים סמוכים
   - שמור בטווח -0.03 עד 0.03

3. **שמור על קריאות**
   - טקסט כהה על רקעים בהירים
   - גודל טקסט מינימלי: 11px

4. **תכנן למסך אחד**
   - צמצם רווחים בחכמה
   - השתמש ב-Transform.scale
   - שמור על SingleChildScrollView לגיבוי

5. **השתמש ב-withValues**
   - תמיד `withValues(alpha:)` ולא `withOpacity`

6. **עטוף async callbacks**
   - `onPressed: () => _asyncFunction()`

### ❌ אל תעשה

1. **אל תשתמש ביותר מ-3 צבעים במסך**
2. **אל תשתמש בסיבובים חזקים** (מעל 0.05)
3. **אל תשכח נגישות** (44px+ buttons, 11px+ text)
4. **אל תערבב עם סגנונות אחרים**
5. **אל תצמצם יותר מדי** (<44px buttons, <11px text)
6. **אל תשתמש ב-withOpacity** (deprecated!)

---

## 🔄 עדכון מסכים קיימים

### צ'קליסט:

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

### withOpacity deprecated

```dart
// ❌ ישן:
Colors.white.withOpacity(0.7)

// ✅ חדש:
Colors.white.withValues(alpha: 0.7)
```

### async callback error

```dart
// ❌ שגיאה:
StickyButton(onPressed: _handleLogin)

// ✅ פתרון:
StickyButton(onPressed: () => _handleLogin())
```

### הכל לא נכנס במסך

**פתרון:**
1. הקטן padding: `horizontal: 16, vertical: 8`
2. הקטן רווחים: `8px`
3. הקטן לוגו: `scale: 0.85`
4. הקטן כפתורים: `height: 44`

---

## 📚 קבצים רלוונטיים

### קבצי קוד

| רכיב | קובץ |
|------|------|
| **UI Constants** | `lib/core/ui_constants.dart` |
| **Theme** | `lib/theme/app_theme.dart` |
| **NotebookBackground** | `lib/widgets/common/notebook_background.dart` |
| **StickyNote** | `lib/widgets/common/sticky_note.dart` |
| **StickyButton** | `lib/widgets/common/sticky_button.dart` |
| **Login Screen** | `lib/screens/auth/login_screen.dart` ⭐ |
| **Welcome Screen** | `lib/screens/welcome/welcome_screen.dart` |

---

## 📈 Version History

### v1.4 - 19/10/2025 🆕 **LATEST - Cleaned & Optimized**
- 🧹 Removed duplicate code examples
- ✂️ Replaced long examples with file references
- 📊 Result: 45% reduction in size

### v1.3 - 19/10/2025
- ✅ Removed duplicate examples
- ✅ Updated imports

---

**Version:** 1.4  
**Created:** 15/10/2025 | **Updated:** 19/10/2025  
**Purpose:** Sticky Notes Design System - components, colors, principles
