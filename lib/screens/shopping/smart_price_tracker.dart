// 📄 File: lib/screens/shopping/smart_price_tracker.dart
// 
// 🎯 Purpose:
// Smart price comparison tracker - השוואת מחירים חכמה בין חנויות שונות.
// מאפשר למשתמש לחפש מוצר ולקבל השוואת מחירים בזמן אמת,
// ליצור התראות מחיר, ולעקוב אחרי מגמות.
//
// 📦 Dependencies:
// - None (standalone widget)
//
// 🔧 Features:
// - חיפוש מוצרים והשוואת מחירים
// - התראות מחיר ממוקדות
// - המלצות על מוצרים פופולריים
// - סימון "ההצעה הטובה ביותר"
// - עדכוני זמינות במלאי
//
// 📝 Usage:
// ```dart
// SmartPriceTracker()
// ```
//
// ⚙️ TODO (Future):
// - חיבור ל-API אמיתי של מחירון ממשלתי
// - שמירת היסטוריית מחירים
// - גרפים של מגמות מחירים
// - התראות פוש כאשר מחיר יורד

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'dart:ui' as ui show TextDirection;

// קבועים מקומיים (הועברו מ-constants.dart שנמחק)
const double kSpacingSmall = 8.0;
const double kSpacingMedium = 16.0;
const double kSpacingLarge = 24.0;
const double kButtonHeight = 48.0;

const List<String> _kPredefinedStores = [
  'שופרסל',
  'רמי לוי',
  'ויקטורי',
  'יינות ביתן',
  'מגה',
  'אושר עד',
];

