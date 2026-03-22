// 📄 lib/widgets/shopping/add_edit_product_dialog.dart
//
// דיאלוג הוספה/עריכה של מוצר - שם, מותג, קטגוריה, כמות ומחיר.
// כולל validation, Sticky Notes design, אנימציות ותמיכה בנגישות.
//
// Features:
//   - אנימציות שדות מדורגות (Staggered Fields)
//   - חתימות Haptic מותאמות לסטטוס
//   - ריווח סמנטי מבוסס Gap
//   - אופטימיזציית RepaintBoundary
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
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/unified_list_item.dart';
import '../../theme/app_theme.dart';
import '../common/app_dialog.dart';
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

  // FocusNodes לניהול צל ממוקד + haptic מעבר שדות
  late final FocusNode _nameFocus;
  late final FocusNode _brandFocus;
  late final FocusNode _quantityFocus;
  late final FocusNode _priceFocus;

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

    // FocusNodes — selectionClick כשמשתמש מעביר מיקוד
    _nameFocus = FocusNode()..addListener(_onFocusChange);
    _brandFocus = FocusNode()..addListener(_onFocusChange);
    _quantityFocus = FocusNode()..addListener(_onFocusChange);
    _priceFocus = FocusNode()..addListener(_onFocusChange);

    // Track changes for exit confirmation
    _nameController.addListener(_markChanged);
    _brandController.addListener(_markChanged);
    _quantityController.addListener(_markChanged);
    _priceController.addListener(_markChanged);
  }

  /// 📳 Haptic: selectionClick במעבר בין שדות
  void _onFocusChange() {
    // מפעיל רק כשהשדה מקבל focus (לא כשמאבד)
    final anyHasFocus = _nameFocus.hasFocus ||
        _brandFocus.hasFocus ||
        _quantityFocus.hasFocus ||
        _priceFocus.hasFocus;
    if (anyHasFocus) {
      unawaited(HapticFeedback.selectionClick());
    }
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
    _nameFocus.dispose();
    _brandFocus.dispose();
    _quantityFocus.dispose();
    _priceFocus.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎨 Focus Shadow Wrapper
  // ═══════════════════════════════════════════════════════════════════════════

  /// עוטף שדה ב-AnimatedContainer עם BoxShadow עדין כשממוקד
  Widget _withFocusShadow({required Widget child, required FocusNode focusNode}) {
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, _) {
        final cs = Theme.of(context).colorScheme;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          decoration: focusNode.hasFocus
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                )
              : const BoxDecoration(),
          child: child,
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ❌ Error / Validation
  // ═══════════════════════════════════════════════════════════════════════════

  void _showErrorSnackBar(String message) {
    // 📳 Haptic: heavyImpact לשגיאה
    unawaited(HapticFeedback.heavyImpact());
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: cs.onError),
            const Gap(kSpacingSmall),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: cs.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🚪 Exit Confirmation
  // ═══════════════════════════════════════════════════════════════════════════

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

  Future<void> _handleCancel() async {
    if (await _confirmExit()) {
      unawaited(HapticFeedback.lightImpact());
      if (mounted) Navigator.pop(context);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 💾 Save
  // ═══════════════════════════════════════════════════════════════════════════

  void _handleSave() {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final brand = _brandController.text.trim();
    final qtyText = _quantityController.text.trim();
    // ✅ Support comma as decimal separator (Israeli convention)
    final priceText = _priceController.text.trim().replaceAll(',', '.');

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

    // 📳 Haptic: mediumImpact לשמירה מוצלחת
    unawaited(HapticFeedback.mediumImpact());

    final newItem = UnifiedListItem.product(
      id: widget.item?.id ?? const Uuid().v4(),
      name: name,
      quantity: qty,
      unitPrice: unitPrice,
      brand: brand.isEmpty ? null : brand,
      category: _selectedCategory,
    );

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

  // ═══════════════════════════════════════════════════════════════════════════
  // 🏗️ Build
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final isEditMode = widget.item != null;

    final stickyColor = brand?.stickyYellow ?? kStickyYellow;

    // Glassmorphic fill — שקיפות עדינה להשתקפות רקע הפתק
    final inputFillColor = cs.surfaceContainerHighest.withValues(alpha: 0.55);
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      borderSide: BorderSide(color: cs.primary, width: 1.5),
    );
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.5)),
    );

    InputDecoration fieldDecoration({
      required String label,
      required IconData icon,
    }) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: defaultBorder,
        enabledBorder: defaultBorder,
        focusedBorder: focusedBorder,
        filled: true,
        fillColor: inputFillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: kSpacingSmall,
          vertical: kSpacingSmallPlus,
        ),
      );
    }

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        final shouldExit = await _confirmExit();
        if (shouldExit && mounted) nav.pop();
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(kSpacingMedium),
        child: StickyNote(
        color: stickyColor,
        rotation: 0.01,
        padding: 0,
        // 🎨 RepaintBoundary — בידוד אנימציות שדות ממקלדת עולה
        child: RepaintBoundary(
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
                      const Gap(kSpacingSmall),
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
                  const Gap(kSpacingMedium),
                  const Divider(),
                  const Gap(kSpacingSmall),

                  // 📝 שם המוצר
                  _withFocusShadow(
                    focusNode: _nameFocus,
                    child: TextField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      autofocus: true,
                      decoration: fieldDecoration(
                        label: AppStrings.listDetails.productNameLabel,
                        icon: Icons.shopping_bag_outlined,
                      ),
                      textDirection: ui.TextDirection.rtl,
                      textInputAction: TextInputAction.next,
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0),

                  const Gap(kSpacingSmall),

                  // 🏢 חברה/מותג
                  _withFocusShadow(
                    focusNode: _brandFocus,
                    child: TextField(
                      controller: _brandController,
                      focusNode: _brandFocus,
                      decoration: fieldDecoration(
                        label: AppStrings.listDetails.brandLabel,
                        icon: Icons.business_outlined,
                      ),
                      textDirection: ui.TextDirection.rtl,
                      textInputAction: TextInputAction.next,
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 40.ms).slideX(begin: 0.05, end: 0, delay: 40.ms),

                  const Gap(kSpacingSmall),

                  // 🏷️ קטגוריה — Glassmorphic Dropdown
                  if (widget.categories.isNotEmpty) ...[
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: fieldDecoration(
                        label: AppStrings.listDetails.categoryLabel,
                        icon: Icons.category_outlined,
                      ),
                      // 🎨 אייקון יוקרתי וקטן
                      icon: Icon(
                        Icons.expand_more,
                        size: kIconSizeMedium,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                      hint: Text(AppStrings.listDetails.selectCategory),
                      isExpanded: true,
                      // עיגול תפריט הנפתח
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                      dropdownColor: cs.surfaceContainer,
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
                        // 📳 Haptic: selectionClick לבחירת קטגוריה
                        unawaited(HapticFeedback.selectionClick());
                        setState(() {
                          _selectedCategory = value;
                          _hasChanges = true;
                        });
                      },
                    ).animate().fadeIn(duration: 300.ms, delay: 80.ms).slideX(begin: 0.05, end: 0, delay: 80.ms),

                    const Gap(kSpacingSmall),
                  ],

                  // 🔢 כמות ומחיר — בשורה אחת
                  Row(
                    children: [
                      Expanded(
                        child: _withFocusShadow(
                          focusNode: _quantityFocus,
                          child: TextField(
                            controller: _quantityController,
                            focusNode: _quantityFocus,
                            decoration: fieldDecoration(
                              label: AppStrings.listDetails.quantityLabel,
                              icon: Icons.numbers,
                            ),
                            keyboardType: TextInputType.number,
                            textDirection: ui.TextDirection.ltr,
                            textAlign: TextAlign.center,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                          ),
                        ),
                      ),
                      const Gap(kSpacingSmall),
                      Expanded(
                        child: _withFocusShadow(
                          focusNode: _priceFocus,
                          child: TextField(
                            controller: _priceController,
                            focusNode: _priceFocus,
                            decoration: fieldDecoration(
                              label: AppStrings.listDetails.priceLabel,
                              icon: Icons.attach_money,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textDirection: ui.TextDirection.ltr,
                            textAlign: TextAlign.center,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleSave(),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms, delay: 120.ms).slideX(begin: 0.05, end: 0, delay: 120.ms),

                  const Gap(kSpacingMedium),

                  // 🔘 כפתורי פעולה
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          label: AppStrings.common.cancel,
                          button: true,
                          child: StickyButton(
                            label: AppStrings.common.cancel,
                            icon: Icons.close,
                            color: cs.surfaceContainerHighest,
                            onPressed: _handleCancel,
                          ),
                        ),
                      ),
                      const Gap(kSpacingSmall),
                      Expanded(
                        child: Semantics(
                          label: AppStrings.common.save,
                          button: true,
                          child: StickyButton(
                            label: _isSaving
                                ? AppStrings.common.loading
                                : AppStrings.common.save,
                            icon: _isSaving ? Icons.hourglass_empty : Icons.check,
                            color: brand?.success ?? const Color(0xFF388E3C),
                            onPressed: _isSaving ? null : _handleSave,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms, delay: 160.ms).slideX(begin: 0.05, end: 0, delay: 160.ms),

                  // ✅ Keyboard padding
                  SizedBox(
                    height: MediaQuery.of(context).viewInsets.bottom > 0
                        ? kSpacingMedium
                        : 0,
                  ),
                ],
              ),
            ),
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
  return AppDialog.show(
    context: context,
    child: AddEditProductDialog(
      item: item,
      onSave: onSave,
      categories: categories,
    ),
  );
}
