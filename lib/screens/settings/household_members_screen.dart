// 📄 lib/screens/settings/household_members_screen.dart
//
// 🏠 מסך חברי הבית — "Professional Notebook" design

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/error_utils.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../providers/user_context.dart';
import '../../services/household_service.dart';
import '../../widgets/common/app_loading_skeleton.dart';
import '../../widgets/common/notebook_background.dart';

class HouseholdMembersScreen extends StatefulWidget {
  const HouseholdMembersScreen({super.key});

  @override
  State<HouseholdMembersScreen> createState() =>
      _HouseholdMembersScreenState();
}

class _HouseholdMembersScreenState extends State<HouseholdMembersScreen> {
  final _householdService = HouseholdService();
  List<_MemberData> _members = [];
  bool _isLoading = true;
  String? _error;
  bool _isOwner = false;
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
      final members = await _householdService.getMembers(_householdId!);

      final mapped = members.map((m) => _MemberData(
        userId: m.userId,
        name: m.name,
        role: m.role,
        joinedAt: m.joinedAt,
        email: m.email,
      )).toList();

      final currentMember = mapped.where((m) => m.userId == _currentUserId);
      final currentRole = currentMember.isNotEmpty ? currentMember.first.role : 'member';
      _isOwner = currentRole == 'owner';

      if (!mounted) return;
      setState(() {
        _members = mapped;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
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
      await _householdService.removeMember(
        householdId: _householdId!,
        memberId: member.userId,
        memberName: member.name,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.household.memberRemoved(member.name))),
        );
        unawaited(_loadMembers());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFriendlyError(e, context: 'removeMember'))),
        );
      }
    }
  }

  Future<void> _toggleRole(_MemberData member) async {
    if (_householdId == null) return;
    if (!_isOwner) return;
    if (member.role == 'owner') return;
    try {
      await _householdService.toggleRole(
        householdId: _householdId!,
        memberId: member.userId,
        currentRole: member.role,
      );

      final newRole = member.role == 'admin' ? 'member' : 'admin';
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
          SnackBar(content: Text(userFriendlyError(e, context: 'household'))),
        );
      }
    }
  }

  Future<void> _leaveHousehold() async {
    // בעלים לא יכול לעזוב — חייב למחוק את הבית או להעביר בעלות
    if (_isOwner) {
      if (mounted) {
        final cs = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.info_outline, color: cs.onTertiaryContainer, size: kIconSizeMedium),
                const SizedBox(width: kSpacingSmall),
                Expanded(child: Text(
                  AppStrings.household.ownerCannotLeave,
                  style: TextStyle(color: cs.onTertiaryContainer),
                )),
              ],
            ),
            backgroundColor: cs.tertiaryContainer,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
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

    if (confirm != true || _householdId == null || _currentUserId == null) {
      return;
    }

    try {
      final memberName = _members
          .where((m) => m.userId == _currentUserId)
          .firstOrNull?.name ?? AppStrings.household.userFallback;

      await _householdService.leaveHousehold(
        householdId: _householdId!,
        userId: _currentUserId!,
        userName: memberName,
      );

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
          SnackBar(content: Text(userFriendlyError(e, context: 'household'))),
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
                        width: kIconSizeLarge + kSpacingXTiny,
                        height: kIconSizeLarge + kSpacingXTiny,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primaryContainer,
                        ),
                        child: const Center(
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
                      ? const AppLoadingSkeleton()
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
              width: kIconSizeXLarge,
              height: kIconSizeXLarge,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isMemberAdmin ? cs.primaryContainer : cs.surfaceContainerHighest,
                border: Border.all(
                  color: isMemberAdmin
                      ? cs.primary.withValues(alpha: 0.3)
                      : Colors.transparent,
                  width: kBorderWidthFocused,
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
