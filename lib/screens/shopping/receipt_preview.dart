// 📄 File: lib/screens/shopping/receipt_preview.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/receipt.dart';

class ReceiptPreview extends StatefulWidget {
  final Receipt receipt;
  final ValueChanged<Receipt> onSave;
  final VoidCallback onCancel;
  final bool isProcessing;

  const ReceiptPreview({
    super.key,
    required this.receipt,
    required this.onSave,
    required this.onCancel,
    this.isProcessing = false,
  });

  @override
  State<ReceiptPreview> createState() => _ReceiptPreviewState();
}

class _ReceiptPreviewState extends State<ReceiptPreview> {
  late Receipt editedReceipt;
  int? editingItemIndex;

  // Controllers קבועים למניעת recreate בכל build
  late TextEditingController storeController;
  late TextEditingController dateController;
  final Map<int, ItemControllers> itemControllersMap = {};

  // Format helpers
  final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'he_IL',
    symbol: '₪',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    editedReceipt = widget.receipt;

    // Initialize main controllers
    storeController = TextEditingController(text: editedReceipt.storeName);
    dateController = TextEditingController(
      text: dateFormatter.format(editedReceipt.date),
    );

    // Initialize item controllers
    _initializeItemControllers();

    // Add listeners
    storeController.addListener(_onStoreNameChanged);
  }

  @override
  void didUpdateWidget(covariant ReceiptPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.receipt != widget.receipt) {
      // נקה מאזינים ישנים
      storeController.removeListener(_onStoreNameChanged);

      // עדכון receipt
      editedReceipt = widget.receipt;

      // עדכון שדות ראשיים
      storeController.text = editedReceipt.storeName;
      dateController.text = dateFormatter.format(editedReceipt.date);

      // Dispose + Rebuild item controllers
      for (final c in itemControllersMap.values) {
        c.dispose();
      }
      itemControllersMap.clear();
      _initializeItemControllers();

      // מאזין מחדש
      storeController.addListener(_onStoreNameChanged);

      setState(() {
        editingItemIndex = null;
      });
    }
  }

  @override
  void dispose() {
    // Dispose main controllers
    storeController.removeListener(_onStoreNameChanged);
    storeController.dispose();
    dateController.dispose();

    // Dispose all item controllers
    for (var controllers in itemControllersMap.values) {
      controllers.dispose();
    }

    super.dispose();
  }

  void _initializeItemControllers() {
    for (int i = 0; i < editedReceipt.items.length; i++) {
      final item = editedReceipt.items[i];
      itemControllersMap[i] = ItemControllers(
        name: TextEditingController(text: item.name ?? 'ללא שם'),
        quantity: TextEditingController(text: item.quantity.toString()),
        unitPrice: TextEditingController(
          text: item.unitPrice.toStringAsFixed(2),
        ),
      );
    }
  }

  void _onStoreNameChanged() {
    editedReceipt = Receipt(
      id: editedReceipt.id,
      storeName: storeController.text,
      date: editedReceipt.date,
      items: editedReceipt.items,
      totalAmount: editedReceipt.totalAmount,
    );
  }

  void _updateItem(int index, ReceiptItem updated) {
    final updatedItems = [...editedReceipt.items];
    updatedItems[index] = updated;

    final newTotal = _calculateTotal(updatedItems);

    setState(() {
      editedReceipt = Receipt(
        id: editedReceipt.id,
        storeName: editedReceipt.storeName,
        date: editedReceipt.date,
        items: updatedItems,
        totalAmount: newTotal,
      );

      // Update controllers if needed
      if (itemControllersMap[index] != null) {
        itemControllersMap[index]!.updateValues(updated);
      }
    });
  }

  void _removeItem(int index) {
    final removedItem = editedReceipt.items[index];

    // Remove item from list
    final updatedItems = [...editedReceipt.items]..removeAt(index);

    // Dispose and remove controllers for this item
    itemControllersMap[index]?.dispose();

    // Reindex controllers
    final newControllersMap = <int, ItemControllers>{};
    itemControllersMap.forEach((key, value) {
      if (key < index) {
        newControllersMap[key] = value;
      } else if (key > index) {
        newControllersMap[key - 1] = value;
      }
    });

    itemControllersMap
      ..clear()
      ..addAll(newControllersMap);

    // Calculate new total
    final newTotal = _calculateTotal(updatedItems);

    setState(() {
      editedReceipt = Receipt(
        id: editedReceipt.id,
        storeName: editedReceipt.storeName,
        date: editedReceipt.date,
        items: updatedItems,
        totalAmount: newTotal,
      );

      // Adjust editing index if needed
      if (editingItemIndex == index) {
        editingItemIndex = null;
      } else if (editingItemIndex != null && editingItemIndex! > index) {
        editingItemIndex = editingItemIndex! - 1;
      }
    });

    // Undo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('הפריט הוסר'),
        action: SnackBarAction(
          label: 'ביטול',
          onPressed: () {
            final items = [...editedReceipt.items];
            items.insert(index, removedItem);
            setState(() {
              editedReceipt = Receipt(
                id: editedReceipt.id,
                storeName: editedReceipt.storeName,
                date: editedReceipt.date,
                items: items,
                totalAmount: _calculateTotal(items),
              );
              // שיקום controllers לפריט המחוזר
              final c = ItemControllers(
                name: TextEditingController(text: removedItem.name ?? 'ללא שם'),
                quantity: TextEditingController(
                  text: removedItem.quantity.toString(),
                ),
                unitPrice: TextEditingController(
                  text: removedItem.unitPrice.toStringAsFixed(2),
                ),
              );
              // הסטה קדימה של אינדקסים קיימים
              final shifted = <int, ItemControllers>{};
              itemControllersMap.forEach((k, v) {
                shifted[k >= index ? k + 1 : k] = v;
              });
              itemControllersMap
                ..clear()
                ..addAll(shifted)
                ..[index] = c;
            });
          },
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addNewItem() {
    // ✅ יצירת פריט חדש דרך מפעל ה־manual (אין צורך ב־id / totalPrice)
    final newItem = ReceiptItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'מוצר חדש',
      quantity: 1,
      unitPrice: 0.0,
      isChecked: false,
    );

    final updatedItems = [...editedReceipt.items, newItem];
    final newIndex = updatedItems.length - 1;

    // Add controllers for new item
    itemControllersMap[newIndex] = ItemControllers(
      name: TextEditingController(text: newItem.name ?? 'מוצר חדש'),
      quantity: TextEditingController(text: '1'),
      unitPrice: TextEditingController(text: '0.00'),
    );

    setState(() {
      editedReceipt = Receipt(
        id: editedReceipt.id,
        storeName: editedReceipt.storeName,
        date: editedReceipt.date,
        items: updatedItems,
        totalAmount: _calculateTotal(updatedItems),
      );
      editingItemIndex = newIndex; // Start editing the new item
    });
  }

  double _calculateTotal(List<ReceiptItem> items) {
    // totalPrice הוא getter נגזר (quantity * unitPrice)
    return items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: editedReceipt.date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('he', 'IL'),
      // builder הוסר – אין צורך לאלץ RTL; ה-Directionality של האפליקציה כבר עושה את זה
    );

    if (picked != null && picked != editedReceipt.date) {
      setState(() {
        editedReceipt = Receipt(
          id: editedReceipt.id,
          storeName: editedReceipt.storeName,
          date: picked,
          items: editedReceipt.items,
          totalAmount: editedReceipt.totalAmount,
        );
        dateController.text = dateFormatter.format(picked);
      });
    }
  }

  void _save() {
    // Validate before saving
    if (editedReceipt.storeName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('שם החנות חובה'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (editedReceipt.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('הקבלה חייבת להכיל לפחות פריט אחד'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.onSave(editedReceipt);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long, size: 28),
                    const SizedBox(width: 8),
                    const Text(
                      'עריכת קבלה',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (widget.isProcessing)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Store and Date
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: storeController,
                        decoration: InputDecoration(
                          labelText: 'שם החנות',
                          prefixIcon: const Icon(Icons.store),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: dateController,
                        decoration: InputDecoration(
                          labelText: 'תאריך',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        readOnly: true,
                        onTap: _selectDate,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Items List
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: Column(
                children: [
                  // Items header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    color: Colors.white,
                    child: Row(
                      children: [
                        const Text(
                          'פריטים',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${editedReceipt.items.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('הוסף פריט'),
                          onPressed: _addNewItem,
                        ),
                      ],
                    ),
                  ),

                  // Items list
                  Expanded(
                    child: editedReceipt.items.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'אין פריטים בקבלה',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.add),
                                  label: const Text('הוסף פריט ראשון'),
                                  onPressed: _addNewItem,
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: editedReceipt.items.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = editedReceipt.items[index];
                              final controllers = itemControllersMap[index];
                              final isEditing = editingItemIndex == index;

                              if (controllers == null) return const SizedBox();

                              return Container(
                                color: isEditing
                                    ? Colors.blue[50]
                                    : Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    // Item number
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).primaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Name field
                                    Expanded(
                                      flex: 3,
                                      child: isEditing
                                          ? TextField(
                                              controller: controllers.name,
                                              decoration: const InputDecoration(
                                                labelText: 'שם המוצר',
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 8,
                                                    ),
                                              ),
                                              autofocus: true,
                                              onSubmitted: (value) {
                                                if (value.trim().isNotEmpty) {
                                                  _updateItem(
                                                    index,
                                                    item.copyWith(
                                                      name: value.trim(),
                                                    ),
                                                  );
                                                  setState(
                                                    () =>
                                                        editingItemIndex = null,
                                                  );
                                                }
                                              },
                                            )
                                          : InkWell(
                                              onTap: () => setState(
                                                () => editingItemIndex = index,
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                                child: Text(
                                                  item.name ?? 'ללא שם',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Quantity field
                                    SizedBox(
                                      width: 60,
                                      child: TextField(
                                        controller: controllers.quantity,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          labelText: 'כמות',
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 8,
                                          ),
                                        ),
                                        onChanged: (value) {
                                          final qty = int.tryParse(value);
                                          if (qty != null && qty > 0) {
                                            final updated = item.copyWith(
                                              quantity: qty,
                                              // ❌ אין totalPrice ב-copyWith – הוא נגזר
                                            );
                                            _updateItem(index, updated);
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text('×'),
                                    const SizedBox(width: 4),

                                    // Unit price field
                                    SizedBox(
                                      width: 80,
                                      child: TextField(
                                        controller: controllers.unitPrice,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9\.,]'),
                                          ),
                                        ],
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          labelText: 'מחיר',
                                          prefixText: '₪',
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 8,
                                          ),
                                        ),
                                        onChanged: (value) {
                                          final normalized = value.replaceAll(
                                            ',',
                                            '.',
                                          );
                                          final price = double.tryParse(
                                            normalized,
                                          );
                                          if (price != null && price >= 0) {
                                            final updated = item.copyWith(
                                              unitPrice: price,
                                              // ❌ אין totalPrice ב-copyWith – הוא נגזר
                                            );
                                            _updateItem(index, updated);
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('='),
                                    const SizedBox(width: 8),

                                    // Total price
                                    SizedBox(
                                      width: 80,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          currencyFormatter.format(
                                            item.totalPrice,
                                          ),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Delete button
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      iconSize: 20,
                                      onPressed: () => _removeItem(index),
                                      tooltip: 'מחק פריט',
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  // Total
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey[300]!, width: 2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'סה״כ לתשלום:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currencyFormatter.format(editedReceipt.totalAmount),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.isProcessing ? null : widget.onCancel,
                  child: const Text('ביטול'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: widget.isProcessing ? null : _save,
                  icon: widget.isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(widget.isProcessing ? 'שומר...' : 'שמור קבלה'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper class for managing item controllers
class ItemControllers {
  final TextEditingController name;
  final TextEditingController quantity;
  final TextEditingController unitPrice;

  ItemControllers({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  void updateValues(ReceiptItem item) {
    // Update only if values changed to avoid cursor issues
    final itemName = item.name ?? 'ללא שם';
    if (name.text != itemName) {
      name.text = itemName;
    }
    if (quantity.text != item.quantity.toString()) {
      quantity.text = item.quantity.toString();
    }
    final priceText = item.unitPrice.toStringAsFixed(2);
    if (unitPrice.text != priceText) {
      unitPrice.text = priceText;
    }
  }

  void dispose() {
    name.dispose();
    quantity.dispose();
    unitPrice.dispose();
  }
}
