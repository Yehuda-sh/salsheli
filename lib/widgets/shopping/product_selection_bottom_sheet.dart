// 📄 lib/widgets/shopping/product_selection_bottom_sheet.dart
// Version 4.0 - Hybrid Premium | 22/02/2026
//
// Bottom Sheet לבחירת מוצרים מהקטלוג - חיפוש, פילטרים והוספה לרשימה.
//
// Features:
//   - Frosted Search Bar: BackdropFilter sigma:10, dark-mode aware surfaceContainerHighest
//   - Staggered Product List: flutter_animate per-row, RepaintBoundary isolation
//   - Glassmorphic Feedback Banner: ValueNotifier (לא setState), BackdropFilter
//   - AnimatedButton quantity controls: ButtonHaptic.selection + AnimatedSwitcher pulse
//   - mediumImpact haptic על הצגת feedback
//   - Gap semantic spacing
//
// 🔗 Related: ProductsProvider, ShoppingListsProvider, ShoppingList

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/receipt.dart';
import '../../models/shopping_list.dart';
import '../../models/unified_list_item.dart';
import '../../providers/products_provider.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../providers/user_context.dart';
import '../../services/category_detection_service.dart';
import '../common/animated_button.dart';
import '../common/notebook_background.dart';
import 'add_edit_product_dialog.dart';

class ProductSelectionBottomSheet extends StatefulWidget {
  final ShoppingList list;

  const ProductSelectionBottomSheet({super.key, required this.list});

  @override
  State<ProductSelectionBottomSheet> createState() => _ProductSelectionBottomSheetState();
}

class _ProductSelectionBottomSheetState extends State<ProductSelectionBottomSheet> {
  final TextEditingController _searchController = TextEditingController();

  ProductsProvider? _productsProvider;
  late UserContext _userContext;

  // 📣 Feedback: ValueNotifier — only the banner rebuilds, not the full sheet
  final ValueNotifier<String?> _feedbackNotifier = ValueNotifier(null);

  // 🔄 Loading state for a specific product row (list rebuilds anyway)
  String? _addingProductId;

  // ✅ Timers — cancelled in dispose
  Timer? _debounceTimer;
  Timer? _feedbackTimer;

