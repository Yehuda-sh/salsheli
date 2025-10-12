// 📄 File: lib/widgets/create_list_dialog.dart
// 
// Purpose: Dialog ליצירת רשימת קניות חדשה עם validation מלא
// 
// Features:
// - Validation למניעת שמות כפולים
// - Validation לתקציב (חייב > 0)
// - Preview ויזואלי לסוג הרשימה הנבחר
// - תמיכה בכל 21 סוגי הרשימות מ-constants.dart
// - תצוגה מקובצת: קניות יומיומיות, מיוחדות, אירועים
// - Logging מלא לכל השלבים
// - Clear button לניקוי תקציב
// - Accessibility: Tooltips על כל הכפתורים
//
// Dependencies:
// - ShoppingListsProvider - לבדיקת שמות כפולים
// - constants.dart - kListTypes (סוגי רשימות + אייקונים)
// - list_type_groups.dart - ListTypeGroups (קיבוץ ב-3 קבוצות)
//
// Usage Example:
// showDialog(
//   context: context,
//   builder: (dialogContext) => CreateListDialog(
//     onCreateList: (data) async {
//       await context.read<ShoppingListsProvider>().createList(data);
//     },
//   ),
// );

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/ui_constants.dart';
import '../config/list_type_groups.dart';
import '../providers/shopping_lists_provider.dart';
import '../providers/templates_provider.dart';
import '../models/template.dart';

class CreateListDialog extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic>) onCreateList;

  const CreateListDialog({super.key, required this.onCreateList});

  @override
  State<CreateListDialog> createState() => _CreateListDialogState();
}

class _CreateListDialogState extends State<CreateListDialog> {
  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController(); // ⭐ Controller לתקציב

  String _name = "";
  String _type = "super";
  double? _budget;
  DateTime? _eventDate; // 🎂 תאריך אירוע
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🔵 CreateListDialog.initState() - Dialog נפתח');
    
