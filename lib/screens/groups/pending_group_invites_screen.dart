// 📄 lib/screens/groups/pending_group_invites_screen.dart
//
// מסך הזמנות ממתינות לקבוצות - אישור או דחיית הזמנות.
// כולל pull-to-refresh ועיצוב כרטיסים מודרני.
//
// 🔗 Related: GroupInvite, PendingInvitesProvider, GroupsProvider

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../models/group_invite.dart';
import '../../providers/groups_provider.dart';
import '../../providers/pending_invites_provider.dart';
import '../../providers/user_context.dart';
import '../../services/notifications_service.dart';
import '../../widgets/common/notebook_background.dart';

class PendingGroupInvitesScreen extends StatefulWidget {
  const PendingGroupInvitesScreen({super.key});

  @override
  State<PendingGroupInvitesScreen> createState() =>
      _PendingGroupInvitesScreenState();
}

class _PendingGroupInvitesScreenState extends State<PendingGroupInvitesScreen> {
  bool _isProcessing = false;

  /// אישור הזמנה
  Future<void> _acceptInvite(GroupInvite invite) async {
    final userContext = context.read<UserContext>();
    final userId = userContext.userId;
    final userName = userContext.displayName ?? 'משתמש';
    final userEmail = userContext.userEmail ?? '';

    if (userId == null) return;

    setState(() => _isProcessing = true);

    try {
      final provider = context.read<PendingInvitesProvider>();
      final success = await provider.acceptInvite(
        invite: invite,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
      );

      if (!mounted) return;

      if (success) {
        unawaited(HapticFeedback.mediumImpact());
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('הצטרפת לקבוצה "${invite.groupName}" בהצלחה!'),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // רענן את רשימת הקבוצות
        unawaited(context.read<GroupsProvider>().loadGroups());
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('שגיאה באישור ההזמנה'),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// דחיית הזמנה
  Future<void> _rejectInvite(GroupInvite invite) async {
    final cs = Theme.of(context).colorScheme;

    // שאלת אישור
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.group_remove, color: cs.onErrorContainer),
            ),
            const SizedBox(width: 12),
            const Text('דחיית הזמנה'),
          ],
        ),
        content: Text(
          'האם לדחות את ההזמנה לקבוצה "${invite.groupName}"?\n\nלא תוכל להצטרף אלא אם יזמינו אותך שוב.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            child: const Text('דחה הזמנה'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);

    try {
      final provider = context.read<PendingInvitesProvider>();
      final userContext = context.read<UserContext>();

      // 🛡️ NotificationsService might not be available - make it defensive
      NotificationsService? notificationsService;
      try {
        notificationsService = context.read<NotificationsService>();
      } catch (e) {
        // Non-critical - rejection will still work, just without notification
        debugPrint('⚠️ NotificationsService not available for rejection notification');
      }

      // 🆕 שולח התראה למזמין שההזמנה נדחתה
      final success = await provider.rejectInvite(
        invite,
        rejectorName: userContext.displayName ?? 'משתמש',
        senderId: userContext.userId, // 🔒 נדרש ל-Firestore rules
        notificationsService: notificationsService,
        householdId: userContext.householdId,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('ההזמנה נדחתה'),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kPaperBackground,
        appBar: AppBar(
          title: const Text('הזמנות לקבוצות'),
          centerTitle: true,
          // ✅ Theme-aware - רך יותר, מתאים ל-Dark Mode
          backgroundColor: cs.surfaceContainerHighest,
          foregroundColor: cs.onSurface,
          elevation: 0,
        ),
        body: Stack(
          children: [
            const NotebookBackground(),
            SafeArea(
              child: Consumer<PendingInvitesProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading || _isProcessing) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: cs.surface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: cs.shadow.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: CircularProgressIndicator(
                              color: cs.primary,
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: kSpacingLarge),
                          Text(
                            _isProcessing ? 'מעבד...' : 'טוען הזמנות...',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (provider.pendingInvites.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildInvitesList(provider.pendingInvites);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // אייקון
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mail_outline_rounded,
                size: 64,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'אין הזמנות ממתינות',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'כאשר מישהו יזמין אותך לקבוצה,\nההזמנה תופיע כאן',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('חזור לדף הבית'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitesList(List<GroupInvite> invites) {
    return RefreshIndicator(
      onRefresh: () async {
        final userContext = context.read<UserContext>();
        await context.read<PendingInvitesProvider>().refresh(
              phone: userContext.user?.phone,
              email: userContext.userEmail,
            );
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(kSpacingMedium),
        itemCount: invites.length,
        itemBuilder: (context, index) {
          final invite = invites[index];
          return _InviteCard(
            invite: invite,
            isProcessing: _isProcessing,
            onAccept: () => _acceptInvite(invite),
            onReject: () => _rejectInvite(invite),
          );
        },
      ),
    );
  }
}

/// כרטיס הזמנה מעוצב
class _InviteCard extends StatelessWidget {
  final GroupInvite invite;
  final bool isProcessing;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _InviteCard({
    required this.invite,
    required this.isProcessing,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // ✅ Sticky-note style card with colored left border
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        // ✅ Border משמאל (RTL = ימין ויזואלית) בצבע primary
        border: Border(
          right: BorderSide(color: cs.primary, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header עם שם הקבוצה ותג תפקיד
            Row(
              children: [
                // אייקון קבוצה
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('👥', style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 12),
                // פרטי הקבוצה
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invite.groupName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: cs.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${invite.role.emoji} ${invite.role.hebrewName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSecondaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // פרטי ההזמנה
            _DetailRow(
              icon: Icons.person_outline,
              label: 'הוזמנת על ידי',
              value: invite.invitedByName,
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.schedule,
              label: 'נשלח',
              value: invite.timeAgoText,
            ),

            const SizedBox(height: 16),

            // כפתורי פעולה
            Row(
              children: [
                // דחה - כפתור משני
                Expanded(
                  child: OutlinedButton(
                    onPressed: isProcessing ? null : onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.error,
                      side: BorderSide(color: cs.error.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'לא תודה',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // אשר - כפתור ראשי
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: isProcessing ? null : onAccept,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text(
                      'הצטרף לקבוצה',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kStickyGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// שורת פרט - theme-aware
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: cs.onSurfaceVariant),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: cs.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
