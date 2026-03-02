// 📄 lib/widgets/shopping/product_filter_section.dart
// Version 4.0 - Hybrid Premium | 22/02/2026
//
// רכיב פילטור מוצרים - חיפוש וסינון לפי קטגוריות.
// כולל chips אנימטיביים, אינדיקטורי גלילה, ותמיכה בסוגי רשימות.
//
// Features:
//   - שורת סטטיסטיקה Glassmorphic (BackdropFilter + Gradient)
//   - אנימציית צ'יפים מדורגת (Staggered Chips)
//   - משוב Haptic מבוסס בחירה
//   - אופטימיזציית RepaintBoundary
//
// 🔗 Related: ProductsProvider, ProductSelectionBottomSheet, ShoppingList

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

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

  // FocusNode לצל ממוקד בשדה החיפוש
  late final FocusNode _searchFocus;

  // ✅ ValueNotifier לאינדיקטורים — מונע rebuild של כל הווידג'ט
  final ValueNotifier<bool> _showLeftFade = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _showRightFade = ValueNotifier<bool>(true);

  // ✅ Debounce לחיפוש — מונע קריאות מיותרות
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

    _searchFocus = FocusNode();

    if (widget.showFilters) {
      _animationController.forward();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFadeIndicators();
    });
  }

  void _updateFadeIndicators() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    if (maxScroll <= 0) {
      _showLeftFade.value = false;
      _showRightFade.value = false;
      return;
    }

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
    _searchFocus.dispose();
    _showLeftFade.dispose();
    _showRightFade.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// ✅ Debounced search
  void _onSearchChangedDebounced(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onSearchChanged(value);
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎨 Focus Shadow Wrapper (search field)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _withSearchFocusShadow(Widget child) {
    return ListenableBuilder(
      listenable: _searchFocus,
      builder: (context, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          decoration: _searchFocus.hasFocus
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: kStickyPurple.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                )
              : const BoxDecoration(),
          child: child,
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🏗️ Build
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = widget.productsProvider.relevantCategories;

    return Column(
      children: [
        // 🎯 Glassmorphic Stats Bar (כולל חיפוש)
        _buildStatsBar(context, theme),

        // 🎯 Animated Filters Section
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

  // ═══════════════════════════════════════════════════════════════════════════
  // 🌟 Glassmorphic Stats Bar
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildStatsBar(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
      // 🎨 BoxShadow עדין — תחושת ציפה מעל המחברת
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kBorderRadius),
        child: BackdropFilter(
          // 🌫️ Glassmorphic blur — מטשטש את תוכן המחברת מתחת
          filter: ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: kSpacingSmall,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kStickyPurple.withValues(alpha: 0.18),
                  kStickyCyan.withValues(alpha: 0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(kBorderRadius),
              border: Border.all(
                color: kStickyPurple.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                // כפתור הצגת/הסתרת פילטרים
                _buildFilterToggleButton(theme),

                const Gap(kSpacingSmall),

                // שדה חיפוש
                Expanded(child: _buildSearchField(theme)),

                // קטגוריה נבחרת
                if (widget.productsProvider.selectedCategory != null) ...[
                  const Gap(kSpacingSmall),
                  _buildSelectedCategoryChip(
                    category: widget.productsProvider.selectedCategory!,
                    onClear: () => widget.productsProvider.clearCategory(),
                    theme: theme,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔍 Search Field
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSearchField(ThemeData theme) {
    return _withSearchFocusShadow(
      SizedBox(
        height: 36,
        child: TextField(
          controller: widget.searchController,
          focusNode: _searchFocus,
          onChanged: _onSearchChangedDebounced,
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
                    onPressed: () {
                      // 📳 Haptic: selectionClick לניקוי חיפוש
                      unawaited(HapticFeedback.selectionClick());
                      widget.onSearchClear();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: kStickyPurple, width: 1.5),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface.withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔵 Selected Category Chip
  // ═══════════════════════════════════════════════════════════════════════════

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
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const Gap(kSpacingXTiny),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔘 Filter Toggle Button
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFilterToggleButton(ThemeData theme) {
    return InkWell(
      onTap: () {
        // 📳 Haptic: lightImpact לפתיחת/סגירת הפילטרים
        unawaited(HapticFeedback.lightImpact());
        widget.onToggleFilters();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.showFilters
              ? kStickyPurple.withValues(alpha: 0.15)
              : theme.colorScheme.surface.withValues(alpha: 0.85),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // 🏷️ Filter Categories (Staggered Chips)
  // ═══════════════════════════════════════════════════════════════════════════

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
          padding: const EdgeInsets.symmetric(
            horizontal: kSpacingSmall,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // כותרת קטגוריות — רק אם יש סינון פעיל
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
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: widget.productsProvider.clearCategory,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        child: Row(
                          children: [
                            Text(
                              AppStrings.common.clearAll,
                              style: const TextStyle(
                                fontSize: 11,
                                color: kStickyPurple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Gap(kSpacingXTiny),
                            const Icon(
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

              // 🎠 רשימת קטגוריות — גלילה אופקית + RepaintBoundary
              SizedBox(
                height: 40,
                child: Stack(
                  children: [
                    // 🎨 RepaintBoundary — מבודד גלילה אופקית מאנימציות fade
                    RepaintBoundary(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            // צ'יפ "הכל" — delay 0ms
                            _buildModernFilterChip(
                              label: AppStrings.common.all,
                              isSelected:
                                  widget.productsProvider.selectedCategory == null,
                              onTap: () => widget.productsProvider.clearCategory(),
                              emoji: widget.list.typeEmoji,
                              color: kStickyPurple,
                              theme: theme,
                            ).animate().fadeIn(duration: 400.ms).slideX(
                                  begin: 0.1,
                                  end: 0,
                                  curve: Curves.easeOutCubic,
                                ),

                            const Gap(6),

                            // צ'יפי קטגוריות — delay מדורג 30ms
                            ...categories.indexed.map((entry) {
                              final (i, category) = entry;
                              final delay = ((i + 1) * 30).ms;
                              return Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: _buildCategoryChip(category, theme)
                                    .animate()
                                    .fadeIn(
                                      duration: 400.ms,
                                      delay: delay,
                                    )
                                    .slideX(
                                      begin: 0.1,
                                      end: 0,
                                      delay: delay,
                                      curve: Curves.easeOutCubic,
                                    ),
                              );
                            }),

                            const Gap(24), // רווח לאינדיקטור
                          ],
                        ),
                      ),
                    ),

                    // ✅ אינדיקטור גלילה שמאלי
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

                    // ✅ אינדיקטור גלילה ימני
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

  // ═══════════════════════════════════════════════════════════════════════════
  // ◀▶ Scroll Indicators
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildScrollIndicator({
    required bool isLeft,
    required ThemeData theme,
  }) {
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

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔵 Category Chip
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCategoryChip(String category, ThemeData theme) {
    final count = widget.productsProvider.productsByCategory[category] ?? 0;
    final isSelected = widget.productsProvider.selectedCategory == category;

    return _buildModernFilterChip(
      label: category,
      count: count,
      isSelected: isSelected,
      onTap: () => widget.productsProvider.setCategory(category),
      emoji: _getCategoryEmoji(category),
      color: _getCategoryColor(category),
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
          onTap: () {
            // 📳 Haptic: selectionClick לבחירת קטגוריה
            unawaited(HapticFeedback.selectionClick());
            onTap();
          },
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
              color: isSelected
                  ? null
                  : colorScheme.surface.withValues(alpha: 0.85),
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
                Text(
                  emoji,
                  style: TextStyle(fontSize: isSelected ? 16 : 14),
                ),
                const Gap(6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? color : null,
                  ),
                ),
                if (count != null) ...[
                  const Gap(kSpacingXTiny),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
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
                        color: isSelected
                            ? color
                            : colorScheme.onSurfaceVariant,
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

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎨 Category Helpers
  // ═══════════════════════════════════════════════════════════════════════════

  String _getCategoryEmoji(String category) {
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

    switch (category) {
      case 'פירות':
        return '🍎';
      case 'ירקות':
        return '🥬';
      case 'פירות יבשים':
        return '🥜';
      case 'מוצרי חלב':
        return '🥛';
      case 'תחליפי חלב':
        return '🌱';
      case 'בשר ודגים':
        return '🥩';
      case 'תחליפי בשר':
        return '🌿';
      case 'מאפים':
        return '🥖';
      case 'אורז ופסטה':
        return '🍝';
      case 'דגנים':
        return '🥣';
      case 'קטניות ודגנים':
        return '🫘';
      case 'ממתקים וחטיפים':
        return '🍫';
      case 'ממרחים מתוקים':
        return '🍯';
      case 'אגוזים וגרעינים':
        return '🥜';
      case 'משקאות':
        return '🥤';
      case 'קפה ותה':
        return '☕';
      case 'שימורים':
        return '🥫';
      case 'שמנים ורטבים':
        return '🫒';
      case 'סלטים מוכנים':
        return '🥗';
      case 'תבלינים ואפייה':
        return '🧂';
      case 'קפואים':
        return '🧊';
      case 'מוצרי ניקיון':
        return '🧹';
      case 'מוצרי בית':
        return '🏠';
      case 'חד פעמי':
        return '🍽️';
      case 'מוצרי גינה':
        return '🌻';
      case 'היגיינה אישית':
        return '🧴';
      case 'מוצרי תינוקות':
        return '👶';
      case 'מזון לחיות מחמד':
        return '🐕';
      case 'אחר':
        return '📦';
      default:
        return '🛒';
    }
  }

  Color _getCategoryColor(String category) {
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

    final colors = [kStickyYellow, kStickyPink, kStickyGreen, kStickyCyan];
    return colors[category.hashCode.abs() % colors.length];
  }
}
