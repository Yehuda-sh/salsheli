// 📄 File: lib/layout/app_layout.dart
//
// פריסה ראשית של האפליקציה - AppBar, Drawer, BottomNavigation.
// תומך RTL ומכיל אנימציות מיקרו לחוויית משתמש חלקה.
//
// Version: 3.3
// Updated: 02/11/2025

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/ui_constants.dart';
import '../l10n/app_strings.dart';
import '../providers/pending_invites_provider.dart';
import '../providers/user_context.dart';
import '../widgets/common/sticky_note.dart';

class AppLayout extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onTabSelected;
  final Map<int, int?>? badges; // optional badges per tab

  const AppLayout({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onTabSelected,
    this.badges,
  });

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  // 🎯 Cache totalBadgeCount for Performance
  int _cachedTotalBadgeCount = 0;

  @override
  void initState() {
    super.initState();
    _updateBadgeCache();
    if (kDebugMode) {
      debugPrint('📱 AppLayout.initState: currentIndex=${widget.currentIndex}, badges=${widget.badges}');
    }
  }

  @override
  void didUpdateWidget(AppLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.badges != oldWidget.badges) {
      _updateBadgeCache();
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      debugPrint('🗑️ AppLayout.dispose');
    }
    super.dispose();
  }

  /// 🎯 Updates cached badge count (Performance Optimization)
  void _updateBadgeCache() {
    _cachedTotalBadgeCount = _calculateTotalBadgeCount();
  }

  /// 🎯 Calculate total badge count (O(n))
  int _calculateTotalBadgeCount() {
    if (widget.badges == null) return 0;
    return widget.badges!.values
        .whereType<int>()
        .fold(0, (sum, count) => sum + count);
  }

  /// 🎯 Get cached total badge count (O(1))
  int get totalBadgeCount => _cachedTotalBadgeCount;

  /// 🚪 Logout function with UserContext Provider
  /// 
  /// ✅ New in v3.0:
  /// - Uses UserContext Provider (not SharedPreferences directly!)
  /// - Clears Firebase Auth (not just local storage)
  /// - Error handling with try-catch
  /// - Context safety after async
  /// - User feedback with SnackBar
  Future<void> _logout(BuildContext context) async {
    if (kDebugMode) {
      debugPrint('🚪 AppLayout.logout: התחלת התנתקות');
    }

    // 💾 Save context before async (Context Safety)
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      // 📨 ניקוי הזמנות ממתינות (לפני logout)
      context.read<PendingInvitesProvider>().clear();

      // 🔐 Logout via UserContext Provider
      // ✅ זה מנקה גם Firebase Auth וגם SharedPreferences!
      await context.read<UserContext>().logout();
      if (kDebugMode) {
        debugPrint('   ✅ UserContext.logout() הושלם בהצלחה');
      }

      // ✅ Context safety check
      if (!mounted) return;

      // 🏠 Navigate to login (Clear stack)
      await navigator.pushNamedAndRemoveUntil('/login', (r) => false);
      if (kDebugMode) {
        debugPrint('   ✅ ניווט ל-/login');
      }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('   ❌ AppLayout.logout: שגיאה - $e');
      }

      // 🚨 Show error to user
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: kSpacingSmall),
              Expanded(
                child: Text(
                  'שגיאה בהתנתקות, נסה שוב',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          duration: kSnackBarDurationLong,
          action: SnackBarAction(
            label: 'נסה שוב',
            textColor: Colors.white,
            onPressed: () => _logout(context),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final safeIndex = widget.currentIndex.clamp(0, _navItems.length - 1);

    // 🌍 RTL Support: Wrap with Directionality
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: _buildAppBar(context, cs),
        drawer: _buildDrawer(context, cs, safeIndex),
        body: widget.child,
        bottomNavigationBar: _buildBottomNav(context, cs, safeIndex),
      ),
    );
  }

  /// 🎨 Build AppBar
  PreferredSizeWidget _buildAppBar(BuildContext context, ColorScheme cs) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: cs.surfaceContainer,
      foregroundColor: cs.onSurface,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, color: cs.primary),
          const SizedBox(width: kSpacingSmall),
          Text(
            AppStrings.layout.appTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        // 🔔 Notifications Button
        _AnimatedIconButton(
          tooltip: AppStrings.layout.notifications,
          icon: Badge.count(
            count: totalBadgeCount,
            isLabelVisible: totalBadgeCount > 0,
            child: const Icon(Icons.notifications_outlined),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  totalBadgeCount > 0
                      ? AppStrings.layout.notificationsCount(totalBadgeCount)
                      : AppStrings.layout.noNotifications,
                ),
              ),
            );
          },
        ),
        // 🚪 Logout Button with Animation
        _AnimatedIconButton(
          tooltip: AppStrings.common.logout,
          icon: const Icon(Icons.logout),
          color: cs.error,
          onPressed: () => _logout(context),
        ),
      ],
    );
  }

  /// 🗂️ Build Drawer
  Widget _buildDrawer(BuildContext context, ColorScheme cs, int safeIndex) {
    return Drawer(
      backgroundColor: cs.surfaceContainerHighest,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(context, cs),
            ..._navItems.asMap().entries.map(
              (e) => _DrawerItem(
                icon: e.value.icon,
                label: e.value.label,
                selected: safeIndex == e.key,
                badgeCount: widget.badges?[e.key],
                onTap: () {
                  if (kDebugMode) {
                    debugPrint('🔄 AppLayout.tabSelected: ${e.key} (${e.value.label})');
                  }
                  Navigator.pop(context);
                  widget.onTabSelected(e.key);
                },
              ),
            ),
            const Divider(),
            _DrawerItem(
              icon: Icons.logout,
              label: AppStrings.common.logoutAction,
              selected: false,
              color: cs.error,
              onTap: () {
                Navigator.pop(context);
                _logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 👤 Build Drawer Header - סגנון StickyNote
  Widget _buildDrawerHeader(BuildContext context, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(kSpacingMedium),
      child: StickyNote(
        color: kStickyYellow,
        rotation: -0.01,
        child: Row(
          children: [
            // אווטאר
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  size: 32,
                  color: cs.primary,
                ),
              ),
            ),
            const SizedBox(width: kSpacingSmall),
            // טקסט
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.layout.hello,
                    style: const TextStyle(
                      fontSize: kFontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: kSpacingXTiny),
                  Text(
                    totalBadgeCount > 0
                        ? AppStrings.layout.welcomeWithUpdates(totalBadgeCount)
                        : AppStrings.layout.welcome,
                    style: const TextStyle(
                      fontSize: kFontSizeBody,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📱 Build Bottom Navigation Bar
  Widget _buildBottomNav(BuildContext context, ColorScheme cs, int safeIndex) {
    return NavigationBar(
      selectedIndex: safeIndex,
      onDestinationSelected: widget.onTabSelected,
      backgroundColor: cs.surfaceContainer,
      indicatorColor: cs.primary.withValues(alpha: 0.12),
      destinations: _navItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final badgeCount = widget.badges?[index];

        Widget icon = Icon(item.icon);
        Widget selectedIcon = Icon(item.icon, color: cs.primary);

        if (badgeCount != null && badgeCount > 0) {
          icon = _buildAnimatedBadge(icon, badgeCount, cs);
          selectedIcon = _buildAnimatedBadge(selectedIcon, badgeCount, cs);
        }

        return NavigationDestination(
          icon: icon,
          selectedIcon: selectedIcon,
          label: item.label,
        );
      }).toList(),
    );
  }

  /// 🎯 Build Animated Badge (Counter Animation)
  Widget _buildAnimatedBadge(Widget icon, int count, ColorScheme cs) {
    return Badge(
      backgroundColor: cs.error,
      textColor: cs.onError,
      label: _AnimatedBadgeCount(count: count),
      child: icon,
    );
  }
}

// === Animated Widgets ===

/// 🎨 Animated Icon Button (Scale Effect on Press)
/// 
/// מה זה עושה:
/// - כשלוחצים → Scale ל-0.95 (150ms)
/// - כששוחררים → חוזר ל-1.0 (150ms)
/// - נותן תחושה של "לחיצה" אמיתית!
/// 
/// New in v3.0 - Modern UI Pattern
class _AnimatedIconButton extends StatefulWidget {
  final String tooltip;
  final Widget icon;
  final VoidCallback onPressed;
  final Color? color;

  const _AnimatedIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: widget.tooltip,
      icon: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: widget.icon,
      ),
      color: widget.color,
      onPressed: () {
        // Animate press
        setState(() => _isPressed = true);
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() => _isPressed = false);
            widget.onPressed();
          }
        });
      },
    );
  }
}

