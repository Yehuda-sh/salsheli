/// 📄 File: lib/screens/price/price_comparison_screen.dart
///
/// 🎯 תפקיד: מסך השוואת מחירים בין סניפים/חנויות שונים
///
/// 📦 תלות:
/// - ProductsProvider: חיפוש מוצרים במאגר המוצרים
/// - AppStrings.priceComparison: מחרוזות UI
/// - ui_constants: spacing, borders, fonts
///
/// ✨ תכונות:
/// - 🔍 חיפוש מוצר לפי שם
/// - 📊 השוואת מחירים (מיון מהזול ליקר)
/// - 💰 חישוב חיסכון פוטנציאלי
/// - 🏪 זיהוי החנות הזולה ביותר
/// - 🎨 Visual feedback (צבע ירוק למחיר הזול)
///
/// 📝 Flow:
/// 1. משתמש מזין שם מוצר
/// 2. חיפוש ב-ProductsProvider (searchProducts)
/// 3. מיון תוצאות לפי מחיר
/// 4. הצגה עם סימון "הכי זול" + חיסכון
///
/// 🔄 State Management:
/// - Consumer with ProductsProvider לקריאת נתונים
/// - context.read with ProductsProvider() לפעולות
///
/// Version: 2.0 (עם ProductsProvider + AppStrings + Logging)

library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

import '../../providers/products_provider.dart';
import '../../l10n/app_strings.dart';
import '../../core/ui_constants.dart';

class PriceComparisonScreen extends StatefulWidget {
  const PriceComparisonScreen({super.key});

  @override
  State<PriceComparisonScreen> createState() => _PriceComparisonScreenState();
}

