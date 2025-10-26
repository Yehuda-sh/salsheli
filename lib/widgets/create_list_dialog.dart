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
// - constants.dart: קבועים גלובליים (kListTypes)
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
import '../core/constants.dart';
import '../core/ui_constants.dart';
import '../core/status_colors.dart';
import '../config/list_type_groups.dart';
import '../providers/shopping_lists_provider.dart';
import '../l10n/app_strings.dart';

class CreateListDialog extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic>) onCreateList;

  const CreateListDialog({super.key, required this.onCreateList});

  @override
  State<CreateListDialog> createState() => _CreateListDialogState();
}

class _CreateListDialogState extends State<CreateListDialog> {
  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController();

  String _name = "";
  String _type = "super";
  double? _budget;
  DateTime? _eventDate;
  bool _isSubmitting = false;
  
  // Template selection (disabled for now - models not implemented)
  // Template? _selectedTemplate;
  // List<UnifiedListItem> _templateItems = [];

  @override
  void initState() {
    super.initState();
    debugPrint('🔵 CreateListDialog.initState() - Dialog נפתח');
  }

  @override
  void dispose() {
    debugPrint('🔵 CreateListDialog.dispose() - Dialog נסגר');
    _budgetController.dispose();
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
    };

    try {
      debugPrint('   ✅ קורא ל-onCreateList');
      await widget.onCreateList(listData);
      debugPrint('   ✅ onCreateList הושלם בהצלחה');

      if (!mounted) {
        debugPrint('   ⚠️ Widget לא mounted - לא סוגר Dialog');
        return;
      }

      debugPrint('   ✅ סוגר Dialog');
      Navigator.of(context, rootNavigator: true).pop();
      
      // הודעת הצלחה עם פרטים
      _showSuccessSnackBar(
        _budget != null
            ? AppStrings.createListDialog.listCreatedWithBudget(_name, _budget!)
            : AppStrings.createListDialog.listCreated(_name),
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

  // 🆕 הצגת הודעות הצלחה
  /// הצגת SnackBar עם הודעת הצלחה
  ///
  /// עיצוב:
  /// - צבע ירוק (green.shade700)
  /// - אייקון check_circle + הודעה
  /// - floating behavior
  /// - משך: kSnackBarDuration
  ///
  /// [message] - ההודעה להצגה
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
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
  }

  // ========================================
  // 📋 Templates Bottom Sheet - DISABLED
  // ========================================
  /// Templates feature is disabled until Template model is implemented
  /* Future<void> _showTemplatesBottomSheet() async {
    debugPrint('📋 פתיחת Templates Bottom Sheet');

    final template = await showModalBottomSheet<Template>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Consumer<TemplatesProvider>(
              builder: (_, provider, child) {
                return Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(kSpacingMedium),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).colorScheme.outline.withValues(alpha: kOpacityLight),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.createListDialog.selectTemplateTitle,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  AppStrings.createListDialog.selectTemplateHint,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),

                    // Loading State
                    if (provider.isLoading)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: kSpacingMedium),
                              Text(AppStrings.createListDialog.loadingTemplates),
                            ],
                          ),
                        ),
                      ),

                    // Error State
                    if (provider.hasError)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: StatusColors.getStatusColor('error', context),
                              ),
                              const SizedBox(height: kSpacingMedium),
                              Text(
                                '${AppStrings.createListDialog.loadingTemplatesError}\n${provider.errorMessage}',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Empty State
                    if (!provider.isLoading && !provider.hasError && provider.templates.isEmpty)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: kOpacityMedium),
                              ),
                              const SizedBox(height: kSpacingMedium),
                              Text(
                                AppStrings.createListDialog.noTemplatesAvailable,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: kSpacingSmall),
                              Text(
                                AppStrings.createListDialog.noTemplatesMessage,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Templates List
                    if (!provider.isLoading && !provider.hasError && provider.templates.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(kSpacingMedium),
                          itemCount: provider.templates.length,
                          itemBuilder: (context, index) {
                            final template = provider.templates[index];
                            final typeInfo = kListTypes[template.type] ?? kListTypes['other']!;

                            return Card(
                              margin: const EdgeInsets.only(bottom: kSpacingSmallPlus),
                              child: ListTile(
                                leading: Container(
                                  width: kMinTouchTarget,
                                  height: kMinTouchTarget,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: kOpacityLow),
                                    borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                                  ),
                                  child: Center(
                                    child: Text(
                                      typeInfo['icon']!,
                                      style: const TextStyle(fontSize: kIconSize),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  template.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '${template.defaultItems.length} ${AppStrings.templates.itemsCount(template.defaultItems.length).split(' ')[1]} • ${typeInfo['name']}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                trailing: const Icon(Icons.arrow_forward),
                                onTap: () {
                                  debugPrint('✅ נבחרה תבנית: ${template.name}');
                                  Navigator.pop(sheetContext, template);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );

    // 🆕 מילוי נתונים מהתבנית + פריטים
    if (template != null && mounted) {
      debugPrint('✨ ממלא נתונים מתבנית: ${template.name}');
      debugPrint('   📦 ${template.defaultItems.length} פריטים');
      
      setState(() {
        _type = template.type;
        _selectedTemplate = template;
        
        // 🆕 המרת פריטי תבנית לפריטי קבלה
        _templateItems = template.defaultItems.map((templateItem) {
          return ReceiptItem(
            name: templateItem.name,
            category: templateItem.category,
            quantity: templateItem.quantity,
            unit: templateItem.unit,
            isChecked: false, // פריטים חדשים מתחילים כלא מסומנים
            unitPrice: 0.0, // אין מחיר בשלב זה
          );
        }).toList();
      });

      // 🆕 הודעה מפורטת על התבנית שנבחרה
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.createListDialog.templateApplied(
              template.name,
              template.defaultItems.length,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  } */

  // ========================================
  // 🎭 תצוגה מקובצת של סוגי רשימות
  // ========================================

  /// בנייה של selector סוגי הרשימות במצב קבוצות
  ///
  /// מבנה:
  /// - Label: "סוג הרשימה"
  /// - Container עם Border
  /// - ExpansionTiles לכל קבוצה (ListTypeGroups)
  /// - FilterChips לכל סוג ברשימה
  ///
  /// Features:
  /// - ניתן to expand/collapse קבוצות
  /// - אינדיקטור לסוג שנבחר כרגע
  /// - בחירה עם setState
  ///
  /// Returns: Widget מקביל למבנה היררכי
  Widget _buildGroupedTypeSelector() {
    final theme = Theme.of(context);
    final strings = AppStrings.createListDialog;

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

        // קבוצות
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: kOpacityLow),
            ),
            borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          ),
          child: Column(
            children: ListTypeGroups.allGroups.map((group) {
              return _buildGroupExpansionTile(group);
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// בנייה של ExpansionTile לקבוצת סוגי רשימות
  ///
  /// תכונות:
  /// - אייקון הקבוצה (emoji)
  /// - שם הקבוצה + תיאור קצר
  /// - ניתן to expand/collapse
  /// - initiallyExpanded: true אם סוג נוכחי בקבוצה
  /// - אינדיקטור "selected" כשהסוג בחר הוא בקבוצה זו
  ///
  /// [group] - הקבוצה להצגה (ListTypeGroup enum)
  /// Returns: ExpansionTile עם FilterChips בתוך
  Widget _buildGroupExpansionTile(ListTypeGroup group) {
    final theme = Theme.of(context);
    final types = ListTypeGroups.getTypesInGroup(group);
    final isCurrentGroupSelected = types.contains(_type);

    return ExpansionTile(
      initiallyExpanded: isCurrentGroupSelected,
      tilePadding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingTiny),
      childrenPadding: const EdgeInsets.only(
        left: kSpacingMedium,
        right: kSpacingMedium,
        bottom: kSpacingSmall,
      ),
      leading: Text(
        ListTypeGroups.getGroupIcon(group),
        style: const TextStyle(fontSize: 24),
      ),
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ListTypeGroups.getGroupName(group),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ListTypeGroups.getGroupDescription(group),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: kFontSizeTiny,
                  ),
                ),
              ],
            ),
          ),
          // אינדיקטור אם הסוג הנוכחי בקבוצה זו
          if (isCurrentGroupSelected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(kBorderRadius),
              ),
              child: Text(
                AppStrings.createListDialog.typeSelected,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      children: [
        // Grid של סוגי הרשימות בקבוצה
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: types.map((type) => _buildTypeChip(type)).toList(),
        ),
      ],
    );
  }

  /// בנייה של FilterChip לסוג רשימה בודד
  ///
  /// תכונות:
  /// - Label: שם + אייקון (emoji)
  /// - selected state: צבע primaryContainer
  /// - onSelected: עדכון _type + בדיקת תבנית
  /// - Disabled כשהדיאלוג משתמש בשליחה (_isSubmitting)
  /// - Logic: אם סוג משתנה ותבנית לא תואמת → מנקה תבנית
  ///
  /// [type] - סוג הרשימה (string key מ-kListTypes)
  /// Returns: FilterChip interactive
  Widget _buildTypeChip(String type) {
    final theme = Theme.of(context);
    final typeInfo = kListTypes[type]!;
    final isSelected = _type == type;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(typeInfo['name']!),
          const SizedBox(width: kSpacingXTiny),
          Text(
            typeInfo['icon']!,
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
                  // Template logic removed - feature not implemented
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
            : theme.colorScheme.outline.withValues(alpha: kOpacityLow),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.read<ShoppingListsProvider>();
    final strings = AppStrings.createListDialog;

    return AlertDialog(
      insetPadding: kPaddingDialog,
      title: Text(strings.title, textAlign: TextAlign.right),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: kDialogMaxHeight,
          maxWidth: kDialogMaxWidth,
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
              // 📋 Templates feature disabled
              // ========================================
              // Template button removed - feature not implemented yet

              // 📝 שם הרשימה
              TextFormField(
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
                          kListTypes[_type]!["icon"]!,
                          style: const TextStyle(fontSize: kIconSizeLarge),
                        ),
                        const SizedBox(width: kSpacingXSmall),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kListTypes[_type]!["name"]!,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                kListTypes[_type]!["description"]!,
                                style: theme.textTheme.bodySmall,
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
                    lastDate: DateTime.now().add(kMaxEventDateRange),
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
                          ? theme.colorScheme.onSurfaceVariant.withValues(alpha: kOpacityHigh)
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
                onChanged: (_) => setState(() {}),
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
            onPressed: _isSubmitting ? null : () {
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