// 📄 File: lib/screens/lists/populate_list_screen.dart
// תיאור: מסך להוספת מוצרים לרשימת קניות מקטלוג המוצרים
//
// ✨ תכונות:
// - חיפוש מוצרים בזמן אמיתי
// - סינון לפי קטגוריות
// - רענון מוצרים מהשרת
// - הצגת סטטיסטיקות (כמה מוצרים זמינים/מוצגים)
// - בחירת כמות מותאמת אישית
// - הוספה מהירה לרשימה
// - מצבי טעינה/שגיאה/ריק
//
// 📦 תלויות:
// - ProductsProvider - ניהול קטלוג המוצרים
// - ShoppingListsProvider - ניהול רשימות הקניות
//
// 🎨 עיצוב:
// - שימוש ב-Theme בלבד (אין צבעים קבועים)
// - תמיכה מלאה ב-RTL
// - responsive למכשירים שונים

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/shopping_list.dart';
import '../../models/receipt.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../providers/products_provider.dart';
import '../../theme/app_theme.dart';

class PopulateListScreen extends StatefulWidget {
  final ShoppingList list;

  const PopulateListScreen({super.key, required this.list});

  @override
  State<PopulateListScreen> createState() => _PopulateListScreenState();
}

class _PopulateListScreenState extends State<PopulateListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customQuantityController = TextEditingController(
    text: '1',
  );

  @override
  void initState() {
    super.initState();
    // טוען מוצרים אם צריך
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final productsProvider = context.read<ProductsProvider>();
      if (productsProvider.isEmpty && !productsProvider.isLoading) {
        productsProvider.loadProducts();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customQuantityController.dispose();
    super.dispose();
  }

  /// הוספת מוצר לרשימה
  Future<void> _addProduct(Map<String, dynamic> product) async {
    final provider = context.read<ShoppingListsProvider>();
    final quantity = int.tryParse(_customQuantityController.text.trim()) ?? 1;

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
      await provider.addItemToList(widget.list.id, newItem);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newItem.name} נוסף לרשימה'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בהוספת מוצר: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    final productsProvider = context.watch<ProductsProvider>();
    final products = productsProvider.products;
    final categories = productsProvider.categories;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surfaceContainer,
        title: Text(
          'הוספת מוצרים: ${widget.list.name}',
          style: TextStyle(color: cs.onSurface),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // כפתור רענון
          if (productsProvider.lastUpdated != null)
            IconButton(
              icon: productsProvider.isRefreshing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: accent,
                      ),
                    )
                  : const Icon(Icons.refresh),
              tooltip: 'רענון מוצרים מהשרת',
              onPressed: productsProvider.isRefreshing
                  ? null
                  : () => productsProvider.refreshProducts(force: true),
            ),
          // כפתור סיום
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.check),
            label: const Text('סיום'),
            style: TextButton.styleFrom(foregroundColor: accent),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header - סטטיסטיקות
          if (productsProvider.lastUpdated != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.inventory_2, color: accent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${productsProvider.totalProducts} מוצרים זמינים | '
                      'מציג ${productsProvider.filteredProductsCount}',
                      style: TextStyle(
                        color: cs.onPrimaryContainer,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),

          // שורת חיפוש
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  productsProvider.setSearchQuery(value.trim()),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: cs.surfaceContainerHighest,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // סינון קטגוריות
          if (categories.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // כפתור "הכל"
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: const Text('הכל'),
                      selected: productsProvider.selectedCategory == null,
                      onSelected: (_) => productsProvider.clearCategory(),
                      selectedColor: accent.withValues(alpha: 0.2),
                    ),
                  ),
                  // כפתורי קטגוריות
                  ...categories.map((category) {
                    final count =
                        productsProvider.productsByCategory[category] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: FilterChip(
                        label: Text('$category ($count)'),
                        selected: productsProvider.selectedCategory == category,
                        onSelected: (_) =>
                            productsProvider.setCategory(category),
                        selectedColor: accent.withValues(alpha: 0.2),
                      ),
                    );
                  }),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // שדה בחירת כמות
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('כמות:'),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _customQuantityController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('יחידות', style: TextStyle(color: cs.onSurfaceVariant)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // רשימת מוצרים
          Expanded(
            child: _buildProductsList(productsProvider, products, cs, accent),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(
    ProductsProvider provider,
    List<Map<String, dynamic>> products,
    ColorScheme cs,
    Color accent,
  ) {
    // מצב טעינה
    if (provider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: accent),
            const SizedBox(height: 16),
            Text(
              'טוען מוצרים...',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    // מצב שגיאה
    if (provider.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: cs.error),
              const SizedBox(height: 16),
              Text(
                provider.errorMessage ?? 'שגיאה לא ידועה',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => provider.loadProducts(),
                icon: const Icon(Icons.refresh),
                label: const Text('נסה שוב'),
                style: FilledButton.styleFrom(minimumSize: const Size(120, 48)),
              ),
            ],
          ),
        ),
      );
    }

    // מצב ריק
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2,
                size: 80,
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                provider.searchQuery.isNotEmpty
                    ? 'לא נמצאו מוצרים התואמים לחיפוש'
                    : 'אין מוצרים זמינים',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                provider.searchQuery.isNotEmpty
                    ? 'נסה לחפש משהו אחר'
                    : 'טען מוצרים מהשרת',
                style: TextStyle(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              if (provider.searchQuery.isEmpty) ...[
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => provider.loadProducts(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('טען מוצרים'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(140, 48),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // רשימת מוצרים
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product, cs, accent);
      },
    );
  }

  Widget _buildProductCard(
    Map<String, dynamic> product,
    ColorScheme cs,
    Color accent,
  ) {
    final name = product['name'] as String? ?? 'ללא שם';
    final price = (product['price'] as num?)?.toDouble() ?? 0.0;
    final category = product['category'] as String? ?? 'אחר';
    final manufacturer = product['manufacturer'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outline.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: () => _addProduct(product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // אייקון קטגוריה
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  color: accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // פרטי המוצר
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSecondaryContainer,
                            ),
                          ),
                        ),
                        if (manufacturer != null) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              manufacturer,
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurfaceVariant,
                              ),
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

              // מחיר וכפתור הוספה
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₪${price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: () => _addProduct(product),
                      icon: const Icon(
                        Icons.add_shopping_cart,
                        color: Colors.white,
                        size: 24,
                      ),
                      padding: EdgeInsets.zero,
                      tooltip: 'הוסף לרשימה',
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