const List<String> _kPopularProducts = [
  'חלב',
  'לחם',
  'ביצים',
  'גבינה צהובה',
  'עגבניות',
  'קפה',
];

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
  bool _hasError = false;
  String? _lastQuery;

  NumberFormat get _nis =>
      NumberFormat.currency(locale: 'he_IL', symbol: '₪', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    debugPrint('📊 SmartPriceTracker.initState()');
  }

  @override
  void dispose() {
    debugPrint('🗑️ SmartPriceTracker.dispose()');
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handlePriceSearch(String productName) async {
    final query = productName.trim();
    if (query.isEmpty) {
      debugPrint('⚠️ SmartPriceTracker: שאילתת חיפוש ריקה');
      return;
    }

    debugPrint('🔍 SmartPriceTracker: מחפש מחירים ל-"$query"');

    setState(() {
      _isSearching = true;
      _hasError = false;
      _lastQuery = query;
    });

    try {
      // סימולציית מקור נתונים
      await Future.delayed(const Duration(milliseconds: 900));
      final random = Random();
      final stores = _kPredefinedStores;

      // בונים תוצאות רנדומליות, ממיינים: קודם זמינות (כן לפני לא), ואז מחיר
      final results = stores
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
          if (a.inStock != b.inStock) {
            return (b.inStock ? 1 : 0) - (a.inStock ? 1 : 0);
          }
          return a.price.compareTo(b.price);
        });

      debugPrint('   ✅ נמצאו ${results.length} תוצאות');
      debugPrint('   📦 ${results.where((r) => r.inStock).length} במלאי');

      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('   ❌ שגיאה בחיפוש: $e');
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isSearching = false;
      });
    }
  }

  void _handleAddPriceAlert(String productName, double? defaultPrice) async {
    debugPrint('🔔 SmartPriceTracker: יוצר התראת מחיר ל-"$productName"');

    final cs = Theme.of(context).colorScheme;
    final controller = TextEditingController(
      text: defaultPrice != null ? defaultPrice.toStringAsFixed(2) : '',
    );

    final target = await showDialog<double>(
      context: context,
      builder: (dialogContext) => Directionality(
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
              onPressed: () {
                debugPrint('   ❌ בוטל');
                Navigator.pop(dialogContext);
              },
              child: const Text('בטל'),
            ),
            FilledButton(
              onPressed: () {
                final v =
                    double.tryParse(controller.text.replaceAll(',', '.'));
                debugPrint('   ✅ נבחר מחיר: ₪${v?.toStringAsFixed(2)}');
                Navigator.pop(dialogContext, v);
              },
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                minimumSize: const Size(kButtonHeight, kButtonHeight),
              ),
              child: const Text('שמור'),
            ),
          ],
        ),
      ),
    );

    if (target == null || target <= 0) {
      debugPrint('   ⚠️ מחיר לא תקין או בוטל');
      return;
    }

    setState(() {
      _priceAlerts.add(
        PriceAlert(
          productName: productName,
          targetPrice: target,
          createdAt: DateTime.now(),
        ),
      );
    });

    debugPrint('   ✅ התראה נוספה: $productName < ₪${target.toStringAsFixed(2)}');

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("התראת מחיר ל־$productName נוספה!"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  PriceResult? get _bestOfferInStock {
    // אחרי המיון למעלה, ההצעה הראשונה שבמלאי תהיה "הטובה ביותר"
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
        padding: const EdgeInsets.all(kSpacingMedium),
        children: [
          _buildSearchHeader(cs),
          const SizedBox(height: kSpacingMedium),

          // Loading State
          if (_isSearching) const Center(child: CircularProgressIndicator()),

          // Error State
          if (_hasError && !_isSearching) _buildErrorState(cs),

          // Results
          if (!_isSearching && !_hasError && _searchResults.isNotEmpty)
            _buildSearchResults(cs),

          // Empty State - אחרי חיפוש שלא מצא כלום
          if (!_isSearching &&
              !_hasError &&
              _searchResults.isEmpty &&
              _lastQuery != null)
            _buildEmptyState(cs),

          const SizedBox(height: kSpacingMedium),
          _buildRecommended(cs),
          const SizedBox(height: kSpacingMedium),

          if (_priceAlerts.isNotEmpty) _buildAlertsSection(cs),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(ColorScheme cs) {
    return Card(
      color: cs.tertiaryContainer.withValues(alpha: 0.25),
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
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
                    borderRadius: BorderRadius.circular(kSpacingSmall),
                  ),
                  child: Icon(Icons.track_changes, color: cs.onPrimary),
                ),
                const SizedBox(width: kSpacingMedium - 4),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
            const SizedBox(height: kSpacingMedium),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _handlePriceSearch,
                    decoration: InputDecoration(
                      hintText: "חפש מוצר...",
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              tooltip: 'נקה חיפוש',
                              onPressed: () {
                                debugPrint('🗑️ SmartPriceTracker: ניקוי חיפוש');
                                setState(() {
                                  _searchController.clear();
                                  _searchResults.clear();
                                  _lastQuery = null;
                                  _hasError = false;
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: kSpacingSmall),
                ElevatedButton(
                  onPressed: _searchController.text.trim().isNotEmpty
                      ? () => _handlePriceSearch(_searchController.text)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                    minimumSize: const Size(kButtonHeight, kButtonHeight),
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

  Widget _buildErrorState(ColorScheme cs) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: kSpacingMedium),
            const Text(
              'אופס! משהו השתבש',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: kSpacingSmall),
            const Text(
              'לא הצלחנו לטעון את המחירים. נסה שוב מאוחר יותר.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingLarge),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('נסה שוב'),
              onPressed: () {
                if (_lastQuery != null) {
                  _handlePriceSearch(_lastQuery!);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                minimumSize: const Size(kButtonHeight * 2, kButtonHeight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: kSpacingMedium),
            Text(
              'לא נמצאו תוצאות ל"$_lastQuery"',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: kSpacingSmall),
            const Text(
              'נסה לחפש מוצר אחר או בחר מהמוצרים המומלצים למטה',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
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
        padding: const EdgeInsets.all(kSpacingMedium),
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
                    icon: const Icon(Icons.notifications_active, size: 18),
                    label: const Text("התראה למחיר"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.primary,
                      side: BorderSide(color: cs.primary),
                      minimumSize: const Size(140, kButtonHeight),
                    ),
                    onPressed: () =>
                        _handleAddPriceAlert(_lastQuery!, best?.price),
                  ),
              ],
            ),
            const SizedBox(height: kSpacingMedium - 4),

            // רשימת התוצאות
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchResults.length,
              separatorBuilder: (_, __) => const SizedBox(height: kSpacingSmall),
              itemBuilder: (_, i) {
                final result = _searchResults[i];
                final isBest = best != null &&
                    result.store == best.store &&
                    result.price == best.price;

                final bg = result.inStock
                    ? (isBest
                        ? cs.primaryContainer.withValues(alpha: 0.30)
                        : cs.surfaceContainerHighest.withValues(alpha: 0.35))
                    : Colors.red.shade50;

                final borderColor = isBest
                    ? cs.primary
                    : (result.inStock ? cs.outline : Colors.red.shade200);

                return Container(
                  padding: const EdgeInsets.all(kSpacingMedium - 4),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(kSpacingSmall),
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
                                color:
                                    result.inStock ? Colors.green : Colors.red,
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
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.flash_on, color: Colors.orange),
                SizedBox(width: kSpacingSmall),
                Text(
                  "מוצרים מומלצים לבדיקה",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: kSpacingMedium - 4),
            Wrap(
              spacing: kSpacingSmall,
              runSpacing: kSpacingSmall,
              children: _kPopularProducts
                  .map(
                    (product) => ActionChip(
                      label: Text(product),
                      onPressed: () {
                        debugPrint(
                            '💡 SmartPriceTracker: נבחר מוצר מומלץ - $product');
                        _handlePriceSearch(product);
                      },
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
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notifications, color: Colors.blue),
                SizedBox(width: kSpacingSmall),
                Text(
                  "התראות מחירים פעילות",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: kSpacingMedium - 4),
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
