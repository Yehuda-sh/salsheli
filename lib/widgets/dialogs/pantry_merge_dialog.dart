// lib/widgets/dialogs/pantry_merge_dialog.dart — Pantry merge dialog — resolve duplicate items when merging pantry data

import 'package:flutter/material.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../common/app_dialog.dart';

/// מציג דיאלוג מיזוג מזווה ומחזיר `true` אם המשתמש בחר למזג
Future<bool> showPantryMergeDialog({
  required BuildContext context,
  required int personalItemCount,
}) async {
  final cs = Theme.of(context).colorScheme;

  final result = await AppDialog.show<bool>(
    context: context,
    barrierDismissible: false,
    child: AlertDialog(
      // Was a 📦 emoji — Material icon matches the rest of the app
      // (suggestions / last_chance / pantry rows) and won't render as
      // a tofu box on older Android builds.
      icon: Icon(
        Icons.inventory_2_outlined,
        size: kIconSizeLarge,
        color: cs.primary,
      ),
      title: Text(AppStrings.inventory.pantryMergeTitle),
      content: Text(
        AppStrings.inventory.pantryMergeContent(personalItemCount),
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          // The user isn't cancelling the invite acceptance — they're
          // choosing to keep their personal pantry separate. "ביטול"
          // would imply rollback; "השאר אישי" names the actual choice.
          child: Text(AppStrings.inventory.pantryMergeKeepSeparate),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.merge_type),
          label: Text(AppStrings.inventory.pantryMergeButton),
          style: FilledButton.styleFrom(
            backgroundColor: cs.primary,
          ),
        ),
      ],
    ),
  );

  return result ?? false;
}
