// lib/screens/notifications/notifications_center_screen.dart — Notifications center — in-app notification list with mark-read, delete, pagination

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/status_colors.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/notification.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../providers/user_context.dart';
import '../../screens/shopping/details/shopping_list_details_screen.dart';
import '../../services/notifications_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_loading_skeleton.dart';
import '../../widgets/common/notebook_background.dart';

// Layout tokens local to this screen.
//
// _kLeadingIconSize / _kUnreadDotSize / _kEmptyImageSize: hardcoded
// dimensions extracted into named constants so future readers see the
// intent, not bare numbers.
const double _kLeadingIconSize = 44.0;
const double _kUnreadDotSize = 10.0;
const double _kEmptyImageSize = 120.0;

// Bottom list padding clears the floating action bar / system insets.
// Replaces `kSpacingXLarge + kSpacingLarge` — token-via-addition reads
// as a magic value mid-line (the CLAUDE.md anti-pattern).
const double _kListBottomClearance = 56.0;

// Per-tile entry stagger — multiplied by index for cascade effect.
const int _kStaggerStepMs = 40;

// Empty-state image pulse — 1.05× scale, slow breath. The asset is
// decorative ("nothing here yet"), so the gentle motion keeps the
// screen from feeling dead without distracting.
const Duration _kEmptyPulseDuration = Duration(milliseconds: 2000);
const double _kEmptyPulseScale = 1.05;

// Unread shimmer — one-shot 1.2s pass after a 3s delay. Previously this
// repeated forever, which meant N unread items meant N infinite
// animations running in parallel. The pass is now a single "look at me,
// new!" cue that fades into stillness.
const Duration _kShimmerDelay = Duration(milliseconds: 3000);
const Duration _kShimmerDuration = Duration(milliseconds: 1200);

// Undo window for swipe-to-delete — snackbar lasts 5s, the delete
// commits 1s after to leave a safety buffer.
const Duration _kUndoSnackBarDuration = Duration(seconds: 5);
const Duration _kUndoCommitDelay = Duration(seconds: 6);

class NotificationsCenterScreen extends StatefulWidget {
  const NotificationsCenterScreen({super.key});

  @override
  State<NotificationsCenterScreen> createState() => _NotificationsCenterScreenState();
}

