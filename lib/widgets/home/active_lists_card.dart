// 📄 File: lib/screens/shopping/active_shopping_screen.dart
//
// ✅ עדכון חדש:
// - הוספת כפתור "סיים קנייה" שמנווט למסך סיכום
// - שמירת הרשימה לפני ניווט
//
// מסך קנייה פעילה - סימון פריטים שנקנו בזמן אמת

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/shopping_list.dart';
import '../../models/receipt.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../theme/app_theme.dart';

class ActiveShoppingScreen extends StatefulWidget {
  final String listName;
  final String? listId;

  const ActiveShoppingScreen({super.key, required this.listName, this.listId});

  @override
  State<ActiveShoppingScreen> createState() => _ActiveShoppingScreenState();
}

class _ActiveShoppingScreenState extends State<ActiveShoppingScreen> {
  bool isLoading = false;

  // Undo mechanism
  ShoppingList? _lastState;
  String? _lastActionMessage;

  @override
  void initState() {
    super.initState();
  }

  ShoppingList? _getCurrentList(BuildContext context) {
    if (widget.listId == null) return null;
    final provider = context.watch<ShoppingListsProvider>();
    return provider.getById(widget.listId!);
  }

  Future<void> _updateItemStatus(
    ShoppingList list,
    int index,
    String newStatus,
  ) async {
    final provider = context.read<ShoppingListsProvider>();

    _lastState = list;

    final updatedItem = list.items[index].copyWith(
      isChecked: newStatus == 'taken',
    );

    await provider.updateItemAt(list.id, index, (_) => updatedItem);

    setState(() {
      _lastActionMessage = 'הפריט עודכן';
    });
  }

  Future<void> _markAllAsTaken(ShoppingList list) async {
    final provider = context.read<ShoppingListsProvider>();

    _lastState = list;

    final updatedItems = list.items.map((item) {
      return item.copyWith(isChecked: true);
    }).toList();

    final updatedList = list.copyWith(items: updatedItems);
    await provider.updateList(updatedList);

    setState(() {
      _lastActionMessage = 'כל הפריטים סומנו כנלקחו';
    });

    _showUndoSnackbar();
  }

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
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ✅ סיום קנייה - ניווט למסך סיכום
  Future<void> _finishShopping(ShoppingList list) async {
    // עדכון הרשימה לסטטוס "completed"
    final provider = context.read<ShoppingListsProvider>();

    try {
      await provider.completeList(list.id);

      if (mounted) {
        // ניווט למסך סיכום
        Navigator.pushReplacementNamed(
          context,
          '/shopping-summary',
          arguments: list.id,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בסיום קנייה: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Map<String, List<MapEntry<int, ReceiptItem>>> _groupByCategory(
    List<ReceiptItem> items,
  ) {
    final grouped = <String, List<MapEntry<int, ReceiptItem>>>{};

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      // ✅ קיבוץ לפי אות ראשונה של השם (במקום קטגוריה)
      final itemName = item.name ?? 'ללא שם';
      final firstLetter = itemName.isNotEmpty
          ? itemName[0].toUpperCase()
          : '#';

      if (!grouped.containsKey(firstLetter)) {
        grouped[firstLetter] = [];
      }

      grouped[firstLetter]!.add(MapEntry(i, item));
    }

    return grouped;
  }

  Widget _buildStatusChip(IconData icon, int count, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(BuildContext context, int index, ReceiptItem item) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isTaken = item.isChecked;

    return ListTile(
      leading: Checkbox(
        value: isTaken,
        onChanged: (_) => _updateItemStatus(
          _getCurrentList(context)!,
          index,
          isTaken ? 'pending' : 'taken',
        ),
      ),
      title: Text(
        item.name ?? 'ללא שם',
        style: TextStyle(
          decoration: isTaken ? TextDecoration.lineThrough : null,
          color: isTaken ? cs.onSurfaceVariant : cs.onSurface,
        ),
      ),
      subtitle: item.quantity > 1 ? Text('כמות: ${item.quantity}') : null,
      trailing: isTaken
          ? Icon(Icons.check_circle, color: Colors.green, size: 20)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    final list = _getCurrentList(context);

    if (isLoading) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: Center(child: CircularProgressIndicator(color: accent)),
      );
    }

    if (list == null) {
      return Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(title: const Text('שגיאה'), backgroundColor: cs.surface),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'הרשימה לא נמצאה',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('אנא חזור למסך הרשימות'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('חזור'),
              ),
            ],
          ),
        ),
      );
    }

    final totalItems = list.items.length;
    final takenCount = list.items.where((item) => item.isChecked).length;
    final pendingCount = totalItems - takenCount;
    final progress = totalItems > 0 ? takenCount / totalItems : 0.0;

    final groupedItems = _groupByCategory(list.items);

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
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: groupedItems.entries.map((entry) {
                final category = entry.key;
                final items = entry.value;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    title: Text(
                      category,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${items.length} פריטים'),
                    children: [
                      const Divider(height: 1),
                      ...items.map(
                        (entry) =>
                            _buildItemRow(context, entry.key, entry.value),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ כפתור סיום קנייה
            FilledButton.icon(
              onPressed: takenCount > 0 ? () => _finishShopping(list) : null,
              icon: const Icon(Icons.done_all),
              label: const Text('סיים קנייה'),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: pendingCount == 0
                        ? null
                        : () => _markAllAsTaken(list),
                    icon: const Icon(Icons.playlist_add_check),
                    label: const Text('סמן הכל'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: takenCount == 0
                        ? null
                        : () => _resetAllStatuses(list),
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('איפוס'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
