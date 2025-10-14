// 📄 File: lib/widgets/auth/auth_button.dart
// תיאור: כפתור מעוצב למסכי Auth (התחברות/הרשמה/Welcome)
// Version: 3.0 - Modern UI/UX: Micro Animations + Accessibility ⭐
// Last Updated: 14/10/2025
//
// תכונות:
// - תומך ב-2 סגנונות: primary (מלא) ו-secondary (קווי)
// - 🎬 Button Animation - Scale ל-0.95 בלחיצה (150ms) ⭐ חדש!
// - ♿ Accessibility - Loading State עם Semantics ⭐ חדש!
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
// - Loading State: "טוען, אנא המתן..." למשתמשי screen readers
// - גודל מגע מינימלי 48x48 (Material Design)
// - ניגודיות צבעים: AA compliant
//
// 🎬 Animations:
// - Scale Animation: 1.0 → 0.95 בלחיצה (150ms)
// - Curve: easeInOut (חלק ונעים)
// - Performance: 60fps - אין השפעה על ביצועים

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

class AuthButton extends StatefulWidget {
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
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton> {
  /// האם הכפתור לחוץ (לanimation)
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    // בדיקה אם הכפתור enabled
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    // תוכן הכפתור (טקסט + אייקון אופציונלי)
    final content = widget.isLoading
        ? Semantics(
            label: 'טוען, אנא המתן',
            child: SizedBox(
              width: kIconSize,
              height: kIconSize,
              child: CircularProgressIndicator(
                strokeWidth: kBorderWidthFocused,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.type == AuthButtonType.primary ? Colors.black : accent,
                ),
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: widget.type == AuthButtonType.primary
                      ? Colors.black
                      : accent,
                  size: kIconSizeMedium,
                ),
                const SizedBox(width: kSpacingSmall),
              ],
              Text(widget.label, style: TextStyle(fontSize: widget.fontSize)),
            ],
          );

    // 🎬 Animation Wrapper
    final animatedContent = GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: _buildButton(context, accent, content, isEnabled),
      ),
    );

    return animatedContent;
  }

  /// בניית הכפתור לפי הסוג
  Widget _buildButton(
    BuildContext context,
    Color accent,
    Widget content,
    bool isEnabled,
  ) {
    if (widget.type == AuthButtonType.primary) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: null, // ה-GestureDetector מטפל בלחיצה
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled ? accent : Colors.grey,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: kSpacingMedium),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            minimumSize: const Size(double.infinity, kButtonHeight),
            disabledBackgroundColor: Colors.grey,
            disabledForegroundColor: Colors.black54,
          ),
          child: content,
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: null, // ה-GestureDetector מטפל בלחיצה
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isEnabled ? accent : Colors.grey,
              width: kBorderWidthFocused,
            ),
            foregroundColor: isEnabled ? accent : Colors.grey,
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
