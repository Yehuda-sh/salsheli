// File: lib/screens/groups/pending_group_invites_screen.dart
// Purpose: מסך הזמנות ממתינות לקבוצות
//
// Features:
// - תצוגת הזמנות ממתינות לקבוצות
// - אישור הזמנה (הצטרפות לקבוצה)
// - דחיית הזמנה
// - תג badge במסך הבית
//
// Version: 1.0
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
import '../../widgets/common/sticky_note.dart';

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
            content: Text('הצטרפת לקבוצה "${invite.groupName}" בהצלחה!'),
            backgroundColor: Colors.green,
          ),
        );

        // רענן את רשימת הקבוצות
        unawaited(context.read<GroupsProvider>().loadGroups());
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('שגיאה באישור ההזמנה'),
            backgroundColor: Colors.red,
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
        title: const Text('דחיית הזמנה'),
        content: Text('לדחות את ההזמנה לקבוצה "${invite.groupName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ביטול'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('דחה'),
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
          const SnackBar(
            content: Text('ההזמנה נדחתה'),
            backgroundColor: Colors.orange,
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
        ),
        body: Stack(
          children: [
            const NotebookBackground(),
            SafeArea(
              child: Consumer<PendingInvitesProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading || _isProcessing) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: kSpacingMedium),
                          Text('טוען הזמנות...'),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_add_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: kSpacingMedium),
          Text(
            'אין הזמנות ממתינות',
            style: TextStyle(
              fontSize: kFontSizeLarge,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            'כאשר מישהו יזמין אותך לקבוצה,\nההזמנה תופיע כאן',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: kSpacingLarge),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('חזור'),
          ),
        ],
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
          return _buildInviteCard(invite);
        },
      ),
    );
  }

  Widget _buildInviteCard(GroupInvite invite) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kSpacingMedium),
      child: StickyNote(
        color: kStickyYellow,
        rotation: 0.01,
        child: Padding(
          padding: const EdgeInsets.all(kSpacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // כותרת
              Row(
                children: [
                  const Text('👥', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: kSpacingSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invite.groupName,
                          style: const TextStyle(
                            fontSize: kFontSizeLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'הזמנה לקבוצה',
                          style: TextStyle(
                            fontSize: kFontSizeSmall,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: kSpacingMedium),

              // פרטי ההזמנה
              _buildInfoRow(
                Icons.person,
                'מזמין:',
                invite.invitedByName,
              ),

              const SizedBox(height: kSpacingTiny),

              _buildInfoRow(
                Icons.badge,
                'תפקיד:',
                '${invite.role.emoji} ${invite.role.hebrewName}',
              ),

              const SizedBox(height: kSpacingTiny),

              _buildInfoRow(
                Icons.access_time,
                'נשלח:',
                invite.timeAgoText,
              ),

              const SizedBox(height: kSpacingMedium),
              const Divider(),
              const SizedBox(height: kSpacingSmall),

              // כפתורי פעולה
              Row(
                children: [
                  // דחה
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _isProcessing ? null : () => _rejectInvite(invite),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('דחה'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),

                  const SizedBox(width: kSpacingSmall),

                  // אשר
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed:
                          _isProcessing ? null : () => _acceptInvite(invite),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('הצטרף לקבוצה'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kStickyGreen,
                        foregroundColor: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: kSpacingSmall),
        Text(
          label,
          style: TextStyle(
            fontSize: kFontSizeSmall,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: kSpacingTiny),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: kFontSizeSmall,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
