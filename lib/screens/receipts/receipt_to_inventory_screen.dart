// 📄 File: lib/screens/receipts/receipt_to_inventory_screen.dart
//
// 🎯 Purpose: מסך העברת פריטים מקבלה למלאי - Receipt to Inventory Screen
//
// 📋 Features:
// ✅ בחירת פריטים להעברה למלאי
// ✅ קביעת כמות ומיקום לכל פריט
// ✅ זיהוי פריטים קיימים במלאי
// ✅ 4 Empty States: Loading, Error, Empty, Data
// ✅ Error Recovery עם retry
// ✅ Logging מפורט
//
// 🔗 Dependencies:
// - InventoryProvider - ניהול מלאי
// - ReceiptToInventoryService - לוגיקת העברה
// - StorageLocationsConfig - מיקומים
//
// 📊 Flow:
// 1. טעינה: עיבוד פריטי הקבלה
// 2. בחירה: משתמש בוחר פריטים + מיקום
// 3. אישור: העברה למלאי
// 4. סיום: חזרה למסך קודם
//
// Version: 2.0 - Full Refactor with Error Handling
// Last Updated: 17/10/2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/receipt.dart';
import '../../providers/inventory_provider.dart';
import '../../services/receipt_to_inventory_service.dart';
import '../../config/storage_locations_config.dart';
import '../../core/ui_constants.dart';

class ReceiptToInventoryScreen extends StatefulWidget {
  final Receipt receipt;
  
  const ReceiptToInventoryScreen({
    super.key,
    required this.receipt,
  });

  @override
  State<ReceiptToInventoryScreen> createState() => _ReceiptToInventoryScreenState();
}

