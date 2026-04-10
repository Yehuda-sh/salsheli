// 📄 File: lib/layout/app_layout.dart
//
// 🎯 Purpose: פריסת היישום הראשית - AppBar + BottomNavigation
//
// 📋 Features:
//     - AppBar עם כותרת, התראות ו-logout
//     - NavigationBar (Material 3) עם animated badges
//     - משוב Haptic מבוסס מגע (Selection Feedback)
//     - עיצוב Glassmorphic ל-Bottom Navigation
//     - RTL support מלא
//     - Theme-aware colors (Dark Mode support)
//     - Accessibility: Semantics + Tooltips
//     - Micro-animations: Scale effect, badge counter
//     - Error handling with user feedback
//
// 🔗 Related:
//     - lib/l10n/app_strings.dart - AppStrings.layout
//     - lib/providers/user_context.dart - UserContext
//     - Parent: MainNavigationScreen (manages state)
//
// Version: 4.0
// Last Updated: 22/02/2026

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:provider/provider.dart';

import '../core/ui_constants.dart';
import '../l10n/app_strings.dart';
import '../providers/inventory_provider.dart';
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
  /// 🔔 הצגת תפריט בחירת סוג הזמנות
  void _showNotificationsMenu(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface.withValues(alpha: kOpacityHigh),
      barrierColor: cs.scrim.withValues(alpha: kOpacityLight),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kBorderRadiusLarge)),
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
                margin: const EdgeInsets.only(top: kSpacingSmallPlus),
                width: kSpacingXLarge + kSpacingSmall,
                height: kSpacingXTiny,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(kSpacingXTiny / 2),
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
              // הזמנות ממתינות (קבוצות + רשימות באותו מסך)
              ListTile(
                leading: Icon(Icons.mail_outlined, color: cs.primary),
                title: Text(AppStrings.layout.pendingInvitesTitle),
                subtitle: Text(AppStrings.layout.groupInvitesSubtitle),
                trailing: Icon(forwardChevron),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed('/pending-invites');
                },
              ),
              // מלאי חסר — רק אם יש
              Builder(builder: (ctx) {
                final lowStockCount = ctx.read<InventoryProvider>().getLowStockItems().length;
                if (lowStockCount == 0) return const SizedBox.shrink();
                return ListTile(
                  leading: Icon(Icons.inventory_2_outlined, color: cs.error),
                  title: Text(AppStrings.layout.lowStockTitle),
                  subtitle: Text(AppStrings.layout.lowStockSubtitle(lowStockCount)),
                  trailing: Badge.count(count: lowStockCount, child: Icon(forwardChevron)),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onTabSelected(1); // מעבר לטאב מזווה
                  },
                );
              }),
              const Divider(height: 1),
              // התראות כלליות
              ListTile(
                leading: Icon(Icons.notifications_outlined, color: cs.tertiary),
                title: Text(AppStrings.layout.notifications),
                subtitle: Text(AppStrings.layout.notificationsSubtitle),
                trailing: Icon(forwardChevron),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed('/notifications');
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
    return AppBar(
      // ✅ Premium branded header
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 📓 App logo
          Image.asset(
            'assets/images/logo.png',
            width: kAppBarIconSize,
            height: kAppBarIconSize,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: kSpacingSmall),
          // ✍️ Handwriting-style brand name
          Text(
            AppStrings.layout.appTitle,
            style: TextStyle(
              fontFamily: 'Caveat',
              fontSize: kFontSizeXLarge,
              fontWeight: FontWeight.w700,
              color: cs.primary,
              letterSpacing: 0.5,
              height: 1.0,
            ),
          ),
        ],
      ),
      centerTitle: true,
      // 👤 Avatar בצד ימין (leading ב-RTL) — לחיצה עוברת לטאב הגדרות
      leading: Padding(
        padding: const EdgeInsetsDirectional.only(start: kSpacingSmall),
        child: GestureDetector(
          onTap: () => widget.onTabSelected(3), // index 3 = Settings tab
          child: Center(
            child: Container(
              width: kIconSizeLarge,
              height: kIconSizeLarge,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: cs.primary.withValues(alpha: 0.3), width: 1.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: Builder(
                builder: (ctx) {
                  final userCtx = ctx.watch<UserContext>();
                  final url = userCtx.profileImageUrl;
                  if (url != null) {
                    return Image.network(url, fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Image.asset('assets/images/default_avatar.webp', fit: BoxFit.cover));
                  }
                  return Image.asset('assets/images/default_avatar.webp', fit: BoxFit.cover);
                },
              ),
            ),
          ),
        ),
      ),
      actions: [
        // 🔔 Notifications — only notification count (not low stock)
        IconButton(
          tooltip: AppStrings.layout.notifications,
          icon: Badge.count(
            count: widget.badges?[0] ?? 0,
            isLabelVisible: (widget.badges?[0] ?? 0) > 0,
            child: Icon(Icons.notifications_outlined, size: kIconSizeMedium),
          ),
          onPressed: () => _showNotificationsMenu(context),
        ),
      ],
    );
  }

  /// 📱 Build Bottom Navigation Bar
  /// ✅ Glassmorphic: BackdropFilter + semi-transparent background
  /// ✅ Haptic: selectionClick על מעבר טאב
  /// ✅ RepaintBoundary: מבודד את אנימציות ה-badges מהעץ
  Widget _buildBottomNav(BuildContext context, ColorScheme cs, int safeIndex) {
    final currentTabLabel = _navItems[safeIndex].label;

    return RepaintBoundary(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: kGlassBlurMedium, sigmaY: kGlassBlurMedium),
          child: Semantics(
            label: AppStrings.layout.navSemanticLabel(currentTabLabel),
            hint: AppStrings.layout.navSemanticHint,
            child: NavigationBar(
              selectedIndex: safeIndex,
              onDestinationSelected: (index) {
                unawaited(HapticFeedback.selectionClick());
                widget.onTabSelected(index);
              },
              backgroundColor: cs.surfaceContainer.withValues(alpha: kOpacityHigh),
              indicatorColor: cs.primary.withValues(alpha: kOpacitySubtle),
              destinations: _navItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                // ⚠️ Tab 0 (Home) - לא מציגים תג כי הפעמון ב-AppBar
                // כבר מציג את אותו ערך (unread notifications). למניעת כפילות.
                final badgeCount = index == 0 ? null : widget.badges?[index];

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
          ),
        ),
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
    if (oldWidget.count != widget.count) {
      _previousCount = oldWidget.count;
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
      curve: Curves.easeOutCubic,
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
/// Version 6.0: New navigation - Home | Pantry | History | Settings
/// ✅ Getter (not final) so labels update on locale change
List<_NavItem> get _navItems => [
  _NavItem(icon: Icons.home, label: AppStrings.navigation.home),
  _NavItem(icon: Icons.inventory_2_outlined, label: AppStrings.navigation.pantry),
  _NavItem(icon: Icons.receipt_long, label: AppStrings.navigation.history),
  _NavItem(icon: Icons.settings, label: AppStrings.navigation.settings),
];

