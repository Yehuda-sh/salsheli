// 📄 File: lib/screens/shopping/shopping_list_details_screen.dart - FIXED
//
// ✅ תיקונים:
// 1. שימוש ב-positional parameters במקום named parameters
// 2. החלפת updateItemInList ב-updateItemAt
// 3. תיקון כל הקריאות ל-Provider
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

class ShoppingListDetailsScreen extends StatelessWidget {
  final ShoppingList list;

  const ShoppingListDetailsScreen({super.key, required this.list});

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
                    // ➕ פריט חדש
                    // ✅ תיקון: positional parameters במקום named
                    provider.addItemToList(list.id, newItem);
                  } else if (index != null) {
                    // ✏️ עדכון פריט קיים
                    // ✅ תיקון: שימוש ב-updateItemAt עם function
                    provider.updateItemAt(list.id, index, (_) => newItem);
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

    // ✅ תיקון: positional parameters במקום named
    provider.removeItemFromList(list.id, index);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('המוצר "${removed.name ?? 'ללא שם'}" נמחק'),
        action: SnackBarAction(
          label: 'בטל',
          onPressed: () {
            // ✅ תיקון: positional parameters במקום named
            provider.addItemToList(list.id, removed);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShoppingListsProvider>();
    final currentList = provider.lists.firstWhere(
      (l) => l.id == list.id,
      orElse: () => list,
    );

    final theme = Theme.of(context);
    final items = currentList.items;
    final totalAmount = items.fold(0.0, (sum, item) => sum + item.totalPrice);

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(currentList.name)),
        body: Column(
          children: [
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_basket_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'הרשימה ריקה',
                            style: TextStyle(
                              fontSize: 18,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'לחץ על + להוספת מוצרים',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final formattedPrice = NumberFormat.simpleCurrency(
                          locale: 'he_IL',
                        ).format(item.totalPrice);

                        return Card(
                          child: ListTile(
                            title: Text(
                              item.name ?? 'ללא שם',
                              style: theme.textTheme.titleLarge,
                            ),
                            subtitle: Text(
                              "כמות: ${item.quantity} | מחיר כולל: $formattedPrice",
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  tooltip: "ערוך מוצר",
                                  onPressed: () => _showItemDialog(
                                    context,
                                    item: item,
                                    index: index,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  tooltip: "מחק מוצר",
                                  onPressed: () =>
                                      _deleteItem(context, index, item),
                                ),
                              ],
                            ),
                            onTap: () => _showItemDialog(
                              context,
                              item: item,
                              index: index,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.centerRight,
              child: Text(
                "סה״כ: ${NumberFormat.simpleCurrency(locale: 'he_IL').format(totalAmount)}",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
}
