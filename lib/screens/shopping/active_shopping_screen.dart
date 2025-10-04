// 📄 File: lib/screens/shopping/active_shopping_screen.dart - FIXED v2
//
// ✅ תיקונים קריטיים:
// 1. context.watch מועבר ל-build (לא בפונקציה נפרדת)
// 2. enum לסטטוס פריט במקום strings
// 3. null safety מלא
// 4. validation טוב יותר

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/shopping_list.dart';
import '../../models/receipt.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../theme/app_theme.dart';

/// 🇮🇱 סטטוס פריט - enum מובנה במקום strings
enum ItemStatus {
  pending,
  taken;

  bool get isTaken => this == ItemStatus.taken;
}

class ActiveShoppingScreen extends StatefulWidget {
  final String listName;
  final String? listId;

  const ActiveShoppingScreen({
    super.key,
    required this.listName,
    this.listId,
  });

  @override
  State<ActiveShoppingScreen> createState() => _ActiveShoppingScreenState();
}

class _ActiveShoppingScreenState extends State<ActiveShoppingScreen> {
  bool isLoading = false;

  // Undo mechanism
  ShoppingList? _lastState;
  String? _lastActionMessage;

  /// ✅ עדכון פריט דרך Provider
  Future<void> _updateItemStatus(
    ShoppingList list,
    int index,
    ItemStatus newStatus,
  ) async {
    final provider = context.read<ShoppingListsProvider>();

    // שמירת מצב לצורך Undo
    _lastState = list;

    // עדכון הפריט
    final updatedItem = list.items[index].copyWith(
      isChecked: newStatus.isTaken,
    );

    // עדכון הרשימה דרך Provider
    await provider.updateItemAt(list.id, index, (_) => updatedItem);

    setState(() {
      _lastActionMessage = 'הפריט עודכן';
    });
  }

  /// ✅ סימון הכל כנלקח
  Future<void> _markAllAsTaken(ShoppingList list) async {
    final provider = context.read<ShoppingListsProvider>();

    _lastState = list;

    // עדכון כל הפריטים לסטטוס "נלקח"
    final updatedItems = list.items.map((item) {
      return item.copyWith(isChecked: true);
    }).toList();

    // החלפת כל הפריטים בבת אחת
    final updatedList = list.copyWith(items: updatedItems);
    await provider.updateList(updatedList);

    setState(() {
      _lastActionMessage = 'כל הפריטים סומנו כנלקחו';
    });

    _showUndoSnackbar();
  }

  /// ✅ איפוס כל הסטטוסים
  Future<void> _resetAllStatuses(ShoppingList list) async {
    final provider = context.read<ShoppingListsProvider>();

    _lastState = list;

    final updatedItems = list.items.map((item) {
      return item.copyWith(isChecked: false);
    }).toList();

    final updatedList = list.copyWith(items: updatedItems);
    await provider.updateList(updatedList);

    setState(() {
      _lastActionMessage = 'הסטטוסים אופסו';
    });

    _showUndoSnackbar();
  }

