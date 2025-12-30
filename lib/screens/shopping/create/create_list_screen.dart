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
//
// Version: 3.0 - Screen-based refactor
// Last Updated: 26/11/2025

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../config/list_types_config.dart';
import '../../../core/status_colors.dart';
import '../../../core/ui_constants.dart';
import '../../../l10n/app_strings.dart';
import '../../../models/unified_list_item.dart';
import '../../../providers/shopping_lists_provider.dart';
import '../../../services/template_service.dart';
import 'template_picker_dialog.dart';

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

  // 📋 Template selection
  TemplateInfo? _selectedTemplate;
  List<UnifiedListItem> _templateItems = [];

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
        items: _templateItems.isNotEmpty ? _templateItems : null,
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

    // ✅ FIX: אם המשתמש לא מחובר - מעבירים ל-Login במקום להציג הודעה
    if (errorStr.contains('not logged in') || errorStr.contains('user')) {
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

        setState(() {
          _selectedTemplate = selected;
          // 🔧 עדכון שם רק אם השדה ריק - שומר על כוונת המשתמש
          if (_nameController.text.trim().isEmpty) {
            _nameController.text = selected.name;
          }
          _templateItems = items;
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppStrings.createListDialog.templateApplied(selected.name, items.length),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ שגיאה בטעינת תבניות: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.createListDialog.loadingTemplatesError),
          backgroundColor: Colors.red,
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
    final strings = AppStrings.createListDialog;
    // 🔧 שימוש ב-watch כדי שהולידציה תתעדכן אם נוספה רשימה ברקע
    final provider = context.watch<ShoppingListsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: strings.cancelTooltip,
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: kSpacingSmall),
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: kIconSizeMedium,
                      height: kIconSizeMedium,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(strings.createButton),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(kSpacingMedium),
          children: [
            // 📋 כפתור בחירת תבנית
            _buildTemplateButton(),
            const SizedBox(height: kSpacingLarge),

            // 📝 שם הרשימה
            _buildNameField(provider),
            const SizedBox(height: kSpacingMedium),

            // 📋 סוג הרשימה
            _buildTypeSelector(theme),
            const SizedBox(height: kSpacingMedium),

            // ✨ Preview
            _buildTypePreview(theme),
            const SizedBox(height: kSpacingMedium),

            // 📅 תאריך אירוע
            _buildEventDateField(theme),
            const SizedBox(height: kSpacingMedium),

            // 💰 תקציב
            _buildBudgetField(),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateButton() {
    final strings = AppStrings.createListDialog;

    return OutlinedButton.icon(
      icon: const Icon(Icons.list_alt),
      label: Text(
        _selectedTemplate == null
            ? strings.useTemplateButton
            : '✨ ${_selectedTemplate!.name}',
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        backgroundColor: _selectedTemplate != null
            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
            : null,
      ),
      onPressed: _isSubmitting ? null : _selectTemplate,
    );
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
          alignment: WrapAlignment.end,
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
                setState(() => _type = type);
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

  Widget _buildTypePreview(ThemeData theme) {
    final typeInfo = ListTypes.getByKey(_type);

    return Container(
      padding: const EdgeInsets.all(kSpacingMedium),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: kOpacityMedium),
        borderRadius: BorderRadius.circular(kBorderRadius),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: kOpacityLight),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            typeInfo?.emoji ?? '📋',
            style: const TextStyle(fontSize: 40.0),
          ),
          const SizedBox(width: kSpacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeInfo?.fullName ?? 'אחר',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedTemplate != null)
                  Text(
                    '${_templateItems.length} פריטים מתבנית',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
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
        FilteringTextInputFormatter.allow(RegExp(r'^\d+([.,]\d{0,2})?$')),
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
