// 📄 File: lib/widgets/home/upcoming_shop_card.dart
//
// ✅ עדכונים:
// 1. שימוש ב-DashboardCard המשותף
// 2. עיצוב אחיד
// 3. אנימציות משופרות

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shopping_list.dart';
import '../../providers/shopping_lists_provider.dart';
import '../create_list_dialog.dart';
import '../common/dashboard_card.dart';

class UpcomingShopCard extends StatelessWidget {
  final ShoppingList? list;

  const UpcomingShopCard({super.key, this.list});

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

          if (name != null && name.trim().isNotEmpty) {
            await provider.createList(name: name, type: type, budget: budget);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (list == null) {
      return _EmptyUpcomingCard(
        onCreateList: () => _showCreateListDialog(context),
      );
    }

    return DashboardCard(
      title: "הקנייה הקרובה",
      icon: Icons.shopping_cart,
      onTap: () {
        Navigator.pushNamed(context, '/populate-list', arguments: list);
      },
      child: _ListSummary(list: list!),
    );
  }
}

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
      child: Column(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 48,
            color: cs.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            "אין רשימה פעילה כרגע",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
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

class _ListSummary extends StatelessWidget {
  final ShoppingList list;

  const _ListSummary({required this.list});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final itemsCount = list.items.length;
    final checkedCount = list.checkedCount;
    final progress = list.progress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // שם הרשימה
        Text(
          list.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // תג סוג + תקציב
        Row(
          children: [
            _buildTypeBadge(context, list.type),
            if (list.budget != null) ...[
              const SizedBox(width: 8),
              _buildBudgetChip(context, list.budget!),
            ],
          ],
        ),
        const SizedBox(height: 16),

        // התקדמות
        LinearProgressIndicator(
          value: progress,
          backgroundColor: cs.surfaceContainerHighest,
          color: cs.primary,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),

        // מידע נוסף
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$checkedCount מתוך $itemsCount פריטים",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            Text(
              "${(progress * 100).toInt()}%",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeBadge(BuildContext context, String type) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final typeLabels = {
      'super': 'סופר',
      'pharmacy': 'בית מרקחת',
      'hardware': 'חומרי בניין',
      'other': 'אחר',
    };

    final typeIcons = {
      'super': Icons.shopping_cart,
      'pharmacy': Icons.local_pharmacy,
      'hardware': Icons.hardware,
      'other': Icons.more_horiz,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            typeIcons[type] ?? Icons.list,
            size: 14,
            color: cs.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            typeLabels[type] ?? type,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetChip(BuildContext context, double budget) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 14,
            color: cs.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            '₪${budget.toStringAsFixed(0)}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
