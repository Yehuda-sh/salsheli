// lib/widgets/common/app_error_state.dart — Error state — full-screen error with icon, message, retry button

import 'package:flutter/material.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';

/// 🚨 Error state widget — consistent across all screens
class AppErrorState extends StatelessWidget {
  /// Error message to display
  final String message;

  /// Action button callback (retry, go back, etc.)
  final VoidCallback onAction;

  /// Optional title above the message
  final String? title;

  /// Custom icon (default: error_outline)
  final IconData icon;

  /// Action button label (default: AppStrings.common.retry)
  final String? actionLabel;

  /// Action button icon (default: refresh)
  final IconData actionIcon;

  const AppErrorState({
    super.key,
    required this.message,
    required this.onAction,
    this.title,
    this.icon = Icons.error_outline,
    this.actionLabel,
    this.actionIcon = Icons.refresh,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Semantics(
      // Announce the error automatically when this state appears, so a
      // screen-reader user doesn't keep hearing the previous "loading"
      // label while the screen has actually flipped to an error.
      liveRegion: true,
      // explicitChildNodes keeps the retry FilledButton as its own
      // accessibility node ("button: Retry"), while the inner icon +
      // text — which already feed into our `label` below — get
      // collapsed into this single live region instead of being read
      // a second time as standalone nodes.
      explicitChildNodes: true,
      label: title == null ? message : '$title, $message',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(kSpacingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: Icon(
                  icon,
                  size: kIconSizeXXLarge,
                  color: cs.error.withValues(alpha: kOpacityStrong),
                ),
              ),
              const SizedBox(height: kSpacingMedium),
              if (title != null) ...[
                ExcludeSemantics(
                  child: Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: tt.titleMedium?.copyWith(color: cs.onSurface),
                  ),
                ),
                const SizedBox(height: kSpacingSmall),
              ],
              ExcludeSemantics(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: kSpacingLarge),
              FilledButton.icon(
                onPressed: onAction,
                icon: Icon(actionIcon),
                label: Text(actionLabel ?? AppStrings.common.retry),
                // Force the app's primary seed color so the button stays
                // green even when Material You / dynamic colors shift the
                // system primary to blue.
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
