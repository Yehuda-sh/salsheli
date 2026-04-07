// 📄 lib/screens/home/dashboard/widgets/household_activity_feed.dart
//
// פיד פעילות הבית — מציג פעולות אחרונות של חברי הבית
// מבוסס על ActivityLogProvider (יומן פעילות מלא).
//
// Version: 2.0 (07/04/2026) — ActivityLogProvider במקום receipts בלבד

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/ui_constants.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../models/activity_event.dart';
import '../../../../providers/activity_log_provider.dart';
import '../../../../providers/user_context.dart';
import '../../../history/shopping_history_screen.dart';

/// פיד פעילות הבית
class HouseholdActivityFeed extends StatelessWidget {
  /// Callback למעבר לטאב היסטוריה (במקום push חדש)
  final VoidCallback? onSeeAllHistory;

  const HouseholdActivityFeed({super.key, this.onSeeAllHistory});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActivityLogProvider>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    // מציג עד 5 אירועים אחרונים
    final events = provider.events.take(5).toList();

    if (events.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        // כותרת וכפתור "ראה הכל"
        Row(
          children: [
            Image.asset('assets/images/icon_home_activity.webp', width: kIconSizeLarge, height: kIconSizeLarge),
            const SizedBox(width: kSpacingSmall),
            Text(AppStrings.homeDashboard.activityFeedTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton(
              onPressed: () {
                unawaited(HapticFeedback.lightImpact());
                if (onSeeAllHistory != null) {
                  onSeeAllHistory!();
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ShoppingHistoryScreen()));
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
                    style: theme.textTheme.bodySmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 2),
                  Icon(isRtl ? Icons.chevron_left : Icons.chevron_right, size: kIconSizeSmall, color: cs.primary),
                ],
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
            side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < events.length; i++) ...[
                _ActivityEventTile(event: events[i]),
                if (i < events.length - 1) const Divider(height: 1, indent: 64, endIndent: kSpacingMedium),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================
// Activity Event Tile (Dashboard)
// ============================================

class _ActivityEventTile extends StatelessWidget {
  final ActivityEvent event;

  const _ActivityEventTile({required this.event});

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

  String _descriptionForEvent(ActivityLogStrings strings) {
    final actor = event.actorName.isNotEmpty ? event.actorName : '?';
    switch (event.type) {
      case ActivityType.shoppingCompleted:
        return strings.shoppingCompleted(actor, event.listName ?? '');
      case ActivityType.shoppingStarted:
        return strings.shoppingStarted(actor, event.listName ?? '');
      case ActivityType.shoppingJoined:
        return strings.shoppingJoined(actor, event.listName ?? '');
      case ActivityType.listCreated:
        return strings.listCreated(actor, event.listName ?? '');
      case ActivityType.itemAdded:
        return strings.itemAdded(actor, event.itemName ?? '', event.listName ?? '');
      case ActivityType.stockUpdated:
        return strings.stockUpdated(actor, event.productName ?? '');
      case ActivityType.memberLeft:
        return strings.memberLeft(actor);
      case ActivityType.roleChanged:
        return strings.roleChanged(actor, event.targetName ?? '', event.newRole ?? '');
      case ActivityType.unknown:
        return strings.unknownActivity(actor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currentUserId = context.read<UserContext>().userId;
    final isMe = event.actorId == currentUserId;
    final strings = AppStrings.activityLog;
    final locale = Localizations.localeOf(context).languageCode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmallPlus),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // אווטר
          Container(
            width: kButtonHeightSmall,
            height: kButtonHeightSmall,
            decoration: BoxDecoration(
              color: isMe ? cs.primaryContainer : cs.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                _iconForType(event.type),
                size: kIconSizeSmallPlus,
                color: isMe ? cs.onPrimaryContainer : cs.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(width: kSpacingMedium),

          // תוכן
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // שורה 1: שם + זמן
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        isMe ? AppStrings.homeDashboard.youLabel : event.actorName,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• ${_formatRelativeDate(event.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // שורה 2: תיאור הפעולה
                Text(
                  _descriptionForEvent(strings),
                  style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant.withValues(alpha: 0.9)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    final strings = AppStrings.homeDashboard;
    if (diff.inMinutes < 60) return strings.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return strings.hoursAgo(diff.inHours);
    if (now.year == date.year && now.month == date.month && now.day == date.day) {
      return strings.today;
    }
    if (diff.inDays == 1) return strings.yesterday;
    if (diff.inDays < 7) return strings.daysAgo(diff.inDays);
    return '${date.day}/${date.month}';
  }
}
