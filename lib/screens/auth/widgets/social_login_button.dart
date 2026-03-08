import 'package:flutter/material.dart';
import 'package:salsheli/core/ui_constants.dart';

class SocialLoginButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  @override
  State<SocialLoginButton> createState() => SocialLoginButtonState();
}

class SocialLoginButtonState extends State<SocialLoginButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDisabled = widget.onPressed == null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ צל מותאם ל-Dark Mode
    final shadowColor = isDark
        ? cs.surfaceContainerLowest.withValues(alpha: 0.1)
        : cs.shadow.withValues(alpha: 0.15);

    return Semantics(
      button: true,
      label: AppStrings.auth.socialLoginSemanticLabel(widget.label),
      enabled: !isDisabled,
      child: GestureDetector(
        onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
        onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
        onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: Container(
            decoration: BoxDecoration(
              color: isDisabled
                  ? cs.surfaceContainerHighest.withValues(alpha: 0.5)
                  : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(kBorderRadius),
              boxShadow: isDisabled
                  ? null
                  : [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: BorderRadius.circular(kBorderRadius),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: kSpacingSmall + 4,
                    horizontal: kSpacingMedium,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        widget.icon,
                        size: 18,
                        color: isDisabled
                            ? widget.color.withValues(alpha: 0.5)
                            : widget.color,
                      ),
                      SizedBox(width: kSpacingSmall),
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: isDisabled
                              ? cs.onSurface.withValues(alpha: 0.5)
                              : cs.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: kFontSizeMedium,
                        ),
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
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🌫️ Loading Overlay with Cycling Text
// ═══════════════════════════════════════════════════════════════════════════

/// ✅ v4.0: Loading overlay עם טקסט משתנה ליצירת תחושת מהירות
