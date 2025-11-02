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
// גרסה: v1.0 | תאריך: 02/11/2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:memozap/core/ui_constants.dart';
import 'package:memozap/models/shared_user.dart';
import 'package:memozap/models/enums/user_role.dart';
import 'package:memozap/models/shopping_list.dart';
import 'package:memozap/providers/shopping_lists_provider.dart';
import 'package:memozap/providers/user_context.dart';
import 'package:memozap/services/share_list_service.dart';
import 'package:memozap/widgets/common/notebook_background.dart';
import 'package:memozap/widgets/common/sticky_button.dart';

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
  late List<SharedUser> _users;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _users = ShareListService.getUsersForList(widget.list);
    });
  }

  // Helper: מחזיר שם תצוגה (תמיד String, לא nullable)
  String _getDisplayName(SharedUser user) {
    return user.userName ?? user.userId;
  }

  Future<void> _removeUser(SharedUser user) async {
    final userContext = context.read<UserContext>();
    final currentUserId = userContext.userId;

    // בדיקה שהמשתמש מחובר
    if (currentUserId == null) {
      _showError('שגיאה: משתמש לא מחובר');
      return;
    }

    // בדיקת הרשאות
    if (!ShareListService.canUserManage(widget.list, currentUserId)) {
      _showError('אין לך הרשאה להסיר משתמשים');
      return;
    }

    // אישור מהמשתמש
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final displayName = _getDisplayName(user);
        return AlertDialog(
          title: const Text('הסרת משתמש'),
          content: Text(
            'האם אתה בטוח שברצונך להסיר את $displayName?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('ביטול'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: kStickyPink,
              ),
              child: const Text('הסר'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final updatedList = ShareListService.removeUser(
        list: widget.list,
        currentUserId: currentUserId,
        removedUserId: user.userId,
      );

      // שמירה ב-Firebase
      await context.read<ShoppingListsProvider>().updateList(updatedList);

      if (mounted) {
        _loadUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('משתמש הוסר בהצלחה')),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('שגיאה בהסרת משתמש: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _editUserRole(SharedUser user) async {
    final userContext = context.read<UserContext>();
    final currentUserId = userContext.userId;

    // בדיקה שהמשתמש מחובר
    if (currentUserId == null) {
      _showError('שגיאה: משתמש לא מחובר');
      return;
    }

    // בדיקת הרשאות
    if (!ShareListService.canUserManage(widget.list, currentUserId)) {
      _showError('אין לך הרשאה לשנות תפקידים');
      return;
    }

    // בחירת תפקיד חדש
    final newRole = await showDialog<UserRole>(
      context: context,
      builder: (context) {
        final displayName = _getDisplayName(user);
        return AlertDialog(
          title: const Text('עריכת תפקיד'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('בחר תפקיד חדש עבור $displayName:'),
              const SizedBox(height: kSpacingMedium),
              ...UserRole.values
                  .where((role) => role != UserRole.owner)
                  .map((role) => ListTile(
                        leading: Text(
                          role.emoji,
                          style: const TextStyle(fontSize: 24),
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
      final updatedList = ShareListService.updateUserRole(
        list: widget.list,
        currentUserId: currentUserId,
        targetUserId: user.userId,
        newRole: newRole,
      );

      // שמירה ב-Firebase
      await context.read<ShoppingListsProvider>().updateList(updatedList);

      if (mounted) {
        _loadUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('התפקיד עודכן ל-${newRole.hebrewName}')),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('שגיאה בעדכון תפקיד: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: kStickyPink,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContext>();
    final currentUserId = userContext.userId;
    
    // אם המשתמש לא מחובר - הצג שגיאה
    if (currentUserId == null) {
      return Scaffold(
        backgroundColor: kPaperBackground,
        appBar: AppBar(
          title: const Text('ניהול משתמשים'),
          backgroundColor: kStickyYellow,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: kStickyPink.withValues(alpha: 0.7),
              ),
              const SizedBox(height: kSpacingMedium),
              const Text(
                'שגיאה: משתמש לא מחובר',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }
    
    final isOwner = ShareListService.canUserManage(widget.list, currentUserId);

    return Scaffold(
      backgroundColor: kPaperBackground,
      appBar: AppBar(
        title: const Text('ניהול משתמשים'),
        backgroundColor: kStickyYellow,
      ),
      body: Stack(
        children: [
          const NotebookBackground(),
          _buildBody(isOwner),
        ],
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
              onPressed: () {
                // TODO(UI): פתיחת Invite User Dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('הזמנת משתמשים תהיה זמינה בקרוב'),
                  ),
                );
              },
              backgroundColor: kStickyGreen,
              icon: const Icon(Icons.person_add),
              label: const Text('הזמן משתמש'),
            )
          : null,
    );
  }

  Widget _buildBody(bool isOwner) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: kSpacingMedium),
            Text('טוען משתמשים...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: kStickyPink.withValues(alpha: 0.7),
            ),
            const SizedBox(height: kSpacingMedium),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: kSpacingMedium),
            StickyButton(
              label: 'נסה שוב 🔄',
              color: kStickyCyan,
              onPressed: _loadUsers,
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
              size: 64,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: kSpacingMedium),
            const Text(
              'אין משתמשים משותפים',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: kSpacingSmall),
            const Text(
              'לחץ על + להזמנת משתמשים',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(kSpacingMedium),
      itemCount: _users.length,
      separatorBuilder: (_, __) => const SizedBox(height: kSpacingSmall),
      itemBuilder: (context, index) {
        final user = _users[index];
        return _buildUserCard(user, isOwner);
      },
    );
  }

  Widget _buildUserCard(SharedUser user, bool isOwner) {
    final isUserOwner = user.role == UserRole.owner;
    final displayName = _getDisplayName(user);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user.role).withValues(alpha: 0.3),
          child: Text(
            user.role.emoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        title: Text(
          displayName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
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
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        trailing: isOwner && !isUserOwner
            ? PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: kSpacingSmall),
                        Text('ערוך תפקיד'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: kStickyPink),
                        SizedBox(width: kSpacingSmall),
                        Text('הסר משתמש', style: TextStyle(color: kStickyPink)),
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
    switch (role) {
      case UserRole.owner:
        return kStickyYellow;
      case UserRole.admin:
        return kStickyPurple;
      case UserRole.editor:
        return kStickyCyan;
      case UserRole.viewer:
        return Colors.grey;
    }
  }
}
