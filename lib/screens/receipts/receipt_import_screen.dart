// 📄 File: lib/screens/receipts/receipt_import_screen.dart
//
// 🎯 מטרה: מסך ייבוא קבלה למלאי

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/receipt.dart';
import '../../providers/receipt_provider.dart';
import '../../widgets/receipt_to_inventory_dialog.dart';
import '../../core/ui_constants.dart';


class ReceiptImportScreen extends StatelessWidget {
  const ReceiptImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final receiptProvider = context.watch<ReceiptProvider>();
    final receipts = receiptProvider.receipts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ייבוא קבלה למלאי'),
        backgroundColor: cs.surfaceContainer,
      ),
      body: receipts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 80,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: kSpacingMedium),
                  Text(
                    'אין קבלות זמינות',
                    style: TextStyle(
                      fontSize: kFontSizeLarge,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(kSpacingMedium),
              itemCount: receipts.length,
              itemBuilder: (context, index) {
                final receipt = receipts[index];
                return Card(
                  color: cs.surfaceContainer,
                  margin: const EdgeInsets.only(bottom: kSpacingMedium),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.withValues(alpha: 0.2),
                      child: const Icon(
                        Icons.receipt,
                        color: Colors.orange,
                      ),
                    ),
                    title: Text(
                      receipt.storeName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${receipt.date.day}/${receipt.date.month}/${receipt.date.year}',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                        Text(
                          '${receipt.items.length} פריטים • ₪${receipt.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: kFontSizeSmall,
                          ),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton.icon(
                      onPressed: () => _showImportDialog(context, receipt),
                      icon: const Icon(Icons.move_to_inbox, size: 16),
                      label: const Text('למלאי'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _showImportDialog(BuildContext context, Receipt receipt) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ReceiptToInventoryDialog(receipt: receipt),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ הפריטים נוספו למלאי בהצלחה'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}