// 📄 lib/screens/home/dashboard/widgets/action_center_card.dart
//
// 🎯 Action Center — מציג פריטים שדורשים טיפול מהמשתמש.
// נעלם כשאין מה לטפל. כל פריט הוא actionable.
//
// 🔗 Related: ShoppingListsProvider, InventoryProvider, PendingInvitesService

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/ui_constants.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../models/shopping_list.dart';
import '../../../../providers/inventory_provider.dart';
import '../../../../providers/shopping_lists_provider.dart';
import '../../../../providers/user_context.dart';
import '../../../../theme/app_theme.dart';

/// Action Center — כרטיס "דורש טיפול" עם פריטים actionable
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

    final actionItems = <_ActionItem>[];

    // 1. בקשות ממתינות (pending requests) — רק ל-owner/admin
    for (final list in listsProvider.lists) {
      if (list.status != ShoppingList.statusActive) continue;
      if (!list.canCurrentUserApprove) continue;
      final pending = list.pendingRequests.where((r) => r.status.isPending).toList();
      if (pending.isEmpty) continue;
      actionItems.add(_ActionItem(
        icon: Icons.pending_actions,
        color: brand?.stickyOrange ?? kStickyOrange,
        title: AppStrings.actionCenter.pendingRequests(pending.length),
        subtitle: list.name,
        actionLabel: AppStrings.actionCenter.review,
        onAction: () {
          unawaited(HapticFeedback.lightImpact());
          onNavigateToList?.call(list);
        },
      ));
    }

    // 2. רשימות באיחור (overdue target_date)
    // ⚠️ target מגיע כ-UTC מ-Firestore — נרמול ל-local date-only
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final list in listsProvider.lists) {
      if (list.status != ShoppingList.statusActive) continue;
      final target = list.targetDate;
      if (target == null) continue;
      final targetLocal = target.toLocal();
      final targetDay = DateTime(targetLocal.year, targetLocal.month, targetLocal.day);
      if (!today.isAfter(targetDay)) continue;
      actionItems.add(_ActionItem(
        icon: Icons.schedule,
        color: cs.error,
        title: AppStrings.actionCenter.overdueList,
        subtitle: list.name,
        actionLabel: AppStrings.actionCenter.startShopping,
        onAction: () {
          unawaited(HapticFeedback.lightImpact());
          onNavigateToList?.call(list);
        },
      ));
    }

    // 3. מלאי קריטי (quantity = 0)
    final criticalItems = inventoryProvider.items.where((i) => i.quantity <= 0).toList();
    if (criticalItems.isNotEmpty) {
      final names = criticalItems.take(2).map((i) => i.productName).join(', ');
      final more = criticalItems.length > 2 ? ' +${criticalItems.length - 2}' : '';
      actionItems.add(_ActionItem(
        icon: Icons.warning_amber_rounded,
        color: brand?.stickyPink ?? kStickyPink,
        title: AppStrings.actionCenter.criticalStock(criticalItems.length),
        subtitle: '$names$more',
        actionLabel: AppStrings.actionCenter.goToPantry,
        onAction: () {
          unawaited(HapticFeedback.lightImpact());
          onNavigateToPantry?.call();
        },
      ));
    }

    // אם אין מה לטפל — לא מציגים כלום
    if (actionItems.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        // כותרת — עם רקע paper לקריאות על קווי מחברת
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: kSpacingSmallPlus, vertical: kSpacingXTiny),
            decoration: BoxDecoration(
              color: brand?.paperBackground.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications_active_outlined, size: kIconSizeSmallPlus, color: cs.onSurfaceVariant),
                const SizedBox(width: kSpacingSmall),
                Text(
                  AppStrings.actionCenter.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: kSpacingXTiny),
                Text(
                  '${actionItems.length}',
                  style: theme.textTheme.bodySmall?.copyWith(color: cs.outline),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: kSpacingSmall),

        // פריטי action
        ...actionItems.map((item) => _ActionTile(item: item)),
      ],
    );
  }
}

/// מודל פנימי לפריט action
class _ActionItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _ActionItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });
}

/// טייל בודד ב-Action Center
class _ActionTile extends StatelessWidget {
  final _ActionItem item;
  const _ActionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      color: cs.surface.withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
        side: BorderSide(color: item.color.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: item.onAction,
        borderRadius: BorderRadius.circular(kBorderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSpacingSmallPlus, vertical: kSpacingSmall),
          child: Row(
            children: [
              // אייקון בעיגול צבעוני
              Container(
                width: kIconSizeLarge,
                height: kIconSizeLarge,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.color, size: kIconSizeSmallPlus),
              ),
              const SizedBox(width: kSpacingSmallPlus),

              // טקסט
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: kFontSizeSmall,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: kFontSizeTiny,
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: kSpacingSmall),

              // כפתור פעולה
              Container(
                padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingXTiny),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                ),
                child: Text(
                  item.actionLabel,
                  style: TextStyle(
                    fontSize: kFontSizeTiny,
                    fontWeight: FontWeight.bold,
                    color: item.color,
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
