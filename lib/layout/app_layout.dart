// 📄 File: lib/layout/app_layout.dart
//
// 🇮🇱 קובץ זה מגדיר את פריסת האפליקציה (AppLayout):
//     - מציג AppBar עם התראות והתנתקות.
//     - Drawer עם פרטי משתמש ותפריט ניווט.
//     - BottomNavigationBar עם באדג'ים לכל טאב.
//     - ניהול child (תוכן דינמי לפי הטאב הנבחר).
//     - מציג מצב Offline במידת הצורך.
//
// 🇬🇧 This file defines the main app layout (AppLayout):
//     - Displays AppBar with notifications and logout.
//     - Drawer with user profile and navigation menu.
//     - BottomNavigationBar with badges per tab.
//     - Manages the child (dynamic content per selected tab).
//     - Shows an offline banner when connection is lost.
//

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool isOnline = true;

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');

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
              "סל חכם", // TODO: move to localization
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
            tooltip: 'התראות', // TODO: move to localization
            icon: Badge.count(
              count: _getTotalBadgeCount(),
              isLabelVisible: _getTotalBadgeCount() > 0,
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _getTotalBadgeCount() > 0
                        ? "יש לך ${_getTotalBadgeCount()} עדכונים חדשים"
                        : "אין התראות חדשות", // TODO: move to localization
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'התנתק', // TODO: move to localization
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
                    Navigator.pop(context);
                    widget.onTabSelected(e.key);
                  },
                ),
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: cs.error),
                title: Text('התנתקות', style: TextStyle(color: cs.onSurface)),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          if (!isOnline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              color: cs.errorContainer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 16, color: cs.onErrorContainer),
                  const SizedBox(width: 8),
                  Text(
                    'אין חיבור לרשת', // TODO: move to localization
                    style: TextStyle(color: cs.onErrorContainer),
                  ),
                ],
              ),
            ),
          Expanded(child: widget.child),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: widget.onTabSelected,
        backgroundColor: cs.surfaceContainer,
        indicatorColor: cs.primary.withOpacity(0.12),
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

  int _getTotalBadgeCount() {
    if (widget.badges == null) return 0;
    return widget.badges!.values
        .where((count) => count != null)
        .fold(0, (sum, count) => sum + count!);
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(color: cs.primary),
      accountName: const Text('שלום 👋'), // TODO: move to localization
      accountEmail: Text(
        _getTotalBadgeCount() > 0
            ? 'יש לך ${_getTotalBadgeCount()} עדכונים חדשים'
            : 'ברוך הבא לסל חכם', // TODO: move to localization
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: cs.onPrimary.withOpacity(0.15),
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

const List<_NavItem> _navItems = [
  _NavItem(Icons.home, "בית"), // TODO: move to localization
  _NavItem(Icons.shopping_cart, "רשימות"), // TODO: move to localization
  _NavItem(Icons.inventory, "מזווה"), // TODO: move to localization
  _NavItem(Icons.bar_chart, "תובנות"), // TODO: move to localization
  _NavItem(Icons.settings, "הגדרות"), // TODO: move to localization
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
      selectedTileColor: cs.primary.withOpacity(0.08),
      onTap: onTap,
    );
  }
}
