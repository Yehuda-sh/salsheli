// 📄 File: lib/widgets/shopping/product_selection_bottom_sheet.dart
// תיאור: Bottom Sheet לבחירת מוצרים מהקטלוג
//
// ✨ V2.0 - Clean Notebook Design:
// - שורות נקיות על רקע המחברת (לא Sticky Notes כבדות)
// - חיפוש עם אפקט זכוכית מט (BackdropFilter)
// - פילטרים בגלילה אופקית קומפקטית
// - כפתורי הוספה/כמות קומפקטיים
//
// 📦 תלויות:
// - ProductsProvider - ניהול קטלוג המוצרים
// - ShoppingListsProvider - ניהול רשימות הקניות

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
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
import '../common/notebook_background.dart';
import 'add_edit_product_dialog.dart';

class ProductSelectionBottomSheet extends StatefulWidget {
  final ShoppingList list;

  const ProductSelectionBottomSheet({super.key, required this.list});

  @override
  State<ProductSelectionBottomSheet> createState() =>
      _ProductSelectionBottomSheetState();
}

class _ProductSelectionBottomSheetState
    extends State<ProductSelectionBottomSheet> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  ProductsProvider? _productsProvider;
  late UserContext _userContext;

  // 🎬 Animation Controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // ✅ פידבק הוספת מוצר
  String? _lastAddedProduct;
  String? _addingProductId;

  @override
  void initState() {
    super.initState();

    _userContext = context.read<UserContext>();
    _userContext.addListener(_onUserContextChanged);

    // 🎬 Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _productsProvider = context.read<ProductsProvider>();

      debugPrint(
          '🎯 ProductSelectionBottomSheet: סוג רשימה = ${widget.list.type}');
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
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// 📝 עדכון כמות למוצר קיים
  Future<void> _updateProductQuantity(
    Map<String, dynamic> product,
    int newQuantity,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final provider = context.read<ShoppingListsProvider>();
    final productName = product['name'] as String;
    final productId = product['id']?.toString() ?? productName;

    setState(() {
      _addingProductId = productId;
    });

    debugPrint(
        '🔄 ProductSelectionBottomSheet: מעדכן "$productName" לכמות $newQuantity');

    try {
      final currentList =
          provider.lists.firstWhere((l) => l.id == widget.list.id);
      final itemIndex = currentList.items.indexWhere(
        (item) => item.name.toLowerCase() == productName.toLowerCase(),
      );

      if (itemIndex != -1) {
        if (newQuantity <= 0) {
          await provider.removeItemFromList(widget.list.id, itemIndex);
          debugPrint('   🗑️ פריט נמחק (כמות 0)');

          if (!mounted) return;
          setState(() {
            _lastAddedProduct =
                AppStrings.shopping.productRemovedFromList(productName);
            _addingProductId = null;
          });
        } else {
          final currentItem = currentList.items[itemIndex];
          final updatedItem = currentItem.copyWith(
            productData: {
              ...?currentItem.productData,
              'quantity': newQuantity,
            },
          );

          await provider.updateItemAt(
            widget.list.id,
            itemIndex,
            (_) => updatedItem,
          );

          if (!mounted) return;

          setState(() {
            _lastAddedProduct = AppStrings.shopping
                .productUpdatedQuantity(productName, newQuantity);
            _addingProductId = null;
          });

          debugPrint('   ✅ עודכן לכמות $newQuantity');
        }

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _lastAddedProduct = null;
            });
          }
        });
      }
    } catch (e) {
      debugPrint('   ❌ שגיאה: $e');
      if (!mounted) return;

      setState(() {
        _addingProductId = null;
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text(AppStrings.shopping.updateProductError(e.toString())),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// ➕ הוספת מוצר חדש (לא מהקטלוג) - פותח דיאלוג
  Future<void> _handleAddCustomProduct() async {
    final provider = context.read<ShoppingListsProvider>();

    await showAddEditProductDialog(
      context,
      onSave: (item) async {
        await provider.addUnifiedItem(widget.list.id, item);
        debugPrint(
            '✅ ProductSelectionBottomSheet: הוסף מוצר חדש "${item.name}"');

        if (!mounted) return;

        setState(() {
          _lastAddedProduct = item.name;
        });

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _lastAddedProduct = null;
            });
          }
        });
      },
    );
  }

  Future<void> _addProduct(Map<String, dynamic> product) async {
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    final provider = context.read<ShoppingListsProvider>();
    final productId = product['id']?.toString() ?? product['name'].toString();

    setState(() {
      _addingProductId = productId;
    });

    debugPrint('➕ ProductSelectionBottomSheet: מוסיף "${product['name']}"');

    final newItem = ReceiptItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: product['name'] as String,
      unitPrice: (product['price'] as num?)?.toDouble() ?? 0.0,
      barcode: product['barcode'] as String?,
      manufacturer: product['manufacturer'] as String?,
    );

    try {
      final detectedCategory =
          CategoryDetectionService.detectFromProductJson(product);

      await provider.addItemToList(
        widget.list.id,
        newItem.name ?? 'מוצר ללא שם',
        newItem.quantity,
        newItem.unit ?? "יח'",
        category: detectedCategory,
      );

      final originalCategory = product['category'] as String?;
      if (originalCategory != detectedCategory && originalCategory != null) {
        debugPrint(
            '   🔧 קטגוריה תוקנה: "$originalCategory" → "$detectedCategory"');
      } else {
        debugPrint('   ✅ נוסף בהצלחה עם קטגוריה: $detectedCategory');
      }

      if (!mounted) return;

      setState(() {
        _lastAddedProduct = newItem.name;
        _addingProductId = null;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _lastAddedProduct = null;
          });
        }
      });
    } catch (e) {
      debugPrint('   ❌ שגיאה: $e');
      if (!mounted) return;

      setState(() {
        _addingProductId = null;
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text(AppStrings.shopping.addProductError(e.toString())),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final productsProvider = context.watch<ProductsProvider>();
    final products = productsProvider.products;

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
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(kBorderRadiusLarge)),
            ),
            child: Stack(
              children: [
                // 🎨 Notebook background
                const Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(kBorderRadiusLarge)),
                    child: NotebookBackground(),
                  ),
                ),

                // 📝 Content
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
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
                            horizontal: kSpacingMedium, vertical: kSpacingSmall),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                AppStrings.shopping
                                    .addProductsTitle(widget.list.name),
                                style: theme.textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),

                      // 🔍 חיפוש עם אפקט זכוכית מט
                      _buildFrostedSearchBar(productsProvider),

                      // 🏷️ פילטרים קומפקטיים
                      _buildCompactCategoryFilters(productsProvider),

                      const SizedBox(height: kSpacingSmall),

                      // רשימת מוצרים
                      Expanded(
                        child: _buildProductsList(
                            productsProvider, products, cs, scrollController),
                      ),
                    ],
                  ),
                ),

                // ➕ FAB להוספת מוצר חדש
                Positioned(
                  left: kSpacingMedium,
                  bottom: kSpacingMedium,
                  child: FloatingActionButton(
                    heroTag: 'add_custom_product',
                    backgroundColor: kStickyYellow,
                    tooltip: 'הוסף מוצר חדש',
                    onPressed: _handleAddCustomProduct,
                    child:
                        const Icon(Icons.edit_note, color: Colors.black87, size: 28),
                  ),
                ),

                // ✅ באנר הצלחה צף
                if (_lastAddedProduct != null)
                  Positioned(
                    top: 80,
                    left: kSpacingMedium,
                    right: kSpacingMedium,
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey(_lastAddedProduct),
                      duration: const Duration(milliseconds: 400),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, -20 * (1 - value)),
                          child: Opacity(
                            opacity: value.clamp(0.0, 1.0),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(kSpacingMedium),
                        decoration: BoxDecoration(
                          color: kStickyGreen,
                          borderRadius: BorderRadius.circular(kBorderRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.white, size: 24),
                            const SizedBox(width: kSpacingSmall),
                            Expanded(
                              child: Text(
                                AppStrings.shopping
                                    .productAddedToList(_lastAddedProduct!),
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
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 🔍 שורת חיפוש עם אפקט זכוכית מט (Frosted Glass)
  Widget _buildFrostedSearchBar(ProductsProvider productsProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: kSpacingMedium, vertical: kSpacingSmall),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: kGlassBlurSigma, sigmaY: kGlassBlurSigma),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
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
                          _searchController.clear();
                          productsProvider.clearSearch();
                          setState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                isDense: true,
              ),
              onChanged: (value) {
                productsProvider.setSearchQuery(value.trim());
                setState(() {});
              },
            ),
          ),
        ),
      ),
    );
  }

  /// 🏷️ פילטרים קומפקטיים בגלילה אופקית
  Widget _buildCompactCategoryFilters(ProductsProvider productsProvider) {
    final categories = productsProvider.relevantCategories;
    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
        children: [
          // כפתור "הכל"
          _buildCompactFilterChip(
            label: AppStrings.common.all,
            emoji: widget.list.typeEmoji,
            isSelected: productsProvider.selectedCategory == null,
            onTap: () => productsProvider.clearCategory(),
          ),
          const SizedBox(width: 8),
          // קטגוריות
          ...categories.map((category) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _buildCompactFilterChip(
                  label: category,
                  emoji: _getCategoryEmoji(category),
                  isSelected: productsProvider.selectedCategory == category,
                  onTap: () => productsProvider.setCategory(category),
                ),
              )),
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
          side: BorderSide(
            color: isSelected ? Colors.black12 : Colors.transparent,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildProductsList(
    ProductsProvider provider,
    List<Map<String, dynamic>> products,
    ColorScheme cs,
    ScrollController scrollController,
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
            const SizedBox(height: kSpacingMedium),
            Text(provider.errorMessage ?? 'שגיאה לא ידועה'),
            const SizedBox(height: kSpacingLarge),
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
            Icon(Icons.inbox,
                size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: kSpacingMedium),
            Text(
              provider.searchQuery.isNotEmpty
                  ? AppStrings.shopping
                      .noProductsMatchingSearch(provider.searchQuery)
                  : AppStrings.shopping.noProductsAvailable,
              style:
                  const TextStyle(fontSize: kFontSizeMedium, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (provider.searchQuery.isEmpty) ...[
              const SizedBox(height: kSpacingLarge),
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

    return ListView.builder(
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
        // 🎬 Staggered animation
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 30).clamp(0, 300)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset((1 - value) * 50, 0),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: _buildCleanProductRow(product, cs),
        );
      },
    );
  }

  /// 🎴 שורת מוצר נקייה - על קווי המחברת (RTL optimized)
  Widget _buildCleanProductRow(Map<String, dynamic> product, ColorScheme cs) {
    final name = product['name'] as String? ?? AppStrings.shopping.productNoName;
    final category =
        product['category'] as String? ?? AppStrings.shopping.typeOther;

    // 🔍 בדיקה אם המוצר כבר ברשימה
    final provider = context.read<ShoppingListsProvider>();
    final currentList =
        provider.lists.firstWhere((l) => l.id == widget.list.id);
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
              // 🏷️ אייקון קטגוריה (ימין/Start ב-RTL)
              Text(
                _getCategoryEmoji(category),
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(width: 6),

              // 📝 שם המוצר - bold, יישור לימין
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold, // Bold לקריאות
                      color: isInList
                          ? cs.onSurface.withValues(alpha: 0.5)
                          : cs.onSurface,
                      height: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // ➕ כפתור הוספה/כמות (שמאל/End ב-RTL)
              isInList
                  ? _buildQuantityControls(product, currentQuantity)
                  : _buildAddButton(isAdding),
            ],
          ),
        ),
      ),
    );
  }

  /// ➕ כפתור הוספה עדין - רק אייקון ירוק
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

  /// 🔢 בקרי כמות קומפקטיים
  Widget _buildQuantityControls(
      Map<String, dynamic> product, int currentQuantity) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // כפתור +
        _buildSmallCircleButton(
          icon: Icons.add,
          color: kStickyGreen,
          onTap: () => _updateProductQuantity(product, currentQuantity + 1),
        ),
        // כמות
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: kStickyCyan,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$currentQuantity',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        // כפתור -
        _buildSmallCircleButton(
          icon: Icons.remove,
          color: kStickyPink,
          onTap: () => _updateProductQuantity(product, currentQuantity - 1),
        ),
      ],
    );
  }

  /// 🔘 כפתור עגול קטן
  Widget _buildSmallCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

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
