// 📄 File: lib/widgets/dialogs/invite_user_dialog.dart
//
// 🇮🇱 דיאלוג הזמנת משתמש חדש:
//     - הזנת email
//     - בחירת תפקיד (Admin/Editor/Viewer)
//     - Validation
//     - שליחת הזמנה
//
// 🎨 UI:
//     - Sticky Notes Design
//     - RTL Support
//     - Loading State
//     - Error Handling
//
// גרסה: v1.0 | תאריך: 02/11/2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:memozap/core/ui_constants.dart';
import 'package:memozap/models/enums/user_role.dart';
import 'package:memozap/models/shopping_list.dart';
import 'package:memozap/providers/shopping_lists_provider.dart';
import 'package:memozap/providers/user_context.dart';
import 'package:memozap/services/share_list_service.dart';
import 'package:memozap/widgets/common/sticky_button.dart';

/// 🇮🇱 דיאלוג הזמנת משתמש חדש
/// 🇬🇧 Invite user dialog
class InviteUserDialog extends StatefulWidget {
  final ShoppingList list;

  const InviteUserDialog({
    required this.list,
    super.key,
  });

  @override
  State<InviteUserDialog> createState() => _InviteUserDialogState();
}

class _InviteUserDialogState extends State<InviteUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  UserRole _selectedRole = UserRole.editor; // ברירת מחדל: Editor
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _inviteUser() async {
    // בדיקת Validation
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userContext = context.read<UserContext>();
    final currentUserId = userContext.userId;

    if (currentUserId == null) {
      _showError('שגיאה: משתמש לא מחובר');
      return;
    }

    // בדיקת הרשאות
    if (!ShareListService.canUserManage(widget.list, currentUserId)) {
      _showError('אין לך הרשאה להזמין משתמשים');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();

      // בדיקה שהמשתמש לא מזמין את עצמו
      if (email.toLowerCase() == userContext.userEmail?.toLowerCase()) {
        throw Exception('לא ניתן להזמין את עצמך');
      }

      // TODO: בעתיד - לבדוק אם המשתמש כבר קיים במערכת
      // ולקבל את userId שלו מה-Firebase Authentication

      // כרגע - נשתמש ב-email כ-userId (זמני)
      final invitedUserId = email.toLowerCase();

      // הוספת המשתמש לרשימה
      final updatedList = ShareListService.inviteUser(
        list: widget.list,
        currentUserId: currentUserId,
        invitedUserId: invitedUserId,
        userEmail: email,
        role: _selectedRole,
      );

      // שמירה ב-Firebase
      if (mounted) {
        await context.read<ShoppingListsProvider>().updateList(updatedList);

        // הצלחה!
        if (mounted) {
          Navigator.of(context).pop(true); // סגירת הדיאלוג עם הצלחה
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ המשתמש $email הוזמן בהצלחה כ-${_selectedRole.hebrewName}'),
              backgroundColor: kStickyGreen,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.person_add, color: kStickyGreen),
            SizedBox(width: kSpacingSmall),
            Text('הזמנת משתמש חדש'),
          ],
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'אימייל המשתמש',
                    hintText: 'example@email.com',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'שדה חובה';
                    }
                    // בדיקת פורמט אימייל בסיסית
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                      return 'אימייל לא תקין';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: kSpacingMedium),

                // Role Selector
                DropdownButtonFormField<UserRole>(
                  initialValue: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'תפקיד',
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    UserRole.admin,
                    UserRole.editor,
                    UserRole.viewer,
                  ].map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Row(
                        children: [
                          Text(role.emoji, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: kSpacingSmall),
                          Text(role.hebrewName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: _isLoading
                      ? null
                      : (UserRole? newRole) {
                          if (newRole != null) {
                            setState(() => _selectedRole = newRole);
                          }
                        },
                ),

                const SizedBox(height: kSpacingSmall),

                // Role Description
                Container(
                  padding: const EdgeInsets.all(kSpacingSmall),
                  decoration: BoxDecoration(
                    color: _getRoleColor(_selectedRole).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getRoleColor(_selectedRole).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _getRoleDescription(_selectedRole),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),

                // Error Message
                if (_errorMessage != null) ...[
                  const SizedBox(height: kSpacingMedium),
                  Container(
                    padding: const EdgeInsets.all(kSpacingSmall),
                    decoration: BoxDecoration(
                      color: kStickyPink.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kStickyPink),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: kStickyPink, size: 20),
                        const SizedBox(width: kSpacingSmall),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: kStickyPink,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
            child: const Text('ביטול'),
          ),

          // Send Invite Button
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: kSpacingMedium),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : StickyButton(
                  label: 'שלח הזמנה',
                  color: kStickyGreen,
                  onPressed: _inviteUser,
                ),
        ],
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

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return '👑 בעלים - גישה מלאה לכל הפעולות';
      case UserRole.admin:
        return '⭐ מנהל - יכול לאשר בקשות ולנהל משתמשים';
      case UserRole.editor:
        return '✏️ עורך - יכול ליצור בקשות להוספת פריטים';
      case UserRole.viewer:
        return '👁️ צופה - צפייה בלבד, ללא עריכה';
    }
  }
}

/// 🇮🇱 פונקציה עוזרת להצגת הדיאלוג
/// 🇬🇧 Helper function to show the dialog
Future<bool?> showInviteUserDialog(
  BuildContext context,
  ShoppingList list,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) => InviteUserDialog(list: list),
  );
}
