// 📄 File: lib/widgets/price_checker.dart
//
// 🇮🇱 PriceChecker: ווידג'ט לבדיקה והשוואת מחירים מול מאגר אמיתי.
//     - חיפוש לפי שם מוצר / ברקוד.
//     - הצגת טווח מחירים (min/avg/max).
//     - וריאנטים (items) עם אפשרות עדכון מחיר.
//     - משוב ויזואלי אם המחיר הנוכחי זול/יקר מהממוצע.
//
// 🇬🇧 PriceChecker widget:
//     - Search by product name / barcode.
//     - Displays price range (min/avg/max).
//     - Shows variants with update option.
//     - Visual trend vs. current price.
//

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/price_data.dart';

class PriceChecker extends StatefulWidget {
  final String? initialSearch;
  final double? currentPrice;
  final void Function(double newPrice)? onPriceUpdate;
  final Future<PriceData?> Function(String query) fetchPriceData;

  const PriceChecker({
    super.key,
    this.initialSearch,
    this.currentPrice,
    this.onPriceUpdate,
    required this.fetchPriceData,
  });

  @override
  State<PriceChecker> createState() => _PriceCheckerState();
}

class _PriceCheckerState extends State<PriceChecker> {
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;
  String? error;
  PriceData? priceData;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialSearch ?? '';
    if (_controller.text.isNotEmpty) {
      _checkPrices();
    }
  }

  Future<void> _checkPrices() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
      error = null;
      priceData = null;
    });

    try {
      final pd = await widget.fetchPriceData(query);
      if (pd == null) {
        error = "לא נמצא מידע למחיר";
      } else {
        priceData = pd;
      }
    } catch (e) {
      error = "שגיאה בקריאת המחירים";
    }

    setState(() => isLoading = false);
  }

  /// 🧮 השוואת מחיר נוכחי מול ממוצע
  Widget _buildTrend() {
    if (priceData == null || widget.currentPrice == null) {
      return const SizedBox.shrink();
    }
    final current = widget.currentPrice!;
    final avg = priceData!.averagePrice;

    if (current < avg) {
      return const _TrendRow(
        icon: Icons.trending_down,
        color: Colors.green,
        text: "מחיר טוב!",
      );
    } else if (current > avg) {
      return const _TrendRow(
        icon: Icons.trending_up,
        color: Colors.red,
        text: "יקר מהממוצע",
      );
    } else {
      return const _TrendRow(
        icon: Icons.remove,
        color: Colors.blue,
        text: "מחיר ממוצע",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- כותרת ---
            Row(
              children: [
                Icon(Icons.search, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  "בדיקת מחירים",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- שורת חיפוש ---
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "הקלידו שם מוצר או ברקוד...",
                    ),
                    onSubmitted: (_) => _checkPrices(),
                  ),
                ),
                IconButton(
                  onPressed: isLoading ? null : _checkPrices,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                ),
              ],
            ),

            if (error != null) ...[
              const SizedBox(height: 12),
              Text(error!, style: TextStyle(color: cs.error)),
            ],

            if (priceData != null) ...[
              const SizedBox(height: 16),

              // --- טווח מחירים ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _PriceBox("נמוך", priceData!.minPrice, Colors.green),
                  _PriceBox("ממוצע", priceData!.averagePrice, Colors.blue),
                  _PriceBox("גבוה", priceData!.maxPrice, Colors.red),
                ],
              ),

              const SizedBox(height: 12),

              // --- השוואה למחיר נוכחי ---
              if (widget.currentPrice != null) _buildTrend(),

              const SizedBox(height: 12),

              // --- וריאנטים ---
              if (priceData!.items?.isNotEmpty ?? false) ...[
                const Divider(),
                Text(
                  "וריאנטים זמינים:",
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...priceData!.items!.map((pi) {
                  return ListTile(
                    title: Text(pi.name),
                    subtitle: Text("ברקוד: ${pi.code}"),
                    trailing: Text("₪${pi.price.toStringAsFixed(2)}"),
                    onTap: widget.onPriceUpdate != null
                        ? () => widget.onPriceUpdate!(pi.price)
                        : null,
                  );
                }),
              ],

              const SizedBox(height: 12),

              // --- כפתורי פעולה מהירים ---
              if (widget.onPriceUpdate != null) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          widget.onPriceUpdate!(priceData!.minPrice),
                      child: Text(
                        "עדכן לנמוך (₪${priceData!.minPrice.toStringAsFixed(2)})",
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () =>
                          widget.onPriceUpdate!(priceData!.averagePrice),
                      child: Text(
                        "עדכן לממוצע (₪${priceData!.averagePrice.toStringAsFixed(2)})",
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// 📦 קופסת מחיר בודד
class _PriceBox extends StatelessWidget {
  final String label;
  final double price;
  final Color color;

  const _PriceBox(this.label, this.price, this.color);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: "he_IL",
      symbol: "₪",
      decimalDigits: 2,
    );

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color)),
          Text(
            formatter.format(price),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// 📈 שורת טרנד (ירוק/אדום/כחול)
class _TrendRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _TrendRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: color)),
      ],
    );
  }
}
