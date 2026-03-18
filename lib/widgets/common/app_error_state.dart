// 📄 lib/widgets/common/app_error_state.dart
//
// 🎯 Error state אחיד לכל המסכים
// ✅ Icon + title (optional) + message + action button
// ✅ Consistent styling — single source of truth

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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: cs.error.withValues(alpha: 0.7)),
            const SizedBox(height: kSpacingMedium),
            if (title != null) ...[
              Text(
                title!,
                textAlign: TextAlign.center,
                style: tt.titleMedium?.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: kSpacingSmall),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: kSpacingLarge),
            FilledButton.icon(
              onPressed: onAction,
              icon: Icon(actionIcon),
              label: Text(actionLabel ?? AppStrings.common.retry),
            ),
          ],
        ),
      ),
    );
  }
}
