// lib/widgets/common/household_invite_dialog.dart — Household invite dialog — shared helper for inviting someone to the household via email

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../providers/user_context.dart';
import '../../services/pending_invites_service.dart';
import '../../theme/app_theme.dart';

/// Opens the "Invite someone to your household" dialog.
///
/// Requires the user to be signed in with a household. If the household
/// doesn't have a name set yet, shows a SnackBar directing the user to
/// Settings instead of silently failing.
Future<void> showHouseholdInviteDialog(BuildContext context) async {
  final userContext = context.read<UserContext>();

  if (userContext.userId == null || userContext.householdId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.settings.inviteError('')),
      ),
    );
    return;
  }

  if (userContext.householdName == null ||
      userContext.householdName!.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.settings.inviteToHouseholdNeedName),
      ),
    );
    return;
  }

  final cs = Theme.of(context).colorScheme;
  final emailController = TextEditingController();
  bool isSending = false;
  String? errorText;
  String? successText;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        return AlertDialog(
          title: Text(AppStrings.settings.inviteToHouseholdTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: AppStrings.settings.inviteToHouseholdHint,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email_outlined),
                  errorText: errorText,
                ),
              ),
              if (successText != null) ...[
                const SizedBox(height: kSpacingSmall),
                Text(
                  successText!,
                  style: TextStyle(
                    color: Theme.of(ctx).extension<AppBrand>()?.stickyGreen ??
                        kStickyGreen,
                    fontSize: kFontSizeSmall,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppStrings.common.cancel),
            ),
            FilledButton.icon(
              icon: isSending
                  ? const SizedBox(
                      width: kIconSizeSmall,
                      height: kIconSizeSmall,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send, size: kIconSizeSmall),
              label: Text(AppStrings.settings.inviteToHouseholdButton),
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
              ),
              onPressed: isSending
                  ? null
                  : () async {
                      final email = emailController.text.trim();
                      if (email.isEmpty || !email.contains('@')) {
                        setDialogState(
                            () => errorText = AppStrings.settings.invalidEmail);
                        return;
                      }

                      setDialogState(() {
                        isSending = true;
                        errorText = null;
                        successText = null;
                      });

                      final service = PendingInvitesService();
                      final userId = userContext.userId!;
                      final userName = userContext.user?.name ??
                          AppStrings.settings.defaultUserName;
                      final householdId = userContext.householdId!;
                      final householdName = userContext.householdName ??
                          AppStrings.settings.defaultHouseholdName;

                      String? invitedUserId;
                      try {
                        final usersQuery = await FirebaseFirestore.instance
                            .collection('users')
                            .where('email', isEqualTo: email.toLowerCase())
                            .limit(1)
                            .get();
                        if (usersQuery.docs.isNotEmpty) {
                          invitedUserId = usersQuery.docs.first.id;
                        }
                      } catch (e) {
                        debugPrint('⚠️ Failed to lookup invited user: $e');
                      }

                      final result = await service.createHouseholdInvite(
                        inviterId: userId,
                        inviterName: userName,
                        invitedUserEmail: email,
                        invitedUserId: invitedUserId,
                        householdId: householdId,
                        householdName: householdName,
                      );

                      if (!ctx.mounted) return;

                      if (result.isSuccess) {
                        setDialogState(() {
                          isSending = false;
                          successText =
                              AppStrings.settings.inviteToHouseholdSuccess;
                          emailController.clear();
                        });
                      } else if (result.type ==
                          InviteResultType.inviteAlreadyPending) {
                        setDialogState(() {
                          isSending = false;
                          errorText = AppStrings
                              .settings.inviteToHouseholdAlreadyPending;
                        });
                      } else {
                        setDialogState(() {
                          isSending = false;
                          errorText = result.errorMessage ??
                              AppStrings.settings.inviteError('');
                        });
                      }
                    },
            ),
          ],
        );
      },
    ),
  );
  emailController.dispose();
}
