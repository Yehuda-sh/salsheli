// 📄 lib/screens/home/dashboard/widgets/pending_invite_banner.dart
//
// באנר "הזמנה ממתינה" - מוצג כשיש הזמנה לקבוצה שממתינה לאישור.
// מאפשר לקבל או לדחות את ההזמנה ישירות מהדשבורד.
//
// Version: 1.0 (08/01/2026)
// 🔗 Related: PendingInvitesProvider, GroupInvite

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/ui_constants.dart';
import '../../../../providers/pending_invites_provider.dart';
import '../../../../providers/user_context.dart';

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

    final messenger = ScaffoldMessenger.of(context);
    final invitesProvider = context.read<PendingInvitesProvider>();
    final userContext = context.read<UserContext>();

    try {
      final invite = invitesProvider.pendingInvites.first;
      final user = userContext.user;

      if (user == null) {
        throw Exception('לא מחובר');
      }

      await invitesProvider.acceptInvite(
        invite: invite,
        userId: user.id,
        userName: user.name,
        userEmail: user.email,
      );

      if (!mounted) return;

      await HapticFeedback.mediumImpact();
      messenger.showSnackBar(
        SnackBar(
          content: Text('הצטרפת לקבוצה "${invite.groupName}"'),
          backgroundColor: kStickyGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('שגיאה: $e'),
          backgroundColor: kStickyPink,
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

    final invitesProvider = context.read<PendingInvitesProvider>();
    final invite = invitesProvider.pendingInvites.first;

    // אישור לפני דחייה
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('דחיית הזמנה'),
        content: const Text('האם אתה בטוח שברצונך לדחות את ההזמנה?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: kStickyPink),
            child: const Text('דחה'),
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

      await HapticFeedback.lightImpact();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('ההזמנה נדחתה'),
          backgroundColor: kStickyCyan,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('שגיאה: $e'),
          backgroundColor: kStickyPink,
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
    final invitesProvider = context.watch<PendingInvitesProvider>();

    // אם אין הזמנות - לא מציג
    if (!invitesProvider.hasPendingInvites) {
      return const SizedBox.shrink();
    }

    final invite = invitesProvider.pendingInvites.first;
    final moreCount = invitesProvider.pendingCount - 1;

    return Container(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade200,
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
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.mail_outline,
                color: Colors.blue.shade700,
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
                        'הזמנה לקבוצה',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.blue.shade900,
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
                            color: Colors.blue.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '+$moreCount',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${invite.invitedByName} הזמין אותך ל"${invite.groupName}"',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // כפתורי פעולה
            if (_isProcessing)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // כפתור קבל
                  ElevatedButton(
                    onPressed: () => _onAccept(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kStickyGreen,
                      foregroundColor: Colors.white,
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
                    child: const Text('קבל'),
                  ),
                  const SizedBox(width: 8),
                  // כפתור דחה
                  IconButton(
                    onPressed: () => _onReject(context),
                    icon: const Icon(Icons.close),
                    color: Colors.blue.shade400,
                    tooltip: 'דחה',
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
