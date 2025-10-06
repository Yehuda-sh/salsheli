// 📄 File: lib/layout/app_layout.dart
//
// 🇮🇱 קובץ זה מגדיר את פריסת האפליקציה (AppLayout):
//     - מציג AppBar עם התראות והתנתקות.
//     - Drawer עם פרטי משתמש ותפריט ניווט.
//     - BottomNavigationBar עם באדג'ים לכל טאב.
//     - ניהול child (תוכן דינמי לפי הטאב הנבחר).
//
// 🇬🇧 This file defines the main app layout (AppLayout):
//     - Displays AppBar with notifications and logout.
//     - Drawer with user profile and navigation menu.
//     - BottomNavigationBar with badges per tab.
//     - Manages the child (dynamic content per selected tab).
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
// Version: 2.0
// Last Updated: 06/10/2025
//

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_strings.dart';

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
  @override
  void initState() {
    super.initState();
    debugPrint('📱 AppLayout.initState: currentIndex=${widget.currentIndex}, badges=${widget.badges}');
  }

  @override
  void dispose() {
    debugPrint('🗑️ AppLayout.dispose');
    super.dispose();
  }

  Future<void> _logout() async {
    debugPrint('🚪 AppLayout.logout: clearing userId');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    debugPrint('   ✅ userId cleared, navigating to /login');

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final safeIndex = widget.currentIndex.clamp(0, _navItems.length - 1);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surfaceContainer,
        foregroundColor: cs.onSurface,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_basket_outlined, color: cs.primary),
            const SizedBox(width: 8),
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
          IconButton(
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
          IconButton(
            tooltip: AppStrings.common.logout,
            icon: const Icon(Icons.logout),
            color: cs.error,
            onPressed: _logout,
          ),
        ],
      ),

      drawer: Drawer(
        backgroundColor: cs.surfaceContainerHighest,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildDrawerHeader(context),
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
              ListTile(
                leading: Icon(Icons.logout, color: cs.error),
                title: Text(AppStrings.common.logoutAction, style: TextStyle(color: cs.onSurface)),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),

      body: widget.child,

      bottomNavigationBar: NavigationBar(
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
            icon = _buildBadgedIcon(icon, badgeCount, cs);
            selectedIcon = _buildBadgedIcon(selectedIcon, badgeCount, cs);
          }

          return NavigationDestination(
            icon: icon,
            selectedIcon: selectedIcon,
            label: item.label,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBadgedIcon(Widget icon, int count, ColorScheme cs) {
    return Badge.count(
      count: count,
      isLabelVisible: true,
      backgroundColor: cs.error,
      textColor: cs.onError,
      child: icon,
    );
  }

  /// Total badge count across all tabs
  int get totalBadgeCount {
    if (widget.badges == null) return 0;
    return widget.badges!.values
        .whereType<int>()
        .fold(0, (sum, count) => sum + count);
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

// Note: _navItems must be a top-level const, so we use literal strings.
// The AppStrings are used at runtime in the widget tree.
final List<_NavItem> _navItems = [
  _NavItem(Icons.home, AppStrings.navigation.home),
  _NavItem(Icons.shopping_cart, AppStrings.navigation.lists),
  _NavItem(Icons.inventory, AppStrings.navigation.pantry),
  _NavItem(Icons.bar_chart, AppStrings.navigation.insights),
  _NavItem(Icons.settings, AppStrings.navigation.settings),
];

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? badgeCount;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget leadingIcon = Icon(
      icon,
      color: selected ? cs.primary : cs.onSurfaceVariant,
    );

    if (badgeCount != null && badgeCount! > 0) {
      leadingIcon = Badge.count(
        count: badgeCount!,
        backgroundColor: cs.error,
        textColor: cs.onError,
        child: leadingIcon,
      );
    }

    return ListTile(
      leading: leadingIcon,
      title: Text(
        label,
        style: TextStyle(color: selected ? cs.primary : cs.onSurface),
        textAlign: TextAlign.right,
      ),
      trailing: selected
          ? Icon(Icons.chevron_right, color: cs.primary)
          : const Icon(Icons.chevron_left, color: Colors.transparent),
      selected: selected,
      selectedTileColor: cs.primary.withValues(alpha: 0.08),
      onTap: onTap,
    );
  }
}
