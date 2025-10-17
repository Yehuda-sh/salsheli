// 📄 File: lib/widgets/receipt_to_inventory_dialog.dart
//
// 🎯 מטרה: דיאלוג להעברת פריטים מקבלה למלאי

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/receipt.dart';
import '../models/inventory_item.dart';
import '../providers/inventory_provider.dart';
import '../providers/product_location_provider.dart';
import '../config/storage_locations_config.dart';
import '../core/ui_constants.dart';

class ReceiptToInventoryDialog extends StatefulWidget {
  final Receipt receipt;
  
  const ReceiptToInventoryDialog({
    super.key,
    required this.receipt,
  });

  @override
  State<ReceiptToInventoryDialog> createState() => _ReceiptToInventoryDialogState();
}

class _ReceiptToInventoryDialogState extends State<ReceiptToInventoryDialog> {
  final Map<String, String> _selectedLocations = {};
  final Map<String, int> _quantities = {};
  final Map<String, bool> _selected = {};
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeItems();
  }

  void _initializeItems() {
    final locationProvider = context.read<ProductLocationProvider>();
    
    for (var item in widget.receipt.items) {
      if (item.name != null) {
        final productName = item.name!;
        
        // נסה לקבל מיקום ידוע או נחש
        _selectedLocations[productName] = locationProvider.getProductLocation(
          productName,
          category: item.category,
        ) ?? StorageLocationsConfig.mainPantry;
        
        _quantities[productName] = item.quantity;
        _selected[productName] = true; // ברירת מחדל - כולם מסומנים
      }
    }
  }

  Future<void> _processItems() async {
    setState(() => _isProcessing = true);
    
    final inventoryProvider = context.read<InventoryProvider>();
    final locationProvider = context.read<ProductLocationProvider>();
    
    int addedCount = 0;
    int updatedCount = 0;
    
    for (var item in widget.receipt.items) {
      if (item.name == null || !(_selected[item.name!] ?? false)) continue;
      
      final productName = item.name!;
      final location = _selectedLocations[productName]!;
      final quantity = _quantities[productName] ?? item.quantity;
      
      try {
        // שמור את המיקום לזיכרון
        await locationProvider.saveProductLocation(
          productName,
          location,
          category: item.category,
        );
        
        // חפש אם המוצר כבר קיים במלאי
        final existingItems = inventoryProvider.items
            .where((i) => i.productName.toLowerCase() == productName.toLowerCase())
            .toList();
        
        if (existingItems.isNotEmpty) {
          // עדכן כמות
          final existing = existingItems.first;
          final updated = existing.copyWith(
            quantity: existing.quantity + quantity,
          );
          await inventoryProvider.updateItem(updated);
          updatedCount++;
          debugPrint('📦 Updated: $productName (+$quantity)');
        } else {
          // צור פריט חדש
          await inventoryProvider.createItem(
            productName: productName,
            category: item.category ?? 'כללי',
            location: location,
            quantity: quantity,
            unit: item.unit ?? 'יח\'',
          );
          addedCount++;
          debugPrint('➕ Added: $productName to $location');
        }
      } catch (e) {
        debugPrint('❌ Error processing $productName: $e');
      }
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('נוספו $addedCount פריטים, עודכנו $updatedCount פריטים'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true); // החזר true כסימן להצלחה
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final validItems = widget.receipt.items.where((i) => i.name != null).toList();
    
    return Dialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(kSpacingMedium),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(kBorderRadiusLarge),
                  topRight: Radius.circular(kBorderRadiusLarge),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.move_to_inbox, color: cs.primary),
                  const SizedBox(width: kSpacingSmall),
                  Expanded(
                    child: Text(
                      'העברה למלאי',
                      style: TextStyle(
                        fontSize: kFontSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.all(kSpacingMedium),
                shrinkWrap: true,
                itemCount: validItems.length,
                itemBuilder: (context, index) {
                  final item = validItems[index];
                  final productName = item.name!;
                  final isSelected = _selected[productName] ?? false;
                  final locationProvider = context.watch<ProductLocationProvider>();
                  final isKnown = locationProvider.isProductKnown(productName);
                  
                  return Card(
                    color: isSelected ? cs.secondaryContainer : cs.surfaceContainer,
                    margin: const EdgeInsets.only(bottom: kSpacingSmall),
                    child: Padding(
                      padding: const EdgeInsets.all(kSpacingSmall),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: isSelected,
                                onChanged: (val) {
                                  setState(() => _selected[productName] = val ?? false);
                                },
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      productName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                    if (isKnown)
                                      Text(
                                        '✓ מוצר מוכר',
                                        style: TextStyle(
                                          fontSize: kFontSizeSmall,
                                          color: Colors.green,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // כמות
                              SizedBox(
                                width: 60,
                                child: TextFormField(
                                  initialValue: _quantities[productName].toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                  onChanged: (val) {
                                    _quantities[productName] = int.tryParse(val) ?? 1;
                                  },
                                ),
                              ),
                              const SizedBox(width: kSpacingSmall),
                              // מיקום
                              DropdownButton<String>(
                                value: _selectedLocations[productName],
                                isDense: true,
                                items: StorageLocationsConfig.primaryLocations
                                    .map((locationId) {
                                  final info = StorageLocationsConfig.getLocationInfo(locationId);
                                  return DropdownMenuItem(
                                    value: locationId,
                                    child: Row(
                                      children: [
                                        Text(info.emoji),
                                        const SizedBox(width: 4),
                                        Text(
                                          info.name,
                                          style: TextStyle(fontSize: kFontSizeSmall),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: isSelected
                                    ? (val) {
                                        setState(() {
                                          _selectedLocations[productName] = val!;
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(kSpacingMedium),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(kBorderRadiusLarge),
                  bottomRight: Radius.circular(kBorderRadiusLarge),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
                    child: const Text('ביטול'),
                  ),
                  const SizedBox(width: kSpacingSmall),
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _processItems,
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: Text(_isProcessing ? 'מעבד...' : 'העבר למלאי'),
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