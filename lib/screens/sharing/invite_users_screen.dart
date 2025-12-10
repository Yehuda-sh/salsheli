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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memozap/l10n/app_strings.dart';
import 'package:memozap/models/enums/user_role.dart';
import 'package:memozap/models/saved_contact.dart';
import 'package:memozap/models/shopping_list.dart';
import 'package:memozap/providers/user_context.dart';
import 'package:memozap/services/notifications_service.dart';
import 'package:memozap/services/pending_invites_service.dart';
import 'package:memozap/services/saved_contacts_service.dart';
import 'package:memozap/widgets/common/notebook_background.dart';
import 'package:memozap/widgets/common/sticky_button.dart';
import 'package:memozap/widgets/common/sticky_note.dart';
import 'package:provider/provider.dart';

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
  late final SavedContactsService _savedContactsService;
  late final PendingInvitesService _pendingInvitesService;

  UserRole _selectedRole = UserRole.editor; // Default to Editor
  bool _isLoading = false;
  bool _isLoadingContacts = true;

  // 📇 Saved contacts
  List<SavedContact> _savedContacts = [];
  SavedContact? _selectedSavedContact;

  @override
  void initState() {
    super.initState();
    debugPrint('📝 InviteUsersScreen: פתיחת מסך הזמנת משתמשים');

    final userContext = context.read<UserContext>();
    _notificationsService = NotificationsService(FirebaseFirestore.instance);
    _savedContactsService = SavedContactsService();
    _pendingInvitesService = PendingInvitesService();

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
    } else {
      // 📇 Load saved contacts
      _loadSavedContacts();
    }
  }

  /// טעינת אנשי קשר שמורים
  Future<void> _loadSavedContacts() async {
    final userContext = context.read<UserContext>();
    final currentUserId = userContext.userId;

    if (currentUserId == null) return;

    try {
      final contacts = await _savedContactsService.getContacts(currentUserId);
      if (mounted) {
        setState(() {
          _savedContacts = contacts;
          _isLoadingContacts = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading saved contacts: $e');
      if (mounted) {
        setState(() => _isLoadingContacts = false);
      }
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
    // 📇 Saved contact selected
    final bool usingSavedContact = _selectedSavedContact != null;

    if (!usingSavedContact && !_formKey.currentState!.validate()) return;

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

      // Determine invited user details
      final String invitedUserId;
      final String? invitedUserName;
      final String? invitedUserEmail;
      final String displayName;

      if (usingSavedContact) {
        // 📇 Saved contact
        invitedUserId = _selectedSavedContact!.userId;
        invitedUserName = _selectedSavedContact!.userName;
        invitedUserEmail = _selectedSavedContact!.userEmail;
        displayName = _selectedSavedContact!.displayName;
        debugPrint('📇 Inviting saved contact: $displayName ($invitedUserId)');
      } else {
        // ✉️ Email input
        invitedUserId = _emailController.text.trim();
        invitedUserName = null;
        invitedUserEmail = _emailController.text.trim();
        displayName = _emailController.text.trim();
      }

      // יצירת הזמנה ממתינה - המוזמן יצטרך לאשר
      await _pendingInvitesService.createInvite(
        listId: widget.list.id,
        listName: widget.list.name,
        inviterId: currentUserId,
        inviterName: currentUserName,
        invitedUserId: invitedUserId,
        invitedUserEmail: invitedUserEmail,
        invitedUserName: invitedUserName,
        role: _selectedRole,
        householdId: householdId,
      );

      // שליחת התראה למוזמן
      await _notificationsService.createInviteNotification(
        userId: invitedUserId,
        householdId: householdId,
        listId: widget.list.id,
        listName: widget.list.name,
        inviterName: currentUserName,
        role: _selectedRole.hebrewName,
      );

      // 💾 Save contact for future use (or update last_invited_at)
      {
        try {
          await _savedContactsService.saveContact(
            currentUserId: currentUserId,
            contactUserId: invitedUserId,
            contactUserName: invitedUserName,
            contactUserEmail: invitedUserEmail,
          );
          debugPrint('💾 Contact saved: $displayName');
        } catch (e) {
          debugPrint('⚠️ Failed to save contact: $e');
          // Don't fail the invite if saving contact fails
        }
      }

      // Check if widget still mounted
      if (!mounted) return;

      // Success - show message and go back
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'הזמנה נשלחה ל$displayName - ממתינה לאישור',
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

                      // 📇 Saved Contacts Section
                      if (_savedContacts.isNotEmpty) ...[
                        StickyNote(
                          color: const Color(0xFFB3E5FC), // Light blue
                          rotation: 0.01,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Text('📇', style: TextStyle(fontSize: 20)),
                                    SizedBox(width: 8),
                                    Text(
                                      'אנשי קשר שמורים',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'בחר מאנשי קשר שהזמנת בעבר',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ..._savedContacts.map(_buildSavedContactOption),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Center(
                          child: Text(
                            '── או הזן אימייל חדש ──',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ] else if (_isLoadingContacts) ...[
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        ),
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
                                enabled: !_isLoading && _selectedSavedContact == null,
                                onChanged: (_) {
                                  // Clear selections when typing email
                                  if (_selectedSavedContact != null) {
                                    setState(() {
                                      _selectedSavedContact = null;
                                    });
                                  }
                                },
                              ),
                              if (_selectedSavedContact != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'איש קשר נבחר - האימייל לא ישמש',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue.shade700,
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
  // Saved Contact Option Widget
  // ============================================================

  Widget _buildSavedContactOption(SavedContact contact) {
    final isSelected = _selectedSavedContact?.userId == contact.userId;
    final isAlreadyShared = widget.list.sharedUsers.values.any((u) => u.userId == contact.userId);
    final isOwner = widget.list.createdBy == contact.userId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: (isAlreadyShared || isOwner || _isLoading)
            ? null
            : () {
                setState(() {
                  _selectedSavedContact = isSelected ? null : contact;
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
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Checkbox Icon
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected
                    ? Colors.blue
                    : (isAlreadyShared || isOwner)
                        ? Colors.grey
                        : Colors.black54,
              ),
              const SizedBox(width: 12),
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blue.shade100,
                child: contact.userAvatar != null
                    ? ClipOval(
                        child: Image.network(
                          contact.userAvatar!,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Text(
                            contact.initials,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        contact.initials,
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
                        Flexible(
                          child: Text(
                            contact.displayName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: (isAlreadyShared || isOwner) ? Colors.grey : Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                    if (contact.userName != null)
                      Text(
                        contact.userEmail,
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
