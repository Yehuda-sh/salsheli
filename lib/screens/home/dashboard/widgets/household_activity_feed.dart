// lib/screens/home/dashboard/widgets/household_activity_feed.dart — Activity feed — recent household events with receipt fallback

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/ui_constants.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../models/activity_event.dart';
import '../../../../models/receipt.dart';
import '../../../../providers/activity_log_provider.dart';
import '../../../../providers/receipt_provider.dart';
import '../../../../providers/shopping_lists_provider.dart';
import '../../../../providers/user_context.dart';
import '../../../history/shopping_history_screen.dart';

// Avatar circle width matches the small button height (36) — keep using
// the existing token but name the intent locally.
const double _kAvatarSize = kButtonHeightSmall;
// Divider indent equals avatar width + leading gap so the line aligns
// under the text column.
const double _kDividerIndent = _kAvatarSize + kSpacingMedium;

// ---------------------------------------------------------------------------
// Top-level helpers — used by both activity tiles and receipt fallback.
// ---------------------------------------------------------------------------

/// Relative time label ("עכשיו", "לפני 5 דק׳", "אתמול"...).
String _formatRelativeDate(DateTime date) {
  final strings = AppStrings.homeDashboard;
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inMinutes < 1) return AppStrings.activityLog.justNow;
  if (diff.inMinutes < 60) return strings.minutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return strings.hoursAgo(diff.inHours);
  if (now.year == date.year && now.month == date.month && now.day == date.day) {
    return strings.today;
  }
  if (diff.inDays == 1) return strings.yesterday;
  if (diff.inDays < 7) return strings.daysAgo(diff.inDays);
  return '${date.day}/${date.month}';
}

IconData _iconForType(ActivityType type) {
  switch (type) {
    case ActivityType.shoppingCompleted:
      return Icons.check_circle;
    case ActivityType.shoppingStarted:
      return Icons.shopping_cart;
    case ActivityType.shoppingJoined:
      return Icons.group_add;
    case ActivityType.listCreated:
      return Icons.playlist_add;
    case ActivityType.itemAdded:
      return Icons.add_circle_outline;
    case ActivityType.stockUpdated:
      return Icons.inventory_2;
    case ActivityType.memberLeft:
      return Icons.person_remove;
    case ActivityType.roleChanged:
      return Icons.admin_panel_settings;
    case ActivityType.unknown:
      return Icons.info_outline;
  }
}

/// Avatar (background, foreground) pair per event type. Mirrors the mapping
/// used by the history screen so the same event looks the same across screens.
({Color bg, Color fg}) _avatarColorsForType(
  ActivityType type,
  ColorScheme cs, {
  required bool isMe,
}) {
  // "אתה" still gets a primary tint regardless of type — the highlight is
  // about ownership, not category.
  if (isMe) return (bg: cs.primaryContainer, fg: cs.onPrimaryContainer);

  switch (type) {
    case ActivityType.shoppingCompleted:
    case ActivityType.itemAdded:
      return (bg: cs.primaryContainer, fg: cs.onPrimaryContainer);
    case ActivityType.shoppingStarted:
    case ActivityType.shoppingJoined:
    case ActivityType.roleChanged:
      return (bg: cs.tertiaryContainer, fg: cs.onTertiaryContainer);
    case ActivityType.listCreated:
    case ActivityType.stockUpdated:
      return (bg: cs.secondaryContainer, fg: cs.onSecondaryContainer);
    case ActivityType.memberLeft:
      return (bg: cs.errorContainer, fg: cs.onErrorContainer);
    case ActivityType.unknown:
      return (bg: cs.surfaceContainerHighest, fg: cs.onSurfaceVariant);
  }
}

