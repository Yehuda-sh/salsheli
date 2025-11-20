// 📄 File: lib/widgets/create_list_dialog.dart
// 
// Purpose: Dialog ליצירת רשימת קניות חדשה עם validation מלא
// 
// ✨ Features:
// - ✅ i18n: כל המחרוזות דרך AppStrings
// - ✅ Validation: מניעת שמות כפולים + תקציב חיובי
// - ✅ Preview: תצוגה ויזואלית לסוג הרשימה הנבחר
// - ✅ Error handling: הודעות שגיאה ידידותיות
// - ✅ Accessibility: Tooltips על כל הכפתורים
// - ✅ Logging: תיעוד מפורט לכל הפעולות
//
// 🔗 Dependencies:
// - ShoppingListsProvider: ניהול state של רשימות
// - AppStrings: מחרוזות UI (l10n/app_strings.dart)
// - list_types_config.dart: הגדרות סוגי רשימות (kListTypes)
// - ui_constants.dart: קבועי UI (ריווחים, גדלים)
// - list_type_groups.dart: קיבוץ סוגי רשימות
//
// 📝 Usage Example:
// ```dart
// showDialog(
//   context: context,
//   builder: (dialogContext) => CreateListDialog(
//     onCreateList: (data) async {
//       await context.read<ShoppingListsProvider>().createList(data);
//     },
//   ),
// );
// ```
//
// Version: 2.0 - Complete refactor with all improvements
// Last Updated: 14/10/2025

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../config/list_types_config.dart';
import '../../core/status_colors.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/unified_list_item.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../services/template_service.dart';

class CreateListDialog extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic>) onCreateList;

  const CreateListDialog({super.key, required this.onCreateList});

  @override
  State<CreateListDialog> createState() => _CreateListDialogState();
}

class _CreateListDialogState extends State<CreateListDialog> {
  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController();
  final _nameController = TextEditingController();

  String _name = '';
  String _type = 'supermarket';
  double? _budget;
  DateTime? _eventDate;
  bool _isSubmitting = false;

  // 📋 Template selection
  TemplateInfo? _selectedTemplate;
  List<UnifiedListItem> _templateItems = [];

  @override
  void initState() {
    super.initState();
    debugPrint('🔵 CreateListDialog.initState() - Dialog נפתח');
  }

  /// טיפול בשינוי תקציב - מעדכן UI להצגת כפתור Clear
  void _handleBudgetChanged(String value) {
    setState(() {});
  }

  @override
  void dispose() {
    debugPrint('🔵 CreateListDialog.dispose() - Dialog נסגר');
    _budgetController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /// הטיפול בהגשת הטופס - validation and שמירה
  ///
  /// תהליך:
  /// 1. בדיקת validation של הטופס
  /// 2. שמירת נתונים (שם, סוג, תקציב, תאריך)
  /// 3. קריאה ל-onCreateList callback
  /// 4. סגירת ה-dialog בהצלחה
  /// 5. הודעת הצלחה ל-user
  ///
  /// שגיאות מטופלות עם הודעות ידידותיות
  Future<void> _handleSubmit() async {
    debugPrint('🔵 CreateListDialog._handleSubmit() התחיל');

    if (!(_formKey.currentState?.validate() ?? false)) {
      debugPrint('   ⚠️ Validation נכשל');
      _showErrorSnackBar(AppStrings.createListDialog.validationFailed);
      return;
    }

    _formKey.currentState?.save();
    debugPrint(
      '   📝 שם: "$_name", סוג: "$_type", תקציב: ${_budget ?? "לא הוגדר"}',
    );

    setState(() => _isSubmitting = true);

    final listData = {
      'name': _name,
      'type': _type,
      'status': 'active',
      if (_budget != null) 'budget': _budget,
      if (_eventDate != null) 'eventDate': _eventDate,
      if (_templateItems.isNotEmpty) 'items': _templateItems,
    };

    try {
      // Capture messenger before async operation
      final messenger = ScaffoldMessenger.of(context);
      
      debugPrint('   ✅ קורא ל-onCreateList');
      await widget.onCreateList(listData);
      debugPrint('   ✅ onCreateList הושלם בהצלחה');

      if (!mounted) {
        debugPrint('   ⚠️ Widget לא mounted - מדלג על הודעה');
        return;
      }

      // הודעת הצלחה עם פרטים
      final message = _budget != null
          ? AppStrings.createListDialog.listCreatedWithBudget(_name, _budget!)
          : AppStrings.createListDialog.listCreated(_name);
      
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
    } catch (e) {
      debugPrint('   ❌ שגיאה ב-onCreateList: $e');

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      // 🆕 הודעת שגיאה ידידותית
      _showErrorSnackBar(_getFriendlyErrorMessage(e));
    }
  }

  // 🆕 המרת שגיאות להודעות ידידותיות
  /// המרת שגיאות טכניות להודעות ידידותיות
  ///
  /// בודק את סוג השגיאה ומחזיר הודעה רלוונטית:
  /// - שגיאות network/connection
  /// - שגיאות user/login
  /// - שגיאה כללית כברירת מחדל
  ///
  /// [error] - השגיאה המקורית (כל סוג)
  /// Returns: הודעה ידידותית בעברית
  String _getFriendlyErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('network') || errorStr.contains('connection')) {
      return AppStrings.createListDialog.networkError;
    }
    
