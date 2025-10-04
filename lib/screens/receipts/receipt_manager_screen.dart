import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/receipt.dart';
import '../../providers/receipt_provider.dart';
import 'receipt_view_screen.dart';

class ReceiptManagerScreen extends StatefulWidget {
  const ReceiptManagerScreen({super.key});

  @override
  State<ReceiptManagerScreen> createState() => _ReceiptManagerScreenState();
}

class _ReceiptManagerScreenState extends State<ReceiptManagerScreen> {
  @override
  void initState() {
    super.initState();
    // טען קבלות מה־Repository דרך ה־Provider
    // (מאפשר Pull-to-Refresh וגם טעינה ראשונית)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ReceiptProvider>().loadReceipts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReceiptProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // מצב ריק
    if (provider.isEmpty) {
      return RefreshIndicator(
        onRefresh: provider.loadReceipts,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'אין קבלות להצגה',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'סרקו קבלה חדשה או ייבאו מהענן כאשר החיבור יופעל.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // רשימת קבלות
    final receipts = provider.receipts;

    return RefreshIndicator(
      onRefresh: provider.loadReceipts,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: receipts.length,
        itemBuilder: (context, index) {
          final r = receipts[index];
          final dateStr = DateFormat("dd/MM/yyyy").format(r.date);
          return Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.orange),
              title: Text(r.storeName),
              subtitle: Text("$dateStr • ${r.items.length} פריטים"),
              trailing: Text("${r.totalAmount.toStringAsFixed(2)} ₪"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReceiptViewScreen(receipt: r),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
