// 📄 File: lib/features/household/screens/household_members_screen.dart
// 🎯 Purpose: מסך ניהול חברי משפחה
//
// 📋 Features:
// - צפייה בכל חברי המשפחה
// - שינוי תפקיד (Owner בלבד)
// - הסרת חבר (Owner בלבד)
//
// 📝 Version: 1.0
// 📅 Created: 04/12/2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/enums/user_role.dart';
import '../../../providers/user_context.dart';
import '../../../widgets/common/notebook_background.dart';
import '../../../widgets/common/sticky_note.dart';
import '../models/household_member.dart';
import '../services/household_service.dart';

class HouseholdMembersScreen extends StatefulWidget {
  const HouseholdMembersScreen({super.key});

  @override
  State<HouseholdMembersScreen> createState() => _HouseholdMembersScreenState();
}

class _HouseholdMembersScreenState extends State<HouseholdMembersScreen> {
  final _householdService = HouseholdService();

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContext>();
    final householdId = userContext.householdId;
    final currentUserId = userContext.userId;

    if (householdId == null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('חברי משפחה')),
          body: const Center(child: Text('לא מחובר למשפחה')),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('חברי משפחה'),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            const NotebookBackground(),
            SafeArea(
              child: StreamBuilder<List<HouseholdMember>>(
                stream: _householdService.watchHouseholdMembers(householdId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('שגיאה: ${snapshot.error}'),
                    );
                  }

                  final members = snapshot.data ?? [];

                  if (members.isEmpty) {
                    return _buildEmptyState();
                  }

                  // מצא אם המשתמש הנוכחי הוא Owner
                  final isCurrentUserOwner = members.any(
                    (m) => m.userId == currentUserId && m.isOwner,
                  );

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      return _buildMemberCard(
                        members[index],
                        isCurrentUserOwner: isCurrentUserOwner,
                        isCurrentUser: members[index].userId == currentUserId,
                        householdId: householdId,
                      );
                    },
                  );
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('👨‍👩‍👧‍👦', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'אין חברי משפחה',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'הזמן בני משפחה להצטרף!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(
    HouseholdMember member, {
    required bool isCurrentUserOwner,
    required bool isCurrentUser,
    required String householdId,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: StickyNote(
        color: member.isOwner
            ? const Color(0xFFFFE082) // צהוב לowner
            : const Color(0xFFE1F5FE), // כחול בהיר לשאר
        rotation: 0.003,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 👤 אווטאר
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue.shade100,
                backgroundImage: member.avatarUrl != null
                    ? NetworkImage(member.avatarUrl!)
                    : null,
                child: member.avatarUrl == null
                    ? Text(
                        member.name.isNotEmpty
                            ? member.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 16),

              // 📋 פרטים
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            member.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'אני',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.email,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          member.roleEmoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          member.roleDisplayName,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ⚙️ אפשרויות (רק ל-Owner ולא על עצמו)
              if (isCurrentUserOwner && !isCurrentUser && !member.isOwner)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'change_role':
                        _showChangeRoleDialog(member, householdId);
                        break;
                      case 'remove':
                        _showRemoveMemberDialog(member, householdId);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'change_role',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('שנה תפקיד'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.person_remove, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('הסר מהמשפחה', style: TextStyle(color: Colors.red)),
                        ],
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

  /// ✏️ דיאלוג שינוי תפקיד
  void _showChangeRoleDialog(HouseholdMember member, String householdId) {
    UserRole selectedRole = member.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('שינוי תפקיד'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('שנה את התפקיד של ${member.name}:'),
                const SizedBox(height: 16),
                ...UserRole.values
                    .where((r) => r != UserRole.owner)
                    .map((role) => RadioListTile<UserRole>(
                          title: Text(_getRoleTitle(role)),
                          subtitle: Text(
                            _getRoleDescription(role),
                            style: const TextStyle(fontSize: 12),
                          ),
                          value: role,
                          groupValue: selectedRole,
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => selectedRole = value);
                            }
                          },
                          dense: true,
                        )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ביטול'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _changeRole(member, householdId, selectedRole);
                },
                child: const Text('שמור'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🗑️ דיאלוג הסרת חבר
  void _showRemoveMemberDialog(HouseholdMember member, String householdId) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('הסרת חבר'),
          content: Text(
            'האם להסיר את ${member.name} מהמשפחה?\n\nהמשתמש יאבד גישה לכל הרשימות והמלאי המשותפים.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ביטול'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _removeMember(member, householdId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('הסר'),
            ),
          ],
        ),
      ),
    );
  }

  /// ✏️ שינוי תפקיד
  Future<void> _changeRole(
      HouseholdMember member, String householdId, UserRole newRole) async {
    try {
      await _householdService.updateMemberRole(
        householdId: householdId,
        memberId: member.userId,
        newRole: newRole,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('התפקיד של ${member.name} עודכן'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 🗑️ הסרת חבר
  Future<void> _removeMember(HouseholdMember member, String householdId) async {
    try {
      final userContext = context.read<UserContext>();
      final removerId = userContext.userId;

      if (removerId == null) return;

      await _householdService.removeMember(
        householdId: householdId,
        memberId: member.userId,
        removerId: removerId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${member.name} הוסר מהמשפחה'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getRoleTitle(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return '👨‍💼 מנהל';
      case UserRole.editor:
        return '✏️ עורך';
      case UserRole.viewer:
        return '👁️ צופה';
      case UserRole.owner:
        return '👑 בעלים';
    }
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'יכול להזמין ולנהל משתמשים';
      case UserRole.editor:
        return 'יכול לערוך רשימות ומלאי';
      case UserRole.viewer:
        return 'יכול לצפות בלבד';
      case UserRole.owner:
        return 'שליטה מלאה';
    }
  }
}
