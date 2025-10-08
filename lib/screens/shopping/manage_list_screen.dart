// 📄 File: lib/screens/shopping/manage_list_screen.dart - FIXED
//
// ✅ תיקונים:
// 1. שימוש נכון ב-API של ShoppingListsProvider (positional parameters)
// 2. תיקון addItemToList - ללא named parameters
// 3. תיקון removeItemFromList - ללא named parameters
// 4. החלפת toggleItemChecked ב-updateItemAt
// 5. שימוש ב-PopScope במקום WillPopScope (deprecated)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/shopping_list.dart';
import '../../models/receipt.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../theme/app_theme.dart';

class ManageListScreen extends StatefulWidget {
  final String listName;
  final String listId;

  const ManageListScreen({
    super.key,
    required this.listName,
    required this.listId,
  });

  @override
  State<ManageListScreen> createState() => _ManageListScreenState();
}

class _ManageListScreenState extends State<ManageListScreen> {
  final _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  /// קבלת הרשימה מה-Provider
  ShoppingList? _getList(BuildContext context) {
    final provider = context.watch<ShoppingListsProvider>();
    return provider.getById(widget.listId);
  }

  /// דיאלוג הוספת פריט ידני
  Future<void> _showAddCustomItemDialog(ShoppingListsProvider provider) async {
    final nameController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    final priceController = TextEditingController(text: '0');

    await showDialog(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('הוסף פריט חדש'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'שם המוצר',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: qtyController,
                        decoration: const InputDecoration(
                          labelText: 'כמות',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'מחיר',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('ביטול'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;

                  final qty = int.tryParse(qtyController.text.trim()) ?? 1;
                  final price =
                      double.tryParse(priceController.text.trim()) ?? 0.0;

                  final newItem = ReceiptItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    quantity: qty,
                    unitPrice: price,
                    isChecked: false,
                  );

                  // ✅ תיקון: positional parameters
                  await provider.addItemToList(widget.listId, newItem);

                  // שמור messenger לפני async
                  final messenger = ScaffoldMessenger.of(context);
                  
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('✅ $name נוסף לרשימה'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text('הוסף'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    final list = _getList(context);

    if (_isLoading || list == null) {
      return Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: Text(widget.listName),
          backgroundColor: cs.surface,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final provider = context.read<ShoppingListsProvider>();

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: Text(widget.listName),
          backgroundColor: cs.surface,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.play_arrow),
              tooltip: 'התחל קניה',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/active-shopping',
                  arguments: {
                    'listName': widget.listName,
                    'listId': widget.listId,
                  },
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Header - סטטיסטיקות
            Builder(
              builder: (context) {
                // חישוב סטטיסטיקות מקומי (getters נמחקו)
                final totalAmount = list.items.fold<double>(
                  0.0,
                  (sum, item) => sum + item.totalPrice,
                );
                final totalQuantity = list.items.fold<int>(
                  0,
                  (sum, item) => sum + item.quantity,
                );

                return Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'פריטים',
                        '${list.items.length}',
                        Icons.shopping_cart,
                        cs,
                      ),
                      _buildStatItem(
                        'סה"כ',
                        '₪${totalAmount.toStringAsFixed(2)}',
                        Icons.account_balance_wallet,
                        cs,
                      ),
                      _buildStatItem(
                        'כמות',
                        '$totalQuantity',
                        Icons.format_list_numbered,
                        cs,
                      ),
                    ],
                  ),
                );
              },
            ),

            // רשימת פריטים
            Expanded(
              child: list.items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_basket_outlined,
                            size: 64,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'הרשימה ריקה',
                            style: TextStyle(
                              fontSize: 18,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'לחץ על כפתור + להוספת פריטים',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: list.items.length,
                      itemBuilder: (context, index) {
                        final item = list.items[index];
                        return Dismissible(
                          key: Key(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('אישור מחיקה'),
                                    content: Text('למחוק את "${item.name ?? 'ללא שם'}"?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('ביטול'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: const Text('מחק'),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;
                          },
                          onDismissed: (_) async {
                            // ✅ תיקון: positional parameters
                            await provider.removeItemFromList(
                              widget.listId,
                              index,
                            );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('"${item.name ?? 'ללא שם'}" הוסר'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(item.name ?? 'ללא שם'),
                              subtitle: Text(
                                "${item.quantity} × ₪${item.unitPrice.toStringAsFixed(2)} = ₪${item.totalPrice.toStringAsFixed(2)}",
                              ),
                              trailing: Checkbox(
                                value: item.isChecked,
                                onChanged: (_) async {
                                  // ✅ תיקון: שימוש ב-updateItemAt
                                  await provider.updateItemAt(
                                    widget.listId,
                                    index,
                                    (currentItem) => currentItem.copyWith(
                                      isChecked: !currentItem.isChecked,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddCustomItemDialog(provider),
          backgroundColor: accent,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('הוסף פריט'),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    ColorScheme cs,
  ) {
    return Column(
      children: [
        Icon(icon, color: cs.onPrimaryContainer, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: cs.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: cs.onPrimaryContainer),
        ),
      ],
    );
  }
}