  /// ביטול פעולה אחרונה (Undo)
  Future<void> _undo() async {
    if (_lastState == null) return;

    final provider = context.read<ShoppingListsProvider>();
    await provider.updateList(_lastState!);

    setState(() {
      _lastState = null;
      _lastActionMessage = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('הפעולה בוטלה'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showUndoSnackbar() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_lastActionMessage ?? 'הפעולה בוצעה'),
        action: SnackBarAction(label: 'ביטול', onPressed: _undo),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// קיבוץ פריטים לפי אות ראשונה
  Map<String, List<MapEntry<int, ReceiptItem>>> _groupByFirstLetter(
    List<ReceiptItem> items,
  ) {
    final map = <String, List<MapEntry<int, ReceiptItem>>>{};

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final firstLetter = item.name.isNotEmpty
          ? item.name[0].toUpperCase()
          : '#';

      map.putIfAbsent(firstLetter, () => []);
      map[firstLetter]!.add(MapEntry(i, item));
    }

    return map;
  }

  /// בניית שורת פריט
  Widget _buildItemRow(
    BuildContext context,
    ShoppingList list,
    int index,
    ReceiptItem item,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isChecked = item.isChecked;

    return ListTile(
      leading: Checkbox(
        value: isChecked,
        onChanged: (val) {
          _updateItemStatus(
            list,
            index,
            val == true ? ItemStatus.taken : ItemStatus.pending,
          );
        },
      ),
      title: Text(
        item.name,
        style: TextStyle(
          decoration: isChecked ? TextDecoration.lineThrough : null,
          color: isChecked ? cs.onSurfaceVariant : cs.onSurface,
        ),
      ),
      subtitle: Text('כמות: ${item.quantity}'),
      trailing: isChecked
          ? const Icon(Icons.check_circle, color: Colors.green)
          : Icon(Icons.radio_button_unchecked, color: cs.outline),
    );
  }

  /// בניית chip סטטוס
  Widget _buildStatusChip(IconData icon, int count, Color color) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text('$count', style: TextStyle(color: color)),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
    );
  }

  /// בניית מסך שגיאה
  Widget _buildErrorScreen(String message) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('שגיאה'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('חזור'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    // ✅ בדיקת null safety
    if (widget.listId == null) {
      return _buildErrorScreen('לא סופק מזהה רשימה');
    }

    // ✅ קבלת הרשימה ישירות מה-Provider (context.watch ב-build)
    final provider = context.watch<ShoppingListsProvider>();
    final list = provider.getById(widget.listId!);

    if (isLoading) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: Center(child: CircularProgressIndicator(color: accent)),
      );
    }

    if (list == null) {
      return _buildErrorScreen('הרשימה לא נמצאה');
    }

    // חישוב סטטיסטיקות
    final totalItems = list.items.length;
    final takenCount = list.items.where((item) => item.isChecked).length;
    final pendingCount = totalItems - takenCount;
    final progress = totalItems > 0 ? takenCount / totalItems : 0.0;

    // קיבוץ לפי אות ראשונה
    final groupedItems = _groupByFirstLetter(list.items);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(widget.listName),
        backgroundColor: cs.surface,
        elevation: 0,
        actions: [
          if (_lastState != null)
            IconButton(
              icon: const Icon(Icons.undo),
              tooltip: 'ביטול',
              onPressed: _undo,
            ),
        ],
      ),
      body: Column(
        children: [
          // Header - סיכום והתקדמות
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusChip(
                        Icons.schedule,
                        pendingCount,
                        Colors.grey,
                      ),
                      _buildStatusChip(
                        Icons.check_circle,
                        takenCount,
                        Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: cs.surfaceContainerHighest,
                    color: accent,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(progress * 100).toInt()}% הושלם ($takenCount מתוך $totalItems)',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          // רשימת פריטים מקובצת
          Expanded(
            child: totalItems == 0
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 64, color: cs.outline),
                        const SizedBox(height: 16),
                        Text(
                          'הרשימה ריקה',
                          style: TextStyle(
                            fontSize: 18,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: groupedItems.entries.map((entry) {
                      final letter = entry.key;
                      final items = entry.value;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          title: Text(
                            letter,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text('${items.length} פריטים'),
                          initiallyExpanded: true,
                          children: [
                            const Divider(height: 1),
                            ...items.map(
                              (entry) => _buildItemRow(
                                context,
                                list,
                                entry.key,
                                entry.value,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),

      // כפתורי פעולה מהירים
      bottomNavigationBar: totalItems == 0
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: pendingCount == 0 ? null : () => _markAllAsTaken(list),
                      icon: const Icon(Icons.done_all),
                      label: const Text('סמן הכל'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: takenCount == 0 ? null : () => _resetAllStatuses(list),
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('איפוס'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