/// 🎯 Animated Badge Count (Counter Animation)
/// 
/// מה זה עושה:
/// - כשהמספר משתנה → סופר מ-0 לערך החדש (800ms)
/// - Curve: easeOut (התחלה מהירה, סיום איטי)
/// - נותן תחושה של "ספירה חיה"!
/// 
/// דוגמה:
/// Badge count משתנה מ-3 ל-5:
/// - 0ms: 3
/// - 400ms: 4
/// - 800ms: 5 ✨
/// 
/// New in v3.0 - Modern UI Pattern
class _AnimatedBadgeCount extends StatelessWidget {
  final int count;

  const _AnimatedBadgeCount({required this.count});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: count),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Text(value.toString());
      },
    );
  }
}

// === Navigation Items ===

/// 📱 Navigation Item Data Class
class _NavItem {
  final IconData icon;
  final String label;
  
  const _NavItem({
    required this.icon, 
    required this.label,
  });
}

/// 📋 Navigation Items List
///
/// Note: Uses AppStrings for consistent i18n support.
/// These items define the bottom navigation structure.
/// Version 4.0: New navigation - Home | Family | Groups | Settings
final List<_NavItem> _navItems = [
  _NavItem(icon: Icons.home, label: AppStrings.navigation.home),
  _NavItem(icon: Icons.family_restroom, label: AppStrings.navigation.family),
  _NavItem(icon: Icons.groups, label: AppStrings.navigation.groups),
  _NavItem(icon: Icons.settings, label: AppStrings.navigation.settings),
];

