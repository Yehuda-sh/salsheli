// 📄 File: lib/screens/main_navigation_screen.dart
//
// 🇮🇱 **מסך הניווט הראשי** - Bottom Navigation Shell
//
// **4 Tabs:**
// 0. 🏠 בית - HomeDashboardScreen
// 1. 📦 מזווה - MyPantryScreen
// 2. 👥 קבוצות - GroupsListScreen
// 3. ⚙️ הגדרות - SettingsScreen
//
// **Back Button:**
// - מטאב 1-3 → חזרה לדשבורד (tab 0)
// - מדשבורד → double-tap ליציאה (2 שניות)
//
// **Version:** 4.1 (13/01/2026) - Added badges for pending group invites
//
// **Badges:**
// - Tab 2 (קבוצות) מציג badge עם מספר הזמנות ממתינות

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/ui_constants.dart';
import '../l10n/app_strings.dart';
import '../layout/app_layout.dart';
import '../providers/pending_invites_provider.dart';
import 'groups/groups_list_screen.dart';
import 'home/dashboard/home_dashboard_screen.dart';
import 'pantry/my_pantry_screen.dart';
import 'settings/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  DateTime? _lastBackPress;
  bool _initialArgsHandled = false; // ✅ דגל: כבר טיפלתי ב-args הראשוניים

  late final List<Widget> _pages = const <Widget>[
    HomeDashboardScreen(),
    MyPantryScreen(),
    GroupsListScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      debugPrint('🏠 MainNavigationScreen.initState()');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ טיפול ב-args פעם אחת בלבד (מונע בדיקות מיותרות)
    if (_initialArgsHandled) return;
    _initialArgsHandled = true; // ✅ סימון מיידי - גם אם אין args

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int && args >= 0 && args < _pages.length) {
      if (_selectedIndex != args) {
        setState(() {
          _selectedIndex = args;
        });
        if (kDebugMode) {
          debugPrint('🏠 MainNavigation: Switched to tab $args via arguments');
        }
      }
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      debugPrint('🏠 MainNavigationScreen.dispose()');
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    // 🛡️ בדיקת bounds - מונע RangeError
    if (index < 0 || index >= _pages.length) {
      if (kDebugMode) {
        debugPrint('❌ MainNavigationScreen: טאב לא חוקי $index (טווח חוקי: 0-${_pages.length - 1})');
      }
      return;
    }

    if (_selectedIndex == index) return;

    // 🔧 איפוס טיימר double-tap כשעוברים בין טאבים
    _lastBackPress = null;

    // ✨ Haptic feedback קל למשוב מישוש
    HapticFeedback.selectionClick();

    if (kDebugMode) {
      debugPrint('🏠 MainNavigationScreen: מעבר לטאב $_selectedIndex → $index');
    }
    setState(() => _selectedIndex = index);
  }

  Future<bool> _onWillPop() {
    // אם לא בטאב הראשון - חזור אליו במקום לצאת
    if (_selectedIndex != 0) {
      if (kDebugMode) {
        debugPrint('🏠 MainNavigationScreen: Back מטאב $_selectedIndex → חזרה לדשבורד (0)');
      }
      setState(() => _selectedIndex = 0);
      return Future.value(false);
    }

    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > kDoubleTapTimeout) {
      _lastBackPress = now;
      if (kDebugMode) {
        debugPrint('🏠 MainNavigationScreen: לחיצה ראשונה על Back - חכה לשנייה');
      }

      // ✅ בדיקת mounted ו-context נשמרים לפני כל פעולה
      if (!mounted) return Future.value(false);
      final messenger = ScaffoldMessenger.of(context);

      // 🔧 מנקה SnackBar קודם אם קיים (מונע duplicates)
      messenger.clearSnackBars();

      // ✨ Haptic feedback למשוב מישוש
      HapticFeedback.lightImpact();

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
      debugPrint('🏠 MainNavigationScreen: לחיצה שנייה על Back - יוצא מהאפליקציה');
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    // 🔔 מספר הזמנות ממתינות לקבוצות (ל-badge)
    final pendingCount = context.watch<PendingInvitesProvider>().pendingCount;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          // ✅ SystemNavigator.pop() - יוצא מהאפליקציה לגמרי (לא חוזר ל-route קודם)
          await SystemNavigator.pop();
        }
      },
      child: AppLayout(
        currentIndex: _selectedIndex,
        onTabSelected: _onItemTapped,
        // 🔔 Badge על טאב קבוצות (index 2) אם יש הזמנות ממתינות
        badges: pendingCount > 0 ? {2: pendingCount} : null,
        // ✅ IndexedStack: שומר מצב של כל הטאבים (גלילה, פילטרים, חיפוש)
        // כל ה-pages נשארים בזיכרון, רק הנראות משתנה
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
    );
  }
}
