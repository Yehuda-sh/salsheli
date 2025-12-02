// 📄 File: lib/screens/sharing/pending_invites_screen.dart
//
// 🎯 Purpose: מסך הזמנות ממתינות - לאישור או דחיית הזמנות לרשימות
//
// 📋 Features:
// - תצוגת הזמנות ממתינות
// - אישור הזמנה (הצטרפות לרשימה)
// - דחיית הזמנה
// - Real-time updates
//
// 🔗 Related:
// - pending_invites_service.dart - שירות ניהול הזמנות
// - invite_users_screen.dart - מסך שליחת הזמנות
//
// Version: 1.0
// Created: 30/11/2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../models/enums/user_role.dart';
import '../../models/pending_request.dart';
import '../../providers/user_context.dart';
import '../../services/pending_invites_service.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_note.dart';

class PendingInvitesScreen extends StatefulWidget {
  const PendingInvitesScreen({super.key});

  @override
  State<PendingInvitesScreen> createState() => _PendingInvitesScreenState();
}

class _PendingInvitesScreenState extends State<PendingInvitesScreen> {
  late final PendingInvitesService _invitesService;
  List<PendingRequest> _pendingInvites = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _invitesService = PendingInvitesService();
    _loadInvites();
  }

  Future<void> _loadInvites() async {
    final userContext = context.read<UserContext>();
    final userId = userContext.userId;

    if (userId == null) {
      setState(() {
        _isLoading = false;
        _error = 'לא מחובר';
      });
      return;
    }

    try {
      final invites = await _invitesService.getPendingInvitesForUser(userId);
      if (mounted) {
        setState(() {
          _pendingInvites = invites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'שגיאה בטעינת הזמנות';
        });
      }
    }
  }

  Future<void> _acceptInvite(PendingRequest invite) async {
    final userContext = context.read<UserContext>();
    final userId = userContext.userId;
    final userName = userContext.user?.name;

    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      await _invitesService.acceptInvite(
        inviteId: invite.id,
        acceptingUserId: userId,
        acceptingUserName: userName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('הצטרפת לרשימה "${invite.requestData['list_name']}"'),
            backgroundColor: Colors.green,
          ),
        );
        _loadInvites(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה באישור ההזמנה: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _declineInvite(PendingRequest invite) async {
    final userContext = context.read<UserContext>();
    final userId = userContext.userId;
    final userName = userContext.user?.name;

    if (userId == null) return;

    // שאלת אישור
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('דחיית הזמנה'),
        content: Text('לדחות את ההזמנה לרשימה "${invite.requestData['list_name']}"?'),
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

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await _invitesService.declineInvite(
        inviteId: invite.id,
        decliningUserId: userId,
        decliningUserName: userName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ההזמנה נדחתה'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadInvites(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בדחיית ההזמנה: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kPaperBackground,
        appBar: AppBar(
          backgroundColor: kStickyCyan,
          title: const Text('הזמנות ממתינות'),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            const NotebookBackground(),
            SafeArea(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: kStickyCyan),
            SizedBox(height: kSpacingMedium),
            Text('טוען הזמנות...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: kSpacingMedium),
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: kSpacingMedium),
            ElevatedButton(
              onPressed: _loadInvites,
              child: const Text('נסה שוב'),
            ),
          ],
        ),
      );
    }

    if (_pendingInvites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: kSpacingMedium),
            Text(
              'אין הזמנות ממתינות',
              style: TextStyle(
                fontSize: kFontSizeLarge,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: kSpacingSmall),
            Text(
              'כאשר מישהו יזמין אותך לרשימה,\nההזמנה תופיע כאן',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInvites,
      child: ListView.builder(
        padding: const EdgeInsets.all(kSpacingMedium),
        itemCount: _pendingInvites.length,
        itemBuilder: (context, index) {
          final invite = _pendingInvites[index];
          return _buildInviteCard(invite);
        },
      ),
    );
  }

  Widget _buildInviteCard(PendingRequest invite) {
    final listName = invite.requestData['list_name'] as String? ?? 'רשימה';
    final inviterName = invite.requesterName ?? 'משתמש';
    final roleName = invite.requestData['role'] as String? ?? 'editor';
    final role = UserRole.values.firstWhere(
      (r) => r.name == roleName,
      orElse: () => UserRole.editor,
    );

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
                  const Text('👥', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: kSpacingSmall),
                  Expanded(
                    child: Text(
                      'הזמנה לרשימה "$listName"',
                      style: const TextStyle(
                        fontSize: kFontSizeMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: kSpacingSmall),

              // פרטי ההזמנה
              Text(
                '$inviterName מזמין אותך להצטרף',
                style: const TextStyle(fontSize: kFontSizeSmall),
              ),

              const SizedBox(height: kSpacingTiny),

              // תפקיד
              Row(
                children: [
                  Text(
                    'תפקיד: ',
                    style: TextStyle(
                      fontSize: kFontSizeSmall,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kSpacingSmall,
                      vertical: kSpacingXTiny,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                    child: Text(
                      '${role.emoji} ${role.hebrewName}',
                      style: TextStyle(
                        fontSize: kFontSizeTiny,
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: kSpacingTiny),

              // זמן
              Text(
                invite.timeAgoText,
                style: TextStyle(
                  fontSize: kFontSizeTiny,
                  color: Colors.grey.shade500,
                ),
              ),

              const SizedBox(height: kSpacingMedium),

              // כפתורי פעולה
              Row(
                children: [
                  // דחה
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _declineInvite(invite),
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
                      onPressed: () => _acceptInvite(invite),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('הצטרף'),
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
}