/// Description without the actor name — actor is rendered separately as the
/// tile header so we don't repeat "יהודה ... יהודה ...".
String _descriptionForEvent(ActivityEvent event, ActivityLogStrings strings) {
  switch (event.type) {
    case ActivityType.shoppingCompleted:
      return strings.feedShoppingCompleted(event.listName ?? '');
    case ActivityType.shoppingStarted:
      return strings.feedShoppingStarted(event.listName ?? '');
    case ActivityType.shoppingJoined:
      return strings.feedShoppingJoined(event.listName ?? '');
    case ActivityType.listCreated:
      return strings.feedListCreated(event.listName ?? '');
    case ActivityType.itemAdded:
      return strings.feedItemAdded(event.itemName ?? '', event.listName ?? '');
    case ActivityType.stockUpdated:
      return strings.feedStockUpdated(event.productName ?? '');
    case ActivityType.memberLeft:
      return strings.feedMemberLeft;
    case ActivityType.roleChanged:
      return strings.feedRoleChanged(event.targetName ?? '', event.newRole ?? '');
    case ActivityType.unknown:
      return strings.feedUnknownActivity;
  }
}

/// פיד פעילות הבית
class HouseholdActivityFeed extends StatelessWidget {
  /// Callback למעבר לטאב היסטוריה (במקום push חדש)
  final VoidCallback? onSeeAllHistory;

  /// האם להציג כפתור "ראה הכל" — false כשמוצג בתוך מסך היסטוריה
  final bool showSeeAll;

  const HouseholdActivityFeed({super.key, this.onSeeAllHistory, this.showSeeAll = true});

  @override
  Widget build(BuildContext context) {
    final activityProvider = context.watch<ActivityLogProvider>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    // מציג עד 5 אירועים אחרונים
    final events = activityProvider.events.take(5).toList();

    // Always watch ReceiptProvider (unconditional — required by Provider rules)
    final allReceipts = context.watch<ReceiptProvider>().receipts;

    // Fallback: אם אין אירועי activity_log, הצג קבלות אחרונות.
    // Sort returns a new list (sorted) only when the activity log is empty —
    // so the cost is paid once per build only on that branch.
    final fallbackReceipts = events.isEmpty && allReceipts.isNotEmpty
        ? (List<Receipt>.from(allReceipts)..sort((a, b) => b.date.compareTo(a.date))).take(3).toList()
        : const <Receipt>[];

    if (events.isEmpty && fallbackReceipts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        // כותרת וכפתור "ראה הכל"
        Row(
          children: [
            Image.asset(
              'assets/images/icon_home_activity.webp',
              width: kIconSizeLarge,
              height: kIconSizeLarge,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.history, size: kIconSizeLarge, color: cs.primary),
            ),
            const SizedBox(width: kSpacingSmall),
            Text(
              AppStrings.homeDashboard.activityFeedTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (showSeeAll)
              Semantics(
                button: true,
                label: AppStrings.homeDashboard.seeAll,
                child: TextButton(
                  onPressed: () {
                    unawaited(HapticFeedback.lightImpact());
                    if (onSeeAllHistory != null) {
                      onSeeAllHistory!();
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ShoppingHistoryScreen()),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.homeDashboard.seeAll,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: kSpacingXTiny / 2),
                      Icon(
                        isRtl ? Icons.chevron_left : Icons.chevron_right,
                        size: kIconSizeSmall,
                        color: cs.primary,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: kSpacingSmall),

        // כרטיסי פעילות
        Card(
          elevation: 0,
          color: cs.surface.withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
            side: BorderSide(color: cs.outlineVariant.withValues(alpha: kOpacityLight)),
          ),
          child: events.isNotEmpty
              ? _ActivityList(events: events)
              : _ReceiptList(receipts: fallbackReceipts),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Lists (events vs fallback receipts) — both render via the shared _FeedTile.
// ---------------------------------------------------------------------------

class _ActivityList extends StatelessWidget {
  final List<ActivityEvent> events;
  const _ActivityList({required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < events.length; i++) ...[
          _ActivityEventTile(event: events[i]),
          if (i < events.length - 1)
            const Divider(height: 1, indent: _kDividerIndent, endIndent: kSpacingMedium),
        ],
      ],
    );
  }
}

class _ReceiptList extends StatelessWidget {
  final List<Receipt> receipts;
  const _ReceiptList({required this.receipts});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < receipts.length; i++) ...[
          _ReceiptFallbackTile(receipt: receipts[i]),
          if (i < receipts.length - 1)
            const Divider(height: 1, indent: _kDividerIndent, endIndent: kSpacingMedium),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared tile — avatar (icon in a colored circle) + title + subtitle + tap.
// ---------------------------------------------------------------------------

class _FeedTile extends StatelessWidget {
  final IconData icon;
  final Color avatarBg;
  final Color avatarFg;
  final String title;
  final String time;
  final String subtitle;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  const _FeedTile({
    required this.icon,
    required this.avatarBg,
    required this.avatarFg,
    required this.title,
    required this.time,
    required this.subtitle,
    this.onTap,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kSpacingMedium,
        vertical: kSpacingSmallPlus,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: _kAvatarSize,
            height: _kAvatarSize,
            decoration: BoxDecoration(color: avatarBg, shape: BoxShape.circle),
            child: Center(
              child: Icon(icon, size: kIconSizeSmallPlus, color: avatarFg),
            ),
          ),
          const SizedBox(width: kSpacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: kSpacingTiny),
                    Text(
                      '• $time',
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: kSpacingXTiny),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onTap != null)
            Padding(
              padding: const EdgeInsets.only(top: kSpacingSmall),
              child: Icon(
                isRtl ? Icons.chevron_left : Icons.chevron_right,
                size: kIconSizeSmallPlus,
                color: cs.onSurfaceVariant.withValues(alpha: kOpacityLight),
              ),
            ),
        ],
      ),
    );

    final tappable = onTap == null
        ? row
        : InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(kBorderRadius),
            child: row,
          );

    return Semantics(
      button: onTap != null,
      label: semanticsLabel ?? '$title, $subtitle, $time',
      child: tappable,
    );
  }
}

// ============================================
// Activity Event Tile
// ============================================

class _ActivityEventTile extends StatelessWidget {
  final ActivityEvent event;
  const _ActivityEventTile({required this.event});