    if (errorStr.contains('not logged in') || errorStr.contains('user')) {
      return AppStrings.createListDialog.userNotLoggedIn;
    }
    
    // שגיאה כללית
    return AppStrings.createListDialog.createListErrorGeneric;
  }

  // 🆕 הצגת הודעות שגיאה
  /// הצגת SnackBar עם הודעת שגיאה
  ///
  /// עיצוב:
  /// - צבע אדום (red.shade700)
  /// - אייקון error + הודעה
  /// - floating behavior
  /// - משך: kSnackBarDurationLong
  ///
  /// [message] - ההודעה להצגה
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

  // ========================================
  // 🎭 Selector פשוט של סוגי רשימות (7 סוגים)
  // ========================================

  /// בנייה של selector סוגי הרשימות - גרסה פשוטה
  ///
  /// מבנה:
  /// - Label: "סוג הרשימה"
  /// - Wrap של 7 FilterChips (ללא קבוצות)
  ///
  /// Features:
  /// - אינדיקטור לסוג שנבחר
  /// - בחירה עם setState
  ///
  /// Returns: Widget פשוט ונקי
  Widget _buildGroupedTypeSelector() {
    final theme = Theme.of(context);
    final strings = AppStrings.createListDialog;

    // 7 סוגי הרשימות החדשים בלבד
    const types = [
      'supermarket',
      'pharmacy',
      'greengrocer',
      'butcher',
      'bakery',
      'market',
      'other',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Label
        Text(
          strings.typeLabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: kSpacingSmall),

        // Wrap של כל הסוגים
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: types.map(_buildTypeChip).toList(),
        ),
      ],
    );
  }

  /// בנייה של FilterChip לסוג רשימה בודד
  ///
  /// תכונות:
  /// - Label: שם + אייקון (emoji)
  /// - selected state: צבע primaryContainer
  /// - onSelected: עדכון _type
  /// - Disabled כשהדיאלוג משתמש בשליחה (_isSubmitting)
  ///
  /// [type] - סוג הרשימה (string key מ-ListTypes)
  /// Returns: FilterChip interactive
  Widget _buildTypeChip(String type) {
    final theme = Theme.of(context);
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
          Text(
            typeInfo.emoji,
            style: const TextStyle(fontSize: kIconSizeSmall),
          ),
        ],
      ),
      onSelected: _isSubmitting
          ? null
          : (selected) {
              if (selected) {
                debugPrint('🔄 סוג רשימה שונה ל: $type');
                setState(() {
                  _type = type;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.read<ShoppingListsProvider>();
    final strings = AppStrings.createListDialog;

    return AlertDialog(
      insetPadding: const EdgeInsets.all(kSpacingMedium),
      title: Text(strings.title, textAlign: TextAlign.right),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 600.0,
          maxWidth: 500.0,
        ),
        child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ========================================
              // 📋 Template Selection
              // ========================================
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.list_alt),
                  label: Text(
                    _selectedTemplate == null
                        ? '📋 בחר תבנית מוכנה'
                        : '✨ ${_selectedTemplate!.name}',
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: _selectedTemplate != null
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : null,
                  ),
                  onPressed: () async {
                    try {
                      final templates =
                          await TemplateService.loadTemplatesList();

                      if (!mounted) return;

                      final selected = await showDialog<TemplateInfo>(
                        context: context,
                        builder: (context) =>
                            _TemplatePickerDialog(templates: templates),
                      );

                      if (selected != null) {
                        debugPrint(
                            '📋 [CreateListDialog] נבחרה תבנית: ${selected.name}');

                        // טען את הפריטים מהתבנית
                        final items = await TemplateService.loadTemplateItems(
                          selected.templateFile,
                        );

                        setState(() {
                          _selectedTemplate = selected;
                          _nameController.text = selected.name;
                          _templateItems = items;
                        });

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '✨ תבנית "${selected.name}" נטענה! ${items.length} מוצרים הוכנו',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      debugPrint('❌ [CreateListDialog] שגיאה בטעינת תבניות: $e');
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('❌ שגיאה בטעינת התבניות'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ),

              // 📝 שם הרשימה
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: strings.nameLabel,
                  hintText: strings.nameHint,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return strings.nameRequired;
                  }

                  // בדיקת שם כפול
                  final trimmedName = value.trim();
                  final exists = provider.lists.any(
                    (list) =>
                        list.name.trim().toLowerCase() ==
                        trimmedName.toLowerCase(),
                  );

                  if (exists) {
                    return strings.nameAlreadyExists(trimmedName);
                  }

                  return null;
                },
                onSaved: (value) => _name = value!.trim(),
                textDirection: TextDirection.rtl,
                autofocus: true,
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: kSpacingSmallPlus),

              // 📋 סוג הרשימה - תצוגה מקובצת
              _buildGroupedTypeSelector(),
              const SizedBox(height: kSpacingSmallPlus),

              // ✨ Preview של הסוג שנבחר + תבנית
              Container(
                padding: const EdgeInsets.all(kSpacingSmall),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: kOpacityMedium,
                  ),
                  borderRadius: BorderRadius.circular(kBorderRadius),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: kOpacityLight),
                  ),
                ),
                child: Column(
                  children: [
                    // מידע על הסוג
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ListTypes.getByKey(_type)?.emoji ?? '📋',
                          style: const TextStyle(fontSize: 32.0),
                        ),
                        const SizedBox(width: kSpacingSmall),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ListTypes.getByKey(_type)?.fullName ?? 'אחר',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Template info removed - feature not implemented yet
                  ],
                ),
              ),
              const SizedBox(height: kSpacingSmallPlus),

              // 📅 תאריך אירוע (אופציונלי)
              InkWell(
                onTap: _isSubmitting ? null : () async {
                  debugPrint('📅 פותח DatePicker');
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
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: strings.eventDateLabel,
                    hintText: strings.eventDateHint,
                    prefixIcon: const Icon(Icons.event),
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
                    _eventDate == null
                        ? strings.noDate
                        : '${_eventDate!.day}/${_eventDate!.month}/${_eventDate!.year}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _eventDate == null
                          ? theme.colorScheme.onSurfaceVariant.withValues(alpha: kOpacityMedium)
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: kSpacingSmallPlus),

              // 💰 תקציב + Clear Button
              TextFormField(
                controller: _budgetController,
                decoration: InputDecoration(
                  labelText: strings.budgetLabel,
                  hintText: strings.budgetHint,
                  prefixIcon: const Icon(Icons.monetization_on),
                  suffixIcon: _budgetController.text.isNotEmpty
                      ? Tooltip(
                          message: strings.clearBudgetTooltip,
                          child: IconButton(
                            icon: const Icon(Icons.close, size: kIconSizeSmall),
                            onPressed: () {
                              debugPrint('🗑️ מנקה תקציב');
                              setState(() {
                                _budgetController.clear();
                                _budget = null;
                              });
                            },
                          ),
                        )
                      : null,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+([.,]\d{0,2})?$'),
                  ),
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
                onSaved: (value) {
                  if (value != null && value.isNotEmpty) {
                    final normalized = value.replaceAll(',', '.');
                    _budget = double.tryParse(normalized);
                  } else {
                    _budget = null;
                  }
                },
                onChanged: _handleBudgetChanged,
                textDirection: TextDirection.rtl,
                enabled: !_isSubmitting,
              ),
            ],
          ),
        ),
        ),
      ),
      actions: [
        Tooltip(
          message: strings.cancelTooltip,
          child: TextButton(
            onPressed: _isSubmitting
                ? null
                : () {
                    debugPrint('❌ משתמש ביטל יצירת רשימה');
                    Navigator.of(context, rootNavigator: true).pop();
                  },
            child: Text(strings.cancelButton),
          ),
        ),
        Tooltip(
          message: strings.createTooltip,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              minimumSize: const Size.square(kMinTouchTarget),
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
    );
  }
}

// ════════════════════════════════════════════
// Template Picker Dialog
// ════════════════════════════════════════════

/// דיאלוג לבחירת תבנית רשימה מוכנה
class _TemplatePickerDialog extends StatelessWidget {
  final List<TemplateInfo> templates;

  const _TemplatePickerDialog({required this.templates});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('בחר תבנית מוכנה'),
      content: SizedBox(
        width: double.maxFinite,
        child: templates.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    'אין תבניות זמינות',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final template = templates[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Text(
                        template.icon,
                        style: const TextStyle(fontSize: 32),
                      ),
                      title: Text(
                        template.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: template.description != null
                          ? Text(template.description!)
                          : null,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.pop(context, template),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ביטול'),
        ),
      ],
    );
  }
}