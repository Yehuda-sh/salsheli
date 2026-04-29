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
import 'app_dialog.dart';
import 'edit_household_name_dialog.dart';

/// Opens the "Invite someone to your household" dialog.
///
/// Requires the user to be signed in with a household. If the household
/// doesn't have a name set yet (legacy accounts), prompts to set one
/// first instead of dead-ending on a "go to Settings" SnackBar.
Future<void> showHouseholdInviteDialog(BuildContext context) async {
  final userContext = context.read<UserContext>();

  if (userContext.userId == null || userContext.householdId == null) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(AppStrings.settings.inviteError(''))),
      );
    return;
  }

  // Legacy fallback — new registrations always land on a "MemoZap-XXXX"
  // default name, but pre-fix accounts can still hit this. Instead of a
  // "go to Settings" dead-end, route them straight through the rename
  // dialog and continue inviting once they save a name.
  if (userContext.householdName == null ||
      userContext.householdName!.trim().isEmpty) {
    final saved = await showEditHouseholdNameDialog(context, userContext);
    if (!saved || !context.mounted) return;
  }

  final emailController = TextEditingController();
  bool isSending = false;
  bool isSuccess = false;
  String? errorText;
  String? successText;

  try {
    await AppDialog.show<void>(
      context: context,
      child: StatefulBuilder(
        builder: (ctx, setDialogState) {
          final brand = Theme.of(ctx).extension<AppBrand>();
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
                      color: brand?.success ?? kStickyGreen,
                      fontSize: kFontSizeSmall,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                // Once an invite has gone through, the user is "done", not
                // "cancelling" — relabel the exit button to match.
                child: Text(isSuccess
                    ? AppStrings.settings.inviteToHouseholdDone
                    : AppStrings.common.cancel),
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
                onPressed: isSending
                    ? null
                    : () async {
                        final email = emailController.text.trim();
                        if (email.isEmpty || !email.contains('@')) {
                          setDialogState(
                              () => errorText = AppStrings.settings.invalidEmail);
                          return;
                        }
                        // Block self-invite client-side instead of letting
                        // the server return a generic error — the user
                        // typed their own address, that's a clear mistake
                        // we can name.
                        final ownEmail = userContext.userEmail?.toLowerCase();
                        if (ownEmail != null && email.toLowerCase() == ownEmail) {
                          setDialogState(() => errorText =
                              AppStrings.settings.inviteToHouseholdSelf);
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

                        // If the user dismissed the dialog while we were
                        // looking up their target, don't fire the invite
                        // anyway — they explicitly bailed.
                        if (!ctx.mounted) return;

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
                            isSuccess = true;
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
  } finally {
    emailController.dispose();
  }
}
