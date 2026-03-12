// 📄 lib/widgets/common/app_error_state.dart
//
// 🎯 Error state אחיד — Template מבוסס Settings Screen
// ✅ Icon + message + retry button
// ✅ Consistent styling across all screens

import 'package:flutter/material.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';

/// 🚨 Error state widget — מבוסס Settings Screen template
class AppErrorState extends StatelessWidget {
  /// Error message to display
  final String message;

  /// Retry callback
  final VoidCallback onRetry;

  /// Custom icon (default: error_outline)
  final IconData icon;

  /// Custom retry label
  final String? retryLabel;

  const AppErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.icon = Icons.error_outline,
    this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: cs.error),
            const SizedBox(height: kSpacingMedium),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.error, fontSize: kFontSizeBody),
            ),
            const SizedBox(height: kSpacingMedium),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryLabel ?? AppStrings.common.retry),
            ),
          ],
        ),
      ),
    );
  }
}
