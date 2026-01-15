// 📄 File: lib/screens/shopping/create/contact_selector_dialog.dart
//
// 🎯 Purpose: דיאלוג לבחירת אנשי קשר לשיתוף רשימה
//
// 📋 Features:
// - טעינת אנשי קשר שמורים (SavedContacts)
// - חיפוש לפי שם/אימייל
// - בחירת תפקיד (Admin/Editor/Viewer) לכל איש קשר
// - הוספת אימייל חדש (משתמש לא רשום)
//
// 🔗 Related:
// - create_list_screen.dart - מסך יצירת רשימה
// - selected_contact.dart - מודל איש קשר נבחר
// - saved_contacts_service.dart - שירות אנשי קשר שמורים
//
// Version: 1.0
// Created: 06/01/2026
// Last Updated: 13/01/2026

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/ui_constants.dart';
import '../../../models/enums/user_role.dart';
import '../../../models/saved_contact.dart';
import '../../../models/selected_contact.dart';
import '../../../providers/user_context.dart';
import '../../../repositories/firebase_user_repository.dart';
import '../../../services/saved_contacts_service.dart';

/// סוג קלט לאיש קשר חדש
enum _ContactInputType { email, phone }

/// דיאלוג לבחירת אנשי קשר לשיתוף רשימה
///
/// מחזיר List<SelectedContact> עם כל אנשי הקשר שנבחרו,
/// כולל התפקיד שלהם והאם הם רשומים או לא.
class ContactSelectorDialog extends StatefulWidget {
  /// אנשי קשר שכבר נבחרו (להצגה כ-selected)
  final List<SelectedContact> alreadySelected;

  const ContactSelectorDialog({
    super.key,
    this.alreadySelected = const [],
  });

  /// פותח את הדיאלוג ומחזיר את הבחירה
  static Future<List<SelectedContact>?> show(
    BuildContext context, {
    List<SelectedContact> alreadySelected = const [],
  }) {
    return showDialog<List<SelectedContact>>(
      context: context,
      builder: (_) => ContactSelectorDialog(alreadySelected: alreadySelected),
    );
  }

  @override
  State<ContactSelectorDialog> createState() => _ContactSelectorDialogState();
}

class _ContactSelectorDialogState extends State<ContactSelectorDialog> {
  final _searchController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _savedContactsService = SavedContactsService();
  final _userRepository = FirebaseUserRepository();

  List<SavedContact> _savedContacts = [];
  List<SelectedContact> _selectedContacts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _isAddingContact = false;
  bool _isCheckingContact = false;
  _ContactInputType _inputType = _ContactInputType.email;

