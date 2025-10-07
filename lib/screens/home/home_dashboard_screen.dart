// 📄 File: lib/screens/home/home_dashboard_screen.dart
//
// 🇮🇱 **מסך דשבורד הבית** - Dashboard Screen
//
// **תכונות:**
// - Pull-to-Refresh (רשימות + הצעות)
// - מיון רשימות (תאריך/שם/סטטוס)
// - Empty state משופר עם אנימציה
// - כרטיסים: הקנייה הבאה, הצעות חכמות, קבלות, רשימות פעילות
// - Dismissible lists עם undo
//
// **Dependencies:**
// - `ShoppingListsProvider` - רשימות קניות
// - `SuggestionsProvider` - הצעות חכמות
// - `UserContext` - פרטי משתמש
// - `ReceiptProvider` - קבלות
// - `flutter_animate` - אנימציות
//
// **Material 3:**
// - צבעים רק דרך Theme/ColorScheme
// - RTL support מלא
// - Accessibility compliant
//
// **Version:** 2.1 (Constants Migration)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/shopping_list.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../providers/suggestions_provider.dart';
import '../../providers/user_context.dart';
import '../../providers/receipt_provider.dart';
import '../../widgets/home/upcoming_shop_card.dart';
import '../../widgets/home/smart_suggestions_card.dart';
import '../../widgets/create_list_dialog.dart';
import '../../theme/app_theme.dart';
import '../../core/ui_constants.dart';

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
    debugPrint('🏠 HomeDashboard: מתחיל refresh...');
    
    final lists = context.read<ShoppingListsProvider>();
    await lists.loadLists();
    debugPrint('   ✅ רשימות נטענו: ${lists.lists.length}');

    if (context.mounted) {
      try {
        final sugg = context.read<SuggestionsProvider>();
        await sugg.refresh();
        debugPrint('   ✅ הצעות נטענו: ${sugg.suggestions.length}');
      } catch (e) {
        debugPrint('   ⚠️ לא ניתן לטעון הצעות: $e');
      }
    }
    
    debugPrint('🏠 HomeDashboard: refresh הושלם');
  }

  List<ShoppingList> _sortLists(List<ShoppingList> lists) {
    debugPrint('🏠 HomeDashboard: ממיין ${lists.length} רשימות לפי ${_sortOption.label}');
    
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

    debugPrint('   ✅ מיון הושלם');
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
            padding: const EdgeInsets.all(kSpacingMedium),
            children: [
              _Header(userName: userContext.displayName),
              const SizedBox(height: kSpacingMedium),

              if (!listsProvider.isLoading && listsProvider.lists.isNotEmpty)
                _SortBar(
                  currentSort: _sortOption,
                  onSortChanged: (value) {
                    debugPrint('🏠 HomeDashboard: שינוי מיון ל-${value.label}');
                    setState(() => _sortOption = value);
                  },
                ),

              if (listsProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: kButtonHeight),
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
    debugPrint('🏠 HomeDashboard: פותח דיאלוג יצירת רשימה');
    
    final provider = context.read<ShoppingListsProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) => CreateListDialog(
        onCreateList: (listData) async {
          Navigator.of(dialogContext).pop();

          final name = listData['name'] as String?;
          final type = listData['type'] as String? ?? 'super';
          final budget = listData['budget'] as double?;
          final eventDate = listData['eventDate'] as DateTime?;

          debugPrint('🏠 HomeDashboard: יוצר רשימה "$name" (סוג: $type, תאריך: $eventDate)');

          if (name != null && name.trim().isNotEmpty) {
            try {
              await provider.createList(
                name: name, 
                type: type, 
                budget: budget,
                eventDate: eventDate,
              );
              debugPrint('   ✅ רשימה נוצרה בהצלחה');
            } catch (e) {
              debugPrint('   ❌ שגיאה ביצירת רשימה: $e');
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
      padding: const EdgeInsets.symmetric(
        horizontal: kSpacingMedium,
        vertical: kSpacingMedium + 2, // 18px
      ),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
        border: Border.all(color: cs.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: kSpacingLarge - 2, // 22px
            backgroundColor: (brand?.accent ?? cs.secondary).withValues(
              alpha: 0.18,
            ),
            child: Icon(
              Icons.home_outlined,
              color: brand?.accent ?? cs.secondary,
            ),
          ),
          const SizedBox(width: kBorderRadius),
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
      margin: const EdgeInsets.only(bottom: kSpacingMedium),
      padding: const EdgeInsets.symmetric(
        horizontal: kBorderRadius,
        vertical: kSpacingSmall,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Row(
        children: [
          Icon(Icons.sort, size: kIconSizeSmall + 4, color: accent), // 20px
          const SizedBox(width: kSpacingSmall),
          Text(
            'מיון:',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: kSpacingSmall),
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

  /// 🧠 חישוב דחיפות רשימה לפי 3 קריטריונים:
  /// 1. תאריך אירוע קרוב (100 נקודות אם בעוד פחות משבוע)
  /// 2. מלאי שנגמר (60 נקודות אם 3+ פריטים)
  /// 3. עדכון אחרון (20 נקודות אם עודכן היום)
  int _calculateListPriority(ShoppingList list) {
    int priority = 0;
    final now = DateTime.now();

    // 📅 קריטריון 1: תאריך אירוע
    if (list.eventDate != null) {
      final daysUntilEvent = list.eventDate!.difference(now).inDays;
      
      if (daysUntilEvent <= 7 && daysUntilEvent >= -1) {
        // שבוע לפני האירוע (או האירוע היה אתמול)
        priority += 100;
        debugPrint('   📅 "${list.name}": אירוע בעוד $daysUntilEvent ימים (+100)');
      } else if (daysUntilEvent <= 14 && daysUntilEvent > 7) {
        // שבועיים לפני האירוע
        priority += 50;
        debugPrint('   📅 "${list.name}": אירוע בעוד $daysUntilEvent ימים (+50)');
      }
    }

    // 🛒 קריטריון 2: מלאי שנגמר
    // TODO(v2.0): חיבור למערכת מלאי
    // final outOfStockCount = _checkInventoryForList(list);
    // if (outOfStockCount >= 3) priority += 60;
    // else if (outOfStockCount >= 1) priority += 30;

    // ⏰ קריטריון 3: עדכון אחרון
    final daysSinceUpdate = now.difference(list.updatedDate).inDays;
    if (daysSinceUpdate == 0) {
      priority += 20;
      debugPrint('   ⏰ "${list.name}": עודכן היום (+20)');
    } else if (daysSinceUpdate == 1) {
      priority += 10;
      debugPrint('   ⏰ "${list.name}": עודכן אתמול (+10)');
    }

    return priority;
  }

  @override
  Widget build(BuildContext context) {
    final activeLists = allLists
        .where((l) => l.status == ShoppingList.statusActive)
        .toList();

    // 🧠 מחשב דחיפות לכל רשימה וממיין
    debugPrint('🧠 מחשב דחיפות עבור ${activeLists.length} רשימות:');
    activeLists.sort((a, b) {
      final priorityA = _calculateListPriority(a);
      final priorityB = _calculateListPriority(b);
      debugPrint('   "${a.name}": $priorityA נקודות vs "${b.name}": $priorityB נקודות');
      return priorityB.compareTo(priorityA); // גבוה לנמוך
    });

    final mostRecentList = activeLists.isNotEmpty ? activeLists.first : null;
    if (mostRecentList != null) {
      final finalPriority = _calculateListPriority(mostRecentList);
      debugPrint('   ✅ הקנייה הקרובה: "${mostRecentList.name}" ($finalPriority נקודות)');
    }

    final otherLists = activeLists.length > 1
        ? activeLists.sublist(1)
        : const <ShoppingList>[];

    debugPrint('🏠 HomeDashboard._Content: רשימות פעילות=${activeLists.length}, אחרות=${otherLists.length}');

    return Column(
      children: [
        UpcomingShopCard(list: mostRecentList),
        const SizedBox(height: kSpacingMedium),
        SmartSuggestionsCard(mostRecentList: mostRecentList),
        const SizedBox(height: kSpacingMedium),
        const _ReceiptsCard(),
        const SizedBox(height: kSpacingMedium),
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
        padding: EdgeInsets.symmetric(
          vertical: kSpacingLarge * 2.67, // 64px
          horizontal: kSpacingXLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                  width: kSpacingXLarge * 3.75, // 120px
                  height: kSpacingXLarge * 3.75, // 120px
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: kSpacingLarge * 2.67, // 64px
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

            const SizedBox(height: kSpacingLarge),

            Text(
              "אין רשימות פעילות כרגע",
              style: t.headlineSmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: kBorderRadius),

            Text(
              "צור את הרשימה הראשונה שלך\nוהתחל לחסוך זמן וכסף!",
              style: t.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: kSpacingXLarge),

            FilledButton.icon(
              onPressed: onCreateList,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("צור רשימה ראשונה"),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: kSpacingXLarge,
                  vertical: kSpacingMedium,
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

class _ReceiptsCard extends StatelessWidget {
  const _ReceiptsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final receiptProvider = context.watch<ReceiptProvider>();

    final receiptsCount = receiptProvider.receipts.length;
    final totalAmount = receiptProvider.receipts.fold<double>(
      0.0,
      (sum, r) => sum + r.totalAmount,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
      ),
      child: InkWell(
        onTap: () {
          debugPrint('🏠 HomeDashboard: ניווט למסך קבלות');
          Navigator.pushNamed(context, '/receipts');
        },
        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(kSpacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(kSpacingSmall),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: Colors.orange,
                      size: kIconSizeSmall + 4, // 20px
                    ),
                  ),
                  const SizedBox(width: kBorderRadius),
                  Expanded(
                    child: Text(
                      'הקבלות שלי',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_left, color: cs.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: kBorderRadius),
              if (receiptProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(kSpacingMedium),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (receiptsCount == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: kSpacingSmall),
                  child: Text(
                    'אין קבלות עדיין. התחל להוסיף!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$receiptsCount קבלות',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          '₪${totalAmount.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: kSpacingSmall),
                    LinearProgressIndicator(
                      value: receiptsCount / 10,
                      backgroundColor: cs.surfaceContainerHighest,
                      color: Colors.orange,
                      minHeight: kBorderWidthThick * 2, // 4px
                      borderRadius: BorderRadius.circular(kBorderWidthThick),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 450.ms, delay: 200.ms).slideY(begin: 0.1);
  }
}

class _ActiveListsCard extends StatelessWidget {
  final List<ShoppingList> lists;

  const _ActiveListsCard({required this.lists});

  Future<void> _deleteList(
    BuildContext context,
    ShoppingList list,
  ) async {
    debugPrint('🏠 HomeDashboard: מוחק רשימה "${list.name}" (${list.id})');
    
    final provider = context.read<ShoppingListsProvider>();

    try {
      // שמירת כל הנתונים לפני מחיקה
      final deletedList = list;

      // מחיקה מיידית
      await provider.deleteList(list.id);
      debugPrint('   ✅ רשימה נמחקה');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('הרשימה "${deletedList.name}" נמחקה'),
            action: SnackBarAction(
              label: 'בטל',
              onPressed: () async {
                debugPrint('🏠 HomeDashboard: משחזר רשימה "${deletedList.name}"');
                await provider.restoreList(deletedList);
                debugPrint('   ✅ רשימה שוחזרה');
              },
            ),
            duration: kSnackBarDurationLong,
          ),
        );
      }
    } catch (e) {
      debugPrint('   ❌ שגיאה במחיקת רשימה: $e');
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(kSpacingSmall),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: accent,
                    size: kIconSizeSmall + 4, // 20px
                  ),
                ),
                const SizedBox(width: kBorderRadius),
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
                    debugPrint('🏠 HomeDashboard: ניווט לכל הרשימות');
                    Navigator.pushNamed(context, "/shopping-lists");
                  },
                  tooltip: 'כל הרשימות',
                ),
              ],
            ),
            const SizedBox(height: kSpacingMedium),
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
      padding: const EdgeInsets.only(bottom: kSpacingSmall),
      child: Dismissible(
        key: Key(list.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete(),
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: kIconSizeSmall + 4), // 20px
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(kBorderRadius - 2), // 10px
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.delete_outline, color: Colors.white),
              SizedBox(width: kSpacingSmall),
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
            borderRadius: BorderRadius.circular(kBorderRadius - 2), // 10px
            side: BorderSide(
              color: cs.outline.withValues(alpha: 0.2),
              width: kBorderWidth,
            ),
          ),
          child: InkWell(
            onTap: () {
              debugPrint('🏠 HomeDashboard: ניווט לרשימה "${list.name}"');
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
            borderRadius: BorderRadius.circular(kBorderRadius - 2), // 10px
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: kBorderRadius,
                vertical: kBorderRadius - 2, // 10px
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: kSpacingMedium - 2, // 14px
                    backgroundColor: cs.primary.withValues(alpha: 0.12),
                    child: Icon(
                      Icons.list_alt,
                      size: kIconSizeSmall,
                      color: cs.primary,
                    ),
                  ),
                  SizedBox(width: kBorderRadius - 2), // 10px
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
                        const SizedBox(height: kBorderWidthThick),
                        Text(
                          "$itemsCount פריטים",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: kSpacingSmall),
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
