// 📄 File: lib/screens/shopping/shopping_lists_screen.dart - V2.0 ENHANCED
//
// ✨ שיפורים חדשים (v2.0):
// 1. 🔍 חיפוש טקסט בשם הרשימה
// 2. 🏷️ סינון לפי ListType (dropdown)
// 3. 📊 מיון: תאריך ↓↑ | שם א-ת | תקציב ↓↑
//
// 🇮🇱 מסך רשימות קניות:
//     - מציג את כל הרשימות של המשתמש.
//     - תומך ביצירה, מחיקה ופתיחה של רשימה.
//     - כולל מצב טעינה, שגיאה ומצב ריק.
//     - חיפוש וסינון מתקדם.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/shopping_list.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../widgets/create_list_dialog.dart';
import '../../widgets/shopping_list_tile.dart';
import '../../core/constants.dart';
import '../../core/ui_constants.dart';
import './active_shopping_screen.dart';

class ShoppingListsScreen extends StatefulWidget {
  const ShoppingListsScreen({super.key});

  @override
  State<ShoppingListsScreen> createState() => _ShoppingListsScreenState();
}

class _ShoppingListsScreenState extends State<ShoppingListsScreen> {
  // 🔍 חיפוש וסינון
  String _searchQuery = '';
  String _selectedType = 'all'; // 'all' = הכל
  String _sortBy = 'date_desc'; // date_desc | date_asc | name | budget_desc | budget_asc

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShoppingListsProvider>();

