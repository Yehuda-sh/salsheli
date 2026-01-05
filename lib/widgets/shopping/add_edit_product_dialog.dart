// 📄 lib/widgets/shopping/add_edit_product_dialog.dart
//
// דיאלוג הוספה/עריכה של מוצר - שם, מותג, קטגוריה, כמות ומחיר.
// כולל validation, Sticky Notes design, אנימציות ותמיכה בנגישות.
//
// ✅ אבטחות:
//    - מניעת קריסה כשקטגוריה לא קיימת ברשימה
//    - null safety מלא ל-quantity/unitPrice
//    - מניעת שמירה כפולה (_isSaving flag)
//    - אישור יציאה כשיש שינויים לא שמורים
//    - InputFormatters למניעת קלט לא תקין
//    - תמיכה בפסיק כמפריד עשרוני (12,5 → 12.5)
//
// 🔗 Related: UnifiedListItem, StickyNote, StickyButton, showGeneralDialog

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../core/status_colors.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/unified_list_item.dart';
import '../common/sticky_button.dart';
import '../common/sticky_note.dart';

class AddEditProductDialog extends StatefulWidget {
  final UnifiedListItem? item;
  final void Function(UnifiedListItem item) onSave;
  final List<String> categories;

  const AddEditProductDialog({
    super.key,
    this.item,
    required this.onSave,
    this.categories = const [],
  });

  @override
  State<AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends State<AddEditProductDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  String? _selectedCategory;
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _brandController = TextEditingController(text: widget.item?.brand ?? '');

    // ✅ Safe null handling for quantity and price
    final quantity = widget.item?.quantity;
    _quantityController = TextEditingController(
      text: quantity != null ? quantity.toString() : '1',
    );

    final price = widget.item?.unitPrice;
    _priceController = TextEditingController(
      text: price != null && price > 0 ? price.toString() : '',
    );

    // ✅ Validate category exists in list, otherwise set to null
    final itemCategory = widget.item?.category;
    _selectedCategory = (itemCategory != null && widget.categories.contains(itemCategory))
        ? itemCategory
        : null;

