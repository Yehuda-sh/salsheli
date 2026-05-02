// lib/widgets/common/edit_household_name_dialog.dart — Edit household name dialog — shared helper for renaming the household

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/error_utils.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../providers/user_context.dart';
import 'app_dialog.dart';

// Firestore field size budget + UI readability — 40 fits one line on most phones.
const int _kMaxHouseholdNameLength = 40;

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
          Future<void> trySave() async {
            final trimmed = controller.text.trim();
            if (trimmed.isEmpty) {
              setDialogState(() {
                errorText = AppStrings.settings.householdNameEmpty;
              });
              return;
            }
            setDialogState(() => isSaving = true);
            try {
              await userContext.updateHouseholdName(trimmed);
              saved = true;
              unawaited(HapticFeedback.lightImpact());
              if (ctx.mounted) Navigator.pop(ctx);
            } catch (e) {
              if (!ctx.mounted) return;
              setDialogState(() {
                isSaving = false;
                errorText =
                    userFriendlyError(e, context: 'householdName');
              });
            }
          }

          final theme = Theme.of(ctx);
          return AlertDialog(
            title: Text(AppStrings.settings.householdName),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.settings.householdNameDialogSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: kSpacingSmall),
                TextField(
                  controller: controller,
                  maxLength: _kMaxHouseholdNameLength,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: isSaving ? null : (_) => trySave(),
                  decoration: InputDecoration(
                    hintText: AppStrings.settings.householdNameHint,
                    border: const OutlineInputBorder(),
                    errorText: errorText,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppStrings.common.cancel),
              ),
              FilledButton(
                onPressed: isSaving ? null : trySave,
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
