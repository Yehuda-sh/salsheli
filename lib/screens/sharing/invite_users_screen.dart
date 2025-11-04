// 📄 File: lib/screens/sharing/invite_users_screen.dart
//
// 🎯 מטרה: מסך הזמנת משתמשים לרשימה משותפת (Phase 3B)
//
// 🔐 הרשאות: רק Owner יכול להזמין משתמשים
//
// 📝 תהליך:
// 1. בעלים מזין email + בוחר role
// 2. ShareListService.inviteUser()
// 3. משתמש מקבל התראה
// 4. משתמש מתווסף לשותפים ברשימה
//
// Version: 1.0
// Last Updated: 03/11/2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:memozap/l10n/app_strings.dart';
import 'package:memozap/models/shopping_list.dart';
import 'package:memozap/models/user_role.dart';
import 'package:memozap/providers/user_context.dart';
import 'package:memozap/services/share_list_service.dart';
import 'package:memozap/widgets/common/notebook_background.dart';
import 'package:memozap/widgets/common/sticky_button.dart';
import 'package:memozap/widgets/common/sticky_note.dart';

class InviteUsersScreen extends StatefulWidget {
  final ShoppingList list;

  const InviteUsersScreen({
    required this.list,
    super.key,
  });

  @override
  State<InviteUsersScreen> createState() => _InviteUsersScreenState();
}

class _InviteUsersScreenState extends State<InviteUsersScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late final ShareListService _shareService;

  UserRole _selectedRole = UserRole.editor; // Default to Editor
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    debugPrint('📝 InviteUsersScreen: פתיחת מסך הזמנת משתמשים');

    final userContext = context.read<UserContext>();
    _shareService = ShareListService(userContext);

    // 🔒 Validation: רק Owner יכול להזמין
    final currentUserId = userContext.userId;
    final isOwner = widget.list.createdBy == currentUserId;

    if (!isOwner) {
      debugPrint('⛔ InviteUsersScreen: אין הרשאה - רק Owner יכול להזמין');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);

          messenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.block, color: Color(0xFFF48FB1)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(AppStrings.sharing.noPermissionInvite),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFF48FB1),
            ),
          );

          navigator.pop();
        }
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // ============================================================
  // Invite User
  // ============================================================

  Future<void> _inviteUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Capture context before async
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      await _shareService.inviteUser(
        widget.list,
        _emailController.text.trim(),
        _selectedRole,
      );

      // Check if widget still mounted
      if (!mounted) return;

      // Success - show message and go back
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.sharing.inviteSent(_emailController.text.trim()),
          ),
          backgroundColor: Colors.green,
        ),
      );

      navigator.pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.sharing.inviteError(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ============================================================
  // Email Validator
  // ============================================================

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.sharing.emailRequired;
    }

    // Basic email regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return AppStrings.sharing.emailInvalid;
    }

    return null;
  }

  // ============================================================
  // Build UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text(AppStrings.sharing.inviteTitle),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            const NotebookBackground(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Subtitle
                      Text(
                        AppStrings.sharing.inviteSubtitle,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // Email Field (StickyNote Yellow)
                      StickyNote(
                        color: const Color(0xFFFFF59D), // kStickyYellow
                        rotation: 0.01,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.sharing.emailLabel,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textDirection: TextDirection.ltr,
                                decoration: InputDecoration(
                                  hintText: AppStrings.sharing.emailHint,
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator: _validateEmail,
                                enabled: !_isLoading,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Role Selector (StickyNote Cyan)
                      StickyNote(
                        color: const Color(0xFF80DEEA), // kStickyCyan
                        rotation: -0.01,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.sharing.selectRoleLabel,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Admin Option
                              _buildRoleOption(
                                role: UserRole.admin,
                                icon: '👨‍💼',
                                label: AppStrings.sharing.roleAdmin,
                                description: AppStrings.sharing.roleAdminDesc,
                              ),

                              const SizedBox(height: 8),

                              // Editor Option (Default)
                              _buildRoleOption(
                                role: UserRole.editor,
                                icon: '✏️',
                                label: AppStrings.sharing.roleEditor,
                                description: AppStrings.sharing.roleEditorDesc,
                              ),

                              const SizedBox(height: 8),

                              // Viewer Option
                              _buildRoleOption(
                                role: UserRole.viewer,
                                icon: '👁️',
                                label: AppStrings.sharing.roleViewer,
                                description: AppStrings.sharing.roleViewerDesc,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          // Cancel Button
                          Expanded(
                            child: StickyButton(
                              text: AppStrings.sharing.cancelButton,
                              color: Colors.grey,
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.pop(context),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Invite Button
                          Expanded(
                            flex: 2,
                            child: StickyButton(
                              text: _isLoading
                                  ? AppStrings.sharing.inviting
                                  : AppStrings.sharing.inviteButton,
                              color: const Color(0xFFA5D6A7), // kStickyGreen
                              onPressed: _isLoading ? null : _inviteUser,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Role Option Widget
  // ============================================================

  Widget _buildRoleOption({
    required UserRole role,
    required String icon,
    required String label,
    required String description,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: _isLoading ? null : () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Radio Icon
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.black : Colors.grey,
            ),

            const SizedBox(width: 12),

            // Emoji
            Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),

            const SizedBox(width: 12),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
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
}
