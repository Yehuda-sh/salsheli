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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memozap/l10n/app_strings.dart';
import 'package:memozap/models/enums/user_role.dart';
import 'package:memozap/models/shopping_list.dart';
import 'package:memozap/providers/user_context.dart';
import 'package:memozap/services/notifications_service.dart';
import 'package:memozap/services/share_list_service.dart';
import 'package:memozap/widgets/common/notebook_background.dart';
import 'package:memozap/widgets/common/sticky_button.dart';
import 'package:memozap/widgets/common/sticky_note.dart';
import 'package:provider/provider.dart';

/// 🧪 Demo users for development/testing
/// These can be used to test sharing functionality without real users
class _DemoUser {
  final String id;
  final String name;
  final String email;

  const _DemoUser({
    required this.id,
    required this.name,
    required this.email,
  });
}

const List<_DemoUser> _demoUsers = [
  _DemoUser(
    id: 'user_001_demo',
    name: 'שרה כהן',
    email: 'sarah.cohen@demo.memozap.com',
  ),
  _DemoUser(
    id: 'user_002_demo',
    name: 'דוד כהן',
    email: 'david.cohen@demo.memozap.com',
  ),
  _DemoUser(
    id: 'user_003_demo',
    name: 'מיכל לוי',
    email: 'michal.levi@demo.memozap.com',
  ),
  _DemoUser(
    id: 'user_004_demo',
    name: 'אביב מזרחי',
    email: 'aviv.mizrahi@demo.memozap.com',
  ),
  _DemoUser(
    id: 'user_005_demo',
    name: 'נועה מזרחי',
    email: 'noa.mizrahi@demo.memozap.com',
  ),
];

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
  late final NotificationsService _notificationsService;

  UserRole _selectedRole = UserRole.editor; // Default to Editor
  bool _isLoading = false;

  // 🧪 Demo mode - select from predefined demo users
  _DemoUser? _selectedDemoUser;

  @override
  void initState() {
    super.initState();
    debugPrint('📝 InviteUsersScreen: פתיחת מסך הזמנת משתמשים');

    final userContext = context.read<UserContext>();
    _notificationsService = NotificationsService(FirebaseFirestore.instance);

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
    // 🧪 In debug mode with demo user selected, skip email validation
    final bool usingDemoUser = kDebugMode && _selectedDemoUser != null;

    if (!usingDemoUser && !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Capture context before async
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      final userContext = context.read<UserContext>();
      final currentUserId = userContext.userId;
      final currentUserName = userContext.user?.name ?? 'משתמש';
      final householdId = userContext.householdId;

      // Validate user is logged in
      if (currentUserId == null) {
        throw Exception('user_not_logged_in');
      }

      // Validate household ID exists
      if (householdId == null) {
        throw Exception('household_not_found');
      }

      // 🧪 Use demo user ID or email input
      final String invitedUserId;
      final String? invitedUserName;
      final String displayName;

      if (usingDemoUser) {
        invitedUserId = _selectedDemoUser!.id;
        invitedUserName = _selectedDemoUser!.name;
        displayName = _selectedDemoUser!.name;
        debugPrint('🧪 Inviting demo user: $invitedUserName ($invitedUserId)');
      } else {
        invitedUserId = _emailController.text.trim();
        invitedUserName = null;
        displayName = _emailController.text.trim();
      }

      // Call static method with NotificationsService
      await ShareListService.inviteUser(
        list: widget.list,
        currentUserId: currentUserId,
        invitedUserId: invitedUserId,
        role: _selectedRole,
        inviterName: currentUserName,
        householdId: householdId,
        notificationsService: _notificationsService,
        userName: invitedUserName,
      );

      // TODO: Update list in Firebase/Provider

      // Check if widget still mounted
      if (!mounted) return;

      // Success - show message and go back
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.sharing.inviteSent(displayName),
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

                      // 🧪 Demo User Selection (Debug Mode Only)
                      if (kDebugMode) ...[
                        StickyNote(
                          color: const Color(0xFFFFCDD2), // Light red for demo
                          rotation: 0.02,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Text('🧪', style: TextStyle(fontSize: 20)),
                                    SizedBox(width: 8),
                                    Text(
                                      'בחר משתמש דמו (מצב פיתוח)',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ..._demoUsers.map(_buildDemoUserOption),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Center(
                          child: Text(
                            '── או הזן אימייל ידנית ──',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

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
                                enabled: !_isLoading && _selectedDemoUser == null,
                                onChanged: (_) {
                                  // Clear demo user selection when typing email
                                  if (_selectedDemoUser != null) {
                                    setState(() => _selectedDemoUser = null);
                                  }
                                },
                              ),
                              if (_selectedDemoUser != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'משתמש דמו נבחר - האימייל לא ישמש',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange.shade700,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
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
                              label: AppStrings.sharing.cancelButton,
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
                              label: _isLoading
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
  // Demo User Option Widget (Debug Mode Only)
  // ============================================================

  Widget _buildDemoUserOption(_DemoUser user) {
    final isSelected = _selectedDemoUser?.id == user.id;
    final isAlreadyShared = widget.list.sharedUsers.any((u) => u.userId == user.id);
    final isOwner = widget.list.createdBy == user.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: (isAlreadyShared || isOwner || _isLoading)
            ? null
            : () {
                setState(() {
                  _selectedDemoUser = isSelected ? null : user;
                  if (!isSelected) {
                    _emailController.clear();
                  }
                });
              },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : (isAlreadyShared || isOwner)
                    ? Colors.grey.shade200
                    : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.green : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Checkbox Icon
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected
                    ? Colors.green
                    : (isAlreadyShared || isOwner)
                        ? Colors.grey
                        : Colors.black54,
              ),
              const SizedBox(width: 12),
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  user.name.substring(0, 1),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: (isAlreadyShared || isOwner) ? Colors.grey : Colors.black,
                          ),
                        ),
                        if (isOwner) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'בעלים',
                              style: TextStyle(fontSize: 10, color: Colors.purple),
                            ),
                          ),
                        ],
                        if (isAlreadyShared && !isOwner) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'כבר שותף',
                              style: TextStyle(fontSize: 10, color: Colors.orange),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 11,
                        color: (isAlreadyShared || isOwner) ? Colors.grey : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
