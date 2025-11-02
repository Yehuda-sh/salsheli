// 📄 File: lib/widgets/shopping/product_selection_bottom_sheet.dart
// תיאור: Bottom Sheet לבחירת מוצרים מהקטלוג
//
// ✨ תכונות:
// - חיפוש מוצרים בזמן אמיתי
// - סינון לפי קטגוריות
// - סינון חכם לפי סוג רשימה
// - הוספה מהירה לרשימה
// - מצבי טעינה/שגיאה/ריק
//
// 📦 תלויות:
// - ProductsProvider - ניהול קטלוג המוצרים
// - ShoppingListsProvider - ניהול רשימות הקניות
//
// 🎨 עיצוב:
// - Bottom Sheet מלא מסך
// - Sticky Notes Design System
// - תמיכה מלאה ב-RTL

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../models/receipt.dart';
import '../../models/shopping_list.dart';
import '../../providers/products_provider.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../providers/user_context.dart';
import '../common/sticky_button.dart';
import '../common/sticky_note.dart';
import '../common/tappable_card.dart';

class ProductSelectionBottomSheet extends StatefulWidget {
  final ShoppingList list;

  const ProductSelectionBottomSheet({super.key, required this.list});

  @override
  State<ProductSelectionBottomSheet> createState() => _ProductSelectionBottomSheetState();
}

