// 📄 lib/widgets/dialogs/pantry_merge_dialog.dart
//
// דיאלוג שנשאל כשמשתמש מצטרף לבית חדש ויש לו מזווה אישי.
// מאפשר למזג את המזווה האישי למזווה הבית.

import 'package:flutter/material.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';

/// מציג דיאלוג מיזוג מזווה ומחזיר `true` אם המשתמש בחר למזג
Future<bool> showPantryMergeDialog({
  required BuildContext context,
  required int personalItemCount,
}) async {
  final cs = Theme.of(context).colorScheme;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      icon: const Text('📦', style: TextStyle(fontSize: kFontSizeDisplay)),
      title: const Text('יש לך מזווה אישי!'),
      content: Text(
        'יש לך $personalItemCount מוצרים במזווה האישי.\n\n'
        'תרצה להעביר אותם למזווה של הבית החדש?',
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(AppStrings.common.cancel),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(ctx, true),
          icon: const Icon(Icons.merge_type),
          label: const Text('העבר למזווה הבית'),
          style: FilledButton.styleFrom(
            backgroundColor: cs.primary,
          ),
        ),
      ],
    ),
  );

  return result ?? false;
}
