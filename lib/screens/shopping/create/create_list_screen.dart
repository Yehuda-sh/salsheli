// 📄 File: lib/screens/shopping/create/create_list_screen.dart
//
// Purpose: מסך יצירת רשימת קניות חדשה
//
// ✨ Features:
// - ✅ מסך מלא (לא Dialog) לחווית משתמש טובה יותר
// - ✅ i18n: כל המחרוזות דרך AppStrings
// - ✅ Validation בזמן הקלדה
// - ✅ Focus management עם FocusNodes
// - ✅ Preview ויזואלי לסוג הרשימה
// - ✅ תמיכה בתבניות מוכנות
// - ✅ 3 אופציות נראות: אישית / משפחתית / שיתוף ספציפי
//
// Version: 4.0 - Added specific sharing option
// Last Updated: 06/01/2026

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../config/list_types_config.dart';
import '../../../core/status_colors.dart';
import '../../../core/ui_constants.dart';
import '../../../l10n/app_strings.dart';
import '../../../models/selected_contact.dart';
import '../../../models/shopping_list.dart';
import '../../../models/unified_list_item.dart';
import '../../../providers/shopping_lists_provider.dart';
import '../../../services/template_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/notebook_background.dart';
import '../../../widgets/common/sticky_button.dart';
import '../../../widgets/common/sticky_note.dart';
import 'contact_selector_dialog.dart';
import 'template_picker_dialog.dart';

/// סוג נראות הרשימה
enum ListVisibility {
  /// רשימה אישית - רק אני רואה
  private,

  /// משפחתית - כל משק הבית רואה
  household,

  /// שיתוף ספציפי - אנשים שאני בוחר (ללא גישה למזווה)
  shared,
}

class CreateListScreen extends StatefulWidget {
  const CreateListScreen({super.key});

  @override
  State<CreateListScreen> createState() => _CreateListScreenState();
}

