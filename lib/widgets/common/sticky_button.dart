// 📄 lib/widgets/common/sticky_button.dart
//
// כפתור בסגנון פתק Post-it עם צללים ואנימציות.
// - StickyButton (48px) + StickyButtonSmall (36px)
// - תמיכה ב-isLoading, disabled state, נגישות (Semantics)
//
// ✨ Features:
// - עומק ויזואלי באמצעות גרדיאנט עדין
// - ניהול ריווחים באמצעות Gap
// - אופטימיזציית RepaintBoundary
// - משוב Haptic מבוסס מצב
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
//

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

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
/// - [haptic]: סוג משוב רטט (ברירת מחדל: light)
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
///   haptic: ButtonHaptic.medium,
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

  /// סוג משוב רטט (ברירת מחדל: light לכפתורי CTA)
  final ButtonHaptic haptic;

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
    this.haptic = ButtonHaptic.light,
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
        ? theme.colorScheme.onSurfaceVariant
        : (textColor ??
            (ThemeData.estimateBrightnessForColor(buttonColor) == Brightness.light
                ? theme.colorScheme.onSurface
                : theme.colorScheme.surface));

    // ✅ AnimatedButton is effect-only - Material+InkWell handles tap with ripple
    final isEnabled = onPressed != null && !isLoading;
    final borderRadius = BorderRadius.circular(kStickyButtonRadius);

    // 🎨 גרדיאנט לעומק פיזי - נייר שתופס אור
    final effectiveColor = isDisabled ? buttonColor.withValues(alpha: 0.5) : buttonColor;
    final gradientBottom = Color.lerp(effectiveColor, shadowColor, 0.05)!;

    final Widget buttonWidget = RepaintBoundary(
      child: Semantics(
        button: true,
        label: label,
        enabled: isEnabled,
        child: AnimatedButton(
          enabled: isEnabled,
          haptic: haptic,
          child: Material(
            color: Colors.transparent,
            borderRadius: borderRadius,
            child: Container(
              width: double.infinity,
              height: height,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [effectiveColor, gradientBottom],
                ),
                boxShadow: isDisabled || elevation <= 0
                    ? null
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
              child: InkWell(
                onTap: isEnabled ? onPressed : null,
                borderRadius: borderRadius,
                splashColor: btnTextColor.withValues(alpha: 0.15),
                highlightColor: btnTextColor.withValues(alpha: 0.08),
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          height: kIconSizeSmall,
                          width: kIconSizeSmall,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(btnTextColor),
                          ),
                        )
                          .animate()
                          .fadeIn(duration: 300.ms)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (icon != null) ...[
                              Icon(icon, color: btnTextColor, size: kIconSize),
                              const Gap(kSpacingSmall),
                            ],
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                color: btnTextColor,
                                fontSize: kFontSizeLarge,
                                fontWeight: FontWeight.w600,
                              ),
                              child: Text(label),
                            ),
                          ],
                        ),
                ),
              ),
            ),
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

  /// סוג משוב רטט (ברירת מחדל: light)
  final ButtonHaptic haptic;

  const StickyButtonSmall({
    super.key,
    this.color,
    this.textColor,
    required this.label,
    this.icon,
    this.onPressed,
    this.elevation = 1.0,
    this.tooltip,
    this.haptic = ButtonHaptic.light,
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
      haptic: haptic,
    );
  }
}
