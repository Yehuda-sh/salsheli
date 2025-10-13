// 📄 File: lib/widgets/auth/auth_button.dart
// תיאור: כפתור מעוצב למסכי Auth (התחברות/הרשמה/Welcome)
// Version: 2.0 - Constants Integration
// Last Updated: 10/10/2025
//
// תכונות:
// - תומך ב-2 סגנונות: primary (מלא) ו-secondary (קווי)
// - גדלי מגע מינימליים 48x48
// - אייקון אופציונלי
// - מצב loading
// - שימוש בצבעי Theme
// - תמיכה מלאה ב-RTL (symmetric padding)
//
// 💡 דוגמאות שימוש:
//
// // כפתור primary (מלא)
// AuthButton.primary(
//   label: 'התחבר',
//   icon: Icons.login,
//   onPressed: () => _handleLogin(),
//   isLoading: _isLoading,
// )
//
// // כפתור secondary (קווי)
// AuthButton.secondary(
//   label: 'הרשמה',
//   icon: Icons.person_add,
//   onPressed: () => Navigator.push(...),
// )
//
// // בלי אייקון
// AuthButton(
//   label: 'המשך',
//   onPressed: _handleNext,
//   type: AuthButtonType.primary,
// )
//
// ♿ Accessibility:
// - הטקסט מוקרא אוטומטית על ידי screen readers
// - גודל מגע מינימלי 48x48 (Material Design)
// - ניגודיות צבעים: AA compliant

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/ui_constants.dart';

/// סוג הכפתור
enum AuthButtonType {
  /// כפתור מלא (ElevatedButton) - צבע רקע ענבר
  primary,

  /// כפתור קווי (OutlinedButton) - מסגרת ענבר
  secondary,
}

class AuthButton extends StatelessWidget {
  /// טקסט הכפתור
  final String label;

  /// פעולה בלחיצה
  final VoidCallback? onPressed;

  /// אייקון אופציונלי
  final IconData? icon;

  /// סוג הכפתור (primary/secondary)
  final AuthButtonType type;

  /// האם להציג loading spinner
  final bool isLoading;

  /// גודל טקסט (ברירת מחדל: kFontSizeMedium)
  final double fontSize;

  const AuthButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.type = AuthButtonType.primary,
    this.isLoading = false,
    this.fontSize = kFontSizeMedium,
  });

  /// Constructor ייעודי לכפתור primary
  const AuthButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fontSize = kFontSizeMedium,
  }) : type = AuthButtonType.primary;

  /// Constructor ייעודי לכפתור secondary
  const AuthButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fontSize = kFontSizeMedium,
  }) : type = AuthButtonType.secondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    // תוכן הכפתור (טקסט + אייקון אופציונלי)
    final content = isLoading
        ? SizedBox(
            width: kIconSize,
            height: kIconSize,
            child: CircularProgressIndicator(
              strokeWidth: kBorderWidthFocused,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == AuthButtonType.primary ? Colors.black : accent,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: type == AuthButtonType.primary ? Colors.black : accent,
                  size: kIconSizeMedium,
                ),
                const SizedBox(width: kSpacingSmall),
              ],
              Text(label, style: TextStyle(fontSize: fontSize)),
            ],
          );

    // בניית הכפתור לפי הסוג
    if (type == AuthButtonType.primary) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: kSpacingMedium),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            minimumSize: const Size(double.infinity, kButtonHeight),
          ),
          child: content,
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: accent, width: kBorderWidthFocused),
            foregroundColor: accent,
            padding: const EdgeInsets.symmetric(vertical: kSpacingMedium),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            minimumSize: const Size(double.infinity, kButtonHeight),
          ),
          child: content,
        ),
      );
    }
  }
}