  @override
  void initState() {
    super.initState();
    _selectedContacts = List.from(widget.alreadySelected);
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    final userId = context.read<UserContext>().user?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      final contacts = await _savedContactsService.getContacts(userId);
      if (mounted) {
        setState(() {
          _savedContacts = contacts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('❌ Error loading contacts: $e');
    }
  }

  /// סינון אנשי קשר לפי חיפוש
  List<SavedContact> get _filteredContacts {
    if (_searchQuery.isEmpty) return _savedContacts;
    final query = _searchQuery.toLowerCase();
    return _savedContacts.where((contact) {
      return contact.displayName.toLowerCase().contains(query) ||
          contact.userEmail.toLowerCase().contains(query);
    }).toList();
  }

  /// האם איש קשר כבר נבחר
  bool _isSelected(SavedContact contact) {
    return _selectedContacts.any((c) => c.email == contact.userEmail);
  }

  /// הוספה/הסרה של איש קשר
  void _toggleContact(SavedContact contact, UserRole role) {
    setState(() {
      final existingIndex =
          _selectedContacts.indexWhere((c) => c.email == contact.userEmail);
      if (existingIndex >= 0) {
        _selectedContacts.removeAt(existingIndex);
      } else {
        _selectedContacts
            .add(SelectedContact.fromSavedContact(contact, role: role));
      }
    });
  }

  /// עדכון תפקיד של איש קשר נבחר
  void _updateRole(String email, UserRole newRole) {
    setState(() {
      final index = _selectedContacts.indexWhere((c) => c.email == email);
      if (index >= 0) {
        _selectedContacts[index] =
            _selectedContacts[index].copyWith(role: newRole);
      }
    });
  }

  /// הסרת איש קשר נבחר
  void _removeSelected(String email) {
    setState(() {
      _selectedContacts.removeWhere((c) => c.email == email);
    });
  }

  /// הוספת איש קשר חדש (אימייל או טלפון)
  Future<void> _addNewContact() async {
    if (_inputType == _ContactInputType.email) {
      await _addByEmail();
    } else {
      await _addByPhone();
    }
  }

  /// הוספה לפי אימייל
  Future<void> _addByEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('נא להזין אימייל תקין')),
      );
      return;
    }

    // בדוק אם כבר נבחר
    if (_selectedContacts.any((c) => c.email == email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('איש קשר זה כבר נבחר')),
      );
      return;
    }

    setState(() => _isCheckingContact = true);

    try {
      // חפש משתמש רשום
      final user = await _userRepository.findByEmail(email);

      if (mounted) {
        setState(() {
          if (user != null) {
            // משתמש רשום
            _selectedContacts.add(SelectedContact.fromRegisteredUser(
              userId: user.id,
              email: email,
              phone: user.phone,
              name: user.name,
              avatar: user.profileImageUrl,
              role: UserRole.editor,
            ));
          } else {
            // משתמש לא רשום - הזמנה ממתינה
            _selectedContacts.add(SelectedContact.fromEmail(
              email,
              role: UserRole.editor,
            ));
          }
          _emailController.clear();
          _isAddingContact = false;
          _isCheckingContact = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCheckingContact = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('שגיאה: $e')),
        );
      }
    }
  }

  /// הוספה לפי טלפון
  Future<void> _addByPhone() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || !_isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('נא להזין מספר טלפון תקין (05X-XXXXXXX)')),
      );
      return;
    }

    final normalizedPhone = _normalizePhone(phone);

    // בדוק אם כבר נבחר
    if (_selectedContacts.any((c) => c.phone == normalizedPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('איש קשר זה כבר נבחר')),
      );
      return;
    }

    setState(() => _isCheckingContact = true);

    try {
      // חפש משתמש רשום לפי טלפון
      final user = await _userRepository.findByPhone(normalizedPhone);

      if (mounted) {
        setState(() {
          if (user != null) {
            // משתמש רשום
            _selectedContacts.add(SelectedContact.fromRegisteredUser(
              userId: user.id,
              email: user.email,
              phone: user.phone,
              name: user.name,
              avatar: user.profileImageUrl,
              role: UserRole.editor,
            ));
          } else {
            // משתמש לא רשום - הזמנה ממתינה
            _selectedContacts.add(SelectedContact.fromPhone(
              normalizedPhone,
              role: UserRole.editor,
            ));
          }
          _phoneController.clear();
          _isAddingContact = false;
          _isCheckingContact = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCheckingContact = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('שגיאה: $e')),
        );
      }
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final normalized = _normalizePhone(phone);
    // פורמט טלפון ישראלי: 05X-XXXXXXX
    return RegExp(r'^05\d{8}$').hasMatch(normalized);
  }

  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400,
            maxHeight: 600,
          ),
          child: Padding(
            padding: const EdgeInsets.all(kSpacingMedium),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // === Header ===
                Row(
                  children: [
                    Icon(Icons.people, color: cs.primary),
                    const SizedBox(width: kSpacingSmall),
                    Text(
                      'בחירת אנשים לשיתוף',
                      style: theme.textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),

                // === Selected Contacts Chips ===
                if (_selectedContacts.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _selectedContacts.map((contact) {
                      return Chip(
                        avatar: contact.isPending
                            ? Icon(Icons.hourglass_empty,
                                size: 18, color: cs.onPrimaryContainer)
                            : CircleAvatar(
                                backgroundColor: cs.primaryContainer,
                                child: Text(contact.initials,
                                    style: const TextStyle(fontSize: 10)),
                              ),
                        label: Text(contact.displayName),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeSelected(contact.email),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: kSpacingSmall),
                  const Divider(),
                ],

                // === Search Bar ===
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'חיפוש לפי שם או אימייל...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: kSpacingMedium,
                      vertical: kSpacingSmall,
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: kSpacingSmall),

                // === Add New Contact Button / Field ===
                if (_isAddingContact)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Radio buttons for email/phone
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<_ContactInputType>(
                              title: const Text('אימייל'),
                              value: _ContactInputType.email,
                              groupValue: _inputType,
                              onChanged: (value) {
                                setState(() => _inputType = value!);
                              },
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<_ContactInputType>(
                              title: const Text('טלפון'),
                              value: _ContactInputType.phone,
                              groupValue: _inputType,
                              onChanged: (value) {
                                setState(() => _inputType = value!);
                              },
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: kSpacingSmall),
                      // Input field
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _inputType == _ContactInputType.email
                                  ? _emailController
                                  : _phoneController,
                              decoration: InputDecoration(
                                hintText: _inputType == _ContactInputType.email
                                    ? 'הזן אימייל...'
                                    : '05X-XXXXXXX',
                                prefixIcon: Icon(
                                  _inputType == _ContactInputType.email
                                      ? Icons.email_outlined
                                      : Icons.phone_outlined,
                                ),
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: kSpacingMedium,
                                  vertical: kSpacingSmall,
                                ),
                              ),
                              keyboardType: _inputType == _ContactInputType.email
                                  ? TextInputType.emailAddress
                                  : TextInputType.phone,
                              autofocus: true,
                              onSubmitted: (_) => _addNewContact(),
                            ),
                          ),
                          const SizedBox(width: kSpacingSmall),
                          _isCheckingContact
                              ? const SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.check),
                                  onPressed: _addNewContact,
                                  color: cs.primary,
                                ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _emailController.clear();
                              _phoneController.clear();
                              setState(() => _isAddingContact = false);
                            },
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  TextButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text('הוסף איש קשר חדש'),
                    onPressed: () => setState(() => _isAddingContact = true),
                  ),

                const SizedBox(height: kSpacingSmall),

                // === Contacts List ===
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredContacts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.people_outline,
                                      size: 48, color: cs.onSurfaceVariant),
                                  const SizedBox(height: kSpacingSmall),
                                  Text(
                                    _searchQuery.isEmpty
                                        ? 'אין אנשי קשר שמורים'
                                        : 'לא נמצאו תוצאות',
                                    style: TextStyle(color: cs.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _filteredContacts.length,
                              itemBuilder: (context, index) {
                                final contact = _filteredContacts[index];
                                final isSelected = _isSelected(contact);
                                final selectedContact = isSelected
                                    ? _selectedContacts.firstWhere(
                                        (c) => c.email == contact.userEmail)
                                    : null;

                                return _ContactTile(
                                  contact: contact,
                                  isSelected: isSelected,
                                  selectedRole: selectedContact?.role,
                                  onToggle: (role) =>
                                      _toggleContact(contact, role),
                                  onRoleChanged: (role) =>
                                      _updateRole(contact.userEmail, role),
                                );
                              },
                            ),
                ),

                const Divider(),

                // === Actions ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ביטול'),
                    ),
                    const SizedBox(width: kSpacingSmall),
                    FilledButton(
                      onPressed: _selectedContacts.isEmpty
                          ? null
                          : () => Navigator.pop(context, _selectedContacts),
                      child: Text('אישור (${_selectedContacts.length})'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// שורת איש קשר עם תפקיד
class _ContactTile extends StatelessWidget {
  final SavedContact contact;
  final bool isSelected;
  final UserRole? selectedRole;
  final void Function(UserRole role) onToggle;
  final void Function(UserRole role) onRoleChanged;

  const _ContactTile({
    required this.contact,
    required this.isSelected,
    this.selectedRole,
    required this.onToggle,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isSelected ? cs.primaryContainer : cs.surfaceContainerHighest,
        child: Text(
          contact.initials,
          style: TextStyle(
            color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
          ),
        ),
      ),
      title: Text(contact.displayName),
      subtitle: Text(
        contact.userEmail,
        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
      ),
      trailing: isSelected
          ? _RoleDropdown(
              value: selectedRole ?? UserRole.editor,
              onChanged: onRoleChanged,
            )
          : IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showRolePicker(context),
            ),
      selected: isSelected,
      selectedTileColor: cs.primaryContainer.withValues(alpha: 0.3),
      onTap: () {
        if (isSelected) {
          // הסר
          onToggle(selectedRole ?? UserRole.editor);
        } else {
          // הוסף - פתח בורר תפקיד
          _showRolePicker(context);
        }
      },
    );
  }

  void _showRolePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(kSpacingMedium),
                child: Text(
                  'בחר תפקיד עבור ${contact.displayName}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Divider(height: 1),
              _RoleOption(
                role: UserRole.admin,
                onTap: () {
                  Navigator.pop(ctx);
                  onToggle(UserRole.admin);
                },
              ),
              _RoleOption(
                role: UserRole.editor,
                onTap: () {
                  Navigator.pop(ctx);
                  onToggle(UserRole.editor);
                },
              ),
              _RoleOption(
                role: UserRole.viewer,
                onTap: () {
                  Navigator.pop(ctx);
                  onToggle(UserRole.viewer);
                },
              ),
              const SizedBox(height: kSpacingMedium),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dropdown לבחירת תפקיד
class _RoleDropdown extends StatelessWidget {
  final UserRole value;
  final void Function(UserRole) onChanged;

  const _RoleDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<UserRole>(
      value: value,
      underline: const SizedBox.shrink(),
      items: [UserRole.admin, UserRole.editor, UserRole.viewer]
          .map((role) => DropdownMenuItem(
                value: role,
                child: Text(role.hebrewName),
              ))
          .toList(),
      onChanged: (newRole) {
        if (newRole != null) onChanged(newRole);
      },
    );
  }
}

/// אופציית תפקיד ב-BottomSheet
class _RoleOption extends StatelessWidget {
  final UserRole role;
  final VoidCallback onTap;

  const _RoleOption({
    required this.role,
    required this.onTap,
  });

  IconData _getIconForRole(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return Icons.star;
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.editor:
        return Icons.edit;
      case UserRole.viewer:
        return Icons.visibility;
      case UserRole.unknown:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    String description;
    switch (role) {
      case UserRole.owner:
        description = 'בעלים - מלוא ההרשאות';
      case UserRole.admin:
        description = 'יכול לערוך ישירות ולהזמין אחרים';
      case UserRole.editor:
        description = 'יכול לערוך דרך אישור';
      case UserRole.viewer:
        description = 'יכול לצפות בלבד';
      case UserRole.unknown:
        description = 'תפקיד לא מוכר';
    }

    return ListTile(
      leading: Icon(_getIconForRole(role), color: cs.primary),
      title: Text('${role.emoji} ${role.hebrewName}'),
      subtitle: Text(description, style: TextStyle(color: cs.onSurfaceVariant)),
      onTap: onTap,
    );
  }
}
