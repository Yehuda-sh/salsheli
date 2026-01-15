// 📄 lib/screens/home/dashboard/widgets/pending_invite_banner.dart
//
// באנר "הזמנה ממתינה" - מוצג כשיש הזמנה לקבוצה שממתינה לאישור.
// מאפשר לקבל או לדחות את ההזמנה ישירות מהדשבורד.
//
// Version: 1.0 (08/01/2026)
// 🔗 Related: PendingInvitesProvider, GroupInvite

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/ui_constants.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../providers/groups_provider.dart';
import '../../../../providers/pending_invites_provider.dart';
import '../../../../providers/user_context.dart';
import '../../../../theme/app_theme.dart';

/// באנר הזמנה ממתינה - מציג הזמנה ראשונה עם אפשרות קבלה/דחייה
class PendingInviteBanner extends StatefulWidget {
  const PendingInviteBanner({super.key});

  @override
  State<PendingInviteBanner> createState() => _PendingInviteBannerState();
}

class _PendingInviteBannerState extends State<PendingInviteBanner> {
  bool _isProcessing = false;

  Future<void> _onAccept(BuildContext context) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    // ✅ FIX: Cache values before async gap
    final strings = AppStrings.pendingInviteBanner;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final successColor = theme.extension<AppBrand>()?.success ?? kStickyGreen;
    final messenger = ScaffoldMessenger.of(context);
    final invitesProvider = context.read<PendingInvitesProvider>();
    final groupsProvider = context.read<GroupsProvider>();
    final userContext = context.read<UserContext>();

    try {
      final invite = invitesProvider.pendingInvites.first;
      final user = userContext.user;

      if (user == null) {
        throw Exception(strings.notLoggedIn);
      }

      // ✅ FIX: Normalize email - empty string stays empty (provider handles it)
      final userEmail = user.email.trim().isNotEmpty ? user.email : '';

      // ✅ FIX: Check return value
      final success = await invitesProvider.acceptInvite(
        invite: invite,
        userId: user.id,
        userName: user.name,
        userEmail: userEmail,
      );

      if (!mounted) return;

      if (success) {
        // ✅ FIX: unawaited for fire-and-forget
        unawaited(HapticFeedback.mediumImpact());
        messenger.showSnackBar(
          SnackBar(
            content: Text(strings.acceptSuccess(invite.groupName)),
            // ✅ FIX: Theme-aware color
            backgroundColor: successColor,
          ),
        );
        // ✅ FIX: Refresh groups after accept
        unawaited(groupsProvider.loadGroups());
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(strings.acceptError),
            backgroundColor: cs.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      // ✅ FIX: User-friendly error message
      messenger.showSnackBar(
        SnackBar(
          content: Text(strings.acceptError),
          backgroundColor: cs.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _onReject(BuildContext context) async {
    if (_isProcessing) return;

    // ✅ FIX: Cache values before async gap
    final strings = AppStrings.pendingInviteBanner;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accentColor = theme.extension<AppBrand>()?.accent ?? cs.tertiary;
    final invitesProvider = context.read<PendingInvitesProvider>();
    final invite = invitesProvider.pendingInvites.first;

    // אישור לפני דחייה
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.rejectDialogTitle),
        content: Text(strings.rejectDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(strings.cancelButton),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            // ✅ FIX: Theme-aware error color
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            child: Text(strings.rejectButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);

    final messenger = ScaffoldMessenger.of(context);

    try {
      await invitesProvider.rejectInvite(invite);

      if (!mounted) return;

      // ✅ FIX: unawaited for fire-and-forget
      unawaited(HapticFeedback.lightImpact());
      messenger.showSnackBar(
        SnackBar(
          content: Text(strings.rejectSuccess),
          // ✅ FIX: Theme-aware color
          backgroundColor: accentColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // ✅ FIX: User-friendly error message
      messenger.showSnackBar(
        SnackBar(
          content: Text(strings.rejectError),
          backgroundColor: cs.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final strings = AppStrings.pendingInviteBanner;
    final invitesProvider = context.watch<PendingInvitesProvider>();

    // ✅ FIX: Theme-aware colors
    final accentColor = theme.extension<AppBrand>()?.accent ?? cs.primary;
    final successColor = theme.extension<AppBrand>()?.success ?? kStickyGreen;

    // אם אין הזמנות - לא מציג
    if (!invitesProvider.hasPendingInvites) {
      return const SizedBox.shrink();
    }

    final invite = invitesProvider.pendingInvites.first;
    final moreCount = invitesProvider.pendingCount - 1;

    return Container(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      decoration: BoxDecoration(
        // ✅ FIX: Theme-aware colors
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Row(
          children: [
            // אייקון
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                // ✅ FIX: Theme-aware color
                color: accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.mail_outline,
                // ✅ FIX: Theme-aware color
                color: accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: kSpacingMedium),

            // טקסט
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        strings.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          // ✅ FIX: Theme-aware color
                          color: cs.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (moreCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            // ✅ FIX: Theme-aware color
                            color: accentColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            strings.moreCount(moreCount),
                            style: theme.textTheme.labelSmall?.copyWith(
                              // ✅ FIX: Theme-aware color
                              color: cs.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    strings.inviteMessage(invite.invitedByName, invite.groupName),
                    style: theme.textTheme.bodySmall?.copyWith(
                      // ✅ FIX: Theme-aware color
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // כפתורי פעולה
            if (_isProcessing)
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  // ✅ FIX: Theme-aware color
                  color: accentColor,
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // כפתור קבל
                  ElevatedButton(
                    onPressed: () => _onAccept(context),
                    style: ElevatedButton.styleFrom(
                      // ✅ FIX: Theme-aware colors
                      backgroundColor: successColor,
                      foregroundColor: cs.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text(strings.acceptButton),
                  ),
                  const SizedBox(width: 8),
                  // כפתור דחה
                  IconButton(
                    onPressed: () => _onReject(context),
                    icon: const Icon(Icons.close),
                    // ✅ FIX: Theme-aware color
                    color: cs.onSurfaceVariant,
                    tooltip: strings.rejectTooltip,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
