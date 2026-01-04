// 📄 File: lib/screens/shopping/lists/shopping_lists_screen.dart
//
// מסך רשימות קניות - עיצוב נקי עם תפריט שלוש נקודות.
// סינון/חיפוש/מיון נגישים דרך התפריט, לא תופסים מקום קבוע.
//
// Version: 6.0 - Clean UI with menu
// Updated: 01/01/2026

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../config/list_types_config.dart';
import '../../../core/ui_constants.dart';
import '../../../l10n/app_strings.dart';
import '../../../models/shopping_list.dart';
import '../../../providers/shopping_lists_provider.dart';
import '../../../widgets/common/notebook_background.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/sticky_button.dart';
import '../../../widgets/shopping/shopping_list_tile.dart';
import '../active/active_shopping_screen.dart';

class ShoppingListsScreen extends StatefulWidget {
  const ShoppingListsScreen({super.key});

  @override
  State<ShoppingListsScreen> createState() => _ShoppingListsScreenState();
}

class _ShoppingListsScreenState extends State<ShoppingListsScreen> {
  // 🔍 חיפוש וסינון
  String _searchQuery = '';
  String _selectedType = 'all';
  String _sortBy = 'date_desc';

  // 📦 היסטוריה - pagination
  static const int _historyPageSize = 10;
  int _currentHistoryLimit = 10;

  // 🔄 האם כבר ביקשנו טעינה ראשונית
  bool _initialLoadRequested = false;

  // 🎬 האם הטעינה הראשונית הושלמה (למניעת אנימציות בחיפוש)
  bool _isFirstLoadComplete = false;

  /// האם יש סינון/חיפוש פעיל
  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty || _selectedType != 'all' || _sortBy != 'date_desc';

