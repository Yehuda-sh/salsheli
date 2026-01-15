// 📄 lib/screens/groups/group_details_screen.dart
//
// מסך פרטי קבוצה - צפייה ועריכה (שם, תיאור, חברים).
// כולל הזמנת חברים, שינוי תפקידים, עזיבה ומחיקת קבוצה.
//
// 🔗 Related: Group, GroupsProvider, GroupInvite, ContactPickerScreen
//
// Version 2.0 - No AppBar (Immersive)
// Last Updated: 13/01/2026

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/enums/user_role.dart';
import '../../models/group.dart';
import '../../providers/groups_provider.dart';
import '../../providers/user_context.dart';
import '../../models/group_invite.dart';
import '../../repositories/group_invite_repository.dart';
import '../../services/contact_picker_service.dart';
import '../../services/notifications_service.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_button.dart';
import '../../widgets/common/sticky_note.dart';
import 'contact_picker_screen.dart';

class GroupDetailsScreen extends StatefulWidget {
  final String groupId;

  const GroupDetailsScreen({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;
  bool _isInviting = false;
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadGroupData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadGroupData() {
    final group = context.read<GroupsProvider>().getGroup(widget.groupId);
    if (group != null && !_controllersInitialized) {
      _nameController.text = group.name;
      _descriptionController.text = group.description ?? '';
      _controllersInitialized = true;
    }
  }

  /// סנכרון controllers כשהקבוצה נטענת מאוחר יותר
  void _syncControllersIfNeeded(Group group) {
    if (!_controllersInitialized && !_isEditing) {
      _nameController.text = group.name;
      _descriptionController.text = group.description ?? '';
      _controllersInitialized = true;
    }
  }

  /// קבלת אייקון לפי סוג הקבוצה
  IconData _getGroupTypeIcon(GroupType type) {
    switch (type) {
      case GroupType.family:
        return Icons.family_restroom;
      case GroupType.building:
        return Icons.apartment;
      case GroupType.kindergarten:
        return Icons.child_care;
      case GroupType.friends:
        return Icons.people;
      case GroupType.event:
        return Icons.celebration;
      case GroupType.roommates:
        return Icons.home;
      case GroupType.other:
      case GroupType.unknown:
        return Icons.group;
    }
  }

  /// בדיקת הרשאות המשתמש הנוכחי
  _UserPermissions _getUserPermissions(Group group, String userId) {
    final member = group.getMember(userId);
    if (member == null) {
      return _UserPermissions.none();
    }
    return _UserPermissions(
      canEdit: member.isOwner || member.isAdmin,
      canManageMembers: member.isOwner || member.isAdmin,
      canChangeRoles: member.isOwner,
      canDelete: member.isOwner,
      canLeave: !member.isOwner, // בעלים לא יכול לעזוב
      currentRole: member.role,
    );
  }

  /// שמירת שינויים
  Future<void> _saveChanges(Group group) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedGroup = group.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      final success =
          await context.read<GroupsProvider>().updateGroup(updatedGroup);

      if (!mounted) return;

      final strings = AppStrings.groupDetails;
      if (success) {
        await HapticFeedback.mediumImpact();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(strings.groupUpdatedSuccess),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEditing = false);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.groupUpdateError),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// פתיחת מסך בחירת אנשי קשר להזמנה
  Future<void> _inviteMembers(Group group) async {
    // מניעת לחיצה כפולה
    if (_isInviting) return;

    final result = await Navigator.of(context).push<List<SelectedContact>>(
      MaterialPageRoute(
        builder: (context) => const ContactPickerScreen(),
      ),
    );

    if (result == null || result.isEmpty || !mounted) return;

    setState(() => _isInviting = true);

    try {
      final strings = AppStrings.groupDetails;
      final userContext = context.read<UserContext>();
      final provider = context.read<GroupsProvider>();
      final currentUserId = userContext.userId ?? '';
      final currentUserName = userContext.displayName ?? 'משתמש';
      final inviteRepository = GroupInviteRepository();

      // הצגת מצב טעינה
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.addingMembers(result.length)),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 1),
        ),
      );

      int successCount = 0;
      int failCount = 0;

      for (final contact in result) {
        if (!mounted) break;

        // יצירת מזהה משתמש זמני - שימוש ב-contact.id הבטוח או timestamp
        // הימנעות משימוש באימייל/טלפון שמכילים תווים לא בטוחים ל-Firestore (. @ +)
        final tempUserId = 'invited_${contact.id.isNotEmpty ? contact.id : DateTime.now().microsecondsSinceEpoch}';

        final success = await provider.addMember(
          groupId: group.id,
          userId: tempUserId,
          name: contact.displayName,
          email: contact.email ?? '',
          role: contact.role,
          invitedBy: currentUserId,
        );

        if (!mounted) break;

        if (success) {
          successCount++;

          // יצירת הזמנה ב-collection להזמנות ממתינות
          try {
            final invite = GroupInvite.create(
              groupId: group.id,
              groupName: group.name,
              invitedPhone: contact.phone,
              invitedEmail: contact.email?.toLowerCase(),
              invitedName: contact.displayName,
              role: contact.role,
              invitedBy: currentUserId,
              invitedByName: currentUserName,
            );
            await inviteRepository.createInvite(invite);
            if (!mounted) break;
            debugPrint('📨 הזמנה נוצרה: ${contact.displayName}');
          } catch (e) {
            debugPrint('⚠️ שגיאה ביצירת הזמנה (לא קריטי): $e');
          }
        } else {
          failCount++;
        }
      }

      if (!mounted) return;

      // הודעת סיכום
      if (failCount == 0) {
        unawaited(HapticFeedback.mediumImpact());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.membersAddedSuccess(successCount)),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.membersAddedPartial(successCount, failCount)),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isInviting = false);
      }
    }
  }

  /// שינוי תפקיד חבר
  Future<void> _changeMemberRole(
    Group group,
    GroupMember member,
    UserRole newRole,
  ) async {
    final strings = AppStrings.groupDetails;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.changeRoleTitle),
        content: Text(
          strings.changeRoleConfirm(member.name, newRole.hebrewName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancelButton),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.confirmButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<GroupsProvider>();
    final success = await provider.updateMemberRole(
      group.id,
      member.userId,
      newRole,
    );

    if (!mounted) return;

    if (success) {
      await HapticFeedback.mediumImpact();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.roleChanged(member.name, newRole.hebrewName)),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// הסרת חבר מהקבוצה
  Future<void> _removeMember(Group group, GroupMember member) async {
    final strings = AppStrings.groupDetails;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.removeMemberTitle),
        content: Text(strings.removeMemberConfirm(member.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancelButton),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(strings.removeButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<GroupsProvider>();
    final success = await provider.removeMember(
      group.id,
      member.userId,
    );

    if (!mounted) return;

    if (success) {
      await HapticFeedback.mediumImpact();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.memberRemoved(member.name)),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// עזיבת קבוצה
  Future<void> _leaveGroup(Group group) async {
    final userId = context.read<UserContext>().userId;
    if (userId == null) return;

    final strings = AppStrings.groupDetails;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.leaveGroupTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.leaveGroupConfirm(group.name)),
            const SizedBox(height: 12),
            Text(
              strings.leaveGroupWarning,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancelButton),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(strings.leaveButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final userContext = context.read<UserContext>();
    final displayName = userContext.displayName ?? 'משתמש';
    final householdId = userContext.user?.householdId;
    final provider = context.read<GroupsProvider>();

    final success = await provider.removeMember(
      group.id,
      userId,
    );

    if (!mounted) return;

    if (success) {
      // 📬 שלח התראה לבעלים ולאדמינים
      if (householdId != null) {
        await _sendMemberLeftNotification(group, userId, displayName, householdId);
      }

      await HapticFeedback.mediumImpact();
      if (!mounted) return;
      Navigator.of(context).pop(); // חזרה למסך הקודם
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.leftGroup(group.name)),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// 📬 שליחת התראה לאדמינים ובעלים על עזיבת חבר
  Future<void> _sendMemberLeftNotification(
    Group group,
    String leavingUserId,
    String memberName,
    String householdId,
  ) async {
    try {
      final notificationsService = NotificationsService(FirebaseFirestore.instance);
      final ownerId = group.createdBy;

      // שלח התראה לבעלים
      if (ownerId != leavingUserId) {
        await notificationsService.createMemberLeftNotification(
          userId: ownerId,
          householdId: householdId,
          groupId: group.id,
          groupName: group.name,
          memberName: memberName,
        );
        debugPrint('📬 התראת עזיבה נשלחה לבעלים: $ownerId');
      }

      // שלח התראה לאדמינים
      for (final member in group.membersList) {
        if (member.role == UserRole.admin &&
            member.userId != leavingUserId &&
            member.userId != ownerId) {
          await notificationsService.createMemberLeftNotification(
            userId: member.userId,
            householdId: householdId,
            groupId: group.id,
            groupName: group.name,
            memberName: memberName,
          );
          debugPrint('📬 התראת עזיבה נשלחה לאדמין: ${member.userId}');
        }
      }
    } catch (e) {
      debugPrint('⚠️ שגיאה בשליחת התראת עזיבה (לא קריטי): $e');
    }
  }

  /// מחיקת קבוצה
  Future<void> _deleteGroup(Group group) async {
    final strings = AppStrings.groupDetails;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            Text(strings.deleteGroupTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.deleteGroupConfirm(group.name)),
            const SizedBox(height: 12),
            Text(
              strings.deleteGroupWarning(group.memberCount),
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancelButton),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(strings.deleteGroupButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);

    final provider = context.read<GroupsProvider>();
    final success = await provider.deleteGroup(group.id);

    if (!mounted) return;

    if (success) {
      await HapticFeedback.heavyImpact();
      if (!mounted) return;
      Navigator.of(context).pop(); // חזרה למסך הקודם
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.groupDeleted(group.name)),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.deleteGroupError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final userId = context.watch<UserContext>().userId ?? '';

    return Consumer<GroupsProvider>(
      builder: (context, provider, _) {
        final group = provider.getGroup(widget.groupId);

        if (group == null) {
          final strings = AppStrings.groupDetails;
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: Text(strings.groupNotFoundMessage),
              ),
            ),
          );
        }

        // סנכרון controllers כשהקבוצה נטענת מאוחר יותר מ-Firestore
        _syncControllersIfNeeded(group);

        final permissions = _getUserPermissions(group, userId);
        final strings = AppStrings.groupDetails;

        final theme = Theme.of(context);
        return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: Stack(
                children: [
                  const NotebookBackground(),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Column(
                      children: [
                        // 🏷️ כותרת inline
                        Padding(
                          padding: const EdgeInsets.all(kSpacingMedium),
                          child: Row(
                            children: [
                              Icon(Icons.group, size: 24, color: cs.primary),
                              const SizedBox(width: kSpacingSmall),
                              Expanded(
                                child: Text(
                                  group.displayName,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: cs.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // כפתורי פעולה
                              if (permissions.canEdit && !_isEditing)
                                IconButton(
                                  icon: Icon(Icons.edit, color: cs.primary),
                                  onPressed: () => setState(() => _isEditing = true),
                                  tooltip: strings.editTooltip,
                                ),
                              if (_isEditing)
                                IconButton(
                                  icon: Icon(Icons.close, color: cs.error),
                                  onPressed: () {
                                    _loadGroupData();
                                    setState(() => _isEditing = false);
                                  },
                                  tooltip: strings.cancelTooltip,
                                ),
                            ],
                          ),
                        ),
                        // תוכן המסך
                        Expanded(
                          child: _buildContent(context, group, permissions, cs),
                        ),
                      ],
                    ),
                ],
              ),
            ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    Group group,
    _UserPermissions permissions,
    ColorScheme cs,
  ) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(kSpacingMedium),
        children: [
          // === פרטי קבוצה ===
          _buildGroupInfoCard(group, permissions, cs),

          const SizedBox(height: kSpacingMedium),

          // === חברים (הועבר למעלה - יותר חשוב) ===
          _buildMembersCard(group, permissions, cs),

          const SizedBox(height: kSpacingMedium),

          // === תכונות הקבוצה ===
          _buildFeaturesCard(group, cs),

          const SizedBox(height: kSpacingMedium),

          // === פעולות ===
          _buildActionsCard(group, permissions, cs),

          const SizedBox(height: kSpacingLarge),
        ],
      ),
    );
  }

  /// כרטיס פרטי קבוצה
  Widget _buildGroupInfoCard(
    Group group,
    _UserPermissions permissions,
    ColorScheme cs,
  ) {
    final strings = AppStrings.groupDetails;
    return StickyNote(
      color: kStickyYellow,
      rotation: -0.01,
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === כותרת עם אייקון ===
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // אייקון סוג הקבוצה בעיגול
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      group.type.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: kSpacingSmall),
                // פרטים
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // כותרת + סוג
                      Row(
                        children: [
                          Icon(_getGroupTypeIcon(group.type), size: 18, color: cs.primary),
                          const SizedBox(width: 4),
                          Text(
                            strings.groupDetailsTitle,
                            style: const TextStyle(
                              fontSize: kFontSizeMedium,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        group.type.hebrewName,
                        style: TextStyle(
                          fontSize: kFontSizeSmall,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: kSpacingMedium),

            // === שדות מידע ===
            if (_isEditing) ...[
              // מצב עריכה - שם
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: strings.groupNameLabel,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(kBorderRadius),
                  ),
                ),
                maxLength: 30,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return strings.groupNameValidation;
                  }
                  return null;
                },
              ),
              const SizedBox(height: kSpacingSmall),
              // מצב עריכה - תיאור
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: strings.descriptionLabel,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(kBorderRadius),
                  ),
                ),
                maxLines: 2,
                maxLength: 100,
              ),
            ] else ...[
              // מצב צפייה - עיצוב נקי יותר
              _buildInfoField(
                icon: Icons.badge_outlined,
                label: strings.nameLabel,
                value: group.name,
              ),
              if (group.description != null && group.description!.isNotEmpty)
                _buildInfoField(
                  icon: Icons.notes,
                  label: strings.descriptionFieldLabel,
                  value: group.description!,
                ),
              _buildInfoField(
                icon: Icons.calendar_today_outlined,
                label: strings.createdLabel,
                value: _formatDate(group.createdAt),
              ),
              // שדות נוספים
              if (group.extraFields != null)
                ...group.extraFields!.entries.map((e) => _buildInfoField(
                      icon: Icons.info_outline,
                      label: _getExtraFieldLabel(e.key),
                      value: e.value.toString(),
                    )),
            ],

            // כפתור שמירה
            if (_isEditing) ...[
              const SizedBox(height: kSpacingMedium),
              StickyButton(
                label: strings.saveChanges,
                color: cs.primary,
                textColor: Colors.white,
                onPressed: () => _saveChanges(group),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// שדה מידע בעיצוב נקי
  Widget _buildInfoField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kSpacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.black45),
          const SizedBox(width: kSpacingSmall),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: kFontSizeSmall,
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// כרטיס תכונות
  Widget _buildFeaturesCard(Group group, ColorScheme cs) {
    final strings = AppStrings.groupDetails;
    return StickyNote(
      color: kStickyCyan,
      rotation: 0.008,
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.featuresTitle,
              style: const TextStyle(
                fontSize: kFontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: kSpacingSmall),
            Wrap(
              spacing: kSpacingSmall,
              runSpacing: 4,
              children: [
                if (group.type.hasPantry)
                  _FeatureChip(icon: Icons.inventory_2, label: strings.featurePantry),
                if (group.type.hasShoppingMode)
                  _FeatureChip(icon: Icons.shopping_cart, label: strings.featureShopping),
                if (group.type.hasVoting)
                  _FeatureChip(icon: Icons.how_to_vote, label: strings.featureVoting),
                if (group.type.hasWhosBringing)
                  _FeatureChip(icon: Icons.person_add, label: strings.featureWhosBringing),
                _FeatureChip(icon: Icons.checklist, label: strings.featureChecklist),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// כרטיס חברים
  Widget _buildMembersCard(
    Group group,
    _UserPermissions permissions,
    ColorScheme cs,
  ) {
    final strings = AppStrings.groupDetails;
    final members = group.membersList;
    final currentUserId = context.read<UserContext>().userId;

    return StickyNote(
      color: kStickyGreen,
      rotation: -0.005,
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // כותרת
            Row(
              children: [
                const Icon(Icons.people, size: 20),
                const SizedBox(width: kSpacingSmall),
                Text(
                  strings.membersTitle(members.length),
                  style: const TextStyle(
                    fontSize: kFontSizeMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (permissions.canManageMembers)
                  TextButton.icon(
                    onPressed: _isInviting ? null : () => _inviteMembers(group),
                    icon: _isInviting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.person_add, size: 18),
                    label: Text(_isInviting ? strings.invitingButton : strings.inviteButton),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: kSpacingSmall),

            // רשימת חברים
            ...members.map((member) {
              final isCurrentUser = member.userId == currentUserId;
              final canModify = permissions.canManageMembers &&
                  !isCurrentUser &&
                  !member.isOwner;
              final canChangeRole =
                  permissions.canChangeRoles && !member.isOwner;

              return _MemberTile(
                member: member,
                isCurrentUser: isCurrentUser,
                canModify: canModify,
                canChangeRole: canChangeRole,
                onChangeRole: canChangeRole
                    ? (newRole) => _changeMemberRole(group, member, newRole)
                    : null,
                onRemove:
                    canModify ? () => _removeMember(group, member) : null,
              );
            }),
          ],
        ),
      ),
    );
  }

  /// כרטיס פעולות
  Widget _buildActionsCard(
    Group group,
    _UserPermissions permissions,
    ColorScheme cs,
  ) {
    final strings = AppStrings.groupDetails;
    return StickyNote(
      color: kStickyGray, // צבע ניטרלי - פעולות הרסניות
      rotation: 0.01,
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.actionsTitle,
              style: const TextStyle(
                fontSize: kFontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: kSpacingSmall),

            // עזיבת קבוצה
            if (permissions.canLeave)
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.orange),
                title: Text(strings.leaveGroupAction),
                subtitle: Text(strings.leaveGroupSubtitle),
                onTap: () => _leaveGroup(group),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),

            // מחיקת קבוצה
            if (permissions.canDelete) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: Text(
                  strings.deleteGroupAction,
                  style: const TextStyle(color: Colors.red),
                ),
                subtitle: Text(strings.irreversibleAction),
                onTap: () => _deleteGroup(group),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ],

            // הודעה לבעלים
            if (!permissions.canLeave && !permissions.canDelete)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  strings.ownerCannotLeaveMessage,
                  style: const TextStyle(
                    fontSize: kFontSizeSmall,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getExtraFieldLabel(String key) {
    final strings = AppStrings.groupDetails;
    switch (key) {
      case 'address':
        return strings.addressLabel;
      case 'school_name':
        return strings.schoolNameLabel;
      case 'event_name':
        return strings.eventNameLabel;
      default:
        return key;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ============================================================
// HELPER CLASSES
// ============================================================

/// הרשאות המשתמש הנוכחי
class _UserPermissions {
  final bool canEdit;
  final bool canManageMembers;
  final bool canChangeRoles;
  final bool canDelete;
  final bool canLeave;
  final UserRole? currentRole;

  _UserPermissions({
    required this.canEdit,
    required this.canManageMembers,
    required this.canChangeRoles,
    required this.canDelete,
    required this.canLeave,
    this.currentRole,
  });

  factory _UserPermissions.none() => _UserPermissions(
        canEdit: false,
        canManageMembers: false,
        canChangeRoles: false,
        canDelete: false,
        canLeave: false,
      );
}

/// Chip תכונה
class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kSpacingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(kBorderRadius),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

/// סטטוס חבר בקבוצה
enum _MemberStatus {
  /// מוזמן - טרם אישר
  invited,

  /// פעיל - אישר והצטרף
  active,
}

/// כרטיס חבר
class _MemberTile extends StatelessWidget {
  final GroupMember member;
  final bool isCurrentUser;
  final bool canModify;
  final bool canChangeRole;
  final Function(UserRole)? onChangeRole;
  final VoidCallback? onRemove;

  const _MemberTile({
    required this.member,
    required this.isCurrentUser,
    required this.canModify,
    required this.canChangeRole,
    this.onChangeRole,
    this.onRemove,
  });

  /// קביעת סטטוס החבר לפי ה-userId
  _MemberStatus get _status {
    // אם ה-userId מתחיל ב-invited_ - זה מוזמן שטרם אישר
    if (member.userId.startsWith('invited_')) {
      return _MemberStatus.invited;
    }
    return _MemberStatus.active;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.groupDetails;
    final cs = Theme.of(context).colorScheme;
    final status = _status;
    final isInvited = status == _MemberStatus.invited;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isCurrentUser
          ? cs.primaryContainer.withValues(alpha: 0.3)
          : isInvited
              ? Colors.orange.shade50
              : Colors.white,
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: isInvited ? Colors.orange.shade200 : cs.primaryContainer,
              child: isInvited
                  ? const Icon(Icons.hourglass_empty, size: 20, color: Colors.orange)
                  : Text(
                      (member.name.characters.firstOrNull ?? '?').toUpperCase(),
                      style: TextStyle(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            // Badge סטטוס
            if (isInvited)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name + (isCurrentUser ? strings.currentUserSuffix : ''),
                    style: TextStyle(
                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  // תג סטטוס
                  if (isInvited)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        strings.pendingApproval,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // תג תפקיד
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getRoleColor(member.role),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${member.role.emoji} ${member.role.hebrewName}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          member.email.isNotEmpty ? member.email : strings.noEmail,
          style: TextStyle(
            fontSize: 12,
            fontStyle: member.email.isEmpty ? FontStyle.italic : FontStyle.normal,
            color: member.email.isEmpty ? Colors.grey : null,
          ),
        ),
        trailing: canModify
            ? PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'remove') {
                    onRemove?.call();
                  } else if (value.startsWith('role_')) {
                    final roleName = value.substring(5);
                    final role = UserRole.values.firstWhere(
                      (r) => r.name == roleName,
                      orElse: () => UserRole.editor,
                    );
                    onChangeRole?.call(role);
                  }
                },
                itemBuilder: (context) => [
                  if (canChangeRole) ...[
                    PopupMenuItem(
                      enabled: false,
                      child: Text(
                        strings.changeRoleHeader,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...UserRole.values
                        .where((r) => r != UserRole.owner && r != member.role)
                        .map((role) => PopupMenuItem(
                              value: 'role_${role.name}',
                              child: Text('${role.emoji} ${role.hebrewName}'),
                            )),
                    const PopupMenuDivider(),
                  ],
                  PopupMenuItem(
                    value: 'remove',
                    child: Text(
                      strings.removeFromGroup,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              )
            : null,
        dense: true,
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return Colors.amber[700]!;
      case UserRole.admin:
        return Colors.blue;
      case UserRole.editor:
        return Colors.green;
      case UserRole.viewer:
      case UserRole.unknown:
        return Colors.grey;
    }
  }
}
