// 📄 lib/screens/family/family_screen.dart
//
// מסך המשפחה - TabBar עם 3 טאבים: רשימות, מזווה, אישי.
// מאגד את כל התוכן המשפחתי במקום אחד.
//
// 🔗 Related: ShoppingListsScreen, MyPantryScreen

import 'package:flutter/material.dart';

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
    _tabController = TabController(length: 2, vsync: this);
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
              ],
            ),
          ),

          // === TabBarView ===
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                // Tab 1: רשימות
                _FamilyListsTab(),

                // Tab 2: מזווה
                MyPantryScreen(),
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

