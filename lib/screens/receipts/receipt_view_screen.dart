// lib/screens/receipts/receipt_view_screen.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/receipt.dart';

class ReceiptViewScreen extends StatelessWidget {
  final Receipt receipt;

  const ReceiptViewScreen({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dateStr = DateFormat('dd/MM/yyyy', 'he_IL').format(receipt.date);
    final currency = NumberFormat.currency(locale: 'he_IL', symbol: '₪');

    final itemsCount = receipt.items.length;
    final totalQty = receipt.items.fold<int>(0, (s, it) => s + it.quantity);
    final totalAmount = receipt.totalAmount;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: Text('קבלה מ-${receipt.storeName}'),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
          actions: [
            IconButton(
              tooltip: 'שיתוף (בקרוב)',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('שיתוף קבלה — בקרוב')),
                );
              },
              icon: const Icon(Icons.ios_share),
            ),
          ],
        ),
        body: Column(
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                border: Border(
                  bottom: BorderSide(
                    color: cs.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(Icons.store_mall_directory, color: cs.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          receipt.storeName,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      _Chip(
                        icon: Icons.event,
                        label: dateStr,
                        color: cs.primary,
                      ),
                      _Chip(
                        icon: Icons.inventory_2_outlined,
                        label: '$itemsCount פריטים',
                        color: Colors.blue,
                      ),
                      _Chip(
                        icon: Icons.calculate_outlined,
                        label: '$totalQty יחידות',
                        color: Colors.teal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        currency.format(totalAmount),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'סה״כ לתשלום',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Items list
            Expanded(
              child: receipt.items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'אין פריטים בקבלה',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemCount: receipt.items.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: cs.outlineVariant.withValues(alpha: 0.2),
                      ),
                      itemBuilder: (context, index) {
                        final it = receipt.items[index];
                        final lineTotal = it.totalPrice; // מניח שקיים במודל
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: cs.primary.withValues(alpha: 0.12),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            it.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${it.quantity} × ${currency.format(it.unitPrice)}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: Text(
                            currency.format(lineTotal),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        );
                      },
                    ),
            ),

            // Footer summary bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                border: Border(
                  top: BorderSide(
                    color: cs.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.summarize_outlined, color: cs.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'סה״כ: $itemsCount פריטים • $totalQty יחידות',
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    currency.format(totalAmount),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ייצוא/שיתוף קבלה — בקרוב')),
            );
          },
          icon: const Icon(Icons.share),
          label: const Text('שתף'),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
