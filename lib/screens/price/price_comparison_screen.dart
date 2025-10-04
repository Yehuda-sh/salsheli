// lib/screens/price/price_comparison_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class PriceComparisonScreen extends StatefulWidget {
  const PriceComparisonScreen({super.key});

  @override
  State<PriceComparisonScreen> createState() => _PriceComparisonScreenState();
}

class _PriceComparisonScreenState extends State<PriceComparisonScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool isLoading = false;
  String searchTerm = "";
  List<Map<String, dynamic>> results = [];

  final _money = NumberFormat.currency(
    locale: 'he_IL',
    symbol: '₪',
    decimalDigits: 2,
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // פונקציה לדוגמה שמחזירה תוצאות חיפוש פיקטיביות
  Future<void> _searchPrices() async {
    final term = _searchController.text.trim();
    if (term.isEmpty) return;

    setState(() {
      isLoading = true;
      searchTerm = term;
      results = [];
    });

    await Future.delayed(const Duration(seconds: 1)); // סימולציה של חיפוש

    final mockResults = <Map<String, dynamic>>[
      {"product": term, "store": "שופרסל", "price": 8.9},
      {"product": term, "store": "רמי לוי", "price": 7.5},
      {"product": term, "store": "יינות ביתן", "price": 9.2},
      {"product": term, "store": "ויקטורי", "price": 8.2},
    ];

    mockResults.sort((a, b) {
      final pa = (a["price"] as num?)?.toDouble() ?? double.infinity;
      final pb = (b["price"] as num?)?.toDouble() ?? double.infinity;
      return pa.compareTo(pb);
    });

    if (!mounted) return;
    setState(() {
      results = mockResults;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // הפקת min/max בצורה בטוחה
    final prices = results.map((r) => (r["price"] as num).toDouble()).toList();
    final double? minPrice = prices.isNotEmpty
        ? prices.reduce((a, b) => a < b ? a : b)
        : null;
    final double? maxPrice = prices.isNotEmpty
        ? prices.reduce((a, b) => a > b ? a : b)
        : null;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("השוואת מחירים"),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // 🔍 חיפוש
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (_) => _searchPrices(),
                      decoration: InputDecoration(
                        hintText: "חפש מוצר...",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'נקה',
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    results = [];
                                    searchTerm = "";
                                  });
                                },
                              ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: cs.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isLoading ? null : _searchPrices,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("חפש"),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ⏳ מצב טעינה
              if (isLoading && results.isEmpty)
                const CircularProgressIndicator(),

              // 📭 מצב ריק
              if (!isLoading && results.isEmpty && searchTerm.isNotEmpty)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.search_off, color: Colors.grey),
                    title: Text('לא נמצאו תוצאות עבור "$searchTerm"'),
                    subtitle: const Text('נסו מונח אחר או שם מוצר מדויק יותר'),
                  ),
                ),

              // 📊 תוצאות
              if (!isLoading && results.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'תוצאות עבור "$searchTerm"',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      final price = (item["price"] as num).toDouble();
                      final isCheapest = minPrice != null && price == minPrice;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Icon(
                            Icons.store,
                            color: isCheapest ? Colors.green : cs.primary,
                          ),
                          title: Text("${item["product"]}"),
                          subtitle: Text("${item["store"]}"),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _money.format(price),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isCheapest
                                      ? Colors.green
                                      : cs.onSurface,
                                ),
                              ),
                              if (isCheapest)
                                const Text(
                                  'הכי זול',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                if (minPrice != null && maxPrice != null)
                  Card(
                    color: Colors.green.withOpacity(0.06),
                    margin: const EdgeInsets.only(top: 12),
                    child: ListTile(
                      leading: const Text("💰", style: TextStyle(fontSize: 22)),
                      title: const Text("חיסכון פוטנציאלי"),
                      subtitle: Text(_money.format(maxPrice - minPrice)),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
