// 📄 File: lib/screens/shopping/active_shopping_screen.dart - FIXED
//
// ✅ תיקונים קריטיים:
// 1. חיבור מלא ל-ShoppingListsProvider
// 2. שימוש ברשימה אמיתית מה-Provider במקום SharedPreferences
// 3. עדכון הרשימה דרך Provider (לא ישירות)
// 4. סנכרון אוטומטי עם שאר המערכת

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
    // הנתונים יגיעו מה-Provider, לא צריך לטעון ידנית
  }

  /// ✅ קבלת הרשימה הנוכחית מה-Provider
  ShoppingList? _getCurrentList(BuildContext context) {
    if (widget.listId == null) return null;
    final provider = context.watch<ShoppingListsProvider>();
    return provider.getById(widget.listId!);
  }

  /// ✅ עדכון פריט דרך Provider
  Future<void> _updateItemStatus(
    ShoppingList list,
    int index,
    String newStatus,
  ) async {
    final provider = context.read<ShoppingListsProvider>();

    // שמירת מצב לצורך Undo
    _lastState = list;

    // עדכון הפריט
    final updatedItem = list.items[index].copyWith(
      isChecked: newStatus == 'taken',
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

  /// קיבוץ פריטים לפי קטגוריה
  Map<String, List<MapEntry<int, ReceiptItem>>> _groupByCategory(
    List<ReceiptItem> items,
  ) {
    final map = <String, List<MapEntry<int, ReceiptItem>>>{};

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      // קיבוץ לפי אות ראשונה של השם (במקום קטגוריה)
      final firstLetter = item.name.isNotEmpty
          ? item.name[0].toUpperCase()
          : '#';

      map.putIfAbsent(firstLetter, () => []);
      map[firstLetter]!.add(MapEntry(i, item));
    }

    return map;
  }

  /// בניית שורת פריט
  Widget _buildItemRow(BuildContext context, int index, ReceiptItem item) {
    final cs = Theme.of(context).colorScheme;
    final isChecked = item.isChecked;

    return ListTile(
      leading: Checkbox(
        value: isChecked,
        onChanged: (val) {
          final list = _getCurrentList(context);
          if (list != null) {
            _updateItemStatus(list, index, val == true ? 'taken' : 'pending');
          }
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
          ? Icon(Icons.check_circle, color: Colors.green)
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    // ✅ קבלת הרשימה מה-Provider
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

    // חישוב סטטיסטיקות
    final totalItems = list.items.length;
    final takenCount = list.items.where((item) => item.isChecked).length;
    final pendingCount = totalItems - takenCount;
    final progress = totalItems > 0 ? takenCount / totalItems : 0.0;

    // קיבוץ לפי קטגוריות
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
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: pendingCount == 0
                    ? null
                    : () => _markAllAsTaken(list),
                icon: const Icon(Icons.done_all),
                label: const Text('סמן הכל'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: takenCount == 0
                    ? null
                    : () => _resetAllStatuses(list),
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
