// 📄 File: lib/screens/lists/template_form_screen.dart
//
// Purpose: טופס יצירה/עריכה של תבנית רשימה
//
// Features:
// - Form validation מלא
// - שדות: שם, תיאור, אייקון (21 types), פורמט
// - רשימת פריטים עם Add/Remove/Edit
// - כל פריט: שם, קטגוריה, כמות, יחידה
// - Validation: שם חובה, לפחות פריט אחד
// - Save עם loading state
//
// Dependencies:
// - TemplatesProvider - יצירה/עדכון תבניות
// - Template Model - מבנה נתונים
// - constants.dart - kListTypes
//
// Usage:
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (_) => TemplateFormScreen(template: existingTemplate),
//   ),
// );

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/templates_provider.dart';
import '../../providers/user_context.dart';
import '../../models/template.dart';
import '../../core/constants.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';

class TemplateFormScreen extends StatefulWidget {
  final Template? template; // null = יצירה, לא null = עריכה

  const TemplateFormScreen({super.key, this.template});

  @override
  State<TemplateFormScreen> createState() => _TemplateFormScreenState();
}

class _TemplateFormScreenState extends State<TemplateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _type = 'super';
  String _defaultFormat = 'personal'; // personal, shared, assigned
  List<TemplateItem> _defaultItems = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    debugPrint('📝 TemplateFormScreen.initState()');

    // טעינת נתונים אם עריכה
    if (widget.template != null) {
      final t = widget.template!;
      _nameController.text = t.name;
      _descriptionController.text = t.description;
      _type = t.type;
      _defaultFormat = t.defaultFormat;
      _defaultItems = List.from(t.defaultItems);
      debugPrint('   ✏️ עריכה: ${t.name}, ${_defaultItems.length} פריטים');
    } else {
      debugPrint('   ➕ יצירה חדשה');
    }
  }

  @override
  void dispose() {
    debugPrint('🗑️ TemplateFormScreen.dispose()');
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.template != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? AppStrings.templates.formTitleEdit
              : AppStrings.templates.formTitleCreate,
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(kSpacingMedium),
          children: [
            // ========================================
            // שם התבנית
            // ========================================
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppStrings.templates.nameLabel,
                hintText: AppStrings.templates.nameHint,
                prefixIcon: const Icon(Icons.text_fields),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.templates.nameRequired;
                }
                return null;
              },
              textDirection: TextDirection.rtl,
              enabled: !_isSaving,
            ),
            const SizedBox(height: kSpacingMedium),

            // ========================================
            // תיאור (אופציונלי)
            // ========================================
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: AppStrings.templates.descriptionLabel,
                hintText: AppStrings.templates.descriptionHint,
                prefixIcon: const Icon(Icons.description_outlined),
              ),
              maxLines: 3,
              textDirection: TextDirection.rtl,
              enabled: !_isSaving,
            ),
            const SizedBox(height: kSpacingMedium),

            // ========================================
            // סוג רשימה (אייקון)
            // ========================================
            _buildListTypeSelector(theme),
            const SizedBox(height: kSpacingMedium),

            // ========================================
            // פורמט
            // ========================================
            _buildFormatSelector(theme),
            const SizedBox(height: kSpacingLarge),

            // ========================================
            // כותרת רשימת פריטים
            // ========================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.templates.itemsLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _isSaving ? null : _addItem,
                  icon: const Icon(Icons.add, size: kIconSizeMedium),
                  label: Text(AppStrings.templates.addItemButton),
                ),
              ],
            ),
            const SizedBox(height: kSpacingSmall),

            // ========================================
            // רשימת פריטים
            // ========================================
            if (_defaultItems.isEmpty)
              _buildEmptyItems(theme)
            else
              ..._defaultItems.asMap().entries.map((entry) {
                return _buildItemCard(entry.key, entry.value, theme);
              }),

            const SizedBox(height: kSpacingLarge),

            // ========================================
            // כפתורי שמירה/ביטול
            // ========================================
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(kButtonHeight),
                    ),
                    child: Text(AppStrings.templates.cancelButton),
                  ),
                ),
                const SizedBox(width: kSpacingMedium),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveTemplate,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(kButtonHeight),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(AppStrings.templates.saveButton),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // List Type Selector (Dropdown)
  // ========================================
  Widget _buildListTypeSelector(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: _type,
      decoration: InputDecoration(
        labelText: AppStrings.templates.iconLabel,
        hintText: AppStrings.templates.iconHint,
        prefixIcon: const Icon(Icons.category_outlined),
      ),
      items: kListTypes.entries.map((entry) {
        return DropdownMenuItem(
          value: entry.key,
          child: Row(
            children: [
              Text(
                entry.value['icon']!,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: kSpacingSmall),
              Text(entry.value['name']!),
            ],
          ),
        );
      }).toList(),
      onChanged: _isSaving
          ? null
          : (value) {
              if (value != null) {
                debugPrint('🔄 סוג רשימה שונה ל: $value');
                setState(() => _type = value);
              }
            },
      isExpanded: true,
    );
  }

  // ========================================
  // Format Selector (Radio Buttons)
  // ========================================
  Widget _buildFormatSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.templates.formatLabel,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: kSpacingSmall),

        // Personal
        ListTile(
          title: Text(AppStrings.templates.formatPersonal),
          subtitle: Text(
            AppStrings.templates.formatPersonalDesc,
            style: theme.textTheme.bodySmall,
          ),
          leading: Radio<String>(
            value: 'personal',
            groupValue: _defaultFormat,
            onChanged: _isSaving
                ? null
                : (value) {
                    if (value != null) {
                      debugPrint('🔄 פורמט שונה ל: personal');
                      setState(() => _defaultFormat = value);
                    }
                  },
          ),
        ),

        // Shared
        ListTile(
          title: Text(AppStrings.templates.formatShared),
          subtitle: Text(
            AppStrings.templates.formatSharedDesc,
            style: theme.textTheme.bodySmall,
          ),
          leading: Radio<String>(
            value: 'shared',
            groupValue: _defaultFormat,
            onChanged: _isSaving
                ? null
                : (value) {
                    if (value != null) {
                      debugPrint('🔄 פורמט שונה ל: shared');
                      setState(() => _defaultFormat = value);
                    }
                  },
          ),
        ),

        // Assigned
        ListTile(
          title: Text(AppStrings.templates.formatAssigned),
          subtitle: Text(
            AppStrings.templates.formatAssignedDesc,
            style: theme.textTheme.bodySmall,
          ),
          leading: Radio<String>(
            value: 'assigned',
            groupValue: _defaultFormat,
            onChanged: _isSaving
                ? null
                : (value) {
                    if (value != null) {
                      debugPrint('🔄 פורמט שונה ל: assigned');
                      setState(() => _defaultFormat = value);
                    }
                  },
          ),
        ),
      ],
    );
  }

  // ========================================
  // Empty Items State
  // ========================================
  Widget _buildEmptyItems(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(kSpacingLarge),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(kBorderRadius),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: kIconSizeLarge,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            AppStrings.templates.noItemsYet,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ========================================
  // Item Card
  // ========================================
  Widget _buildItemCard(int index, TemplateItem item, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${item.quantity} ${item.unit}${item.category != null ? ' • ${item.category}' : ''}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // כפתור עריכה
            IconButton(
              onPressed: _isSaving ? null : () => _editItem(index),
              icon: const Icon(Icons.edit_outlined),
              iconSize: kIconSizeMedium,
              tooltip: AppStrings.templates.editButton,
            ),
            // כפתור מחיקה
            IconButton(
              onPressed: _isSaving ? null : () => _removeItem(index),
              icon: const Icon(Icons.delete_outline),
              iconSize: kIconSizeMedium,
              color: theme.colorScheme.error,
              tooltip: AppStrings.templates.deleteButton,
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // Add/Edit Item Dialog
  // ========================================
  Future<void> _addItem() async {
    debugPrint('➕ פתיחת dialog להוספת פריט');
    final item = await _showItemDialog(context);

    if (item != null) {
      debugPrint('✅ פריט נוסף: ${item.name}');
      setState(() => _defaultItems.add(item));
    }
  }

  Future<void> _editItem(int index) async {
    debugPrint('✏️ פתיחת dialog לעריכת פריט $index');
    final item = await _showItemDialog(context, existing: _defaultItems[index]);

    if (item != null) {
      debugPrint('✅ פריט עודכן: ${item.name}');
      setState(() => _defaultItems[index] = item);
    }
  }

  void _removeItem(int index) {
    debugPrint('🗑️ מחיקת פריט $index: ${_defaultItems[index].name}');
    setState(() => _defaultItems.removeAt(index));
  }

  // ========================================
  // Item Dialog
  // ========================================
  Future<TemplateItem?> _showItemDialog(
    BuildContext context, {
    TemplateItem? existing,
  }) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: existing?.name ?? '');
    final quantityController = TextEditingController(
      text: existing?.quantity.toString() ?? '1',
    );
    final unitController = TextEditingController(text: existing?.unit ?? '');
    String? category = existing?.category;

    return showDialog<TemplateItem>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            existing != null
                ? AppStrings.templates.editButton
                : AppStrings.templates.addItemButton,
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // שם פריט
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: AppStrings.templates.itemNameLabel,
                      hintText: AppStrings.templates.itemNameHint,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.templates.itemNameRequired;
                      }
                      return null;
                    },
                    textDirection: TextDirection.rtl,
                    autofocus: true,
                  ),
                  const SizedBox(height: kSpacingMedium),

                  // קטגוריה
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: InputDecoration(
                      labelText: AppStrings.templates.itemCategoryLabel,
                      hintText: AppStrings.templates.itemCategoryHint,
                    ),
                    items: [
                      'אחר',
                      'ירקות',
                      'פירות',
                      'חלב וביצים',
                      'בשר ודגים',
                      'לחם ומאפים',
                      'מוצרים יבשים',
                      'חומרי ניקיון',
                      'טואלטיקה',
                      'קפואים',
                      'משקאות',
                    ]
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            ))
                        .toList(),
                    onChanged: (value) => category = value,
                  ),
                  const SizedBox(height: kSpacingMedium),

                  // כמות + יחידה
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: quantityController,
                          decoration: InputDecoration(
                            labelText: AppStrings.templates.itemQuantityLabel,
                            hintText: AppStrings.templates.itemQuantityHint,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: false,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      const SizedBox(width: kSpacingSmall),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: unitController,
                          decoration: InputDecoration(
                            labelText: AppStrings.templates.itemUnitLabel,
                            hintText: AppStrings.templates.itemUnitHint,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppStrings.templates.cancelButton),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final quantity = int.tryParse(quantityController.text) ?? 1;

                  final item = TemplateItem(
                    name: nameController.text.trim(),
                    category: category,
                    quantity: quantity,
                    unit: unitController.text.trim().isEmpty
                        ? 'יח׳'
                        : unitController.text.trim(),
                  );

                  Navigator.pop(dialogContext, item);
                }
              },
              child: Text(AppStrings.common.save),
            ),
          ],
        );
      },
    );
  }

  // ========================================
  // Save Template
  // ========================================
  Future<void> _saveTemplate() async {
    debugPrint('💾 TemplateFormScreen._saveTemplate()');

    // Validation
    if (!(_formKey.currentState?.validate() ?? false)) {
      debugPrint('   ⚠️ Validation נכשל');
      return;
    }

    if (_defaultItems.isEmpty) {
      debugPrint('   ⚠️ אין פריטים');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.templates.atLeastOneItem),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final provider = context.read<TemplatesProvider>();
      final isEdit = widget.template != null;

      // קבלת user context לקבלת user_id
      final userContext = context.read<UserContext>();
      final userId = userContext.userId ?? '';
      
      // יצירת/עדכון תבנית (סדר פרמטרים נכון!)
      final template = Template.newTemplate(
        id: widget.template?.id ?? '',
        type: _type,  // סוג רשימה
        name: _nameController.text.trim(),  // שם
        description: _descriptionController.text.trim(),  // תיאור
        icon: kListTypes[_type]?['icon'] ?? '📝',  // אייקון
        createdBy: userId,  // מי יצר
        defaultFormat: _defaultFormat,  // פורמט
        defaultItems: _defaultItems,  // פריטים
        householdId: userContext.householdId,  // משק בית
        isSystem: false,  // לא תבנית מערכת
      );

      if (isEdit) {
        debugPrint('   ✏️ מעדכן תבנית: ${template.name}');
        await provider.updateTemplate(template);
      } else {
        debugPrint('   ➕ יוצר תבנית: ${template.name}');
        await provider.createTemplateFromObject(template);
      }

      if (!mounted) return;

      debugPrint('   ✅ הצלחה!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? AppStrings.templates.templateUpdated(template.name)
                : AppStrings.templates.templateCreated(template.name),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );

      // חזרה למסך הקודם עם אינדיקציה שנשמר
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('   ❌ שגיאה בשמירה: $e');

      if (!mounted) return;

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.template != null
                ? AppStrings.templates.updateError(e.toString())
                : AppStrings.templates.createError(e.toString()),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: kSnackBarDurationLong,
        ),
      );
    }
  }
}
