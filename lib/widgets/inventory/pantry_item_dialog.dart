// 📄 File: lib/widgets/inventory/pantry_item_dialog.dart
//
// 🎯 מטרה: דיאלוג מאוחד להוספה ועריכת פריטי מזווה
//
// 📋 כולל:
// - תמיכה בשני מצבים: add/edit
// - ולידציה מלאה של שדות
// - בחירת מיקום אחסון עם אמוג'י
// - תצוגה אדפטיבית לפי theme
//
// 🔗 Dependencies:
// - InventoryItem: המודל של הפריט
// - StorageLocationsConfig: הגדרות מיקומים
// - InventoryProvider: ניהול state
//
// Version: 1.0
// Last Updated: 26/10/2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/storage_locations_config.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/inventory_item.dart';
import '../../providers/inventory_provider.dart';
import '../../theme/app_theme.dart';

enum PantryItemDialogMode {
  add,
  edit,
}

class PantryItemDialog extends StatefulWidget {
  final PantryItemDialogMode mode;
  final InventoryItem? item; // רק ב-edit mode
  final VoidCallback? onSuccess;

  const PantryItemDialog({
    super.key,
    required this.mode,
    this.item,
    this.onSuccess,
  }) : assert(
          mode == PantryItemDialogMode.add || item != null,
          'Item is required in edit mode',
        );

  /// מציג את הדיאלוג להוספת פריט חדש
  static Future<bool?> showAddDialog(
    BuildContext context, {
    VoidCallback? onSuccess,
  }) {
    debugPrint('➕ PantryItemDialog: Opening add dialog');
    return showDialog<bool>(
      context: context,
      builder: (_) => PantryItemDialog(
        mode: PantryItemDialogMode.add,
        onSuccess: onSuccess,
      ),
    );
  }

  /// מציג את הדיאלוג לעריכת פריט קיים
  static Future<bool?> showEditDialog(
    BuildContext context,
    InventoryItem item, {
    VoidCallback? onSuccess,
  }) {
    debugPrint('✏️ PantryItemDialog: Opening edit dialog for ${item.id}');
    return showDialog<bool>(
      context: context,
      builder: (_) => PantryItemDialog(
        mode: PantryItemDialogMode.edit,
        item: item,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<PantryItemDialog> createState() => _PantryItemDialogState();
}

class _PantryItemDialogState extends State<PantryItemDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late String _selectedLocation;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with values based on mode
    if (widget.mode == PantryItemDialogMode.edit && widget.item != null) {
      final item = widget.item!;
      _nameController = TextEditingController(text: item.productName);
      _categoryController = TextEditingController(text: item.category);
      _quantityController = TextEditingController(text: item.quantity.toString());
      _unitController = TextEditingController(text: item.unit);
      _selectedLocation = item.location;
    } else {
      _nameController = TextEditingController();
      _categoryController = TextEditingController();
      _quantityController = TextEditingController(text: '1');
      _unitController = TextEditingController(text: 'יח\'');
      _selectedLocation = StorageLocationsConfig.mainPantry;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  /// מבצע ולידציה ושומר את הפריט
  Future<void> _saveItem() async {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.inventory.productNameRequired),
          duration: kSnackBarDuration,
        ),
      );
      return;
    }

