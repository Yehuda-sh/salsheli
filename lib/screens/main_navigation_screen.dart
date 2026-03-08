// 📄 File: lib/screens/main_navigation_screen.dart
//
// Version: 4.0 (22/02/2026)
//
// 🇮🇱 **מסך הניווט הראשי** - Bottom Navigation Shell
//
// **4 Tabs:**
// 0. 🏠 בית - HomeDashboardScreen
// 1. 📦 מזווה - MyPantryScreen
// 2. 📜 היסטוריה - ShoppingHistoryScreen
// 3. ⚙️ הגדרות - SettingsScreen
//
// ✨ Features:
//     - Fade transition on tab switch (200ms, preserves tab state)
//     - Smart Badges: NotificationsService (unread) + InventoryProvider (low stock)
//     - Context-aware Haptic: selectionClick for nav, heavyImpact for exit warning
//     - Improved global state management
//
// 📅 History:
//     v4.0 (22/02/2026) — Fade transition, Smart Badges, Haptic, improved state
//     v3.0              — PopScope, double-tap exit, AppLayout integration
//
// **Back Button:**
// - מטאב 1-3 → חזרה לדשבורד (tab 0)
// - מדשבורד → double-tap ליציאה (2 שניות)

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/ui_constants.dart';
import '../l10n/app_strings.dart';
import '../layout/app_layout.dart';
import '../providers/inventory_provider.dart';
import '../providers/user_context.dart';
import '../services/notifications_service.dart';
import 'history/shopping_history_screen.dart';
import 'home/dashboard/home_dashboard_screen.dart';
import 'pantry/my_pantry_screen.dart';
import 'settings/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  DateTime? _lastBackPress;
  bool _initialArgsHandled = false;

  // v4.0: Fade transition controller
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // v4.0: Unread notifications badge (stream-based)
  int _unreadCount = 0;
  StreamSubscription<int>? _unreadSub;
  String? _subscribedUserId;

  static const List<Widget> _pages = <Widget>[
    HomeDashboardScreen(),
    MyPantryScreen(),
    ShoppingHistoryScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0, // start fully visible
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    if (kDebugMode) {
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // v4.0: Subscribe to unread notifications count
    _subscribeToUnreadCount();

    // ✅ טיפול ב-args פעם אחת בלבד (מונע בדיקות מיותרות)
    if (_initialArgsHandled) return;
    _initialArgsHandled = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int && args >= 0 && args < _pages.length) {
      if (_selectedIndex != args) {
        setState(() => _selectedIndex = args);
        // v4.0: Haptic + fade for argument-based navigation
        unawaited(HapticFeedback.selectionClick());
        _triggerFadeIn();
        if (kDebugMode) {
        }
      }
    }
  }

  /// 🔔 v4.0: Subscribe to unread notification count stream
  ///
  /// Uses [NotificationsService.watchUnreadCount] for real-time updates.
  /// Guards against redundant resubscriptions via [_subscribedUserId].
  void _subscribeToUnreadCount() {
    final userId = context.read<UserContext>().userId;
    if (userId == _subscribedUserId) return; // already subscribed

    _unreadSub?.cancel();
    _subscribedUserId = userId;

    if (userId == null) return;
    final service = context.read<NotificationsService?>();
    if (service == null) return;

    _unreadSub = service.watchUnreadCount(userId: userId).listen((count) {
      if (mounted && _unreadCount != count) {
        setState(() => _unreadCount = count);
      }
    });
  }

  /// 🎬 v4.0: Trigger fade-in animation (instant reset → smooth fade)
  void _triggerFadeIn() {
    _fadeController.value = 0.0;
    _fadeController.forward();
  }

  @override
  void dispose() {
    _unreadSub?.cancel();
    _fadeController.dispose();
    if (kDebugMode) {
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    // 🛡️ בדיקת bounds - מונע RangeError
    if (index < 0 || index >= _pages.length) {
      if (kDebugMode) {
      }
      return;
    }

    if (_selectedIndex == index) return;

    // 🔧 איפוס טיימר double-tap כשעוברים בין טאבים
    _lastBackPress = null;

    // v4.0: Haptic selectionClick — iOS-standard "physical click" feel
    unawaited(HapticFeedback.selectionClick());

    // v4.0: Fade transition — instant opacity 0, then animate to 1
    _triggerFadeIn();

    if (kDebugMode) {
    }
    setState(() => _selectedIndex = index);
  }

  Future<bool> _handleBackPress() {
    // אם לא בטאב הראשון - חזור אליו במקום לצאת
    if (_selectedIndex != 0) {
      if (kDebugMode) {
      }
      // v4.0: Haptic + fade on back-to-home
      unawaited(HapticFeedback.selectionClick());
      _triggerFadeIn();
      setState(() => _selectedIndex = 0);
      return Future.value(false);
    }

    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > kDoubleTapTimeout) {
      _lastBackPress = now;
      if (kDebugMode) {
      }

      // ✅ בדיקת mounted ו-context נשמרים לפני כל פעולה
      if (!mounted) return Future.value(false);
      final messenger = ScaffoldMessenger.of(context);

      // 🔧 מנקה SnackBar קודם אם קיים (מונע duplicates)
      messenger.clearSnackBars();

      // v4.0: Heavy haptic for exit warning — system-level action emphasis
      unawaited(HapticFeedback.heavyImpact());

      messenger.showSnackBar(
        SnackBar(
            content: Text(
              AppStrings.home.doubleTapToExit,
              textAlign: TextAlign.center,
            ),
            duration: kSnackBarDuration,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(
              bottom: kSnackBarBottomMargin,
              left: kSnackBarHorizontalMargin,
              right: kSnackBarHorizontalMargin,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            ),
          ),
        );
      return Future.value(false);
    }

    // לחיצה שנייה תוך 2 שניות - אפשר יציאה
    if (kDebugMode) {
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    // v4.0: Watch inventory for pantry low-stock badge
    final inventoryProvider = context.watch<InventoryProvider>();
    final lowStockCount = inventoryProvider.getLowStockItems().length;

    // v4.0: Build dynamic badges map
    // Tab 0 (Home): unread notification count
    // Tab 1 (Pantry): low stock item count
    final badges = <int, int?>{
      if (_unreadCount > 0) 0: _unreadCount,
      if (lowStockCount > 0) 1: lowStockCount,
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        final shouldPop = await _handleBackPress();
        if (shouldPop && mounted) {
          // ✅ SystemNavigator.pop() - יוצא מהאפליקציה לגמרי (לא חוזר ל-route קודם)
          await SystemNavigator.pop();
        }
      },
      child: AppLayout(
        currentIndex: _selectedIndex,
        onTabSelected: _onItemTapped,
        badges: badges.isNotEmpty ? badges : null,
        // v4.0: FadeTransition wraps IndexedStack
        // ✅ IndexedStack preserved: שומר מצב של כל הטאבים (גלילה, פילטרים, חיפוש)
        // ✅ FadeTransition: אפקט fade-in עדין (200ms) בכל מעבר טאב
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
        ),
      ),
    );
  }
}
