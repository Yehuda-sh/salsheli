// lib/screens/auth/widgets/social_login_button.dart — Social login button — Google/Apple branded sign-in button widget

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/ui_constants.dart';
import '../../../l10n/app_strings.dart';
import '../../../widgets/common/animated_button.dart';

/// Branded social-login button (Google / Apple).
///
/// Press feedback (scale, RepaintBoundary, mid-press disable reset,
/// kMinTapTarget enforcement) is delegated to the shared
/// [AnimatedButton]. This widget only owns the *visual* of the button
/// — branded icon, themed surface, shadow tuned for light/dark mode —
/// and the [onPressed] is wired straight through to an InkWell so the
/// Material ripple still fires alongside the scale animation.
class SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDisabled = onPressed == null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // In dark mode the standard cs.shadow disappears against the dark
    // surface — fall back to a faint highlight from surfaceContainerLowest
    // so the button still has a sense of elevation.
    final shadowColor = isDark
        ? cs.surfaceContainerLowest.withValues(alpha: 0.1)
        : cs.shadow.withValues(alpha: kOpacitySoft);

    return Semantics(
      button: true,
      label: AppStrings.auth.socialLoginSemanticLabel(label),
      enabled: !isDisabled,
      child: AnimatedButton(
        enabled: !isDisabled,
        // 0.97 matches the heavier-press preset documented in
        // animated_button.dart — keeps the social buttons feeling
        // chunky without being mushy.
        scaleTarget: 0.97,
        child: Container(
          decoration: BoxDecoration(
            color: isDisabled
                ? cs.surfaceContainerHighest.withValues(alpha: kOpacityMedium)
                : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(kBorderRadius),
            boxShadow: isDisabled
                ? null
                : [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: kSpacingTiny,
                      offset: const Offset(0, kSpacingXTiny - 1),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(kBorderRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: kSpacingSmallPlus,
                  horizontal: kSpacingMedium,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      icon,
                      size: kIconSizeSmall,
                      color: isDisabled
                          ? color.withValues(alpha: kOpacityMedium)
                          : color,
                    ),
                    const SizedBox(width: kSpacingSmall),
                    Text(
                      label,
                      style: TextStyle(
                        color: isDisabled
                            ? cs.onSurface.withValues(alpha: kOpacityMedium)
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
    );
  }
}
