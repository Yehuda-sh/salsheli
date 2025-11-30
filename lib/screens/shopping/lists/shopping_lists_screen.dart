// 📄 File: lib/screens/shopping/lists/shopping_lists_screen.dart - V5.0 ACTIVE + HISTORY
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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../config/list_types_config.dart';
import '../../../core/ui_constants.dart';
import '../../../models/shopping_list.dart';
import '../../../providers/shopping_lists_provider.dart';
import '../../../widgets/common/notebook_background.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/sticky_button.dart';
import '../../../widgets/common/sticky_note.dart';
import '../../../widgets/shopping/shopping_list_tile.dart';
import '../active/active_shopping_screen.dart';

// 🔧 Wrapper ללוגים - פועל רק ב-debug mode
void _log(String message) {
  if (kDebugMode) {
    _log(message);
  }
}

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

  // 🔍 Search Controller
  final TextEditingController _searchController = TextEditingController();

  // 🔄 האם כבר ביקשנו טעינה ראשונית
  bool _initialLoadRequested = false;

  @override
  void initState() {
    super.initState();
    _log('📋 ShoppingListsScreen.initState()');

    // FAB Animation Controller
    _fabController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));

    // סנכרון search controller עם state
    _searchController.addListener(() {
      if (_searchQuery != _searchController.text) {
        setState(() => _searchQuery = _searchController.text);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ טעינה ראשונית - רק פעם אחת
    if (!_initialLoadRequested) {
      final provider = context.read<ShoppingListsProvider>();
      if (!provider.isLoading &&
          provider.lists.isEmpty &&
          provider.errorMessage == null &&
          provider.lastUpdated == null) {
        _log('🔄 טוען רשימות ראשונית');
        provider.loadLists();
      }
      _initialLoadRequested = true;
    }
  }

  @override
  void dispose() {
    _log('🗑️ ShoppingListsScreen.dispose()');
    _fabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShoppingListsProvider>();

    return Scaffold(
      backgroundColor: kPaperBackground,
      appBar: AppBar(
        title: const Text('רשימות קניות'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'רענן',
            onPressed: () {
              _log('🔄 רענון ידני');
              provider.loadLists();
            },
          ),
        ],
      ),
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
                      _log('🔄 Pull to refresh');
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
            _log('➕ יצירת רשימה חדשה');

            // ✨ Haptic feedback למשוב מישוש
            HapticFeedback.mediumImpact();

            _fabController.forward().then((_) => _fabController.reverse());
            Navigator.pushNamed(context, '/create-list');
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// 🔍 סעיף חיפוש וסינון - גרסה קומפקטית
  Widget _buildFiltersSection() {
    return Padding(
      padding: const EdgeInsets.all(kSpacingSmall),
      child: StickyNote(
        color: kStickyCyan,
        rotation: -0.015,
        child: Column(
          children: [
            // 🔍 שורת חיפוש קומפקטית
            Consumer<ShoppingListsProvider>(
              builder: (context, provider, _) {
                final activeLists = _getFilteredAndSortedActiveLists(provider.lists);
                final completedLists = _getFilteredAndSortedCompletedLists(provider.lists);
                final filteredCount = activeLists.length + completedLists.length;
                final hasFilters = _searchQuery.isNotEmpty || _selectedType != 'all';

                return TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: kFontSizeSmall),
                  decoration: InputDecoration(
                    hintText: 'חפש רשימה...',
                    hintStyle: const TextStyle(fontSize: kFontSizeSmall),
                    prefixIcon: const Icon(Icons.search, size: kIconSizeSmall),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: kIconSizeSmall),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            onPressed: _searchController.clear,
                          )
                        : null,
                    helperText: hasFilters && provider.lists.isNotEmpty ? 'נמצאו $filteredCount' : null,
                    helperStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: kFontSizeTiny,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(kBorderRadiusSmall)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingSmall),
                    isDense: true,
                  ),
                );
              },
            ),

            const SizedBox(height: kSpacingSmall),

            // 🏷️ סינון ומיון - שורה אחת קומפקטית
            Row(
              children: [
                // סינון לפי סוג
                Expanded(child: _buildCompactTypeFilter()),
                const SizedBox(width: kSpacingSmall),
                // מיון
                Expanded(child: _buildCompactSortButton()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🏷️ Dropdown קומפקטי לסינון לפי סוג
  Widget _buildCompactTypeFilter() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedType,
          isExpanded: true,
          isDense: true,
          icon: const Icon(Icons.filter_list, size: kIconSizeSmall),
          style: const TextStyle(fontSize: kFontSizeSmall, color: Colors.black87),
          items: [
            const DropdownMenuItem(value: 'all', child: Text('כל הסוגים')),
            ...ListTypes.all.map((typeConfig) {
              return DropdownMenuItem(
                value: typeConfig.key,
                child: Text('${typeConfig.emoji} ${typeConfig.shortName}'),
              );
            }),
          ],
          onChanged: (value) {
            if (value != null) {
              _log('🏷️ סינון לפי: $value');
              setState(() => _selectedType = value);
            }
          },
        ),
      ),
    );
  }

  /// 📊 כפתור מיון קומפקטי
  Widget _buildCompactSortButton() {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getSortIcon(), size: kIconSizeSmall),
            const SizedBox(width: kSpacingTiny),
            const Text('מיין', style: TextStyle(fontSize: kFontSizeSmall)),
          ],
        ),
      ),
      itemBuilder: (context) => [
        _buildCompactSortMenuItem('date_desc', 'חדש→ישן', Icons.arrow_downward),
        _buildCompactSortMenuItem('date_asc', 'ישן→חדש', Icons.arrow_upward),
        _buildCompactSortMenuItem('name', 'א-ת', Icons.sort_by_alpha),
        _buildCompactSortMenuItem('budget_desc', 'תקציב ↓', Icons.attach_money),
        _buildCompactSortMenuItem('budget_asc', 'תקציב ↑', Icons.money_off),
      ],
      onSelected: (value) {
        _log('📊 מיון לפי: $value');
        setState(() => _sortBy = value);
      },
    );
  }

  /// פריט תפריט מיון קומפקטי
  PopupMenuItem<String> _buildCompactSortMenuItem(String value, String label, IconData icon) {
    return PopupMenuItem(
      value: value,
      height: 36,
      child: Row(
        children: [
          Icon(
            icon,
            size: kIconSizeSmall,
            color: _sortBy == value ? Theme.of(context).colorScheme.primary : null,
          ),
          const SizedBox(width: kSpacingSmall),
          Text(
            label,
            style: TextStyle(
              fontSize: kFontSizeSmall,
              fontWeight: _sortBy == value ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
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

  /// 💀 Loading State - עם Skeleton Screens
  Widget _buildLoadingState() {
    _log('⏳ _buildLoadingState()');
    return const SkeletonListView.listCards();
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

  /// 🔍 סינון רשימות לפי סטטוס, חיפוש וסוג
  List<ShoppingList> _filterLists(List<ShoppingList> lists, String status) {
    final query = _searchQuery.toLowerCase();
    return lists.where((list) {
      if (list.status != status) return false;
      if (_searchQuery.isNotEmpty && !list.name.toLowerCase().contains(query)) return false;
      if (_selectedType != 'all' && list.type != _selectedType) return false;
      return true;
    }).toList();
  }

  /// 🔍 סינון ומיון רשימות פעילות
  List<ShoppingList> _getFilteredAndSortedActiveLists(List<ShoppingList> lists) {
    final filtered = _filterLists(lists, ShoppingList.statusActive);
    _sortLists(filtered);
    return filtered;
  }

  /// 🔍 סינון ומיון רשימות היסטוריה
  List<ShoppingList> _getFilteredAndSortedCompletedLists(List<ShoppingList> lists) {
    final filtered = _filterLists(lists, ShoppingList.statusCompleted);
    // מיון היסטוריה: תאריך עדכון יורד
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
                  // ✨ Haptic feedback למשוב מישוש
                  HapticFeedback.selectionClick();

                  setState(() {
                    _currentHistoryLimit += _historyPageSize;
                  });
                },
              ),
            ),
          ],
        ],

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

    // 🎬 הגבלת אנימציות - רק 5 פריטים ראשונים לביצועים טובים
    const maxAnimatedItems = 5;

    return lists.asMap().entries.map((entry) {
      final index = entry.key;
      final list = entry.value;
      final colorIndex = index % stickyColors.length;

      final cardWidget = Padding(
        padding: const EdgeInsets.only(bottom: kSpacingMedium),
        child: StickyNote(
          color: stickyColors[colorIndex],
          rotation: stickyRotations[colorIndex],
          child: ShoppingListTile(
            list: list,
            onTap: () {
              _log('📋 פתיחת רשימה: ${list.name}');
              Navigator.pushNamed(context, '/populate-list', arguments: list);
            },
            onDelete: () {
              _log('🗑️ מחיקת רשימה: ${list.name}');
              final provider = context.read<ShoppingListsProvider>();
              provider.deleteList(list.id);
            },
            onRestore: (deletedList) {
              _log('↩️ שחזור רשימה: ${deletedList.name}');
              final provider = context.read<ShoppingListsProvider>();
              provider.restoreList(deletedList);
            },
            onStartShopping: isActive ? () {
              _log('🛒 התחלת קנייה: ${list.name}');
              Navigator.push(context, MaterialPageRoute(builder: (context) => ActiveShoppingScreen(list: list)));
            } : null, // היסטוריה - אין אפשרות קנייה
            onEdit: () {
              _log('✏️ עריכת רשימה: ${list.name}');
              Navigator.pushNamed(context, '/populate-list', arguments: list);
            },
          ),
        ),
      );

      // 🎬 אנימציית כניסה רק לפריטים הראשונים
      if (index < maxAnimatedItems) {
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
          child: cardWidget,
        );
      }

      return cardWidget;
    }).toList();
  }

  /// ❌ מצב שגיאה - משופר עם אנימציות
  Widget _buildErrorState(ShoppingListsProvider provider) {
    _log('❌ _buildErrorState()');
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
              'שגיאה בטעינת הרשימות',
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
                _log('🔄 retry - טוען מחדש');

                // ✨ Haptic feedback למשוב מישוש
                HapticFeedback.lightImpact();

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
    _log('🔍 _buildEmptySearchResults()');
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
              'לא נמצאו רשימות',
              style: TextStyle(fontSize: kFontSizeLarge, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: kSpacingSmall),
            Text('נסה לשנות את החיפוש או הסינון', style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: kSpacingLarge),
            StickyButtonSmall(
              color: kStickyGreen,
              label: 'נקה סינון',
              icon: Icons.clear_all,
              onPressed: () {
                _log('🧹 ניקוי סינון');

                // ✨ Haptic feedback למשוב מישוש
                HapticFeedback.lightImpact();

                _searchController.clear();
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
    _log('📭 _buildEmptyState()');
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
                      'אין רשימות קניות',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: kSpacingSmall),
                      Text(
                        'לחץ על הכפתור מטה ליצירת',
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        'הרשימה הראשונה שלך!',
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
                _log('➕ יצירת רשימה ראשונה');

                // ✨ Haptic feedback למשוב מישוש
                HapticFeedback.mediumImpact();

                Navigator.pushNamed(context, '/create-list');
              },
            ),
            const SizedBox(height: kSpacingLarge),
            Text(
              'או סרוק קבלה במסך הקבלות',
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

}
