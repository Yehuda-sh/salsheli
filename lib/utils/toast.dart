// lib/utils/toast.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart'; // לצבע accent אם קיים (AppBrand)

/// מציג SnackBar כ"טוסט" עם התאמה ל-Theme.
/// שים לב: נסתיר טוסט קיים לפני שנציג חדש כדי למנוע הצטברות.
void showToast(
  BuildContext context,
  String message, {
  IconData? icon,
  Duration duration = const Duration(seconds: 2),
  SnackBarAction? action,
  Color? backgroundColor, // אם לא סופק – יחושב מה-Theme
  Color? foregroundColor, // אם לא סופק – יחושב מה-Theme
}) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;
  final brand = theme.extension<AppBrand>();

  final bg =
      backgroundColor ??
      (theme.brightness == Brightness.dark
          ? cs.inverseSurface
          : cs.surfaceContainerHighest);
  final fg =
      foregroundColor ??
      (theme.brightness == Brightness.dark
          ? cs.onInverseSurface
          : cs.onSurface);

  final content = Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (icon != null) ...[
        Icon(icon, color: fg, size: 20),
        const SizedBox(width: 8),
      ],
      Flexible(
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(color: fg),
        ),
      ),
    ],
  );

  final snackBar = SnackBar(
    content: content,
    backgroundColor: bg,
    behavior: SnackBarBehavior.floating,
    duration: duration,
    action: action,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(snackBar);
}

/// טוסט הצלחה (ירוק/Accent)
void showSuccessToast(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
}) {
  final cs = Theme.of(context).colorScheme;
  final brand = Theme.of(context).extension<AppBrand>();
  showToast(
    context,
    message,
    icon: Icons.check_circle_rounded,
    duration: duration,
    backgroundColor: cs.tertiaryContainer.withValues(alpha: 0.85),
    foregroundColor: cs.onTertiaryContainer,
    action: SnackBarAction(
      label: 'סגור',
      textColor: brand?.accent ?? cs.primary,
      onPressed: () {},
    ),
  );
}

/// טוסט שגיאה (אדום)
void showErrorToast(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  final cs = Theme.of(context).colorScheme;
  showToast(
    context,
    message,
    icon: Icons.error_outline_rounded,
    duration: duration,
    backgroundColor: cs.errorContainer.withValues(alpha: 0.95),
    foregroundColor: cs.onErrorContainer,
  );
}

/// טוסט אינפורמטיבי (כחול/משני)
void showInfoToast(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
}) {
  final cs = Theme.of(context).colorScheme;
  final brand = Theme.of(context).extension<AppBrand>();
  showToast(
    context,
    message,
    icon: Icons.info_outline_rounded,
    duration: duration,
    backgroundColor: cs.surfaceContainerHigh.withValues(alpha: 0.95),
    foregroundColor: cs.onSurface,
    action: SnackBarAction(
      label: 'הבנתי',
      textColor: brand?.accent ?? cs.primary,
      onPressed: () {},
    ),
  );
}
