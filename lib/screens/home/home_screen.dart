// 📄 File: lib/screens/home/home_screen.dart
//
// 🇮🇱 מסך הבית הראשי:
// - ניווט תחתון: דשבורד, רשימות, מזווה, תובנות, הגדרות
// - יציאה בטוחה (לחיצה כפולה Back) עם הודעה למשתמש ✨
// - אנימציות fade חלקות בין מסכים ✨
// - בדג'ים לניווט תחתון (מספר רשימות פעילות)
// - עטיפה ב-AppLayout לאחידות UI

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    setState(() => _selectedIndex = index);
  }

  Future<bool> _onWillPop() async {
    // אם אנחנו לא בטאב הראשון — נחזור אליו במקום לצאת
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return false;
    }

    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;

      // ✨ הודעה למשתמש - לחץ שוב לסגירה
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'לחץ שוב לסגירת האפליקציה',
              textAlign: TextAlign.center,
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
      return false;
    }

    // לחיצה שניה בתוך 2 שניות — אשר יציאה
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

    return WillPopScope(
      onWillPop: _onWillPop,
      child: AppLayout(
        currentIndex: _selectedIndex,
        onTabSelected: _onItemTapped,
        badges: badges,
        // ✨ אנימציית fade חלקה בין מסכים
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
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
