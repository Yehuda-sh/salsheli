// 📄 lib/layout/app_layout.dart
//
// **פריסת היישום הראשית** - AppBar + BottomNavigation.
// מרכז את הניווט הראשי של האפליקציה עם תמיכה מלאה ב-RTL, badges אנימטיביים,
// ואנימציות מיקרו לחוויית משתמש חלקה.
//
// ✅ Features:
//    - AppBar עם כותרת, התראות ו-logout
//    - NavigationBar (Material 3) עם animated badges
//    - RTL support מלא (Directionality wrapper)
//    - Theme-aware colors (Dark Mode support)
//    - Accessibility: Semantics + Tooltips
//    - Micro-animations: Scale effect, badge counter animation
//    - Error handling with user feedback
//
// 🔗 Related: AppStrings.layout, UserContext, PendingInvitesProvider
// 🔗 Parent: MainNavigationScreen (manages state)

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/ui_constants.dart';
import '../l10n/app_strings.dart';
import '../providers/pending_invites_provider.dart';
import '../providers/user_context.dart';

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
    // ✅ FIX: תמיד מחשב מחדש - גם אם אותו אובייקט Map עם ערכים שונים
    _updateBadgeCache();
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
    final cs = Theme.of(context).colorScheme;

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

      // ✅ Context safety check - אל תציג UI אם המסך נסגר
      if (!mounted) return;

      // 🚨 Show error to user
      // ✅ שימוש ב-Theme colors במקום hardcoded
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: cs.onErrorContainer),
              const SizedBox(width: kSpacingSmall),
              Expanded(
                child: Text(
                  AppStrings.layout.logoutError,
                  style: TextStyle(fontSize: 14, color: cs.onErrorContainer),
                ),
              ),
            ],
          ),
          backgroundColor: cs.errorContainer,
          duration: kSnackBarDurationLong,
          action: SnackBarAction(
            label: AppStrings.common.retry,
            textColor: cs.onErrorContainer,
            onPressed: () => _logout(context),
          ),
        ),
      );
    }
  }

  /// 🔔 הצגת תפריט בחירת סוג הזמנות
  void _showNotificationsMenu(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        // ✅ RTL/LTR-aware chevron: forward direction
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        final forwardChevron = isRtl ? Icons.chevron_left : Icons.chevron_right;

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: kSpacingMedium),
              // כותרת
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                child: Text(
                  AppStrings.layout.pendingInvitesTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: kSpacingSmall),
              // הזמנות לקבוצות
              ListTile(
                leading: Icon(Icons.family_restroom, color: cs.primary),
                title: Text(AppStrings.layout.groupInvites),
                subtitle: Text(AppStrings.layout.groupInvitesSubtitle),
                trailing: Icon(forwardChevron),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed('/pending-group-invites');
                },
              ),
              // הזמנות לרשימות
              ListTile(
                leading: Icon(Icons.list_alt, color: cs.secondary),
                title: Text(AppStrings.layout.listInvites),
                subtitle: Text(AppStrings.layout.listInvitesSubtitle),
                trailing: Icon(forwardChevron),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed('/pending-invites');
                },
              ),
              const SizedBox(height: kSpacingMedium),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final safeIndex = widget.currentIndex.clamp(0, _navItems.length - 1);

    // ✅ RTL Support: Let MaterialApp's localization handle direction automatically
    // When app locale is Hebrew → RTL, English → LTR
    // No forced Directionality wrapper needed!
    return Scaffold(
      appBar: _buildAppBar(context, cs),
      body: widget.child,
      bottomNavigationBar: _buildBottomNav(context, cs, safeIndex),
    );
  }

  /// 🎨 Build AppBar
  /// ✅ צבעים מגיעים מ-AppBarTheme (מקור אמת יחיד)
  PreferredSizeWidget _buildAppBar(BuildContext context, ColorScheme cs) {
    final theme = Theme.of(context);

    return AppBar(
      // ✅ הוסר: backgroundColor/foregroundColor - מגיעים מ-Theme
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
        // 🔔 Notifications Button - פותח תפריט בחירת סוג הזמנות
        _AnimatedIconButton(
          tooltip: AppStrings.layout.notifications,
          icon: Badge.count(
            count: totalBadgeCount,
            isLabelVisible: totalBadgeCount > 0,
            child: const Icon(Icons.notifications_outlined),
          ),
          onPressed: () => _showNotificationsMenu(context),
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

  /// 📱 Build Bottom Navigation Bar
  /// ✅ עטוף ב-Semantics לנגישות
  Widget _buildBottomNav(BuildContext context, ColorScheme cs, int safeIndex) {
    final currentTabLabel = _navItems[safeIndex].label;

    return Semantics(
      // ✅ Use AppStrings for i18n-ready accessibility labels
      label: AppStrings.layout.navSemanticLabel(currentTabLabel),
      hint: AppStrings.layout.navSemanticHint,
      child: NavigationBar(
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
      ),
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
        // ✅ FIX: אנימציה + פעולה - עם בדיקת mounted!
        setState(() => _isPressed = true);
        widget.onPressed(); // פעולה (יכולה לעשות navigate/dispose)
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            setState(() => _isPressed = false);
          }
        });
      },
    );
  }
}

/// 🎯 Animated Badge Count (Counter Animation)
///
/// ✅ FIX: סופר מהערך הקודם לחדש (לא מ-0!)
///
/// דוגמה:
/// Badge count משתנה מ-3 ל-5:
/// - 0ms: 3
/// - 200ms: 4
/// - 400ms: 5 ✨
class _AnimatedBadgeCount extends StatefulWidget {
  final int count;

  const _AnimatedBadgeCount({required this.count});

  @override
  State<_AnimatedBadgeCount> createState() => _AnimatedBadgeCountState();
}

class _AnimatedBadgeCountState extends State<_AnimatedBadgeCount> {
  late int _previousCount;
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    // ✅ FIX: בפעם הראשונה, התחל מאותו ערך (ללא אנימציה)
    _previousCount = widget.count;
  }

  @override
  void didUpdateWidget(_AnimatedBadgeCount oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ שומר את הערך הקודם לאנימציה (רק אחרי build ראשון)
    if (oldWidget.count != widget.count) {
      _previousCount = oldWidget.count;
      _isFirstBuild = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: בפעם הראשונה - הצג מיידית ללא אנימציה
    if (_isFirstBuild) {
      _isFirstBuild = false;
      return Text(widget.count.toString());
    }

    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: _previousCount, end: widget.count),
      duration: const Duration(milliseconds: 400),
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
/// Version 5.0: New navigation - Home | Pantry | Groups | Settings
final List<_NavItem> _navItems = [
  _NavItem(icon: Icons.home, label: AppStrings.navigation.home),
  _NavItem(icon: Icons.inventory_2_outlined, label: AppStrings.navigation.pantry),
  _NavItem(icon: Icons.groups, label: AppStrings.navigation.groups),
  _NavItem(icon: Icons.settings, label: AppStrings.navigation.settings),
];

