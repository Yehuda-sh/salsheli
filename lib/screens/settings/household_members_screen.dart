// 📄 lib/screens/settings/household_members_screen.dart
//
// 🏠 מסך חברי הבית — "Professional Notebook" design

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../providers/user_context.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/app_loading_skeleton.dart';

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
  bool _isOwner = false;
  String? _householdCreatedBy;
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
        _error = AppStrings.household.householdNotFound;
      });
      return;
    }

    try {
      // קרא את מסמך הבית כדי לזהות מי הבעלים
      final householdDoc = await FirebaseFirestore.instance
          .collection('households')
          .doc(_householdId)
          .get();
      _householdCreatedBy = householdDoc.data()?['created_by'] as String?;

      final snap = await FirebaseFirestore.instance
          .collection('households')
          .doc(_householdId)
          .collection('members')
          .get();

      final members = snap.docs.map((doc) {
        final data = doc.data();
        final memberId = doc.id;
        // הבעלים = מי שיצר את הבית (owner > admin > member)
        final isCreator = memberId == _householdCreatedBy;
        final rawRole = data['role'] as String? ?? 'member';
        final effectiveRole = isCreator ? 'owner' : rawRole;

        return _MemberData(
          userId: memberId,
          name: data['name'] as String? ?? AppStrings.household.userFallback,
          role: effectiveRole,
          joinedAt: (data['joined_at'] as Timestamp?)?.toDate(),
          email: data['email'] as String?,
        );
      }).toList();

      // מיון: owner ראשון, אח"כ admin, אח"כ member
      members.sort((a, b) {
        const order = {'owner': 0, 'admin': 1, 'member': 2};
        final cmp = (order[a.role] ?? 3).compareTo(order[b.role] ?? 3);
        if (cmp != 0) return cmp;
        return a.name.compareTo(b.name);
      });

      final currentMember = members.where((m) => m.userId == _currentUserId);
      final currentRole = currentMember.isNotEmpty ? currentMember.first.role : 'member';
      _isOwner = currentRole == 'owner';

      setState(() {
        _members = members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = AppStrings.household.loadMembersError;
      });
    }
  }

  Future<void> _removeMember(_MemberData member) async {
    // בעלים לא ניתן להסרה
    if (member.role == 'owner') return;
    // רק בעלים יכול להסיר אדמין
    if (member.role == 'admin' && !_isOwner) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.household.removeMemberTitle),
        content: Text(AppStrings.household.removeMemberConfirm(member.name)),
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
            child: Text(AppStrings.household.removeMemberButton),
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

      final personalHouseholdId = 'house_${member.userId}';
      final batch = FirebaseFirestore.instance.batch();
      batch.set(
        FirebaseFirestore.instance
            .collection('households')
            .doc(personalHouseholdId),
        {
          'name': AppStrings.household.myHome,
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
          SnackBar(content: Text(AppStrings.household.memberRemoved(member.name))),
        );
        unawaited(_loadMembers());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.household.removeMemberError(e.toString()))),
        );
      }
    }
  }

  Future<void> _toggleRole(_MemberData member) async {
    if (_householdId == null) return;
    // רק בעלים יכול לשנות תפקידים
    if (!_isOwner) return;
    // לא ניתן לשנות תפקיד של בעלים
    if (member.role == 'owner') return;
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
              AppStrings.household.memberRoleChanged(member.name, newRole == 'admin' ? AppStrings.household.roleAdmin : AppStrings.household.roleMember),
            ),
          ),
        );
        unawaited(_loadMembers());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.household.genericError(e.toString()))),
        );
      }
    }
  }

  Future<void> _leaveHousehold() async {
    // בעלים לא יכול לעזוב — חייב למחוק את הבית או להעביר בעלות
    if (_isOwner) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.household.ownerCannotLeave)),
        );
      }
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.household.leaveHouseholdTitle),
        content: Text(AppStrings.household.leaveHouseholdConfirm),
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
            child: Text(AppStrings.household.leaveHouseholdButton),
          ),
        ],
      ),
    );

    if (confirm != true ||
        _householdId == null ||
        _currentUserId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('households')
          .doc(_householdId)
          .collection('members')
          .doc(_currentUserId)
          .delete();

      final personalId = 'house_$_currentUserId';
      final batch = FirebaseFirestore.instance.batch();
      batch.set(
        FirebaseFirestore.instance.collection('households').doc(personalId),
        {
          'name': AppStrings.household.myHome,
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
          'name': _members.firstWhere((m) => m.userId == _currentUserId, orElse: () => _MemberData(userId: '', name: AppStrings.household.userFallback, role: '')).name,
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
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.household.leftHousehold)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.household.genericError(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final userContext = context.watch<UserContext>();
    final householdName = userContext.householdName ?? AppStrings.household.myHome;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const NotebookBackground(),
          SafeArea(
            child: Column(
              children: [
                // 🏠 Inline header
                Padding(
                  padding: const EdgeInsets.all(kSpacingMedium),
                  child: Row(
                    children: [
                      // Back button
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(kBorderRadius),
                        child: Container(
                          padding: const EdgeInsets.all(kSpacingSmall),
                          decoration: BoxDecoration(
                            color: cs.surface.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(kBorderRadius),
                          ),
                          child: Icon(Icons.arrow_forward_ios,
                              size: kIconSizeSmall, color: cs.onSurface),
                        ),
                      ),
                      const SizedBox(width: kSpacingSmall),
                      // House icon in colored circle
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primaryContainer,
                        ),
                        child: Center(
                          child: Text('🏠',
                              style: TextStyle(fontSize: kFontSizeBody)),
                        ),
                      ),
                      const SizedBox(width: kSpacingSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              householdName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${_members.length} ${AppStrings.household.membersCount}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Leave button
                      if (_members.length > 1)
                        IconButton(
                          icon: Icon(Icons.exit_to_app, color: cs.error),
                          tooltip: AppStrings.household.leaveHouseholdTooltip,
                          onPressed: _leaveHousehold,
                        ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1),

                // Content
                Expanded(
                  child: _isLoading
                      ? const AppLoadingSkeleton(sectionCount: 3, showHero: false)
                      : _error != null
                          ? Center(
                              child: Text(_error!,
                                  style: TextStyle(color: cs.error)),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadMembers,
                              child: ListView.builder(
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: kSpacingMedium),
                                itemCount: _members.length,
                                itemBuilder: (context, index) {
                                  return _buildMemberCard(
                                          _members[index], cs, theme)
                                      .animate()
                                      .fadeIn(
                                          duration: 400.ms,
                                          delay: (100 * index).ms)
                                      .slideX(begin: 0.05);
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(
      _MemberData member, ColorScheme cs, ThemeData theme) {
    final isCurrentUser = member.userId == _currentUserId;
    final isMemberOwner = member.role == 'owner';
    final isMemberAdmin = member.role == 'admin' || isMemberOwner;

    return Card(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
        side: isCurrentUser
            ? BorderSide(color: cs.primary, width: kBorderWidthThick)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isMemberAdmin ? cs.primaryContainer : cs.surfaceContainerHighest,
                border: Border.all(
                  color: isMemberAdmin
                      ? cs.primary.withValues(alpha: 0.3)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  member.name.isNotEmpty ? member.name[0] : '?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isMemberAdmin ? cs.primary : cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: kSpacingMedium),

            // Name + role
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          member.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight:
                                isCurrentUser ? FontWeight.bold : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: kSpacingTiny),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: kSpacingSmall,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius:
                                BorderRadius.circular(kBorderRadiusSmall),
                          ),
                          child: Text(
                            AppStrings.household.meLabel,
                            style: TextStyle(
                              fontSize: kFontSizeTiny,
                              color: cs.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: kSpacingTiny),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kSpacingSmall,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isMemberOwner
                          ? cs.primary.withValues(alpha: 0.15)
                          : isMemberAdmin
                              ? kStickyGreen.withValues(alpha: 0.15)
                              : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                    child: Text(
                      isMemberOwner ? AppStrings.household.roleOwnerLabel : isMemberAdmin ? AppStrings.household.roleAdminLabel : AppStrings.household.roleMemberLabel,
                      style: TextStyle(
                        fontSize: kFontSizeTiny,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Actions — רק בעלים רואה תפריט פעולות, ולא על עצמו ולא על בעלים אחר
            if (_isOwner && !isCurrentUser && !isMemberOwner)
              PopupMenuButton<String>(
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
                          member.role == 'admin'
                              ? Icons.person_outline
                              : Icons.admin_panel_settings,
                          size: kIconSizeSmall,
                        ),
                        const SizedBox(width: kSpacingSmall),
                        Text(member.role == 'admin' ? AppStrings.household.makeMember : AppStrings.household.makeAdmin),
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
                        Text(AppStrings.household.removeFromHousehold,
                            style: TextStyle(color: cs.error)),
                      ],
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
