// lib/screens/shopping/lists/shopping_lists_screen.dart — Shopping lists — all lists with search, sort, menu delete (owner-only), create FAB

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/ui_constants.dart';
import '../../../l10n/app_strings.dart';
import '../../../models/shopping_list.dart';
import '../../../providers/shopping_lists_provider.dart';
import '../../../providers/user_context.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/notebook_background.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/sticky_button.dart';
import '../../../widgets/shopping/shopping_list_tile.dart';
import '../active/active_shopping_screen.dart';

// Empty-state illustration diameter (sits inside the gradient circle).
const double _kEmptyIllustrationSize = 160.0;

class ShoppingListsScreen extends StatefulWidget {
  const ShoppingListsScreen({super.key});

  @override
  State<ShoppingListsScreen> createState() => _ShoppingListsScreenState();
}

class _ShoppingListsScreenState extends State<ShoppingListsScreen> {
  // 🔍 חיפוש וסינון
  String _searchQuery = '';
  String _sortBy = 'date_desc';

  // 🔄 האם כבר ביקשנו טעינה ראשונית
  bool _initialLoadRequested = false;

  // 🎬 האם הטעינה הראשונית הושלמה (למניעת אנימציות בחיפוש)
  bool _isFirstLoadComplete = false;

  /// האם יש סינון/חיפוש פעיל
  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty || _sortBy != 'date_desc';

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
      // 🔄 פאזה 3: כפתור "רשימה חדשה" הוסר — יש רשימה חיה אחת קבועה.
    );
  }

  /// 🎛️ סרגל עליון — כותרת highlighter + חיפוש בלחיצה אחת + סינון
  Widget _buildTopBar() {
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final canPop = Navigator.canPop(context);
    // The pill controls sort only; search has its own lit icon, so the
    // pill badge reflects just what the popup owns.
    final hasFilterOrSort = _sortBy != 'date_desc';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingTiny),
      child: Row(
        children: [
          // Back button — only visible when this screen was pushed (e.g.
          // from the home dashboard's "see all"). Hidden if it's used as
          // a tab so we don't pop the whole nav stack accidentally.
          if (canPop)
            IconButton(
              onPressed: () {
                unawaited(HapticFeedback.lightImpact());
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_forward),
              color: cs.onSurfaceVariant,
              tooltip: AppStrings.common.goBack,
            ),
          // 🏷️ כותרת מסך בסגנון highlighter — תואמת ל-section headers למטה,
          // כך שהמסך נקרא כ"עמוד מחברת" אחד עם זהות ברורה.
          Semantics(
            header: true,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: kSpacingSmall,
                vertical: kSpacingXTiny,
              ),
              decoration: BoxDecoration(
                color: (brand?.stickyCyan ?? kStickyCyan).withValues(alpha: kHighlightOpacity),
                borderRadius: BorderRadius.circular(kBorderRadiusSmall),
              ),
              child: Text(
                AppStrings.shopping.listsScreenTitle,
                style: const TextStyle(
                  // Screen title outranks the section headers below
                  // (kFontSizeLarge): 28 vs 20 is a clear ~1.4× magnitude,
                  // so "page title" reads above "section title" even though
                  // both wear the same cyan highlighter.
                  fontSize: kFontSizeXLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Spacer(),
          // 🔍 חיפוש בלחיצה אחת — הפעולה הנפוצה ביותר מקבלת כפתור משלה
          // במקום להיקבר שתי רמות בתוך תפריט.
          IconButton(
            onPressed: () {
              unawaited(HapticFeedback.selectionClick());
              _showSearchSheet();
            },
            icon: Icon(
              Icons.search,
              color: _searchQuery.isNotEmpty ? cs.primary : cs.onSurfaceVariant,
            ),
            tooltip: AppStrings.shopping.searchMenuLabel,
          ),
          // 🎛️ סינון + מיון בתפריט; נקודת badge מסמנת סינון פעיל.
          PopupMenuButton<String>(
            tooltip: AppStrings.shopping.searchAndFilter,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            offset: const Offset(0, 40),
            itemBuilder: (context) => [
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
              padding: const EdgeInsets.all(kSpacingTiny),
              decoration: BoxDecoration(
                color: hasFilterOrSort
                    ? cs.primaryContainer
                    : cs.surface.withValues(alpha: kOpacityHigh),
                borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                border: Border.all(
                  color: hasFilterOrSort ? cs.primary : cs.onSurface.withValues(alpha: kOpacitySubtle),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune,
                    size: kIconSizeSmallPlus,
                    color: hasFilterOrSort ? cs.primary : cs.onSurfaceVariant,
                  ),
                  // Badge נקודה כשיש סינון/מיון פעיל
                  if (hasFilterOrSort) ...[
                    const SizedBox(width: kSpacingXTiny),
                    Container(
                      width: kSpacingSmall,
                      height: kSpacingSmall,
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
            : cs.onSurface;

    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: kIconSizeMedium, color: color),
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
                      fontSize: kFontSizeSmall,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (isActive)
            Icon(Icons.check_circle, size: kIconSizeSmallPlus, color: cs.primary),
        ],
      ),
    );
  }

  /// טיפול בבחירה מהתפריט
  void _handleMenuAction(String action) {
    unawaited(HapticFeedback.selectionClick());

    switch (action) {
      case 'sort':
        _showSortSheet();
        break;
      case 'clear':
        _clearAllFilters();
        break;
    }
  }

  /// 🔍 Bottom Sheet לחיפוש
  void _showSearchSheet() async {
    final controller = TextEditingController(text: _searchQuery);
    try {
    await showModalBottomSheet(
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(kBorderRadiusLarge)),
          ),
          padding: const EdgeInsets.all(kSpacingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // כותרת
              Row(
                children: [
                  const Icon(Icons.search, size: kIconSizeMedium),
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
                    borderRadius: BorderRadius.circular(kBorderRadius),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (value) {
                  setState(() {
                    _searchQuery = value.trim();
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
    } finally {
      controller.dispose();
    }
  }

  /// 📊 Bottom Sheet למיון
  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(kBorderRadiusLarge)),
        ),
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // כותרת
            Row(
              children: [
                const Icon(Icons.sort, size: kIconSizeMedium),
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
        color: isSelected ? cs.primary : cs.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? cs.primary : cs.onSurface,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: cs.primary) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      ),
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        setState(() {
          _sortBy = value;
        });
        Navigator.pop(context);
      },
    );
  }

  /// 🧹 ניקוי כל הסינונים
  void _clearAllFilters() {
    unawaited(HapticFeedback.lightImpact());
    setState(() {
      _searchQuery = '';
      _sortBy = 'date_desc';
    });
  }

  /// 🏷️ פס סיכום סינון פעיל
  Widget _buildActiveFiltersStrip() {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
      padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: kOpacityMedium),
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Row(
        children: [
          // אייקון סינון
          Icon(Icons.filter_alt, size: kIconSizeSmall, color: cs.primary),
          const SizedBox(width: kSpacingSmall),

          // תגיות סינון (לחיצות לפתיחת Sheet)
          Expanded(
            child: Wrap(
              spacing: kSpacingSmall,
              children: [
                if (_searchQuery.isNotEmpty)
                  _buildFilterTag('🔍 "$_searchQuery"', onTap: _showSearchSheet),
                if (_sortBy != 'date_desc')
                  _buildFilterTag('📊 ${_getSortLabel()}', onTap: _showSortSheet),
              ],
            ),
          ),

          // כפתור ניקוי
          IconButton(
            icon: const Icon(Icons.close, size: kIconSizeSmallPlus),
            onPressed: _clearAllFilters,
            tooltip: AppStrings.shopping.clearFilterLabel,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: kMinTapTarget, minHeight: kMinTapTarget),
          ),
        ],
      ),
    );
  }

  /// תגית סינון בודדת (לחיצה פותחת את ה-Sheet המתאים)
  Widget _buildFilterTag(String label, {VoidCallback? onTap}) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: 2),
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: kOpacityStrong),
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: kFontSizeSmall),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 2),
              Icon(Icons.edit, size: kFontSizeTiny, color: cs.onSurface.withValues(alpha: 0.45)),
            ],
          ],
        ),
      ),
    );
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
    return const SkeletonListView();
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

    // 🔍 סינון ומיון — 🔄 פאזה 6: רק רשימות פעילות. אין יותר "היסטוריה" של
    // רשימות שהושלמו (הרשימה החיה לא מסתיימת); ההיסטוריה = טאב הקבלות.
    final activeLists = _getFilteredAndSortedActiveLists(provider.lists);

    if (activeLists.isEmpty && provider.lists.isNotEmpty) {
      // יש רשימות אבל הסינון ריק
      return _buildEmptySearchResults();
    }

    if (activeLists.isEmpty) {
      return _buildEmptyState();
    }

    return _buildListsView(activeLists);
  }

  /// 🔍 סינון רשימות לפי סטטוס וחיפוש
  List<ShoppingList> _filterLists(List<ShoppingList> lists, String status) {
    final query = _searchQuery.toLowerCase();
    return lists.where((list) {
      if (list.status != status) return false;
      if (_searchQuery.isNotEmpty && !list.name.toLowerCase().contains(query)) return false;
      return true;
    }).toList();
  }

  /// 🔍 סינון ומיון רשימות פעילות
  List<ShoppingList> _getFilteredAndSortedActiveLists(List<ShoppingList> lists) {
    final filtered = _filterLists(lists, ShoppingList.statusActive);
    _sortLists(filtered);
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

  /// 📌 מציג את הרשימות הפעילות (🔄 פאזה 6: אין יותר סקשן היסטוריה)
  Widget _buildListsView(List<ShoppingList> activeLists) {
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
        ],
      ],
    );
  }

  /// 🏷️ כותרת קטגוריה - סגנון highlighter על מחברת
  /// 🔧 FIX: הוספת פרמטרים subtitle ו-isActive (במקום title.contains שנשבר עם AppStrings)
  Widget _buildSectionHeader(String title, int count, {String? subtitle, bool isActive = true}) {
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();

    // 🔧 FIX: צבע highlighter לפי פרמטר isActive (לא לפי תוכן הכותרת!)
    final highlightColor = isActive
        ? (brand?.stickyCyan ?? kStickyCyan).withValues(alpha: kHighlightOpacity)
        : (brand?.stickyGreen ?? kStickyGreen).withValues(alpha: kHighlightOpacity);

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
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
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
            Navigator.pushNamed(context, '/populate-list', arguments: list);
          },
          // Only owner can delete — matches Firestore rules (created_by check)
          onDelete: list.isCurrentUserOwner ? () async {
            final provider = context.read<ShoppingListsProvider>();
            await provider.deleteList(list.id);
          } : null,
          onRestore: (deletedList) async {
            final provider = context.read<ShoppingListsProvider>();
            await provider.restoreList(deletedList);
          },
          onStartShopping: isActive
              ? () {

                  // 🔐 בדיקת הרשאות - צופה לא יכול להשתתף בקנייה
                  final userId = context.read<UserContext>().userId;
                  if (userId != null) {
                    final userRole = list.getUserRole(userId);
                    if (userRole != null && !userRole.canShop) {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppStrings.shopping.viewerCannotShop),
                          backgroundColor: Theme.of(context).extension<AppBrand>()?.stickyOrange ?? kStickyOrange,
                        ),
                      );
                      return;
                    }
                  }

                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => _getScreenForList(list)));
                }
              : null,
          onEdit: () {
            Navigator.pushNamed(context, '/populate-list', arguments: list);
          },
        ),
      );

      // 🎬 אנימציית כניסה - בטעינה ראשונית
      if (shouldAnimate && index < maxAnimatedItems) {
        return TweenAnimationBuilder<double>(
          key: ValueKey('anim_${list.id}'),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index.clamp(0, 5) * 50)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child),
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
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();

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
              color: brand?.stickyPink ?? kStickyPink,
              label: AppStrings.shopping.tryAgainButton,
              icon: Icons.refresh,
              onPressed: () {

                // ✨ Haptic feedback למשוב מישוש
                unawaited(HapticFeedback.lightImpact());

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
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();

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
              color: brand?.stickyGreen ?? kStickyGreen,
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
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/empty_cart.webp',
                          width: _kEmptyIllustrationSize,
                          height: _kEmptyIllustrationSize,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.shopping_cart_outlined,
                            size: kIconSizeXLarge,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
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
            // 🔄 פאזה 3: כפתור "צור רשימה חדשה" הוסר — הרשימה החיה נוצרת אוטומטית.
            const SizedBox(height: kSpacingMedium),
          ],
        ),
      ),
    );
  }

  /// 🎯 מחזיר את המסך המתאים לפי סוג הרשימה
  Widget _getScreenForList(ShoppingList list) {
    // כל הרשימות: חנויות (קנייה רגילה)
    return ActiveShoppingScreen(list: list);
  }
}
