// File: lib/screens/groups/pending_group_invites_screen.dart
// Purpose: מסך הזמנות ממתינות לקבוצות
//
// Features:
// - תצוגת הזמנות ממתינות לקבוצות
// - אישור הזמנה (הצטרפות לקבוצה)
// - דחיית הזמנה
// - תג badge במסך הבית
//
// Version: 1.1 - Improved Design
// Created: 16/12/2025

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../models/group_invite.dart';
import '../../providers/groups_provider.dart';
import '../../providers/pending_invites_provider.dart';
import '../../providers/user_context.dart';
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
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.group_remove, color: Colors.red.shade400),
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
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
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
      final success = await provider.rejectInvite(invite);

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
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
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
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
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
                              color: Colors.grey.shade600,
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
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mail_outline_rounded,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'אין הזמנות ממתינות',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'כאשר מישהו יזמין אותך לקבוצה,\nההזמנה תופיע כאן',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header עם שם הקבוצה
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade400,
                  Colors.blue.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // אייקון קבוצה
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('👥', style: TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 16),
                // פרטי הקבוצה
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invite.groupName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${invite.role.emoji} ${invite.role.hebrewName}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // פרטי ההזמנה
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // מזמין
                _DetailRow(
                  icon: Icons.person_outline,
                  label: 'הוזמנת על ידי',
                  value: invite.invitedByName,
                ),
                const SizedBox(height: 12),
                // זמן
                _DetailRow(
                  icon: Icons.schedule,
                  label: 'נשלח',
                  value: invite.timeAgoText,
                ),

                const SizedBox(height: 20),

                // כפתורי פעולה
                Row(
                  children: [
                    // דחה
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isProcessing ? null : onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade600,
                          side: BorderSide(color: Colors.red.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'לא תודה',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // אשר
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: isProcessing ? null : onAccept,
                        icon: const Icon(Icons.check_rounded, size: 20),
                        label: const Text(
                          'הצטרף לקבוצה',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// שורת פרט
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
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
