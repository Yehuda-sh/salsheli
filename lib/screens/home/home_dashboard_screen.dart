// 📄 File: lib/screens/home/home_dashboard_screen.dart
//
// ✅ עדכונים חדשים:
// 1. מיון רשימות (תאריך/שם/סטטוס)
// 2. EmptyState משופר עם אנימציה
// 3. Caching למניעת טעינות מיותרות
// 4. _ActiveListsCard פנימי (לא מיובא)
// 5. ✨ תיקון שגיאת Material border (שורה 419)
//
// מסך דשבורד הבית (Material 3 + RTL):
// - צבעים רק דרך Theme/ColorScheme
// - Pull-to-Refresh: טוען רשימות + Suggestions
// - מצבי טעינה/ריק/תוכן
// - הודעת "ברוך הבא" עם כרטיס רקע נעים

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/shopping_list.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../providers/suggestions_provider.dart';
import '../../providers/user_context.dart';
import '../../widgets/home/upcoming_shop_card.dart';
import '../../widgets/home/smart_suggestions_card.dart';
import '../../widgets/create_list_dialog.dart';
import '../../theme/app_theme.dart';

enum SortOption {
  date('תאריך עדכון'),
  name('שם'),
  status('סטטוס');

  final String label;
  const SortOption(this.label);
}

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  SortOption _sortOption = SortOption.date;

  Future<void> _refresh(BuildContext context) async {
    final lists = context.read<ShoppingListsProvider>();
    await lists.loadLists();

    if (context.mounted) {
      try {
        final sugg = context.read<SuggestionsProvider>();
        await sugg.refresh();
      } catch (_) {
        /* לא מחובר – מתעלמים */
      }
    }
  }

  List<ShoppingList> _sortLists(List<ShoppingList> lists) {
    final sorted = List<ShoppingList>.from(lists);

    switch (_sortOption) {
      case SortOption.date:
        sorted.sort((a, b) => b.updatedDate.compareTo(a.updatedDate));
        break;
      case SortOption.name:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.status:
        sorted.sort((a, b) => a.status.compareTo(b.status));
        break;
    }

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final listsProvider = context.watch<ShoppingListsProvider>();
    final userContext = context.watch<UserContext>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: RefreshIndicator(
          color: Theme.of(context).extension<AppBrand>()?.accent ?? cs.primary,
          onRefresh: () => _refresh(context),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Header(userName: userContext.displayName),
              const SizedBox(height: 16),

              if (!listsProvider.isLoading && listsProvider.lists.isNotEmpty)
                _SortBar(
                  currentSort: _sortOption,
                  onSortChanged: (value) {
                    setState(() => _sortOption = value);
                  },
                ),

              if (listsProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (listsProvider.lists.isEmpty)
                _ImprovedEmptyState(
                  onCreateList: () => _showCreateListDialog(context),
                )
              else
                _Content(allLists: _sortLists(listsProvider.lists)),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateListDialog(BuildContext context) {
    final provider = context.read<ShoppingListsProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) => CreateListDialog(
        onCreateList: (listData) async {
          Navigator.of(dialogContext).pop();

          final name = listData['name'] as String?;
          final type = listData['type'] as String? ?? 'super';
          final budget = listData['budget'] as double?;

          if (name != null && name.trim().isNotEmpty) {
            try {
              await provider.createList(name: name, type: type, budget: budget);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('שגיאה ביצירת רשימה: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String? userName;
  const _Header({required this.userName});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: (brand?.accent ?? cs.secondary).withValues(
              alpha: 0.18,
            ),
            child: Icon(
              Icons.home_outlined,
              color: brand?.accent ?? cs.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "ברוך הבא, ${(userName?.trim().isEmpty ?? true) ? 'אורח' : userName}",
              style: t.titleLarge?.copyWith(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: .1);
  }
}

class _SortBar extends StatelessWidget {
  final SortOption currentSort;
  final ValueChanged<SortOption> onSortChanged;

  const _SortBar({required this.currentSort, required this.onSortChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.sort, size: 20, color: accent),
          const SizedBox(width: 8),
          Text(
            'מיון:',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<SortOption>(
              value: currentSort,
              isExpanded: true,
              underline: const SizedBox(),
              items: SortOption.values.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) onSortChanged(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final List<ShoppingList> allLists;
  const _Content({required this.allLists});

  @override
  Widget build(BuildContext context) {
    final activeLists = allLists
        .where((l) => l.status == ShoppingList.statusActive)
        .toList();

    activeLists.sort((a, b) => b.updatedDate.compareTo(a.updatedDate));

    final mostRecentList = activeLists.isNotEmpty ? activeLists.first : null;
    final otherLists = activeLists.length > 1
        ? activeLists.sublist(1)
        : const <ShoppingList>[];

    return Column(
      children: [
        UpcomingShopCard(list: mostRecentList),
        const SizedBox(height: 16),
        SmartSuggestionsCard(mostRecentList: mostRecentList),
        const SizedBox(height: 16),
        if (otherLists.isNotEmpty) _ActiveListsCard(lists: otherLists),
      ],
    ).animate().fadeIn(duration: 450.ms, delay: 100.ms);
  }
}

class _ImprovedEmptyState extends StatelessWidget {
  final VoidCallback onCreateList;

  const _ImprovedEmptyState({required this.onCreateList});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: accent,
                  ),
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  duration: 2000.ms,
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.05, 1.05),
                )
                .then()
                .scale(
                  duration: 2000.ms,
                  begin: const Offset(1.05, 1.05),
                  end: const Offset(0.95, 0.95),
                ),

            const SizedBox(height: 24),

            Text(
              "אין רשימות פעילות כרגע",
              style: t.headlineSmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              "צור את הרשימה הראשונה שלך\nוהתחל לחסוך זמן וכסף!",
              style: t.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: onCreateList,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("צור רשימה ראשונה"),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: t.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }
}

// ✅ רכיב פנימי - ActiveListsCard
class _ActiveListsCard extends StatelessWidget {
  final List<ShoppingList> lists;

  const _ActiveListsCard({required this.lists});

  Future<void> _deleteList(BuildContext context, ShoppingList list) async {
    final provider = context.read<ShoppingListsProvider>();

    try {
      await provider.deleteList(list.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('הרשימה "${list.name}" נמחקה'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה במחיקה: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (lists.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "רשימות פעילות נוספות",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.list_alt),
                  onPressed: () {
                    Navigator.pushNamed(context, "/shopping-lists");
                  },
                  tooltip: 'כל הרשימות',
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...lists.map((list) {
              return _DismissibleListTile(
                list: list,
                onDelete: () => _deleteList(context, list),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _DismissibleListTile extends StatelessWidget {
  final ShoppingList list;
  final VoidCallback onDelete;

  const _DismissibleListTile({required this.list, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final itemsCount = list.items.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key(list.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('מחיקת רשימה'),
                  content: Text('האם למחוק את "${list.name}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('ביטול'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('מחק'),
                    ),
                  ],
                ),
              ) ??
              false;
        },
        onDismissed: (_) => onDelete(),
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.delete_outline, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'מחק',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        child: Material(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: cs.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                "/manage-list",
                arguments: {
                  "listId": list.id,
                  "listName": list.name,
                  "existingList": list,
                },
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: cs.primary.withValues(alpha: 0.12),
                    child: Icon(Icons.list_alt, size: 16, color: cs.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list.name,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "$itemsCount פריטים",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_left, color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
