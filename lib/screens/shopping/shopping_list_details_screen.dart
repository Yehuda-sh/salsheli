// 📄 File: lib/screens/shopping/shopping_list_details_screen.dart - V2.0 ENHANCED
//
// ✨ שיפורים חדשים (v2.0):
// 1. 🔍 חיפוש פריט בתוך הרשימה
// 2. 🏷️ קיבוץ לפי קטגוריה
// 3. 📊 מיון: מחיר (יקר→זול) | סטטוס (checked→unchecked)
//
// 🇮🇱 מסך עריכת פרטי רשימת קניות:
//     - מוסיף/עורך/מוחק פריטים דרך ShoppingListsProvider.
//     - מחשב עלות כוללת.
//     - מציג UI רספונסיבי עם RTL.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui' as ui;

import '../../models/receipt.dart';
import '../../models/shopping_list.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../core/ui_constants.dart';

class ShoppingListDetailsScreen extends StatefulWidget {
  final ShoppingList list;

  const ShoppingListDetailsScreen({super.key, required this.list});

  @override
  State<ShoppingListDetailsScreen> createState() =>
      _ShoppingListDetailsScreenState();
}

class _ShoppingListDetailsScreenState
    extends State<ShoppingListDetailsScreen> {
  // 🔍 חיפוש ומיון
  String _searchQuery = '';
  bool _groupByCategory = false;
  String _sortBy = 'none'; // none | price_desc | checked

  /// === דיאלוג הוספה/עריכה ===
  void _showItemDialog(BuildContext context, {ReceiptItem? item, int? index}) {
    final provider = context.read<ShoppingListsProvider>();

    final nameController = TextEditingController(text: item?.name ?? "");
    final quantityController = TextEditingController(
      text: item?.quantity.toString() ?? "1",
    );
    final priceController = TextEditingController(
      text: item?.unitPrice.toString() ?? "",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item == null ? "הוספת מוצר" : "עריכת מוצר"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "שם מוצר"),
                textDirection: ui.TextDirection.rtl,
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: "כמות"),
                keyboardType: TextInputType.number,
                textDirection: ui.TextDirection.rtl,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "מחיר ליחידה"),
                keyboardType: TextInputType.number,
                textDirection: ui.TextDirection.rtl,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("ביטול"),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final qty = int.tryParse(quantityController.text) ?? 1;
                final unitPrice = double.tryParse(priceController.text) ?? 0.0;

                if (name.isNotEmpty) {
                  final newItem = ReceiptItem(
                    id: const Uuid().v4(),
                    name: name,
                    quantity: qty,
                    unitPrice: unitPrice,
                  );

                  if (item == null) {
                    provider.addItemToList(widget.list.id, newItem);
                  } else if (index != null) {
                    provider.updateItemAt(widget.list.id, index, (_) => newItem);
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text("שמירה"),
            ),
          ],
        );
      },
    );
  }

  /// === מחיקת פריט ===
  void _deleteItem(BuildContext context, int index, ReceiptItem removed) {
    final provider = context.read<ShoppingListsProvider>();
    provider.removeItemFromList(widget.list.id, index);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('המוצר "${removed.name ?? 'ללא שם'}" נמחק'),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.red.shade700,
        action: SnackBarAction(
          label: 'בטל',
          textColor: Colors.white,
          onPressed: () {
            provider.addItemToList(widget.list.id, removed);
          },
        ),
      ),
    );
  }

  /// 🔍 סינון ומיון פריטים
  List<ReceiptItem> _getFilteredAndSortedItems(List<ReceiptItem> items) {
    var filtered = items.where((item) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final name = (item.name ?? '').toLowerCase();
      return name.contains(query);
    }).toList();

    // מיון
    switch (_sortBy) {
      case 'price_desc':
        filtered.sort((a, b) => b.unitPrice.compareTo(a.unitPrice));
        break;
      case 'checked':
        filtered.sort((a, b) {
          if (a.isChecked == b.isChecked) return 0;
          return a.isChecked ? 1 : -1; // unchecked קודם
        });
        break;
    }

    return filtered;
  }

  /// 🏷️ קיבוץ לפי קטגוריה
  Map<String, List<ReceiptItem>> _groupItemsByCategory(
    List<ReceiptItem> items,
  ) {
    final grouped = <String, List<ReceiptItem>>{};

    for (var item in items) {
      final category = item.category ?? 'ללא קטגוריה';
      grouped.putIfAbsent(category, () => []).add(item);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShoppingListsProvider>();
    final currentList = provider.lists.firstWhere(
      (l) => l.id == widget.list.id,
      orElse: () => widget.list,
    );

    final theme = Theme.of(context);
    final allItems = currentList.items;
    final filteredItems = _getFilteredAndSortedItems(allItems);
    final totalAmount = allItems.fold(0.0, (sum, item) => sum + item.totalPrice);

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(currentList.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // פתיחת search bar
                setState(() {
                  if (_searchQuery.isNotEmpty) {
                    _searchQuery = '';
                  }
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // 🔍 חיפוש וסינון
            _buildFiltersSection(allItems),

            // 📋 תוכן
            Expanded(
              child: filteredItems.isEmpty && allItems.isNotEmpty
                  ? _buildEmptySearchResults()
                  : filteredItems.isEmpty
                      ? _buildEmptyState(theme)
                      : _groupByCategory
                          ? _buildGroupedList(filteredItems, theme)
                          : _buildFlatList(filteredItems, theme),
            ),

            // 💰 סה"כ
            Container(
              padding: const EdgeInsets.all(kSpacingMedium),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "סה״כ:",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    NumberFormat.simpleCurrency(locale: 'he_IL')
                        .format(totalAmount),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showItemDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  /// 🔍 סעיף חיפוש וסינון
  Widget _buildFiltersSection(List<ReceiptItem> allItems) {
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
              hintText: 'חפש פריט...',
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

          // 🏷️ קיבוץ ומיון
          Row(
            children: [
              // קיבוץ לפי קטגוריה
              Expanded(
                child: FilterChip(
                  label: const Text('קבץ לפי קטגוריה'),
                  selected: _groupByCategory,
                  onSelected: (value) => setState(() => _groupByCategory = value),
                  avatar: Icon(
                    _groupByCategory ? Icons.folder_open : Icons.folder,
                    size: kIconSizeMedium,
                  ),
                ),
              ),

              const SizedBox(width: kSpacingSmall),

              // מיון
              Expanded(
                child: _buildSortButton(),
              ),
            ],
          ),

          // מונה פריטים
          if (allItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: kSpacingSmall),
              child: Text(
                'מציג ${allItems.length} פריטים',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  /// 📊 כפתור מיון
  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: kSpacingSmall,
          vertical: kSpacingSmall,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getSortIcon(),
              size: kIconSizeMedium,
            ),
            const SizedBox(width: kSpacingTiny),
            const Text('מיין'),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'none',
          child: Row(
            children: [
              Icon(
                Icons.clear,
                size: kIconSizeSmall,
                color: _sortBy == 'none'
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              const SizedBox(width: kSpacingSmall),
              Text(
                'ללא מיון',
                style: TextStyle(
                  fontWeight:
                      _sortBy == 'none' ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'price_desc',
          child: Row(
            children: [
              Icon(
                Icons.arrow_downward,
                size: kIconSizeSmall,
                color: _sortBy == 'price_desc'
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              const SizedBox(width: kSpacingSmall),
              Text(
                'מחיר (יקר→זול)',
                style: TextStyle(
                  fontWeight: _sortBy == 'price_desc'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'checked',
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: kIconSizeSmall,
                color: _sortBy == 'checked'
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              const SizedBox(width: kSpacingSmall),
              Text(
                'סטטוס (לא נסומן קודם)',
                style: TextStyle(
                  fontWeight:
                      _sortBy == 'checked' ? FontWeight.bold : FontWeight.normal,
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
      case 'price_desc':
        return Icons.arrow_downward;
      case 'checked':
        return Icons.check_circle_outline;
      default:
        return Icons.sort;
    }
  }

  /// 📋 רשימה שטוחה (flat)
  Widget _buildFlatList(List<ReceiptItem> items, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: kSpacingSmall),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final originalIndex = widget.list.items.indexOf(item);
        return _buildItemCard(item, originalIndex, theme);
      },
    );
  }

  /// 🏷️ רשימה מקובצת לפי קטגוריה
  Widget _buildGroupedList(List<ReceiptItem> items, ThemeData theme) {
    final grouped = _groupItemsByCategory(items);
    final categories = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: kSpacingSmall),
      itemCount: categories.length,
      itemBuilder: (context, catIndex) {
        final category = categories[catIndex];
        final categoryItems = grouped[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // כותרת קטגוריה
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: kSpacingMedium,
                vertical: kSpacingSmall,
              ),
              color: theme.colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  Icon(
                    Icons.folder,
                    size: kIconSizeMedium,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: kSpacingSmall),
                  Text(
                    category,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: kSpacingSmall),
                  Text(
                    '(${categoryItems.length})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // פריטים בקטגוריה
            ...categoryItems.map((item) {
              final originalIndex = widget.list.items.indexOf(item);
              return _buildItemCard(item, originalIndex, theme);
            }),
          ],
        );
      },
    );
  }

  /// 🎴 כרטיס פריט
  Widget _buildItemCard(ReceiptItem item, int index, ThemeData theme) {
    final formattedPrice =
        NumberFormat.simpleCurrency(locale: 'he_IL').format(item.totalPrice);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: kSpacingMedium,
        vertical: kSpacingTiny,
      ),
      child: ListTile(
        title: Text(
          item.name ?? 'ללא שם',
          style: theme.textTheme.titleMedium?.copyWith(
            decoration: item.isChecked ? TextDecoration.lineThrough : null,
            color: item.isChecked
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          "כמות: ${item.quantity} | מחיר כולל: $formattedPrice",
          style: theme.textTheme.bodySmall,
        ),
        leading: item.isChecked
            ? Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              )
            : Icon(
                Icons.radio_button_unchecked,
                color: theme.colorScheme.onSurfaceVariant,
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              tooltip: "ערוך מוצר",
              onPressed: () => _showItemDialog(context, item: item, index: index),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: "מחק מוצר",
              onPressed: () => _deleteItem(context, index, item),
            ),
          ],
        ),
        onTap: () => _showItemDialog(context, item: item, index: index),
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
            "לא נמצאו פריטים",
            style: TextStyle(fontSize: kFontSizeLarge, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            "נסה לשנות את החיפוש",
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: kSpacingLarge),
          TextButton.icon(
            onPressed: () => setState(() => _searchQuery = ''),
            icon: const Icon(Icons.clear_all),
            label: const Text('נקה חיפוש'),
          ),
        ],
      ),
    );
  }

  /// 📋 מצב ריק
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: kIconSizeXXLarge,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: kSpacingMedium),
          Text(
            'הרשימה ריקה',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            'לחץ על + להוספת מוצרים',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
