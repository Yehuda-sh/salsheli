// 📄 File: lib/screens/groups/group_details_screen.dart
// 🎯 Purpose: מסך פרטי קבוצה ועריכה
//
// 📋 Features:
// - צפייה בפרטי הקבוצה
// - עריכת שם ותיאור (לבעלים/אדמין)
// - ניהול חברים (רשימה, הרשאות, הסרה)
// - עזיבת קבוצה
// - מחיקת קבוצה (רק לבעלים)
//
// 📝 Version: 1.0
// 📅 Created: 16/12/2025

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
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
    if (group != null) {
      _nameController.text = group.name;
      _descriptionController.text = group.description ?? '';
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

      if (success) {
        await HapticFeedback.mediumImpact();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('הקבוצה עודכנה בהצלחה'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEditing = false);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('שגיאה בעדכון הקבוצה'),
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
    final result = await Navigator.of(context).push<List<SelectedContact>>(
      MaterialPageRoute(
        builder: (context) => const ContactPickerScreen(),
      ),
    );

    if (result == null || result.isEmpty || !mounted) return;

    final userContext = context.read<UserContext>();
    final provider = context.read<GroupsProvider>();
    final currentUserId = userContext.userId ?? '';
    final currentUserName = userContext.displayName ?? 'משתמש';
    final inviteRepository = GroupInviteRepository();

    // הצגת מצב טעינה
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('מוסיף ${result.length} חברים לקבוצה...'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 1),
      ),
    );

    int successCount = 0;
    int failCount = 0;

    for (final contact in result) {
      // יצירת מזהה משתמש זמני (מבוסס על אימייל או טלפון)
      final tempUserId = 'invited_${contact.email ?? contact.phone ?? contact.id}';

      final success = await provider.addMember(
        groupId: group.id,
        userId: tempUserId,
        name: contact.displayName,
        email: contact.email ?? '',
        role: contact.role,
        invitedBy: currentUserId,
      );

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
          content: Text('נוספו $successCount חברים לקבוצה בהצלחה!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('נוספו $successCount, נכשלו $failCount'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// שינוי תפקיד חבר
  Future<void> _changeMemberRole(
    Group group,
    GroupMember member,
    UserRole newRole,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('שינוי תפקיד'),
        content: Text(
          'האם לשנות את התפקיד של ${member.name} ל${newRole.hebrewName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('אישור'),
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
          content: Text('התפקיד של ${member.name} שונה ל${newRole.hebrewName}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// הסרת חבר מהקבוצה
  Future<void> _removeMember(Group group, GroupMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('הסרת חבר'),
        content: Text('האם להסיר את ${member.name} מהקבוצה?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('הסר'),
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
          content: Text('${member.name} הוסר מהקבוצה'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// עזיבת קבוצה
  Future<void> _leaveGroup(Group group) async {
    final userId = context.read<UserContext>().userId;
    if (userId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('עזיבת קבוצה'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('האם לעזוב את "${group.name}"?'),
            const SizedBox(height: 12),
            const Text(
              'שים לב:\n• הסימונים שלך יבוטלו\n• לא תוכל לראות את הרשימות',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('עזוב'),
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
          content: Text('עזבת את "${group.name}"'),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('מחיקת קבוצה'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('האם למחוק את "${group.name}"?'),
            const SizedBox(height: 12),
            Text(
              'פעולה זו תמחק:\n'
              '• את הקבוצה\n'
              '• את כל הרשימות (${group.memberCount} חברים)\n\n'
              'פעולה זו בלתי הפיכה!',
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('מחק קבוצה'),
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
          content: Text('הקבוצה "${group.name}" נמחקה'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('שגיאה במחיקת הקבוצה'),
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
          return Scaffold(
            appBar: AppBar(title: const Text('קבוצה לא נמצאה')),
            body: const Center(
              child: Text('הקבוצה לא קיימת או שאין לך גישה'),
            ),
          );
        }

        final permissions = _getUserPermissions(group, userId);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: kPaperBackground,
            appBar: AppBar(
              title: Text(group.displayName),
              centerTitle: true,
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              actions: [
                if (permissions.canEdit && !_isEditing)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => setState(() => _isEditing = true),
                    tooltip: 'עריכה',
                  ),
                if (_isEditing)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _loadGroupData();
                      setState(() => _isEditing = false);
                    },
                    tooltip: 'ביטול',
                  ),
              ],
            ),
            body: Stack(
              children: [
                const NotebookBackground(),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  _buildContent(context, group, permissions, cs),
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
                          Icon(group.type.icon, size: 18, color: cs.primary),
                          const SizedBox(width: 4),
                          const Text(
                            'פרטי הקבוצה',
                            style: TextStyle(
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
                  labelText: 'שם הקבוצה *',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(kBorderRadius),
                  ),
                ),
                maxLength: 30,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'נא להזין שם לקבוצה';
                  }
                  return null;
                },
              ),
              const SizedBox(height: kSpacingSmall),
              // מצב עריכה - תיאור
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'תיאור (אופציונלי)',
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
                label: 'שם',
                value: group.name,
              ),
              if (group.description != null && group.description!.isNotEmpty)
                _buildInfoField(
                  icon: Icons.notes,
                  label: 'תיאור',
                  value: group.description!,
                ),
              _buildInfoField(
                icon: Icons.calendar_today_outlined,
                label: 'נוצרה',
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
                label: 'שמור שינויים',
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
    return StickyNote(
      color: kStickyCyan,
      rotation: 0.008,
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'תכונות זמינות',
              style: TextStyle(
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
                  const _FeatureChip(icon: Icons.inventory_2, label: 'מזווה'),
                if (group.type.hasShoppingMode)
                  const _FeatureChip(icon: Icons.shopping_cart, label: 'קניות'),
                if (group.type.hasVoting)
                  const _FeatureChip(icon: Icons.how_to_vote, label: 'הצבעות'),
                if (group.type.hasWhosBringing)
                  const _FeatureChip(icon: Icons.person_add, label: 'מי מביא'),
                const _FeatureChip(icon: Icons.checklist, label: 'צ\'קליסט'),
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
                  'חברים (${members.length})',
                  style: const TextStyle(
                    fontSize: kFontSizeMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (permissions.canManageMembers)
                  TextButton.icon(
                    onPressed: () => _inviteMembers(group),
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('הזמן'),
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
    return StickyNote(
      color: kStickyGray, // צבע ניטרלי - פעולות הרסניות
      rotation: 0.01,
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'פעולות',
              style: TextStyle(
                fontSize: kFontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: kSpacingSmall),

            // עזיבת קבוצה
            if (permissions.canLeave)
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.orange),
                title: const Text('עזוב קבוצה'),
                subtitle: const Text('תוסר מהקבוצה והסימונים שלך יבוטלו'),
                onTap: () => _leaveGroup(group),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),

            // מחיקת קבוצה
            if (permissions.canDelete) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text(
                  'מחק קבוצה',
                  style: TextStyle(color: Colors.red),
                ),
                subtitle: const Text('פעולה זו בלתי הפיכה'),
                onTap: () => _deleteGroup(group),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ],

            // הודעה לבעלים
            if (!permissions.canLeave && !permissions.canDelete)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'כבעלים של הקבוצה, יש להעביר את הבעלות לפני עזיבה או למחוק את הקבוצה.',
                  style: TextStyle(
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
    switch (key) {
      case 'address':
        return 'כתובת';
      case 'school_name':
        return 'שם הגן/בית ספר';
      case 'event_name':
        return 'שם האירוע';
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
                      member.name[0].toUpperCase(),
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
                    member.name + (isCurrentUser ? ' (את/ה)' : ''),
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
                      child: const Text(
                        'ממתין לאישור',
                        style: TextStyle(
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
          member.email.isNotEmpty ? member.email : 'ללא אימייל',
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
                    const PopupMenuItem(
                      enabled: false,
                      child: Text(
                        'שנה תפקיד:',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                  const PopupMenuItem(
                    value: 'remove',
                    child: Text(
                      'הסר מהקבוצה',
                      style: TextStyle(color: Colors.red),
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
        return Colors.grey;
    }
  }
}
