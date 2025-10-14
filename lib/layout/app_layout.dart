// 📄 File: lib/layout/app_layout.dart
//
// 🇮🇱 קובץ זה מגדיר את פריסת האפליקציה (AppLayout):
//     - מציג AppBar עם התראות והתנתקות.
//     - Drawer עם פרטי משתמש ותפריט ניווט.
//     - BottomNavigationBar עם באדג'ים לכל טאב.
//     - ניהול child (תוכן דינמי לפי הטאב הנבחר).
//     - תמיכה מלאה ב-RTL (עברית).
//     - Micro Animations למעבר חלק.
//
// 🇬🇧 This file defines the main app layout (AppLayout):
//     - Displays AppBar with notifications and logout.
//     - Drawer with user profile and navigation menu.
//     - BottomNavigationBar with badges per tab.
//     - Manages the child (dynamic content per selected tab).
//     - Full RTL support (Hebrew).
//     - Micro Animations for smooth transitions.
//
// 📖 Usage Example:
// ```dart
// AppLayout(
//   currentIndex: 0,
//   onTabSelected: (index) => setState(() => _currentTab = index),
//   badges: {1: 3, 2: 1}, // 3 ברשימות, 1 במזווה
//   child: IndexedStack(
//     index: _currentTab,
//     children: [HomeScreen(), ListsScreen(), PantryScreen(), ...],
//   ),
// )
// ```
//
// 🎨 New in v3.0 (14/10/2025):
// - ✅ UserContext Provider integration (לא SharedPreferences ישירות!)
// - ✅ Firebase Auth logout (מתנתק גם מהשרת)
// - ✅ RTL Support מלא (Directionality wrapper)
// - ✅ Button Animations (Scale effect ללוגאוט)
// - ✅ Badge Count Animations (TweenAnimationBuilder)
// - ✅ Error Handling ללוגאוט
// - ✅ Cached totalBadgeCount (Performance)
// - ✅ Context safety after async
//
// Version: 3.0 - Modern UI/UX + UserContext Integration
// Last Updated: 14/10/2025
//

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_context.dart';
import '../l10n/app_strings.dart';
import '../core/ui_constants.dart';

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
    debugPrint('📱 AppLayout.initState: currentIndex=${widget.currentIndex}, badges=${widget.badges}');
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
    debugPrint('🗑️ AppLayout.dispose');
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
    debugPrint('🚪 AppLayout.logout: התחלת התנתקות');

    // 💾 Save context before async (Context Safety)
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      // 🔐 Logout via UserContext Provider
      // ✅ זה מנקה גם Firebase Auth וגם SharedPreferences!
      await context.read<UserContext>().logout();
      debugPrint('   ✅ UserContext.logout() הושלם בהצלחה');

      // ✅ Context safety check
      if (!mounted) return;

      // 🏠 Navigate to login (Clear stack)
      navigator.pushNamedAndRemoveUntil('/login', (r) => false);
      debugPrint('   ✅ ניווט ל-/login');

    } catch (e) {
      debugPrint('   ❌ AppLayout.logout: שגיאה - $e');

      // 🚨 Show error to user
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: kSpacingSmall),
              Expanded(
                child: Text(
                  'שגיאה בהתנתקות: ${e.toString()}',
                  style: const TextStyle(fontSize: 14),
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
                  debugPrint('🔄 AppLayout.tabSelected: ${e.key} (${e.value.label})');
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

  /// 👤 Build Drawer Header
  Widget _buildDrawerHeader(BuildContext context, ColorScheme cs) {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(color: cs.primary),
      accountName: Text(AppStrings.layout.hello),
      accountEmail: Text(
        totalBadgeCount > 0
            ? AppStrings.layout.welcomeWithUpdates(totalBadgeCount)
            : AppStrings.layout.welcome,
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: cs.onPrimary.withValues(alpha: 0.15),
        child: Icon(Icons.person, color: cs.onPrimary),
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
  const _NavItem(this.icon, this.label);
}

/// 📋 Navigation Items List
/// 
/// Note: Must use literal strings because const doesn't support AppStrings.
/// The actual strings are used at runtime in the widget tree.
final List<_NavItem> _navItems = [
  _NavItem(Icons.home, AppStrings.navigation.home),
  _NavItem(Icons.shopping_cart, AppStrings.navigation.lists),
  _NavItem(Icons.inventory, AppStrings.navigation.pantry),
  _NavItem(Icons.bar_chart, AppStrings.navigation.insights),
  _NavItem(Icons.settings, AppStrings.navigation.settings),
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
        trailing: selected
            ? Icon(Icons.chevron_left, color: cs.primary) // RTL: chevron_left!
            : const Icon(Icons.chevron_right, color: Colors.transparent), // RTL: chevron_right!
        selected: selected,
        onTap: onTap,
      ),
    );
  }
}