// === Drawer Item Widget ===

/// 🗂️ Drawer Item with Animation
/// 
/// מה זה עושה:
/// - Selected item: Background color + Icon color change
/// - Badge: Animated count (TweenAnimationBuilder)
/// - Smooth transitions (AnimatedContainer)
/// 
/// New in v3.0 - Modern UI Pattern
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? badgeCount;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final effectiveColor = color ?? (selected ? cs.primary : cs.onSurfaceVariant);

    Widget leadingIcon = Icon(icon, color: effectiveColor);

    // 🎯 Add animated badge if count > 0
    if (badgeCount != null && badgeCount! > 0) {
      leadingIcon = Badge(
        backgroundColor: cs.error,
        textColor: cs.onError,
        label: _AnimatedBadgeCount(count: badgeCount!),
        child: leadingIcon,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: selected ? cs.primary.withValues(alpha: 0.08) : Colors.transparent,
      ),
      child: ListTile(
        leading: leadingIcon,
        title: Text(
          label,
          style: TextStyle(
            color: color ?? (selected ? cs.primary : cs.onSurface),
          ),
          textAlign: TextAlign.right,
        ),
        trailing: selected ? Icon(Icons.chevron_left, color: cs.primary) : null,
        selected: selected,
        onTap: onTap,
      ),
    );
  }
}
