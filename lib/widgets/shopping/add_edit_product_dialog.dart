// lib/widgets/shopping/add_edit_product_dialog.dart — Add/edit product dialog — product form with name, brand, quantity, price, category

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants.dart' show kDefaultProductUnit;
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/unified_list_item.dart';
import '../../theme/app_theme.dart';
import '../common/app_dialog.dart';
import '../common/product_photo_uploader.dart';
import '../common/product_thumbnail.dart';
import '../common/sticky_button.dart';
import '../common/sticky_note.dart';

// Layout & validation tokens local to the dialog.
// Named so future maintainers see the intent, not bare numbers.
const int _kMaxNameLength = 80;
const int _kMaxBrandLength = 50;
const int _kMaxQuantity = 9999;
const int _kMaxQuantityDigits = 4;   // 9999 = 4 digits
const int _kMaxPriceChars = 10;       // e.g. "12345.67"
const double _kHeroImageSize = 140.0; // edit-mode product thumbnail
const double _kStickyRotation = 0.01;
// Focus shadow tuning — kept inline because it's a single-purpose
// "subtle lift on focus" effect, not a reusable design token.
const double _kFocusShadowBlur = 8.0;
const Offset _kFocusShadowOffset = Offset(0, 2);
// Entry animation stagger — each field appears 40ms after the previous.
const int _kStaggerStepMs = 40;
// Glassmorphic input fill — slightly translucent so the sticky-note
// background tint shows through.
const double _kInputFillAlpha = 0.55;
const double _kInputBorderAlpha = 0.5;
const double _kFocusedBorderWidth = 1.5;

class AddEditProductDialog extends StatefulWidget {
  final UnifiedListItem? item;
  final void Function(UnifiedListItem item) onSave;
  final List<String> categories;
  /// שם מוצע למוצר חדש (למשל מטקסט חיפוש שלא החזיר תוצאות)
  final String? suggestedName;