    // טען תבניות
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TemplatesProvider>().loadTemplates();
      }
    });
  }

  @override
  void dispose() {
    debugPrint('🔵 CreateListDialog.dispose() - Dialog נסגר');
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    debugPrint('🔵 CreateListDialog._handleSubmit() התחיל');

    if (!(_formKey.currentState?.validate() ?? false)) {
      debugPrint('   ⚠️ Validation נכשל');
      return;
    }

    _formKey.currentState?.save();
    debugPrint(
      '   📝 שם: "$_name", סוג: "$_type", תקציב: ${_budget ?? "לא הוגדר"}',
    );

    setState(() => _isSubmitting = true);

    final listData = {
      "name": _name,
      "type": _type,
      "status": "active",
      if (_budget != null) "budget": _budget,
      if (_eventDate != null) "eventDate": _eventDate,
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
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('   ❌ שגיאה ב-onCreateList: $e');

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה ביצירת הרשימה: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ========================================
  // Templates Bottom Sheet
  // ========================================
  Future<void> _showTemplatesBottomSheet() async {
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
              builder: (_, provider, __) {
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
                                  'בחר תבנית',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'בחר תבנית כדי למלא את הרשימה אוטומטית',
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
                      const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),

                    // Error State
                    if (provider.hasError)
                      Expanded(
                        child: Center(
                          child: Text(
                            'שגיאה בטעינת תבניות: ${provider.errorMessage}',
                            textAlign: TextAlign.center,
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
                                'אין תבניות זמינות',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: kSpacingSmall),
                              Text(
                                'צור תבנית ראשונה במסך התבניות',
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
                                  '${template.defaultItems.length} פריטים • ${typeInfo['name']}',
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

    // מילוי נתונים מהתבנית
    if (template != null) {
      debugPrint('✨ ממלא נתונים מתבנית: ${template.name}');
      setState(() {
        _type = template.type;
      });

      // TODO: בעתיד - להעביר גם את הפריטים מהתבנית
      // כרגע רק הסוג ממולא

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('תבנית "${template.name}" נבחרה'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ========================================
  // 🎭 תצוגה מקובצת של סוגי רשימות
  // ========================================

  /// בניית selector מקובץ לפי קבוצות
  ///
  /// מציג 3 קבוצות עם ExpansionTile:
  /// 1. 🛒 קניות יומיומיות (2 סוגים)
  /// 2. 🎯 קניות מיוחדות (12 סוגים)
  /// 3. 🎉 אירועים (6 סוגים)
  Widget _buildGroupedTypeSelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Label
        Text(
          'סוג הרשימה',
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

  /// בניית ExpansionTile לקבוצה אחת
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
                'נבחר',
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

  /// בניית chip לסוג אחד
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
            : theme.colorScheme.outline.withValues(alpha: kOpacityLow),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.read<ShoppingListsProvider>();

    return AlertDialog(
      insetPadding: kPaddingDialog,
      title: const Text("יצירת רשימת קניות חדשה", textAlign: TextAlign.right),
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
              // 📋 כפתור שימוש בתבנית
              // ========================================
              OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _showTemplatesBottomSheet,
                icon: const Icon(Icons.library_books_outlined),
                label: const Text('📋 שימוש בתבנית'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(kButtonHeight),
                ),
              ),
              const SizedBox(height: kSpacingMedium),

              // 📝 שם הרשימה
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "שם הרשימה",
                  hintText: "למשל: קניות השבוע",
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "נא להזין שם רשימה";
                  }

                  // בדיקת שם כפול
                  final trimmedName = value.trim();
                  final exists = provider.lists.any(
                    (list) =>
                        list.name.trim().toLowerCase() ==
                        trimmedName.toLowerCase(),
                  );

                  if (exists) {
                    return "רשימה בשם זה כבר קיימת";
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

              // ✨ Preview של הסוג שנבחר
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
                child: Row(
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
              ),
              const SizedBox(height: kSpacingSmallPlus),

              // 👆 תאריך אירוע (אופציונלי)
              InkWell(
                onTap: _isSubmitting ? null : () async {
                  debugPrint('📅 פותח DatePicker');
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _eventDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(kMaxEventDateRange),
                    helpText: 'בחר תאריך אירוע',
                    cancelText: 'ביטול',
                    confirmText: 'אישור',
                  );
                  
                  if (selectedDate != null) {
                    debugPrint('   ✅ תאריך נבחר: $selectedDate');
                    setState(() => _eventDate = selectedDate);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'תאריך אירוע (אופציונלי)',
                    hintText: 'למשל: יום הולדת, אירוח',
                    prefixIcon: const Icon(Icons.event),
                    suffixIcon: _eventDate != null
                        ? Tooltip(
                            message: 'נקה תאריך',
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
                        ? 'אין תאריך'
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
                  labelText: "תקציב (אופציונלי)",
                  hintText: "₪500",
                  prefixIcon: const Icon(Icons.monetization_on),
                  // ⭐ Clear Button - מופיע רק כשיש טקסט
                  suffixIcon: _budgetController.text.isNotEmpty
                      ? Tooltip(
                          message: 'נקה תקציב',
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
                      return 'נא להזין מספר תקין';
                    }

                    if (amount <= 0) {
                      return 'תקציב חייב להיות גדול מ-0';
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
                onChanged: (_) => setState(() {}), // ⭐ עדכון לClear Button
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
          message: 'ביטול יצירת הרשימה',
          child: TextButton(
            onPressed: _isSubmitting ? null : () {
              debugPrint('❌ משתמש ביטל יצירת רשימה');
              Navigator.of(context).pop();
            },
            child: const Text("בטל"),
          ),
        ),
        Tooltip(
          message: 'יצירת הרשימה החדשה',
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
                : const Text("צור רשימה"),
          ),
        ),
      ],
    );
  }
}
