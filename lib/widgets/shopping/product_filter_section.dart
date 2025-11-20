// 📄 File: lib/widgets/shopping/product_filter_section.dart
// תיאור: רכיב פילטור מוצרים מתקדם עבור ProductSelectionBottomSheet
//
// ✨ תכונות:
// - סטטיסטיקות מוצרים בזמן אמת
// - פילטור לפי קטגוריות עם אנימציות
// - עיצוב Sticky Notes עם צבעים דינמיים
// - תמיכה בסוגי רשימות שונים (כולל אטליז)
//
// 🎨 עיצוב:
// - Modern filter chips עם emojis
// - אנימציות נפילה וסיבוב
// - גרדיאנטים וצללים
// - תמיכה מלאה ב-RTL

import 'package:flutter/material.dart';

import '../../core/ui_constants.dart';
import '../../models/shopping_list.dart';
import '../../providers/products_provider.dart';

class ProductFilterSection extends StatefulWidget {
  final ProductsProvider productsProvider;
  final ShoppingList list;
  final bool showFilters;
  final VoidCallback onToggleFilters;

  const ProductFilterSection({
    super.key,
    required this.productsProvider,
    required this.list,
    required this.showFilters,
    required this.onToggleFilters,
  });

  @override
  State<ProductFilterSection> createState() => _ProductFilterSectionState();
}

class _ProductFilterSectionState extends State<ProductFilterSection> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (widget.showFilters) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ProductFilterSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showFilters != oldWidget.showFilters) {
      if (widget.showFilters) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = widget.productsProvider.relevantCategories;

    return Column(
      children: [
        // 🎯 Compact Filter & Stats Bar
        _buildStatsBar(context, theme),
        
        const SizedBox(height: kSpacingSmallPlus),
        
        // 🎯 Animated Filters Section
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: widget.showFilters && categories.isNotEmpty
              ? _buildFilterCategories(context, theme, categories)
              : const SizedBox.shrink(),
        ),
        
        if (widget.showFilters && categories.isNotEmpty) 
          const SizedBox(height: kSpacingTiny),
      ],
    );
  }

  Widget _buildStatsBar(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
      padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kStickyPurple.withValues(alpha: 0.15),
            kStickyCyan.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(kBorderRadius),
        border: Border.all(
          color: kStickyPurple.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // מספר מוצרים
          _buildStatChip(
            icon: Icons.inventory_2,
            label: '${widget.productsProvider.filteredProductsCount} מוצרים',
            color: kStickyPurple,
          ),
          
          const SizedBox(width: 8),
          
          // קטגוריה נבחרת
          if (widget.productsProvider.selectedCategory != null) ...[
            _buildSelectedCategoryChip(
              category: widget.productsProvider.selectedCategory!,
              onClear: () => widget.productsProvider.clearCategory(),
              theme: theme,
            ),
          ],
          
          const Spacer(),
          
          // כפתור הצגת/הסתרת פילטרים
          _buildFilterToggleButton(theme),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedCategoryChip({
    required String category,
    required VoidCallback onClear,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: kStickyCyan.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            category,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onClear,
            child: Icon(
              Icons.close,
              size: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToggleButton(ThemeData theme) {
    return InkWell(
      onTap: widget.onToggleFilters,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedRotation(
          turns: widget.showFilters ? 0.5 : 0,
          duration: const Duration(milliseconds: 300),
          child: Icon(
            Icons.tune,
            size: 18,
            color: widget.showFilters
                ? kStickyPurple
                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterCategories(
    BuildContext context,
    ThemeData theme,
    List<String> categories,
  ) {
    return FadeTransition(
      opacity: _expandAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.2),
          end: Offset.zero,
        ).animate(_expandAnimation),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
          padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // כותרת קטגוריות - רק אם יש סינון
              if (widget.productsProvider.selectedCategory != null) ...[
                Row(
                  children: [
                    Text(
                      widget.list.type == 'butcher' ? 'סוגי בשר' : 'קטגוריות',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: widget.productsProvider.clearCategory,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Row(
                          children: [
                            Text(
                              'נקה הכל',
                              style: TextStyle(
                                fontSize: 11,
                                color: kStickyPurple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.clear_all,
                              size: 14,
                              color: kStickyPurple,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              
              // רשימת הקטגוריות
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  // כפתור "הכל"
                  _buildModernFilterChip(
                    label: 'הכל',
                    count: widget.productsProvider.filteredProductsCount,
                    isSelected: widget.productsProvider.selectedCategory == null,
                    onTap: () => widget.productsProvider.clearCategory(),
                    emoji: widget.list.typeEmoji, // ✅ שימוש ב-getter מהמודל
                    color: kStickyPurple,
                  ),
                  
                  // שאר הקטגוריות
                  ...categories.map((category) => _buildCategoryChip(category)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildCategoryChip(String category) {
    final count = widget.productsProvider.productsByCategory[category] ?? 0;
    final isSelected = widget.productsProvider.selectedCategory == category;
    
    final emoji = _getCategoryEmoji(category);
    final color = _getCategoryColor(category);
    
    return _buildModernFilterChip(
      label: category,
      count: count,
      isSelected: isSelected,
      onTap: () => widget.productsProvider.setCategory(category),
      emoji: emoji,
      color: color,
    );
  }

  Widget _buildModernFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required String emoji,
    required Color color,
  }) {
    return AnimatedScale(
      scale: isSelected ? 1.03 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.25),
                        color.withValues(alpha: 0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected 
                    ? color 
                    : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: TextStyle(fontSize: isSelected ? 16 : 14)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? color : null,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.2)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected 
                          ? color
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ פונקציה _getListTypeEmoji הוסרה - השתמש ב-widget.list.typeEmoji במקום

  String _getCategoryEmoji(String category) {
    // אטליז
    if (widget.list.type == 'butcher') {
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
        default:
          return '🌭';
      }
    }
    
    // כללי
    switch (category.toLowerCase()) {
      case 'חלב וביצים':
        return '🥛';
      case 'פירות וירקות':
        return '🥬';
      case 'בשר ודגים':
        return '🥩';
      case 'משקאות':
        return '🥤';
      case 'ניקיון':
        return '🧹';
      case 'טיפוח':
        return '💄';
      case 'מוצרי תינוקות':
        return '👶';
      default:
        return '📦';
    }
  }

  Color _getCategoryColor(String category) {
    // צבעים מיוחדים לאטליז
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
        default:
          return kStickyGreen;
      }
    }
    
    // צבעים רגילים
    final colors = [kStickyYellow, kStickyPink, kStickyGreen, kStickyCyan];
    return colors[category.hashCode.abs() % colors.length];
  }
}
