// lib/widgets/common/edit_household_name_dialog.dart — Edit household name dialog — shared helper for renaming the household

import 'package:flutter/material.dart';

import '../../core/error_utils.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../providers/user_context.dart';
import 'app_dialog.dart';

/// Opens the "Edit household name" dialog. Returns true if the name was
/// saved successfully, false if the user cancelled or save failed.
Future<bool> showEditHouseholdNameDialog(
  BuildContext context,
  UserContext userContext,
) async {
  final controller =
      TextEditingController(text: userContext.householdName ?? '');
  bool isSaving = false;
  String? errorText;
  bool saved = false;

  try {
    await AppDialog.show<void>(
      context: context,
      child: StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(AppStrings.settings.householdName),
            content: TextField(
              controller: controller,
              maxLength: 40,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              autofocus: true,
              decoration: InputDecoration(
                hintText: AppStrings.settings.householdNameHint,
                border: const OutlineInputBorder(),
                errorText: errorText,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppStrings.common.cancel),
              ),
              FilledButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        final trimmed = controller.text.trim();
                        if (trimmed.isEmpty) {
                          setDialogState(() {
                            errorText =
                                AppStrings.settings.householdNameEmpty;
                          });
                          return;
                        }
                        setDialogState(() => isSaving = true);
                        try {
                          await userContext.updateHouseholdName(trimmed);
                          saved = true;
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          if (!ctx.mounted) return;
                          setDialogState(() {
                            isSaving = false;
                            errorText =
                                userFriendlyError(e, context: 'householdName');
                          });
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: kIconSizeSmall,
                        height: kIconSizeSmall,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(AppStrings.common.save),
              ),
            ],
          );
        },
      ),
    );
  } finally {
    controller.dispose();
  }

  return saved;
}
