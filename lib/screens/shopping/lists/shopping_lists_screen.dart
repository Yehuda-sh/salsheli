// 📄 File: lib/screens/shopping/lists/shopping_lists_screen.dart
//
// מסך רשימות קניות - הפרדה בין פעילות להיסטוריה עם Sticky Notes Design.
//
// Version: 5.0
// Updated: 24/10/2025

import 'dart:ui' as ui;

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

  // 🔍 Search Controller
  final TextEditingController _searchController = TextEditingController();

  // 🔄 האם כבר ביקשנו טעינה ראשונית
  bool _initialLoadRequested = false;

  // 🎬 האם הטעינה הראשונית הושלמה (למניעת אנימציות בחיפוש)
  bool _isFirstLoadComplete = false;

  @override
  void initState() {
    super.initState();
    debugPrint('📋 ShoppingListsScreen.initState()');

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
        debugPrint('🔄 טוען רשימות ראשונית');
        provider.loadLists();
      }
      _initialLoadRequested = true;
    }
  }

  @override
  void dispose() {
    debugPrint('🗑️ ShoppingListsScreen.dispose()');
    _searchController.dispose();
    super.dispose();
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'shopping_lists_add_btn',
        onPressed: () {
          debugPrint('➕ יצירת רשימה חדשה');
          HapticFeedback.mediumImpact();
          Navigator.pushNamed(context, '/create-list');
        },
        backgroundColor: kStickyYellow,
        tooltip: 'רשימה חדשה',
        child: const Icon(Icons.add, color: Colors.black87),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// 🔍 סעיף חיפוש וסינון
  Widget _buildFiltersSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // שדה חיפוש + כפתור מיון
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: kGlassBlurSigma, sigmaY: kGlassBlurSigma),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // שדה חיפוש
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: 'חפש רשימה...',
                          hintStyle: const TextStyle(fontSize: 14),
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: _searchController.clear,
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          isDense: true,
                        ),
                      ),
                    ),
                    // מפריד אנכי
                    Container(
                      height: 24,
                      width: 1,
                      color: Colors.black12,
                    ),
                    // כפתור מיון
                    _buildSortButtonCompact(),
                  ],
                ),
              ),
            ),
          ),
        ),

        // FilterChips
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
            children: _buildTypeFilterChips(),
          ),
        ),

        const SizedBox(height: kSpacingSmall),
      ],
    );
  }

  /// 🏷️ יצירת FilterChips לסינון סוגים
  List<Widget> _buildTypeFilterChips() {
    // רשימת כל הסוגים עם "הכל" בהתחלה
    final allTypes = [
      ('all', '📦', 'הכל'),
      ...ListTypes.all.map((t) => (t.key, t.emoji, t.shortName)),
    ];

    return allTypes.map((typeData) {
      final (key, emoji, name) = typeData;
      final isSelected = _selectedType == key;

      return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: AnimatedScale(
          scale: isSelected ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: FilterChip(
            showCheckmark: false,
            label: Text(
              '$emoji $name',
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? Colors.black : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              HapticFeedback.selectionClick();
              setState(() => _selectedType = key);
              debugPrint('🏷️ סינון לפי: $key');
            },
            backgroundColor: Colors.white.withValues(alpha: 0.8),
            selectedColor: kStickyCyan,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? Colors.black12 : Colors.transparent,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            visualDensity: VisualDensity.compact,
          ),
        ),
      );
    }).toList();
  }

  /// 📊 כפתור מיון קומפקטי - בתוך שורת החיפוש
  Widget _buildSortButtonCompact() {
    final cs = Theme.of(context).colorScheme;

    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      tooltip: 'מיון',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getSortIcon(), size: 18, color: cs.primary),
            const SizedBox(width: 4),
            Text(
              _getSortLabel(),
              style: TextStyle(fontSize: 13, color: cs.primary, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, size: 18, color: cs.primary),
          ],
        ),
      ),
      itemBuilder: (context) => [
        _buildSortMenuItem('date_desc', 'חדש → ישן', Icons.arrow_downward),
        _buildSortMenuItem('date_asc', 'ישן → חדש', Icons.arrow_upward),
        _buildSortMenuItem('name', 'א-ת', Icons.sort_by_alpha),
        _buildSortMenuItem('budget_desc', 'תקציב ↓', Icons.attach_money),
        _buildSortMenuItem('budget_asc', 'תקציב ↑', Icons.money_off),
      ],
      onSelected: (value) {
        HapticFeedback.selectionClick();
        debugPrint('📊 מיון לפי: $value');
        setState(() => _sortBy = value);
      },
    );
  }

  /// פריט תפריט מיון
  PopupMenuItem<String> _buildSortMenuItem(String value, String label, IconData icon) {
    final isSelected = _sortBy == value;
    return PopupMenuItem(
      value: value,
      height: 40,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.black54,
          ),
          const SizedBox(width: kSpacingSmall),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.black87,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            Icon(Icons.check, size: 18, color: Theme.of(context).colorScheme.primary),
          ],
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

  /// קבלת תווית מיון
  String _getSortLabel() {
    switch (_sortBy) {
      case 'date_desc':
        return 'חדש';
      case 'date_asc':
        return 'ישן';
      case 'name':
        return 'א-ת';
      case 'budget_desc':
        return '₪↓';
      case 'budget_asc':
        return '₪↑';
      default:
        return 'מיין';
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
    if (!_isFirstLoadComplete && provider.lists.isNotEmpty) {
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
    // הגבל היסטוריה
    final limitedHistory = completedLists.take(_currentHistoryLimit).toList();
    final hasMoreHistory = completedLists.length > _currentHistoryLimit;

    return ListView(
      // 📏 Padding מתואם לקווי המחברת (48px בין קווים)
      // 20px למעלה כדי שהכותרת תהיה בין הקווים
      padding: const EdgeInsets.fromLTRB(kSpacingMedium, 20, kSpacingMedium, 80),
      children: [
        // 🔵 פעילות
        if (activeLists.isNotEmpty) ...[
          _buildSectionHeader('🔵 רשימות פעילות', activeLists.length),
          const SizedBox(height: kSpacingMedium),
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

  /// 🏷️ כותרת קטגוריה - סגנון highlighter על מחברת
  Widget _buildSectionHeader(String title, int count) {
    final cs = Theme.of(context).colorScheme;

    // צבע highlighter לפי סוג הכותרת
    final highlightColor = title.contains('פעילות')
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
          onStartShopping: isActive ? () {
            debugPrint('🛒 התחלת קנייה: ${list.name}');
            Navigator.push(context, MaterialPageRoute(builder: (context) => ActiveShoppingScreen(list: list)));
          } : null,
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
                debugPrint('🧹 ניקוי סינון');

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
                      'אין רשימות קניות',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: kSpacingSmall),
                      Text(
                        'לחץ על הכפתור מטה ליצירת\nהרשימה הראשונה שלך!',
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
              label: 'צור רשימה חדשה',
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
