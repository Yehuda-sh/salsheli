// 📄 lib/widgets/shopping/product_selection_bottom_sheet.dart
//
// Bottom Sheet לבחירת מוצרים מהקטלוג - חיפוש, פילטרים והוספה לרשימה.
//
// Features:
//   - Grid/List toggle with SharedPreferences persistence
//   - Recently Added products section (last 10, SharedPreferences)
//   - Category section headers with emoji
//   - Product images from Open Food Facts (with emoji fallback)
//   - Price display in both views
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/product_images_config.dart';
import '../../core/error_utils.dart';
import '../../core/ui_constants.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../../models/shopping_list.dart';
import '../../models/unified_list_item.dart';
import '../../providers/products_provider.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../providers/user_context.dart';
import '../../services/category_detection_service.dart';
import '../common/animated_button.dart';
import '../common/barcode_helpers.dart';
import '../common/notebook_background.dart';
import 'add_edit_product_dialog.dart';
import '../../config/filters_config.dart';
import '../common/app_loading_skeleton.dart';

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

  // 🔀 Grid/List toggle — persisted in SharedPreferences
  static const String _kGridViewKey = 'product_selection_grid_view';
  static const String _kRecentProductsKey = 'recently_added_products';
  static const int _kMaxRecentProducts = 10;

  bool _isGridView = false;
  List<String> _recentProductBarcodes = [];

  // 📸 Track failed image URLs to avoid re-fetching
  static final Set<String> _failedImageUrls = {};

  @override
  void initState() {
    super.initState();

    _userContext = context.read<UserContext>();
    _userContext.addListener(_onUserContextChanged);

    _loadPreferences();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _productsProvider = context.read<ProductsProvider>();

      _productsProvider!.setListType(widget.list.type);

      if (_productsProvider!.isEmpty && !_productsProvider!.isLoading) {
        _productsProvider!.loadProducts();
      }
    });
  }

  /// Load view mode and recent products from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _isGridView = prefs.getBool(_kGridViewKey) ?? false;
      _recentProductBarcodes = prefs.getStringList(_kRecentProductsKey) ?? [];
    });
  }

  /// Toggle between grid and list view
  void _toggleViewMode() {
    unawaited(HapticFeedback.selectionClick());
    setState(() => _isGridView = !_isGridView);
    unawaited(_saveViewMode());
  }

  Future<void> _saveViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kGridViewKey, _isGridView);
  }

  /// Add a product to the recently added list
  Future<void> _addToRecent(String barcode) async {
    _recentProductBarcodes.remove(barcode);
    _recentProductBarcodes.insert(0, barcode);
    if (_recentProductBarcodes.length > _kMaxRecentProducts) {
      _recentProductBarcodes = _recentProductBarcodes.sublist(0, _kMaxRecentProducts);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kRecentProductsKey, _recentProductBarcodes);
  }

  void _onUserContextChanged() {
    if (mounted && _productsProvider != null) {
      _productsProvider!.loadProducts();
    }
  }

  /// 📷 סריקת ברקוד → חיפוש שם המוצר
  Future<void> _scanAndSearch(ProductsProvider productsProvider) async {
    final product = await scanAndLookupProduct(context, productsProvider);
    if (product == null || !mounted) return;

    final name = product['name'] as String? ?? '';
    _searchController.text = name;
    unawaited(productsProvider.searchProducts(name));
    setState(() {});
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

    try {
      final currentList = provider.lists.where((l) => l.id == widget.list.id).firstOrNull;

      if (currentList == null) {
        if (mounted) Navigator.pop(context);
        return;
      }

      final itemIndex = currentList.items.indexWhere(
        (item) => item.name.toLowerCase() == productName.toLowerCase(),
      );

      if (itemIndex != -1) {
        if (newQuantity <= 0) {
          await provider.removeItemFromList(widget.list.id, itemIndex);

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
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _addingProductId = null);

      messenger.showSnackBar(
        SnackBar(
          content: Text(AppStrings.shopping.updateProductError(userFriendlyError(e, context: 'updateProductQuantity'))),
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

    final productUnit = product['defaultUnit'] as String? ?? AppStrings.pantry.unitAbbreviation;
    final productQty = product['defaultQty'] as int? ?? 1;

    try {
      final detectedCategory = CategoryDetectionService.detectFromProductJson(product);

      await provider.addItemToList(
        widget.list.id,
        productName,
        productQty,
        productUnit,
        category: detectedCategory,
      );

      if (!mounted) return;
      setState(() => _addingProductId = null);
      _showFeedback(AppStrings.shopping.productAddedToList(productName));

      // Save to recently added
      final barcode = product['barcode']?.toString();
      if (barcode != null && barcode.isNotEmpty) {
        unawaited(_addToRecent(barcode));
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _addingProductId = null);

      messenger.showSnackBar(
        SnackBar(
          content: Text(AppStrings.shopping.addProductError(userFriendlyError(e, context: 'addProduct'))),
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
    final appBrand = theme.extension<AppBrand>();
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
            decoration: BoxDecoration(
              color: cs.surface,
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
                      width: kSpacingXLarge + kSpacingSmall,
                      height: kSpacingXTiny,
                      decoration: BoxDecoration(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(kSpacingXTiny / 2),
                      ),
                    ),

                    // כותרת עם Grid/List toggle
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
                          // 🔀 Grid/List toggle
                          IconButton(
                            icon: Icon(
                              _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                              size: kIconSizeMedium,
                            ),
                            tooltip: _isGridView
                                ? AppStrings.shopping.listViewTooltip
                                : AppStrings.shopping.gridViewTooltip,
                            onPressed: _toggleViewMode,
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

                    // 📋 רשימת/רשת מוצרים עם RepaintBoundary חיצוני
                    Expanded(
                      child: _buildProductsContent(
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
                    backgroundColor: appBrand?.stickyYellow ?? kStickyYellow,
                    tooltip: AppStrings.shopping.addNewProductTooltip,
                    onPressed: _handleAddCustomProduct,
                    child: Icon(Icons.edit_note, color: cs.onSurface, size: kIconSizeLarge),
                  ),
                ),

                // ✅ באנר פידבק גלסמורפי — ValueNotifier, רק הבאנר מתרענן
                ValueListenableBuilder<String?>(
                  valueListenable: _feedbackNotifier,
                  builder: (context, message, _) {
                    return Positioned(
                      top: kSpacingXLarge * 2 + kSpacingMedium,
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
        borderRadius: BorderRadius.circular(kBorderRadiusXLarge),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            height: kMinInteractiveDimension,
            decoration: BoxDecoration(
              // Dark-mode aware: surfaceContainerHighest adapts automatically
              color: cs.surfaceContainerHighest.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(kBorderRadiusXLarge),
              border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.08),
                  blurRadius: kSpacingSmallPlus,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: AppStrings.common.searchProductHint,
                hintStyle: const TextStyle(fontSize: kFontSizeMedium),
                prefixIcon: const Icon(Icons.search, size: kIconSizeMedium),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: kIconSizeSmall),
                        onPressed: () {
                          unawaited(HapticFeedback.selectionClick());
                          _searchController.clear();
                          productsProvider.clearSearch();
                        },
                      )
                    : IconButton(
                        icon: const Icon(Icons.qr_code_scanner, size: kIconSizeMedium),
                        tooltip: AppStrings.shopping.scanBarcode,
                        onPressed: () => _scanAndSearch(productsProvider),
                      ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
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
      height: kIconSizeLarge + kSpacingXTiny,
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
              padding: const EdgeInsetsDirectional.only(start: kSpacingSmall),
              child: _buildCompactFilterChip(
                label: category,
                emoji: FiltersConfig.getCategoryEmoji(FiltersConfig.hebrewCategoryToEnglish(category)),
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
    final cs = Theme.of(context).colorScheme;
    final appBrand = Theme.of(context).extension<AppBrand>();

    return AnimatedScale(
      scale: isSelected ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: FilterChip(
        showCheckmark: false,
        label: Text(
          '$emoji $label',
          style: TextStyle(
            fontSize: kFontSizeSmall,
            color: isSelected
                ? cs.onSurface
                : cs.onSurface.withValues(alpha: 0.87),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: cs.surface.withValues(alpha: 0.8),
        selectedColor: appBrand?.stickyCyan ?? kStickyCyan,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusLarge + kSpacingXTiny),
          side: BorderSide(
            color: isSelected
                ? cs.outline.withValues(alpha: 0.12)
                : Colors.transparent,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: kSpacingXTiny),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📋 Products List
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildProductsContent(
    ProductsProvider provider,
    List<Map<String, dynamic>> products,
    ColorScheme cs,
    ScrollController scrollController,
    ShoppingList? currentList,
  ) {
    if (provider.isLoading) {
      return const AppLoadingSkeleton(sectionCount: 3, showHero: false);
    }

    if (provider.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: kIconSizeXXLarge, color: cs.error),
            const Gap(kSpacingMedium),
            Text(provider.errorMessage ?? AppStrings.common.unknownErrorGeneric),
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
            Icon(Icons.inbox, size: kIconSizeXXLarge, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
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

    // Group products by category for section headers
    final grouped = _groupProductsByCategory(products);
    final showSectionHeaders = provider.selectedCategory == null && grouped.length > 1;

    // Find recently added products
    final recentProducts = _getRecentProducts(provider);

    // 🎨 Outer RepaintBoundary isolates scroll repaints from the sheet
    return RepaintBoundary(
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          // 📌 Recently Added Section
          if (recentProducts.isNotEmpty && provider.searchQuery.isEmpty)
            SliverToBoxAdapter(
              child: _buildRecentlyAddedSection(recentProducts, cs),
            ),

          // 📂 Category-grouped products
          for (final entry in grouped.entries) ...[
            // Section header
            if (showSectionHeaders)
              SliverToBoxAdapter(
                child: _buildSectionHeader(entry.key, cs),
              ),

            // Products (grid or list)
            if (_isGridView)
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kSpacingMedium,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: kSpacingSmall,
                    crossAxisSpacing: kSpacingSmall,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = entry.value[index];
                      final delay = Duration(milliseconds: (index * 40).clamp(0, 300));
                      return RepaintBoundary(
                        child: _buildProductGridCard(product, cs)
                            .animate()
                            .fadeIn(duration: 300.ms, delay: delay)
                            .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 300.ms, delay: delay),
                      );
                    },
                    childCount: entry.value.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.only(
                  left: kNotebookRedLineOffset + kSpacingSmall,
                  right: kSpacingMedium,
                  top: showSectionHeaders ? 0 : kNotebookLineSpacing - kSpacingSmall,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = entry.value[index];
                      final delay = Duration(milliseconds: (index * 30).clamp(0, 300));
                      return RepaintBoundary(
                        child: _buildCleanProductRow(product, cs)
                            .animate()
                            .fadeIn(duration: 300.ms, delay: delay)
                            .slideX(begin: 0.05, end: 0, duration: 300.ms, delay: delay, curve: Curves.easeOutCubic),
                      );
                    },
                    childCount: entry.value.length,
                  ),
                ),
              ),
          ],

          // Bottom padding for FAB
          const SliverPadding(
            padding: EdgeInsets.only(bottom: kSpacingXLarge * 3 + kSpacingXTiny),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📌 Recently Added Section
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get recent products that exist in the provider's catalog
  List<Map<String, dynamic>> _getRecentProducts(ProductsProvider provider) {
    if (_recentProductBarcodes.isEmpty) return [];
    final all = provider.allProducts;
    final result = <Map<String, dynamic>>[];
    for (final barcode in _recentProductBarcodes) {
      final product = all.cast<Map<String, dynamic>?>().firstWhere(
        (p) => p?['barcode']?.toString() == barcode,
        orElse: () => null,
      );
      if (product != null) result.add(product);
    }
    return result;
  }

  /// Horizontal scroll section showing recently added products
  Widget _buildRecentlyAddedSection(List<Map<String, dynamic>> recentProducts, ColorScheme cs) {
    final appBrand = Theme.of(context).extension<AppBrand>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
          child: Text(
            AppStrings.shopping.recentlyAdded,
            style: TextStyle(
              fontSize: kFontSizeSmall,
              fontWeight: FontWeight.bold,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        SizedBox(
          height: kSpacingXLarge + kSpacingLarge,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
            itemCount: recentProducts.length,
            itemBuilder: (context, index) {
              final product = recentProducts[index];
              final name = product['name'] as String? ?? '';
              final category = product['category'] as String? ?? '';
              final emoji = FiltersConfig.getCategoryEmoji(
                FiltersConfig.hebrewCategoryToEnglish(category),
              );

              return Padding(
                padding: EdgeInsetsDirectional.only(
                  start: index == 0 ? 0 : kSpacingSmall,
                ),
                child: ActionChip(
                  avatar: Text(emoji, style: const TextStyle(fontSize: kFontSizeMedium)),
                  label: Text(
                    name,
                    style: const TextStyle(fontSize: kFontSizeSmall),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  backgroundColor: (appBrand?.stickyYellow ?? kStickyYellow).withValues(alpha: 0.3),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                  ),
                  onPressed: () => _addProduct(product),
                ),
              );
            },
          ),
        ),
        const Gap(kSpacingSmall),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📂 Section Header
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSectionHeader(String category, ColorScheme cs) {
    final emoji = FiltersConfig.getCategoryEmoji(
      FiltersConfig.hebrewCategoryToEnglish(category),
    );

    return Padding(
      padding: const EdgeInsets.only(
        right: kSpacingMedium,
        left: kSpacingMedium,
        top: kSpacingMedium,
        bottom: kSpacingSmall,
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: kFontSizeBody)),
          const SizedBox(width: kSpacingSmall),
          Text(
            category,
            style: TextStyle(
              fontSize: kFontSizeMedium,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(width: kSpacingSmall),
          Expanded(
            child: Divider(color: cs.outlineVariant.withValues(alpha: 0.3)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎴 Product Grid Card
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildProductGridCard(Map<String, dynamic> product, ColorScheme cs) {
    final name = product['name'] as String? ?? AppStrings.shopping.productNoName;
    final category = product['category'] as String? ?? AppStrings.shopping.typeOther;
    final brand = product['brand'] as String?;
    final price = product['price'] as num?;
    final barcode = product['barcode'] as String?;
    final appBrand = Theme.of(context).extension<AppBrand>();
    final showPrices = context.read<UserContext>().showPrices;

    final provider = context.read<ShoppingListsProvider>();
    final currentList = provider.lists.where((l) => l.id == widget.list.id).firstOrNull;

    final existingItem = currentList?.items.cast<UnifiedListItem?>().firstWhere(
      (item) => item?.name.toLowerCase() == name.toLowerCase(),
      orElse: () => null,
    );
    final isInList = existingItem != null;
    final currentQuantity = existingItem?.quantity ?? 0;
    final productId = product['id']?.toString() ?? name;
    final isAdding = _addingProductId == productId;

    return Card(
      elevation: isInList ? 0 : kCardElevation,
      color: isInList
          ? cs.surfaceContainerHighest.withValues(alpha: 0.5)
          : cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
        side: isInList
            ? BorderSide(color: (appBrand?.stickyGreen ?? kStickyGreen).withValues(alpha: 0.4))
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isInList ? null : () => _addProduct(product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 📸 Image area
            Expanded(
              flex: 3,
              child: Container(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                child: _buildProductImage(barcode, category, cs),
              ),
            ),

            // 📝 Details area
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(kSpacingSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: kFontSizeSmall,
                        fontWeight: FontWeight.bold,
                        color: isInList ? cs.onSurface.withValues(alpha: 0.5) : cs.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Brand
                    if (brand != null && brand.isNotEmpty)
                      Text(
                        brand,
                        style: TextStyle(
                          fontSize: kFontSizeTiny,
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const Spacer(),

                    // Price + Add button row
                    Row(
                      children: [
                        if (showPrices && price != null)
                          Text(
                            AppStrings.shopping.priceFormat(price.toDouble()),
                            style: TextStyle(
                              fontSize: kFontSizeSmall,
                              fontWeight: FontWeight.w600,
                              color: cs.primary,
                            ),
                          ),
                        const Spacer(),
                        if (isInList)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: kSpacingSmall,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: appBrand?.stickyCyan ?? kStickyCyan,
                              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                            ),
                            child: Text(
                              '$currentQuantity',
                              style: TextStyle(
                                fontSize: kFontSizeSmall,
                                fontWeight: FontWeight.bold,
                                color: cs.onPrimary,
                              ),
                            ),
                          )
                        else
                          _buildAddButton(isAdding),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📸 Product Image
  // ═══════════════════════════════════════════════════════════════════════════

  /// Product image with Rami Levy CDN, fallback to category emoji.
  /// Credit text only appears when the image loads successfully.
  Widget _buildProductImage(String? barcode, String category, ColorScheme cs) {
    final url = ProductImagesConfig.getImageUrl(barcode);
    final emoji = FiltersConfig.getCategoryEmoji(
      FiltersConfig.hebrewCategoryToEnglish(category),
    );

    if (url == null || _failedImageUrls.contains(url)) {
      return _buildEmojiPlaceholder(emoji);
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      fadeInDuration: const Duration(milliseconds: 200),
      errorWidget: (_, __, ___) {
        _failedImageUrls.add(url);
        return _buildEmojiPlaceholder(emoji);
      },
      placeholder: (_, __) => _buildEmojiPlaceholder(emoji),
      imageBuilder: (context, imageProvider) {
        return Image(image: imageProvider, fit: BoxFit.contain);
      },
    );
  }

  /// Emoji placeholder for products without images
  Widget _buildEmojiPlaceholder(String emoji) {
    return Center(
      child: Text(
        emoji,
        style: const TextStyle(fontSize: kFontSizeDisplay),
      ),
    );
  }

  /// Group products by category
  Map<String, List<Map<String, dynamic>>> _groupProductsByCategory(
    List<Map<String, dynamic>> products,
  ) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final p in products) {
      final cat = p['category'] as String? ?? AppStrings.shopping.typeOther;
      (grouped[cat] ??= []).add(p);
    }
    return grouped;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎴 Product Row
  // ═══════════════════════════════════════════════════════════════════════════

  /// שורת מוצר נקייה — על קווי המחברת (RTL optimized) + מחיר
  Widget _buildCleanProductRow(Map<String, dynamic> product, ColorScheme cs) {
    final name = product['name'] as String? ?? AppStrings.shopping.productNoName;
    final category = product['category'] as String? ?? AppStrings.shopping.typeOther;
    final size = product['size'] as String?;
    final brand = product['brand'] as String?;
    final price = product['price'] as num?;
    final appBrand = Theme.of(context).extension<AppBrand>();
    final showPrices = context.read<UserContext>().showPrices;

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
        splashColor: (appBrand?.stickyGreen ?? kStickyGreen).withValues(alpha: 0.1),
        highlightColor: (appBrand?.stickyGreen ?? kStickyGreen).withValues(alpha: 0.05),
        child: SizedBox(
          height: kNotebookLineSpacing,
          child: Row(
            children: [
              // 🏷️ אייקון קטגוריה
              Text(FiltersConfig.getCategoryEmoji(FiltersConfig.hebrewCategoryToEnglish(category)), style: const TextStyle(fontSize: kFontSizeBody)),

              const Gap(kSpacingTiny),

              // 📝 שם המוצר + גודל + מותג
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: kFontSizeMedium,
                            fontWeight: FontWeight.bold,
                            color: isInList ? cs.onSurface.withValues(alpha: 0.5) : cs.onSurface,
                            height: 1.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (size != null) ...[
                        const SizedBox(width: kSpacingXTiny),
                        Text(
                          size,
                          style: TextStyle(
                            fontSize: kFontSizeSmall,
                            color: cs.onSurface.withValues(alpha: 0.5),
                            height: 1.0,
                          ),
                        ),
                      ],
                      if (brand != null && brand.isNotEmpty) ...[
                        const SizedBox(width: kSpacingXTiny),
                        Text(
                          '· $brand',
                          style: TextStyle(
                            fontSize: kFontSizeTiny,
                            color: cs.onSurface.withValues(alpha: 0.35),
                            height: 1.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // 💰 מחיר
              if (showPrices && price != null) ...[
                Text(
                  AppStrings.shopping.priceFormat(price.toDouble()),
                  style: TextStyle(
                    fontSize: kFontSizeTiny,
                    fontWeight: FontWeight.w600,
                    color: cs.primary.withValues(alpha: 0.7),
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: kSpacingSmall),
              ],

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
          Text(FiltersConfig.getCategoryEmoji(FiltersConfig.hebrewCategoryToEnglish(category)), style: const TextStyle(fontSize: kFontSizeBody)),
          const Gap(kSpacingTiny),
          Expanded(
            child: Text(
              name,
              style: TextStyle(fontSize: kFontSizeMedium, color: cs.onSurface.withValues(alpha: 0.3)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.error_outline, color: cs.error.withValues(alpha: 0.5), size: kIconSizeMedium),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ➕ Add / Quantity Controls
  // ═══════════════════════════════════════════════════════════════════════════

  /// ➕ כפתור הוספה עדין — אייקון ירוק עם pulse בזמן loading
  Widget _buildAddButton(bool isAdding) {
    final appBrand = Theme.of(context).extension<AppBrand>();
    final stickyGreen = appBrand?.stickyGreen ?? kStickyGreen;
    return AnimatedScale(
      scale: isAdding ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Icon(
        Icons.add_circle_outline,
        color: isAdding ? stickyGreen : stickyGreen.withValues(alpha: 0.6),
        size: kIconSizeMedium,
      ),
    );
  }

  /// 🔢 בקרי כמות — AnimatedButton עם selection haptic + AnimatedSwitcher pulse
  Widget _buildQuantityControls(Map<String, dynamic> product, int currentQuantity) {
    final appBrand = Theme.of(context).extension<AppBrand>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ➕ כפתור הגדלת כמות
        _buildQuantityButton(
          icon: Icons.add,
          color: appBrand?.stickyGreen ?? kStickyGreen,
          tooltip: AppStrings.shopping.increaseQuantityTooltip,
          onTap: () => _updateProductQuantity(product, currentQuantity + 1),
        ),

        // 🔢 מספר עם AnimatedSwitcher pulse
        Container(
          margin: const EdgeInsets.symmetric(horizontal: kSpacingXTiny),
          padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: 2),
          decoration: BoxDecoration(
            color: appBrand?.stickyCyan ?? kStickyCyan,
            borderRadius: BorderRadius.circular(kBorderRadiusSmall + 2),
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
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: kFontSizeMedium,
              ),
            ),
          ),
        ),

        // ➖ כפתור הקטנת כמות
        _buildQuantityButton(
          icon: Icons.remove,
          color: appBrand?.stickyPink ?? kStickyPink,
          tooltip: AppStrings.shopping.decreaseQuantityTooltip,
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
        scaleTarget: 0.97,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(kBorderRadiusLarge + kSpacingXTiny),
          child: Padding(
            padding: const EdgeInsets.all(kSpacingSmall),
            child: Container(
              width: kSpacingLarge + kSpacingXTiny,
              height: kSpacingLarge + kSpacingXTiny,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.onPrimary, size: kIconSizeSmall),
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
            color: (Theme.of(context).extension<AppBrand>()?.stickyGreen ?? kStickyGreen).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(kBorderRadius),
            border: Border.all(color: cs.onPrimary.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.15),
                blurRadius: kSpacingSmallPlus,
                offset: const Offset(0, kSpacingXTiny),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: cs.onPrimary, size: kIconSizeMedium),
              const Gap(kSpacingSmall),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: kFontSizeBody,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
