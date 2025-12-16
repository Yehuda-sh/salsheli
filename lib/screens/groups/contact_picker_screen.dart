// 📄 File: lib/screens/groups/contact_picker_screen.dart
// 🎯 Purpose: מסך בחירת אנשי קשר להזמנה לקבוצה
//
// 📋 Features:
// - רשימת אנשי קשר מהטלפון
// - חיפוש אנשי קשר
// - בחירה מרובה
// - תצוגת אנשי קשר נבחרים
//
// 📝 Version: 1.0
// 📅 Created: 14/12/2025

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/ui_constants.dart';
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

      if (!hasPermission) {
        setState(() {
          _hasPermission = false;
          _isLoading = false;
        });
        return;
      }

      final contacts = await _contactService.getContacts();

      setState(() {
        _contacts = contacts;
        _filteredContacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
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

  void _confirmSelection() {
    final selectedContacts =
        _contacts.where((c) => _selectedIds.contains(c.id)).toList();
    Navigator.of(context).pop(selectedContacts);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selectedCount = _selectedIds.length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kPaperBackground,
        appBar: AppBar(
          title: Text(selectedCount > 0
              ? 'נבחרו $selectedCount אנשי קשר'
              : 'בחירת אנשי קשר'),
          centerTitle: true,
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          actions: [
            if (selectedCount > 0)
              TextButton(
                onPressed: _confirmSelection,
                child: const Text(
                  'אישור',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        body: Stack(
          children: [
            const NotebookBackground(),
            _buildBody(cs),
          ],
        ),
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
                      contact.displayName[0].toUpperCase(),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
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
                  'כדי להזמין חברים לקבוצה, נא לאשר גישה לאנשי הקשר בהגדרות המכשיר',
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

  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
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
                  'לא נמצאו אנשי קשר עם טלפון או אימייל',
                  style: TextStyle(fontSize: kFontSizeSmall),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// כרטיס איש קשר
class _ContactTile extends StatelessWidget {
  final SelectedContact contact;
  final bool isSelected;
  final VoidCallback onTap;

  const _ContactTile({
    required this.contact,
    required this.isSelected,
    required this.onTap,
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
                      contact.displayName[0].toUpperCase(),
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
          contact.phone ?? contact.email ?? '',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: cs.primary)
            : Icon(Icons.circle_outlined, color: Colors.grey[400]),
      ),
    );
  }
}