    if (_categoryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.inventory.categoryRequired),
          duration: kSnackBarDuration,
        ),
      );
      return;
    }

    final quantity = int.tryParse(_quantityController.text) ?? 1;
    final productName = _nameController.text.trim();
    final category = _categoryController.text.trim();
    final unit = _unitController.text.trim();

    setState(() => _isLoading = true);

    try {
      final provider = context.read<InventoryProvider>();

      if (widget.mode == PantryItemDialogMode.add) {
        await provider.createItem(
          productName: productName,
          category: category,
          location: _selectedLocation,
          quantity: quantity,
          unit: unit,
        );
      } else {
        final updatedItem = widget.item!.copyWith(
          productName: productName,
          category: category,
          location: _selectedLocation,
          quantity: quantity,
          unit: unit,
        );
        await provider.updateItem(updatedItem);
      }

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.mode == PantryItemDialogMode.add
              ? AppStrings.inventory.itemAdded
              : AppStrings.inventory.itemUpdated),
          duration: kSnackBarDuration,
        ),
      );

      // Call success callback if provided
      widget.onSuccess?.call();

      // Close dialog with success result
      Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint('❌ PantryItemDialog: Error saving item - $e');
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.mode == PantryItemDialogMode.add
              ? AppStrings.inventory.addError
              : AppStrings.inventory.updateError),
          backgroundColor: Colors.red,
          duration: kSnackBarDuration,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    final title = widget.mode == PantryItemDialogMode.add 
        ? AppStrings.inventory.addDialogTitle
        : AppStrings.inventory.editDialogTitle;

    final actionLabel = widget.mode == PantryItemDialogMode.add 
        ? AppStrings.inventory.addButton
        : AppStrings.inventory.saveButton;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text(
          title,
          style: TextStyle(color: accent),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product name field
              TextField(
                controller: _nameController,
                style: TextStyle(color: cs.onSurface),
                decoration: InputDecoration(
                  labelText: AppStrings.inventory.productNameLabel,
                  labelStyle: TextStyle(color: cs.onSurfaceVariant),
                  hintText: AppStrings.inventory.productNameHint,
                  hintStyle: TextStyle(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: kSpacingMedium),

              // Category field
              TextField(
                controller: _categoryController,
                style: TextStyle(color: cs.onSurface),
                decoration: InputDecoration(
                  labelText: AppStrings.inventory.categoryLabel,
                  labelStyle: TextStyle(color: cs.onSurfaceVariant),
                  hintText: AppStrings.inventory.categoryHint,
                  hintStyle: TextStyle(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: kSpacingMedium),

              // Quantity and unit fields
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: cs.onSurface),
                      decoration: InputDecoration(
                        labelText: AppStrings.inventory.quantityLabel,
                        labelStyle: TextStyle(color: cs.onSurfaceVariant),
                      ),
                      enabled: !_isLoading,
                    ),
                  ),
                  const SizedBox(width: kSpacingMedium),
                  Expanded(
                    child: TextField(
                      controller: _unitController,
                      style: TextStyle(color: cs.onSurface),
                      decoration: InputDecoration(
                        labelText: AppStrings.inventory.unitLabel,
                        labelStyle: TextStyle(color: cs.onSurfaceVariant),
                        hintText: AppStrings.inventory.unitHint,
                        hintStyle: TextStyle(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      enabled: !_isLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: kSpacingMedium),

              // Location dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedLocation,
                dropdownColor: cs.surface,
                style: TextStyle(color: cs.onSurface),
                decoration: InputDecoration(
                  labelText: AppStrings.inventory.locationLabel,
                  labelStyle: TextStyle(color: cs.onSurfaceVariant),
                  enabled: !_isLoading,
                ),
                items: StorageLocationsConfig.allLocations
                    .map((locationId) {
                  final info = StorageLocationsConfig.getLocationInfo(locationId);
                  return DropdownMenuItem(
                    value: locationId,
                    child: Row(
                      children: [
                        Text(info.emoji),
                        const SizedBox(width: kSpacingSmall),
                        Text(info.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: _isLoading
                    ? null
                    : (val) {
                        if (val != null) {
                          setDialogState(() => _selectedLocation = val);
                        }
                      },
              ),
            ],
          ),
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: _isLoading
                ? null
                : () => Navigator.pop(context, false),
            child: Text(AppStrings.common.cancel),
          ),
          
          // Save/Add button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              minimumSize: const Size(kButtonHeight, kButtonHeight),
            ),
            onPressed: _isLoading ? null : _saveItem,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(actionLabel),
          ),
        ],
        ),
      ),
    );
  }
}