class _ReceiptToInventoryScreenState extends State<ReceiptToInventoryScreen> {
  late ReceiptToInventoryService _service;
  List<ReceiptToInventoryItem> _items = [];
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    debugPrint('📦 ReceiptToInventoryScreen: initState - Receipt from "${widget.receipt.storeName}"');
    _initializeService();
  }
  
  /// מאתחל את השירות ומעבד את פריטי הקבלה.
  /// טוען פריטים קיימים מהמלאי ומציע מיקומים.
  Future<void> _initializeService() async {
    debugPrint('🔄 _initializeService: מתחיל עיבוד ${widget.receipt.items.length} פריטים...');
    
    try {
      final inventoryProvider = context.read<InventoryProvider>();
      _service = ReceiptToInventoryService(inventoryProvider: inventoryProvider);
      
      // עבד את הקבלה
      final processedItems = await _service.processReceipt(widget.receipt);
      
      debugPrint('✅ _initializeService: עובדו ${processedItems.length} פריטים בהצלחה');
      
      if (!mounted) return;
      
      setState(() {
        _items = processedItems;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      debugPrint('❌ _initializeService: שגיאה - $e');
      
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'שגיאה בטעינת הקבלה: $e';
        _isLoading = false;
      });
    }
  }
  
  /// מאשר ומוסיף את הפריטים שנבחרו למלאי.
  /// מציג הודעת הצלחה/שגיאה ומחזיר למסך הקודם.
  Future<void> _confirmAndAddToInventory() async {
    final selectedCount = _items.where((item) => item.shouldAdd).length;
    debugPrint('✅ _confirmAndAddToInventory: מוסיף $selectedCount פריטים למלאי...');
    
    setState(() => _isProcessing = true);
    
    try {
      await _service.addApprovedItemsToInventory(_items);
      
      debugPrint('🎉 _confirmAndAddToInventory: הוספה הצליחה!');
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ $selectedCount פריטים נוספו למלאי בהצלחה!'),
          backgroundColor: Colors.green,
          duration: kSnackBarDuration,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('❌ _confirmAndAddToInventory: שגיאה - $e');
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ שגיאה בהוספת פריטים: $e'),
          backgroundColor: Colors.red,
          duration: kSnackBarDurationLong,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
  
  /// בונה כרטיס פריט לבחירה.
  /// 
  /// [item] - הפריט להצגה.
  /// [index] - אינדקס הפריט ברשימה.
  Widget _buildItemCard(ReceiptToInventoryItem item, int index) {
    final cs = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
      color: item.shouldAdd ? cs.surface : cs.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // כותרת עם checkbox
            Row(
              children: [
                Checkbox(
                  value: item.shouldAdd,
                  onChanged: (value) {
                    setState(() {
                      _items[index].shouldAdd = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(
                          fontSize: kFontSizeBody,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item.isNewItem)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'מוצר חדש',
                            style: TextStyle(fontSize: kFontSizeSmall, color: Colors.blue),
                          ),
                        )
                      else
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'קיים במלאי (${item.existingInventoryItem!.quantity} ${item.existingInventoryItem!.unit})',
                            style: const TextStyle(fontSize: kFontSizeSmall, color: Colors.green),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: kSpacingSmallPlus),
            
            // כמות ומיקום
            Row(
              children: [
                // כמות
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.numbers, size: kIconSizeSmall),
                      const SizedBox(width: kSpacingSmall),
                      const Text('כמות: '),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: TextEditingController(text: item.quantity.toString()),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          enabled: item.shouldAdd,
                          onChanged: (value) {
                            final qty = int.tryParse(value) ?? 1;
                            setState(() {
                              _items[index].quantity = qty;
                            });
                          },
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(item.receiptItem.unit ?? 'יח\''),
                    ],
                  ),
                ),
                
                // מיקום
                Expanded(
                  child: DropdownButton<String>(
                    value: item.suggestedLocation,
                    isExpanded: true,
                    isDense: true,
                    items: StorageLocationsConfig.primaryLocations.map((locationId) {
                      final info = StorageLocationsConfig.getLocationInfo(locationId);
                      return DropdownMenuItem(
                        value: locationId,
                        child: Row(
                          children: [
                            Text(info.emoji),
                            const SizedBox(width: kSpacingSmall),
                            Flexible(
                              child: Text(
                                info.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: item.shouldAdd ? (value) {
                      if (value != null) {
                        setState(() {
                          _items[index].suggestedLocation = value;
                        });
                      }
                    } : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// בונה Loading State.
  Widget _buildLoadingSkeleton(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: kSpacingMedium),
          Text(
            'מעבד ${widget.receipt.items.length} פריטים...',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  /// בונה Error State עם retry.
  Widget _buildErrorState(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: kIconSizeXLarge,
              color: Colors.red,
            ),
            const SizedBox(height: kSpacingMedium),
            const Text(
              'אופס! משהו השתבש',
              style: TextStyle(
                fontSize: kFontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingSmall),
            Text(
              _errorMessage ?? 'שגיאה לא ידועה',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: kSpacingXLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('חזור'),
                ),
                const SizedBox(width: kSpacingMedium),
                FilledButton.icon(
                  onPressed: () {
                    debugPrint('🔄 Retry: משתמש לחץ retry');
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });
                    _initializeService();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('נסה שוב'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// בונה Empty State.
  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: kIconSizeXLarge,
              color: Colors.orange,
            ),
            const SizedBox(height: kSpacingMedium),
            const Text(
              'אין פריטים בקבלה',
              style: TextStyle(
                fontSize: kFontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingSmall),
            Text(
              'הקבלה ריקה או שכל הפריטים כבר נוספו',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: kSpacingXLarge),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('חזור'),
            ),
          ],
        ),
      ),
    );
  }

  /// בונה את מסך הנתונים הראשי.
  Widget _buildDataScreen(ColorScheme cs) {
    final selectedCount = _items.where((item) => item.shouldAdd).length;
    
    return Column(
      children: [
        // כותרת עם מידע על הקבלה
        Container(
          padding: const EdgeInsets.all(kSpacingMedium),
          color: cs.primaryContainer.withValues(alpha: 0.3),
          child: Row(
            children: [
              const Icon(Icons.store),
              const SizedBox(width: kSpacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.receipt.storeName,
                      style: const TextStyle(
                        fontSize: kFontSizeBody,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.receipt.date.day}/${widget.receipt.date.month}/${widget.receipt.date.year}',
                      style: TextStyle(
                        fontSize: kFontSizeSmall,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$selectedCount/${_items.length} נבחרו',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ],
          ),
        ),
        
        // רשימת פריטים
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return _buildItemCard(_items[index], index);
            },
          ),
        ),
        
        // כפתורי פעולה
        Container(
          padding: const EdgeInsets.all(kSpacingMedium),
          decoration: BoxDecoration(
            color: cs.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                offset: const Offset(0, -2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isProcessing ? null : () => Navigator.pop(context),
                  child: const Text('ביטול'),
                ),
              ),
              const SizedBox(width: kSpacingMedium),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isProcessing || selectedCount == 0
                      ? null
                      : () => _confirmAndAddToInventory(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('הוסף $selectedCount פריטים'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          backgroundColor: cs.surfaceContainer,
          title: Text('הוספת ${widget.receipt.items.length} פריטים למלאי'),
        ),
        body: _isLoading
            ? _buildLoadingSkeleton(cs)
            : _errorMessage != null
                ? _buildErrorState(cs)
                : _items.isEmpty
                    ? _buildEmptyState(cs)
                    : _buildDataScreen(cs),
      ),
    );
  }
}
