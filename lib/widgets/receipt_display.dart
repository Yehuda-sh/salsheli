// 📄 File: lib/widgets/receipt_display.dart
//
// 🇮🇱 ווידג'ט להצגת קבלה (Receipt):
//     - מציג שם חנות, תאריך ושעה, מזהה קבלה.
//     - מציג פריטים עם מחיר ליחידה וסה"כ.
//     - מציג סיכום פריטים וסכום סופי לתשלום.
//     - מעוצב בצורה "מדפסתית" בסגנון קבלה אמיתית.
//     - תמיכה מלאה ב-Accessibility (screen readers).
//
// 🇬🇧 Widget for displaying a Receipt:
//     - Shows store name, date/time, and receipt ID.
//     - Displays list of items with unit & total prices.
//     - Displays summary with total items and total amount.
//     - Styled as a printable receipt-like component.
//     - Full accessibility support for screen readers.
//
// 📖 Usage:
// ```dart
// ReceiptDisplay(
//   receipt: Receipt(
//     id: 'rec_123',
//     storeName: 'שופרסל',
//     date: DateTime.now(),
//     totalAmount: 156.50,
//     items: [
//       ReceiptItem(name: 'חלב', quantity: 2, unitPrice: 6.90, totalPrice: 13.80),
//       ReceiptItem(name: 'לחם', quantity: 1, unitPrice: 5.50, totalPrice: 5.50),
//     ],
//   ),
// )
// ```

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/receipt.dart';

class ReceiptDisplay extends StatelessWidget {
  final Receipt receipt;

  const ReceiptDisplay({super.key, required this.receipt});

  /// 🇮🇱 קיצור מזהה ארוך
  /// 🇬🇧 Shortens long receipt IDs
  String _shortId(String id) {
    return id.length <= 8
        ? id
        : "${id.substring(0, 4)}...${id.substring(id.length - 4)}";
  }

  /// 🇮🇱 עיצוב מחיר לש"ח
  /// 🇬🇧 Format currency to shekels
  String _formatCurrency(double value) {
    final format = NumberFormat.currency(locale: "he_IL", symbol: "₪");
    return format.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final receiptWidth = (screenWidth * 0.9).clamp(300.0, 400.0);

    // 📊 Logging - מציג איזו קבלה מוצגת
    debugPrint('🧾 ReceiptDisplay.build()');
    debugPrint('   חנות: ${receipt.storeName}');
    debugPrint('   תאריך: ${DateFormat("dd/MM/yyyy").format(receipt.date)}');
    debugPrint('   פריטים: ${receipt.items.length}');
    debugPrint('   סכום: ${_formatCurrency(receipt.totalAmount)}');
    debugPrint('   📐 רוחב מסך: ${screenWidth.toInt()}px');
    debugPrint('   📐 רוחב קבלה: ${receiptWidth.toInt()}px');

    return Container(
      width: receiptWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(cs),
          const SizedBox(height: 16),
          _buildMetadata(),
          const Divider(thickness: 1, color: Colors.grey, height: 32),
          _buildItemsSection(),
          const Divider(thickness: 1, color: Colors.grey, height: 32),
          _buildSummary(),
          const Divider(thickness: 1, color: Colors.grey, height: 32),
          _buildFooter(),
        ],
      ),
    );
  }

  /// 🧾 Header with store name
  Widget _buildHeader(ColorScheme cs) {
    return Column(
      children: [
        Semantics(
          label: 'אייקון חנות ${receipt.storeName}',
          child: Icon(Icons.storefront, size: 32, color: cs.primary),
        ),
        const SizedBox(height: 6),
        Text(
          receipt.storeName,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const Text("חשבונית מס", style: TextStyle(fontSize: 12)),
      ],
    );
  }

  /// 📅 Metadata (date, time, id)
  Widget _buildMetadata() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("תאריך: ${DateFormat("dd/MM/yyyy").format(receipt.date)}"),
            Text(
              "שעה: ${DateFormat("HH:mm").format(receipt.createdDate ?? DateTime.now())}",
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("קבלה: #${_shortId(receipt.id)}"),
            const Text("קופה: 001"),
          ],
        ),
      ],
    );
  }

  /// 🛒 Items list
  Widget _buildItemsSection() {
    if (receipt.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          "אין פריטים בקבלה זו.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: receipt.items.map((item) {
        final unitPrice = item.unitPrice;
        final isRefund = item.totalPrice < 0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name ?? 'ללא שם', style: const TextStyle(fontSize: 14)),
                    if (item.quantity > 1)
                      Text(
                        "${_formatCurrency(unitPrice)} x ${item.quantity}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                _formatCurrency(item.totalPrice),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isRefund ? Colors.red : Colors.black,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 📦 Summary
  Widget _buildSummary() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("סה\"כ פריטים:"),
            Text("${receipt.items.length}"),
          ],
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.yellow.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "סה\"כ לתשלום:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                _formatCurrency(receipt.totalAmount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🙏 Footer
  Widget _buildFooter() {
    return Column(
      children: [
        const Text("תודה שקניתם אצלנו!", style: TextStyle(color: Colors.grey)),
        Text(
          "צוות ${receipt.storeName}",
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
