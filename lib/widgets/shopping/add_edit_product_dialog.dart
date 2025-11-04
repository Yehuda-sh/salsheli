// 📄 File: lib/widgets/shopping/add_edit_product_dialog.dart
// 🎯 דיאלוג הוספה/עריכה של מוצר
//
// תכונות:
// - אנימציות fade + scale
// - Validation מלא
// - תמיכה במצב הוספה ועריכה
// - RTL Support
// - Controllers cleanup אוטומטי

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/unified_list_item.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';

class AddEditProductDialog extends StatefulWidget {
  final UnifiedListItem? item;
  final void Function(UnifiedListItem item) onSave;

  const AddEditProductDialog({
    super.key,
    this.item,
    required this.onSave,
  });

  @override
  State<AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends State<AddEditProductDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? "");
    _quantityController = TextEditingController(text: widget.item?.quantity.toString() ?? "1");
    _priceController = TextEditingController(text: widget.item?.unitPrice.toString() ?? "");

    debugPrint(
      widget.item == null
          ? '➕ AddEditProductDialog: פתיחת דיאלוג הוספת מוצר'
          : '✏️ AddEditProductDialog: פתיחת דיאלוג עריכת "${widget.item!.name}"',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    debugPrint('🗑️ AddEditProductDialog: Controllers disposed');
    super.dispose();
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    final qtyText = _quantityController.text.trim();
    final priceText = _priceController.text.trim();

    // ✅ Validation מלא
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.listDetails.productNameEmpty),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final qty = int.tryParse(qtyText);
    if (qty == null || qty <= 0 || qty > 9999) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.listDetails.quantityInvalid),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final unitPrice = double.tryParse(priceText);
    if (unitPrice == null || unitPrice < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.listDetails.priceInvalid),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newItem = UnifiedListItem.product(
      id: widget.item?.id ?? const Uuid().v4(),
      name: name,
      quantity: qty,
      unitPrice: unitPrice,
      unit: "יח'",
    );

    widget.onSave(newItem);
    Navigator.pop(context);

    debugPrint(
      widget.item == null
          ? '✅ AddEditProductDialog: הוסף מוצר "$name"'
          : '✅ AddEditProductDialog: עדכן מוצר "$name"',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.item == null
            ? AppStrings.listDetails.addProductTitle
            : AppStrings.listDetails.editProductTitle,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: AppStrings.listDetails.productNameLabel,
            ),
            textDirection: ui.TextDirection.rtl,
          ),
          const SizedBox(height: kSpacingSmall),
          TextField(
            controller: _quantityController,
            decoration: InputDecoration(
              labelText: AppStrings.listDetails.quantityLabel,
            ),
            keyboardType: TextInputType.number,
            textDirection: ui.TextDirection.rtl,
          ),
          const SizedBox(height: kSpacingSmall),
          TextField(
            controller: _priceController,
            decoration: InputDecoration(
              labelText: AppStrings.listDetails.priceLabel,
            ),
            keyboardType: TextInputType.number,
            textDirection: ui.TextDirection.rtl,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            debugPrint('❌ AddEditProductDialog: ביטול דיאלוג');
            Navigator.pop(context);
          },
          child: Text(AppStrings.common.cancel),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          child: Text(AppStrings.common.save),
        ),
      ],
    );
  }
}

/// 🎬 פונקציית עזר להצגת הדיאלוג עם אנימציה
Future<void> showAddEditProductDialog(
  BuildContext context, {
  UnifiedListItem? item,
  required void Function(UnifiedListItem item) onSave,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
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
          ),
        ),
      );
    },
  );
}