class _CreateListScreenState extends State<CreateListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();

  // 🎯 Focus Nodes לניהול מעבר בין שדות
  final _nameFocusNode = FocusNode();
  final _budgetFocusNode = FocusNode();

  String _type = 'supermarket';
  DateTime? _eventDate;
  bool _isSubmitting = false;

  // 🔒 נראות הרשימה (3 אופציות)
  ListVisibility _visibility = ListVisibility.private;

  // 👥 אנשי קשר לשיתוף ספציפי
  List<SelectedContact> _selectedContacts = [];

  // 📋 Template selection
  TemplateInfo? _selectedTemplate;
  List<UnifiedListItem> _templateItems = [];

  // 🎉 Event mode (לאירועים בלבד)
  // null = קנייה רגילה (לא אירוע)
  // 'who_brings' = מי מביא מה
  // 'shopping' = קנייה רגילה (אירוע)
  // 'tasks' = משימות אישיות
  String? _eventMode;

  // 📅 Date formatter
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    debugPrint('🔵 CreateListScreen.initState()');
  }

  @override
  void dispose() {
    debugPrint('🔵 CreateListScreen.dispose()');
    _nameController.dispose();
    _budgetController.dispose();
    _nameFocusNode.dispose();
    _budgetFocusNode.dispose();
    super.dispose();
  }

  /// הגשת הטופס
  Future<void> _handleSubmit() async {
    debugPrint('🔵 CreateListScreen._handleSubmit()');

    // 🔧 סגירת מקלדת לפני פעולות אסינכרוניות
    FocusManager.instance.primaryFocus?.unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      debugPrint('   ⚠️ Validation נכשל');
      _showErrorSnackBar(AppStrings.createListDialog.validationFailed);
      return;
    }

    _formKey.currentState?.save();

    final name = _nameController.text.trim();
    final budgetText = _budgetController.text.trim();
    final budget = budgetText.isNotEmpty
        ? double.tryParse(budgetText.replaceAll(',', '.'))
        : null;

    debugPrint('   📝 שם: "$name", סוג: "$_type", תקציב: ${budget ?? "לא הוגדר"}');

    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<ShoppingListsProvider>();
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);

      final newList = await provider.createList(
        name: name,
        type: _type,
        budget: budget,
        eventDate: _eventDate,
        isPrivate: _visibility != ListVisibility.household,
        isShared: _visibility == ListVisibility.shared,
        items: _templateItems.isNotEmpty ? _templateItems : null,
        sharedContacts: _visibility == ListVisibility.shared ? _selectedContacts : null,
        eventMode: _type == ShoppingList.typeEvent ? _eventMode : null,
      );

      debugPrint('   ✅ רשימה נוצרה: ${newList.id}');

      if (!mounted) return;

      // הודעת הצלחה
      final message = budget != null
          ? AppStrings.createListDialog.listCreatedWithBudget(name, budget)
          : AppStrings.createListDialog.listCreated(name);

      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: kSpacingSmall),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: StatusColors.getStatusColor('success', context),
          behavior: SnackBarBehavior.floating,
          duration: kSnackBarDuration,
        ),
      );

      // ניווט לעריכת הרשימה
      await navigator.pushReplacementNamed('/populate-list', arguments: newList);
    } catch (e) {
      debugPrint('   ❌ שגיאה: $e');

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      final errorMsg = _getFriendlyErrorMessage(e);
      if (errorMsg != null) {
        _showErrorSnackBar(errorMsg);
      }
    }
  }

  String? _getFriendlyErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('network') || errorStr.contains('connection')) {
      return AppStrings.createListDialog.networkError;
    }

    // 🔧 FIX: זיהוי ספציפי יותר של בעיית התחברות
    // מונע זיהוי שגוי של שגיאות אחרות שמכילות "user"
    final authErrors = [
      'not logged in',
      'user_not_logged_in',
      'user not authenticated',
      'unauthenticated',
      'permission-denied', // Firebase Auth
      'requires-authentication',
    ];

    if (authErrors.any(errorStr.contains)) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      return null; // לא מציגים snackbar
    }

    return AppStrings.createListDialog.createListErrorGeneric;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: kSpacingSmall),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: StatusColors.getStatusColor('error', context),
        behavior: SnackBarBehavior.floating,
        duration: kSnackBarDurationLong,
      ),
    );
  }

  /// בחירת תבנית
  Future<void> _selectTemplate() async {
    try {
      final templates = await TemplateService.loadTemplatesList();

      if (!mounted) return;

      final selected = await showDialog<TemplateInfo>(
        context: context,
        builder: (context) => TemplatePickerDialog(templates: templates),
      );

      if (selected != null) {
        debugPrint('📋 נבחרה תבנית: ${selected.name}');

        final items = await TemplateService.loadTemplateItems(
          selected.templateFile,
        );

        // 🔧 FIX: בדיקת mounted אחרי await - לפני setState
        if (!mounted) return;

        setState(() {
          _selectedTemplate = selected;
          // 🔧 עדכון שם רק אם השדה ריק - שומר על כוונת המשתמש
          if (_nameController.text.trim().isEmpty) {
            _nameController.text = selected.name;
          }
          // 🎉 עדכון סוג הרשימה לפי התבנית
          _type = TemplateService.getListTypeForTemplate(selected.id);
          _templateItems = items;
          // 🎯 עדכון eventMode לתבניות אירוע
          _eventMode = TemplateService.getEventModeForTemplate(
            selected.id,
            isPrivate: _visibility == ListVisibility.private,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppStrings.createListDialog.templateApplied(selected.name, items.length),
            ),
            backgroundColor: StatusColors.getStatusColor('success', context),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ שגיאה בטעינת תבניות: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.createListDialog.loadingTemplatesError),
          backgroundColor: StatusColors.getStatusColor('error', context),
        ),
      );
    }
  }

  /// פתיחת DatePicker
  Future<void> _selectEventDate() async {
    debugPrint('📅 פותח DatePicker');

    // 🔧 סגירת מקלדת לפני פתיחת הדיאלוג
    FocusManager.instance.primaryFocus?.unfocus();

    final strings = AppStrings.createListDialog;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: strings.selectDate,
      cancelText: strings.cancelButton,
      confirmText: AppStrings.common.ok,
    );

    if (selectedDate != null) {
      debugPrint('   ✅ תאריך נבחר: $selectedDate');
      setState(() => _eventDate = selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<AppBrand>();
    final strings = AppStrings.createListDialog;
    // 🔧 שימוש ב-watch כדי שהולידציה תתעדכן אם נוספה רשימה ברקע
    final provider = context.watch<ShoppingListsProvider>();

    return Scaffold(
        backgroundColor: brand?.paperBackground ?? theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            strings.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: strings.cancelTooltip,
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          ),
        ),
        body: Stack(
          children: [
            // 📓 רקע מחברת
            const NotebookBackground(),

            // 📝 תוכן
            SafeArea(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: ListView(
                  padding: EdgeInsets.only(
                    left: kSpacingMedium,
                    right: kSpacingMedium,
                    top: kSpacingSmall,
                    bottom: MediaQuery.of(context).viewInsets.bottom + kSpacingLarge,
                  ),
                  children: [
                    // 📋 כפתור בחירת תבנית
                    _buildTemplateButton(),
                    const SizedBox(height: kSpacingMedium),

                    // 📝 שם הרשימה - Yellow StickyNote
                    StickyNote(
                      color: brand?.stickyYellow ?? kStickyYellow,
                      rotation: 0.008,
                      child: _buildNameField(provider),
                    ),
                    const SizedBox(height: kSpacingMedium),

                    // 📋 סוג הרשימה
                    _buildTypeSelector(theme),
                    const SizedBox(height: kSpacingMedium),

                    // 🔒 אישית/משפחתית
                    _buildPrivacyToggle(theme),
                    const SizedBox(height: kSpacingMedium),

                    // 🎉 מצב אירוע (רק כשהסוג הוא אירוע)
                    if (_type == ShoppingList.typeEvent) ...[
                      _buildEventModeSelector(theme),
                      const SizedBox(height: kSpacingMedium),
                    ],

                    // 📅 תאריך אירוע
                    _buildEventDateField(theme),
                    const SizedBox(height: kSpacingMedium),

                    // 💰 תקציב
                    _buildBudgetField(),
                    const SizedBox(height: kSpacingLarge),

                    // ✅ כפתור יצירה
                    StickyButton(
                      color: brand?.stickyGreen ?? kStickyGreen,
                      label: strings.createButton,
                      icon: Icons.add_task,
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _handleSubmit,
                    ),
                    const SizedBox(height: kSpacingMedium),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildTemplateButton() {
    final strings = AppStrings.createListDialog;
    final theme = Theme.of(context);

    // 🔧 אם נבחרה תבנית - הצג עם כפתור הסרה
    if (_selectedTemplate != null) {
      return Container(
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(kBorderRadius),
          border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            // כפתור שינוי תבנית
            Expanded(
              child: InkWell(
                onTap: _isSubmitting ? null : _selectTemplate,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(kBorderRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSpacingMedium,
                    vertical: kSpacingSmall + 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.list_alt, color: theme.primaryColor),
                      const SizedBox(width: kSpacingSmall),
                      Flexible(
                        child: Text(
                          '✨ ${_selectedTemplate!.name}',
                          style: TextStyle(color: theme.primaryColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // כפתור הסרת תבנית
            Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: theme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: IconButton(
                icon: Icon(Icons.close, color: theme.colorScheme.error),
                tooltip: 'הסר תבנית',
                onPressed: _isSubmitting ? null : _removeTemplate,
              ),
            ),
          ],
        ),
      );
    }

    // אין תבנית - כפתור רגיל
    return OutlinedButton.icon(
      icon: const Icon(Icons.list_alt),
      label: Text(strings.useTemplateButton),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
      onPressed: _isSubmitting ? null : _selectTemplate,
    );
  }

  /// הסרת תבנית שנבחרה
  void _removeTemplate() {
    setState(() {
      _selectedTemplate = null;
      _templateItems = [];
    });
  }

  Widget _buildNameField(ShoppingListsProvider provider) {
    final strings = AppStrings.createListDialog;

    return TextFormField(
      controller: _nameController,
      focusNode: _nameFocusNode,
      decoration: InputDecoration(
        labelText: strings.nameLabel,
        hintText: strings.nameHint,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return strings.nameRequired;
        }

        final trimmedName = value.trim();
        final exists = provider.lists.any(
          (list) => list.name.trim().toLowerCase() == trimmedName.toLowerCase(),
        );

        if (exists) {
          return strings.nameAlreadyExists(trimmedName);
        }

        return null;
      },
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => _budgetFocusNode.requestFocus(),
      autofocus: true,
      enabled: !_isSubmitting,
    );
  }

  Widget _buildTypeSelector(ThemeData theme) {
    final strings = AppStrings.createListDialog;
    // 🔧 שימוש בקונסטנטים מהקונפיגורציה במקום מחרוזות קשיחות
    final types = ListTypes.all.map((t) => t.key).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          strings.typeLabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: kSpacingSmall),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: types.map((type) => _buildTypeChip(type, theme)).toList(),
        ),
      ],
    );
  }

  Widget _buildTypeChip(String type, ThemeData theme) {
    final typeInfo = ListTypes.getByKey(type);
    if (typeInfo == null) return const SizedBox.shrink();

    final isSelected = _type == type;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(typeInfo.fullName),
          const SizedBox(width: kSpacingXTiny),
          Text(typeInfo.emoji, style: const TextStyle(fontSize: kIconSizeSmall)),
        ],
      ),
      onSelected: _isSubmitting
          ? null
          : (selected) {
              if (selected) {
                debugPrint('🔄 סוג רשימה שונה ל: $type');
                setState(() {
                  _type = type;
                  // 🎯 עדכון eventMode כשעוברים לאירוע
                  if (type == ShoppingList.typeEvent) {
                    _eventMode = _visibility == ListVisibility.private
                        ? ShoppingList.eventModeTasks
                        : ShoppingList.eventModeWhoBrings;
                  } else {
                    _eventMode = null;
                  }
                });
              }
            },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withValues(alpha: kOpacityLight),
      ),
    );
  }

  Widget _buildPrivacyToggle(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // כותרת
        Text(
          'מי יראה את הרשימה?',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: kSpacingSmall),
        // SegmentedButton עם 3 אופציות
        SegmentedButton<ListVisibility>(
          segments: const [
            ButtonSegment(
              value: ListVisibility.private,
              label: Text('🔒 אישית'),
            ),
            ButtonSegment(
              value: ListVisibility.household,
              label: Text('👨‍👩‍👧 משפחתית'),
            ),
            ButtonSegment(
              value: ListVisibility.shared,
              label: Text('👥 שיתוף'),
            ),
          ],
          selected: {_visibility},
          onSelectionChanged: _isSubmitting
              ? null
              : (selection) {
                  setState(() {
                    _visibility = selection.first;
                    // נקה אנשי קשר אם עוברים מ-shared לאופציה אחרת
                    if (_visibility != ListVisibility.shared) {
                      _selectedContacts = [];
                    }
                    // 🎯 עדכון eventMode אם זה אירוע
                    if (_type == ShoppingList.typeEvent) {
                      _eventMode = _visibility == ListVisibility.private
                          ? ShoppingList.eventModeTasks
                          : ShoppingList.eventModeWhoBrings;
                    }
                  });
                },
          style: const ButtonStyle(
            visualDensity: VisualDensity.comfortable,
          ),
        ),
        const SizedBox(height: kSpacingTiny),
        // הסבר
        Text(
          _getVisibilityDescription(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        // 👥 בורר אנשי קשר - מוצג רק כש-visibility == shared
        if (_visibility == ListVisibility.shared) ...[
          const SizedBox(height: kSpacingMedium),
          _buildContactsPicker(theme),
        ],
      ],
    );
  }

  String _getVisibilityDescription() {
    switch (_visibility) {
      case ListVisibility.private:
        return 'רק אתה תראה את הרשימה הזו';
      case ListVisibility.household:
        return 'כל המשפחה תוכל לראות ולערוך';
      case ListVisibility.shared:
        return 'שתף עם אנשים ספציפיים (ללא גישה למזווה שלך)';
    }
  }

  /// 🎉 בורר מצב אירוע - מוצג רק כשהסוג הוא אירוע
  Widget _buildEventModeSelector(ThemeData theme) {
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // כותרת
        Text(
          'איך תנהלו את הרשימה?',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.primary,
          ),
        ),
        const SizedBox(height: kSpacingSmall),

        // אופציות
        _buildEventModeOption(
          theme: theme,
          mode: ShoppingList.eventModeWhoBrings,
          icon: Icons.people,
          title: 'מי מביא מה',
          description: 'כל משתתף מתנדב להביא פריטים',
          isRecommended: _visibility != ListVisibility.private,
        ),
        const SizedBox(height: kSpacingSmall),

        _buildEventModeOption(
          theme: theme,
          mode: ShoppingList.eventModeShopping,
          icon: Icons.shopping_cart,
          title: 'קנייה רגילה',
          description: 'אדם אחד קונה את כל הרשימה',
        ),
        const SizedBox(height: kSpacingSmall),

        _buildEventModeOption(
          theme: theme,
          mode: ShoppingList.eventModeTasks,
          icon: Icons.checklist,
          title: 'משימות אישיות',
          description: 'צ\'קליסט פשוט רק לי',
          isRecommended: _visibility == ListVisibility.private,
        ),
      ],
    );
  }

  Widget _buildEventModeOption({
    required ThemeData theme,
    required String mode,
    required IconData icon,
    required String title,
    required String description,
    bool isRecommended = false,
  }) {
    final cs = theme.colorScheme;
    final isSelected = _eventMode == mode;

    return InkWell(
      onTap: _isSubmitting
          ? null
          : () {
              setState(() => _eventMode = mode);
            },
      borderRadius: BorderRadius.circular(kBorderRadiusMedium),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(kSpacingMedium),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primaryContainer.withValues(alpha: 0.5)
              : cs.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? cs.primary : cs.outline,
                  width: 2,
                ),
                color: isSelected ? cs.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: kSpacingMedium),

            // Icon
            Icon(
              icon,
              color: isSelected ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: kSpacingSmall),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? cs.primary : cs.onSurface,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: kSpacingTiny),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: cs.tertiaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'מומלץ',
                            style: TextStyle(
                              fontSize: 10,
                              color: cs.onTertiaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
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

  Widget _buildContactsPicker(ThemeData theme) {
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(kSpacingSmall),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(kBorderRadiusMedium),
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // אנשי קשר שנבחרו
          if (_selectedContacts.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _selectedContacts.map((contact) {
                return Chip(
                  avatar: contact.isPending
                      ? Icon(Icons.hourglass_empty,
                          size: 16, color: cs.onSecondaryContainer)
                      : CircleAvatar(
                          backgroundColor: cs.primaryContainer,
                          radius: 12,
                          child: Text(
                            contact.initials,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                  label: Text(
                    '${contact.displayName} (${contact.role.hebrewName})',
                    style: const TextStyle(fontSize: 12),
                  ),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _selectedContacts
                                .removeWhere((c) => c.email == contact.email);
                          });
                        },
                );
              }).toList(),
            ),
            const SizedBox(height: kSpacingSmall),
          ],
          // כפתור הוספה
          OutlinedButton.icon(
            icon: const Icon(Icons.person_add),
            label: Text(_selectedContacts.isEmpty
                ? 'בחר אנשים לשיתוף'
                : 'הוסף עוד אנשים'),
            onPressed: _isSubmitting ? null : _openContactSelector,
          ),
          // הודעה אם יש pending
          if (_selectedContacts.any((c) => c.isPending)) ...[
            const SizedBox(height: kSpacingSmall),
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: cs.tertiary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'משתמשים שאינם רשומים יקבלו הזמנה ממתינה',
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.tertiary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openContactSelector() async {
    final result = await ContactSelectorDialog.show(
      context,
      alreadySelected: _selectedContacts,
    );

    if (result != null && mounted) {
      setState(() {
        _selectedContacts = result;
      });
    }
  }

  Widget _buildEventDateField(ThemeData theme) {
    final strings = AppStrings.createListDialog;

    return InkWell(
      onTap: _isSubmitting ? null : _selectEventDate,
      borderRadius: BorderRadius.circular(kBorderRadius),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: strings.eventDateLabel,
          hintText: strings.eventDateHint,
          prefixIcon: const Icon(Icons.event),
          border: const OutlineInputBorder(),
          suffixIcon: _eventDate != null
              ? Tooltip(
                  message: strings.clearDateTooltip,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: kIconSizeSmall),
                    onPressed: () {
                      debugPrint('🗑️ מנקה תאריך אירוע');
                      setState(() => _eventDate = null);
                    },
                  ),
                )
              : null,
        ),
        child: Text(
          _eventDate == null ? strings.noDate : _dateFormat.format(_eventDate!),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: _eventDate == null
                ? theme.colorScheme.onSurfaceVariant.withValues(alpha: kOpacityMedium)
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetField() {
    final strings = AppStrings.createListDialog;

    return TextFormField(
      controller: _budgetController,
      focusNode: _budgetFocusNode,
      decoration: InputDecoration(
        labelText: strings.budgetLabel,
        hintText: strings.budgetHint,
        prefixIcon: const Icon(Icons.monetization_on),
        border: const OutlineInputBorder(),
        suffixIcon: _budgetController.text.isNotEmpty
            ? Tooltip(
                message: strings.clearBudgetTooltip,
                child: IconButton(
                  icon: const Icon(Icons.close, size: kIconSizeSmall),
                  onPressed: _budgetController.clear,
                ),
              )
            : null,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        // 🔧 FIX: \d* במקום \d+ - מאפשר שדה ריק (למחיקה ידנית)
        FilteringTextInputFormatter.allow(RegExp(r'^\d*([.,]\d{0,2})?$')),
      ],
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final normalized = value.replaceAll(',', '.');
          final amount = double.tryParse(normalized);

          if (amount == null) {
            return strings.budgetInvalid;
          }

          if (amount <= 0) {
            return strings.budgetMustBePositive;
          }
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleSubmit(),
      enabled: !_isSubmitting,
    );
  }
}
