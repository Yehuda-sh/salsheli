// 📄 File: lib/screens/family/family_screen.dart
//
// 🎯 Purpose: מסך המשפחה - TabBar עם 3 טאבים פנימיים
//
// 📋 Tabs:
// - 📝 רשימות - רשימות קניות משפחתיות
// - 📦 מזווה - מזווה משותף
// - 👤 אישי - רשימות אישיות
//
// 🔗 Dependencies:
// - ShoppingListsScreen
// - MyPantryScreen
// - Personal lists (filtered from ShoppingListsScreen)
//
// Version: 1.0
// Created: 16/12/2025

import 'package:flutter/material.dart';

import '../../core/ui_constants.dart';
import '../pantry/my_pantry_screen.dart';
import '../shopping/lists/shopping_lists_screen.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    debugPrint('👨‍👩‍👧‍👦 FamilyScreen: initState');
  }

  @override
  void dispose() {
    _tabController.dispose();
    debugPrint('👨‍👩‍👧‍👦 FamilyScreen: dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          // === TabBar ===
          Container(
            color: cs.surfaceContainer,
            child: TabBar(
              controller: _tabController,
              labelColor: cs.primary,
              unselectedLabelColor: cs.onSurfaceVariant,
              indicatorColor: cs.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(
                  icon: Icon(Icons.shopping_cart),
                  text: 'רשימות',
                ),
                Tab(
                  icon: Icon(Icons.inventory),
                  text: 'מזווה',
                ),
                Tab(
                  icon: Icon(Icons.person),
                  text: 'אישי',
                ),
              ],
            ),
          ),

          // === TabBarView ===
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                // Tab 1: רשימות משפחתיות
                _FamilyListsTab(),

                // Tab 2: מזווה משותף
                MyPantryScreen(),

                // Tab 3: רשימות אישיות
                _PersonalListsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 📝 Tab: רשימות משפחתיות
/// מציג רשימות קניות משותפות במשפחה
class _FamilyListsTab extends StatelessWidget {
  const _FamilyListsTab();

  @override
  Widget build(BuildContext context) {
    // ShoppingListsScreen כבר מסננת לפי household
    return const ShoppingListsScreen();
  }
}

/// 👤 Tab: רשימות אישיות
/// מציג רשימות אישיות של המשתמש בלבד
class _PersonalListsTab extends StatelessWidget {
  const _PersonalListsTab();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // TODO: להוסיף לוגיקה לסינון רשימות אישיות בלבד
    // כרגע מציג placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 64,
            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: kSpacingMedium),
          Text(
            'רשימות אישיות',
            style: TextStyle(
              fontSize: kFontSizeLarge,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            'כאן יופיעו הרשימות הפרטיות שלך',
            style: TextStyle(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: kSpacingLarge),
          FilledButton.icon(
            onPressed: () {
              // TODO: יצירת רשימה אישית חדשה
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('יצירת רשימה אישית - בקרוב!')),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('רשימה חדשה'),
          ),
        ],
      ),
    );
  }
}
