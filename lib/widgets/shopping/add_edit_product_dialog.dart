// 📄 File: lib/widgets/shopping/add_edit_product_dialog.dart
// 🎯 דיאלוג הוספה/עריכה של מוצר
//
// תכונות:
// - אנימציות fade + scale
// - Validation מלא
// - תמיכה במצב הוספה ועריכה
// - RTL Support
// - Controllers cleanup אוטומטי
// - בחירת קטגוריה וחברה/מותג
// - Sticky Notes Design System
// - Haptic Feedback
// - StatusColors לשגיאות
// - Semantics לנגישות

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _brandController = TextEditingController(text: widget.item?.brand ?? '');
    _quantityController = TextEditingController(text: widget.item?.quantity.toString() ?? '1');
    _priceController = TextEditingController(text: widget.item?.unitPrice.toString() ?? '');
    _selectedCategory = widget.item?.category;
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

  void _handleSave() {
    final name = _nameController.text.trim();
    final brand = _brandController.text.trim();
    final qtyText = _quantityController.text.trim();
    final priceText = _priceController.text.trim();

    // ✅ Validation מלא
    if (name.isEmpty) {
      _showErrorSnackBar(AppStrings.listDetails.productNameEmpty);
      return;
    }

    final qty = int.tryParse(qtyText);
    if (qty == null || qty <= 0 || qty > 9999) {
      _showErrorSnackBar(AppStrings.listDetails.quantityInvalid);
      return;
    }

    final unitPrice = priceText.isEmpty ? 0.0 : double.tryParse(priceText);
    if (unitPrice == null || unitPrice < 0) {
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

    widget.onSave(newItem);
    Navigator.pop(context);
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
                        textDirection: ui.TextDirection.rtl,
                        textInputAction: TextInputAction.next,
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
                        textDirection: ui.TextDirection.rtl,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleSave(),
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
                          onPressed: () {
                            unawaited(HapticFeedback.lightImpact());
                            Navigator.pop(context);
                          },
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
                          label: AppStrings.common.save,
                          icon: Icons.check,
                          color: StatusColors.success,
                          textColor: Colors.white,
                          onPressed: _handleSave,
                        ),
                      ),
                    ),
                  ],
                ),
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
    barrierDismissible: true,
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