  const AddEditProductDialog({
    super.key,
    this.item,
    required this.onSave,
    this.categories = const [],
    this.suggestedName,
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

    _nameController = TextEditingController(text: widget.item?.name ?? widget.suggestedName ?? '');
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

    // FocusNodes — each listener fires haptic only when ITS OWN node
    // gains focus. Previously a shared `_onFocusChange` listened on all
    // four, so a single Tab between two fields fired the haptic twice
    // (once for the lost-focus node, once for the gained-focus node).
    _nameFocus = FocusNode()..addListener(() => _onFocusGained(_nameFocus));
    _brandFocus = FocusNode()..addListener(() => _onFocusGained(_brandFocus));
    _quantityFocus = FocusNode()..addListener(() => _onFocusGained(_quantityFocus));
    _priceFocus = FocusNode()..addListener(() => _onFocusGained(_priceFocus));

    // Track changes for exit confirmation
    _nameController.addListener(_markChanged);
    _brandController.addListener(_markChanged);
    _quantityController.addListener(_markChanged);
    _priceController.addListener(_markChanged);
  }

  /// 📳 Haptic: fires only when the given node *gains* focus (not loses).
  /// This makes a Tab transition produce a single click, not two.
  void _onFocusGained(FocusNode node) {
    if (node.hasFocus) {
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
                      color: cs.primary.withValues(alpha: kOpacitySubtle),
                      blurRadius: _kFocusShadowBlur,
                      offset: _kFocusShadowOffset,
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
    // removeCurrentSnackBar prevents stacking when the user retries
    // multiple times in a row (e.g. empty name → fix → invalid qty →
    // each error stacks visually otherwise).
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
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
    if (qty == null || qty <= 0 || qty > _kMaxQuantity) {
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

    final existing = widget.item;
    final newItem = UnifiedListItem.product(
      id: existing?.id ?? const Uuid().v4(),
      name: name,
      quantity: qty,
      unitPrice: unitPrice,
      brand: brand.isEmpty ? null : brand,
      category: _selectedCategory,
      // ✅ Preserve fields not editable in this dialog
      notes: existing?.notes,
      unit: existing?.unit ?? kDefaultProductUnit,
      barcode: existing?.barcode,
      imageUrl: existing?.imageUrl,
      isChecked: existing?.isChecked ?? false,
      checkedBy: existing?.checkedBy,
      checkedAt: existing?.checkedAt,
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
    final inputFillColor =
        cs.surfaceContainerHighest.withValues(alpha: _kInputFillAlpha);
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      borderSide: BorderSide(color: cs.primary, width: _kFocusedBorderWidth),
    );
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      borderSide:
          BorderSide(color: cs.outline.withValues(alpha: _kInputBorderAlpha)),
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
        // Hide the "0/80" maxLength counter — it's visual clutter on a
        // dialog where users rarely hit the cap. The cap still enforces.
        counterText: '',
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
        rotation: _kStickyRotation,
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

                  // 📸 תמונת מוצר (במצב עריכה) - גדולה ובולטת
                  if (isEditMode && widget.item?.barcode != null && widget.item!.barcode!.length >= 7)
                    Padding(
                      padding: const EdgeInsets.only(bottom: kSpacingMedium),
                      child: Column(
                        children: [
                          Center(
                            child: ProductThumbnail(
                              barcode: widget.item!.barcode,
                              category: widget.item!.category ?? '',
                              productName: widget.item!.name,
                              size: _kHeroImageSize,
                            ),
                          ),
                          // 📷 Personal photo CTA — keyed by barcode so the
                          // same photo surfaces in the matching pantry item.
                          ProductPhotoUploader(
                            barcode: widget.item!.barcode!,
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),

                  const Divider(),
                  const Gap(kSpacingSmall),

                  // 📝 שם המוצר. `textDirection` removed — Flutter auto-
                  // detects Hebrew vs Latin per content; the previous
                  // hardcoded RTL broke English users typing "Milk".
                  // `onSubmitted` chains focus so the keyboard's "next"
                  // arrow actually advances the user through the form.
                  _withFocusShadow(
                    focusNode: _nameFocus,
                    child: TextField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      autofocus: true,
                      maxLength: _kMaxNameLength,
                      decoration: fieldDecoration(
                        label: AppStrings.listDetails.productNameLabel,
                        icon: Icons.shopping_bag_outlined,
                      ),
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _brandFocus.requestFocus(),
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0),

                  const Gap(kSpacingSmall),

                  // 🏢 חברה/מותג
                  _withFocusShadow(
                    focusNode: _brandFocus,
                    child: TextField(
                      controller: _brandController,
                      focusNode: _brandFocus,
                      maxLength: _kMaxBrandLength,
                      decoration: fieldDecoration(
                        label: AppStrings.listDetails.brandLabel,
                        icon: Icons.business_outlined,
                      ),
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _quantityFocus.requestFocus(),
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: const Duration(milliseconds: _kStaggerStepMs)).slideX(begin: 0.05, end: 0, delay: const Duration(milliseconds: _kStaggerStepMs)),

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
                        color: cs.onSurface.withValues(alpha: kOpacityStrong),
                      ),
                      hint: Text(AppStrings.listDetails.selectCategory),
                      isExpanded: true,
                      // עיגול תפריט הנפתח
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                      dropdownColor: cs.surfaceContainer,
                      items: widget.categories.map((category) {
                        // textDirection removed — Hebrew categories will
                        // render RTL automatically from the surrounding
                        // app-wide Directionality; English categories
                        // would have rendered backwards otherwise.
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
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
                    ).animate().fadeIn(duration: 300.ms, delay: const Duration(milliseconds: _kStaggerStepMs * 2)).slideX(begin: 0.05, end: 0, delay: const Duration(milliseconds: _kStaggerStepMs * 2)),

                    const Gap(kSpacingSmall),
                  ],

                  // 🔢 כמות ומחיר — בשורה אחת. Numeric fields keep LTR
                  // intent (digits read left-to-right) via TextAlign.center
                  // — hardcoded `textDirection: ltr` was redundant.
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
                            textAlign: TextAlign.center,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) => _priceFocus.requestFocus(),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(_kMaxQuantityDigits),
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
                            textAlign: TextAlign.center,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleSave(),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                              LengthLimitingTextInputFormatter(_kMaxPriceChars),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms, delay: const Duration(milliseconds: _kStaggerStepMs * 3)).slideX(begin: 0.05, end: 0, delay: const Duration(milliseconds: _kStaggerStepMs * 3)),

                  const Gap(kSpacingMedium),

                  // 🔘 כפתורי פעולה. StickyButton supplies its own
                  // Semantics(button + label) — the outer wrapper used
                  // to double-announce. Fallback green color from the
                  // shared theme constant, not a raw hex literal.
                  Row(
                    children: [
                      Expanded(
                        child: StickyButton(
                          label: AppStrings.common.cancel,
                          icon: Icons.close,
                          color: cs.surfaceContainerHighest,
                          onPressed: _handleCancel,
                        ),
                      ),
                      const Gap(kSpacingSmall),
                      Expanded(
                        child: StickyButton(
                          label: _isSaving
                              ? AppStrings.common.loading
                              : AppStrings.common.save,
                          icon: _isSaving ? Icons.hourglass_empty : Icons.check,
                          color: brand?.success ?? kStickyGreen,
                          onPressed: _isSaving ? null : _handleSave,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms, delay: const Duration(milliseconds: _kStaggerStepMs * 4)).slideX(begin: 0.05, end: 0, delay: const Duration(milliseconds: _kStaggerStepMs * 4)),

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
  String? suggestedName,
}) {
  return AppDialog.show(
    context: context,
    child: AddEditProductDialog(
      item: item,
      onSave: onSave,
      categories: categories,
      suggestedName: suggestedName,
    ),
  );
}
