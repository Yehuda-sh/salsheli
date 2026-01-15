// 📄 lib/screens/home/dashboard/widgets/upcoming_shop_card.dart
//
// כרטיס "הקנייה הקרובה" בדשבורד - מציג רשימה פעילה או מצב ריק.
// כולל שם רשימה, תג סוג, ספירת פריטים וכפתור "התחל קנייה".
//
// ✅ Features:
//    - Theme-aware colors (Dark Mode support)
//    - Accessibility with semanticLabel and tooltips
//    - Empty state with CTA to create list
//    - Hebrew RTL support
//
// 🔗 Related: DashboardCard, ShoppingList
//
// ----------------------------------------------------------------------------
// The UpcomingShopCard widget displays the next shopping list to work on.
// Appears on the Home Dashboard with list details and "Start Shopping" action.
//
// Features:
// • Shows active list with item count and type tag
// • Empty state with "Create List" CTA
// • Theme-aware with Dark Mode support
// • Accessibility with Semantics labels
// ----------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/ui_constants.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../models/shopping_list.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/common/dashboard_card.dart';

class UpcomingShopCard extends StatelessWidget {
  final ShoppingList? list;

  const UpcomingShopCard({super.key, this.list});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.upcomingShopCard;
    // ✅ FIX: Theme-aware color
    final theme = Theme.of(context);
    final accentColor = theme.extension<AppBrand>()?.accent ?? kStickyPink;

    if (list == null) {
      return _EmptyUpcomingCard(
        onCreateList: () => Navigator.pushNamed(context, '/create-list'),
      );
    }

    // ✅ Semantics - תיאור מפורט לנגישות
    final itemCount = list!.items.length;

    return DashboardCard(
      // ✅ FIX: Use AppStrings
      title: strings.cardTitle,
      icon: Icons.shopping_cart,
      // ✅ FIX: Theme-aware color
      color: accentColor,
      rotation: 0.015,
      // ✅ FIX: Use AppStrings
      semanticLabel: strings.semanticLabel(list!.name, itemCount),
      tooltip: strings.editListTooltip(list!.name),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/populate-list',
          arguments: list,
        );
      },
      child: _ListSummary(list: list!),
    );
  }
}

/// כרטיס ריק - כשאין רשימה פעילה
class _EmptyUpcomingCard extends StatelessWidget {
  final VoidCallback onCreateList;

  const _EmptyUpcomingCard({required this.onCreateList});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final strings = AppStrings.upcomingShopCard;
    // ✅ FIX: Theme-aware color
    final successColor = theme.extension<AppBrand>()?.success ?? kStickyCyan;

    return DashboardCard(
      // ✅ FIX: Use AppStrings
      title: strings.cardTitle,
      icon: Icons.shopping_cart_outlined,
      // ✅ FIX: Theme-aware color
      color: successColor,
      rotation: -0.01,
      // ✅ FIX: Use AppStrings
      semanticLabel: strings.emptySemanticLabel,
      child: Column(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 48,
            color: cs.onSurfaceVariant,
          ),
          // ✅ FIX: Use kSpacingSmall instead of kBorderRadius
          const SizedBox(height: kSpacingSmall),
          Text(
            // ✅ FIX: Use AppStrings
            strings.emptyTitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: kSpacingMedium),

          // ✅ Tooltip לכפתור
          Tooltip(
            // ✅ FIX: Use AppStrings
            message: strings.createListTooltip,
            child: FilledButton.icon(
              onPressed: onCreateList,
              icon: const Icon(Icons.add),
              // ✅ FIX: Use AppStrings
              label: Text(strings.createListButton),
            ),
          ),
        ],
      ),
    );
  }
}

/// סיכום רשימה - פרטים עיקריים
class _ListSummary extends StatelessWidget {
  final ShoppingList list;

  const _ListSummary({required this.list});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final strings = AppStrings.upcomingShopCard;
    final itemsCount = list.items.length;

    // שימוש ב-helpers מהמודל (תומך בכל הסוגים)
    final typeLabel = '${list.typeEmoji} ${list.typeName}';
    final typeColor = list.stickyColor;
    // ✅ FIX: Softer tag background for dark mode compatibility
    final tagBgColor = Color.alphaBlend(
      typeColor.withValues(alpha: 0.85),
      cs.surface,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // שורת כותרת עם תג סוג
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // שם הרשימה
            Expanded(
              child: Text(
                list.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                // ✅ FIX: Overflow protection
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: kSpacingSmall),
            // תג סוג הרשימה
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: kSpacingSmall,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                // ✅ FIX: Softer background color
                color: tagBgColor,
                borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                boxShadow: [
                  BoxShadow(
                    // ✅ Theme-aware shadow
                    color: theme.shadowColor.withValues(alpha: 0.1),
                    blurRadius: 2,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: Text(
                typeLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  // ✅ FIX: Theme-aware text color for contrast
                  color: cs.onSurface,
                ),
                // ✅ FIX: Overflow protection
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: kSpacingMedium),

        // ספירת פריטים
        Text(
          // ✅ FIX: Use AppStrings
          strings.itemsCount(itemsCount),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: kSpacingMedium),

        // ✅ כפתור התחל קנייה עם Tooltip
        Tooltip(
          // ✅ FIX: Use AppStrings
          message: strings.startShoppingTooltip(list.name),
          child: FilledButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/active-shopping',
                arguments: list,
              );
            },
            icon: const Icon(Icons.shopping_cart),
            // ✅ FIX: Use AppStrings
            label: Text(strings.startShoppingButton),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
      ],
    );
  }
}
