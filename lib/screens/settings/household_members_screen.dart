// 📄 lib/screens/settings/household_members_screen.dart
//
// 🏠 מסך חברי הבית — צפייה, הסרה, שינוי תפקיד, עזיבה

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../providers/user_context.dart';
import '../../widgets/common/notebook_background.dart';

class HouseholdMembersScreen extends StatefulWidget {
  const HouseholdMembersScreen({super.key});

  @override
  State<HouseholdMembersScreen> createState() =>
      _HouseholdMembersScreenState();
}

class _HouseholdMembersScreenState extends State<HouseholdMembersScreen> {
  List<_MemberData> _members = [];
  bool _isLoading = true;
  String? _error;
  bool _isAdmin = false;
  String? _currentUserId;
  String? _householdId;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final userContext = context.read<UserContext>();
    _currentUserId = userContext.userId;
    _householdId = userContext.householdId;

    if (_householdId == null || _currentUserId == null) {
      setState(() {
        _isLoading = false;
        _error = 'לא נמצא בית';
      });
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection('households')
          .doc(_householdId)
          .collection('members')
          .get();

      final members = snap.docs.map((doc) {
        final data = doc.data();
        return _MemberData(
          userId: doc.id,
          name: data['name'] as String? ?? 'משתמש',
          role: data['role'] as String? ?? 'member',
          joinedAt: (data['joined_at'] as Timestamp?)?.toDate(),
          email: data['email'] as String?,
        );
      }).toList();

      // Sort: admins first, then by name
      members.sort((a, b) {
        if (a.role == 'admin' && b.role != 'admin') return -1;
        if (a.role != 'admin' && b.role == 'admin') return 1;
        return a.name.compareTo(b.name);
      });

      final currentMember = members.where((m) => m.userId == _currentUserId);
      _isAdmin =
          currentMember.isNotEmpty && currentMember.first.role == 'admin';

      setState(() {
        _members = members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'שגיאה בטעינת חברי הבית';
      });
    }
  }

  Future<void> _removeMember(_MemberData member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('הסרת חבר'),
        content: Text('להסיר את ${member.name} מהבית?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.common.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('הסר'),
          ),
        ],
      ),
    );

    if (confirm != true || _householdId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('households')
          .doc(_householdId)
          .collection('members')
          .doc(member.userId)
          .delete();

      // Create personal household for removed user
      final personalHouseholdId = 'house_${member.userId}';
      final batch = FirebaseFirestore.instance.batch();
      batch.set(
        FirebaseFirestore.instance
            .collection('households')
            .doc(personalHouseholdId),
        {
          'name': 'הבית שלי',
          'created_at': FieldValue.serverTimestamp(),
          'created_by': member.userId,
        },
      );
      batch.set(
        FirebaseFirestore.instance
            .collection('households')
            .doc(personalHouseholdId)
            .collection('members')
            .doc(member.userId),
        {
          'user_id': member.userId,
          'name': member.name,
          'role': 'admin',
          'joined_at': FieldValue.serverTimestamp(),
        },
      );
      batch.update(
        FirebaseFirestore.instance.collection('users').doc(member.userId),
        {'household_id': personalHouseholdId},
      );
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${member.name} הוסר מהבית')),
        );
        unawaited(_loadMembers());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('שגיאה בהסרה: $e')),
        );
      }
    }
  }

  Future<void> _toggleRole(_MemberData member) async {
    if (_householdId == null) return;
    final newRole = member.role == 'admin' ? 'member' : 'admin';
    try {
      await FirebaseFirestore.instance
          .collection('households')
          .doc(_householdId)
          .collection('members')
          .doc(member.userId)
          .update({'role': newRole});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${member.name} ${newRole == 'admin' ? 'הפך למנהל' : 'הפך לחבר'}',
            ),
          ),
        );
        unawaited(_loadMembers());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('שגיאה: $e')),
        );
      }
    }
  }

  Future<void> _leaveHousehold() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('עזיבת הבית'),
        content: const Text(
          'בטוח שאתה רוצה לעזוב? תועבר לבית אישי חדש.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.common.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('עזוב'),
          ),
        ],
      ),
    );

    if (confirm != true ||
        _householdId == null ||
        _currentUserId == null) return;

    try {
      // Remove from current household
      await FirebaseFirestore.instance
          .collection('households')
          .doc(_householdId)
          .collection('members')
          .doc(_currentUserId)
          .delete();

      // Create personal household
      final personalId = 'house_$_currentUserId';
      final batch = FirebaseFirestore.instance.batch();
      batch.set(
        FirebaseFirestore.instance.collection('households').doc(personalId),
        {
          'name': 'הבית שלי',
          'created_at': FieldValue.serverTimestamp(),
          'created_by': _currentUserId,
        },
      );
      batch.set(
        FirebaseFirestore.instance
            .collection('households')
            .doc(personalId)
            .collection('members')
            .doc(_currentUserId!),
        {
          'user_id': _currentUserId,
          'name': context.read<UserContext>().user?.name ?? 'משתמש',
          'role': 'admin',
          'joined_at': FieldValue.serverTimestamp(),
        },
      );
      batch.update(
        FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUserId!),
        {'household_id': personalId},
      );
      await batch.commit();

      if (mounted) {
        await context.read<UserContext>().refreshUser();
        if (mounted) {
          Navigator.of(context).pop(); // back to settings
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('עזבת את הבית')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('שגיאה: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final userContext = context.watch<UserContext>();
    final householdName = userContext.householdName ?? 'הבית שלי';

    return Scaffold(
      appBar: AppBar(
        title: Text(householdName),
        centerTitle: true,
        actions: [
          if (!_isAdmin && _members.length > 1)
            IconButton(
              icon: Icon(Icons.exit_to_app, color: cs.error),
              tooltip: 'עזוב את הבית',
              onPressed: _leaveHousehold,
            ),
        ],
      ),
      body: Stack(
        children: [
          const NotebookBackground(),
          _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Text(_error!,
                        style: TextStyle(color: cs.error)),
                  )
                : RefreshIndicator(
                    onRefresh: _loadMembers,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(kSpacingMedium),
                      itemCount: _members.length + (_isAdmin && _members.length > 1 ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _members.length) {
                          // "Leave household" button for admin (only if >1 member)
                          return Padding(
                            padding: const EdgeInsets.only(top: kSpacingLarge),
                            child: OutlinedButton.icon(
                              icon: Icon(Icons.exit_to_app, color: cs.error),
                              label: Text('עזוב את הבית',
                                  style: TextStyle(color: cs.error)),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: cs.error),
                              ),
                              onPressed: _leaveHousehold,
                            ),
                          );
                        }
                        return _buildMemberCard(_members[index], cs);
                      },
                    ),
                  ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(_MemberData member, ColorScheme cs) {
    final isCurrentUser = member.userId == _currentUserId;
    final isAdmin = member.role == 'admin';
    final joinDate = member.joinedAt;

    return Card(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
        side: isCurrentUser
            ? BorderSide(color: cs.primary, width: kBorderWidthThick)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isAdmin ? cs.primaryContainer : cs.surfaceContainerHighest,
          child: Text(
            member.name.isNotEmpty ? member.name[0] : '?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isAdmin ? cs.primary : cs.onSurfaceVariant,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              member.name,
              style: TextStyle(
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isCurrentUser) ...[
              const SizedBox(width: kSpacingTiny),
              Text('(אני)', style: TextStyle(
                fontSize: kFontSizeSmall,
                color: cs.onSurfaceVariant,
              )),
            ],
          ],
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: kSpacingSmall,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: isAdmin ? kStickyGreen.withValues(alpha: 0.2) : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(kBorderRadiusSmall),
              ),
              child: Text(
                isAdmin ? '👑 מנהל' : '👤 חבר',
                style: TextStyle(fontSize: kFontSizeTiny),
              ),
            ),
            if (joinDate != null) ...[
              const SizedBox(width: kSpacingSmall),
              Text(
                'הצטרף ${_formatDate(joinDate)}',
                style: TextStyle(
                  fontSize: kFontSizeTiny,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        trailing: _isAdmin && !isCurrentUser
            ? PopupMenuButton<String>(
                onSelected: (action) {
                  switch (action) {
                    case 'toggle_role':
                      _toggleRole(member);
                    case 'remove':
                      _removeMember(member);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle_role',
                    child: Row(
                      children: [
                        Icon(
                          isAdmin
                              ? Icons.person_outline
                              : Icons.admin_panel_settings,
                          size: kIconSizeSmall,
                        ),
                        const SizedBox(width: kSpacingSmall),
                        Text(isAdmin ? 'הפוך לחבר' : 'הפוך למנהל'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.person_remove,
                            size: kIconSizeSmall, color: cs.error),
                        const SizedBox(width: kSpacingSmall),
                        Text('הסר מהבית',
                            style: TextStyle(color: cs.error)),
                      ],
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _MemberData {
  final String userId;
  final String name;
  final String role;
  final DateTime? joinedAt;
  final String? email;

  _MemberData({
    required this.userId,
    required this.name,
    required this.role,
    this.joinedAt,
    this.email,
  });
}