    // Track changes for exit confirmation
    _nameController.addListener(_markChanged);
    _brandController.addListener(_markChanged);
    _quantityController.addListener(_markChanged);
    _priceController.addListener(_markChanged);
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    unawaited(HapticFeedback.heavyImpact());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: kSpacingSmall),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: StatusColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// ✅ Exit confirmation when form has unsaved changes
  Future<bool> _confirmExit() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.common.unsavedChangesTitle),
        content: Text(AppStrings.common.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.common.stayHere),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.common.exitWithoutSaving),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _handleCancel() async {
    if (await _confirmExit()) {
      unawaited(HapticFeedback.lightImpact());
      if (mounted) Navigator.pop(context);
    }
  }

  void _handleSave() {
    // ✅ Prevent double-save
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final brand = _brandController.text.trim();
    final qtyText = _quantityController.text.trim();
    // ✅ Support comma as decimal separator (Israeli convention)
    final priceText = _priceController.text.trim().replaceAll(',', '.');

    // ✅ Validation מלא
    if (name.isEmpty) {
      setState(() => _isSaving = false);
      _showErrorSnackBar(AppStrings.listDetails.productNameEmpty);
      return;
    }

    final qty = int.tryParse(qtyText);
    if (qty == null || qty <= 0 || qty > 9999) {
      setState(() => _isSaving = false);
      _showErrorSnackBar(AppStrings.listDetails.quantityInvalid);
      return;
    }

    final unitPrice = priceText.isEmpty ? 0.0 : double.tryParse(priceText);
    if (unitPrice == null || unitPrice < 0) {
      setState(() => _isSaving = false);
      _showErrorSnackBar(AppStrings.listDetails.priceInvalid);
      return;
    }

    // ✨ Haptic feedback להצלחה
    unawaited(HapticFeedback.mediumImpact());

    final newItem = UnifiedListItem.product(
      id: widget.item?.id ?? const Uuid().v4(),
      name: name,
      quantity: qty,
      unitPrice: unitPrice,
      unit: "יח'",
      brand: brand.isEmpty ? null : brand,
      category: _selectedCategory,
    );

    // ✅ Safe save with error handling
    try {
      widget.onSave(newItem);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showErrorSnackBar(AppStrings.common.saveFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isEditMode = widget.item != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(kSpacingMedium),
      child: StickyNote(
        color: kStickyYellow,
        rotation: 0.01,
        padding: 0,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(kSpacingMedium),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🏷️ כותרת
                Row(
                  children: [
                    Icon(
                      isEditMode ? Icons.edit : Icons.add_shopping_cart,
                      color: cs.primary,
                      size: kIconSizeLarge,
                    ),
                    const SizedBox(width: kSpacingSmall),
                    Text(
                      isEditMode
                          ? AppStrings.listDetails.editProductTitle
                          : AppStrings.listDetails.addProductTitle,
                      style: TextStyle(
                        fontSize: kFontSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: kSpacingMedium),
                const Divider(),
                const SizedBox(height: kSpacingSmall),

                // 📝 שם המוצר
                TextField(
                  controller: _nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: AppStrings.listDetails.productNameLabel,
                    prefixIcon: const Icon(Icons.shopping_bag_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.7),
                  ),
                  textDirection: ui.TextDirection.rtl,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: kSpacingSmall),

                // 🏢 חברה/מותג
                TextField(
                  controller: _brandController,
                  decoration: InputDecoration(
                    labelText: AppStrings.listDetails.brandLabel,
                    prefixIcon: const Icon(Icons.business_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.7),
                  ),
                  textDirection: ui.TextDirection.rtl,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: kSpacingSmall),

                // 🏷️ קטגוריה
                if (widget.categories.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: AppStrings.listDetails.categoryLabel,
                      prefixIcon: const Icon(Icons.category_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.7),
                    ),
                    hint: Text(AppStrings.listDetails.selectCategory),
                    isExpanded: true,
                    items: widget.categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(
                          category,
                          textDirection: ui.TextDirection.rtl,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      unawaited(HapticFeedback.selectionClick());
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: kSpacingSmall),
                ],

                // 🔢 כמות ומחיר - בשורה אחת
                Row(
                  children: [
                    // כמות
                    Expanded(
                      child: TextField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: AppStrings.listDetails.quantityLabel,
                          prefixIcon: const Icon(Icons.numbers),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.7),
                        ),
                        keyboardType: TextInputType.number,
                        // ✅ LTR for numbers - looks more natural
                        textDirection: ui.TextDirection.ltr,
                        textAlign: TextAlign.center,
                        textInputAction: TextInputAction.next,
                        // ✅ Only allow digits
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                      ),
                    ),
                    const SizedBox(width: kSpacingSmall),
                    // מחיר
                    Expanded(
                      child: TextField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: AppStrings.listDetails.priceLabel,
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.7),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        // ✅ LTR for numbers - looks more natural
                        textDirection: ui.TextDirection.ltr,
                        textAlign: TextAlign.center,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleSave(),
                        // ✅ Allow digits, dot, and comma (Israeli decimal separator)
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                          LengthLimitingTextInputFormatter(10),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: kSpacingMedium),

                // 🔘 כפתורי פעולה
                Row(
                  children: [
                    // ביטול
                    Expanded(
                      child: Semantics(
                        label: AppStrings.common.cancel,
                        button: true,
                        child: StickyButton(
                          label: AppStrings.common.cancel,
                          icon: Icons.close,
                          color: Colors.white,
                          textColor: cs.onSurface,
                          // ✅ Use _handleCancel for exit confirmation
                          onPressed: _handleCancel,
                        ),
                      ),
                    ),
                    const SizedBox(width: kSpacingSmall),
                    // שמור
                    Expanded(
                      child: Semantics(
                        label: AppStrings.common.save,
                        button: true,
                        child: StickyButton(
                          label: _isSaving
                              ? AppStrings.common.loading
                              : AppStrings.common.save,
                          icon: _isSaving ? Icons.hourglass_empty : Icons.check,
                          color: StatusColors.success,
                          textColor: Colors.white,
                          // ✅ Disable button while saving
                          onPressed: _isSaving ? null : _handleSave,
                        ),
                      ),
                    ),
                  ],
                ),

                // ✅ Keyboard padding - prevents fields from hiding behind keyboard
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? kSpacingMedium : 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 🎬 פונקציית עזר להצגת הדיאלוג עם אנימציה
Future<void> showAddEditProductDialog(
  BuildContext context, {
  UnifiedListItem? item,
  required void Function(UnifiedListItem item) onSave,
  List<String> categories = const [],
}) {
  return showGeneralDialog(
    context: context,
    // ✅ Disabled barrier dismiss to prevent accidental data loss
    // Exit confirmation is handled inside the dialog
    barrierDismissible: false,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ),
        child: FadeTransition(
          opacity: animation,
          child: AddEditProductDialog(
            item: item,
            onSave: onSave,
            categories: categories,
          ),
        ),
      );
    },
  );
}
