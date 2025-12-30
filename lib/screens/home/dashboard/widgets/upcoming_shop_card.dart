// 📄 lib/screens/home/dashboard/widgets/upcoming_shop_card.dart
//
// כרטיס "הקנייה הקרובה" בדשבורד - מציג רשימה פעילה או מצב ריק.
// כולל שם רשימה, תג סוג, ספירת פריטים וכפתור "התחל קנייה".
//
// 🔗 Related: DashboardCard, ShoppingList

import 'package:flutter/material.dart';

import '../../../../core/ui_constants.dart';
import '../../../../models/shopping_list.dart';
import '../../../../widgets/common/dashboard_card.dart';

class UpcomingShopCard extends StatelessWidget {
  final ShoppingList? list;

  const UpcomingShopCard({super.key, this.list});

  @override
  Widget build(BuildContext context) {
    return list == null
        ? _EmptyUpcomingCard(
            onCreateList: () => Navigator.pushNamed(context, '/create-list'),
          )
        : DashboardCard(
            title: 'הקנייה הקרובה',
            icon: Icons.shopping_cart,
            color: kStickyPink,
            rotation: 0.015,
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

    return DashboardCard(
      title: 'הקנייה הקרובה',
      icon: Icons.shopping_cart_outlined,
      color: kStickyCyan,
      rotation: -0.01,
      child: Column(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 48,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(height: kBorderRadius),
          Text(
            'אין רשימה פעילה כרגע',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: kSpacingMedium),
          
          FilledButton.icon(
            onPressed: onCreateList,
            icon: const Icon(Icons.add),
            label: const Text('צור רשימה חדשה'),
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
    final itemsCount = list.items.length;

    // שימוש ב-helpers מהמודל (תומך בכל הסוגים)
    final typeLabel = '${list.typeEmoji} ${list.typeName}';
    final typeColor = list.stickyColor;

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
                color: typeColor,
                borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 2,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: Text(
                typeLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: kSpacingMedium),

        // ספירת פריטים
        Text(
          '$itemsCount פריטים',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: kSpacingMedium),

        // כפתור התחל קנייה
        FilledButton.icon(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/active-shopping',
              arguments: list,
            );
          },
          icon: const Icon(Icons.shopping_cart),
          label: const Text('התחל קנייה'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }
}
