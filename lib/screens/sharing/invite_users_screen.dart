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
// Version 2.0 - No AppBar (Immersive)
// Last Updated: 13/01/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/enums/user_role.dart';
import '../../models/saved_contact.dart';
import '../../models/shopping_list.dart';
import '../../providers/user_context.dart';
import '../../repositories/firebase_user_repository.dart';
import '../../services/notifications_service.dart';
import '../../services/pending_invites_service.dart';
import '../../services/saved_contacts_service.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_button.dart';
import '../../widgets/common/sticky_note.dart';

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
  bool _showAllContacts = false; // הצגת כל אנשי הקשר (pagination)
  static const int _initialContactsToShow = 3; // כמה להציג בהתחלה

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
                  const Icon(Icons.block, color: kStickyPink),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(AppStrings.sharing.noPermissionInvite),
                  ),
                ],
              ),
              backgroundColor: kStickyPink,
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

  /// מחזיר רשימת אנשי קשר לתצוגה (עם pagination)
  List<SavedContact> _getVisibleContacts() {
    if (_showAllContacts || _savedContacts.length <= _initialContactsToShow) {
      return _savedContacts;
    }
    return _savedContacts.take(_initialContactsToShow).toList();
  }

  /// טקסט אישור - מסביר מה יקרה בלחיצה על "הזמן"
  String _getConfirmationText() {
    final String recipient;
    if (_selectedSavedContact != null) {
      recipient = _selectedSavedContact!.displayName;
    } else {
      recipient = _emailController.text.trim();
    }

    final roleName = _selectedRole.hebrewName;
    return AppStrings.sharing.inviteConfirmation(recipient, roleName, widget.list.name);
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
      final String? invitedUserId;
      final String? invitedUserName;
      final String invitedUserEmail;
      final String displayName;
      bool userExists = true; // האם המשתמש רשום באפליקציה

      if (usingSavedContact) {
        // 📇 Saved contact - יש לנו כבר את ה-UID
        final contact = _selectedSavedContact!;
        invitedUserId = contact.userId;
        invitedUserName = contact.userName;
        invitedUserEmail = contact.userEmail;
        displayName = contact.displayName;
        debugPrint('📇 Inviting saved contact: $displayName ($invitedUserId)');
      } else {
        // ✉️ Email input - צריך לחפש את המשתמש לפי אימייל
        invitedUserEmail = _emailController.text.trim().toLowerCase();
        displayName = invitedUserEmail;

        // 🔍 חיפוש המשתמש לפי אימייל כדי לקבל את ה-UID האמיתי
        final userRepository = FirebaseUserRepository();
        final foundUser = await userRepository.findByEmail(invitedUserEmail);

        if (foundUser != null) {
          // ✅ משתמש נמצא - משתמשים ב-UID שלו
          invitedUserId = foundUser.id;
          invitedUserName = foundUser.name;
          debugPrint('✅ Found user by email: ${foundUser.name} (${foundUser.id})');
        } else {
          // ⚠️ משתמש לא רשום - שומרים הזמנה לפי אימייל
          invitedUserId = null;
          invitedUserName = null;
          userExists = false;
          debugPrint('⚠️ User not registered yet: $invitedUserEmail');
        }
      }

      // יצירת הזמנה ממתינה - המוזמן יצטרך לאשר
      // 🔧 אם אין UID, משתמשים באימייל כמזהה (המשתמש עדיין לא רשום)
      await _pendingInvitesService.createInvite(
        listId: widget.list.id,
        listName: widget.list.name,
        inviterId: currentUserId,
        inviterName: currentUserName,
        invitedUserId: invitedUserId ?? invitedUserEmail, // אימייל כ-fallback
        invitedUserEmail: invitedUserEmail,
        invitedUserName: invitedUserName,
        role: _selectedRole,
        householdId: householdId,
      );

      // שליחת התראה למוזמן - רק אם המשתמש רשום
      if (userExists && invitedUserId != null) {
        await _notificationsService.createInviteNotification(
          userId: invitedUserId,
          householdId: householdId,
          listId: widget.list.id,
          listName: widget.list.name,
          inviterName: currentUserName,
          role: _selectedRole.hebrewName,
        );
      }

      // 💾 Save contact for future use (or update last_invited_at)
      // רק אם יש UID אמיתי (לא אימייל)
      if (userExists && invitedUserId != null) {
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
      final successMessage = userExists
          ? AppStrings.sharing.inviteSentPending(displayName)
          : AppStrings.sharing.inviteSentUnregistered(displayName);

      messenger.showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: userExists ? kStickyGreen : kStickyOrange,
        ),
      );

      navigator.pop(true); // 🔧 מחזיר true לסימון הצלחה
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.sharing.inviteError(e.toString())),
          backgroundColor: kStickyPink,
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
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kPaperBackground,
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
                      // 🏷️ כותרת inline
                      Padding(
                        padding: const EdgeInsets.only(bottom: kSpacingMedium),
                        child: Row(
                          children: [
                            Icon(Icons.person_add, size: 24, color: cs.primary),
                            const SizedBox(width: kSpacingSmall),
                            Expanded(
                              child: Text(
                                AppStrings.sharing.inviteTitle,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                          color: kStickyCyan,
                          rotation: 0.01,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('📇', style: TextStyle(fontSize: 20)),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppStrings.sharing.savedContactsTitle,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppStrings.sharing.savedContactsSubtitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // 📄 Pagination: הצגת 3 אנשי קשר ראשונים + "הצג עוד"
                                ..._getVisibleContacts().map(_buildSavedContactOption),
                                if (_savedContacts.length > _initialContactsToShow && !_showAllContacts)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Center(
                                      child: TextButton.icon(
                                        onPressed: () => setState(() => _showAllContacts = true),
                                        icon: const Icon(Icons.expand_more, size: 18),
                                        label: Text(
                                          AppStrings.sharing.showMoreContacts(_savedContacts.length - _initialContactsToShow),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            AppStrings.sharing.orEnterNewEmail,
                            style: const TextStyle(
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
                        color: kStickyYellow,
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
                                    AppStrings.sharing.contactSelectedEmailDisabled,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: cs.primary,
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
                        color: kStickyCyan,
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

                      const SizedBox(height: 16),

                      // 📝 Confirmation Text - מה יקרה בלחיצה
                      if (_selectedSavedContact != null ||
                          _emailController.text.trim().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(kSpacingSmall),
                          margin: const EdgeInsets.only(bottom: kSpacingMedium),
                          decoration: BoxDecoration(
                            color: kStickyGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                            border: Border.all(
                              color: kStickyGreen.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: kStickyGreen.withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: kSpacingSmall),
                              Expanded(
                                child: Text(
                                  _getConfirmationText(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

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
                              color: kStickyGreen,
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
    final cs = Theme.of(context).colorScheme;
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
              color: isSelected ? cs.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Checkbox Icon
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected
                    ? cs.primary
                    : (isAlreadyShared || isOwner)
                        ? Colors.grey
                        : Colors.black54,
              ),
              const SizedBox(width: 12),
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: cs.primaryContainer,
                child: contact.userAvatar != null
                    ? ClipOval(
                        child: Image.network(
                          contact.userAvatar!,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Text(
                            contact.initials,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        contact.initials,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
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
                              color: (isAlreadyShared || isOwner) ? Colors.grey : cs.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isOwner) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: kStickyPurple.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              AppStrings.sharing.roleOwner,
                              style: TextStyle(fontSize: 10, color: kStickyPurple.withValues(alpha: 0.8)),
                            ),
                          ),
                        ],
                        if (isAlreadyShared && !isOwner) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: kStickyOrange.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              AppStrings.sharing.alreadySharedBadge,
                              style: TextStyle(fontSize: 10, color: kStickyOrange.withValues(alpha: 0.8)),
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
                          color: (isAlreadyShared || isOwner) ? Colors.grey : cs.onSurfaceVariant,
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
    final cs = Theme.of(context).colorScheme;
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: _isLoading ? null : () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? cs.outline : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Radio Icon
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? cs.onSurface : Colors.grey,
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
