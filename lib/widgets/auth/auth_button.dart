// 📄 File: lib/widgets/auth/auth_button.dart
// תיאור: כפתור מעוצב למסכי Auth (התחברות/הרשמה/Welcome)
//
// תכונות:
// - תומך ב-2 סגנונות: primary (מלא) ו-secondary (קווי)
// - גדלי מגע מינימליים 48x48
// - אייקון אופציונלי
// - מצב loading
// - שימוש בצבעי Theme

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

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

  /// גודל טקסט (ברירת מחדל: 18)
  final double fontSize;

  const AuthButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.type = AuthButtonType.primary,
    this.isLoading = false,
    this.fontSize = 18.0,
  });

  /// Constructor ייעודי לכפתור primary
  const AuthButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fontSize = 18.0,
  }) : type = AuthButtonType.primary;

  /// Constructor ייעודי לכפתור secondary
  const AuthButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fontSize = 18.0,
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
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
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
                  size: 20,
                ),
                const SizedBox(width: 8),
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
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 48),
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
            side: BorderSide(color: accent, width: 1.5),
            foregroundColor: accent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 48),
          ),
          child: content,
        ),
      );
    }
  }
}
