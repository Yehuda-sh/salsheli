// 📄 lib/screens/groups/contact_picker_screen.dart
//
// מסך בחירת אנשי קשר להזמנה לקבוצה - מהטלפון או ידנית.
// תומך בחיפוש, בחירה מרובה, ובחירת תפקיד לכל מוזמן.
//
// Version 1.1 - No AppBar (Immersive)
// Last Updated: 13/01/2026
//
// 🔗 Related: ContactPickerService, SelectedContact, UserRole

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/ui_constants.dart';
import '../../models/enums/user_role.dart';
import '../../services/contact_picker_service.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_note.dart';

class ContactPickerScreen extends StatefulWidget {
  /// אנשי קשר שכבר נבחרו (אם יש)
  final List<SelectedContact> initialSelection;

  /// מספר מקסימלי של אנשי קשר לבחירה (null = ללא הגבלה)
  final int? maxSelection;

  const ContactPickerScreen({
    super.key,
    this.initialSelection = const [],
    this.maxSelection,
  });

  @override
  State<ContactPickerScreen> createState() => _ContactPickerScreenState();
}

class _ContactPickerScreenState extends State<ContactPickerScreen> {
  final _searchController = TextEditingController();
  final _contactService = ContactPickerService();

  List<SelectedContact> _contacts = [];
  List<SelectedContact> _filteredContacts = [];
  Set<String> _selectedIds = {};
  bool _isLoading = true;
  bool _hasPermission = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // ✅ שמור את initialSelection כ-contacts (לא רק IDs!)
    // זה מונע אובדן של מוזמנים ידניים/קודמים שלא קיימים ברשימת אנשי הקשר של המכשיר
    _contacts = List.from(widget.initialSelection);
    _filteredContacts = List.from(widget.initialSelection);
    _selectedIds = widget.initialSelection.map((c) => c.id).toSet();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final hasPermission = await _contactService.requestPermission();

      // ✅ mounted check אחרי await
      if (!mounted) return;

      if (!hasPermission) {
        setState(() {
          _hasPermission = false;
          _isLoading = false;
        });
        return;
      }

      final phoneContacts = await _contactService.getContacts();

      // ✅ mounted check אחרי await
      if (!mounted) return;

      // ✅ מיזוג: שמור את הקיימים (initialSelection) והוסף חדשים מהטלפון
      // מונע אובדן של מוזמנים ידניים/קודמים שלא קיימים ברשימת אנשי הקשר
      final existingIds = _contacts.map((c) => c.id).toSet();
      final newContacts = phoneContacts.where((c) => !existingIds.contains(c.id)).toList();

