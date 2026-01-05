// 📄 lib/screens/family/family_screen.dart
//
// מסך המשפחה - TabBar עם 3 טאבים: רשימות, מזווה, אישי.
// מאגד את כל התוכן המשפחתי במקום אחד.
//
// 🔗 Related: ShoppingListsScreen, MyPantryScreen

import 'package:flutter/material.dart';

import '../../core/ui_constants.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_button.dart';
import '../../widgets/common/sticky_note.dart';
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
/// ✅ עיצוב StickyNote - תואם למסכי אימות
class _PersonalListsTab extends StatelessWidget {
  const _PersonalListsTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();

    // TODO: להוסיף לוגיקה לסינון רשימות אישיות בלבד
    // כרגע מציג placeholder בעיצוב StickyNote על רקע מחברת
    return Stack(
      fit: StackFit.expand,
      children: [
        // 📓 רקע מחברת עם קווים (כמו מסכי אימות)
        const Positioned.fill(
          child: NotebookBackground(),
        ),

        // 📝 תוכן
        Center(
          child: Padding(
            padding: const EdgeInsets.all(kSpacingLarge),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: StickyNote(
                color: brand?.stickyYellow ?? kStickyYellow,
                rotation: -0.015,
                semanticLabel: 'רשימות אישיות - בקרוב',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 56,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: kSpacingSmall),
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
                        fontSize: kFontSizeMedium,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: kSpacingMedium),
                    StickyButton(
                      color: brand?.stickyGreen ?? kStickyGreen,
                      label: 'רשימה חדשה',
                      icon: Icons.add,
                      onPressed: () {
                        // TODO: יצירת רשימה אישית חדשה
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('יצירת רשימה אישית - בקרוב!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
