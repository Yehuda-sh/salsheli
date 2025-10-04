// 📄 File: lib/widgets/product_catalog.dart
//
// 🇮🇱 קטלוג מוצרים (ProductCatalog):
//     - מציג רשימת מוצרים ב־Grid.
//     - תומך במצבי טעינה, חיפוש ריק, והוספת מוצר חדש.
//     - כרטיס מוצר כולל שם, קטגוריה, מותג, גודל, מחיר.
//     - פעולה עיקרית: הוספה לרשימת קניות עם פידבק מיידי.
//
// 🇬🇧 ProductCatalog widget:
//     - Displays products in a grid layout.
//     - Supports loading, empty search state, and add-new-product action.
//     - Product card shows name, category, brand, package size, price.
//     - Main action: add to shopping list with instant feedback.
//

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../config/category_config.dart' show kCategoryConfigs;

/// --- Product Catalog Wrapper ---
class ProductCatalog extends StatefulWidget {
  final List<Product> products;
  final bool isLoading;
  final String searchTerm;
  final String? listTypeName;
  final void Function(Product product) onAddProduct;
  final VoidCallback onAddNewProductClick;

  const ProductCatalog({
    super.key,
    required this.products,
    required this.onAddProduct,
    required this.onAddNewProductClick,
    this.isLoading = false,
    this.searchTerm = "",
    this.listTypeName,
  });

  @override
  State<ProductCatalog> createState() => _ProductCatalogState();
}

class _ProductCatalogState extends State<ProductCatalog> {
  final Map<String, bool> _addedItems = {};

  void _handleAdd(Product product) {
    widget.onAddProduct(product);
    setState(() => _addedItems[product.id] = true);

    // אחרי 2 שניות – מחזיר את הכפתור למצב רגיל
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _addedItems.remove(product.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // --- מצב טעינה ---
    if (widget.isLoading) {
      return GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        children: List.generate(
          6,
          (i) => Card(
            color: cs.surfaceContainerHighest,
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }

    // --- מצב ריק (אין תוצאות) ---
    if (widget.products.isEmpty) {
      if (widget.searchTerm.isNotEmpty) {
        return _buildEmptySearch(cs);
      }
      return const Center(child: Text("אין מוצרים זמינים"));
    }

    // --- Grid של מוצרים ---
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final product = widget.products[index];
              final isAdded = _addedItems[product.id] ?? false;

              return ProductCard(
                product: product,
                isAdded: isAdded,
                onAdd: () => _handleAdd(product),
              );
            },
          ),

          const SizedBox(height: 12),

          // ➕ כפתור הוספת מוצר חדש
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onAddNewProductClick,
              icon: const Icon(Icons.add_box_outlined),
              label: const Text("הוסף מוצר חדש לקטלוג"),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔍 מצב "לא נמצא מוצר בחיפוש"
  Widget _buildEmptySearch(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 48, color: cs.outline),
          const SizedBox(height: 8),
          Text(
            "לא מצאנו את '${widget.searchTerm}'",
            style: TextStyle(color: cs.onSurface),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: widget.onAddNewProductClick,
            icon: const Icon(Icons.add_box_outlined),
            label: const Text("הוסף מוצר חדש לקטלוג"),
          ),
        ],
      ),
    );
  }
}

/// --- Product Card Component ---
class ProductCard extends StatelessWidget {
  final Product product;
  final bool isAdded;
  final VoidCallback onAdd;

  const ProductCard({
    super.key,
    required this.product,
    required this.isAdded,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cfg = kCategoryConfigs[product.category];

    final catName = cfg?.nameHe ?? product.category ?? "כללי";
    final catIcon = cfg?.emoji ?? "📦";
    final catColor = cfg?.color ?? const Color(0xFFE5E7EB);

    return InkWell(
      onTap: onAdd,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🏷 שם + קטגוריה
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    backgroundColor: catColor.withAlpha(38),
                    label: Text(catName, style: const TextStyle(fontSize: 11)),
                    avatar: Text(catIcon, style: const TextStyle(fontSize: 14)),
                    side: BorderSide(color: catColor.withAlpha(64)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              const SizedBox(height: 6),

              /// 📝 תיאור
              if (product.description?.trim().isNotEmpty ?? false)
                Text(
                  product.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),

              /// 🏢 מותג
              if (product.brand?.trim().isNotEmpty ?? false) ...[
                const SizedBox(height: 4),
                Text(
                  "מותג: ${product.brand}",
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],

              /// 📦 גודל
              if (product.packageSize?.trim().isNotEmpty ?? false) ...[
                const SizedBox(height: 2),
                Text(
                  "גודל: ${product.packageSize}",
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],

              /// 💰 מחיר
              if (product.price != null) ...[
                const SizedBox(height: 8),
                Text(
                  "₪${product.price!.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ],

              const Spacer(),

              /// ➕ כפתור/מצב "נוסף"
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: isAdded
                      ? Text(
                          "✅ נוסף בהצלחה",
                          key: const ValueKey('added'),
                          style: TextStyle(color: cs.tertiary),
                        )
                      : Text(
                          "+ הוסף לרשימה",
                          key: const ValueKey('add'),
                          style: TextStyle(color: cs.primary),
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
