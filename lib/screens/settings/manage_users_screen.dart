// 📄 File: lib/screens/settings/manage_users_screen.dart
//
// 🇮🇱 מסך ניהול משתמשים משותפים:
//     - רשימת כל המשתמשים ברשימה (Owner + Shared)
//     - עריכת תפקידים (רק Owner)
//     - הסרת משתמשים (רק Owner)
//     - הזמנת משתמשים חדשים (רק Owner)
//
// 🔒 הרשאות:
//     - רק Owner יכול לראות/לערוך מסך זה
//     - Admin/Editor/Viewer רואים read-only
//
// 🎨 UI:
//     - Sticky Notes Design
//     - RTL Support
//     - Empty State
//     - Loading State
//
// Version 2.1 - No AppBar (Immersive)
// Last Updated: 13/01/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/enums/user_role.dart';
import '../../models/shared_user.dart';
import '../../models/shopping_list.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../providers/user_context.dart';
import '../../services/notifications_service.dart';
import '../../services/share_list_service.dart';
import '../sharing/invite_users_screen.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/app_loading_skeleton.dart';

/// 🇮🇱 מסך ניהול משתמשים משותפים
/// 🇬🇧 Manage shared users screen
class ManageUsersScreen extends StatefulWidget {
  final ShoppingList list;

  const ManageUsersScreen({
    required this.list,
    super.key,
  });

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<SharedUser> _users = [];
  late final NotificationsService _notificationsService;
  late ShoppingList _currentList; // 🔧 רשימה עדכנית (לא widget.list הישן)
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _notificationsService = NotificationsService(FirebaseFirestore.instance);
    _currentList = widget.list; // 🔧 אתחול הרשימה הנוכחית

    // 🔒 Note: גם משתמשים ללא הרשאת ניהול יכולים לראות (read-only mode)
    // FAB והתפריט לא יוצגו להם
    if (kDebugMode && !widget.list.canCurrentUserManage) {
    }

    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      // 🔧 שימוש ב-_currentList (לא widget.list) כדי לקבל נתונים עדכניים
      _users = ShareListService.getUsersForList(_currentList);

