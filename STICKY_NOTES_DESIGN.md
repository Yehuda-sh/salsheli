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

| צבע | קוד | שימוש מומלץ |
|-----|-----|-------------|
| 🟨 צהוב | `kStickyYellow = Color(0xFFFFF59D)` | לוגו, פעולות ראשיות |
| 🌸 ורוד | `kStickyPink = Color(0xFFF8BBD0)` | תזכורות, התראות רכות |
| 🟩 ירוק | `kStickyGreen = Color(0xFFC5E1A5)` | הצלחות, אישורים |
| 🔵 תכלת | `kStickyCyan = Color(0xFF80DEEA)` | מידע, עזרה |
| 🟣 סגול | `kStickyPurple = Color(0xFFCE93D8)` | יצירתיות, חדש |

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
  color: Colors.black.withOpacity(0.2),  // kStickyShadowPrimaryOpacity
  blurRadius: 10.0,                       // kStickyShadowPrimaryBlur
  offset: Offset(2.0, 6.0),              // X, Y
)

// צל משני - עומק
BoxShadow(
  color: Colors.black.withOpacity(0.1),  // kStickyShadowSecondaryOpacity
  blurRadius: 20.0,                       // kStickyShadowSecondaryBlur
  offset: Offset(0, 12.0),               // Y בלבד
)
```

### צללי לוגו (חזקים יותר)

```dart
// צל ראשי
BoxShadow(
  color: Colors.black.withOpacity(0.25), // kStickyLogoShadowPrimaryOpacity
  blurRadius: 12.0,                       // kStickyLogoShadowPrimaryBlur
  offset: Offset(2.0, 8.0),
)