    // ✅ טעינה ראשונית
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!provider.isLoading &&
          provider.lists.isEmpty &&
          provider.errorMessage == null &&
          provider.lastUpdated == null) {
        provider.loadLists();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('רשימות קניות'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "רענן",
            onPressed: () => provider.loadLists(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 חיפוש וסינון
            _buildFiltersSection(),

            // 📋 תוכן
            Expanded(
              child: RefreshIndicator(
                onRefresh: provider.loadLists,
                child: _buildBody(context, provider),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateListDialog(context, provider),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 🔍 סעיף חיפוש וסינון
  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(kSpacingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 🔍 שורת חיפוש
          TextField(
            decoration: InputDecoration(
              hintText: 'חפש רשימה...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kBorderRadius),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: kSpacingMedium,
                vertical: kInputPadding,
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          
          const SizedBox(height: kSpacingSmall),

          // 🏷️ סינון ומיון
          Row(
            children: [
              // סינון לפי סוג
              Expanded(
                child: _buildTypeFilter(),
              ),
              const SizedBox(width: kSpacingSmall),
              // מיון
              Expanded(
                child: _buildSortButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🏷️ Dropdown לסינון לפי סוג
  Widget _buildTypeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedType,
          isExpanded: true,
          icon: const Icon(Icons.filter_list, size: kIconSizeMedium),
          items: [
            const DropdownMenuItem(
              value: 'all',
              child: Text('כל הסוגים'),
            ),
            ...ListType.allTypes.map((type) {
              final typeInfo = kListTypes[type];
              return DropdownMenuItem(
                value: type,
                child: Row(
                  children: [
                    Text(typeInfo?['icon'] ?? '📝'),
                    const SizedBox(width: kSpacingSmall),
                    Text(typeInfo?['name'] ?? type),
                  ],
                ),
              );
            }),
          ],
          onChanged: (value) {
            if (value != null) {
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
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getSortIcon(),
            size: kIconSizeMedium,
          ),
          const SizedBox(width: kSpacingTiny),
          const Text('מיין'),
        ],
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'date_desc',
          child: Row(
            children: [
              Icon(
                Icons.arrow_downward,
                size: kIconSizeSmall,
                color: _sortBy == 'date_desc'
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              const SizedBox(width: kSpacingSmall),
              Text(
                'תאריך (חדש→ישן)',
                style: TextStyle(
                  fontWeight: _sortBy == 'date_desc'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
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
                color: _sortBy == 'date_asc'
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              const SizedBox(width: kSpacingSmall),
              Text(
                'תאריך (ישן→חדש)',
                style: TextStyle(
                  fontWeight:
                      _sortBy == 'date_asc' ? FontWeight.bold : FontWeight.normal,
                ),
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
                color: _sortBy == 'name'
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              const SizedBox(width: kSpacingSmall),
              Text(
                'שם (א-ת)',
                style: TextStyle(
                  fontWeight:
                      _sortBy == 'name' ? FontWeight.bold : FontWeight.normal,
                ),
              ),
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
                color: _sortBy == 'budget_desc'
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              const SizedBox(width: kSpacingSmall),
              Text(
                'תקציב (גבוה→נמוך)',
                style: TextStyle(
                  fontWeight: _sortBy == 'budget_desc'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
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
                color: _sortBy == 'budget_asc'
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              const SizedBox(width: kSpacingSmall),
              Text(
                'תקציב (נמוך→גבוה)',
                style: TextStyle(
                  fontWeight: _sortBy == 'budget_asc'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) => setState(() => _sortBy = value),
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

  /// 📌 מציג דיאלוג ליצירת רשימה חדשה
  void _showCreateListDialog(
    BuildContext context,
    ShoppingListsProvider provider,
  ) {
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
              final newList = await provider.createList(
                name: name,
                type: type,
                budget: budget,
              );

              debugPrint('   ✅ רשימה נוצרה: ${newList.id}');

              if (!context.mounted) {
                debugPrint('   ⚠️ context לא mounted - מדלג על ניווט');
                return;
              }

              debugPrint('   ➡️ ניווט ל-populate-list');
              Navigator.pushNamed(
                context,
                '/populate-list',
                arguments: newList,
              );
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
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null) {
      return _buildErrorState(provider);
    }

    // 🔍 סינון ומיון
    final filteredLists = _getFilteredAndSortedLists(provider.lists);

    if (filteredLists.isEmpty && provider.lists.isNotEmpty) {
      // יש רשימות אבל הסינון ריק
      return _buildEmptySearchResults();
    }

    if (filteredLists.isEmpty) {
      return _buildEmptyState(context, provider);
    }

    return _buildListsView(filteredLists);
  }

  /// 🔍 סינון ומיון רשימות
  List<ShoppingList> _getFilteredAndSortedLists(List<ShoppingList> lists) {
    var filtered = lists.where((list) {
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
    switch (_sortBy) {
      case 'date_desc':
        filtered.sort((a, b) => b.createdDate.compareTo(a.createdDate));
        break;
      case 'date_asc':
        filtered.sort((a, b) => a.createdDate.compareTo(b.createdDate));
        break;
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'budget_desc':
        filtered.sort((a, b) {
          final budgetA = a.budget ?? 0.0;
          final budgetB = b.budget ?? 0.0;
          return budgetB.compareTo(budgetA);
        });
        break;
      case 'budget_asc':
        filtered.sort((a, b) {
          final budgetA = a.budget ?? 0.0;
          final budgetB = b.budget ?? 0.0;
          return budgetA.compareTo(budgetB);
        });
        break;
    }

    return filtered;
  }

  /// 📌 מציג את כל הרשימות
  Widget _buildListsView(List<ShoppingList> lists) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: kSpacingSmall),
      itemCount: lists.length,
      itemBuilder: (context, index) {
        final list = lists[index];
        return ShoppingListTile(
          list: list,
          onTap: () {
            Navigator.pushNamed(context, '/populate-list', arguments: list);
          },
          onDelete: () {
            final provider = context.read<ShoppingListsProvider>();
            provider.deleteList(list.id);
          },
          onRestore: (deletedList) {
            final provider = context.read<ShoppingListsProvider>();
            provider.restoreList(deletedList);
          },
          onStartShopping: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ActiveShoppingScreen(list: list),
              ),
            );
          },
        );
      },
    ).animate().fadeIn(duration: 300.ms);
  }

  /// ❌ מצב שגיאה
  Widget _buildErrorState(ShoppingListsProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: kSpacingMedium),
          Text(
            "שגיאה בטעינת הרשימות",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            provider.errorMessage!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: kSpacingLarge),
          ElevatedButton.icon(
            onPressed: () => provider.loadLists(),
            icon: const Icon(Icons.refresh),
            label: const Text('נסה שוב'),
          ),
        ],
      ),
    );
  }

  /// 📭 תוצאות חיפוש ריקות
  Widget _buildEmptySearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: kIconSizeXLarge, color: Colors.grey),
          const SizedBox(height: kSpacingMedium),
          const Text(
            "לא נמצאו רשימות",
            style: TextStyle(fontSize: kFontSizeLarge, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            "נסה לשנות את החיפוש או הסינון",
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: kSpacingLarge),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _selectedType = 'all';
              });
            },
            icon: const Icon(Icons.clear_all),
            label: const Text('נקה סינון'),
          ),
        ],
      ),
    );
  }

  /// 📋 מצב ריק – אין רשימות להצגה
  Widget _buildEmptyState(
    BuildContext context,
    ShoppingListsProvider provider,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.list_alt_rounded, size: kIconSizeXXLarge, color: Colors.grey),
          const SizedBox(height: kSpacingMedium),
          const Text(
            "אין רשימות להצגה",
            style: TextStyle(fontSize: kFontSizeLarge, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: kSpacingSmall),
          const Text(
            "לחץ על כפתור הפלוס כדי ליצור את הרשימה הראשונה שלך!",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: kSpacingLarge),
          ElevatedButton.icon(
            onPressed: () => _showCreateListDialog(context, provider),
            icon: const Icon(Icons.add),
            label: const Text("צור רשימה חדשה"),
          ),
        ],
      ),
    );
  }
}
