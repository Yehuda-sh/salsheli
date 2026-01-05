// 📄 lib/widgets/shopping/product_filter_section.dart
//
// רכיב פילטור מוצרים - חיפוש וסינון לפי קטגוריות.
// כולל chips אנימטיביים, אינדיקטורי גלילה, ותמיכה בסוגי רשימות.
//
// 🔗 Related: ProductsProvider, ProductSelectionBottomSheet, ShoppingList

import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/shopping_list.dart';
import '../../providers/products_provider.dart';

class ProductFilterSection extends StatefulWidget {
  final ProductsProvider productsProvider;
  final ShoppingList list;
  final bool showFilters;
  final VoidCallback onToggleFilters;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;

  const ProductFilterSection({
    super.key,
    required this.productsProvider,
    required this.list,
    required this.showFilters,
    required this.onToggleFilters,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSearchClear,
  });

  @override
  State<ProductFilterSection> createState() => _ProductFilterSectionState();
}

class _ProductFilterSectionState extends State<ProductFilterSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late ScrollController _scrollController;

  // ✅ ValueNotifier לאינדיקטורים - מונע rebuild של כל הווידג'ט
  final ValueNotifier<bool> _showLeftFade = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _showRightFade = ValueNotifier<bool>(true);

  // ✅ Debounce לחיפוש - מונע קריאות מיותרות
  Timer? _debounceTimer;

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

    _scrollController = ScrollController();
    _scrollController.addListener(_updateFadeIndicators);

    if (widget.showFilters) {
      _animationController.forward();
    }

    // עדכון אינדיקטורים אחרי הבנייה הראשונית
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFadeIndicators();
    });
  }

  void _updateFadeIndicators() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    // אם אין מה לגלול, לא מציגים אינדיקטורים
    if (maxScroll <= 0) {
      _showLeftFade.value = false;
      _showRightFade.value = false;
      return;
    }

    // ✅ ValueNotifier - לא קורא setState, רק מעדכן את האינדיקטורים
    // LTR layout:
    // - Left arrow shows when can scroll left (offset > 0)
    // - Right arrow shows when can scroll right (offset < max)
    _showLeftFade.value = currentScroll > 10;
    _showRightFade.value = currentScroll < maxScroll - 10;
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
    _scrollController.dispose();
    _showLeftFade.dispose();
    _showRightFade.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// ✅ Debounced search - מונע קריאות מיותרות בזמן הקלדה
  void _onSearchChangedDebounced(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onSearchChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = widget.productsProvider.relevantCategories;

    return Column(
      children: [
        // 🎯 Compact Filter & Stats Bar (כולל חיפוש)
        _buildStatsBar(context, theme),

        // 🎯 Animated Filters Section - רווח מינימלי
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: widget.showFilters && categories.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _buildFilterCategories(context, theme, categories),
                )
              : const SizedBox.shrink(),
        ),
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
          // כפתור הצגת/הסתרת פילטרים
          _buildFilterToggleButton(theme),

          const SizedBox(width: 8),

          // שדה חיפוש
          Expanded(
            child: _buildSearchField(theme),
          ),

          // קטגוריה נבחרת
          if (widget.productsProvider.selectedCategory != null) ...[
            const SizedBox(width: 8),
            _buildSelectedCategoryChip(
              category: widget.productsProvider.selectedCategory!,
              onClear: () => widget.productsProvider.clearCategory(),
              theme: theme,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: widget.searchController,
        onChanged: _onSearchChangedDebounced, // ✅ Debounce
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: AppStrings.common.searchProductHint,
          hintStyle: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 36),
          suffixIcon: widget.searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 18,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  onPressed: widget.onSearchClear,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: kStickyPurple,
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
        ),
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.showFilters
              ? kStickyPurple.withValues(alpha: 0.15)
              : theme.colorScheme.surface,
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
            widget.showFilters ? Icons.expand_less : Icons.expand_more,
            size: 22,
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
                      widget.list.type == 'butcher'
                          ? AppStrings.common.meatTypes
                          : AppStrings.common.categories,
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
                              AppStrings.common.clearAll,
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
              
              // רשימת הקטגוריות - גלילה אופקית
              SizedBox(
                height: 40,
                child: Stack(
                  children: [
                    // רשימת הקטגוריות עם גלילה
                    SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          // כפתור "הכל" (ללא מספר מוצרים)
                          _buildModernFilterChip(
                            label: AppStrings.common.all,
                            count: null,
                            isSelected: widget.productsProvider.selectedCategory == null,
                            onTap: () => widget.productsProvider.clearCategory(),
                            emoji: widget.list.typeEmoji,
                            color: kStickyPurple,
                            theme: theme,
                          ),
                          const SizedBox(width: 6),
                          // שאר הקטגוריות
                          ...categories.map((category) => Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: _buildCategoryChip(category, theme),
                          )),
                          // רווח בסוף לאינדיקטור
                          const SizedBox(width: 24),
                        ],
                      ),
                    ),

                    // ✅ אינדיקטור גלילה שמאלי - ValueListenableBuilder + AnimatedOpacity
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _showLeftFade,
                        builder: (context, show, child) => AnimatedOpacity(
                          opacity: show ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: IgnorePointer(
                            ignoring: !show,
                            child: child,
                          ),
                        ),
                        child: _buildScrollIndicator(isLeft: true, theme: theme),
                      ),
                    ),

                    // ✅ אינדיקטור גלילה ימני - ValueListenableBuilder + AnimatedOpacity
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _showRightFade,
                        builder: (context, show, child) => AnimatedOpacity(
                          opacity: show ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: IgnorePointer(
                            ignoring: !show,
                            child: child,
                          ),
                        ),
                        child: _buildScrollIndicator(isLeft: false, theme: theme),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildScrollIndicator({required bool isLeft, required ThemeData theme}) {
    return Container(
      width: 28,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
          colors: [
            theme.colorScheme.surfaceContainerHighest,
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0),
          ],
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: kStickyPurple.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isLeft ? Icons.chevron_left : Icons.chevron_right,
            size: 16,
            color: kStickyPurple,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category, ThemeData theme) {
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
      theme: theme,
    );
  }

  Widget _buildModernFilterChip({
    required String label,
    int? count,
    required bool isSelected,
    required VoidCallback onTap,
    required String emoji,
    required Color color,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;

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
              color: isSelected ? null : colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? color
                    : colorScheme.outline.withValues(alpha: 0.3),
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
                // מציג מספר רק אם יש ערך
                if (count != null) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.2)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
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

    // סופרמרקט - כל הקטגוריות
    switch (category) {
      // פירות וירקות
      case 'פירות':
        return '🍎';
      case 'ירקות':
        return '🥬';
      case 'פירות יבשים':
        return '🥜';

      // מוצרי חלב וביצים
      case 'מוצרי חלב':
        return '🥛';
      case 'תחליפי חלב':
        return '🌱';

      // בשר ודגים
      case 'בשר ודגים':
        return '🥩';
      case 'תחליפי בשר':
        return '🌿';

      // לחם ומאפים
      case 'מאפים':
        return '🥖';

      // דגנים ופסטה
      case 'אורז ופסטה':
        return '🍝';
      case 'דגנים':
        return '🥣';
      case 'קטניות ודגנים':
        return '🫘';

      // ממתקים וחטיפים
      case 'ממתקים וחטיפים':
        return '🍫';
      case 'ממרחים מתוקים':
        return '🍯';
      case 'אגוזים וגרעינים':
        return '🥜';

      // משקאות
      case 'משקאות':
        return '🥤';
      case 'קפה ותה':
        return '☕';

      // שימורים ורטבים
      case 'שימורים':
        return '🥫';
      case 'שמנים ורטבים':
        return '🫒';
      case 'סלטים מוכנים':
        return '🥗';

      // תבלינים ואפייה
      case 'תבלינים ואפייה':
        return '🧂';

      // קפואים
      case 'קפואים':
        return '🧊';

      // ניקיון ובית
      case 'מוצרי ניקיון':
        return '🧹';
      case 'מוצרי בית':
        return '🏠';
      case 'חד פעמי':
        return '🍽️';
      case 'מוצרי גינה':
        return '🌻';

      // היגיינה וטיפוח
      case 'היגיינה אישית':
        return '🧴';

      // תינוקות וחיות
      case 'מוצרי תינוקות':
        return '👶';
      case 'מזון לחיות מחמד':
        return '🐕';

      // אחר
      case 'אחר':
        return '📦';

      default:
        return '🛒';
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
