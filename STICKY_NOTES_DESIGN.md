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
  color: brand.accent,  // צבע accent מה-theme
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

## 🎨 דוגמאות קוד - Sticky Components

### StickyButton Widget

```dart
// lib/widgets/common/sticky_button.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/app_brand.dart';
import '../../core/ui_constants.dart';

class StickyButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final double? rotation;
  final bool isEnabled;

  const StickyButton({
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.rotation,
    this.isEnabled = true,
  });

  @override
  State<StickyButton> createState() => _StickyButtonState();
}

class _StickyButtonState extends State<StickyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? AppBrand.stickyYellow;
    final rotation = widget.rotation ?? 0.01;
    
    return Transform.rotate(
      angle: rotation,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: GestureDetector(
          onTapDown: (_) {
            if (!widget.isEnabled) return;
            setState(() => _isPressed = true);
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            if (widget.isEnabled) widget.onPressed();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: kSpacingLarge,
              vertical: kSpacingMedium,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(kStickyBorderRadius),
              boxShadow: kStickyShadow,
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1.5,
              ),
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

**שימוש:**
```dart
StickyButton(
  label: 'שמור',
  backgroundColor: AppBrand.stickyGreen,
  rotation: -0.01,
  onPressed: _onSave,
)
```

---

### StickyCard Widget

```dart
// lib/widgets/common/sticky_card.dart

class StickyCard extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final double? rotation;
  final EdgeInsets? padding;

  const StickyCard({
    required this.child,
    this.backgroundColor = AppBrand.stickyYellow,
    this.onTap,
    this.rotation,
    this.padding,
  });

  @override
  State<StickyCard> createState() => _StickyCardState();
}

