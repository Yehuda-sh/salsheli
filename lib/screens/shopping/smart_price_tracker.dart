// lib/components/shopping/smart_price_tracker.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'dart:ui' as ui show TextDirection;

class PriceResult {
  final String store;
  final double price;
  final bool inStock;
  final DateTime lastUpdated;

  const PriceResult({
    required this.store,
    required this.price,
    required this.inStock,
    required this.lastUpdated,
  });
}

class PriceAlert {
  final String productName;
  final double targetPrice;
  final bool isActive;
  final DateTime createdAt;

  const PriceAlert({
    required this.productName,
    required this.targetPrice,
    this.isActive = true,
    required this.createdAt,
  });
}

class SmartPriceTracker extends StatefulWidget {
  const SmartPriceTracker({super.key});

  @override
  State<SmartPriceTracker> createState() => _SmartPriceTrackerState();
}

class _SmartPriceTrackerState extends State<SmartPriceTracker> {
  final TextEditingController _searchController = TextEditingController();

  List<PriceResult> _searchResults = [];
  final List<PriceAlert> _priceAlerts = [];
  bool _isSearching = false;
  String? _lastQuery;

  final List<String> _recommendedProducts = const [
    "חלב",
    "לחם",
    "ביצים",
    "אורז",
    "שמן זית",
    "פסטה",
    "עגבניות",
    "מלפפונים",
  ];

  NumberFormat get _nis =>
      NumberFormat.currency(locale: 'he_IL', symbol: '₪', decimalDigits: 2);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handlePriceSearch(String productName) async {
    final query = productName.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _lastQuery = query;
    });

    // סימולציית מקור נתונים
    await Future.delayed(const Duration(milliseconds: 900));
    final random = Random();
    final stores = ["שופרסל", "רמי לוי", "יינות ביתן", "יוחננוף", "ויקטורי"];

    // בונים תוצאות רנדומליות, ממיינים: קודם זמינות (כן לפני לא), ואז מחיר
    final results =
        stores
            .map(
              (store) => PriceResult(
                store: store,
                price: 5 + random.nextDouble() * 30,
                inStock: random.nextBool(),
                lastUpdated: DateTime.now(),
              ),
            )
            .toList()
          ..sort((a, b) {
            // זמינות יורדת (true קודם), ואז מחיר עולה
            if (a.inStock != b.inStock)
              return (b.inStock ? 1 : 0) - (a.inStock ? 1 : 0);
            return a.price.compareTo(b.price);
          });

    if (!mounted) return;
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _handleAddPriceAlert(String productName, double? defaultPrice) async {
    final cs = Theme.of(context).colorScheme;
    final controller = TextEditingController(
      text: defaultPrice != null ? defaultPrice.toStringAsFixed(2) : '',
    );

    final target = await showDialog<double>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          title: const Text('התראת מחיר'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'מחיר יעד (₪)',
              hintText: 'לדוגמה: 7.90',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('בטל'),
            ),
            FilledButton(
              onPressed: () {
                final v = double.tryParse(controller.text.replaceAll(',', '.'));
                Navigator.pop(ctx, v);
              },
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
              ),
              child: const Text('שמור'),
            ),
          ],
        ),
      ),
    );

    if (target == null) return;

    setState(() {
      _priceAlerts.add(
        PriceAlert(
          productName: productName,
          targetPrice: target,
          createdAt: DateTime.now(),
        ),
      );
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("התראת מחיר ל־$productName נוספה!"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  PriceResult? get _bestOfferInStock {
    // אחרי המיון למעלה, ההצעה הראשונה שבמלאי תהיה “הטובה ביותר”
    try {
      return _searchResults.firstWhere((r) => r.inStock);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSearchHeader(cs),

          const SizedBox(height: 16),

          if (_isSearching) const Center(child: CircularProgressIndicator()),

          if (!_isSearching && _searchResults.isNotEmpty)
            _buildSearchResults(cs),

          const SizedBox(height: 16),

          _buildRecommended(cs),

          const SizedBox(height: 16),

          if (_priceAlerts.isNotEmpty) _buildAlertsSection(cs),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(ColorScheme cs) {
    return Card(
      color: cs.tertiaryContainer.withValues(alpha: 0.25),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cs.primary, cs.secondary],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.track_changes, color: cs.onPrimary),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "מעקב מחירים חכם",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "השוואת מחירים ומעקב מגמות",
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _handlePriceSearch,
                    decoration: const InputDecoration(
                      hintText: "חפש מוצר...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_searchController.text.trim().isNotEmpty) {
                      _handlePriceSearch(_searchController.text);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text("חפש"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(ColorScheme cs) {
    final best = _bestOfferInStock;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "תוצאות השוואת מחירים",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_lastQuery != null)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.notifications_active),
                    label: const Text("התראה למחיר"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.primary,
                      side: BorderSide(color: cs.primary),
                    ),
                    onPressed: () =>
                        _handleAddPriceAlert(_lastQuery!, best?.price),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // רשימת התוצאות
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchResults.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final result = _searchResults[i];
                final isBest =
                    best != null &&
                    result.store == best.store &&
                    result.price == best.price;

                final bg = result.inStock
                    ? (isBest
                          ? cs.primaryContainer.withValues(alpha: 0.30)
                          : cs.surfaceVariant.withValues(alpha: 0.35))
                    : Colors.red.shade50;

                final borderColor = isBest
                    ? cs.primary
                    : (result.inStock ? cs.outline : Colors.red.shade200);

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          result.store,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _nis.format(result.price),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isBest ? cs.primary : cs.onSurface,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                result.inStock
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                size: 16,
                                color: result.inStock
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                result.inStock ? "זמין במלאי" : "לא זמין",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: result.inStock
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "עודכן: ${TimeOfDay.fromDateTime(result.lastUpdated).format(context)}",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommended(ColorScheme cs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.flash_on, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  "מוצרים מומלצים לבדיקה",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recommendedProducts
                  .map(
                    (product) => ActionChip(
                      label: Text(product),
                      onPressed: () => _handlePriceSearch(product),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsSection(ColorScheme cs) {
    return Card(
      color: cs.secondaryContainer.withValues(alpha: 0.25),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.notifications, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  "התראות מחירים פעילות",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._priceAlerts.map(
              (alert) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(alert.productName),
                subtitle: Text(
                  "התראה מתחת ל־${_nis.format(alert.targetPrice)}",
                ),
                trailing: const Icon(Icons.check_circle, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
