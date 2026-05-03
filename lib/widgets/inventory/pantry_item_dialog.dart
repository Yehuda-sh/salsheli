// lib/widgets/inventory/pantry_item_dialog.dart — Pantry item dialog — add/edit inventory item with all fields and barcode scan

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
import '../../providers/products_provider.dart';
import '../../theme/app_theme.dart';
import '../common/app_dialog.dart';
import '../common/product_thumbnail.dart';

enum PantryItemDialogMode {
  add,
  edit,
}

class PantryItemDialog extends StatefulWidget {
  final PantryItemDialogMode mode;
  final InventoryItem? item; // רק ב-edit mode
  final VoidCallback? onSuccess;
  final String? initialName; // pre-fill from barcode scan
  final String? initialCategory; // pre-fill from barcode scan

  const PantryItemDialog({
    super.key,
    required this.mode,
    this.item,
    this.onSuccess,
    this.initialName,
    this.initialCategory,
  }) : assert(
          mode == PantryItemDialogMode.add || item != null,
          'Item is required in edit mode',
        );

  /// מציג את הדיאלוג לעריכת פריט קיים
  static Future<bool?> showEditDialog(
    BuildContext context,
    InventoryItem item, {
    VoidCallback? onSuccess,
  }) {
    return AppDialog.show<bool>(
      context: context,
      child: PantryItemDialog(
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
  // In edit mode the name field is hidden by default — the dialog title
  // already shows the product name, so duplicating it as an editable field
  // immediately below was redundant. Rename is a deliberate action: tap
  // the small "✏️ שינוי שם" button to reveal the editable field.
  // In add mode the field is required, so it's always visible.
  bool _renameMode = false;
  // Advanced settings (category / unit / expiry / notes / recurring)
  // collapse-by-default in edit mode — the daily flow is "I bought 3
  // more, update the count" and shouldn't ask users to scroll past
  // 5 read-only fields. In add mode they're all needed up front, so
  // start expanded. The user can still toggle either way.
  late bool _advancedExpanded =
      widget.mode == PantryItemDialogMode.add;

  // 🆕 Brand + size pulled from the product catalog (read-only — they're
  // not stored on InventoryItem, only displayed). Looked up by barcode
  // on initState if we're editing an item that has one.
  String? _catalogBrand;
  String? _catalogSize;

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
      _selectedCategory = FiltersConfig.hebrewCategoryToEnglish(item.category);
      _selectedLocation = item.location;
      // שדות חדשים
      _expiryDate = item.expiryDate;
      _isRecurring = item.isRecurring;
    } else {
      _nameController = TextEditingController(text: widget.initialName ?? '');
      _quantityController = TextEditingController(text: '1');
      _unitController = TextEditingController(text: AppStrings.inventory.defaultUnit);
      _minQuantityController = TextEditingController(text: '2');
      _notesController = TextEditingController();
      _selectedCategory = widget.initialCategory != null
          ? FiltersConfig.hebrewCategoryToEnglish(widget.initialCategory!)
          : 'other';
      _selectedLocation = StorageLocationsConfig.mainPantry;
    }

    // 🛡️ Track changes for exit confirmation
    _nameController.addListener(_markChanged);
    _quantityController.addListener(_markChanged);
    _unitController.addListener(_markChanged);
    _minQuantityController.addListener(_markChanged);
    _notesController.addListener(_markChanged);

    // 🔎 Edit-mode + barcode → fetch brand/size from catalog asynchronously.
    // We don't store these on InventoryItem; the lookup re-runs every time
    // the dialog opens, so a future catalog update is automatically picked
    // up without any per-user data migration.
    final barcode = widget.item?.barcode;
    if (widget.mode == PantryItemDialogMode.edit &&
        barcode != null &&
        barcode.length >= 7) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadCatalogDetails(barcode);
      });
    }
  }

  Future<void> _loadCatalogDetails(String barcode) async {
    try {
      final products = context.read<ProductsProvider>();
      final product = await products.getProductByBarcode(barcode);
      if (!mounted || product == null) return;

      final brand = (product['brand'] as String?)?.trim();
      final size = (product['size'] as String?)?.trim();
      final catalogCategory = (product['category'] as String?)?.trim();

      // 🔄 Catalog re-sync: if the stored item's category is stale (we
      // moved candies from תבלינים to ממתקים in a script run, but the
      // user's pantry doc was cached before), pull the fresh value.
      // Mark _hasChanges so the save button picks it up — the user gets
      // a one-tap "save" to commit the correction.
      String? syncedCategoryKey;
      if (catalogCategory != null && catalogCategory.isNotEmpty) {
        final newKey = FiltersConfig.hebrewCategoryToEnglish(catalogCategory);
        if (newKey != _selectedCategory) {
          syncedCategoryKey = newKey;
        }
      }

      final newBrand = (brand != null && brand.isNotEmpty) ? brand : null;
      final newSize = (size != null && size.isNotEmpty) ? size : null;

      if (newBrand == null && newSize == null && syncedCategoryKey == null) {
        return;
      }
      setState(() {
        _catalogBrand = newBrand;
        _catalogSize = newSize;
        if (syncedCategoryKey != null) {
          _selectedCategory = syncedCategoryKey;
          _hasChanges = true;
        }
      });
    } catch (_) {
      // Best-effort lookup — silently skip if catalog fetch fails.
    }
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  /// Categories where products typically don't have a meaningful expiry
  /// date (or one a household actually tracks). For these, the "add expiry
  /// date" CTA shrinks to a low-emphasis TextButton — still reachable, but
  /// not competing for attention with quantity/category. Comparison is
  /// against the canonical English keys from FiltersConfig.
  static const _nonPerishableCategoryKeys = <String>{
    'other',
    'spices',
    'cleaning',
    'cosmetics',
    'hygiene',
    'pet_food',
    'first_aid',
  };

  bool _isNonPerishableCategory(String key) =>
      _nonPerishableCategoryKeys.contains(key);

  /// Dialog title row — product thumbnail + the thing the user is here to
  /// edit/add.
  ///
  /// In **edit** mode the dialog's "title" is the *product name itself* —
  /// the user came to the dialog because of this product, so its name is
  /// the primary identifier; the editable name field below is for renaming.
  /// In **add** mode the title is the action label ("הוסף פריט") because
  /// there's no product name yet.
  Widget _buildDialogTitle(ColorScheme cs, Color accent, String addTitle) {
    final isEdit = widget.mode == PantryItemDialogMode.edit;
    final hasImage = isEdit &&
        widget.item?.barcode != null &&
        widget.item!.barcode!.length >= 7;
    final categoryKey = isEdit
        ? FiltersConfig.hebrewCategoryToEnglish(widget.item!.category)
        : _selectedCategory;
    final categoryEmoji = FiltersConfig.getCategoryInfo(categoryKey).emoji;

    // In edit mode prefer the product's actual name. Use the controller
    // text (rather than widget.item!.productName) so a rename in-progress
    // is reflected in the title — but keep the original name as a sane
    // fallback if the field was cleared mid-edit.
    final titleString = isEdit
        ? (_nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : widget.item!.productName)
        : addTitle;

    final titleText = Expanded(
      child: Text(
        titleString,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: cs.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    // Hero thumbnail: deliberately larger than a label-row badge — the
    // product image (or fallback emoji) is the primary visual anchor
    // for "which item am I editing", so it earns ~2× the previous size.
    const thumbnailSize = kIconSizeXXLarge + kSpacingXLarge; // 64 + 32 = 96
    final thumbnail = hasImage
        ? GestureDetector(
            onTap: () => _showFullImage(cs),
            child: Hero(
              tag: 'pantry-thumb-${widget.item!.barcode}',
              child: ProductThumbnail(
                barcode: widget.item!.barcode,
                category: widget.item!.category,
                productName: isEdit ? widget.item!.productName : null,
                size: thumbnailSize,
              ),
            ),
          )
        : Container(
            width: thumbnailSize,
            height: thumbnailSize,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              ProductThumbnail.matchProductEmoji(
                    isEdit ? widget.item?.productName : _nameController.text,
                  ) ??
                  categoryEmoji,
              style: const TextStyle(fontSize: kFontSizeHeroEmoji),
            ),
          );

    return Row(
      children: [
        titleText,
        const SizedBox(width: kSpacingMedium),
        thumbnail,
      ],
    );
  }

  /// Opens a full-screen image viewer with pinch-to-zoom + drag-to-pan.
  /// Tap anywhere to dismiss.
  void _showFullImage(ColorScheme cs) {
    final barcode = widget.item!.barcode;
    final category = widget.item!.category;
    final productName = widget.item!.productName;
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, _, _) => GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Stack(
            children: [
              Center(
                child: Hero(
                  tag: 'pantry-thumb-${barcode ?? category}',
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: ProductThumbnail(
                      barcode: barcode,
                      category: category,
                      // Pass productName so the emoji fallback runs through
                      // matchProductEmoji (🫚 for "ג'ינג'ר") instead of
                      // dropping to the generic category emoji (🧂 for
                      // "תבלינים"). Without this the title shows ginger but
                      // the zoomed view falls back to a salt shaker.
                      productName: productName,
                      // Generous size — InteractiveViewer scales it further.
                      size: 360,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: kSpacingLarge,
                right: kSpacingLarge,
                child: SafeArea(
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.white,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🆕 בונה שדה כמות עם כפתורי +/-
  /// Quantity +/- stepper. [accentColor] controls the icon/text tint so
  /// callers can visually distinguish "current quantity" (primary, bold)
  /// from "minimum alert" (muted, lighter).
  Widget _buildQuantityField({
    required TextEditingController controller,
    required String label,
    required ColorScheme cs,
    int minValue = 0,
    int maxValue = kMaxPantryQuantity,
    Color? accentColor,
    double fontSize = kFontSizeBody,
    double iconSize = kIconSizeMedium,
  }) {
    final color = accentColor ?? cs.primary;
    // Force LTR so +/- buttons stay in consistent visual order (- left, + right)
    // Compact padding — values are at most 2 digits so 28px is plenty.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // כפתור מינוס
          InkWell(
            onTap: _isLoading
                ? null
                : () {
                    final current = int.tryParse(controller.text) ?? 0;
                    if (current > minValue) {
                      unawaited(HapticFeedback.selectionClick());
                      controller.text = (current - 1).toString();
                    }
                  },
            borderRadius: BorderRadius.circular(kBorderRadiusLarge),
            child: Padding(
              padding: const EdgeInsets.all(kSpacingSmall),
              child: Icon(Icons.remove_circle_outline, color: color, size: iconSize),
            ),
          ),
          // ערך — 28px wide, enough for 2 digits (max pantry qty is 99)
          SizedBox(
            width: 28,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: kFontSizeSmall),
                contentPadding: const EdgeInsets.symmetric(vertical: kSpacingXTiny),
                isDense: true,
                border: InputBorder.none,
              ),
              enabled: !_isLoading,
            ),
          ),
          // כפתור פלוס
          InkWell(
            onTap: _isLoading
                ? null
                : () {
                    final current = int.tryParse(controller.text) ?? 0;
                    if (current < maxValue) {
                      unawaited(HapticFeedback.selectionClick());
                      controller.text = (current + 1).toString();
                    }
                  },
            borderRadius: BorderRadius.circular(kBorderRadiusLarge),
            child: Padding(
              padding: const EdgeInsets.all(kSpacingSmall),
              child: Icon(Icons.add_circle_outline, color: color, size: iconSize),
            ),
          ),
        ],
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
      if (mounted) Navigator.pop(context, false);
    }
  }

  /// Permanently deletes the item. Confirms first, then calls the
  /// provider, closes the dialog, and lets the host screen show its own
  /// "deleted" snackbar (with undo) on the result. Returns early if the
  /// user cancels at the confirmation step.
  Future<void> _handleDelete() async {
    final item = widget.item;
    if (item == null || _isLoading) return;

    final strings = AppStrings.inventory;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.deleteConfirmTitle),
        content: Text(strings.deleteConfirmMessage(item.productName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.common.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(AppStrings.common.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    unawaited(HapticFeedback.heavyImpact());

    try {
      await context.read<InventoryProvider>().deleteItem(item.id);
      if (!mounted) return;
      // Pop with `null` so the host screen distinguishes "deleted" from
      // "saved" (true) or "cancelled" (false) and can show its own
      // delete-with-undo snackbar.
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(strings.deleteError),
          backgroundColor: StatusColors.getColor(StatusType.error, context),
          duration: kSnackBarDuration,
        ));
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

  /// 🆕 בונה widget סטטיסטיקות - עיצוב מינימלי ומעומעם
  /// Statistics card. Sized so each line is comfortably readable on a phone:
  /// labels at kFontSizeSmall (12pt) instead of kFontSizeTiny (10pt) which
  /// was hard to read in cramped phone width. Wrap can spill to a second
  /// row when needed rather than fighting for horizontal space.
  Widget _buildStatistics(InventoryItem item, ColorScheme cs) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final mutedColor = cs.onSurfaceVariant;
    const valueFont = kFontSizeSmall;

    return Container(
      padding: const EdgeInsets.all(kSpacingSmallPlus),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: kOpacityLight),
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // כותרת קטנה
          Row(
            children: [
              Icon(Icons.bar_chart, size: kIconSizeSmall, color: mutedColor),
              const SizedBox(width: kSpacingXTiny),
              Text(
                AppStrings.inventory.statisticsLabel,
                style: TextStyle(
                  fontSize: kFontSizeSmall,
                  fontWeight: FontWeight.w600,
                  color: mutedColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: kSpacingSmall),
          // שורת נתונים אופקית
          Wrap(
            spacing: kSpacingMedium,
            runSpacing: kSpacingSmall,
            children: [
              // כמה פעמים נקנה
              if (item.purchaseCount > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: kIconSizeSmall, color: mutedColor),
                    const SizedBox(width: kSpacingXTiny),
                    Text(
                      AppStrings.inventory.purchaseCountLabel(item.purchaseCount),
                      style: TextStyle(fontSize: valueFont, color: mutedColor),
                    ),
                  ],
                ),
              // קנייה אחרונה — מציג גם relative ('לפני 3 ימים') וגם
              // התאריך המדויק כ-tooltip להעמקה.
              if (item.lastPurchased != null)
                Tooltip(
                  message: dateFormat.format(item.lastPurchased!),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history, size: kIconSizeSmall, color: mutedColor),
                      const SizedBox(width: kSpacingXTiny),
                      Text(
                        AppStrings.inventory.relativePurchaseLabel(item.lastPurchased!),
                        style: TextStyle(fontSize: valueFont, color: mutedColor),
                      ),
                    ],
                  ),
                ),
              // פופולרי
              if (item.isPopular)
                Builder(builder: (_) {
                  final successColor = StatusColors.getColor(StatusType.success, context).withValues(alpha: kOpacityStrong);
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up, size: kIconSizeSmall, color: successColor),
                      const SizedBox(width: kSpacingXTiny),
                      Text(
                        AppStrings.inventory.popularLabel,
                        style: TextStyle(
                          fontSize: valueFont,
                          color: successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                }),
            ],
          ),
        ],
      ),
    );
  }

  /// בחירת תאריך תפוגה
  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();
    // אם יש תאריך תפוגה שכבר עבר — מרשים לראות אותו בבוחר
    final earliest = _expiryDate != null && _expiryDate!.isBefore(now)
        ? _expiryDate!
        : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? now.add(const Duration(days: 30)),
      firstDate: earliest,
      lastDate: now.add(const Duration(days: 365 * 5)),
      locale: const Locale('he', 'IL'),
      helpText: AppStrings.inventory.selectExpiryDate,
      cancelText: AppStrings.inventory.cancelLabel,
      confirmText: AppStrings.inventory.confirmLabel,
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
          backgroundColor: StatusColors.getColor(StatusType.error, context),
          duration: kSnackBarDuration,
        ),
      );
      return;
    }

    // Validation - כמות (בהוספה חובה >= 1, בעריכה מותר 0 = "נגמר")
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    if (widget.mode == PantryItemDialogMode.add && quantity <= 0) {
      unawaited(HapticFeedback.heavyImpact());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.inventory.quantityMustBePositive),
          backgroundColor: StatusColors.getColor(StatusType.error, context),
          duration: kSnackBarDuration,
        ),
      );
      return;
    }

    final minQuantity = int.tryParse(_minQuantityController.text) ?? 2;
    final productName = _nameController.text.trim();
    // שמור את הקטגוריה בעברית (לתאימות עם שאר המערכת)
    final category = FiltersConfig.getCategoryInfo(_selectedCategory).label;
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
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.mode == PantryItemDialogMode.add
              ? AppStrings.inventory.addError
              : AppStrings.inventory.updateError),
          backgroundColor: StatusColors.getColor(StatusType.error, context),
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
      // Hardware/Bluetooth keyboard: Enter (or numpad Enter) saves the
      // form; Escape cancels. Phone soft-keyboards still chain via
      // textInputAction so this only matters on tablets/desktops.
      child: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.enter): () {
            if (!_isLoading) _saveItem();
          },
          const SingleActivator(LogicalKeyboardKey.numpadEnter): () {
            if (!_isLoading) _saveItem();
          },
          const SingleActivator(LogicalKeyboardKey.escape): () {
            if (!_isLoading) _handleCancel();
          },
        },
        child: Focus(
          autofocus: true,
          child: AlertDialog(
        backgroundColor: cs.surface,
        title: _buildDialogTitle(cs, accent, title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ═══════════════════════════════════════════════════════════
              // 🟢 שלב עליון: אזור מהיר (תמיד פתוח)
              // ═══════════════════════════════════════════════════════════

              // שם המוצר — 2 שורות, ללא prefixIcon שאוכל רוחב.
              // In edit mode the field is hidden behind a "✏️ שינוי שם"
              // button so the title (which already shows the name) doesn't
              // visually duplicate the same string twice. In add mode the
              // field is always visible (we need a name to create the item).
              if (widget.mode == PantryItemDialogMode.add || _renameMode)
                TextField(
                  controller: _nameController,
                  style: TextStyle(color: cs.onSurface, fontSize: kFontSizeBody),
                  textDirection: TextDirection.rtl,
                  maxLength: 80,
                  maxLines: 2,
                  minLines: 1,
                  textInputAction: TextInputAction.next,
                  autofocus: _renameMode,
                  // Counter only appears once the user gets close to the
                  // limit — quietly hides for short names where it's clutter.
                  buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                      currentLength >= 70
                          ? Text(
                              '$currentLength/$maxLength',
                              style: TextStyle(
                                fontSize: kFontSizeTiny,
                                color: cs.onSurfaceVariant,
                              ),
                            )
                          : null,
                  decoration: InputDecoration(
                    labelText: AppStrings.inventory.productNameLabel,
                    labelStyle: TextStyle(color: cs.onSurfaceVariant),
                    hintText: AppStrings.inventory.productNameHint,
                    hintStyle: TextStyle(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  enabled: !_isLoading,
                )
              else
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => setState(() => _renameMode = true),
                    icon: Icon(
                      Icons.edit_outlined,
                      size: kIconSizeSmall,
                      color: cs.onSurfaceVariant,
                    ),
                    label: Text(
                      AppStrings.inventory.renameProduct,
                      style: TextStyle(
                        fontSize: kFontSizeSmall,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kSpacingSmall,
                        vertical: kSpacingXTiny,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),

              // 🏷️ Brand + size from catalog — only renders when at least
              // one of them is available. Read-only badges; the underlying
              // InventoryItem doesn't store these.
              if (_catalogBrand != null || _catalogSize != null) ...[
                const SizedBox(height: kSpacingXTiny),
                Wrap(
                  spacing: kSpacingSmall,
                  runSpacing: kSpacingXTiny,
                  children: [
                    if (_catalogBrand != null)
                      _CatalogBadge(
                        icon: Icons.sell_outlined,
                        text: _catalogBrand!,
                        cs: cs,
                      ),
                    if (_catalogSize != null)
                      _CatalogBadge(
                        icon: Icons.scale_outlined,
                        text: _catalogSize!,
                        cs: cs,
                      ),
                  ],
                ),
              ],

              // 🔢 Barcode row — read-only. Helps the user confirm the right
              // product was scanned, disambiguates similar items (1L vs 1.5L
              // milk both show as "תנובה"), and exposes the code for sharing.
              if (widget.item?.barcode != null && widget.item!.barcode!.isNotEmpty) ...[
                const SizedBox(height: kSpacingXTiny),
                Text(
                  AppStrings.inventory.barcodeRow(widget.item!.barcode!),
                  style: TextStyle(
                    fontSize: kFontSizeTiny,
                    color: cs.onSurfaceVariant.withValues(alpha: kOpacityStrong),
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ],

              const SizedBox(height: kSpacingSmall),

              // כמות + מינימום
              // Hierarchy: quantity is the primary edit (the user came here
              // to update stock). Minimum is a one-time alert threshold.
              // Quantity gets a tinted container + display-size number;
              // minimum sits next to it as a compact inline row.
              Row(
                children: [
                  // כמות נוכחית — hero counter
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kSpacingSmall,
                        vertical: kSpacingTiny,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withValues(alpha: kOpacityLight),
                        borderRadius: BorderRadius.circular(kBorderRadius),
                        border: Border.all(
                          color: cs.primary.withValues(alpha: kOpacityMedium),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppStrings.inventory.quantityLabelShort,
                            style: TextStyle(
                              fontSize: kFontSizeSmall,
                              color: cs.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: kSpacingTiny),
                          _buildQuantityField(
                            controller: _quantityController,
                            label: '',
                            cs: cs,
                            accentColor: cs.primary,
                            fontSize: kFontSizeXLarge,
                            iconSize: kIconSizeMediumPlus,
                            minValue: widget.mode == PantryItemDialogMode.add ? 1 : 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: kSpacingSmall),
                  // מינימום (התראה) — compact, muted
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_outlined,
                              size: kFontSizeMedium,
                              color: cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: kSpacingXTiny),
                            Text(
                              AppStrings.inventory.minimumLabel,
                              style: TextStyle(
                                fontSize: kFontSizeSmall,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: kSpacingXTiny),
                        _buildQuantityField(
                          controller: _minQuantityController,
                          label: '',
                          cs: cs,
                          accentColor: cs.onSurfaceVariant,
                          iconSize: kIconSizeSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: kSpacingSmall),

              // מיקום אחסון
              Consumer<LocationsProvider>(
                builder: (context, locationsProvider, _) {
                  final customLocations = locationsProvider.customLocations;
                  final allLocations = [
                    ...StorageLocationsConfig.allLocations,
                    ...customLocations.map((c) => c.key),
                  ];

                  if (!allLocations.contains(_selectedLocation)) {
                    allLocations.add(_selectedLocation);
                  }

                  // No prefixIcon — each dropdown item already shows its
                  // location emoji (🍳 / 🥛 / 🧊 / etc.), so a generic
                  // place-pin alongside it was duplicating the visual cue.
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedLocation,
                    dropdownColor: cs.surface,
                    style: TextStyle(color: cs.onSurface),
                    decoration: InputDecoration(
                      labelText: AppStrings.inventory.locationLabel,
                      labelStyle: TextStyle(color: cs.onSurfaceVariant),
                    ),
                    items: allLocations.map((locationId) {
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
                              setState(() {
                                _selectedLocation = val;
                                _hasChanges = true;
                              });
                            }
                          },
                  );
                },
              ),

              const SizedBox(height: kSpacingSmall),

              // ═══════════════════════════════════════════════════════════
              // ⚪ שלב ביניים: הגדרות נוספות (collapsible)
              // Daily flow is "I bought N more" — keep this folded so the
              // user doesn't scroll past 5 fields they rarely change.
              // Tap the row to expand. Add-mode opens it by default.
              // ═══════════════════════════════════════════════════════════

              const SizedBox(height: kSpacingMedium),
              InkWell(
                onTap: _isLoading
                    ? null
                    : () => setState(() => _advancedExpanded = !_advancedExpanded),
                borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: kSpacingXTiny),
                  child: Row(
                    children: [
                      Icon(Icons.tune, size: kIconSizeSmall, color: cs.onSurfaceVariant),
                      const SizedBox(width: kSpacingXTiny),
                      Text(
                        AppStrings.inventory.advancedSettings,
                        style: TextStyle(
                          fontSize: kFontSizeSmall,
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: kSpacingSmall),
                      Expanded(
                        child: Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      const SizedBox(width: kSpacingSmall),
                      AnimatedRotation(
                        turns: _advancedExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.expand_more,
                          size: kIconSizeSmallPlus,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_advancedExpanded) ...[
              const SizedBox(height: kSpacingSmall),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    // קטגוריה — same rationale as the location dropdown:
                    // each item carries its own emoji, so a generic
                    // category icon would just duplicate the cue.
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      dropdownColor: cs.surface,
                      style: TextStyle(color: cs.onSurface),
                      decoration: InputDecoration(
                        labelText: AppStrings.inventory.categoryLabel,
                        labelStyle: TextStyle(color: cs.onSurfaceVariant),
                      ),
                      items: FiltersConfig.kCategoryInfo.entries
                          .where((e) => e.key != 'all')
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
                                setState(() {
                                  _selectedCategory = val;
                                  _hasChanges = true;
                                });
                              }
                            },
                    ),
                    const SizedBox(height: kSpacingSmall),

                    // יחידה — no prefixIcon: the ruler glyph rendered as
                    // visual noise at the field height, and the label
                    // already says what this field is for.
                    TextField(
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
                    const SizedBox(height: kSpacingSmall),

                    // תאריך תפוגה — for perishable categories the "add date"
                    // CTA is a full bordered button (it's actionable signal).
                    // For non-perishable groups (spices, cleaning, hygiene…)
                    // expiry rarely matters, so the empty-state CTA shrinks
                    // to a quiet TextButton — present but not competing
                    // with quantity/category for the user's eye.
                    if (_expiryDate != null)
                      InkWell(
                        onTap: _isLoading ? null : _selectExpiryDate,
                        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: AppStrings.inventory.expiryDateLabel,
                            labelStyle: TextStyle(color: cs.onSurfaceVariant),
                            prefixIcon: Icon(Icons.event_outlined, color: cs.primary),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear, size: kIconSizeSmall),
                              onPressed: _isLoading
                                  ? null
                                  : () => setState(() {
                                        _expiryDate = null;
                                        _hasChanges = true;
                                      }),
                              tooltip: AppStrings.inventory.clearDateTooltip,
                            ),
                          ),
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(_expiryDate!),
                            style: TextStyle(color: cs.onSurface),
                          ),
                        ),
                      )
                    else if (_isNonPerishableCategory(_selectedCategory))
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          onPressed: _isLoading ? null : _selectExpiryDate,
                          icon: Icon(
                            Icons.event_outlined,
                            color: cs.onSurfaceVariant,
                            size: kIconSizeSmall,
                          ),
                          label: Text(
                            AppStrings.inventory.expiryNotSetCta,
                            style: TextStyle(
                              fontSize: kFontSizeSmall,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: kSpacingSmall,
                              vertical: kSpacingXTiny,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _selectExpiryDate,
                        icon: Icon(Icons.event_outlined, color: cs.primary),
                        label: Text(AppStrings.inventory.expiryNotSetCta),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.primary,
                          side: BorderSide(color: cs.outlineVariant),
                          minimumSize: const Size.fromHeight(kButtonHeight),
                          alignment: AlignmentDirectional.centerStart,
                          padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                        ),
                      ),
                    const SizedBox(height: kSpacingSmall),

                    // הערות
                    TextField(
                      controller: _notesController,
                      style: TextStyle(color: cs.onSurface),
                      maxLines: 2,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: AppStrings.inventory.notesLabel,
                        labelStyle: TextStyle(color: cs.onSurfaceVariant),
                        hintText: AppStrings.inventory.notesHint,
                        hintStyle: TextStyle(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        prefixIcon: Icon(Icons.notes_outlined, color: cs.primary),
                      ),
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: kSpacingSmall),

                    // מוצר קבוע — star is the toggle (filled = on, outlined =
                    // off). Single indicator instead of star + checkbox; the
                    // star carries more meaning ("special / recurring") than
                    // a generic checkbox, so we let it stand on its own.
                    InkWell(
                      onTap: _isLoading
                          ? null
                          : () {
                              unawaited(HapticFeedback.selectionClick());
                              setState(() {
                                _isRecurring = !_isRecurring;
                                _hasChanges = true;
                              });
                            },
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: kSpacingXTiny),
                        child: Row(
                          children: [
                            Icon(
                              _isRecurring ? Icons.star : Icons.star_border,
                              color: _isRecurring ? accent : cs.onSurfaceVariant,
                              size: kIconSizeMedium,
                            ),
                            const SizedBox(width: kSpacingSmall),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.inventory.permanentProduct,
                                    style: TextStyle(
                                      color: cs.onSurface,
                                      fontWeight: _isRecurring
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    AppStrings.inventory.autoAddToLists,
                                    style: TextStyle(
                                      fontSize: kFontSizeTiny,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // ═══════════════════════════════════════════════════════════
              // 🔵 שלב תחתון: סטטיסטיקות (רק במצב עריכה)
              // ═══════════════════════════════════════════════════════════

              if (widget.mode == PantryItemDialogMode.edit &&
                  widget.item != null) ...[
                const SizedBox(height: kSpacingSmall),
                _buildStatistics(widget.item!, cs),
                // 🗑️ Delete CTA — small destructive text button so it's
                // discoverable from the dialog (the swipe-to-delete on the
                // list row is a hidden affordance most users miss). Tinted
                // error palette + low emphasis so it doesn't compete with
                // the primary Save action.
                const SizedBox(height: kSpacingSmall),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: _isLoading ? null : _handleDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      size: kIconSizeSmall,
                      color: cs.error,
                    ),
                    label: Text(
                      AppStrings.inventory.deleteItemButton,
                      style: TextStyle(
                        fontSize: kFontSizeSmall,
                        color: cs.error,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kSpacingSmall,
                        vertical: kSpacingXTiny,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        // Equal-width Cancel/Save buttons. The default AlertDialog actions
        // OverflowBar mixes a TextButton with an ElevatedButton, which
        // looks lopsided. We pin both to the same height + flex so the
        // bottom row reads as a clean pair.
        actionsPadding: const EdgeInsets.fromLTRB(
          kSpacingMedium, 0, kSpacingMedium, kSpacingSmall,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  label: AppStrings.common.cancel,
                  button: true,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _handleCancel,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(kButtonHeight),
                      foregroundColor: cs.onSurfaceVariant,
                      side: BorderSide(color: cs.outlineVariant),
                    ),
                    child: Text(AppStrings.common.cancel),
                  ),
                ),
              ),
              const SizedBox(width: kSpacingSmall),
              Expanded(
                child: Semantics(
                  label: actionLabel,
                  button: true,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: cs.onPrimary,
                      minimumSize: const Size.fromHeight(kButtonHeight),
                    ),
                    onPressed: _isLoading ? null : _saveItem,
                    child: _isLoading
                        ? SizedBox(
                            width: kIconSizeSmall,
                            height: kIconSizeSmall,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(cs.onPrimary),
                            ),
                          )
                        : Text(actionLabel),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
        ),
      ),
    );
  }
}

/// Compact pill rendering a single catalog-derived attribute (brand or size).
/// Read-only — taps don't do anything; this is informational chrome.
class _CatalogBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final ColorScheme cs;

  const _CatalogBadge({
    required this.icon,
    required this.text,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kSpacingSmall,
        vertical: kSpacingXTiny,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: kIconSizeSmall, color: cs.onSurfaceVariant),
          const SizedBox(width: kSpacingXTiny),
          Text(
            text,
            style: TextStyle(
              fontSize: kFontSizeSmall,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
