// 📄 File: lib/screens/home/home_screen.dart
//
// 🇮🇱 **מסך הבית הראשי** - Navigation Shell
//
// **מבנה:**
// - Bottom Navigation Bar עם 5 טאבים
// - AnimatedSwitcher עם fade transitions (200ms)
// - Badges דינמיים (מספר רשימות פעילות)
// - יציאה בטוחה (double-tap back)
//
// **Tabs:**
// 0. 🏠 דשבורד - HomeDashboardScreen
// 1. 📝 רשימות - ShoppingListsScreen (עם badge)
// 2. 📦 מזווה - MyPantryScreen
// 3. 💡 תובנות - InsightsScreen
// 4. ⚙️ הגדרות - SettingsScreen
//
// **Dependencies:**
// - `AppLayout` - Bottom navigation wrapper
// - `ShoppingListsProvider` - מספר רשימות פעילות
//
// **Behavior:**
// - Back ← מטאב 1-4: חזרה לדשבורד (tab 0)
// - Back ← מדשבורד: double-tap ליציאה (2 שניות timeout)
// - SnackBar feedback: "לחץ שוב לסגירת האפליקציה"
//
// **Version:** 2.0 (PopScope + Logging)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:salsheli/core/ui_constants.dart';
import 'package:salsheli/layout/app_layout.dart';
import 'package:salsheli/models/shopping_list.dart';
import 'package:salsheli/providers/shopping_lists_provider.dart';

import 'package:salsheli/screens/home/home_dashboard_screen.dart';
import 'package:salsheli/screens/shopping/shopping_lists_screen.dart';
import 'package:salsheli/screens/pantry/my_pantry_screen.dart';
import 'package:salsheli/screens/insights/insights_screen.dart';
import 'package:salsheli/screens/settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  DateTime? _lastBackPress;

  final _pages = const <Widget>[
    HomeDashboardScreen(),
    ShoppingListsScreen(),
    MyPantryScreen(),
    InsightsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    
    debugPrint('🏠 HomeScreen: מעבר לטאב $_selectedIndex → $index');
    setState(() => _selectedIndex = index);
  }

  Future<bool> _onWillPop() async {
    // אם אנחנו לא בטאב הראשון — נחזור אליו במקום לצאת
    if (_selectedIndex != 0) {
      debugPrint('🏠 HomeScreen: Back מטאב $_selectedIndex → חזרה לדשבורד (0)');
      setState(() => _selectedIndex = 0);
      return false;
    }

    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > kDoubleTapTimeout) {
      _lastBackPress = now;
      debugPrint('🏠 HomeScreen: לחיצה ראשונה על Back - המתן ללחיצה שנייה');

      // הודעה למשתמש - לחץ שוב לסגירה
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'לחץ שוב לסגירת האפליקציה',
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
      }
      return false;
    }

    // לחיצה שניה בתוך 2 שניות — אשר יציאה
    debugPrint('🏠 HomeScreen: לחיצה שנייה על Back - יציאה מהאפליקציה');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // מספר רשימות פעילות (לבדג' בטאב "רשימות")
    final activeListsCount = context.select<ShoppingListsProvider, int>(
      (p) => p.lists.where((l) => l.status == ShoppingList.statusActive).length,
    );

    final badges = <int, int?>{
      1: activeListsCount > 0 ? activeListsCount : null,
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: AppLayout(
        currentIndex: _selectedIndex,
        onTabSelected: _onItemTapped,
        badges: badges,
        // אנימציית fade חלקה בין מסכים
        child: AnimatedSwitcher(
          duration: kAnimationDurationShort,
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          child: KeyedSubtree(
            key: ValueKey<int>(_selectedIndex),
            child: _pages[_selectedIndex],
          ),
        ),
      ),
    );
  }
}
