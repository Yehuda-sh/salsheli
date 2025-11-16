// 📄 File: lib/widgets/common/sticky_button.dart
// 🎯 Purpose: כפתור בסגנון פתק מודבק
//
// 📋 Features:
// - כפתור עם עיצוב פתק Post-it
// - צללים מציאותיים
// - אנימציית לחיצה (AnimatedButton)
// - נגישות מלאה (Semantics)
// - גובה מינימלי 48px לנגישות
//
// 🔗 Related:
// - AnimatedButton - אנימציית לחיצה
// - ui_constants.dart - קבועי גדלים
// - app_theme.dart - AppBrand
//
// 🎨 Design:
// - רקע צבעוני (ניתן להתאמה)
// - צל בודד חזק
// - פינות מעוגלות (4px)
// - אייקון + טקסט
//
// Usage:
// ```dart
// StickyButton(
//   color: Colors.green,
//   label: 'לחץ כאן',
//   icon: Icons.check,
//   onPressed: () => print('נלחץ!'),
// )
// ```
//
// Version: 1.0 - Sticky Notes Design System (15/10/2025)

import 'package:flutter/material.dart';
import '../../core/ui_constants.dart';
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

  const StickyButton({
    super.key,
    this.color,
    this.textColor,
    required this.label,
    this.icon,
    this.onPressed,
    this.height = kButtonHeight,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.primary;
    final isDisabled = onPressed == null && !isLoading;

    // בחר צבע טקסט אוטומטית לפי בהירות הרקע
    final btnTextColor = isDisabled
        ? theme.colorScheme.onSurfaceVariant // ✅ צבע disabled
        : (textColor ??
            (ThemeData.estimateBrightnessForColor(buttonColor) == Brightness.light
                ? Colors.black
                : Colors.white));

    return Semantics(
      button: true,
      label: label,
      enabled: onPressed != null,
      child: IgnorePointer(
        ignoring: isDisabled, // ✅ בטל לחיצות כש-disabled
        child: AnimatedButton(
          onPressed: onPressed ?? () {}, // חייב callback, אבל IgnorePointer מונע לחיצה
          child: Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: isDisabled ? buttonColor.withValues(alpha: 0.5) : buttonColor, // ✅ שקוף כש-disabled
            borderRadius: BorderRadius.circular(kStickyButtonRadius),
            boxShadow: isDisabled
                ? null // ✅ הסר shadow כש-disabled
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: kStickyShadowPrimaryOpacity),
                      blurRadius: kStickyShadowPrimaryBlur,
                      offset: const Offset(
                        kStickyShadowPrimaryOffsetX,
                        kStickyShadowPrimaryOffsetY,
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
      ),
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

  const StickyButtonSmall({
    super.key,
    this.color,
    this.textColor,
    required this.label,
    this.icon,
    this.onPressed,
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
    );
  }
}
