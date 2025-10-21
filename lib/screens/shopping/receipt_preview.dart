// 📄 File: lib/screens/shopping/receipt_preview.dart
//
// 🎯 Purpose: Widget לעריכת קבלה אחרי OCR/סריקה - תצוגה מקדימה ועריכה
//
// ✨ Features:
// - ✏️ עריכת שם חנות ותאריך
// - ➕ הוספת פריטים חדשים
// - 🗑️ מחיקת פריטים עם Undo (2 שניות)
// - 🔢 עדכון אוטומטי של סכום כולל
// - ✅ Validation: שם חנות + לפחות פריט אחד
// - 📊 סטטיסטיקות: מספר פריטים + סה"כ
// - 🎨 Theme-aware + RTL
//
// 📦 Dependencies:
// - Receipt model (Receipt + ReceiptItem)
// - NumberFormat / DateFormat (intl package)
//
// 🎨 UI:
// - Header: שם חנות + תאריך + loading indicator
// - Items List: עריכה inline עם controllers
// - Empty State: "אין פריטים בקבלה" + CTA
// - Footer: סכום כולל + כפתורי שמירה/ביטול
//
// 📝 Usage:
// ```dart
// showDialog(
//   context: context,
//   builder: (context) => Dialog(
//     child: SizedBox(
//       width: MediaQuery.of(context).size.width * 0.9,
//       height: MediaQuery.of(context).size.height * 0.8,
//       child: ReceiptPreview(
//         receipt: scannedReceipt,
//         onSave: (editedReceipt) {
//           // שמור את הקבלה המעודכנת
//           Navigator.pop(context);
//         },
//         onCancel: () => Navigator.pop(context),
//         isProcessing: false,
//       ),
//     ),
//   ),
// );
// ```
//
// 🔗 Related:
// - receipt_scanner.dart - סורק קבלות עם OCR
// - receipt_manager_screen.dart - מסך ניהול קבלות
// - receipt_view_screen.dart - תצוגת קבלה בלבד (ללא עריכה)
//
// Version: 2.0 - Refactored with Constants + Logging
// Last Updated: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/receipt.dart';
import '../../core/ui_constants.dart';

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
    debugPrint('📝 ReceiptPreview.initState()');
    debugPrint('   📋 Receipt: ${widget.receipt.storeName}');
    debugPrint('   📦 Items: ${widget.receipt.items.length}');
    
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
    
    debugPrint('✅ ReceiptPreview.initState: הושלם');
  }

  @override
  void didUpdateWidget(covariant ReceiptPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.receipt != widget.receipt) {
      debugPrint('🔄 ReceiptPreview.didUpdateWidget: קבלה השתנתה');
      
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
      
      debugPrint('✅ ReceiptPreview.didUpdateWidget: עודכן');
    }
  }

  @override
  void dispose() {
    debugPrint('🗑️ ReceiptPreview.dispose()');
    
    // Dispose main controllers
    storeController.removeListener(_onStoreNameChanged);
    storeController.dispose();
    dateController.dispose();

    // Dispose all item controllers
    for (var controllers in itemControllersMap.values) {
      controllers.dispose();
    }

    debugPrint('✅ ReceiptPreview.dispose: הושלם');
    super.dispose();
  }

  void _initializeItemControllers() {
    debugPrint('🔧 _initializeItemControllers: ${editedReceipt.items.length} פריטים');
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
    debugPrint('✅ _initializeItemControllers: הושלם');
  }

  void _onStoreNameChanged() {
    debugPrint('✏️ _onStoreNameChanged: "${storeController.text}"');
    editedReceipt = Receipt(
      id: editedReceipt.id,
      storeName: storeController.text,
      date: editedReceipt.date,
      items: editedReceipt.items,
      totalAmount: editedReceipt.totalAmount,
      householdId: editedReceipt.householdId,
    );
  }

  void _updateItem(int index, ReceiptItem updated) {
    debugPrint('✏️ _updateItem: index=$index, name="${updated.name}"');
    debugPrint('   🔢 quantity=${updated.quantity}, price=₪${updated.unitPrice}');
    
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
        householdId: editedReceipt.householdId,
      );

      // Update controllers if needed
      if (itemControllersMap[index] != null) {
        itemControllersMap[index]!.updateValues(updated);
      }
    });
    
    debugPrint('✅ _updateItem: סה"כ חדש = ₪$newTotal');
  }

  void _removeItem(int index) {
    final removedItem = editedReceipt.items[index];
    debugPrint('🗑️ _removeItem: index=$index, name="${removedItem.name}"');

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
        householdId: editedReceipt.householdId,
      );

      // Adjust editing index if needed
      if (editingItemIndex == index) {
        editingItemIndex = null;
      } else if (editingItemIndex != null && editingItemIndex! > index) {
        editingItemIndex = editingItemIndex! - 1;
      }
    });
    
    debugPrint('✅ _removeItem: נותרו ${updatedItems.length} פריטים');

    // Undo - שמור messenger לפני async
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    
    messenger.showSnackBar(
      SnackBar(
        content: const Text('הפריט הוסר'),
        action: SnackBarAction(
          label: 'ביטול',
          onPressed: () {
            debugPrint('↩️ Undo: מחזיר פריט "${removedItem.name}"');
            final items = [...editedReceipt.items];
            items.insert(index, removedItem);
            setState(() {
              editedReceipt = Receipt(
                id: editedReceipt.id,
                storeName: editedReceipt.storeName,
                date: editedReceipt.date,
                items: items,
                totalAmount: _calculateTotal(items),
                householdId: editedReceipt.householdId,
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
            debugPrint('✅ Undo: פריט הוחזר');
          },
        ),
        duration: kSnackBarDuration,
      ),
    );
  }

  void _addNewItem() {
    debugPrint('➕ _addNewItem: יוצר פריט חדש');
    
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
        householdId: editedReceipt.householdId,
      );
      editingItemIndex = newIndex; // Start editing the new item
    });
    
    debugPrint('✅ _addNewItem: פריט נוסף, סה"כ ${updatedItems.length} פריטים');
  }

  double _calculateTotal(List<ReceiptItem> items) {
    final total = items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
    debugPrint('💰 _calculateTotal: סה"כ = ₪${total.toStringAsFixed(2)}');
    return total;
  }

  Future<void> _selectDate() async {
    debugPrint('📅 _selectDate: פותח בחירת תאריך');
    
    final picked = await showDatePicker(
      context: context,
      initialDate: editedReceipt.date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('he', 'IL'),
    );

    if (picked != null && picked != editedReceipt.date) {
      debugPrint('✅ _selectDate: תאריך נבחר - ${dateFormatter.format(picked)}');
      setState(() {
        editedReceipt = Receipt(
          id: editedReceipt.id,
          storeName: editedReceipt.storeName,
          date: picked,
          items: editedReceipt.items,
          totalAmount: editedReceipt.totalAmount,
          householdId: editedReceipt.householdId,
        );
        dateController.text = dateFormatter.format(picked);
      });
    } else {
      debugPrint('❌ _selectDate: בוטל או לא השתנה');
    }
  }

  void _save() {
    debugPrint('💾 _save: מנסה לשמור');
    
    // Validate before saving
    if (editedReceipt.storeName.trim().isEmpty) {
      debugPrint('❌ _save: שם חנות ריק');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('שם החנות חובה'),
          backgroundColor: Colors.red,
          duration: kSnackBarDuration,
        ),
      );
      return;
    }

    if (editedReceipt.items.isEmpty) {
      debugPrint('❌ _save: אין פריטים');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('הקבלה חייבת להכיל לפחות פריט אחד'),
          backgroundColor: Colors.red,
          duration: kSnackBarDuration,
        ),
      );
      return;
    }

    debugPrint('✅ _save: Validation עבר, מפעיל callback');
    widget.onSave(editedReceipt);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎨 ReceiptPreview.build()');
    
    return Card(
      margin: EdgeInsets.all(kSpacingMedium),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(kSpacingMedium),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(kBorderRadiusLarge),
                topRight: Radius.circular(kBorderRadiusLarge),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long, size: kIconSizeLarge + 4),
                    SizedBox(width: kSpacingSmall),
                    Text(
                      'עריכת קבלה',
                      style: TextStyle(
                        fontSize: kFontSizeLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (widget.isProcessing)
                      SizedBox(
                        width: kIconSizeMedium,
                        height: kIconSizeMedium,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                SizedBox(height: kSpacingMedium),

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
                            borderRadius: BorderRadius.circular(kBorderRadius),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLength: 50,
                      ),
                    ),
                    SizedBox(width: kSpacingSmallPlus),
                    Expanded(
                      child: TextField(
                        controller: dateController,
                        decoration: InputDecoration(
                          labelText: 'תאריך',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(kBorderRadius),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: kSpacingMedium,
                      vertical: kSpacingSmallPlus,
                    ),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Text(
                          'פריטים',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: kFontSizeBody,
                          ),
                        ),
                        SizedBox(width: kSpacingSmall),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: kSpacingSmall,
                            vertical: kSpacingXTiny,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                          ),
                          child: Text(
                            '${editedReceipt.items.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: kFontSizeSmall,
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          icon: Icon(Icons.add, size: kIconSizeSmall + 2),
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
                                  size: kIconSizeXLarge,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: kSpacingMedium),
                                Text(
                                  'אין פריטים בקבלה',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: kFontSizeBody,
                                  ),
                                ),
                                SizedBox(height: kSpacingSmall),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.add),
                                  label: const Text('הוסף פריט ראשון'),
                                  onPressed: _addNewItem,
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.symmetric(vertical: kSpacingSmall),
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
                                padding: EdgeInsets.symmetric(
                                  horizontal: kSpacingMedium,
                                  vertical: kSpacingSmallPlus,
                                ),
                                child: Row(
                                  children: [
                                    // Item number
                                    Container(
                                      width: kIconSize,
                                      height: kIconSize,
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).primaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(kBorderRadiusSmall + 3),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: kFontSizeSmall,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: kSpacingSmallPlus),

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
                                                      horizontal: kSpacingSmall,
                                                      vertical: kSpacingSmall,
                                                    ),
                                              ),
                                              autofocus: true,
                                              maxLength: 50,
                                              onSubmitted: (value) {
                                                final trimmed = value.trim();
                                                if (trimmed.isNotEmpty) {
                                                  _updateItem(
                                                    index,
                                                    item.copyWith(
                                                      name: trimmed,
                                                    ),
                                                  );
                                                  setState(
                                                    () =>
                                                        editingItemIndex = null,
                                                  );
                                                } else {
                                                  debugPrint('⚠️ שם מוצר ריק - לא מעדכן');
                                                }
                                              },
                                            )
                                          : InkWell(
                                              onTap: () => setState(
                                                () => editingItemIndex = index,
                                              ),
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.symmetric(
                                                      vertical: kSpacingSmall,
                                                    ),
                                                child: Text(
                                                  item.name ?? 'ללא שם',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: kFontSizeBody,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ),
                                    ),
                                    SizedBox(width: kSpacingSmall),

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
                                            horizontal: kSpacingSmall,
                                            vertical: kSpacingSmall,
                                          ),
                                        ),
                                        onChanged: (value) {
                                          final qty = int.tryParse(value);
                                          if (qty != null && qty > 0) {
                                            final updated = item.copyWith(
                                              quantity: qty,
                                            );
                                            _updateItem(index, updated);
                                          } else {
                                            debugPrint('⚠️ כמות לא תקינה: $value');
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(width: kSpacingTiny),
                                    const Text('×'),
                                    SizedBox(width: kSpacingTiny),

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
                                            horizontal: kSpacingSmall,
                                            vertical: kSpacingSmall,
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
                                            );
                                            _updateItem(index, updated);
                                          } else {
                                            debugPrint('⚠️ מחיר לא תקין: $value');
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(width: kSpacingSmall),
                                    const Text('='),
                                    SizedBox(width: kSpacingSmall),

                                    // Total price
                                    SizedBox(
                                      width: 80,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: kSpacingSmall,
                                          vertical: kSpacingSmall,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            kSpacingTiny,
                                          ),
                                        ),
                                        child: Text(
                                          currencyFormatter.format(
                                            item.totalPrice,
                                          ),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: kFontSizeSmall,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: kSpacingSmall),

                                    // Delete button
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      iconSize: kIconSizeMedium,
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
                    padding: EdgeInsets.all(kSpacingMedium),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey[300]!, width: 2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'סה״כ לתשלום:',
                          style: TextStyle(
                            fontSize: kFontSizeMedium,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currencyFormatter.format(editedReceipt.totalAmount),
                          style: TextStyle(
                            fontSize: kFontSizeXLarge,
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
            padding: EdgeInsets.all(kSpacingMedium),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(kBorderRadiusLarge),
                bottomRight: Radius.circular(kBorderRadiusLarge),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.isProcessing ? null : () {
                    debugPrint('❌ Cancel: משתמש ביטל');
                    widget.onCancel();
                  },
                  child: const Text('ביטול'),
                ),
                SizedBox(width: kSpacingSmallPlus),
                ElevatedButton.icon(
                  onPressed: widget.isProcessing ? null : _save,
                  icon: widget.isProcessing
                      ? SizedBox(
                          width: kIconSizeSmall,
                          height: kIconSizeSmall,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(widget.isProcessing ? 'שומר...' : 'שמור קבלה'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: kSpacingLarge,
                      vertical: kSpacingSmallPlus,
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