  /// Some event types carry a `list_id` we can navigate to. Others (member
  /// left, role changed, stock updated, unknown) have nowhere obvious to go
  /// from the dashboard.
  String? get _navigableListId {
    switch (event.type) {
      case ActivityType.shoppingCompleted:
      case ActivityType.shoppingStarted:
      case ActivityType.shoppingJoined:
      case ActivityType.listCreated:
      case ActivityType.itemAdded:
        return event.data['list_id'] as String?;
      case ActivityType.stockUpdated:
      case ActivityType.memberLeft:
      case ActivityType.roleChanged:
      case ActivityType.unknown:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currentUserId = context.read<UserContext>().userId;
    final isMe = event.actorId == currentUserId;
    final actor = isMe
        ? AppStrings.homeDashboard.youLabel
        : (event.actorName.isNotEmpty ? event.actorName : '?');
    final colors = _avatarColorsForType(event.type, cs, isMe: isMe);

    // Resolve the target list once — used both for the chevron decision
    // and the tap handler.
    final listId = _navigableListId;
    final targetList = listId != null
        ? context.read<ShoppingListsProvider>().getById(listId)
        : null;

    return _FeedTile(
      icon: _iconForType(event.type),
      avatarBg: colors.bg,
      avatarFg: colors.fg,
      title: actor,
      time: _formatRelativeDate(event.createdAt),
      subtitle: _descriptionForEvent(event, AppStrings.activityLog),
      onTap: targetList == null
          ? null
          : () {
              unawaited(HapticFeedback.lightImpact());
              Navigator.pushNamed(context, '/list-details', arguments: targetList);
            },
    );
  }
}

// ============================================
// Fallback: Receipt Tile (כשאין אירועי activity_log)
// ============================================

class _ReceiptFallbackTile extends StatelessWidget {
  final Receipt receipt;
  const _ReceiptFallbackTile({required this.receipt});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _FeedTile(
      icon: Icons.shopping_cart,
      avatarBg: cs.primaryContainer,
      avatarFg: cs.onPrimaryContainer,
      title: receipt.storeName,
      time: _formatRelativeDate(receipt.date),
      subtitle: AppStrings.homeDashboard.completedShoppingAt(receipt.storeName),
      onTap: () {
        unawaited(HapticFeedback.lightImpact());
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShoppingHistoryScreen(initialReceiptId: receipt.id),
          ),
        );
      },
    );
  }
}