class _PriceComparisonScreenState extends State<PriceComparisonScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String _searchTerm = "";
  List<Map<String, dynamic>> _results = [];

  final _money = NumberFormat.currency(
    locale: 'he_IL',
    symbol: '₪',
    decimalDigits: 2,
  );

  @override
  void dispose() {
    debugPrint('🗑️ PriceComparisonScreen.dispose()');
    _searchController.dispose();
    super.dispose();
  }

  /// 🔍 חיפוש מוצרים באמצעות ProductsProvider
  Future<void> _searchPrices() async {
    final term = _searchController.text.trim();
    if (term.isEmpty) return;

    debugPrint('🔍 _searchPrices: searching for "$term"');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchTerm = term;
      _results = [];
    });

    try {
      final provider = context.read<ProductsProvider>();
      final products = await provider.searchProducts(term);

      debugPrint('   📦 Found ${products.length} products');

      if (products.isEmpty) {
        debugPrint('   ❌ No products found');
        setState(() {
          _results = [];
        });
        return;
      }

      // המרה לפורמט תוצאות עם מיון לפי מחיר
      final results = products.map((p) {
        return {
          'product': p['name'] as String,
          'store': p['store_name'] as String? ?? 'לא ידוע',
          'price': (p['price'] as num?)?.toDouble(),
          'category': p['category'] as String? ?? '',
        };
      }).toList();

      // סינון רק מוצרים עם מחיר + מיון
      results.removeWhere((r) => r['price'] == null);
      results.sort((a, b) {
        final pa = (a['price'] as double?) ?? double.infinity;
        final pb = (b['price'] as double?) ?? double.infinity;
        return pa.compareTo(pb);
      });

      debugPrint('   ✅ Processed ${results.length} results with prices');

      if (!mounted) return;
      setState(() {
        _results = results;
      });
    } catch (e) {
      debugPrint('   ❌ Error during search: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      // שמירת מצב isLoading אם עדיין mounted
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 🔄 נסה שוב אחרי שגיאה
  void _retry() {
    debugPrint('🔄 _retry: retrying search');
    _errorMessage = null;
    _searchPrices();
  }

  /// 🧹 ניקוי חיפוש
  void _clearSearch() {
    debugPrint('🧹 _clearSearch: clearing search');
    setState(() {
      _searchController.clear();
      _results = [];
      _searchTerm = "";
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final strings = AppStrings.priceComparison;

    // חישוב min/max בצורה בטוחה
    final prices = _results.map((r) => (r['price'] as num).toDouble()).toList();
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
          title: Text(strings.title),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(kSpacingMedium),
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
                          hintText: strings.searchHint,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: strings.clearTooltip,
                                  icon: const Icon(Icons.clear),
                                  onPressed: _clearSearch,
                                ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(kBorderRadius),
                          ),
                          filled: true,
                          fillColor: cs.surfaceContainerHighest,
                        ),
                      ),
                    ),
                    SizedBox(width: kSpacingSmall),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _searchPrices,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        padding: EdgeInsets.symmetric(
                          horizontal: kButtonPaddingHorizontal,
                          vertical: kButtonPaddingVertical,
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: kIconSizeMedium,
                              height: kIconSizeMedium,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(strings.searchButton),
                    ),
                  ],
                ),

                SizedBox(height: kSpacingMedium),

                // === 3 Empty States ===

                // ⏳ Loading
                if (_isLoading && _results.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          SizedBox(height: kSpacingMedium),
                          Text(
                            strings.searching,
                            style: TextStyle(
                              fontSize: kFontSizeBody,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ❌ Error
                if (_errorMessage != null && !_isLoading)
                  Expanded(
                    child: Center(
                      child: Card(
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: EdgeInsets.all(kSpacingMedium),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: kIconSizeLarge * 2,
                                color: Colors.red,
                              ),
                              SizedBox(height: kSpacingMedium),
                              Text(
                                strings.errorTitle,
                                style: TextStyle(
                                  fontSize: kFontSizeLarge,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade900,
                                ),
                              ),
                              SizedBox(height: kSpacingSmall),
                              Text(
                                strings.searchError(_errorMessage!),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: kFontSizeBody,
                                  color: Colors.red.shade800,
                                ),
                              ),
                              SizedBox(height: kSpacingMedium),
                              ElevatedButton(
                                onPressed: _retry,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(strings.retry),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // 📭 Empty (no results)
                if (!_isLoading &&
                    _errorMessage == null &&
                    _results.isEmpty &&
                    _searchTerm.isNotEmpty)
                  Expanded(
                    child: Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(kSpacingLarge),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: kIconSizeLarge * 2,
                                color: Colors.grey,
                              ),
                              SizedBox(height: kSpacingMedium),
                              Text(
                                strings.noResultsTitle,
                                style: TextStyle(
                                  fontSize: kFontSizeLarge,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: kSpacingSmall),
                              Text(
                                strings.noResultsMessage(_searchTerm),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: kFontSizeBody,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(height: kSpacingSmall),
                              Text(
                                strings.noResultsHint,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: kFontSizeSmall,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // 📭 Empty (initial state)
                if (!_isLoading &&
                    _errorMessage == null &&
                    _results.isEmpty &&
                    _searchTerm.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.compare_arrows,
                            size: kIconSizeLarge * 2,
                            color: cs.primary,
                          ),
                          SizedBox(height: kSpacingMedium),
                          Text(
                            strings.emptyStateTitle,
                            style: TextStyle(
                              fontSize: kFontSizeLarge,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: kSpacingSmall),
                          Text(
                            strings.emptyStateMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: kFontSizeBody,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 📊 Results
                if (!_isLoading && _errorMessage == null && _results.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      strings.searchResults(_searchTerm),
                      style: TextStyle(
                        fontSize: kFontSizeLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: kSpacingSmallPlus),

                  Expanded(
                    child: ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final item = _results[index];
                        final price = (item['price'] as double?) ?? 0.0;
                        final isCheapest = minPrice != null && price == minPrice;

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: kSpacingSmall / 2),
                          child: ListTile(
                            leading: Icon(
                              Icons.store,
                              color: isCheapest ? Colors.green : cs.primary,
                            ),
                            title: Text("${item['product']}"),
                            subtitle: Text("${item['store']}"),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _money.format(price),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: kFontSizeBody,
                                    color: isCheapest ? Colors.green : cs.onSurface,
                                  ),
                                ),
                                if (isCheapest)
                                  Text(
                                    strings.cheapestLabel,
                                    style: TextStyle(
                                      fontSize: kFontSizeSmall,
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

                  // 💰 Savings Card
                  if (minPrice != null && maxPrice != null && minPrice < maxPrice)
                    Card(
                      color: Colors.green.withValues(alpha: 0.06),
                      margin: EdgeInsets.only(top: kSpacingSmallPlus),
                      child: ListTile(
                        leading: Text(
                          strings.savingsIcon,
                          style: TextStyle(fontSize: kFontSizeLarge),
                        ),
                        title: Text(strings.savingsLabel),
                        subtitle: Text(_money.format(maxPrice - minPrice)),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
