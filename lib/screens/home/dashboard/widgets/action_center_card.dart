// lib/screens/home/dashboard/widgets/action_center_card.dart — Action center — compact status chips for pending requests, overdue lists, critical stock

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/ui_constants.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../models/inventory_item.dart';
import '../../../../models/shopping_list.dart';
import '../../../../providers/inventory_provider.dart';
import '../../../../providers/shopping_lists_provider.dart';
import '../../../../providers/user_context.dart';
import '../../../../theme/app_theme.dart';
import '../../../pantry/my_pantry_screen.dart' show MyPantryScreen, PantryStockFilter;

/// Action Center — קומפקטי: שורת chips של "דורש טיפול"
///
/// Each chip is one category of pending state (pending requests,
/// overdue lists, items out of stock). Tapping a chip opens a bottom
/// sheet with the full breakdown OR — for the out-of-stock chip —
/// switches to the pantry tab with the matching filter pre-applied.
class ActionCenterCard extends StatelessWidget {
  final void Function(ShoppingList list)? onNavigateToList;
  final VoidCallback? onNavigateToPantry;

  const ActionCenterCard({
    super.key,
    this.onNavigateToList,
    this.onNavigateToPantry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final userContext = context.watch<UserContext>();
    final listsProvider = context.watch<ShoppingListsProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();

    if (!userContext.isLoggedIn) return const SizedBox.shrink();

    // Single pass over the lists to bucket pending vs overdue.
    final pendingLists = <ShoppingList>[];
    final overdueLists = <ShoppingList>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final list in listsProvider.lists) {
      if (list.status != ShoppingList.statusActive) continue;

      if (list.canCurrentUserApprove &&
          list.pendingRequests.any((r) => r.status.isPending)) {
        pendingLists.add(list);
      }

      final target = list.targetDate;
      if (target != null) {
        final tLocal = target.toLocal();
        final tDay = DateTime(tLocal.year, tLocal.month, tLocal.day);
        if (today.isAfter(tDay)) overdueLists.add(list);
      }
    }

    final criticalItems = inventoryProvider.items
        .where((i) => i.quantity <= 0)
        .toList();

    final pendingCount = _countPendingRequests(pendingLists);

    // Hide the whole bar when there's nothing to action.
    if (pendingCount == 0 && overdueLists.isEmpty && criticalItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final strings = AppStrings.actionCenter;

    return Padding(
      padding: const EdgeInsets.only(bottom: kSpacingSmall),
      child: Row(
        children: [
          if (criticalItems.isNotEmpty) ...[
            Expanded(
              child: _StatusChip(
                icon: Icons.warning_amber_rounded,
                color: brand?.stickyPink ?? kStickyPink,
                count: criticalItems.length,
                label: strings.criticalStock(criticalItems.length),
                onTap: () => _openCriticalStock(context, criticalItems),
              ),
            ),
            const SizedBox(width: kSpacingSmall),
          ],
          if (overdueLists.isNotEmpty) ...[
            Expanded(
              child: _StatusChip(
                icon: Icons.schedule,
                color: cs.error,
                count: overdueLists.length,
                label: overdueLists.length == 1
                    ? strings.overdueList
                    : strings.overdueListsCount(overdueLists.length),
                onTap: () => _openOverdueLists(context, overdueLists),
              ),
            ),
            const SizedBox(width: kSpacingSmall),
          ],
          if (pendingCount > 0)
            Expanded(
              child: _StatusChip(
                icon: Icons.pending_actions,
                color: brand?.stickyOrange ?? kStickyOrange,
                count: pendingCount,
                label: strings.pendingRequests(pendingCount),
                onTap: () => _openPendingRequests(context, pendingLists),
              ),
            ),
        ],
      ),
    );
  }

  int _countPendingRequests(List<ShoppingList> lists) {
    var total = 0;
    for (final list in lists) {
      total += list.pendingRequests.where((r) => r.status.isPending).length;
    }
    return total;
  }

  /// Out-of-stock chip → switch to the pantry tab with the matching
  /// filter pre-applied. The pantry consumes the static intent on its
  /// next build, so order matters: set the filter, THEN switch tabs.
  void _openCriticalStock(BuildContext context, List<InventoryItem> items) {
    unawaited(HapticFeedback.lightImpact());
    MyPantryScreen.pendingStockFilter = PantryStockFilter.outOfStock;
    onNavigateToPantry?.call();
  }

  void _openOverdueLists(BuildContext context, List<ShoppingList> lists) {
    unawaited(HapticFeedback.lightImpact());
    if (lists.length == 1) {
      onNavigateToList?.call(lists.first);
      return;
    }
    _showListsSheet(
      context: context,
      title: AppStrings.actionCenter.overdueListsCount(lists.length),
      icon: Icons.schedule,
      lists: lists,
    );
  }

  void _openPendingRequests(
    BuildContext context,
    List<ShoppingList> lists,
  ) {
    unawaited(HapticFeedback.lightImpact());
    if (lists.length == 1) {
      onNavigateToList?.call(lists.first);
      return;
    }
    _showListsSheet(
      context: context,
      title: AppStrings.actionCenter.pendingRequests(lists.length),
      icon: Icons.pending_actions,
      lists: lists,
    );
  }

  void _showListsSheet({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<ShoppingList> lists,
  }) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kBorderRadiusLarge)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: kSpacingSmall),
              // Drag handle
              Container(
                width: kSpacingXLarge,
                height: kSpacingXTiny,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                ),
              ),
              const SizedBox(height: kSpacingMedium),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                child: Row(
                  children: [
                    Icon(icon, color: cs.primary, size: kIconSizeMedium),
                    const SizedBox(width: kSpacingSmall),
                    Text(
                      title,
                      style: Theme.of(sheetCtx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: kSpacingSmall),
              ...lists.map((list) => ListTile(
                    leading: Icon(Icons.shopping_bag_outlined, color: cs.primary),
                    title: Text(list.name),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      onNavigateToList?.call(list);
                    },
                  )),
              const SizedBox(height: kSpacingSmall),
            ],
          ),
        );
      },
    );
  }
}

/// Compact one-line chip — icon + count + short label, all tappable.
class _StatusChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int count;
  final String label;
  final VoidCallback onTap;

  const _StatusChip({
    required this.icon,
    required this.color,
    required this.count,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: '$label, $count',
      child: Material(
        color: color.withValues(alpha: kOpacitySubtle),
        borderRadius: BorderRadius.circular(kBorderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(kBorderRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: kSpacingSmallPlus,
              vertical: kSpacingSmall,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: kIconSizeSmallPlus),
                const SizedBox(width: kSpacingSmall),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: kFontSizeMedium,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: kSpacingXTiny),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: kFontSizeTiny,
                      color: cs.onSurface,
                      fontWeight: FontWeight.w500,
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
}
