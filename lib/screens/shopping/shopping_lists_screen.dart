// 📄 File: lib/screens/shopping/shopping_lists_screen.dart - V5.0 ACTIVE + HISTORY
//
// ✨ שיפורים חדשים (v5.0 - 24/10/2025):
// 1. 📋 הפרדה בין פעילות (🔵) להיסטוריה (✅)
// 2. 📊 פעילות למעלה, היסטוריה למטה
// 3. 📦 טעינת 10 שורות היסטוריה + "טען עוד"
// 4. 🎨 אייקונים שונים לפי סטטוס
//
// ✨ שיפורים קודמים (v4.0 - 17/10/2025):
// 1. 📝 המרה מלאה ל-Sticky Notes Design System
// 2. 🎨 NotebookBackground + kPaperBackground
// 3. 📋 כל הכרטיסים ב-StickyNote
// 4. 🔘 FAB → StickyButton מרחף
// 5. 🎨 Sticky Colors: Yellow/Pink/Green + rotation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../models/shopping_list.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_button.dart';
import '../../widgets/common/sticky_note.dart';
import '../../widgets/create_list_dialog.dart';
import '../../widgets/shopping_list_tile.dart';
import './active_shopping_screen.dart';

class ShoppingListsScreen extends StatefulWidget {
  const ShoppingListsScreen({super.key});

  @override
  State<ShoppingListsScreen> createState() => _ShoppingListsScreenState();
}

class _ShoppingListsScreenState extends State<ShoppingListsScreen> with SingleTickerProviderStateMixin {
  // 🔍 חיפוש וסינון
  String _searchQuery = '';
  String _selectedType = 'all'; // 'all' = הכל
  String _sortBy = 'date_desc'; // date_desc | date_asc | name | budget_desc | budget_asc

  // 📦 היסטוריה - pagination
  final int _historyPageSize = 10; // כמה רשימות היסטוריה להציג
  int _currentHistoryLimit = 10; // כמה רשימות להציג כרגע

  // 🎨 Animation Controllers
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    debugPrint('📋 ShoppingListsScreen.initState()');

