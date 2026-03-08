import 'package:flutter/material.dart';
import 'package:salsheli/core/ui_constants.dart';

/// 🗨️ דיאלוג אדפטיבי — Material ב-Android, Cupertino ב-iOS
///
/// שימוש:
/// ```dart
/// final confirmed = await AppDialog.confirm(
///   context,
///   title: 'מחיקה',
///   message: 'למחוק את הרשימה?',
///   confirmLabel: 'מחק',
///   isDestructive: true,
/// );
/// ```
class AppDialog {
  AppDialog._();

  /// דיאלוג אישור (כן/לא)
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    String? message,
    String confirmLabel = 'אישור',
    String cancelLabel = 'ביטול',
    bool isDestructive = false,
  }) async {
    final cs = Theme.of(context).colorScheme;

    final result = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(title),
        content: message != null ? Text(message) : null,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDestructive
                ? TextButton.styleFrom(foregroundColor: cs.error)
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// דיאלוג מידע (OK בלבד)
  static Future<void> info(
    BuildContext context, {
    required String title,
    String? message,
    Widget? content,
    String okLabel = 'הבנתי',
  }) async {
    await showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(title),
        content: content ?? (message != null ? Text(message) : null),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(okLabel),
          ),
        ],
      ),
    );
  }

  /// דיאלוג עם בחירה מרובה
  static Future<T?> choose<T>(
    BuildContext context, {
    required String title,
    required List<DialogOption<T>> options,
    String? cancelLabel,
  }) async {
    return showAdaptiveDialog<T>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((opt) => ListTile(
              leading: opt.icon != null ? Icon(opt.icon) : null,
              title: Text(opt.label),
              subtitle: opt.subtitle != null ? Text(opt.subtitle!) : null,
              onTap: () => Navigator.pop(context, opt.value),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kBorderRadiusSmall),
              ),
            )).toList(),
          ),
        ),
        actions: cancelLabel != null
            ? [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(cancelLabel),
                ),
              ]
            : null,
      ),
    );
  }
}

/// אופציה לדיאלוג choose
class DialogOption<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;

  const DialogOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });
}
