// 📄 lib/screens/notifications/notifications_center_screen.dart
//
// מרכז ההתראות - מציג את כל ההתראות של המשתמש:
// - הזמנות לרשימות/קבוצות
// - אישורים ודחיות
// - שינויי תפקיד
// - התראות מלאי
// ✨ v4.0: אנימציות כניסה מדורגות (Staggered Entrance), מחוות Swipe-to-Action,
//          AppBar בעיצוב Glassmorphic, משוב Haptic מורחב
//
// Version: 4.0 (22/02/2026)
// 🔗 Related: NotificationsService, AppNotification

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/notification.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../providers/user_context.dart';
import '../../screens/shopping/details/shopping_list_details_screen.dart';
import '../../services/notifications_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/notebook_background.dart';

class NotificationsCenterScreen extends StatefulWidget {
  const NotificationsCenterScreen({super.key});

  @override
  State<NotificationsCenterScreen> createState() => _NotificationsCenterScreenState();
}

class _NotificationsCenterScreenState extends State<NotificationsCenterScreen> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Initialize Hebrew locale for timeago
    timeago.setLocaleMessages('he', timeago.HeMessages());
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final strings = AppStrings.notificationsCenter;

    setState(() {
      _isLoading = true;
      _error = null;
    });

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

      // ✅ FIX: mounted guard after async
      if (!mounted) return;

      if (result.isSuccess) {
        setState(() {
          _notifications = result.notifications ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result.errorMessage ?? strings.loadingError;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
      }
      // ✅ FIX: mounted guard after async
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
      if (kDebugMode) {
      }
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
      messenger.showSnackBar(
        SnackBar(
          content: Text(strings.allMarkedAsRead),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
      }
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
        NotebookBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: kGlassBlurSigma, sigmaY: kGlassBlurSigma),
                child: Container(
                  color: cs.surface.withValues(alpha: 0.7),
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
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: cs.error),
            const SizedBox(height: 16),
            Text(_error!, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh),
              label: Text(strings.retryButton),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(
                  begin: 1.0,
                  end: 1.08,
                  duration: 2000.ms,
                  curve: Curves.easeInOut,
                ),
            SizedBox(height: 16),
            Text(
              strings.emptyTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 8),
            Text(
              strings.emptySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: kSpacingSmall),
        itemCount: _notifications.length,
        // ✅ FIX: Always scrollable for pull-to-refresh with few items
        physics: const AlwaysScrollableScrollPhysics(),
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return RepaintBoundary(
            child: Dismissible(
              key: ValueKey(notification.id),
              // סווייפ ימינה (RTL) → סמן כנקרא
              background: Container(
                alignment: AlignmentDirectional.centerStart,
                padding: const EdgeInsetsDirectional.only(start: 20),
                color: (brand?.success ?? kStickyGreen).withValues(alpha: 0.2),
                child: Icon(Icons.check, color: brand?.success ?? kStickyGreen),
              ),
              // סווייפ שמאלה → מחיקה
              secondaryBackground: Container(
                alignment: AlignmentDirectional.centerEnd,
                padding: const EdgeInsetsDirectional.only(end: 20),
                color: cs.error.withValues(alpha: 0.2),
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
                setState(() => _notifications.removeAt(index));
              },
              child: _NotificationTile(
                notification: notification,
                onTap: () => _handleNotificationTap(notification),
                onMarkAsRead: () => _markAsRead(notification),
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: (40 * index).ms)
                .slideX(
                  begin: -0.1,
                  end: 0,
                  duration: 300.ms,
                  delay: (40 * index).ms,
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

    Widget tile = Container(
      decoration: BoxDecoration(
        color: isUnread
            ? cs.primaryContainer.withValues(alpha: 0.25)
            : null,
        border: isUnread
            ? BorderDirectional(
                start: BorderSide(
                  color: cs.primary,
                  width: 3,
                ),
              )
            : null,
      ),
      child: ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _getTypeColor(notification.type, cs, brand).withValues(alpha: 0.15),
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
          SizedBox(height: 4),
          Text(
            timeAgo,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
      trailing: isUnread
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
              ),
            )
          : null,
      ),
    );

    // ✨ v4.0: shimmer עדין להתראות שלא נקראו
    if (isUnread) {
      tile = tile
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(
            delay: 3000.ms,
            duration: 1200.ms,
            color: cs.primary.withValues(alpha: 0.08),
          );
    }

    return tile;
  }

  /// ✅ FIX: Theme-aware colors from AppBrand
  Color _getTypeColor(NotificationType type, ColorScheme cs, AppBrand? brand) {
    switch (type) {
      case NotificationType.invite:
        return cs.primary;
      case NotificationType.requestApproved:
        return brand?.success ?? kStickyGreen;
      case NotificationType.requestRejected:
      case NotificationType.userRemoved:
        return cs.error;
      case NotificationType.roleChanged:
        return brand?.warning ?? kStickyOrange;
      case NotificationType.lowStock:
        return brand?.accent ?? kStickyYellow;
      default:
        return cs.secondary;
    }
  }
}
