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

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/receipt.dart';
import '../../models/shopping_list.dart';
import '../../providers/products_provider.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../providers/user_context.dart';
import '../common/animated_button.dart';
import '../common/notebook_background.dart';
import '../common/sticky_button.dart';
import '../common/sticky_note.dart';
import '../common/tappable_card.dart';
import 'product_filter_section.dart';

class ProductSelectionBottomSheet extends StatefulWidget {
  final ShoppingList list;

  const ProductSelectionBottomSheet({super.key, required this.list});

  @override
  State<ProductSelectionBottomSheet> createState() => _ProductSelectionBottomSheetState();
}

class _ProductSelectionBottomSheetState extends State<ProductSelectionBottomSheet> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customQuantityController = TextEditingController(text: '1');

  ProductsProvider? _productsProvider;
  late UserContext _userContext;
  bool _showFilters = false;

  // 🎬 Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _userContext = context.read<UserContext>();
    _userContext.addListener(_onUserContextChanged);

    // 🎬 Initialize animations
    _fadeController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _slideController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);

    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    // Start animations
    _fadeController.forward();
    _slideController.forward();

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
    // clearListType עם notify=false כדי למנוע notifyListeners במהלך dispose
    _productsProvider?.clearListType(notify: false);
    _fadeController.dispose();
    _slideController.dispose();
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
      // isChecked defaults to false, no need to specify
      barcode: product['barcode'] as String?, // Can be null
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

                // 📝 Content
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
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
                          padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'הוספת מוצרים: ${widget.list.name}',
                                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                            ],
                          ),
                        ),

                        // 🎯 Filter Section
                        ProductFilterSection(
                          productsProvider: productsProvider,
                          list: widget.list,
                          showFilters: _showFilters,
                          onToggleFilters: () {
                            setState(() {
                              _showFilters = !_showFilters;
                            });
                          },
                        ),

                        // חיפוש
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) => productsProvider.setSearchQuery(value.trim()),
                            decoration: InputDecoration(
                              hintText: AppStrings.priceComparison.searchHint,
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

                        const SizedBox(height: kSpacingTiny),

                        // כמות
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                          child: Row(
                            children: [
                              Text(AppStrings.listDetails.quantityLabel),
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

                        const SizedBox(height: kSpacingTiny),

                        // רשימת מוצרים
                        Expanded(child: _buildProductsList(productsProvider, products, cs, scrollController)),
                      ],
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

  Widget _buildProductsList(
  ProductsProvider provider,
  List<Map<String, dynamic>> products,
  ColorScheme cs,
  ScrollController scrollController,
) {
  if (provider.isLoading) {
    // 🎨 Loading state
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: kSpacingMedium),
          Text('טוען מוצרים...'),
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
              label: AppStrings.common.retry,
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
    // 📦 Empty state with better design
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.bounceOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(Icons.inbox, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                );
              },
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
            if (provider.searchQuery.isEmpty) ...[
              const SizedBox(height: kSpacingLarge),
              StickyButton(
                label: 'טען מוצרים',
                icon: Icons.refresh,
                color: kStickyGreen,
                onPressed: () => provider.loadProducts(),
              ),
            ],
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
      // 🎬 Staggered animation for each card
      return TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 300 + (index * 50)),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset((1 - value) * 50, 0),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: _buildProductCard(product, cs),
      );
    },
  );
  }

  Widget _buildProductCard(Map<String, dynamic> product, ColorScheme cs) {
  final name = product['name'] as String? ?? 'ללא שם';
  final category = product['category'] as String? ?? 'אחר';
  final manufacturer = product['manufacturer'] as String?;
  final description = product['description'] as String?;
  final hasImage = product['imageUrl'] != null;

  // צבעים לפי קטגוריה
  final Color stickyColor = _getCategoryColor(category);

  return Padding(
    padding: const EdgeInsets.only(bottom: kSpacingSmall),
    child: StickyNote(
      color: stickyColor,
      rotation: (product.hashCode % 5 - 2) * 0.003,
      child: SimpleTappableCard(
        onTap: () => _addProduct(product),
        child: Padding(
          padding: const EdgeInsets.all(kSpacingSmall),
          child: Row(
            children: [
              // תמונה גדולה בצד שמאל
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.2), width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: hasImage
                      ? Image.asset(
                          product['imageUrl'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: cs.surfaceContainerHighest,
                              child: Icon(_getCategoryIcon(category), size: 28, color: cs.onSurfaceVariant),
                            );
                          },
                        )
                      : Container(
                          color: cs.surfaceContainerHighest,
                          child: Center(child: Text(_getCategoryEmoji(category), style: const TextStyle(fontSize: 28))),
                        ),
                ),
              ),
              const SizedBox(width: kSpacingSmall),
              // תוכן
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    if (description != null)
                      Text(
                        description,
                        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(category, style: TextStyle(fontSize: 10, color: cs.onSecondaryContainer)),
                        ),
                        if (manufacturer != null) ...[
                          const SizedBox(width: 4),
                          Text('• $manufacturer', style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: kSpacingSmall),
              // כפתור הוספה
              AnimatedButton(
                onPressed: () => _addProduct(product),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kStickyGreen,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Color _getCategoryColor(String category) {
    // צבעים מיוחדים לקטגוריות באטליז
    if (widget.list.type == 'butcher') {
      switch (category) {
        case 'בקר':
          return kStickyPink;
        case 'עוף':
          return kStickyYellow;
        case 'דגים':
          return kStickyCyan;
        case 'טלה וכבש':
          return kStickyOrange;
        case 'הודו':
          return kStickyPurple;
        case 'אחר':
          return kStickyGreen;
        default:
          final colors = [kStickyYellow, kStickyPink, kStickyGreen, kStickyCyan];
          return colors[category.hashCode.abs() % colors.length];
      }
    } else {
      final colors = [kStickyYellow, kStickyPink, kStickyGreen, kStickyCyan];
      return colors[category.hashCode.abs() % colors.length];
    }
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
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
      case 'אחר':
        return '🌭';
      default:
        return '🥩';
    }
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