  @override
  void initState() {
    super.initState();
    debugPrint('📋 ShoppingListsScreen.initState()');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ טעינה ראשונית - רק פעם אחת
    if (!_initialLoadRequested) {
      _initialLoadRequested = true;
      final provider = context.read<ShoppingListsProvider>();
      if (!provider.isLoading &&
          provider.lists.isEmpty &&
          provider.errorMessage == null &&
          provider.lastUpdated == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            debugPrint('🔄 טוען רשימות ראשונית');
            provider.loadLists();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShoppingListsProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const NotebookBackground(),
          SafeArea(
            child: Column(
              children: [
                // 🎛️ סרגל פעולות עליון - נקי
                _buildTopBar(),

                // 🏷️ פס סיכום סינון (מופיע רק אם יש סינון פעיל)
                if (_hasActiveFilters) _buildActiveFiltersStrip(),

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
      floatingActionButton: FloatingActionButton(
        heroTag: 'shopping_lists_add_btn',
        onPressed: () {
          debugPrint('➕ יצירת רשימה חדשה');
          HapticFeedback.mediumImpact();
          Navigator.pushNamed(context, '/create-list');
        },
        backgroundColor: kStickyYellow,
        tooltip: AppStrings.shopping.newListTooltip,
        child: const Icon(Icons.add, color: Colors.black87),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// 🎛️ סרגל עליון נקי - כפתור גלולה עם טקסט
  Widget _buildTopBar() {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingTiny),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 🎛️ כפתור כלים/סינון בסגנון גלולה
          PopupMenuButton<String>(
            tooltip: AppStrings.shopping.searchAndFilter,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadiusMedium),
            ),
            offset: const Offset(0, 40),
            itemBuilder: (context) => [
              _buildMenuItem(
                value: 'search',
                icon: Icons.search,
                label: AppStrings.shopping.searchMenuLabel,
                isActive: _searchQuery.isNotEmpty,
              ),
              _buildMenuItem(
                value: 'filter',
                icon: Icons.filter_list,
                label: AppStrings.shopping.filterByTypeLabel,
                isActive: _selectedType != 'all',
              ),
              _buildMenuItem(
                value: 'sort',
                icon: Icons.sort,
                label: AppStrings.shopping.sortLabel,
                subtitle: _getSortLabel(),
              ),
              if (_hasActiveFilters) ...[
                const PopupMenuDivider(),
                _buildMenuItem(
                  value: 'clear',
                  icon: Icons.clear_all,
                  label: AppStrings.shopping.clearFilterLabel,
                  isDestructive: true,
                ),
              ],
            ],
            onSelected: _handleMenuAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _hasActiveFilters
                    ? cs.primaryContainer
                    : Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _hasActiveFilters ? cs.primary : Colors.black12,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune,
                    size: 18,
                    color: _hasActiveFilters ? cs.primary : Colors.black54,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _hasActiveFilters ? AppStrings.shopping.filterActive : AppStrings.shopping.searchMenuLabel,
                    style: TextStyle(
                      fontSize: 13,
                      color: _hasActiveFilters ? cs.primary : Colors.black54,
                      fontWeight: _hasActiveFilters ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  // Badge נקודה כשיש סינון
                  if (_hasActiveFilters) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// בניית פריט תפריט
  PopupMenuItem<String> _buildMenuItem({
    required String value,
    required IconData icon,
    required String label,
    String? subtitle,
    bool isActive = false,
    bool isDestructive = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    final color = isDestructive
        ? cs.error
        : isActive
            ? cs.primary
            : Colors.black87;

    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: kSpacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (isActive)
            Icon(Icons.check_circle, size: 18, color: cs.primary),
        ],
      ),
    );
  }

  /// טיפול בבחירה מהתפריט
  void _handleMenuAction(String action) {
    HapticFeedback.selectionClick();

    switch (action) {
      case 'search':
        _showSearchSheet();
        break;
      case 'filter':
        _showFilterSheet();
        break;
      case 'sort':
        _showSortSheet();
        break;
      case 'clear':
        _clearAllFilters();
        break;
    }
  }

  /// 🔍 Bottom Sheet לחיפוש
  void _showSearchSheet() {
    final controller = TextEditingController(text: _searchQuery);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(kSpacingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // כותרת
              Row(
                children: [
                  const Icon(Icons.search, size: 24),
                  const SizedBox(width: kSpacingSmall),
                  Text(
                    AppStrings.shopping.searchListTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: kSpacingLarge),

              // שדה חיפוש
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: AppStrings.shopping.searchListHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: controller.clear,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(kBorderRadiusMedium),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                    _currentHistoryLimit = _historyPageSize; // 🔄 איפוס pagination
                  });
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: kSpacingLarge),

              // כפתורים
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.clear();
                        setState(() => _searchQuery = '');
                        Navigator.pop(context);
                      },
                      child: Text(AppStrings.shopping.clearButton),
                    ),
                  ),
                  const SizedBox(width: kSpacingMedium),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = controller.text.trim();
                          _currentHistoryLimit = _historyPageSize; // 🔄 איפוס pagination
                        });
                        Navigator.pop(context);
                      },
                      child: Text(AppStrings.shopping.searchButton),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: kSpacingSmall),
            ],
          ),
        ),
      ),
    );
  }

  /// 🏷️ Bottom Sheet לסינון לפי סוג
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // כותרת
            Row(
              children: [
                const Icon(Icons.filter_list, size: 24),
                const SizedBox(width: kSpacingSmall),
                Text(
                  AppStrings.shopping.filterByTypeTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: kSpacingLarge),

            // אפשרויות סינון
            Wrap(
              spacing: kSpacingSmall,
              runSpacing: kSpacingSmall,
              children: [
                _buildFilterChip('all', '📦', AppStrings.shopping.allTypesLabel),
                ...ListTypes.all.map((t) => _buildFilterChip(t.key, t.emoji, t.shortName)),
              ],
            ),
            const SizedBox(height: kSpacingLarge),
          ],
        ),
      ),
    );
  }

  /// צ'יפ סינון
  Widget _buildFilterChip(String key, String emoji, String name) {
    final isSelected = _selectedType == key;

    return FilterChip(
      showCheckmark: false,
      label: Text(
        '$emoji $name',
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedType = key;
          _currentHistoryLimit = _historyPageSize; // 🔄 איפוס pagination
        });
        Navigator.pop(context);
      },
      backgroundColor: Colors.white,
      selectedColor: kStickyCyan,
    );
  }

  /// 📊 Bottom Sheet למיון
  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // כותרת
            Row(
              children: [
                const Icon(Icons.sort, size: 24),
                const SizedBox(width: kSpacingSmall),
                Text(
                  AppStrings.shopping.sortTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: kSpacingMedium),

            // אפשרויות מיון
            _buildSortOption('date_desc', AppStrings.shopping.sortDateDesc, Icons.arrow_downward),
            _buildSortOption('date_asc', AppStrings.shopping.sortDateAsc, Icons.arrow_upward),
            _buildSortOption('name', AppStrings.shopping.sortNameAZ, Icons.sort_by_alpha),
            _buildSortOption('budget_desc', AppStrings.shopping.sortBudgetDesc, Icons.attach_money),
            _buildSortOption('budget_asc', AppStrings.shopping.sortBudgetAsc, Icons.money_off),

            const SizedBox(height: kSpacingSmall),
          ],
        ),
      ),
    );
  }

  /// אפשרות מיון
  Widget _buildSortOption(String value, String label, IconData icon) {
    final isSelected = _sortBy == value;
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? cs.primary : Colors.black54,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? cs.primary : Colors.black87,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: cs.primary) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      ),
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _sortBy = value;
          _currentHistoryLimit = _historyPageSize; // 🔄 איפוס pagination
        });
        Navigator.pop(context);
      },
    );
  }

  /// 🧹 ניקוי כל הסינונים
  void _clearAllFilters() {
    HapticFeedback.lightImpact();
    setState(() {
      _searchQuery = '';
      _selectedType = 'all';
      _sortBy = 'date_desc';
      _currentHistoryLimit = _historyPageSize; // 🔄 איפוס pagination
    });
  }

  /// 🏷️ פס סיכום סינון פעיל
  Widget _buildActiveFiltersStrip() {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
      padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(kBorderRadiusMedium),
      ),
      child: Row(
        children: [
          // אייקון סינון
          Icon(Icons.filter_alt, size: 16, color: cs.primary),
          const SizedBox(width: kSpacingSmall),

          // תגיות סינון (לחיצות לפתיחת Sheet)
          Expanded(
            child: Wrap(
              spacing: kSpacingSmall,
              children: [
                if (_searchQuery.isNotEmpty)
                  _buildFilterTag('🔍 "$_searchQuery"', onTap: _showSearchSheet),
                if (_selectedType != 'all')
                  _buildFilterTag('🏷️ ${_getTypeLabel(_selectedType)}', onTap: _showFilterSheet),
                if (_sortBy != 'date_desc')
                  _buildFilterTag('📊 ${_getSortLabel()}', onTap: _showSortSheet),
              ],
            ),
          ),

          // כפתור ניקוי
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: _clearAllFilters,
            tooltip: AppStrings.shopping.clearFilterLabel,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  /// תגית סינון בודדת (לחיצה פותחת את ה-Sheet המתאים)
  Widget _buildFilterTag(String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 2),
              const Icon(Icons.edit, size: 10, color: Colors.black45),
            ],
          ],
        ),
      ),
    );
  }

  /// קבלת תווית סוג
  String _getTypeLabel(String type) {
    if (type == 'all') return AppStrings.shopping.allTypesLabel;
    final listType = ListTypes.all.where((t) => t.key == type).firstOrNull;
    return listType?.shortName ?? type;
  }

  /// קבלת תווית מיון
  String _getSortLabel() {
    switch (_sortBy) {
      case 'date_desc':
        return AppStrings.shopping.sortLabelNew;
      case 'date_asc':
        return AppStrings.shopping.sortLabelOld;
      case 'name':
        return AppStrings.shopping.sortLabelAZ;
      case 'budget_desc':
        return '₪↓';
      case 'budget_asc':
        return '₪↑';
      default:
        return AppStrings.shopping.sortLabel;
    }
  }

  /// 💀 Loading State - עם Skeleton Screens
  Widget _buildLoadingState() {
    debugPrint('⏳ _buildLoadingState()');
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

    // 🎬 סימון שהטעינה הראשונית הושלמה (למניעת אנימציות בחיפוש)
    // 🔧 FIX: סימון גם אם אין רשימות - אחרת אנימציות ימשיכו לרוץ
    if (!_isFirstLoadComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isFirstLoadComplete = true);
      });
    }

    // 🔍 סינון ומיון
    final activeLists = _getFilteredAndSortedActiveLists(provider.lists);
    final completedLists = _getFilteredAndSortedCompletedLists(provider.lists);

    if (activeLists.isEmpty && completedLists.isEmpty && provider.lists.isNotEmpty) {
      // יש רשימות אבל הסינון ריק
      return _buildEmptySearchResults();
    }

    if (activeLists.isEmpty && completedLists.isEmpty) {
      return _buildEmptyState();
    }

    return _buildListsView(activeLists, completedLists);
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
  Widget _buildListsView(List<ShoppingList> activeLists, List<ShoppingList> completedLists) {
    // 🔧 FIX: כשיש סינון פעיל - הצג את כל ההיסטוריה (בלי pagination)
    // כדי שהמשתמש יראה את כל התוצאות שמתאימות לחיפוש
    final showAllHistory = _hasActiveFilters;
    final limitedHistory = showAllHistory
        ? completedLists
        : completedLists.take(_currentHistoryLimit).toList();
    final hasMoreHistory = !showAllHistory && completedLists.length > _currentHistoryLimit;

    return ListView(
      // 📏 Padding מתואם לקווי המחברת (48px בין קווים)
      // 20px למעלה כדי שהכותרת תהיה בין הקווים
      padding: const EdgeInsets.fromLTRB(kSpacingMedium, 20, kSpacingMedium, 80),
      children: [
        // 🔵 פעילות
        if (activeLists.isNotEmpty) ...[
          _buildSectionHeader(AppStrings.shopping.activeLists, activeLists.length),
          const SizedBox(height: kSpacingMedium),
          ..._buildListCards(activeLists, isActive: true),
          const SizedBox(height: kSpacingLarge),
        ],

        // ✅ היסטוריה
        if (limitedHistory.isNotEmpty) ...[
          // 🔧 FIX: הוספת הערה שההיסטוריה ממוינת לפי עדכון אחרון
          _buildSectionHeader(
            AppStrings.shopping.historyLists,
            completedLists.length,
            subtitle: AppStrings.shopping.historyListsNote,
            isActive: false, // 🔧 FIX: צבע ירוק להיסטוריה
          ),
          const SizedBox(height: kSpacingSmall),
          ..._buildListCards(limitedHistory, isActive: false),

          // כפתור "טען עוד" - רק אם לא בסינון
          if (hasMoreHistory) ...[
            const SizedBox(height: kSpacingMedium),
            Center(
              child: StickyButtonSmall(
                color: kStickyCyan,
                label: AppStrings.shopping.loadMoreLists(completedLists.length - _currentHistoryLimit),
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

  /// 🏷️ כותרת קטגוריה - סגנון highlighter על מחברת
  /// 🔧 FIX: הוספת פרמטרים subtitle ו-isActive (במקום title.contains שנשבר עם AppStrings)
  Widget _buildSectionHeader(String title, int count, {String? subtitle, bool isActive = true}) {
    final cs = Theme.of(context).colorScheme;

    // 🔧 FIX: צבע highlighter לפי פרמטר isActive (לא לפי תוכן הכותרת!)
    final highlightColor = isActive
        ? kStickyCyan.withValues(alpha: kHighlightOpacity)
        : kStickyGreen.withValues(alpha: kHighlightOpacity);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
      child: Row(
        children: [
          // כותרת עם אפקט highlighter
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: kSpacingSmall,
              vertical: kSpacingXTiny,
            ),
            decoration: BoxDecoration(
              color: highlightColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: kFontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // הערה קטנה (למשל: "לפי עדכון אחרון")
          if (subtitle != null) ...[
            const SizedBox(width: kSpacingTiny),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: kFontSizeSmall,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(width: kSpacingSmall),
          // מונה פריטים
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: kSpacingSmall,
              vertical: kSpacingXTiny,
            ),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: kFontSizeSmall,
                fontWeight: FontWeight.bold,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📋 בונה כרטיסי רשימות
  List<Widget> _buildListCards(List<ShoppingList> lists, {required bool isActive}) {
    // 🎬 הגבלת אנימציות - רק 5 פריטים ראשונים לביצועים טובים
    // ⚠️ לא מפעילים אנימציות אחרי הטעינה הראשונית (חיפוש/סינון)
    const maxAnimatedItems = 5;
    final shouldAnimate = !_isFirstLoadComplete;

    return lists.asMap().entries.map((entry) {
      final index = entry.key;
      final list = entry.value;

      final cardWidget = Padding(
        key: ValueKey(list.id), // 🔑 Key ייחודי למניעת בנייה מחדש מיותרת
        padding: const EdgeInsets.only(bottom: kSpacingSmall),
        child: ShoppingListTile(
          list: list,
          onTap: () {
            debugPrint('📋 פתיחת רשימה: ${list.name}');
            Navigator.pushNamed(context, '/populate-list', arguments: list);
          },
          onDelete: () async {
            debugPrint('🗑️ מחיקת רשימה: ${list.name}');
            final provider = context.read<ShoppingListsProvider>();
            await provider.deleteList(list.id);
          },
          onRestore: (deletedList) async {
            debugPrint('↩️ שחזור רשימה: ${deletedList.name}');
            final provider = context.read<ShoppingListsProvider>();
            await provider.restoreList(deletedList);
          },
          onStartShopping: isActive
              ? () {
                  debugPrint('🛒 התחלת קנייה: ${list.name}');
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => ActiveShoppingScreen(list: list)));
                }
              : null,
          onEdit: () {
            debugPrint('✏️ עריכת רשימה: ${list.name}');
            Navigator.pushNamed(context, '/populate-list', arguments: list);
          },
        ),
      );

      // 🎬 אנימציית כניסה רק בטעינה ראשונית, ורק לפריטים הראשונים
      if (shouldAnimate && index < maxAnimatedItems) {
        return TweenAnimationBuilder<double>(
          key: ValueKey('anim_${list.id}'),
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
  /// ⚠️ עטוף ב-SingleChildScrollView לתמיכה ב-Pull-to-Refresh
  Widget _buildErrorState(ShoppingListsProvider provider) {
    debugPrint('❌ _buildErrorState()');
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
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
              AppStrings.shopping.loadingListsError,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: kSpacingSmall),
            Text(
              provider.errorMessage ?? AppStrings.shopping.somethingWentWrong,
              style: TextStyle(color: cs.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingLarge),
            StickyButton(
              color: kStickyPink,
              label: AppStrings.shopping.tryAgainButton,
              icon: Icons.refresh,
              onPressed: () {
                debugPrint('🔄 retry - טוען מחדש');

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
  /// ⚠️ עטוף ב-SingleChildScrollView לתמיכה ב-Pull-to-Refresh
  Widget _buildEmptySearchResults() {
    debugPrint('🔍 _buildEmptySearchResults()');
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
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
            Text(
              AppStrings.shopping.noListsFoundTitle,
              style: const TextStyle(fontSize: kFontSizeLarge, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: kSpacingSmall),
            Text(AppStrings.shopping.noListsFoundSubtitle, style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: kSpacingLarge),
            StickyButtonSmall(
              color: kStickyGreen,
              label: AppStrings.shopping.clearFilterLabel,
              icon: Icons.clear_all,
              onPressed: _clearAllFilters,
            ),
          ],
        ),
      ),
    );
  }

  /// 📋 מצב ריק – אין רשימות להצגה
  Widget _buildEmptyState() {
    debugPrint('📭 _buildEmptyState()');
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
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
                            cs.primaryContainer.withValues(alpha: 0.3),
                            cs.secondaryContainer.withValues(alpha: 0.2),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.shopping_bag_outlined, size: 80, color: cs.primary),
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
                        AppStrings.shopping.noListsTitle,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: kSpacingSmall),
                      Text(
                        AppStrings.shopping.noListsSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: kSpacingXLarge),
            StickyButton(
              color: kStickyYellow,
              label: AppStrings.shopping.createNewListButton,
              icon: Icons.add,
              onPressed: () {
                debugPrint('➕ יצירת רשימה ראשונה');

                // ✨ Haptic feedback למשוב מישוש
                HapticFeedback.mediumImpact();

                Navigator.pushNamed(context, '/create-list');
              },
            ),
            const SizedBox(height: kSpacingLarge),
            Text(
              AppStrings.shopping.orScanReceiptHint,
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
