// 📄 File: lib/screens/receipts/receipt_to_inventory_screen.dart
//
// 🎯 מטרה: מסך אישור להעברת פריטים מקבלה למלאי
// מאפשר למשתמש לבחור איזה פריטים להוסיף ולאן

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/receipt.dart';
import '../../providers/inventory_provider.dart';
import '../../services/receipt_to_inventory_service.dart';
import '../../config/storage_locations_config.dart';


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
  
  @override
  void initState() {
    super.initState();
    _initializeService();
  }
  
  Future<void> _initializeService() async {
    final inventoryProvider = context.read<InventoryProvider>();
    _service = ReceiptToInventoryService(inventoryProvider: inventoryProvider);
    
    // עבד את הקבלה
    final processedItems = await _service.processReceipt(widget.receipt);
    
    setState(() {
      _items = processedItems;
      _isLoading = false;
    });
  }
  
  Future<void> _confirmAndAddToInventory() async {
    setState(() => _isProcessing = true);
    
    try {
      await _service.addApprovedItemsToInventory(_items);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ הפריטים נוספו למלאי בהצלחה!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ שגיאה בהוספת פריטים: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }
  
  Widget _buildItemCard(ReceiptToInventoryItem item, int index) {
    final cs = Theme.of(context).colorScheme;
    // final locationInfo = StorageLocationsConfig.getLocationInfo(item.suggestedLocation);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: item.shouldAdd ? cs.surface : cs.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
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
                            style: TextStyle(fontSize: 12, color: Colors.blue),
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
                            style: const TextStyle(fontSize: 12, color: Colors.green),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // כמות ומיקום
            Row(
              children: [
                // כמות
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.numbers, size: 16),
                      const SizedBox(width: 8),
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
                            const SizedBox(width: 8),
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
  
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selectedCount = _items.where((item) => item.shouldAdd).length;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          backgroundColor: cs.surfaceContainer,
          title: Text('הוספת ${widget.receipt.items.length} פריטים למלאי'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // כותרת עם מידע על הקבלה
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: cs.primaryContainer.withValues(alpha: 0.3),
                    child: Row(
                      children: [
                        const Icon(Icons.store),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.receipt.storeName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${widget.receipt.date.day}/${widget.receipt.date.month}/${widget.receipt.date.year}',
                                style: TextStyle(
                                  fontSize: 12,
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
                    padding: const EdgeInsets.all(16),
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isProcessing || selectedCount == 0
                                ? null
                                : _confirmAndAddToInventory,
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
              ),
      ),
    );
  }
}
