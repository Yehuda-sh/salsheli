// 📄 lib/screens/groups/create_group_screen.dart
//
// מסך יצירת קבוצה חדשה - בחירת סוג, שם, תיאור והזמנת חברים.
// שדות דינמיים לפי סוג הקבוצה (בניין/גן/אירוע).
//
// 🔗 Related: Group, GroupType, GroupsProvider, ContactPickerScreen

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../models/enums/user_role.dart';
import '../../models/group.dart';
import '../../providers/groups_provider.dart';
import '../../services/contact_picker_service.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_button.dart';
import '../../widgets/common/sticky_note.dart';
import 'contact_picker_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _extraFieldController = TextEditingController();

  GroupType _selectedType = GroupType.family;
  bool _isLoading = false;

  /// אנשי קשר נבחרים להזמנה
  List<SelectedContact> _selectedContacts = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _extraFieldController.dispose();
    super.dispose();
  }

  /// יצירת הקבוצה
  Future<void> _createGroup() async {
    // מניעת לחיצה כפולה
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<GroupsProvider>();

      // הכנת שדות נוספים לפי סוג
      Map<String, dynamic>? extraFields;
      final extraValue = _extraFieldController.text.trim();

      if (extraValue.isNotEmpty) {
        switch (_selectedType) {
          case GroupType.building:
            extraFields = {'address': extraValue};
            break;
          case GroupType.kindergarten:
            extraFields = {'school_name': extraValue};
            break;
          case GroupType.event:
            // TODO: DatePicker לתאריך אירוע
            extraFields = {'event_name': extraValue};
            break;
          default:
            break;
        }
      }

      final group = await provider.createGroup(
        name: _nameController.text.trim(),
        type: _selectedType,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        extraFields: extraFields,
        invitedContacts: _selectedContacts.isNotEmpty ? _selectedContacts : null,
      );

      if (!mounted) return;

      if (group != null) {
        // הצלחה
        await HapticFeedback.mediumImpact();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('הקבוצה "${group.name}" נוצרה בהצלחה!'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop(group);
      } else {
        // שגיאה
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'שגיאה ביצירת הקבוצה'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// פתיחת מסך בחירת אנשי קשר
  Future<void> _openContactPicker() async {
    final result = await Navigator.of(context).push<List<SelectedContact>>(
      MaterialPageRoute(
        builder: (context) => ContactPickerScreen(
          initialSelection: _selectedContacts,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedContacts = result;
      });
    }
  }

  /// הסרת איש קשר מהרשימה
  void _removeContact(SelectedContact contact) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedContacts = _selectedContacts
          .where((c) => c.id != contact.id)
          .toList();
    });
  }

  /// עדכון תפקיד של איש קשר נבחר
  void _updateContactRole(SelectedContact contact, UserRole newRole) {
    setState(() {
      final index = _selectedContacts.indexWhere((c) => c.id == contact.id);
      if (index != -1) {
        _selectedContacts[index] = _selectedContacts[index].copyWith(role: newRole);
      }
    });
  }

  /// שם השדה הנוסף לפי סוג הקבוצה
  String? _getExtraFieldLabel() {
    switch (_selectedType) {
      case GroupType.building:
        return 'כתובת הבניין (אופציונלי)';
      case GroupType.kindergarten:
        return 'שם הגן/בית ספר (אופציונלי)';
      case GroupType.event:
        return 'שם האירוע (אופציונלי)';
      default:
        return null;
    }
  }

  /// Hint לשדה הנוסף
  String? _getExtraFieldHint() {
    switch (_selectedType) {
      case GroupType.building:
        return 'לדוגמה: הרצל 5, תל אביב';
      case GroupType.kindergarten:
        return 'לדוגמה: גן הילדים שמש';
      case GroupType.event:
        return 'לדוגמה: חתונת יוסי ורונית';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final extraFieldLabel = _getExtraFieldLabel();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kPaperBackground,
        appBar: AppBar(
          title: const Text('יצירת קבוצה חדשה'),
          centerTitle: true,
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
        ),
        body: Stack(
          children: [
            const NotebookBackground(),
            SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(kSpacingMedium),
                  children: [
                    // === בחירת סוג קבוצה ===
                    StickyNote(
                      color: kStickyYellow,
                      rotation: -0.01,
                      child: Padding(
                        padding: const EdgeInsets.all(kSpacingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'סוג הקבוצה',
                              style: TextStyle(
                                fontSize: kFontSizeMedium,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: kSpacingSmall),
                            const Text(
                              'בחר את סוג הקבוצה שברצונך ליצור',
                              style: TextStyle(
                                fontSize: kFontSizeSmall,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: kSpacingMedium),
                            Wrap(
                              spacing: kSpacingSmall,
                              runSpacing: kSpacingSmall,
                              children: GroupType.values.map((type) {
                                final isSelected = type == _selectedType;
                                return ChoiceChip(
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(type.emoji),
                                      const SizedBox(width: 4),
                                      Text(type.hebrewName),
                                    ],
                                  ),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    setState(() => _selectedType = type);
                                    HapticFeedback.selectionClick();
                                  },
                                  selectedColor: cs.primaryContainer,
                                  backgroundColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? cs.onPrimaryContainer
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: kSpacingMedium),

                    // === תכונות הסוג הנבחר ===
                    StickyNote(
                      color: kStickyCyan,
                      rotation: 0.008,
                      child: Padding(
                        padding: const EdgeInsets.all(kSpacingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _selectedType.icon,
                                  size: 24,
                                  color: cs.primary,
                                ),
                                const SizedBox(width: kSpacingSmall),
                                Text(
                                  _selectedType.hebrewName,
                                  style: const TextStyle(
                                    fontSize: kFontSizeMedium,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: kSpacingSmall),
                            Wrap(
                              spacing: kSpacingSmall,
                              runSpacing: 4,
                              children: [
                                if (_selectedType.hasPantry)
                                  const _FeatureChip(
                                    icon: Icons.inventory_2,
                                    label: 'מזווה',
                                  ),
                                if (_selectedType.hasShoppingMode)
                                  const _FeatureChip(
                                    icon: Icons.shopping_cart,
                                    label: 'קניות',
                                  ),
                                if (_selectedType.hasVoting)
                                  const _FeatureChip(
                                    icon: Icons.how_to_vote,
                                    label: 'הצבעות',
                                  ),
                                if (_selectedType.hasWhosBringing)
                                  const _FeatureChip(
                                    icon: Icons.person_add,
                                    label: 'מי מביא',
                                  ),
                                const _FeatureChip(
                                  icon: Icons.checklist,
                                  label: 'צ\'קליסט',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: kSpacingMedium),

                    // === שם הקבוצה ===
                    StickyNote(
                      color: kStickyGreen,
                      rotation: -0.005,
                      child: Padding(
                        padding: const EdgeInsets.all(kSpacingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'שם הקבוצה *',
                              style: TextStyle(
                                fontSize: kFontSizeMedium,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: kSpacingSmall),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                hintText: _getNameHint(),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(kBorderRadius),
                                ),
                                prefixIcon: Icon(
                                  _selectedType.icon,
                                  color: cs.primary,
                                ),
                              ),
                              maxLength: 30,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'נא להזין שם לקבוצה';
                                }
                                if (value.trim().length < 2) {
                                  return 'שם הקבוצה קצר מדי';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: kSpacingMedium),

                    // === תיאור (אופציונלי) ===
                    StickyNote(
                      color: kStickyPink,
                      rotation: 0.01,
                      child: Padding(
                        padding: const EdgeInsets.all(kSpacingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'תיאור (אופציונלי)',
                              style: TextStyle(
                                fontSize: kFontSizeMedium,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: kSpacingSmall),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                hintText: 'הוסף תיאור קצר...',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(kBorderRadius),
                                ),
                              ),
                              maxLines: 2,
                              maxLength: 100,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: kSpacingMedium),

                    // === הזמנת חברים ===
                    StickyNote(
                      color: kStickyOrange,
                      rotation: 0.005,
                      child: Padding(
                        padding: const EdgeInsets.all(kSpacingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.people_alt,
                                  size: 20,
                                  color: cs.primary,
                                ),
                                const SizedBox(width: kSpacingSmall),
                                const Expanded(
                                  child: Text(
                                    'הזמן חברים (אופציונלי)',
                                    style: TextStyle(
                                      fontSize: kFontSizeMedium,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _openContactPicker,
                                  icon: const Icon(Icons.add, size: 18),
                                  label: Text(
                                    _selectedContacts.isEmpty
                                        ? 'בחר מאנשי קשר'
                                        : 'הוסף עוד',
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_selectedContacts.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(top: kSpacingSmall),
                                child: Text(
                                  'תוכל להזמין חברים עכשיו או אחרי יצירת הקבוצה',
                                  style: TextStyle(
                                    fontSize: kFontSizeSmall,
                                    color: Colors.black54,
                                  ),
                                ),
                              )
                            else ...[
                              const SizedBox(height: kSpacingSmall),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _selectedContacts.map((contact) {
                                  return _ContactChipWithRole(
                                    contact: contact,
                                    onDeleted: () => _removeContact(contact),
                                    onRoleChanged: (role) =>
                                        _updateContactRole(contact, role),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: kSpacingSmall),
                              Text(
                                'נבחרו ${_selectedContacts.length} אנשי קשר',
                                style: TextStyle(
                                  fontSize: kFontSizeSmall,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // === שדה נוסף (לפי סוג) ===
                    if (extraFieldLabel != null) ...[
                      const SizedBox(height: kSpacingMedium),
                      StickyNote(
                        color: kStickyPurple,
                        rotation: -0.008,
                        child: Padding(
                          padding: const EdgeInsets.all(kSpacingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                extraFieldLabel,
                                style: const TextStyle(
                                  fontSize: kFontSizeMedium,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: kSpacingSmall),
                              TextFormField(
                                controller: _extraFieldController,
                                decoration: InputDecoration(
                                  hintText: _getExtraFieldHint(),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(kBorderRadius),
                                  ),
                                ),
                                maxLength: 50,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: kSpacingLarge),

                    // === כפתור יצירה ===
                    StickyButton(
                      label: _isLoading ? 'יוצר קבוצה...' : 'צור קבוצה',
                      color: cs.primary,
                      textColor: Colors.white,
                      onPressed: _isLoading ? null : _createGroup,
                    ),

                    const SizedBox(height: kSpacingMedium),

                    // === הערה ===
                    Text(
                      _selectedContacts.isEmpty
                          ? '💡 לאחר יצירת הקבוצה, תוכל להזמין חברים באמצעות קוד הזמנה'
                          : '💡 הזמנות ישלחו לחברים שנבחרו לאחר יצירת הקבוצה',
                      style: const TextStyle(
                        fontSize: kFontSizeSmall,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: kSpacingLarge),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hint לשם הקבוצה לפי סוג
  String _getNameHint() {
    switch (_selectedType) {
      case GroupType.family:
        return 'לדוגמה: משפחת כהן';
      case GroupType.building:
        return 'לדוגמה: ועד בית הרצל 5';
      case GroupType.kindergarten:
        return 'לדוגמה: ועד גן שמש';
      case GroupType.friends:
        return 'לדוגמה: החבר\'ה לטיול';
      case GroupType.event:
        return 'לדוגמה: חתונת יוסי ורונית';
      case GroupType.roommates:
        return 'לדוגמה: שותפים לדירה';
      case GroupType.other:
        return 'הזן שם לקבוצה';
    }
  }
}

/// Chip להצגת תכונה
class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kSpacingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(kBorderRadius),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip של איש קשר עם בחירת תפקיד
class _ContactChipWithRole extends StatelessWidget {
  final SelectedContact contact;
  final VoidCallback onDeleted;
  final ValueChanged<UserRole> onRoleChanged;

  const _ContactChipWithRole({
    required this.contact,
    required this.onDeleted,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // אווטאר
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: contact.photo != null
                ? CircleAvatar(
                    backgroundImage: MemoryImage(contact.photo!),
                    radius: 14,
                  )
                : CircleAvatar(
                    backgroundColor: cs.primaryContainer,
                    radius: 14,
                    child: Text(
                      contact.displayName[0].toUpperCase(),
                      style: TextStyle(
                        color: cs.onPrimaryContainer,
                        fontSize: 10,
                      ),
                    ),
                  ),
          ),
          // שם
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              contact.displayName,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          // בורר תפקיד
          PopupMenuButton<UserRole>(
            initialValue: contact.role,
            onSelected: onRoleChanged,
            tooltip: 'שנה תפקיד',
            padding: EdgeInsets.zero,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    contact.role.emoji,
                    style: const TextStyle(fontSize: 10),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 14),
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
          ),
          // כפתור מחיקה
          InkWell(
            onTap: onDeleted,
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 16),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