  @override
  void initState() {
    super.initState();

    _userContext = context.read<UserContext>();
    _userContext.addListener(_onUserContextChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _productsProvider = context.read<ProductsProvider>();

      debugPrint('🎯 ProductSelectionBottomSheet: סוג רשימה = ${widget.list.type}');
      _productsProvider!.setListType(widget.list.type);

      if (_productsProvider!.isEmpty && !_productsProvider!.isLoading) {
        _productsProvider!.loadProducts();
      }
    });
  }

  void _onUserContextChanged() {
    debugPrint('🔄 ProductSelectionBottomSheet: שינוי בהקשר המשתמש');
    if (mounted && _productsProvider != null) {
      _productsProvider!.loadProducts();
    }
  }

  @override
  void dispose() {
    _userContext.removeListener(_onUserContextChanged);
    _productsProvider?.clearListType(notify: false);
    _feedbackNotifier.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }

  /// ✅ Debounced search — מונע קריאות מיותרות בזמן הקלדה
  void _onSearchChangedDebounced(String value, ProductsProvider provider) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      provider.setSearchQuery(value.trim());
    });
  }

  /// ✅ הצגת פידבק — mediumImpact + ValueNotifier (לא setState)
  void _showFeedback(String message) {
    unawaited(HapticFeedback.mediumImpact());
    _feedbackTimer?.cancel();
    _feedbackNotifier.value = message;
    _feedbackTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) _feedbackNotifier.value = null;
    });
  }

  /// 📝 עדכון כמות למוצר קיים
  Future<void> _updateProductQuantity(Map<String, dynamic> product, int newQuantity) async {
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final provider = context.read<ShoppingListsProvider>();
    final productName = product['name'] as String;
    final productId = product['id']?.toString() ?? productName;

    setState(() => _addingProductId = productId);

    debugPrint('🔄 ProductSelectionBottomSheet: מעדכן "$productName" לכמות $newQuantity');

    try {
      final currentList = provider.lists.where((l) => l.id == widget.list.id).firstOrNull;

      if (currentList == null) {
        debugPrint('   ⚠️ הרשימה לא נמצאה - ייתכן שנמחקה');
        if (mounted) Navigator.pop(context);
        return;
      }

      final itemIndex = currentList.items.indexWhere(
        (item) => item.name.toLowerCase() == productName.toLowerCase(),
      );

      if (itemIndex != -1) {
        if (newQuantity <= 0) {
          await provider.removeItemFromList(widget.list.id, itemIndex);
          debugPrint('   🗑️ פריט נמחק (כמות 0)');

          if (!mounted) return;
          setState(() => _addingProductId = null);
          _showFeedback(AppStrings.shopping.productRemovedFromList(productName));
        } else {
          final currentItem = currentList.items[itemIndex];
          final updatedItem = currentItem.copyWith(
            productData: {...?currentItem.productData, 'quantity': newQuantity},
          );

          await provider.updateItemAt(widget.list.id, itemIndex, (_) => updatedItem);

          if (!mounted) return;
          setState(() => _addingProductId = null);
          _showFeedback(AppStrings.shopping.productUpdatedQuantity(productName, newQuantity));
          debugPrint('   ✅ עודכן לכמות $newQuantity');
        }
      }
    } catch (e) {
      debugPrint('   ❌ שגיאה: $e');
      if (!mounted) return;

      setState(() => _addingProductId = null);

      messenger.showSnackBar(
        SnackBar(
          content: Text(AppStrings.shopping.updateProductError(e.toString())),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// ➕ הוספת מוצר חדש (לא מהקטלוג) — פותח דיאלוג
  Future<void> _handleAddCustomProduct() async {
    final provider = context.read<ShoppingListsProvider>();

    await showAddEditProductDialog(
      context,
      onSave: (item) async {
        await provider.addUnifiedItem(widget.list.id, item);
        debugPrint('✅ ProductSelectionBottomSheet: הוסף מוצר חדש "${item.name}"');

        if (!mounted) return;
        _showFeedback(AppStrings.shopping.productAddedToList(item.name));
      },
    );
  }

  Future<void> _addProduct(Map<String, dynamic> product) async {
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    final provider = context.read<ShoppingListsProvider>();
    final productName = product['name']?.toString() ?? AppStrings.shopping.productNoName;
    final productId = product['id']?.toString() ?? productName;

    setState(() => _addingProductId = productId);

    debugPrint('➕ ProductSelectionBottomSheet: מוסיף "$productName"');

    final newItem = ReceiptItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: productName,
      unitPrice: (product['price'] as num?)?.toDouble() ?? 0.0,
      barcode: product['barcode'] as String?,
      manufacturer: product['manufacturer'] as String?,
    );

    try {
      final detectedCategory = CategoryDetectionService.detectFromProductJson(product);

      await provider.addItemToList(
        widget.list.id,
        newItem.name ?? 'מוצר ללא שם',
        newItem.quantity,
        newItem.unit ?? "יח'",
        category: detectedCategory,
      );

      final originalCategory = product['category'] as String?;
      if (originalCategory != detectedCategory && originalCategory != null) {
        debugPrint('   🔧 קטגוריה תוקנה: "$originalCategory" → "$detectedCategory"');
      } else {
        debugPrint('   ✅ נוסף בהצלחה עם קטגוריה: $detectedCategory');
      }

      if (!mounted) return;
      setState(() => _addingProductId = null);
      _showFeedback(AppStrings.shopping.productAddedToList(newItem.name ?? 'מוצר'));
    } catch (e) {
      debugPrint('   ❌ שגיאה: $e');
      if (!mounted) return;

      setState(() => _addingProductId = null);

      messenger.showSnackBar(
        SnackBar(
          content: Text(AppStrings.shopping.addProductError(e.toString())),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🏗️ Build
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final productsProvider = context.watch<ProductsProvider>();
    final products = productsProvider.products;

    // ✅ Watch ShoppingListsProvider לעדכון כשמוסיפים/מסירים מוצרים
    final listsProvider = context.watch<ShoppingListsProvider>();
    final currentList = listsProvider.lists.where((l) => l.id == widget.list.id).firstOrNull;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: kPaperBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(kBorderRadiusLarge)),
            ),
            child: Stack(
              children: [
                // 🎨 Notebook background
                const Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(kBorderRadiusLarge)),
                    child: NotebookBackground(),
                  ),
                ),

                // 📝 Content — flutter_animate entry instead of FadeTransition
                Column(
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(top: kSpacingSmall),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // כותרת
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kSpacingMedium,
                        vertical: kSpacingSmall,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppStrings.shopping.addProductsTitle(widget.list.name),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    // 🔍 Frosted Search Bar — sigma 10, dark-mode aware
                    _buildFrostedSearchBar(productsProvider, cs),

                    // 🏷️ פילטרים קומפקטיים בגלילה אופקית
                    _buildCompactCategoryFilters(productsProvider),

                    const Gap(kSpacingSmall),

                    // 📋 רשימת מוצרים עם RepaintBoundary חיצוני
                    Expanded(
                      child: _buildProductsList(
                        productsProvider,
                        products,
                        cs,
                        scrollController,
                        currentList,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms),

                // ➕ FAB להוספת מוצר חדש
                Positioned(
                  left: kSpacingMedium,
                  bottom: kSpacingMedium,
                  child: FloatingActionButton(
                    heroTag: 'add_custom_product',
                    backgroundColor: kStickyYellow,
                    tooltip: 'הוסף מוצר חדש',
                    onPressed: _handleAddCustomProduct,
                    child: Icon(Icons.edit_note, color: cs.onSurface, size: 28),
                  ),
                ),

                // ✅ באנר פידבק גלסמורפי — ValueNotifier, רק הבאנר מתרענן
                ValueListenableBuilder<String?>(
                  valueListenable: _feedbackNotifier,
                  builder: (context, message, _) {
                    return Positioned(
                      top: 80,
                      left: kSpacingMedium,
                      right: kSpacingMedium,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeOutBack,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween(
                              begin: const Offset(0, -0.3),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: message != null
                            ? _buildGlassFeedbackBanner(message, cs)
                            : const SizedBox.shrink(),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔍 Frosted Search Bar
  // ═══════════════════════════════════════════════════════════════════════════

  /// שורת חיפוש Frosted Glass — sigma 10, dark-mode aware
  Widget _buildFrostedSearchBar(ProductsProvider productsProvider, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              // Dark-mode aware: surfaceContainerHighest adapts automatically
              color: cs.surfaceContainerHighest.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: AppStrings.common.searchProductHint,
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          unawaited(HapticFeedback.selectionClick());
                          _searchController.clear();
                          productsProvider.clearSearch();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {}); // לעדכון כפתור הניקוי
                _onSearchChangedDebounced(value, productsProvider);
              },
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🏷️ Category Filters
  // ═══════════════════════════════════════════════════════════════════════════

  /// פילטרים קומפקטיים בגלילה אופקית — haptic + staggered
  Widget _buildCompactCategoryFilters(ProductsProvider productsProvider) {
    final categories = productsProvider.relevantCategories;
    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
        children: [
          // כפתור "הכל" — delay: 0ms
          _buildCompactFilterChip(
            label: AppStrings.common.all,
            emoji: widget.list.typeEmoji,
            isSelected: productsProvider.selectedCategory == null,
            onTap: () {
              unawaited(HapticFeedback.selectionClick());
              productsProvider.clearCategory();
            },
          ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.04, end: 0),

          // קטגוריות — staggered 30ms each
          ...categories.indexed.map((e) {
            final (i, category) = e;
            final delay = Duration(milliseconds: (i + 1) * 30);
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _buildCompactFilterChip(
                label: category,
                emoji: _getCategoryEmoji(category),
                isSelected: productsProvider.selectedCategory == category,
                onTap: () {
                  unawaited(HapticFeedback.selectionClick());
                  productsProvider.setCategory(category);
                },
              ).animate().fadeIn(duration: 200.ms, delay: delay).slideX(begin: 0.04, end: 0, delay: delay),
            );
          }),
        ],
      ),
    );
  }

  /// 🎯 צ'יפ פילטר קומפקטי
  Widget _buildCompactFilterChip({
    required String label,
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedScale(
      scale: isSelected ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: FilterChip(
        showCheckmark: false,
        label: Text(
          '$emoji $label',
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.black : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        selectedColor: kStickyCyan,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? Colors.black12 : Colors.transparent),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📋 Products List
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildProductsList(
    ProductsProvider provider,
    List<Map<String, dynamic>> products,
    ColorScheme cs,
    ScrollController scrollController,
    ShoppingList? currentList,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: cs.error),
            const Gap(kSpacingMedium),
            Text(provider.errorMessage ?? 'שגיאה לא ידועה'),
            const Gap(kSpacingLarge),
            TextButton.icon(
              onPressed: () => provider.loadProducts(),
              icon: const Icon(Icons.refresh),
              label: Text(AppStrings.common.retry),
            ),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
            const Gap(kSpacingMedium),
            Text(
              provider.searchQuery.isNotEmpty
                  ? AppStrings.shopping.noProductsMatchingSearch(provider.searchQuery)
                  : AppStrings.shopping.noProductsAvailable,
              style: const TextStyle(fontSize: kFontSizeMedium, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (provider.searchQuery.isEmpty) ...[
              const Gap(kSpacingLarge),
              TextButton.icon(
                onPressed: () => provider.loadProducts(),
                icon: const Icon(Icons.refresh),
                label: Text(AppStrings.shopping.loadProductsButton),
              ),
            ],
          ],
        ),
      );
    }

    // 🎨 Outer RepaintBoundary isolates list scroll repaints from the sheet
    return RepaintBoundary(
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.only(
          top: kNotebookLineSpacing - 8,
          left: kNotebookRedLineOffset + kSpacingSmall,
          right: kSpacingMedium,
          bottom: 100, // מקום ל-FAB
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final delay = Duration(milliseconds: (index * 30).clamp(0, 300));

          // 🎨 Inner RepaintBoundary per-row + flutter_animate stagger
          return RepaintBoundary(
            child: _buildCleanProductRow(product, cs)
                .animate()
                .fadeIn(duration: 300.ms, delay: delay)
                .slideX(begin: 0.05, end: 0, duration: 300.ms, delay: delay, curve: Curves.easeOutCubic),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎴 Product Row
  // ═══════════════════════════════════════════════════════════════════════════

  /// שורת מוצר נקייה — על קווי המחברת (RTL optimized)
  Widget _buildCleanProductRow(Map<String, dynamic> product, ColorScheme cs) {
    final name = product['name'] as String? ?? AppStrings.shopping.productNoName;
    final category = product['category'] as String? ?? AppStrings.shopping.typeOther;

    final provider = context.read<ShoppingListsProvider>();
    final currentList = provider.lists.where((l) => l.id == widget.list.id).firstOrNull;

    if (currentList == null) {
      return _buildDisabledProductRow(name, category, cs);
    }

    final existingItem = currentList.items.cast<UnifiedListItem?>().firstWhere(
      (item) => item?.name.toLowerCase() == name.toLowerCase(),
      orElse: () => null,
    );
    final currentQuantity = existingItem?.quantity ?? 0;
    final isInList = existingItem != null;
    final productId = product['id']?.toString() ?? name;
    final isAdding = _addingProductId == productId;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isInList ? null : () => _addProduct(product),
        splashColor: kStickyGreen.withValues(alpha: 0.1),
        highlightColor: kStickyGreen.withValues(alpha: 0.05),
        child: SizedBox(
          height: kNotebookLineSpacing,
          child: Row(
            children: [
              // 🏷️ אייקון קטגוריה
              Text(_getCategoryEmoji(category), style: const TextStyle(fontSize: 18)),

              const Gap(6),

              // 📝 שם המוצר
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isInList ? cs.onSurface.withValues(alpha: 0.5) : cs.onSurface,
                      height: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // ➕ כפתור הוספה / בקרי כמות
              isInList ? _buildQuantityControls(product, currentQuantity) : _buildAddButton(isAdding),
            ],
          ),
        ),
      ),
    );
  }

  /// 🚫 שורת מוצר מושבתת (כשהרשימה לא קיימת)
  Widget _buildDisabledProductRow(String name, String category, ColorScheme cs) {
    return SizedBox(
      height: kNotebookLineSpacing,
      child: Row(
        children: [
          Text(_getCategoryEmoji(category), style: const TextStyle(fontSize: 18)),
          const Gap(6),
          Expanded(
            child: Text(
              name,
              style: TextStyle(fontSize: 15, color: cs.onSurface.withValues(alpha: 0.3)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.error_outline, color: cs.error.withValues(alpha: 0.5), size: 20),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ➕ Add / Quantity Controls
  // ═══════════════════════════════════════════════════════════════════════════

  /// ➕ כפתור הוספה עדין — אייקון ירוק עם pulse בזמן loading
  Widget _buildAddButton(bool isAdding) {
    return AnimatedScale(
      scale: isAdding ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Icon(
        Icons.add_circle_outline,
        color: isAdding ? kStickyGreen : kStickyGreen.withValues(alpha: 0.6),
        size: 24,
      ),
    );
  }

  /// 🔢 בקרי כמות — AnimatedButton עם selection haptic + AnimatedSwitcher pulse
  Widget _buildQuantityControls(Map<String, dynamic> product, int currentQuantity) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ➕ כפתור הגדלת כמות
        _buildQuantityButton(
          icon: Icons.add,
          color: kStickyGreen,
          tooltip: 'הוסף כמות',
          onTap: () => _updateProductQuantity(product, currentQuantity + 1),
        ),

        // 🔢 מספר עם AnimatedSwitcher pulse
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: kStickyCyan,
            borderRadius: BorderRadius.circular(10),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: Tween<double>(begin: 1.3, end: 1.0).animate(animation),
              child: child,
            ),
            child: Text(
              '$currentQuantity',
              key: ValueKey(currentQuantity),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),

        // ➖ כפתור הקטנת כמות
        _buildQuantityButton(
          icon: Icons.remove,
          color: kStickyPink,
          tooltip: 'הפחת כמות',
          onTap: () => _updateProductQuantity(product, currentQuantity - 1),
        ),
      ],
    );
  }

  /// 🔘 כפתור עגול קטן עם AnimatedButton + נגישות
  Widget _buildQuantityButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: AnimatedButton(
        haptic: ButtonHaptic.selection,
        scaleTarget: 0.88,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅ Glassmorphic Feedback Banner
  // ═══════════════════════════════════════════════════════════════════════════

  /// באנר פידבק גלסמורפי — BackdropFilter + צבע ירוק עם שקיפות
  Widget _buildGlassFeedbackBanner(String message, ColorScheme cs) {
    return ClipRRect(
      key: ValueKey(message),
      borderRadius: BorderRadius.circular(kBorderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          padding: const EdgeInsets.all(kSpacingMedium),
          decoration: BoxDecoration(
            color: kStickyGreen.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(kBorderRadius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 24),
              const Gap(kSpacingSmall),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🏷️ Category Emoji
  // ═══════════════════════════════════════════════════════════════════════════

  String _getCategoryEmoji(String category) {
    switch (category) {
      // אטליז
      case 'בקר':
        return '🐄';
      case 'עוף':
        return '🐔';
      case 'דגים':
        return '🐟';
      case 'טלה וכבש':
        return '🐑';
      case 'הודו':
        return '🦃';

      // סופרמרקט
      case 'היגיינה אישית':
        return '🧼';
      case 'מוצרי ניקיון':
        return '🧹';
      case 'מוצרי תינוקות':
        return '👶';
      case 'ירקות':
        return '🥬';
      case 'פירות':
        return '🍎';
      case 'מוצרי חלב':
        return '🥛';
      case 'בשר ודגים':
        return '🥩';
      case 'משקאות':
        return '🥤';
      case 'מאפים':
        return '🍞';
      case 'ממתקים וחטיפים':
        return '🍫';
      case 'שמנים ורטבים':
        return '🫗';
      case 'תבלינים ואפייה':
        return '🧂';
      case 'קפה ותה':
        return '☕';
      case 'קפואים':
        return '🧊';
      case 'אורז ופסטה':
        return '🍚';
      case 'שימורים':
        return '🥫';
      case 'אחר':
        return '📦';
      default:
        return '🛒';
    }
  }
}