class _NotificationsCenterScreenState extends State<NotificationsCenterScreen> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String? _error;

  // Pending swipe-to-delete commits, keyed by notification id. The undo
  // SnackBar runs for 5s; we commit after 6s unless the user taps Undo.
  // Holding refs lets us cancel on dispose — losing a "will-delete in 1s"
  // when the user navigates away is fine; ghost network calls aren't.
  final Map<String, Timer> _pendingDeleteTimers = {};

  @override
  void initState() {
    super.initState();
    // Initialize Hebrew locale for timeago
    timeago.setLocaleMessages('he', timeago.HeMessages());
    _loadNotifications();
  }

  @override
  void dispose() {
    for (final timer in _pendingDeleteTimers.values) {
      timer.cancel();
    }
    _pendingDeleteTimers.clear();
    super.dispose();
  }

  /// Initial load — flips `_isLoading` so the skeleton shows. Used only
  /// from `initState`; pull-to-refresh uses [_refreshNotifications]
  /// instead so the existing list stays on screen during refresh.
  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await _fetchNotifications();
  }

  /// Pull-to-refresh — same data path as [_loadNotifications] but never
  /// flips the skeleton. The user sees their existing list throughout
  /// the refresh, with the indicator's own spinner as feedback.
  Future<void> _refreshNotifications() => _fetchNotifications();

  /// Shared fetch + state update. Caller controls whether the skeleton
  /// is shown by flipping `_isLoading` before calling.
  Future<void> _fetchNotifications() async {
    final strings = AppStrings.notificationsCenter;

    try {
      final userContext = context.read<UserContext>();
      final userId = userContext.user?.id;

      if (userId == null) {
        if (!mounted) return;
        setState(() {
          _error = strings.userNotLoggedIn;
          _isLoading = false;
        });
        return;
      }

      final service = context.read<NotificationsService>();
      final result = await service.getUserNotificationsResult(userId: userId);

      if (!mounted) return;

      if (result.isSuccess) {
        setState(() {
          _notifications = result.notifications ?? [];
          _isLoading = false;
          _error = null;
        });
      } else {
        setState(() {
          _error = result.errorMessage ?? strings.loadingError;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = strings.loadingError;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(AppNotification notification) async {
    try {
      final userContext = context.read<UserContext>();
      final userId = userContext.user?.id;
      if (userId == null) return;

      final service = context.read<NotificationsService>();
      await service.markAsRead(userId: userId, notificationId: notification.id);

      // ✅ FIX: mounted guard after async
      if (!mounted) return;

      // Update local state
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = notification.copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
        }
      });
    } catch (e) {
      // Silent — non-critical operation
    }
  }

  Future<void> _markAllAsRead() async {
    final strings = AppStrings.notificationsCenter;
    final userContext = context.read<UserContext>();
    final userId = userContext.user?.id;
    if (userId == null) return;

    final service = context.read<NotificationsService>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      await service.markAllAsRead(userId: userId);

      // ✅ FIX: mounted guard after async
      if (!mounted) return;

      // Update local state
      setState(() {
        _notifications = _notifications.map((n) => n.copyWith(
          isRead: true,
          readAt: DateTime.now(),
        )).toList();
      });

      // ✅ FIX: unawaited for fire-and-forget
      unawaited(HapticFeedback.lightImpact());
      messenger.removeCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(strings.allMarkedAsRead),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Silent — non-critical operation
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final strings = AppStrings.notificationsCenter;

    final unreadCount = _notifications.where((n) => n.isUnread).length;

    // ✅ FIX: NotebookBackground + transparent Scaffold
    return Stack(
      children: [
        const NotebookBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: kGlassBlurSigma, sigmaY: kGlassBlurSigma),
                child: Container(
                  color: cs.surface.withValues(alpha: kOpacityStrong),
                ),
              ),
            ),
            title: Text(strings.title),
            centerTitle: true,
            actions: [
              if (unreadCount > 0)
                TextButton(
                  onPressed: _markAllAsRead,
                  child: Text(
                    strings.markAllAsRead,
                    style: TextStyle(color: cs.primary),
                  ),
                ),
            ],
          ),
          body: _buildBody(cs, theme),
        ),
      ],
    );
  }

  Widget _buildBody(ColorScheme cs, ThemeData theme) {
    final strings = AppStrings.notificationsCenter;
    final brand = theme.extension<AppBrand>();

    if (_isLoading) {
      return const AppLoadingSkeleton();
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(kSpacingLarge),
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusLarge)),
            child: Padding(
              padding: const EdgeInsets.all(kSpacingLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_outlined, size: kIconSizeXXLarge, color: cs.onSurfaceVariant.withValues(alpha: kOpacityMedium)),
                  const SizedBox(height: kSpacingMedium),
                  Text(_error!, style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant), textAlign: TextAlign.center),
                  const SizedBox(height: kSpacingMedium),
                  FilledButton.icon(
                    onPressed: _loadNotifications,
                    icon: const Icon(Icons.refresh),
                    label: Text(strings.retryButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().fadeIn(duration: 400.ms);
    }

    if (_notifications.isEmpty) {
      // Wrap empty state in RefreshIndicator + scrollable list so the
      // user can pull-to-refresh even when there's "nothing" — fixes
      // the gap where a user with 0 notifications had no way to check
      // for new ones short of leaving the screen.
      return RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // Vertical centering inside a sized box keeps the content
            // pinned mid-screen even though the parent is a scrollable
            // ListView (which has unbounded height by default).
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/images/empty_notifications.webp',
                        width: _kEmptyImageSize,
                        height: _kEmptyImageSize,
                        fit: BoxFit.cover,
                        // Fallback when the asset is missing/corrupt —
                        // sibling files use the same pattern, the muted
                        // icon reads better than a broken-image placeholder.
                        errorBuilder: (_, _, _) => Icon(
                          Icons.notifications_none_outlined,
                          size: _kEmptyImageSize,
                          color: cs.onSurfaceVariant.withValues(alpha: kOpacityMedium),
                        ),
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleXY(
                          begin: 1.0,
                          end: _kEmptyPulseScale,
                          duration: _kEmptyPulseDuration,
                          curve: Curves.easeInOut,
                        ),
                    const SizedBox(height: kSpacingMedium),
                    Text(
                      strings.emptyTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: kSpacingSmall),
                    Text(
                      strings.emptySubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: kOpacityStrong),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      child: ListView.separated(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(
          top: kSpacingSmall,
          left: kSpacingSmall,
          right: kSpacingSmall,
          bottom: _kListBottomClearance,
        ),
        itemCount: _notifications.length,
        // Always scrollable so pull-to-refresh works even with few items.
        physics: const AlwaysScrollableScrollPhysics(),
        separatorBuilder: (_, _) => const SizedBox(height: kSpacingSmall),
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return RepaintBoundary(
            child: Dismissible(
              key: ValueKey(notification.id),
              // Swipe from start → "mark as read" (green tint).
              background: Container(
                alignment: AlignmentDirectional.centerStart,
                padding: const EdgeInsetsDirectional.only(start: kIconSizeSmallPlus),
                color: (brand?.success ?? kStickyGreen).withValues(alpha: kOpacityLow),
                child: Icon(Icons.check, color: brand?.success ?? kStickyGreen),
              ),
              // Swipe from end → delete (red tint, 5s undo).
              secondaryBackground: Container(
                alignment: AlignmentDirectional.centerEnd,
                padding: const EdgeInsetsDirectional.only(end: kIconSizeSmallPlus),
                color: cs.error.withValues(alpha: kOpacityLow),
                child: Icon(Icons.delete_outline, color: cs.error),
              ),
              confirmDismiss: (direction) async {
                unawaited(HapticFeedback.lightImpact());
                if (direction == DismissDirection.startToEnd) {
                  // סמן כנקרא
                  unawaited(_markAsRead(notification));
                  unawaited(HapticFeedback.mediumImpact());
                  return false; // לא להסיר מהרשימה
                }
                // מחיקה — אישור
                unawaited(HapticFeedback.mediumImpact());
                return true;
              },
              onDismissed: (_) {
                // Remove from UI immediately so the swipe feels responsive.
                final removedIndex = _notifications.indexOf(notification);
                setState(() => _notifications.removeWhere((n) => n.id == notification.id));

                // Show undo snackbar (5s) before actually committing
                // the server-side delete.
                final messenger = ScaffoldMessenger.of(context);
                messenger.clearSnackBars();
                messenger.showSnackBar(SnackBar(
                  content: Text(AppStrings.common.deleted),
                  action: SnackBarAction(
                    label: AppStrings.common.undo,
                    onPressed: () {
                      // Cancel pending delete + restore to UI.
                      _pendingDeleteTimers.remove(notification.id)?.cancel();
                      setState(() {
                        if (removedIndex >= 0 && removedIndex <= _notifications.length) {
                          _notifications.insert(removedIndex, notification);
                        } else {
                          _notifications.add(notification);
                        }
                      });
                    },
                  ),
                  duration: _kUndoSnackBarDuration,
                ));

                // Cache providers before the async gap — using context
                // after dispose would crash. The Timer also lives in
                // _pendingDeleteTimers so dispose() can cancel it; that
                // prevents ghost API calls firing after the user has
                // navigated away.
                final cachedUserId = context.read<UserContext>().userId;
                final cachedNotifService = context.read<NotificationsService>();
                _pendingDeleteTimers[notification.id]?.cancel();
                _pendingDeleteTimers[notification.id] =
                    Timer(_kUndoCommitDelay, () {
                  _pendingDeleteTimers.remove(notification.id);
                  // Belt-and-braces: only delete if the notification is
                  // still removed (undo would have re-inserted it).
                  if (!_notifications.any((n) => n.id == notification.id)) {
                    if (cachedUserId != null) {
                      unawaited(cachedNotifService.deleteNotification(
                        notificationId: notification.id,
                        userId: cachedUserId,
                      ));
                    }
                  }
                });
              },
              child: _NotificationTile(
                notification: notification,
                onTap: () => _handleNotificationTap(notification),
                onMarkAsRead: () => _markAsRead(notification),
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: (_kStaggerStepMs * index).ms)
                .slideX(
                  begin: -0.1,
                  end: 0,
                  duration: 300.ms,
                  delay: (_kStaggerStepMs * index).ms,
                  curve: Curves.easeOut,
                ),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    // Mark as read
    if (notification.isUnread) {
      _markAsRead(notification);
    }

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.invite:
        Navigator.pushNamed(context, '/pending-invites');
        break;
      case NotificationType.requestApproved:
      case NotificationType.requestRejected:
        // Navigate to list if listId exists
        if (notification.listId != null && mounted) {
          final listsProvider = context.read<ShoppingListsProvider>();
          try {
            final list = listsProvider.lists.firstWhere(
              (l) => l.id == notification.listId,
            );
            if (mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ShoppingListDetailsScreen(list: list),
                ),
              );
            }
          } catch (_) {
            // רשימה לא נמצאה — אולי נמחקה
          }
        }
        break;
      default:
        // Just mark as read, no navigation
        break;
    }
  }
}

