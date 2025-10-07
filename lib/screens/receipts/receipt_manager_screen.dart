import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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

  void _addReceipt() async {
    final provider = context.read<ReceiptProvider>();
    
    try {
      // יצירת קבלה חדשה עם פרטים ריקים
      await provider.createReceipt(
        storeName: 'שופרסל',  // ברירת מחדל
        date: DateTime.now(),
        items: [],
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('קבלה נוצרה בהצלחה! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה ביצירת קבלה: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReceiptProvider>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('הקבלות שלי'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _addReceipt,
            tooltip: 'הוסף קבלה',
          ),
        ],
      ),
      body: _buildBody(provider, cs),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReceipt,
        icon: const Icon(Icons.add),
        label: const Text('קבלה חדשה'),
        tooltip: 'הוסף קבלה',
      ),
    );
  }

  Widget _buildBody(ReceiptProvider provider, ColorScheme cs) {
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
            Icon(
              Icons.receipt_long,
              size: 80,
              color: Colors.orange.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'אין קבלות עדיין',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'התחל להוסיף קבלות כדי לעקוב אחר ההוצאות שלך!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: FilledButton.icon(
                onPressed: _addReceipt,
                icon: const Icon(Icons.add),
                label: const Text('הוסף קבלה ראשונה'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
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
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Colors.orange,
                ),
              ),
              title: Text(
                r.storeName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("$dateStr • ${r.items.length} פריטים"),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "₪${r.totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
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
