// 📄 File: lib/screens/receipts/receipt_manager_screen.dart
// 🎯 Purpose: מסך ניהול קבלות - Receipts Manager Screen
//
// 📋 Features:
// ✅ רשימת קבלות עם תצוגה מפורטת
// ✅ Pull-to-Refresh
// ✅ Empty State עם CTA
// ✅ Error State + Retry
// ✅ יצירת קבלה חדשה
// ✅ Logging מפורט
//
// 🔗 Dependencies:
// - ReceiptProvider - ניהול קבלות
// - ReceiptViewScreen - תצוגת קבלה בודדת
//
// 🎨 Material 3:
// - צבעים דרך Theme/ColorScheme
// - ui_constants לעיצוב
// - RTL support

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/receipt_provider.dart';
import '../../core/ui_constants.dart';
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
    debugPrint('🧾 ReceiptManagerScreen: initState');
    // טען קבלות מה־Repository דרך ה־Provider
    // (מאפשר Pull-to-Refresh וגם טעינה ראשונית)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      debugPrint('🔄 ReceiptManagerScreen: טוען קבלות ראשוניות...');
      context.read<ReceiptProvider>().loadReceipts();
    });
  }

  void _addReceipt() async {
    debugPrint('➕ ReceiptManagerScreen: יוצר קבלה חדשה...');
    final provider = context.read<ReceiptProvider>();
    
    try {
      // יצירת קבלה חדשה עם פרטים ריקים
      await provider.createReceipt(
        storeName: 'שופרסל',  // ברירת מחדל
        date: DateTime.now(),
        items: [],
      );
      
      debugPrint('✅ ReceiptManagerScreen: קבלה נוצרה בהצלחה');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('קבלה נוצרה בהצלחה! 🎉'),
            backgroundColor: Colors.green,
            duration: kSnackBarDuration,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ ReceiptManagerScreen: שגיאה ביצירת קבלה - $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה ביצירת קבלה: $e'),
            backgroundColor: Colors.red,
            duration: kSnackBarDuration,
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
    // 🔄 Loading State
    if (provider.isLoading) {
      debugPrint('🔄 ReceiptManagerScreen: מציג Loading State');
      return const Center(child: CircularProgressIndicator());
    }

    // ❌ Error State
    if (provider.hasError) {
      debugPrint('❌ ReceiptManagerScreen: מציג Error State');
      return RefreshIndicator(
        onRefresh: provider.loadReceipts,
        child: ListView(
          padding: const EdgeInsets.all(kSpacingLarge),
          children: [
            const SizedBox(height: kSpacingXXLarge),
            Icon(
              Icons.error_outline,
              size: kIconSizeXLarge,
              color: Colors.red.withValues(alpha: 0.5),
            ),
            const SizedBox(height: kSpacingMedium),
            Text(
              'אופס! משהו השתבש',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: kSpacingSmall),
            Text(
              provider.errorMessage ?? 'שגיאה לא ידועה',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: kSpacingXLarge),
            Center(
              child: FilledButton.icon(
                onPressed: () {
                  debugPrint('🔄 ReceiptManagerScreen: משתמש לחץ retry');
                  provider.retry();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('נסה שוב'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSpacingXLarge,
                    vertical: kSpacingMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 📭 Empty State
    if (provider.isEmpty) {
      debugPrint('📭 ReceiptManagerScreen: מציג Empty State');
      return RefreshIndicator(
        onRefresh: provider.loadReceipts,
        child: ListView(
          padding: const EdgeInsets.all(kSpacingLarge),
          children: [
            const SizedBox(height: kSpacingXXLarge),
            Icon(
              Icons.receipt_long,
              size: kIconSizeXLarge,
              color: Colors.orange.withValues(alpha: 0.5),
            ),
            const SizedBox(height: kSpacingMedium),
            Text(
              'אין קבלות עדיין',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: kSpacingSmall),
            Text(
              'התחל להוסיף קבלות כדי לעקוב אחר ההוצאות שלך!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: kSpacingXLarge),
            Center(
              child: FilledButton.icon(
                onPressed: _addReceipt,
                icon: const Icon(Icons.add),
                label: const Text('הוסף קבלה ראשונה'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSpacingXLarge,
                    vertical: kSpacingMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 📜 רשימת קבלות
    final receipts = provider.receipts;
    debugPrint('📜 ReceiptManagerScreen: מציג ${receipts.length} קבלות');

    return RefreshIndicator(
      onRefresh: provider.loadReceipts,
      child: ListView.builder(
        padding: const EdgeInsets.all(kSpacingSmallPlus),
        itemCount: receipts.length,
        itemBuilder: (context, index) {
          final r = receipts[index];
          final dateStr = DateFormat("dd/MM/yyyy").format(r.date);
          return Card(
            margin: const EdgeInsets.only(bottom: kSpacingSmall),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(kSpacingSmall),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
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
                      fontSize: kFontSizeBody,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              onTap: () {
                debugPrint('👆 ReceiptManagerScreen: לחיצה על קבלה "${r.storeName}"');
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