/// Individual notification tile
class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();

    final isUnread = notification.isUnread;
    final timeAgo = timeago.format(notification.createdAt, locale: 'he');

    Widget tile = Card(
      elevation: isUnread ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
        side: isUnread ? BorderSide(color: cs.primary.withValues(alpha: kOpacityLight)) : BorderSide.none,
      ),
      child: Container(
      decoration: BoxDecoration(
        color: isUnread
            ? cs.primaryContainer.withValues(alpha: kOpacitySoft)
            : null,
        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusLarge)),
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        onTap();
      },
      leading: Container(
        width: _kLeadingIconSize,
        height: _kLeadingIconSize,
        decoration: BoxDecoration(
          color: _getTypeColor(notification.type, cs, brand).withValues(alpha: kOpacitySoft),
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        child: Center(
          child: Text(
            notification.type.emoji,
            style: const TextStyle(fontSize: kFontSizeTitle),
          ),
        ),
      ),
      title: Text(
        notification.title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: kSpacingXTiny),
          Text(
            timeAgo,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant.withValues(alpha: kOpacityStrong),
            ),
          ),
        ],
      ),
      trailing: isUnread
          ? Container(
              width: _kUnreadDotSize,
              height: _kUnreadDotSize,
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
              ),
            )
          : null,
      ),
      ),
    );

    // One-shot shimmer for unread items: previously this looped forever
    // (`onPlay: c.repeat(...)`), so a screen with N unread notifications
    // ran N infinite animations in parallel — visually exhausting and a
    // controller leak waiting to happen. The single pass after a 3s
    // delay still says "new!" without staying loud.
    if (isUnread) {
      tile = tile.animate().shimmer(
            delay: _kShimmerDelay,
            duration: _kShimmerDuration,
            color: cs.primary.withValues(alpha: kOpacitySubtle),
          );
    }

    return tile;
  }

  /// ✅ FIX: Theme-aware colors via model's statusType
  Color _getTypeColor(NotificationType type, ColorScheme cs, AppBrand? brand) {
    // invite gets primary (distinct from status-based colors)
    if (type == NotificationType.invite) return cs.primary;

    // All other types — derive color from semantic statusType
    return switch (type.statusType) {
      StatusType.error   => cs.error,
      StatusType.warning => brand?.warning ?? kStickyOrange,
      StatusType.success => brand?.success ?? kStickyGreen,
      StatusType.info    => cs.secondary,
      StatusType.pending => cs.outline,
    };
  }
}