class _StickyCardState extends State<StickyCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final rotation = widget.rotation ?? 
        math.Random().nextDouble() * 0.04 - 0.02;
    
    return Transform.rotate(
      angle: rotation,
      child: GestureDetector(
        onTapDown: widget.onTap != null ? (_) {
          setState(() => _isPressed = true);
        } : null,
        onTapUp: widget.onTap != null ? (_) {
          setState(() => _isPressed = false);
          widget.onTap?.call();
        } : null,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 150),
          transform: _isPressed 
            ? (Matrix4.identity()..scale(0.98))
            : Matrix4.identity(),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(kStickyBorderRadius),
            boxShadow: kStickyShadow,
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: widget.padding ?? EdgeInsets.all(kSpacingMedium),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
```

**שימוש:**
```dart
StickyCard(
  backgroundColor: AppBrand.stickyPink,
  rotation: -0.02,
  onTap: () => print('tapped!'),
  child: Text('פתק צבעוני'),
)
```

---

### StickyDialog Widget

```dart
class StickyDialog extends StatelessWidget {
  final String title;
  final String content;
  final Color backgroundColor;

  const StickyDialog({
    required this.title,
    required this.content,
    this.backgroundColor = AppBrand.stickyYellow,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Transform.rotate(
        angle: 0.01,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(kStickyBorderRadius),
            boxShadow: kStickyShadow,
            border: Border.all(color: Colors.grey[300]!, width: 2),
          ),
          child: Padding(
            padding: EdgeInsets.all(kSpacingLarge),
            child: Column([
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: kSpacingMedium),
              Text(content),
              SizedBox(height: kSpacingLarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  StickyButton(
                    label: 'סגור',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
```

**שימוש:**
```dart
showDialog(
  context: context,
  builder: (context) => StickyDialog(
    title: '✓ הצלחה',
    content: 'הרשימה נשמרה!',
    backgroundColor: AppBrand.stickyGreen,
  ),
);
```

---

## 📱 דוגמאות שימוש מלאות

### מסך התחברות (Login Screen) - Compact

```dart
import 'package:flutter/material.dart';
import 'package:salsheli/widgets/common/notebook_background.dart';
import 'package:salsheli/widgets/common/sticky_note.dart';
import 'package:salsheli/widgets/common/sticky_button.dart';
import 'package:salsheli/core/ui_constants.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPaperBackground,
      body: Stack(
        children: [
          NotebookBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: kSpacingMedium, // 16px
                  vertical: kSpacingSmall, // 8px
                ),
                child: Column(
                  children: [
                    SizedBox(height: kSpacingSmall),
                    
                    // לוגו מוקטן
                    Transform.scale(
                      scale: 0.85,
                      child: StickyNoteLogo(
                        color: kStickyYellow,
                        icon: Icons.shopping_basket_outlined,
                        rotation: -0.03,
                      ),
                    ),
                    SizedBox(height: kSpacingSmall),
                    
                    // כותרת compact
                    StickyNote(
                      color: Colors.white,
                      rotation: -0.02,
                      child: Column(
                        children: [
                          Text(
                            'התחברות',
                            style: TextStyle(
                              fontSize: 24, // מצומצם
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'ברוך שובך!',
                            style: TextStyle(fontSize: kFontSizeSmall),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: kSpacingMedium),
                    
                    // שדה אימייל
                    StickyNote(
                      color: kStickyCyan,
                      rotation: 0.01,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'אימייל',
                          prefixIcon: Icon(Icons.email_outlined),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: kSpacingMedium,
                            vertical: kSpacingSmall,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: kSpacingSmall),
                    
                    // שדה סיסמה
                    StickyNote(
                      color: kStickyGreen,
                      rotation: -0.015,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'סיסמה',
                          prefixIcon: Icon(Icons.lock_outlined),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: kSpacingMedium,
                            vertical: kSpacingSmall,
                          ),
                        ),
                        obscureText: true,
                      ),
                    ),
                    SizedBox(height: kSpacingMedium),
                    
                    // כפתור התחברות
                    StickyButton(
                      color: Colors.green,
                      label: 'התחבר',
                      icon: Icons.login,
                      onPressed: () => _handleLogin(),
                      height: 44, // compact
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

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
                    child: ListTile(
                      leading: Icon(Icons.people_outline),
                      title: Text('שיתוף בקבוצה'),
                      subtitle: Text('כולם רואים את אותה רשימה'),
                    ),
                  ),
                  
                  SizedBox(height: kSpacingMedium),
                  
                  StickyNote(
                    color: kStickyPink,
                    rotation: -0.015,
                    child: ListTile(
                      leading: Icon(Icons.camera_alt_outlined),
                      title: Text('סריקת קבלות'),
                      subtitle: Text('צלם והכל יתווסף אוטומטית'),
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
              onPressed: () {}, // לא async? תעביר ישירות
            ),
          ],
        ),
      ),
    ],
  ),
)
```

### המרה ל-Compact:

```dart
Scaffold(
  backgroundColor: kPaperBackground,
  body: Stack(
    children: [
      NotebookBackground(),
      SafeArea(
        child: Center( // ⭐ חשוב למרכוז
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: kSpacingMedium, // 16px
              vertical: kSpacingSmall, // 8px
            ),
            child: Column(
              children: [
                // הקטן אלמנטים גדולים
                Transform.scale(
                  scale: 0.85,
                  child: StickyNoteLogo(...),
                ),
                SizedBox(height: kSpacingSmall), // רווחים קטנים
                
                StickyNote(
                  color: kStickyYellow,
                  rotation: 0.01,
                  child: Text('תוכן'),
                ),
                SizedBox(height: kSpacingSmall),
                
                StickyButton(
                  label: 'כפתור',
                  height: 44, // ⭐ גובה מצומצם
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  ),
)
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
- `lib/core/ui_constants.dart` - כל הקבועים
- `lib/theme/app_theme.dart` - AppBrand עם צבעי פתקים
- `lib/widgets/common/notebook_background.dart` - רקע מחברת
- `lib/widgets/common/sticky_note.dart` - פתקים
- `lib/widgets/common/sticky_button.dart` - כפתורים
- `lib/screens/auth/login_screen.dart` - דוגמה מלאה למסך compact ⭐
- `lib/widgets/auth/demo_login_button.dart` - דוגמה לרכיב compact ⭐

### מסמכים
- `STICKY_NOTES_DESIGN.md` - המדריך הזה
- `README.md` - מידע כללי על הפרויקט

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

**גרסה:** 1.1  
**תאריך:** 15/10/2025  
**מעודכן לאחרונה:** 15/10/2025

🎨 **Happy Designing!** 📝
