// 📄 File: lib/widgets/inventory/pantry_item_dialog.dart
//
// 🎯 מטרה: דיאלוג מאוחד להוספה ועריכת פריטי מזווה
//
// 📋 כולל:
// - תמיכה בשני מצבים: add/edit
// - ולידציה מלאה של שדות
// - בחירת מיקום אחסון עם אמוג'י
// - תצוגה אדפטיבית לפי theme
// - תאריך תפוגה (DatePicker)
// - הערות (TextField)
// - מוצר קבוע (Checkbox)
// - סטטיסטיקות קנייה (read-only)
//
// 🔗 Dependencies:
// - InventoryItem: המודל של הפריט
// - StorageLocationsConfig: הגדרות מיקומים
// - InventoryProvider: ניהול state
//
// Version: 2.0
// Last Updated: 16/12/2025

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../../config/filters_config.dart';
import '../../config/storage_locations_config.dart';
import '../../core/status_colors.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/custom_location.dart';
import '../../models/inventory_item.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/locations_provider.dart';
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
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late final TextEditingController _minQuantityController;
  late final TextEditingController _notesController;
  late String _selectedCategory;
  late String _selectedLocation;

  // שדות חדשים v3.0
  DateTime? _expiryDate;
  bool _isRecurring = false;

  bool _isLoading = false;
  bool _hasChanges = false; // 🛡️ מעקב אחר שינויים לאישור יציאה

  @override
  void initState() {
    super.initState();

    // Initialize controllers with values based on mode
    if (widget.mode == PantryItemDialogMode.edit && widget.item != null) {
      final item = widget.item!;
      _nameController = TextEditingController(text: item.productName);
      _quantityController =
          TextEditingController(text: item.quantity.toString());
      _unitController = TextEditingController(text: item.unit);
      _minQuantityController =
          TextEditingController(text: item.minQuantity.toString());
      _notesController = TextEditingController(text: item.notes ?? '');
      // המר קטגוריה עברית למפתח אנגלית, או השתמש ב-other כברירת מחדל
      _selectedCategory = hebrewCategoryToEnglish(item.category) ?? 'other';
      _selectedLocation = item.location;
      // שדות חדשים
      _expiryDate = item.expiryDate;
      _isRecurring = item.isRecurring;
    } else {
      _nameController = TextEditingController();
      _quantityController = TextEditingController(text: '1');
      _unitController = TextEditingController(text: 'יח\'');
      _minQuantityController = TextEditingController(text: '2');
      _notesController = TextEditingController();
      _selectedCategory = 'other';
      _selectedLocation = StorageLocationsConfig.mainPantry;
    }

    // 🛡️ Track changes for exit confirmation
    _nameController.addListener(_markChanged);
    _quantityController.addListener(_markChanged);
    _unitController.addListener(_markChanged);
    _minQuantityController.addListener(_markChanged);
    _notesController.addListener(_markChanged);
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
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
      if (mounted) Navigator.pop(context, false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _minQuantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// בונה widget סטטיסטיקות
  Widget _buildStatistics(InventoryItem item, ColorScheme cs) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'סטטיסטיקות',
          style: TextStyle(
            fontSize: kFontSizeSmall,
            fontWeight: FontWeight.bold,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: kSpacingSmall),
        Row(
          children: [
            const Icon(Icons.shopping_cart, size: 16),
            const SizedBox(width: 4),
            Text(
              'נקנה ${item.purchaseCount} פעמים',
              style: TextStyle(
                fontSize: kFontSizeSmall,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
        if (item.lastPurchased != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.history, size: 16),
              const SizedBox(width: 4),
              Text(
                'קנייה אחרונה: ${dateFormat.format(item.lastPurchased!)}',
                style: TextStyle(
                  fontSize: kFontSizeSmall,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
        if (item.isPopular) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.trending_up, size: 16, color: StatusColors.getStatusColor('success', context)),
              const SizedBox(width: 4),
              Text(
                'מוצר פופולרי!',
                style: TextStyle(
                  fontSize: kFontSizeSmall,
                  color: StatusColors.getStatusColor('success', context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// בחירת תאריך תפוגה
  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
      locale: const Locale('he', 'IL'),
      helpText: 'בחר תאריך תפוגה',
      cancelText: 'ביטול',
      confirmText: 'אישור',
    );

    if (picked != null && mounted) {
      unawaited(HapticFeedback.lightImpact());
      setState(() {
        _expiryDate = picked;
        _hasChanges = true; // 🛡️ Track change
      });
    }
  }

  /// מבצע ולידציה ושומר את הפריט
  Future<void> _saveItem() async {
    // 🛡️ מניעת לחיצה כפולה
    if (_isLoading) return;

    // Validation - שם
    if (_nameController.text.trim().isEmpty) {
      unawaited(HapticFeedback.heavyImpact());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.inventory.productNameRequired),
          backgroundColor: StatusColors.getStatusColor('error', context),
          duration: kSnackBarDuration,
        ),
      );
      return;
    }

    // Validation - כמות
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    if (quantity <= 0) {
      unawaited(HapticFeedback.heavyImpact());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('כמות חייבת להיות גדולה מאפס'),
          backgroundColor: StatusColors.getStatusColor('error', context),
          duration: kSnackBarDuration,
        ),
      );
      return;
    }

    final minQuantity = int.tryParse(_minQuantityController.text) ?? 2;
    final productName = _nameController.text.trim();
    // שמור את הקטגוריה בעברית (לתאימות עם שאר המערכת)
    final category = getCategoryLabel(_selectedCategory);
    final unit = _unitController.text.trim();
    final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    setState(() => _isLoading = true);

    // ✨ Haptic feedback לתחילת שמירה
    unawaited(HapticFeedback.mediumImpact());

    try {
      final provider = context.read<InventoryProvider>();

      if (widget.mode == PantryItemDialogMode.add) {
        await provider.createItem(
          productName: productName,
          category: category,
          location: _selectedLocation,
          quantity: quantity,
          unit: unit,
          minQuantity: minQuantity,
          expiryDate: _expiryDate,
          notes: notes,
          isRecurring: _isRecurring,
        );
      } else {
        final updatedItem = widget.item!.copyWith(
          productName: productName,
          category: category,
          location: _selectedLocation,
          quantity: quantity,
          unit: unit,
          minQuantity: minQuantity,
          expiryDate: _expiryDate,
          clearExpiryDate: _expiryDate == null && widget.item!.expiryDate != null,
          notes: notes,
          clearNotes: notes == null && widget.item!.notes != null,
          isRecurring: _isRecurring,
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
          backgroundColor: StatusColors.getStatusColor('error', context),
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
      child: AlertDialog(
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
                textInputAction: TextInputAction.next,
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

              // Category dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                dropdownColor: cs.surface,
                style: TextStyle(color: cs.onSurface),
                decoration: InputDecoration(
                  labelText: AppStrings.inventory.categoryLabel,
                  labelStyle: TextStyle(color: cs.onSurfaceVariant),
                ),
                items: kCategoryInfo.entries
                    .where((e) => e.key != 'all') // לא להציג "הכל"
                    .map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Row(
                      children: [
                        Text(entry.value.emoji),
                        const SizedBox(width: kSpacingSmall),
                        Text(entry.value.label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: _isLoading
                    ? null
                    : (val) {
                        if (val != null) {
                          setState(() => _selectedCategory = val);
                        }
                      },
              ),
              const SizedBox(height: kSpacingMedium),

              // Quantity, unit, and min quantity fields
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(color: cs.onSurface),
                      decoration: InputDecoration(
                        labelText: AppStrings.inventory.quantityLabel,
                        labelStyle: TextStyle(color: cs.onSurfaceVariant),
                      ),
                      enabled: !_isLoading,
                    ),
                  ),
                  const SizedBox(width: kSpacingSmall),
                  Expanded(
                    child: TextField(
                      controller: _unitController,
                      textInputAction: TextInputAction.next,
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
                  const SizedBox(width: kSpacingSmall),
                  // מינימום - מתי להתריע על מלאי נמוך
                  SizedBox(
                    width: 70,
                    child: TextField(
                      controller: _minQuantityController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(color: cs.onSurface),
                      decoration: InputDecoration(
                        labelText: 'מינ\'',
                        labelStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: kFontSizeSmall),
                        helperText: 'התראה',
                        helperStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6), fontSize: kFontSizeTiny),
                      ),
                      enabled: !_isLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: kSpacingMedium),

              // Location dropdown (כולל מיקומים מותאמים)
              Consumer<LocationsProvider>(
                builder: (context, locationsProvider, _) {
                  final customLocations = locationsProvider.customLocations;
                  final allLocations = [
                    ...StorageLocationsConfig.allLocations,
                    ...customLocations.map((c) => c.key),
                  ];

                  // ודא שהמיקום הנבחר קיים ברשימה
                  if (!allLocations.contains(_selectedLocation)) {
                    // אם המיקום לא קיים, הוסף אותו (לתאימות לאחור)
                    allLocations.add(_selectedLocation);
                  }

                  return DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _selectedLocation,
                    dropdownColor: cs.surface,
                    style: TextStyle(color: cs.onSurface),
                    decoration: InputDecoration(
                      labelText: AppStrings.inventory.locationLabel,
                      labelStyle: TextStyle(color: cs.onSurfaceVariant),
                    ),
                    items: allLocations.map((locationId) {
                      // בדוק אם זה מיקום מותאם
                      final customLoc = customLocations.cast<CustomLocation?>().firstWhere(
                        (c) => c?.key == locationId,
                        orElse: () => null,
                      );
                      if (customLoc != null) {
                        return DropdownMenuItem(
                          value: locationId,
                          child: Row(
                            children: [
                              Text(customLoc.emoji),
                              const SizedBox(width: kSpacingSmall),
                              Text(customLoc.name),
                            ],
                          ),
                        );
                      }
                      // מיקום ברירת מחדל
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
                              setState(() => _selectedLocation = val);
                            }
                          },
                  );
                },
              ),
              const SizedBox(height: kSpacingMedium),

              // === שדות חדשים v3.0 ===

              // תאריך תפוגה
              InkWell(
                onTap: _isLoading ? null : _selectExpiryDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'תאריך תפוגה',
                    labelStyle: TextStyle(color: cs.onSurfaceVariant),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_expiryDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: _isLoading
                                ? null
                                : () => setState(() => _expiryDate = null),
                            tooltip: 'נקה תאריך',
                          ),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
                  child: Text(
                    _expiryDate != null
                        ? DateFormat('dd/MM/yyyy').format(_expiryDate!)
                        : 'לא הוגדר',
                    style: TextStyle(
                      color: _expiryDate != null
                          ? cs.onSurface
                          : cs.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: kSpacingMedium),

              // הערות
              TextField(
                controller: _notesController,
                style: TextStyle(color: cs.onSurface),
                maxLines: 2,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'הערות',
                  labelStyle: TextStyle(color: cs.onSurfaceVariant),
                  hintText: 'הערות נוספות (אופציונלי)',
                  hintStyle: TextStyle(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: kSpacingSmall),

              // מוצר קבוע
              CheckboxListTile(
                value: _isRecurring,
                onChanged: _isLoading
                    ? null
                    : (val) {
                        unawaited(HapticFeedback.selectionClick());
                        setState(() {
                          _isRecurring = val ?? false;
                          _hasChanges = true; // 🛡️ Track change
                        });
                      },
                title: const Text('מוצר קבוע'),
                subtitle: const Text(
                  'יתווסף אוטומטית לרשימות חדשות',
                  style: TextStyle(fontSize: 12),
                ),
                secondary: Icon(
                  _isRecurring ? Icons.star : Icons.star_border,
                  color: _isRecurring ? accent : cs.onSurfaceVariant,
                ),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),

              // סטטיסטיקות (רק במצב עריכה)
              if (widget.mode == PantryItemDialogMode.edit &&
                  widget.item != null) ...[
                const Divider(),
                _buildStatistics(widget.item!, cs),
              ],
            ],
          ),
        ),
        actions: [
          // Cancel button
          Semantics(
            label: AppStrings.common.cancel,
            button: true,
            child: TextButton(
              onPressed: _isLoading ? null : _handleCancel,
              child: Text(AppStrings.common.cancel),
            ),
          ),

          // Save/Add button
          Semantics(
            label: actionLabel,
            button: true,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: cs.onPrimary,
                minimumSize: const Size(kButtonHeight, kButtonHeight),
              ),
              onPressed: _isLoading ? null : _saveItem,
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(cs.onPrimary),
                      ),
                    )
                  : Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}