    // FAB Animation Controller
    _fabController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
  }

  @override
  void dispose() {
    debugPrint('🗑️ ShoppingListsScreen.dispose()');
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShoppingListsProvider>();

    // ✅ טעינה ראשונית
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!provider.isLoading &&
          provider.lists.isEmpty &&
          provider.errorMessage == null &&
          provider.lastUpdated == null) {
        debugPrint('🔄 טוען רשימות ראשונית');
        provider.loadLists();
      }
    });

    return Scaffold(
      backgroundColor: kPaperBackground,
      appBar: AppBar(
        title: const Text('רשימות קניות'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "רענן",
            onPressed: () {
              debugPrint('🔄 רענון ידני');
              provider.loadLists();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, provider),
      body: Stack(
        children: [
          const NotebookBackground(),
          SafeArea(
            child: Column(
              children: [
                // 🔍 חיפוש וסינון
                _buildFiltersSection(),

                // 📋 תוכן
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      debugPrint('🔄 Pull to refresh');
                      await provider.loadLists();
                    },
                    child: _buildBody(context, provider),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: StickyButton(
          color: kStickyYellow,
          label: 'רשימה חדשה',
          icon: Icons.add,
          onPressed: () {
            debugPrint('➕ יצירת רשימה חדשה');
            _fabController.forward().then((_) => _fabController.reverse());
            _showCreateListDialog(context, provider);
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// 🔍 סעיף חיפוש וסינון
  Widget _buildFiltersSection() {
    return Padding(
      padding: const EdgeInsets.all(kSpacingMedium),
      child: StickyNote(
        color: kStickyCyan,
        rotation: -0.02,
        child: Column(
          children: [
            // 🔍 שורת חיפוש
            Consumer<ShoppingListsProvider>(
              builder: (context, provider, _) {
                final activeLists = _getFilteredAndSortedActiveLists(provider.lists);
                final completedLists = _getFilteredAndSortedCompletedLists(provider.lists);
                final filteredCount = activeLists.length + completedLists.length;
                final hasFilters = _searchQuery.isNotEmpty || _selectedType != 'all';

                return TextField(
                  decoration: InputDecoration(
                    hintText: 'חפש רשימה...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            iconSize: kIconSizeMedium,
                            constraints: const BoxConstraints(minWidth: kMinTouchTarget, minHeight: kMinTouchTarget),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    helperText: hasFilters && provider.lists.isNotEmpty ? 'נמצאו $filteredCount רשימות' : null,
                    helperStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kInputPadding),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                );
              },
            ),

            const SizedBox(height: kSpacingSmall),

            // 🏷️ סינון ומיון
            Row(
              children: [
                // סינון לפי סוג
                Expanded(child: _buildTypeFilter()),
                const SizedBox(width: kSpacingSmall),
                // מיון
                Expanded(child: _buildSortButton()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🏷️ Dropdown לסינון לפי סוג
  Widget _buildTypeFilter() {
    // 📋 Map של types עם אייקונים ושמות
    final listTypes = {
      ShoppingList.typeSupermarket: {'icon': '🛒', 'name': 'סופרמרקט'},
      ShoppingList.typePharmacy: {'icon': '💊', 'name': 'בית מרקחת'},
      ShoppingList.typeGreengrocer: {'icon': '🥬', 'name': 'ירקן'},
      ShoppingList.typeButcher: {'icon': '🥩', 'name': 'אטליז'},
      ShoppingList.typeBakery: {'icon': '🍞', 'name': 'מאפייה'},
      ShoppingList.typeMarket: {'icon': '🏪', 'name': 'שוק'},
      ShoppingList.typeHousehold: {'icon': '🏠', 'name': 'כלי בית'},
      ShoppingList.typeOther: {'icon': '➕', 'name': 'אחר'},
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedType,
          isExpanded: true,
          icon: const Icon(Icons.filter_list, size: kIconSizeMedium),
          items: [
            const DropdownMenuItem(value: 'all', child: Text('כל הסוגים')),
            ...listTypes.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Row(
                  children: [
                    Text(entry.value['icon']!),
                    const SizedBox(width: kSpacingSmall),
                    Text(entry.value['name']!),
                  ],
                ),
              );
            }),
          ],
          onChanged: (value) {
            if (value != null) {
              debugPrint('🏷️ סינון לפי: $value');
              setState(() => _selectedType = value);
            }
          },
        ),
      ),
    );
  }

  /// 📊 כפתור מיון
  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      child: Container(
        height: kMinTouchTarget,
        padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getSortIcon(), size: kIconSizeMedium),
            const SizedBox(width: kSpacingTiny),
            const Text('מיין'),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'date_desc',
          child: Row(
            children: [
              Icon(
                Icons.arrow_downward,
                size: kIconSizeSmall,
                color: _sortBy == 'date_desc' ? Theme.of(context).colorScheme.primary : null,
              ),
              const SizedBox(width: kSpacingSmall),
              Text(
                'תאריך (חדש→ישן)',
                style: TextStyle(fontWeight: _sortBy == 'date_desc' ? FontWeight.bold : FontWeight.normal),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'date_asc',
          child: Row(
            children: [
              Icon(
                Icons.arrow_upward,
                size: kIconSizeSmall,
                color: _sortBy == 'date_asc' ? Theme.of(context).colorScheme.primary : null,
              ),
              const SizedBox(width: kSpacingSmall),
              Text(
                'תאריך (ישן→חדש)',
                style: TextStyle(fontWeight: _sortBy == 'date_asc' ? FontWeight.bold : FontWeight.normal),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'name',
          child: Row(
            children: [
              Icon(
                Icons.sort_by_alpha,
                size: kIconSizeSmall,
                color: _sortBy == 'name' ? Theme.of(context).colorScheme.primary : null,
              ),
              const SizedBox(width: kSpacingSmall),
              Text('שם (א-ת)', style: TextStyle(fontWeight: _sortBy == 'name' ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'budget_desc',
          child: Row(
            children: [
              Icon(
                Icons.arrow_downward,
                size: kIconSizeSmall,
                color: _sortBy == 'budget_desc' ? Theme.of(context).colorScheme.primary : null,
              ),
              const SizedBox(width: kSpacingSmall),
              Text(
                'תקציב (גבוה→נמוך)',
                style: TextStyle(fontWeight: _sortBy == 'budget_desc' ? FontWeight.bold : FontWeight.normal),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'budget_asc',
          child: Row(
            children: [
              Icon(
                Icons.arrow_upward,
                size: kIconSizeSmall,
                color: _sortBy == 'budget_asc' ? Theme.of(context).colorScheme.primary : null,
              ),
              const SizedBox(width: kSpacingSmall),
              Text(
                'תקציב (נמוך→גבוה)',
                style: TextStyle(fontWeight: _sortBy == 'budget_asc' ? FontWeight.bold : FontWeight.normal),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        debugPrint('📊 מיון לפי: $value');
        setState(() => _sortBy = value);
      },
    );
  }

  /// קבלת אייקון לפי סוג המיון
  IconData _getSortIcon() {
    switch (_sortBy) {
      case 'date_desc':
      case 'budget_desc':
        return Icons.arrow_downward;
      case 'date_asc':
      case 'budget_asc':
        return Icons.arrow_upward;
      case 'name':
        return Icons.sort_by_alpha;
      default:
        return Icons.sort;
    }
  }

  /// 💀 Skeleton Box - קופסה מהבהבת
  Widget _buildSkeletonBox({required double width, required double height, BorderRadius? borderRadius}) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surfaceContainerHighest.withValues(alpha: 0.3),
            cs.surfaceContainerHighest.withValues(alpha: 0.1),
            cs.surfaceContainerHighest.withValues(alpha: 0.3),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(kBorderRadiusSmall),
      ),
    );
  }

  /// 💀 Skeleton של כרטיס רשימה
  Widget _buildListCardSkeleton() {
    // 🎨 צבעים לפתקים (rotation)
    final stickyColors = [kStickyYellow, kStickyPink, kStickyGreen];
    final stickyRotations = [0.01, -0.015, 0.01];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
      child: StickyNote(
        color: stickyColors[DateTime.now().millisecond % 3],
        rotation: stickyRotations[DateTime.now().millisecond % 3],
        child: Padding(
          padding: const EdgeInsets.all(kSpacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // אייקון
                  _buildSkeletonBox(width: 40, height: 40, borderRadius: BorderRadius.circular(20)),
                  const SizedBox(width: kSpacingMedium),
                  // כותרת
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSkeletonBox(width: double.infinity, height: 18),
                        const SizedBox(height: kSpacingSmall),
                        _buildSkeletonBox(width: 100, height: 14),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: kSpacingMedium),
              // סטטיסטיקות
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (int i = 0; i < 3; i++)
                    Column(
                      children: [
                        _buildSkeletonBox(width: 40, height: 12),
                        const SizedBox(height: kSpacingTiny),
                        _buildSkeletonBox(width: 50, height: 10),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 💀 Loading State - עם Skeleton Screens
  Widget _buildLoadingState() {
    debugPrint('⏳ _buildLoadingState()');

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: kSpacingSmall),
      itemCount: 5,
      itemBuilder: (context, index) => _buildListCardSkeleton(),
    );
  }

  /// 📌 מציג דיאלוג ליצירת רשימה חדשה
  void _showCreateListDialog(BuildContext context, ShoppingListsProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => CreateListDialog(
        onCreateList: (listData) async {
          debugPrint('🔵 shopping_lists_screen: קיבל נתונים מהדיאלוג');

          final name = listData['name'] as String?;
          final type = listData['type'] as String? ?? 'super';
          final budget = listData['budget'] as double?;

          debugPrint('   name: $name, type: $type, budget: $budget');

          if (name != null && name.isNotEmpty) {
            try {
              // שמירת navigator לפני async
              final navigator = Navigator.of(context);
              
              final newList = await provider.createList(name: name, type: type, budget: budget);

              debugPrint('   ✅ רשימה נוצרה: ${newList.id}');

              // ✅ סגור דיאלוג לפני ניווט
              if (mounted) {
                Navigator.of(dialogContext, rootNavigator: true).pop();
              }

              if (!mounted) {
                debugPrint('   ⚠️ widget לא mounted - מדלג על ניווט');
                return;
              }

              debugPrint('   ➡️ ניווט ל-populate-list');
              await navigator.pushNamed('/populate-list', arguments: newList);
            } catch (e) {
              debugPrint('   ❌ שגיאה ביצירת רשימה: $e');
              rethrow;
            }
          }
        },
      ),
    );
  }

  /// 📌 בונה את גוף המסך לפי מצב הטעינה / שגיאה / נתונים
  Widget _buildBody(BuildContext context, ShoppingListsProvider provider) {
    if (provider.isLoading) {
      return _buildLoadingState();
    }
    if (provider.errorMessage != null) {
      return _buildErrorState(provider);
    }

    // 🔍 סינון ומיון
    final activeLists = _getFilteredAndSortedActiveLists(provider.lists);
    final completedLists = _getFilteredAndSortedCompletedLists(provider.lists);

    if (activeLists.isEmpty && completedLists.isEmpty && provider.lists.isNotEmpty) {
      // יש רשימות אבל הסינון ריק
      return _buildEmptySearchResults();
    }

    if (activeLists.isEmpty && completedLists.isEmpty) {
      return _buildEmptyState(context, provider);
    }

    return _buildListsView(provider.lists);
  }

  /// 🔍 סינון ומיון רשימות פעילות
  List<ShoppingList> _getFilteredAndSortedActiveLists(List<ShoppingList> lists) {
    var filtered = lists.where((list) {
      // רק פעילות
      if (list.status != ShoppingList.statusActive) return false;

      // סינון לפי חיפוש
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!list.name.toLowerCase().contains(query)) {
          return false;
        }
      }

      // סינון לפי סוג
      if (_selectedType != 'all' && list.type != _selectedType) {
        return false;
      }

      return true;
    }).toList();

    // מיון
    _sortLists(filtered);
    return filtered;
  }

  /// 🔍 סינון ומיון רשימות היסטוריה
  List<ShoppingList> _getFilteredAndSortedCompletedLists(List<ShoppingList> lists) {
    var filtered = lists.where((list) {
      // רק הושלמו
      if (list.status != ShoppingList.statusCompleted) return false;

      // סינון לפי חיפוש
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!list.name.toLowerCase().contains(query)) {
          return false;
        }
      }

      // סינון לפי סוג
      if (_selectedType != 'all' && list.type != _selectedType) {
        return false;
      }

      return true;
    }).toList();

    // מיון (ברירת מחדל: תאריך יורד)
    filtered.sort((a, b) => b.updatedDate.compareTo(a.updatedDate));
    return filtered;
  }

  /// 📊 מיון כללי
  void _sortLists(List<ShoppingList> lists) {
    switch (_sortBy) {
      case 'date_desc':
        lists.sort((a, b) => b.createdDate.compareTo(a.createdDate));
        break;
      case 'date_asc':
        lists.sort((a, b) => a.createdDate.compareTo(b.createdDate));
        break;
      case 'name':
        lists.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'budget_desc':
        lists.sort((a, b) {
          final budgetA = a.budget ?? 0.0;
          final budgetB = b.budget ?? 0.0;
          return budgetB.compareTo(budgetA);
        });
        break;
      case 'budget_asc':
        lists.sort((a, b) {
          final budgetA = a.budget ?? 0.0;
          final budgetB = b.budget ?? 0.0;
          return budgetA.compareTo(budgetB);
        });
        break;
    }
  }

  /// 📌 מציג פעילות + היסטוריה
  Widget _buildListsView(List<ShoppingList> allLists) {
    // הפרד לפעילות והיסטוריה
    final activeLists = _getFilteredAndSortedActiveLists(allLists);
    final completedLists = _getFilteredAndSortedCompletedLists(allLists);
    
    // הגבל היסטוריה
    final limitedHistory = completedLists.take(_currentHistoryLimit).toList();
    final hasMoreHistory = completedLists.length > _currentHistoryLimit;

    return ListView(
      padding: const EdgeInsets.all(kSpacingMedium),
      children: [
        // 🔵 פעילות
        if (activeLists.isNotEmpty) ...[  
          _buildSectionHeader('🔵 רשימות פעילות', activeLists.length),
          const SizedBox(height: kSpacingSmall),
          ..._buildListCards(activeLists, isActive: true),
          const SizedBox(height: kSpacingLarge),
        ],

        // ✅ היסטוריה
        if (limitedHistory.isNotEmpty) ...[  
          _buildSectionHeader('✅ היסטוריה', completedLists.length),
          const SizedBox(height: kSpacingSmall),
          ..._buildListCards(limitedHistory, isActive: false),
          
          // כפתור "טען עוד"
          if (hasMoreHistory) ...[
            const SizedBox(height: kSpacingMedium),
            Center(
              child: StickyButtonSmall(
                color: kStickyCyan,
                label: 'טען עוד רשימות (${completedLists.length - _currentHistoryLimit} נותרו)',
                icon: Icons.expand_more,
                onPressed: () {
                  setState(() {
                    _currentHistoryLimit += _historyPageSize;
                  });
                },
              ),
            ),
          ],
        ],

        // אם אין כלום
        if (activeLists.isEmpty && completedLists.isEmpty)
          const SizedBox.shrink(),
      ],
    );
  }

  /// 🏷️ כותרת קטגוריה
  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: kFontSizeLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: kSpacingSmall),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: kSpacingSmall,
              vertical: kSpacingTiny,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: kFontSizeSmall,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📋 בונה כרטיסי רשימות
  List<Widget> _buildListCards(List<ShoppingList> lists, {required bool isActive}) {
    // 🎨 צבעים לפתקים
    final stickyColors = isActive 
        ? [kStickyYellow, kStickyPink, kStickyGreen]
        : [kStickyGreen.withValues(alpha: 0.7), kStickyCyan.withValues(alpha: 0.7)];
    final stickyRotations = [0.01, -0.015, 0.01];

    return lists.asMap().entries.map((entry) {
      final index = entry.key;
      final list = entry.value;
      final colorIndex = index % stickyColors.length;

      // אנימציית כניסה לכל כרטיס
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 300 + (index * 50)),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(offset: Offset(20 * (1 - value), 0), child: child),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: kSpacingMedium),
          child: StickyNote(
            color: stickyColors[colorIndex],
            rotation: stickyRotations[colorIndex],
            child: ShoppingListTile(
              list: list,
              onTap: () {
                debugPrint('📋 פתיחת רשימה: ${list.name}');
                Navigator.pushNamed(context, '/populate-list', arguments: list);
              },
              onDelete: () {
                debugPrint('🗑️ מחיקת רשימה: ${list.name}');
                final provider = context.read<ShoppingListsProvider>();
                provider.deleteList(list.id);
              },
              onRestore: (deletedList) {
                debugPrint('↩️ שחזור רשימה: ${deletedList.name}');
                final provider = context.read<ShoppingListsProvider>();
                provider.restoreList(deletedList);
              },
              onStartShopping: isActive ? () {
                debugPrint('🛒 התחלת קנייה: ${list.name}');
                Navigator.push(context, MaterialPageRoute(builder: (context) => ActiveShoppingScreen(list: list)));
              } : null, // היסטוריה - אין אפשרות קנייה
            ),
          ),
        ),
      );
    }).toList();
  }

  /// ❌ מצב שגיאה - משופר עם אנימציות
  Widget _buildErrorState(ShoppingListsProvider provider) {
    debugPrint('❌ _buildErrorState()');
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(kSpacingLarge),
                    decoration: BoxDecoration(color: cs.errorContainer.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: Icon(Icons.error_outline, size: kIconSizeXLarge, color: cs.error),
                  ),
                );
              },
            ),
            const SizedBox(height: kSpacingLarge),
            Text(
              "שגיאה בטעינת הרשימות",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: kSpacingSmall),
            Text(
              provider.errorMessage ?? 'משהו השתבש...',
              style: TextStyle(color: cs.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingLarge),
            StickyButton(
              color: kStickyPink,
              label: 'נסה שוב',
              icon: Icons.refresh,
              onPressed: () {
                debugPrint('🔄 retry - טוען מחדש');
                provider.loadLists();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 📭 תוצאות חיפוש ריקות - משופר עם אנימציות
  Widget _buildEmptySearchResults() {
    debugPrint('🔍 _buildEmptySearchResults()');
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Container(
                      padding: const EdgeInsets.all(kSpacingLarge),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            cs.surfaceContainerHighest.withValues(alpha: 0.3),
                            cs.surfaceContainerHighest.withValues(alpha: 0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.search_off, size: kIconSizeXLarge, color: cs.onSurfaceVariant),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: kSpacingLarge),
            const Text(
              "לא נמצאו רשימות",
              style: TextStyle(fontSize: kFontSizeLarge, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: kSpacingSmall),
            Text("נסה לשנות את החיפוש או הסינון", style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: kSpacingLarge),
            StickyButtonSmall(
              color: kStickyGreen,
              label: 'נקה סינון',
              icon: Icons.clear_all,
              onPressed: () {
                debugPrint('🧹 ניקוי סינון');
                setState(() {
                  _searchQuery = '';
                  _selectedType = 'all';
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 📋 מצב ריק – אין רשימות להצגה - משופר עם אנימציות
  Widget _buildEmptyState(BuildContext context, ShoppingListsProvider provider) {
    debugPrint('📭 _buildEmptyState()');
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Container(
                      padding: const EdgeInsets.all(kSpacingXLarge),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            cs.primaryContainer.withValues(alpha: 0.3),
                            cs.secondaryContainer.withValues(alpha: 0.2),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.shopping_bag_outlined, size: 120, color: cs.primary),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: kSpacingLarge),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Column(
                    children: [
                      Text(
                        "אין רשימות קניות",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: kSpacingSmall),
                      Text(
                        "לחץ על הכפתור מטה ליצירת",
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        "הרשימה הראשונה שלך!",
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: kSpacingXLarge),
            StickyButton(
              color: kStickyYellow,
              label: 'צור רשימה חדשה',
              icon: Icons.add,
              onPressed: () {
                debugPrint('➕ יצירת רשימה ראשונה');
                _showCreateListDialog(context, provider);
              },
            ),
            const SizedBox(height: kSpacingLarge),
            Text(
              "או סרוק קבלה במסך הקבלות",
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  /// 📂 Drawer עם קבוצות - משופר עם אנימציות
  Widget _buildDrawer(BuildContext context, ShoppingListsProvider provider) {
    final theme = Theme.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.7)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.shopping_basket, size: kIconSizeXLarge, color: theme.colorScheme.onPrimary),
                const SizedBox(height: kSpacingSmall),
                Text(
                  'סוגי רשימות',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // כל הרשימות
          _buildDrawerItem(
            context: context,
            title: 'כל הרשימות',
            icon: Icons.list,
            type: 'all',
            isSelected: _selectedType == 'all',
          ),

          const Divider(),

          // 🛒 סוגי רשימות (7 סוגים)
          _buildDrawerItem(
            context: context,
            title: 'סופרמרקט',
            icon: Icons.shopping_cart,
            type: 'supermarket',
            isSelected: _selectedType == 'supermarket',
          ),
          _buildDrawerItem(
            context: context,
            title: 'בית מרקחת',
            icon: Icons.medication,
            type: 'pharmacy',
            isSelected: _selectedType == 'pharmacy',
          ),
          _buildDrawerItem(
            context: context,
            title: 'ירקן',
            icon: Icons.local_florist,
            type: 'greengrocer',
            isSelected: _selectedType == 'greengrocer',
          ),
          _buildDrawerItem(
            context: context,
            title: 'אטליז',
            icon: Icons.set_meal,
            type: 'butcher',
            isSelected: _selectedType == 'butcher',
          ),
          _buildDrawerItem(
            context: context,
            title: 'מאפייה',
            icon: Icons.bakery_dining,
            type: 'bakery',
            isSelected: _selectedType == 'bakery',
          ),
          _buildDrawerItem(
            context: context,
            title: 'שוק',
            icon: Icons.store,
            type: 'market',
            isSelected: _selectedType == 'market',
          ),
          _buildDrawerItem(
            context: context,
            title: 'אחר',
            icon: Icons.more_horiz,
            type: 'household',
            isSelected: _selectedType == 'household',
          ),
        ],
      ),
    );
  }

  /// 📝 פריט בDrawer
  Widget _buildDrawerItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String type,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      minVerticalPadding: kSpacingSmall,
      leading: Icon(icon, color: isSelected ? theme.colorScheme.primary : null, size: kIconSizeMedium),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? theme.colorScheme.primary : null,
        ),
      ),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
      contentPadding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingTiny),
      onTap: () {
        debugPrint('🏷️ בחירת סוג: $type');
        setState(() {
          _selectedType = type;
        });
        Navigator.pop(context);
      },
    );
  }
}