      // 📊 מיון לפי תפקיד: Owner → Admin → Editor → Viewer
      _users.sort((a, b) => a.role.index.compareTo(b.role.index));
    });
  }

  // Helper: מחזיר שם תצוגה (תמיד String, לא nullable)
  String _getDisplayName(SharedUser user) {
    final strings = AppStrings.manageUsers;

    // אם יש userName - השתמש בו
    if (user.userName != null && user.userName!.isNotEmpty) {
      return user.userName!;
    }

    // אם זה המשתמש הנוכחי - קח את השם מ-UserContext
    final userContext = context.read<UserContext>();
    if (user.userId == userContext.userId) {
      return userContext.displayName ?? strings.me;
    }

    // ברירת מחדל - הצג "משתמש" עם 4 תווים אחרונים של ה-ID
    final shortId = user.userId.length > 4
        ? user.userId.substring(user.userId.length - 4)
        : user.userId;
    return strings.userShortId(shortId);
  }

  Future<void> _removeUser(SharedUser user) async {
    final cs = Theme.of(context).colorScheme;
    final strings = AppStrings.manageUsers;
    final userContext = context.read<UserContext>();
    final currentUserId = userContext.userId;

    // בדיקה שהמשתמש מחובר
    if (currentUserId == null) {
      _showError(strings.errorUserNotLoggedIn);
      return;
    }

    // בדיקת הרשאות - שימוש ב-_currentList
    if (!ShareListService.canUserManage(_currentList, currentUserId)) {
      _showError(strings.errorNoPermissionRemove);
      return;
    }

    // אישור מהמשתמש
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final displayName = _getDisplayName(user);
        return AlertDialog(
          title: Text(strings.removeUserTitle),
          content: Text(strings.removeUserConfirmation(displayName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: cs.error,
              ),
              child: Text(strings.removeButton),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final currentUserName = userContext.displayName ?? strings.defaultUserName;
      final householdId = userContext.householdId;
      final provider = context.read<ShoppingListsProvider>();

      // בדיקה שיש householdId
      if (householdId == null) {
        _showError(strings.errorNoHousehold);
        return;
      }

      final updatedList = await ShareListService.removeUser(
        list: _currentList, // 🔧 שימוש ב-_currentList
        currentUserId: currentUserId,
        removedUserId: user.userId,
        removerName: currentUserName,
        householdId: householdId,
        notificationsService: _notificationsService,
      );

      // שמירה ב-Firebase
      await provider.updateList(updatedList);

      if (mounted) {
        // 🔧 עדכון הרשימה המקומית לפני רענון המשתמשים
        _currentList = updatedList;
        _loadUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.userRemovedSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError(strings.errorRemovingUser(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _editUserRole(SharedUser user) async {
    final strings = AppStrings.manageUsers;
    final userContext = context.read<UserContext>();
    final currentUserId = userContext.userId;

    // בדיקה שהמשתמש מחובר
    if (currentUserId == null) {
      _showError(strings.errorUserNotLoggedIn);
      return;
    }

    // בדיקת הרשאות - שימוש ב-_currentList
    if (!ShareListService.canUserManage(_currentList, currentUserId)) {
      _showError(strings.errorNoPermissionEditRole);
      return;
    }

    // בחירת תפקיד חדש
    final newRole = await showDialog<UserRole>(
      context: context,
      builder: (context) {
        final displayName = _getDisplayName(user);
        return AlertDialog(
          title: Text(strings.editRoleTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(strings.selectNewRole(displayName)),
              const SizedBox(height: kSpacingMedium),
              ...UserRole.values
                  .where((role) => role != UserRole.owner)
                  .map((role) => ListTile(
                        leading: Text(
                          role.emoji,
                          style: const TextStyle(fontSize: kFontSizeTitle),
                        ),
                        title: Text(role.hebrewName),
                        onTap: () => Navigator.of(context).pop(role),
                      )),
            ],
          ),
        );
      },
    );

    if (newRole == null || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final currentUserName = userContext.displayName ?? strings.defaultUserName;
      final householdId = userContext.householdId;
      final provider = context.read<ShoppingListsProvider>();

      // בדיקה שיש householdId
      if (householdId == null) {
        _showError(strings.errorNoHousehold);
        return;
      }

      final updatedList = await ShareListService.updateUserRole(
        list: _currentList, // 🔧 שימוש ב-_currentList
        currentUserId: currentUserId,
        targetUserId: user.userId,
        newRole: newRole,
        changerName: currentUserName,
        householdId: householdId,
        notificationsService: _notificationsService,
      );

      // שמירה ב-Firebase
      await provider.updateList(updatedList);

      if (mounted) {
        // 🔧 עדכון הרשימה המקומית לפני רענון המשתמשים
        _currentList = updatedList;
        _loadUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.roleUpdatedSuccess(newRole.hebrewName))),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError(strings.errorUpdatingRole(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    final cs = Theme.of(context).colorScheme;
    // SnackBar בלבד - לשגיאות פעולה (remove/editRole).
    // _errorMessage משמש רק לשגיאות טעינה ראשוניות.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: cs.error,
      ),
    );
  }

  Future<void> _inviteUser() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => InviteUsersScreen(list: _currentList),
      ),
    );

    // 🔧 רענון תמיד אחרי חזרה מהזמנה
    // כי ייתכן שהוזמנו משתמשים (הזמנות ממתינות, לא sharedUsers)
    if (mounted) {
      // משיכת הרשימה העדכנית מה-Provider
      final provider = context.read<ShoppingListsProvider>();
      final updatedList = provider.getById(_currentList.id);
      if (updatedList != null) {
        _currentList = updatedList;
      }
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.manageUsers;
    final userContext = context.watch<UserContext>();
    final currentUserId = userContext.userId;

    final cs = Theme.of(context).colorScheme;

    // אם המשתמש לא מחובר - הצג שגיאה
    if (currentUserId == null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Stack(
            children: [
              const NotebookBackground(),
              SafeArea(
                child: Column(
                  children: [
                    // 🏷️ כותרת inline
                    Padding(
                      padding: const EdgeInsets.all(kSpacingMedium),
                      child: Row(
                        children: [
                          Icon(Icons.group, size: kIconSizeMedium, color: cs.primary),
                          const SizedBox(width: kSpacingSmall),
                          Expanded(
                            child: Text(
                              strings.title,
                              style: TextStyle(
                                fontSize: kFontSizeLarge,
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: kIconSizeXXLarge,
                              color: cs.error.withValues(alpha: 0.7),
                            ),
                            const SizedBox(height: kSpacingMedium),
                            Text(
                              strings.errorUserNotLoggedIn,
                              style: const TextStyle(fontSize: kFontSizeTitle),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isOwner = ShareListService.canUserManage(_currentList, currentUserId);

    return Stack(
      children: [
        const NotebookBackground(),
        Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // 🏷️ כותרת inline
              Padding(
                padding: const EdgeInsets.all(kSpacingMedium),
                child: Row(
                  children: [
                    Icon(Icons.group, size: kIconSizeMedium, color: cs.primary),
                    const SizedBox(width: kSpacingSmall),
                    Expanded(
                      child: Text(
                        strings.title,
                        style: TextStyle(
                          fontSize: kFontSizeLarge,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildBody(isOwner)),
            ],
          ),
        ),
        floatingActionButton: isOwner
            ? FloatingActionButton.extended(
                heroTag: 'manage_users_fab',
                onPressed: _inviteUser,
                icon: const Icon(Icons.person_add),
                label: Text(strings.inviteUser),
              )
            : null,
      ),
    ),
      ],
    );
  }

  Widget _buildBody(bool isOwner) {
    final cs = Theme.of(context).colorScheme;
    final strings = AppStrings.manageUsers;

    if (_isLoading) {
      return const AppLoadingSkeleton(sectionCount: 3, showHero: false);
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: kSpacingMedium),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: kFontSizeBody),
            ),
            const SizedBox(height: kSpacingMedium),
            FilledButton.icon(
              onPressed: _loadUsers,
              icon: const Icon(Icons.refresh),
              label: Text(strings.retryButton),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: kIconSizeXXLarge,
              color: cs.outline.withValues(alpha: 0.5),
            ),
            SizedBox(height: kSpacingMedium),
            Text(
              strings.noSharedUsers,
              style: TextStyle(fontSize: kFontSizeTitle),
            ),
            SizedBox(height: kSpacingSmall),
            // 🔧 טקסט שונה לפי הרשאות
            Text(
              isOwner ? strings.inviteUsersHint : strings.onlyOwnerCanInvite,
              style: TextStyle(color: cs.outline),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(kSpacingMedium),
      itemCount: _users.length,
      separatorBuilder: (_, _) => const SizedBox(height: kSpacingSmall),
      itemBuilder: (context, index) {
        final user = _users[index];
        return _buildUserCard(user, isOwner);
      },
    );
  }

  Widget _buildUserCard(SharedUser user, bool isOwner) {
    final cs = Theme.of(context).colorScheme;
    final strings = AppStrings.manageUsers;
    final userContext = context.read<UserContext>();
    final isUserOwner = user.role == UserRole.owner;
    final isCurrentUser = user.userId == userContext.userId;
    final displayName = _getDisplayName(user);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user.role).withValues(alpha: 0.3),
          child: Text(
            user.role.emoji,
            style: const TextStyle(fontSize: kFontSizeTitle),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                displayName,
                style: const TextStyle(
                  fontSize: kFontSizeBody,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isCurrentUser)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                ),
                child: Text(
                  strings.you,
                  style: TextStyle(
                    fontSize: kFontSizeSmall,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.role.hebrewName,
              style: TextStyle(
                color: _getRoleColor(user.role),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (user.userEmail != null)
              Text(
                user.userEmail!,
                style: TextStyle(fontSize: kFontSizeSmall, color: cs.outline),
              ),
          ],
        ),
        trailing: isOwner && !isUserOwner
            ? PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: kSpacingSmall),
                        Text(strings.editRole),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: cs.error),
                        SizedBox(width: kSpacingSmall),
                        Text(strings.removeUser, style: TextStyle(color: cs.error)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _editUserRole(user);
                    case 'remove':
                      _removeUser(user);
                  }
                },
              )
            : null,
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    final cs = Theme.of(context).colorScheme;
    switch (role) {
      case UserRole.owner:
        return cs.tertiary;
      case UserRole.admin:
        return cs.tertiary;
      case UserRole.editor:
        return cs.primary;
      case UserRole.viewer:
      case UserRole.unknown:
        return cs.outline;
    }
  }
}
