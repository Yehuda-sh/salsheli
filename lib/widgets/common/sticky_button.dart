// 📄 lib/widgets/common/sticky_button.dart
//
// כפתור בסגנון פתק Post-it עם צללים ואנימציות.
// - StickyButton (48px) + StickyButtonSmall (36px)
// - תמיכה ב-isLoading, disabled state, נגישות (Semantics)
//
// ✅ תיקונים:
//    - ברירת מחדל לצבע: brand.accent (צבע מותג) במקום primary
//    - עקביות עם ElevatedButton שמשתמש ב-accent
//    - הוספת elevation parameter לשליטה בצללים
//    - הוספת Tooltip לנגישות
//    - הוספת HapticFeedback בלחיצה
//    - שימוש בצבע צל מ-Theme (לא Colors.black)
//
// 🔗 Related: AnimatedButton, ui_constants.dart, AppBrand, sticky_note.dart

import 'package:flutter/material.dart';
import '../../core/ui_constants.dart';
import '../../theme/app_theme.dart';
import 'animated_button.dart';

/// כפתור בסגנון פתק מודבק עם צללים ואנימציות
///
/// כפתור אינטראקטיבי שנראה כמו פתק Post-it מודבק.
/// כולל אנימציית לחיצה, נגישות מלאה, ועיצוב עקבי.
///
/// Parameters:
/// - [color]: צבע רקע הכפתור (ברירת מחדל: accent מה-Theme)
/// - [textColor]: צבע הטקסט והאייקון (ברירת מחדל: לבן או שחור לפי הצבע)
/// - [label]: טקסט הכפתור
/// - [icon]: אייקון להצגה (אופציונלי)
/// - [onPressed]: פעולה בלחיצה
/// - [height]: גובה הכפתור (ברירת מחדל: 48px לנגישות)
/// - [elevation]: רמת צל (0.0-1.0, ברירת מחדל: 1.0)
/// - [tooltip]: טקסט tooltip לנגישות (אופציונלי, ברירת מחדל: label)
///
/// דוגמה בסיסית:
/// ```dart
/// StickyButton(
///   label: 'המשך',
///   icon: Icons.arrow_forward,
///   onPressed: () => Navigator.push(...),
/// )
/// ```
///
/// דוגמה מתקדמת:
/// ```dart
/// StickyButton(
///   color: Colors.pink.shade100,
///   textColor: Colors.pink.shade900,
///   label: 'מחק',
///   icon: Icons.delete_outline,
///   elevation: 0.5,
///   onPressed: () => showDeleteDialog(),
/// )
/// ```
class StickyButton extends StatelessWidget {
  /// צבע רקע הכפתור
  final Color? color;

  /// צבע הטקסט והאייקון
  final Color? textColor;

  /// טקסט הכפתור
  final String label;

  /// אייקון להצגה (אופציונלי)
  final IconData? icon;

  /// פעולה בלחיצה
  final VoidCallback? onPressed;

  /// גובה הכפתור (ברירת מחדל: 48px)
  final double height;

  /// האם להציג מצב טעינה
  final bool isLoading;

  /// רמת צל (0.0-1.0, ברירת מחדל: 1.0)
  /// 0.0 = ללא צל, 1.0 = צל מלא
  final double elevation;

  /// טקסט tooltip לנגישות (אופציונלי)
  final String? tooltip;

  const StickyButton({
    super.key,
    this.color,
    this.textColor,
    required this.label,
    this.icon,
    this.onPressed,
    this.height = kButtonHeight,
    this.isLoading = false,
    this.elevation = 1.0,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<AppBrand>();
    // ✅ ברירת מחדל: brand.accent (צבע מותג) לעקביות עם ElevatedButton
    final buttonColor = color ?? brand?.accent ?? theme.colorScheme.primary;
    final isDisabled = onPressed == null;
    // ✅ צבע צל מ-Theme במקום Colors.black
    final shadowColor = theme.shadowColor;

    // בחר צבע טקסט אוטומטית לפי בהירות הרקע
    final btnTextColor = isDisabled
        ? theme.colorScheme.onSurfaceVariant // ✅ צבע disabled
        : (textColor ??
            (ThemeData.estimateBrightnessForColor(buttonColor) == Brightness.light
                ? Colors.black
                : Colors.white));

    // ✅ AnimatedButton already handles HapticFeedback - no need to add here
    final wrappedOnPressed = (onPressed != null && !isLoading) ? onPressed : null;

    final Widget buttonWidget = Semantics(
      button: true,
      label: label,
      enabled: onPressed != null && !isLoading,
      child: AnimatedButton(
        onPressed: wrappedOnPressed,
        child: Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: isDisabled ? buttonColor.withValues(alpha: 0.5) : buttonColor, // ✅ שקוף כש-disabled
            borderRadius: BorderRadius.circular(kStickyButtonRadius),
            boxShadow: isDisabled || elevation <= 0
                ? null // ✅ הסר shadow כש-disabled או elevation == 0
                : [
                    BoxShadow(
                      color: shadowColor.withValues(
                          alpha: kStickyShadowPrimaryOpacity * elevation),
                      blurRadius: kStickyShadowPrimaryBlur * elevation,
                      offset: Offset(
                        kStickyShadowPrimaryOffsetX,
                        kStickyShadowPrimaryOffsetY * elevation,
                      ),
                    ),
                  ],
          ),
          child: isLoading
              ? Center(
                  child: SizedBox(
                    height: kIconSizeSmall,
                    width: kIconSizeSmall,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(btnTextColor),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[Icon(icon, color: btnTextColor, size: kIconSize), const SizedBox(width: kSpacingSmall)],
                    Text(
                      label,
                      style: TextStyle(
                        color: btnTextColor,
                        fontSize: kFontSizeLarge,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );

    // ✅ הוסף Tooltip לנגישות
    return Tooltip(
      message: tooltip ?? label,
      child: buttonWidget,
    );
  }
}

/// כפתור פתק קטן - לפעולות משניות
///
/// גרסה קטנה יותר של StickyButton לשימוש בממשקים צפופים
/// או כפתורי פעולה משניים.
///
/// דוגמה:
/// ```dart
/// StickyButtonSmall(
///   label: 'ביטול',
///   icon: Icons.close,
///   onPressed: () => Navigator.pop(context),
/// )
/// ```
class StickyButtonSmall extends StatelessWidget {
  /// צבע רקע הכפתור
  final Color? color;

  /// צבע הטקסט והאייקון
  final Color? textColor;

  /// טקסט הכפתור
  final String label;

  /// אייקון להצגה (אופציונלי)
  final IconData? icon;

  /// פעולה בלחיצה
  final VoidCallback? onPressed;

  /// רמת צל (0.0-1.0, ברירת מחדל: 1.0)
  final double elevation;

  /// טקסט tooltip לנגישות (אופציונלי)
  final String? tooltip;

  const StickyButtonSmall({
    super.key,
    this.color,
    this.textColor,
    required this.label,
    this.icon,
    this.onPressed,
    this.elevation = 1.0,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return StickyButton(
      color: color,
      textColor: textColor,
      label: label,
      icon: icon,
      onPressed: onPressed,
      height: kButtonHeightSmall,
      elevation: elevation,
      tooltip: tooltip,
    );
  }
}