      setState(() {
        _hasPermission = true; // ✅ FIX: חזרה ל-true אחרי הצלחה
        _contacts = [..._contacts, ...newContacts];
        _filteredContacts = List.from(_contacts);
        _isLoading = false;
      });
    } catch (e) {
      // ✅ mounted check אחרי await
      if (!mounted) return;

      setState(() {
        _errorMessage = 'שגיאה בטעינת אנשי קשר';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = _contacts;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredContacts = _contacts.where((contact) {
          return contact.displayName.toLowerCase().contains(lowerQuery) ||
              (contact.phone?.contains(query) ?? false) ||
              (contact.email?.toLowerCase().contains(lowerQuery) ?? false);
        }).toList();
      }
    });
  }

  void _toggleSelection(SelectedContact contact) {
    HapticFeedback.selectionClick();

    setState(() {
      if (_selectedIds.contains(contact.id)) {
        _selectedIds.remove(contact.id);
      } else {
        // בדיקת מגבלת בחירה
        if (widget.maxSelection != null &&
            _selectedIds.length >= widget.maxSelection!) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ניתן לבחור עד ${widget.maxSelection} אנשי קשר'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        _selectedIds.add(contact.id);
      }
    });
  }

  /// עדכון תפקיד של איש קשר נבחר
  void _updateContactRole(SelectedContact contact, UserRole newRole) {
    setState(() {
      final index = _contacts.indexWhere((c) => c.id == contact.id);
      if (index != -1) {
        _contacts[index] = _contacts[index].copyWith(role: newRole);
      }
      // עדכון גם ברשימה המסוננת
      final filteredIndex = _filteredContacts.indexWhere((c) => c.id == contact.id);
      if (filteredIndex != -1) {
        _filteredContacts[filteredIndex] = _filteredContacts[filteredIndex].copyWith(role: newRole);
      }
    });
  }

  void _confirmSelection() {
    final selectedContacts =
        _contacts.where((c) => _selectedIds.contains(c.id)).toList();
    Navigator.of(context).pop(selectedContacts);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selectedCount = _selectedIds.length;

    return Scaffold(
      backgroundColor: kPaperBackground,
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
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                        color: cs.primary,
                      ),
                      Icon(Icons.contacts, size: 24, color: cs.primary),
                      const SizedBox(width: kSpacingSmall),
                      Expanded(
                        child: Text(
                          selectedCount > 0
                              ? 'נבחרו $selectedCount אנשי קשר'
                              : 'בחירת אנשי קשר',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      if (selectedCount > 0)
                        TextButton(
                          onPressed: _confirmSelection,
                          child: Text(
                            'אישור',
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(child: _buildBody(cs)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ColorScheme cs) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: kSpacingMedium),
            Text('טוען אנשי קשר...'),
          ],
        ),
      );
    }

    if (!_hasPermission) {
      return _buildPermissionRequest(cs);
    }

    if (_errorMessage != null) {
      return _buildError(cs);
    }

    if (_contacts.isEmpty) {
      return _buildEmptyState(cs);
    }

    return Column(
      children: [
        // === כפתור הזמנה ידנית ===
        Padding(
          padding: const EdgeInsets.fromLTRB(kSpacingMedium, kSpacingMedium, kSpacingMedium, 0),
          child: StickyNote(
            color: kStickyGreen,
            rotation: 0.005,
            child: InkWell(
              onTap: () => _showManualInviteDialog(cs),
              child: Padding(
                padding: const EdgeInsets.all(kSpacingSmall),
                child: Row(
                  children: [
                    Icon(Icons.person_add, color: Colors.green[700]),
                    const SizedBox(width: kSpacingSmall),
                    const Expanded(
                      child: Text(
                        'הזמנה ידנית (מייל או טלפון)',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
          ),
        ),

        // === שורת חיפוש ===
        Padding(
          padding: const EdgeInsets.all(kSpacingMedium),
          child: StickyNote(
            color: kStickyYellow,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: kSpacingSmall,
                vertical: 4,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'חיפוש איש קשר...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),

        // === אנשי קשר נבחרים ===
        if (_selectedIds.isNotEmpty) _buildSelectedChips(cs),

        // === רשימת אנשי קשר ===
        Expanded(
          child: _filteredContacts.isEmpty
              ? Center(
                  child: Text(
                    'לא נמצאו אנשי קשר',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
                  itemCount: _filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = _filteredContacts[index];
                    final isSelected = _selectedIds.contains(contact.id);
                    return _ContactTile(
                      contact: contact,
                      isSelected: isSelected,
                      onTap: () => _toggleSelection(contact),
                      onRoleChanged: isSelected
                          ? (role) => _updateContactRole(contact, role)
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSelectedChips(ColorScheme cs) {
    final selectedContacts =
        _contacts.where((c) => _selectedIds.contains(c.id)).toList();

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: selectedContacts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final contact = selectedContacts[index];
          return Chip(
            avatar: contact.photo != null
                ? CircleAvatar(backgroundImage: MemoryImage(contact.photo!))
                : CircleAvatar(
                    backgroundColor: cs.primaryContainer,
                    child: Text(
                      (contact.displayName.characters.firstOrNull ?? '?').toUpperCase(),
                      style: TextStyle(color: cs.onPrimaryContainer),
                    ),
                  ),
            label: Text(
              contact.displayName,
              style: const TextStyle(fontSize: 12),
            ),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () => _toggleSelection(contact),
            backgroundColor: cs.primaryContainer.withValues(alpha: 0.3),
          );
        },
      ),
    );
  }

  Widget _buildPermissionRequest(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(kSpacingMedium),
      child: Column(
        children: [
          // === כפתור הזמנה ידנית ===
          StickyNote(
            color: kStickyGreen,
            rotation: 0.005,
            child: InkWell(
              onTap: () => _showManualInviteDialog(cs),
              child: Padding(
                padding: const EdgeInsets.all(kSpacingSmall),
                child: Row(
                  children: [
                    Icon(Icons.person_add, color: Colors.green[700]),
                    const SizedBox(width: kSpacingSmall),
                    const Expanded(
                      child: Text(
                        'הזמנה ידנית (מייל או טלפון)',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: kSpacingLarge),

          // === הודעה על הרשאות ===
          Expanded(
            child: Center(
              child: StickyNote(
                color: kStickyPink,
                rotation: -0.02,
                child: Padding(
                  padding: const EdgeInsets.all(kSpacingLarge),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.contacts,
                        size: 64,
                        color: cs.primary,
                      ),
                      const SizedBox(height: kSpacingMedium),
                      const Text(
                        'נדרשת גישה לאנשי קשר',
                        style: TextStyle(
                          fontSize: kFontSizeLarge,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: kSpacingSmall),
                      const Text(
                        'כדי לראות אנשי קשר מהטלפון, נא לאשר גישה בהגדרות\nאו השתמש בהזמנה ידנית למעלה',
                        style: TextStyle(fontSize: kFontSizeSmall),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: kSpacingMedium),
                      ElevatedButton.icon(
                        onPressed: _loadContacts,
                        icon: const Icon(Icons.refresh),
                        label: const Text('נסה שוב'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
        child: StickyNote(
          color: kStickyPink,
          rotation: 0.01,
          child: Padding(
            padding: const EdgeInsets.all(kSpacingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: kSpacingMedium),
                Text(
                  _errorMessage!,
                  style: const TextStyle(fontSize: kFontSizeMedium),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: kSpacingMedium),
                ElevatedButton.icon(
                  onPressed: _loadContacts,
                  icon: const Icon(Icons.refresh),
                  label: const Text('נסה שוב'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// דיאלוג להזמנה ידנית
  /// עכשיו תומך בהזנת גם אימייל וגם טלפון לשיפור מציאת הזמנות
  void _showManualInviteDialog(ColorScheme cs) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    UserRole selectedRole = UserRole.editor; // ברירת מחדל: עורך

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'הזמנה ידנית',
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // שם
                    TextField(
                      controller: nameController,
                      textDirection: TextDirection.rtl,
                      decoration: const InputDecoration(
                        labelText: 'שם *',
                        hintText: 'הזן שם...',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: kSpacingMedium),

                    // אימייל
                    TextField(
                      controller: emailController,
                      textDirection: TextDirection.ltr,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'אימייל',
                        hintText: 'example@mail.com',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: kSpacingMedium),

                    // טלפון
                    TextField(
                      controller: phoneController,
                      textDirection: TextDirection.ltr,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'טלפון',
                        hintText: '050-1234567',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: kSpacingSmall),

                    // הערה
                    Text(
                      '💡 מומלץ להזין גם אימייל וגם טלפון לשיפור הסיכוי שההזמנה תימצא',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: kSpacingMedium),

                    // בחירת תפקיד
                    const Text(
                      'תפקיד בקבוצה:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: kSpacingSmall),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('מנהל'),
                          selected: selectedRole == UserRole.admin,
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() => selectedRole = UserRole.admin);
                            }
                          },
                          avatar: const Icon(Icons.admin_panel_settings, size: 18),
                        ),
                        ChoiceChip(
                          label: const Text('עורך'),
                          selected: selectedRole == UserRole.editor,
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() => selectedRole = UserRole.editor);
                            }
                          },
                          avatar: const Icon(Icons.edit, size: 18),
                        ),
                        ChoiceChip(
                          label: const Text('צופה'),
                          selected: selectedRole == UserRole.viewer,
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() => selectedRole = UserRole.viewer);
                            }
                          },
                          avatar: const Icon(Icons.visibility, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('ביטול'),
                ),
                FilledButton(
                  onPressed: () {
                    // ✅ בדיקת maxSelection - חסם לפני הוספה ידנית
                    if (widget.maxSelection != null &&
                        _selectedIds.length >= widget.maxSelection!) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text('ניתן לבחור עד ${widget.maxSelection} אנשי קשר'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    final name = nameController.text.trim();
                    final email = emailController.text.trim();
                    final phone = phoneController.text.trim();

                    // ולידציה
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('נא להזין שם'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    if (email.isEmpty && phone.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('נא להזין לפחות אימייל או טלפון'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    // יצירת איש קשר ידני עם שני הפרטים (אם קיימים)
                    final manualContact = SelectedContact(
                      id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
                      displayName: name,
                      phone: phone.isNotEmpty ? phone : null,
                      email: email.isNotEmpty ? email.toLowerCase() : null,
                      role: selectedRole,
                    );

                    Navigator.pop(context);

                    // הוספה לרשימה
                    setState(() {
                      _contacts.insert(0, manualContact);
                      _selectedIds.add(manualContact.id);
                      // עדכון הרשימה המסוננת ישירות
                      final query = _searchController.text;
                      if (query.isEmpty) {
                        _filteredContacts = List.from(_contacts);
                      } else {
                        final lowerQuery = query.toLowerCase();
                        _filteredContacts = _contacts.where((c) {
                          return c.displayName.toLowerCase().contains(lowerQuery) ||
                              (c.phone?.contains(query) ?? false) ||
                              (c.email?.toLowerCase().contains(lowerQuery) ?? false);
                        }).toList();
                      }
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$name נוסף להזמנה'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text('הוסף'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(kSpacingMedium),
      child: Column(
        children: [
          // === כפתור הזמנה ידנית ===
          StickyNote(
            color: kStickyGreen,
            rotation: 0.005,
            child: InkWell(
              onTap: () => _showManualInviteDialog(cs),
              child: Padding(
                padding: const EdgeInsets.all(kSpacingSmall),
                child: Row(
                  children: [
                    Icon(Icons.person_add, color: Colors.green[700]),
                    const SizedBox(width: kSpacingSmall),
                    const Expanded(
                      child: Text(
                        'הזמנה ידנית (מייל או טלפון)',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: kSpacingLarge),

          // === הודעה שאין אנשי קשר ===
          Expanded(
            child: Center(
              child: StickyNote(
                color: kStickyCyan,
                rotation: -0.01,
                child: Padding(
                  padding: const EdgeInsets.all(kSpacingLarge),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: cs.primary,
                      ),
                      const SizedBox(height: kSpacingMedium),
                      const Text(
                        'אין אנשי קשר',
                        style: TextStyle(
                          fontSize: kFontSizeLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: kSpacingSmall),
                      const Text(
                        'לא נמצאו אנשי קשר עם טלפון או אימייל\nניתן להשתמש בהזמנה ידנית למעלה',
                        style: TextStyle(fontSize: kFontSizeSmall),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// כרטיס איש קשר
class _ContactTile extends StatelessWidget {
  final SelectedContact contact;
  final bool isSelected;
  final VoidCallback onTap;
  final ValueChanged<UserRole>? onRoleChanged;

  const _ContactTile({
    required this.contact,
    required this.isSelected,
    required this.onTap,
    this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isSelected ? cs.primaryContainer.withValues(alpha: 0.3) : Colors.white,
      child: ListTile(
        onTap: onTap,
        leading: Stack(
          children: [
            // תמונה או אות ראשונה
            contact.photo != null
                ? CircleAvatar(
                    backgroundImage: MemoryImage(contact.photo!),
                    radius: 24,
                  )
                : CircleAvatar(
                    backgroundColor: cs.primaryContainer,
                    radius: 24,
                    child: Text(
                      (contact.displayName.characters.firstOrNull ?? '?').toUpperCase(),
                      style: TextStyle(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
            // אייקון בחירה
            if (isSelected)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          contact.displayName,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          _buildContactSubtitle(contact),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          maxLines: 2,
        ),
        trailing: isSelected
            ? _buildRoleSelector(context, cs)
            : Icon(Icons.circle_outlined, color: Colors.grey[400]),
      ),
    );
  }

  /// בורר תפקיד קומפקטי
  Widget _buildRoleSelector(BuildContext context, ColorScheme cs) {
    return PopupMenuButton<UserRole>(
      initialValue: contact.role,
      onSelected: onRoleChanged,
      tooltip: 'שנה תפקיד',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${contact.role.emoji} ${contact.role.hebrewName}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: Colors.white,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: UserRole.admin,
          child: Text('${UserRole.admin.emoji} מנהל'),
        ),
        PopupMenuItem(
          value: UserRole.editor,
          child: Text('${UserRole.editor.emoji} עורך'),
        ),
        PopupMenuItem(
          value: UserRole.viewer,
          child: Text('${UserRole.viewer.emoji} צופה'),
        ),
      ],
    );
  }

  /// בניית טקסט subtitle עם אימייל וטלפון
  String _buildContactSubtitle(SelectedContact contact) {
    final parts = <String>[];
    if (contact.phone != null && contact.phone!.isNotEmpty) {
      parts.add('📱 ${contact.phone}');
    }
    if (contact.email != null && contact.email!.isNotEmpty) {
      parts.add('✉️ ${contact.email}');
    }
    return parts.join('\n');
  }
}