// צל משני
BoxShadow(
  color: Colors.black.withOpacity(0.12), // kStickyLogoShadowSecondaryOpacity
  blurRadius: 24.0,                       // kStickyLogoShadowSecondaryBlur
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

---

## 🧩 רכיבים משותפים

### 1. NotebookBackground

רקע מחברת עם קווים כחולים וקו אדום.

```dart
import 'package:flutter/material.dart';
import 'package:salsheli/widgets/common/notebook_background.dart';

Scaffold(
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
- מסכי הרשמה (Onboarding)
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
      SizedBox(height: 8),
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

**וריאציות:**

```dart
// כפתור ראשי
StickyButton(
  color: brand.accent,  // צבע accent מה-theme
  label: 'התחברות',
  icon: Icons.login,
  onPressed: () {},
)

// כפתור משני
StickyButton(
  color: Colors.white,
  textColor: Colors.green,
  label: 'הרשמה',
  icon: Icons.app_registration_outlined,
  onPressed: () {},
)

// כפתור קטן
StickyButtonSmall(
  label: 'ביטול',
  icon: Icons.close,
  onPressed: () => Navigator.pop(context),
)
```

**נגישות:**
- גובה מינימלי 48px
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

## 📱 דוגמאות שימוש מלאות

### מסך Welcome

```dart
import 'package:flutter/material.dart';
import 'package:salsheli/widgets/common/notebook_background.dart';
import 'package:salsheli/widgets/common/sticky_note.dart';
import 'package:salsheli/widgets/common/sticky_button.dart';
import 'package:salsheli/core/ui_constants.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<AppBrand>();
    
    return Scaffold(
      backgroundColor: kPaperBackground,
      body: Stack(
        children: [
          NotebookBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(kSpacingMedium),
              child: Column(
                children: [
                  SizedBox(height: kSpacingMedium),
                  
                  // לוגו
                  Hero(
                    tag: 'app_logo',
                    child: StickyNoteLogo(
                      color: kStickyYellow,
                      icon: Icons.shopping_basket_outlined,
                      iconColor: brand!.accent,
                    ),
                  ),
                  
                  SizedBox(height: kSpacingMedium),
                  
                  // כותרת
                  StickyNote(
                    color: Colors.white,
                    rotation: -0.02,
                    child: Column(
                      children: [
                        Text(
                          'ברוכים הבאים!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: kSpacingSmall),
                        Text(
                          'נהל את הקניות בקלות',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: kSpacingLarge),
                  
                  // יתרונות
                  StickyNote(
                    color: kStickyYellow,
                    rotation: 0.01,
                    child: BenefitTile(
                      icon: Icons.people_outline,
                      title: 'שיתוף בקבוצה',
                      subtitle: 'כולם רואים את אותה רשימה',
                    ),
                  ),
                  
                  SizedBox(height: kSpacingMedium),
                  
                  StickyNote(
                    color: kStickyPink,
                    rotation: -0.015,
                    child: BenefitTile(
                      icon: Icons.camera_alt_outlined,
                      title: 'סריקת קבלות',
                      subtitle: 'צלם והכל יתווסף אוטומטית',
                    ),
                  ),
                  
                  SizedBox(height: kSpacingLarge),
                  
                  // כפתורים
                  StickyButton(
                    color: brand.accent,
                    label: 'התחברות',
                    icon: Icons.login,
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                  ),
                  
                  SizedBox(height: kSpacingMedium),
                  
                  StickyButton(
                    color: Colors.white,
                    textColor: brand.accent,
                    label: 'הרשמה',
                    icon: Icons.app_registration_outlined,
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

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
- כל הכפתורים: 48px מינימום
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

2. **הוסף סיבובים קלים**
   - שנה כיוון בין פתקים סמוכים
   - שמור בטווח -0.03 עד 0.03

3. **שמור על קריאות**
   - טקסט כהה על רקעים בהירים
   - שורות קצרות (עד 60 תווים)

4. **הוסף אנימציות**
   - הרכיבים כוללים אנימציות מובנות
   - השתמש בהן!

### ❌ אל תעשה

1. **אל תשתמש ביותר מ-3 צבעי פתקים במסך אחד**
   - יותר מדי צבעים = בלגן ויזואלי

2. **אל תשתמש בסיבובים חזקים**
   - מעל 0.05 רדיאנים נראה לא טבעי

3. **אל תשכח נגישות**
   - שמור על גובה 48px לכפתורים
   - בדוק ניגודיות

4. **אל תערבב עם סגנונות אחרים**
   - פתקים + Material Cards = לא עקבי
   - בחר בסגנון אחד

---

## 🔄 עדכון מסכים קיימים

כדי להמיר מסך קיים לעיצוב Sticky Notes:

### לפני:
```dart
Scaffold(
  body: SafeArea(
    child: Column(
      children: [
        Card(
          child: Text('תוכן'),
        ),
        ElevatedButton(
          child: Text('כפתור'),
          onPressed: () {},
        ),
      ],
    ),
  ),
)
```

### אחרי:
```dart
Scaffold(
  backgroundColor: kPaperBackground,
  body: Stack(
    children: [
      NotebookBackground(),
      SafeArea(
        child: Column(
          children: [
            StickyNote(
              color: kStickyYellow,
              rotation: 0.01,
              child: Text('תוכן'),
            ),
            StickyButton(
              label: 'כפתור',
              onPressed: () {},
            ),
          ],
        ),
      ),
    ],
  ),
)
```

---

## 📚 קבצים רלוונטיים

### קבצי קוד
- `lib/core/ui_constants.dart` - כל הקבועים
- `lib/theme/app_theme.dart` - AppBrand עם צבעי פתקים
- `lib/widgets/common/notebook_background.dart` - רקע מחברת
- `lib/widgets/common/sticky_note.dart` - פתקים
- `lib/widgets/common/sticky_button.dart` - כפתורים
- `lib/screens/welcome_screen.dart` - דוגמה מלאה

### מסמכים
- `STICKY_NOTES_DESIGN.md` - המדריך הזה

---

## 🎓 טיפים מתקדמים

### 1. התאמת צבעים דינמית

```dart
final brand = Theme.of(context).extension<AppBrand>();

StickyNote(
  color: brand!.stickyYellow, // צבע מה-theme
  child: Text('פתק דינמי'),
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

---

## 📞 תמיכה

יש שאלות על העיצוב? פנה למפתח הראשי או פתח issue ב-GitHub.

---

**גרסה:** 1.0  
**תאריך:** 15/10/2025  
**מעודכן לאחרונה:** 15/10/2025

🎨 **Happy Designing!** 📝