class _ProductSelectionBottomSheetState extends State<ProductSelectionBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customQuantityController = TextEditingController(text: '1');
  
  ProductsProvider? _productsProvider;
  late UserContext _userContext;

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
    _searchController.dispose();
    _customQuantityController.dispose();
    super.dispose();
  }

  Future<void> _addProduct(Map<String, dynamic> product) async {
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    
    final provider = context.read<ShoppingListsProvider>();
    final quantity = int.tryParse(_customQuantityController.text.trim()) ?? 1;

    debugPrint('➕ ProductSelectionBottomSheet: מוסיף "${product['name']}" (x$quantity)');

    final newItem = ReceiptItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: product['name'] as String,
      quantity: quantity,
      unitPrice: (product['price'] as num?)?.toDouble() ?? 0.0,
      isChecked: false,
      barcode: product['barcode'] as String?,
      manufacturer: product['manufacturer'] as String?,
    );

    try {
      await provider.addItemToList(
        widget.list.id,
        newItem.name ?? 'מוצר ללא שם',
        newItem.quantity,
        newItem.unit ?? "יח'",
      );
      debugPrint('   ✅ נוסף בהצלחה');

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text('${newItem.name} נוסף לרשימה'),
          duration: kSnackBarDuration,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('   ❌ שגיאה: $e');
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text('שגיאה בהוספת מוצר: ${e.toString()}'),
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
    final categories = productsProvider.relevantCategories;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: kPaperBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(kBorderRadiusLarge)),
          ),
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
                padding: const EdgeInsets.all(kSpacingMedium),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'הוספת מוצרים: ${widget.list.name}',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // סטטיסטיקות
              if (productsProvider.lastUpdated != null)
                Container(
                  padding: const EdgeInsets.all(kSpacingSmallPlus),
                  margin: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(kBorderRadius),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2, size: kIconSizeMedium),
                      const SizedBox(width: kSpacingSmall),
                      Expanded(
                        child: Text(
                          '${productsProvider.totalProducts} מוצרים זמינים | מציג ${productsProvider.filteredProductsCount}',
                          style: TextStyle(
                            color: cs.onPrimaryContainer,
                            fontSize: kFontSizeSmall,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: kSpacingMedium),

              // חיפוש
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => productsProvider.setSearchQuery(value.trim()),
                  decoration: InputDecoration(
                    hintText: 'חפש מוצר...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              productsProvider.clearSearch();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                  ),
                ),
              ),

              const SizedBox(height: kSpacingSmallPlus),

              // קטגוריות
              if (categories.isNotEmpty)
                SizedBox(
                  height: kChipHeight,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: kSpacingSmall),
                        child: FilterChip(
                          label: const Text('הכל'),
                          selected: productsProvider.selectedCategory == null,
                          onSelected: (_) => productsProvider.clearCategory(),
                          selectedColor: cs.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      ...categories.map((category) {
                        final count = productsProvider.productsByCategory[category] ?? 0;
                        return Padding(
                          padding: const EdgeInsets.only(left: kSpacingSmall),
                          child: FilterChip(
                            label: Text('$category ($count)'),
                            selected: productsProvider.selectedCategory == category,
                            onSelected: (_) => productsProvider.setCategory(category),
                            selectedColor: cs.primary.withValues(alpha: 0.2),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

              const SizedBox(height: kSpacingSmall),

              // כמות
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                child: Row(
                  children: [
                    const Text('כמות:'),
                    const SizedBox(width: kSpacingSmall),
                    SizedBox(
                      width: kFieldWidthNarrow,
                      child: TextField(
                        controller: _customQuantityController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(kBorderRadiusSmall)),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: kSpacingSmall,
                            vertical: kSpacingSmallPlus,
                          ),
                          filled: true,
                          fillColor: cs.surfaceContainerHighest,
                        ),
                      ),
                    ),
                    const SizedBox(width: kSpacingSmall),
                    Text('יחידות', style: TextStyle(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),

              const SizedBox(height: kSpacingSmallPlus),

              // רשימת מוצרים
              Expanded(
                child: _buildProductsList(productsProvider, products, cs, scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductsList(
    ProductsProvider provider,
    List<Map<String, dynamic>> products,
    ColorScheme cs,
    ScrollController scrollController,
  ) {
    if (provider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: cs.primary),
            const SizedBox(height: kSpacingMedium),
            Text('טוען מוצרים...', style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    if (provider.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(kSpacingXLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: cs.error),
              const SizedBox(height: kSpacingMedium),
              Text(
                provider.errorMessage ?? 'שגיאה לא ידועה',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: kSpacingLarge),
              StickyButton(
                label: 'נסה שוב',
                icon: Icons.refresh,
                onPressed: () => provider.loadProducts(),
                color: kStickyGreen,
              ),
            ],
          ),
        ),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(kSpacingXLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2,
                size: kIconSizeXLarge,
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: kSpacingMedium),
              Text(
                provider.searchQuery.isNotEmpty
                    ? 'לא נמצאו מוצרים התואמים "${provider.searchQuery}"'
                    : 'אין מוצרים זמינים כרגע',
                style: const TextStyle(fontSize: kFontSizeMedium, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: kSpacingSmall),
              Text(
                provider.searchQuery.isNotEmpty ? 'נסה לחפש משהו אחר' : 'טען מוצרים מהשרת',
                style: TextStyle(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product, cs);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, ColorScheme cs) {
    final name = product['name'] as String? ?? 'ללא שם';
    final price = (product['price'] as num?)?.toDouble() ?? 0.0;
    final category = product['category'] as String? ?? 'אחר';
    final manufacturer = product['manufacturer'] as String?;

    return Padding(
      padding: const EdgeInsets.only(bottom: kSpacingTiny),
      child: StickyNote(
        color: kStickyYellow,
        rotation: (product.hashCode % 5 - 2) * 0.005,
        child: SimpleTappableCard(
          onTap: () => _addProduct(product),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kSpacingSmallPlus, vertical: kSpacingSmall),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(_getCategoryIcon(category), color: cs.primary, size: 18),
                ),
                const SizedBox(width: kSpacingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: kSpacingSmall),
                          Text(
                            '₪${price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: cs.secondaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(fontSize: 11, color: cs.onSecondaryContainer),
                            ),
                          ),
                          if (manufacturer != null) ...[
                            const SizedBox(width: kSpacingSmall),
                            Flexible(
                              child: Text(
                                manufacturer,
                                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: kSpacingSmall),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: kStickyGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    onPressed: () => _addProduct(product),
                    icon: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 18),
                    padding: EdgeInsets.zero,
                    tooltip: 'הוסף לרשימה',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'מזון':
        return Icons.restaurant;
      case 'ניקיון':
        return Icons.cleaning_services;
      case 'טיפוח':
        return Icons.spa;
      case 'משקאות':
        return Icons.local_drink;
      case 'חלב וביצים':
        return Icons.egg;
      case 'בשר ודגים':
        return Icons.set_meal;
      case 'פירות וירקות':
        return Icons.eco;
      default:
        return Icons.shopping_basket;
    }
  }
}
