// 📄 File: lib/widgets/home/upcoming_shop_card.dart
// ✅ עדכון (26/10/2025) - Simplified UI:
// - הסרת animations מורכבות
// - פישוט card ל-basics: שם + ספירה + כפתור

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shopping_list.dart';
import '../../providers/shopping_lists_provider.dart';
import '../create_list_dialog.dart';
import '../common/dashboard_card.dart';
import '../../core/ui_constants.dart';

class UpcomingShopCard extends StatelessWidget {
  final ShoppingList? list;

  const UpcomingShopCard({super.key, this.list});

  /// הצגת דיאלוג ליצירת רשימה קניות חדשה
  void _showCreateListDialog(BuildContext context) {
    final provider = context.read<ShoppingListsProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) => CreateListDialog(
        onCreateList: (listData) async {
          Navigator.of(dialogContext).pop();

          final name = listData['name'] as String?;
          final type = listData['type'] as String? ?? 'super';
          final budget = listData['budget'] as double?;
          final eventDate = listData['eventDate'] as DateTime?;

          if (name != null && name.trim().isNotEmpty) {
            await provider.createList(
              name: name,
              type: type,
              budget: budget,
              eventDate: eventDate,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return list == null
        ? _EmptyUpcomingCard(
            onCreateList: () => _showCreateListDialog(context),
          )
        : DashboardCard(
            title: "הקנייה הקרובה",
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
      title: "הקנייה הקרובה",
      icon: Icons.shopping_cart_outlined,
      color: kStickyCyan,
      rotation: -0.01,
      child: Column(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 48,
            color: cs.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: kBorderRadius),
          Text(
            "אין רשימה פעילה כרגע",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: kSpacingMedium),
          
          FilledButton.icon(
            onPressed: onCreateList,
            icon: const Icon(Icons.add),
            label: const Text("צור רשימה חדשה"),
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

  /// 🏷️ מקבל את התג והצבע לסוג הרשימה
  (String label, Color color) _getTypeTagInfo() {
    switch (list.type) {
      case ShoppingList.typeSuper:
        return ('🛒 סופרמרקט', kStickyGreen);
      case ShoppingList.typePharmacy:
        return ('💊 בית מרקחת', kStickyCyan);
      case ShoppingList.typeOther:
      default:
        return ('📋 כללי', kStickyPurple);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final itemsCount = list.items.length;
    final (typeLabel, typeColor) = _getTypeTagInfo();

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
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: kSpacingMedium),

        // ספירת פריטים
        Text(
          "$itemsCount פריטים",
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
