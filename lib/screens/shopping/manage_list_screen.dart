// 📄 File: lib/screens/shopping/manage_list_screen.dart
//
// 🎯 Purpose: מסך ניהול רשימת קניות - עריכת פריטים, מחיקה, סימון
//
// ✨ Features:
// - 📊 סטטיסטיקות: פריטים, סה"כ, כמות
// - ➕ הוספת פריטים ידנית (שם, כמות, מחיר)
// - ✏️ עריכת פריטים: סימון/ביטול סימון
// - 🗑️ מחיקה עם אישור (Dismissible + Dialog)
// - 🎯 ניווט לקנייה פעילה
// - 📱 3 Empty States: Loading/Error/Empty
//
// 📦 Dependencies:
// - ShoppingListsProvider: CRUD על רשימות
// - ShoppingList model: מבנה הרשימה
// - ReceiptItem model: מבנה פריט
//
// 🎨 UI:
// - Header: סטטיסטיקות בכרטיס כחול
// - ListView: רשימת פריטים עם Dismissible
// - FAB: הוספת פריט חדש
// - Empty State: אייקון + טקסט
// - Error State: retry button
//
// 📝 Usage:
// ```dart
// Navigator.pushNamed(
//   context,
//   '/manage-list',
//   arguments: {
//     'list': myShoppingList,
//   },
// );
// ```
//
// 🔗 Related:
// - active_shopping_screen.dart - מסך קנייה פעילה
// - shopping_lists_screen.dart - רשימת כל הרשימות
// - populate_list_screen.dart - מילוי רשימה ממקורות
//
// Version: 2.1 - Fixed compilation errors
// Last Updated: 09/10/2025
//

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/shopping_list.dart';
import '../../models/receipt.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../theme/app_theme.dart';
import '../../core/ui_constants.dart';

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
  @override
  void initState() {
    super.initState();
    debugPrint('📋 ManageListScreen.initState() | listId: ${widget.listId}');
  }

  @override
  void dispose() {
    debugPrint('🗑️ ManageListScreen.dispose()');
    super.dispose();
  }

  /// דיאלוג הוספת פריט ידני
  Future<void> _showAddCustomItemDialog(ShoppingListsProvider provider) async {
    debugPrint('➕ _showAddCustomItemDialog()');
    
    final nameController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    final priceController = TextEditingController(text: '0');

    // שמירת messenger לפני async
    final messenger = ScaffoldMessenger.of(context);

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
                SizedBox(height: kSpacingSmallPlus),
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
                    SizedBox(width: kSpacingSmallPlus),
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
                onPressed: () {
                  debugPrint('❌ ביטול הוספת פריט');
                  Navigator.pop(ctx);
                },
                child: const Text('ביטול'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    debugPrint('⚠️ שם פריט ריק');
                    return;
                  }

                  final qty = int.tryParse(qtyController.text.trim()) ?? 1;
                  final price =
                      double.tryParse(priceController.text.trim()) ?? 0.0;

                  debugPrint('➕ מוסיף פריט: "$name" x$qty = ₪$price');

                  final newItem = ReceiptItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    quantity: qty,
                    unitPrice: price,
                    isChecked: false,
                  );

                  try {
                    await provider.addItemToList(widget.listId, newItem);
                    debugPrint('✅ פריט "$name" נוסף בהצלחה');

                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('✅ $name נוסף לרשימה'),
                          duration: kSnackBarDuration,
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint('❌ שגיאה בהוספת פריט: $e');
                    if (ctx.mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('❌ שגיאה: ${e.toString()}'),
                          duration: kSnackBarDurationLong,
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
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

  /// מחיקת פריט עם אישור
  Future<void> _deleteItem(
    BuildContext context,
    ShoppingListsProvider provider,
    int index,
    ReceiptItem item,
  ) async {
    debugPrint('🗑️ _deleteItem() | index: $index, item: ${item.name}');

    // שמירת messenger לפני async
    final messenger = ScaffoldMessenger.of(context);

    try {
      await provider.removeItemFromList(widget.listId, index);
      debugPrint('✅ פריט "${item.name}" נמחק');

      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('"${item.name ?? 'ללא שם'}" הוסר'),
            behavior: SnackBarBehavior.floating,
            duration: kSnackBarDuration,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ שגיאה במחיקת פריט: $e');
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('❌ שגיאה: ${e.toString()}'),
            duration: kSnackBarDurationLong,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// סימון/ביטול סימון פריט
  Future<void> _toggleItem(
    ShoppingListsProvider provider,
    int index,
    ReceiptItem item,
  ) async {
    debugPrint('✔️ _toggleItem() | index: $index, current: ${item.isChecked}');

    try {
      await provider.updateItemAt(
        widget.listId,
        index,
        (currentItem) => currentItem.copyWith(
          isChecked: !currentItem.isChecked,
        ),
      );
      debugPrint('✅ פריט "${item.name}" עודכן');
    } catch (e) {
      debugPrint('❌ שגיאה בעדכון פריט: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ שגיאה: ${e.toString()}'),
            duration: kSnackBarDuration,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Loading State
  Widget _buildLoading(ColorScheme cs) {
    debugPrint('⏳ _buildLoading()');
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(widget.listName),
        backgroundColor: cs.surface,
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Error State
  Widget _buildError(ColorScheme cs, ShoppingListsProvider provider) {
    debugPrint('❌ _buildError()');
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(widget.listName),
        backgroundColor: cs.surface,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: kIconSizeXLarge,
              color: cs.error,
            ),
            SizedBox(height: kSpacingMedium),
            Text(
              'שגיאה בטעינת הרשימה',
              style: TextStyle(
                fontSize: kFontSizeMedium,
                color: cs.onSurface,
              ),
            ),
            SizedBox(height: kSpacingSmall),
            ElevatedButton.icon(
              onPressed: () {
                debugPrint('🔄 retry - טוען מחדש');
                provider.retry();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('נסה שוב'),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty State
  Widget _buildEmpty(ColorScheme cs) {
    debugPrint('📭 _buildEmpty()');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: kIconSizeXLarge,
            color: cs.onSurfaceVariant,
          ),
          SizedBox(height: kSpacingMedium),
          Text(
            'הרשימה ריקה',
            style: TextStyle(
              fontSize: kFontSizeMedium,
              color: cs.onSurfaceVariant,
            ),
          ),
          SizedBox(height: kSpacingSmall),
          Text(
            'לחץ על כפתור + להוספת פריטים',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  /// סטטיסטיקות Header
  Widget _buildStatsHeader(ShoppingList list, ColorScheme cs) {
    // חישוב סטטיסטיקות
    final totalAmount = list.items.fold<double>(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );
    final totalQuantity = list.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    debugPrint('📊 סטטיסטיקות: ${list.items.length} פריטים, ₪$totalAmount, כמות: $totalQuantity');

    return Container(
      padding: EdgeInsets.all(kSpacingMedium),
      margin: EdgeInsets.all(kSpacingMedium),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(kBorderRadius),
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
  }

  /// פריט סטטיסטיקה בודד
  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    ColorScheme cs,
  ) {
    return Column(
      children: [
        Icon(icon, color: cs.onPrimaryContainer, size: kIconSize),
        SizedBox(height: kSpacingTiny),
        Text(
          value,
          style: TextStyle(
            fontSize: kFontSizeMedium,
            fontWeight: FontWeight.bold,
            color: cs.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: kFontSizeSmall,
            color: cs.onPrimaryContainer,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎨 ManageListScreen.build()');
    
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    final provider = context.watch<ShoppingListsProvider>();
    final list = provider.getById(widget.listId);

    // Loading State
    if (provider.isLoading && list == null) {
      return _buildLoading(cs);
    }

    // Error State
    if (provider.hasError) {
      return _buildError(cs, provider);
    }

    // List not found
    if (list == null) {
      debugPrint('❌ רשימה ${widget.listId} לא נמצאה');
      return Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: const Text('שגיאה'),
          backgroundColor: cs.surface,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: kIconSizeXLarge,
                color: cs.error,
              ),
              SizedBox(height: kSpacingMedium),
              Text(
                'רשימה לא נמצאה',
                style: TextStyle(
                  fontSize: kFontSizeMedium,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Content
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
                debugPrint('▶️ ניווט לקנייה פעילה');
                Navigator.pushNamed(
                  context,
                  '/active-shopping',
                  arguments: list,
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Header - סטטיסטיקות
            _buildStatsHeader(list, cs),

            // רשימת פריטים
            Expanded(
              child: list.items.isEmpty
                  ? _buildEmpty(cs)
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: kSpacingMedium),
                      itemCount: list.items.length,
                      itemBuilder: (context, index) {
                        final item = list.items[index];
                        return Dismissible(
                          key: Key(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: kSpacingMedium),
                            color: cs.error,
                            child: Icon(
                              Icons.delete,
                              color: cs.onError,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            debugPrint('❓ confirmDismiss | פריט: ${item.name}');
                            return await showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('אישור מחיקה'),
                                    content: Text(
                                        'למחוק את "${item.name ?? 'ללא שם'}"?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          debugPrint('❌ ביטול מחיקה');
                                          Navigator.pop(ctx, false);
                                        },
                                        child: const Text('ביטול'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          debugPrint('✅ אישור מחיקה');
                                          Navigator.pop(ctx, true);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: cs.error,
                                          foregroundColor: cs.onError,
                                        ),
                                        child: const Text('מחק'),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;
                          },
                          onDismissed: (_) async {
                            await _deleteItem(
                              context,
                              provider,
                              index,
                              item,
                            );
                          },
                          child: Card(
                            margin: EdgeInsets.only(bottom: kSpacingSmall),
                            child: ListTile(
                              title: Text(item.name ?? 'ללא שם'),
                              subtitle: Text(
                                "${item.quantity} × ₪${item.unitPrice.toStringAsFixed(2)} = ₪${item.totalPrice.toStringAsFixed(2)}",
                              ),
                              trailing: Checkbox(
                                value: item.isChecked,
                                onChanged: (_) async {
                                  await _toggleItem(provider, index, item);
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
          foregroundColor: cs.onPrimary,
          icon: const Icon(Icons.add),
          label: const Text('הוסף פריט'),
        ),
      ),
    );
  }
}
