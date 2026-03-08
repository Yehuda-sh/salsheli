import 'package:flutter/material.dart';
import 'package:memozap/core/ui_constants.dart';

/// 🍫 SnackBar אחיד לכל האפליקציה
///
/// שימוש:
/// ```dart
/// AppSnackBar.show(context, 'הודעה');
/// AppSnackBar.success(context, 'נשמר בהצלחה');
/// AppSnackBar.error(context, 'שגיאה');
/// ```
class AppSnackBar {
  AppSnackBar._();

  /// הודעה רגילה
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _show(context, message, duration: duration, action: action);
  }

  /// הודעת הצלחה (ירוק)
  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    final cs = Theme.of(context).colorScheme;
    _show(
      context,
      message,
      backgroundColor: cs.primary,
      textColor: cs.onPrimary,
      duration: duration,
    );
  }

  /// הודעת שגיאה (אדום)
  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    final cs = Theme.of(context).colorScheme;
    _show(
      context,
      message,
      backgroundColor: cs.error,
      textColor: cs.onError,
      duration: duration,
    );
  }

  /// הודעת אזהרה (כתום)
  static void warning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    final cs = Theme.of(context).colorScheme;
    _show(
      context,
      message,
      backgroundColor: cs.tertiary,
      textColor: cs.onTertiary,
      duration: duration,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: textColor != null ? TextStyle(color: textColor) : null,
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
          duration: duration,
          action: action,
        ),
      );
  }
}
