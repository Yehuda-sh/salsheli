// 📄 lib/screens/history/shopping_history_screen.dart
//
// מסך היסטוריית קניות - צפייה בקבלות קודמות.
// כולל חיפוש, מיון, וסטטיסטיקות הוצאות.
// ללא AppBar - כותרת inline עם SafeArea
//
// Version: 1.1 - No AppBar (Immersive)
// Last Updated: 13/01/2026
// 🔗 Related: ReceiptProvider, Receipt, ReceiptDetailsScreen

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/receipt.dart';
import '../../providers/receipt_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_note.dart';
import 'receipt_details_screen.dart';

class ShoppingHistoryScreen extends StatefulWidget {
  const ShoppingHistoryScreen({super.key});

  @override
  State<ShoppingHistoryScreen> createState() => _ShoppingHistoryScreenState();
}

class _ShoppingHistoryScreenState extends State<ShoppingHistoryScreen> {
  String _searchQuery = '';
  String _sortBy = 'date'; // date, store, amount

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final strings = AppStrings.shoppingHistory;

    return Stack(
      children: [
        const NotebookBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Consumer<ReceiptProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.hasError) {
                return _ErrorState(
                  message: provider.errorMessage ?? strings.defaultError,
                  onRetry: () => provider.retry(),
                );
              }

              final receipts = _filterAndSortReceipts(provider.receipts);

              if (receipts.isEmpty && _searchQuery.isEmpty) {
                return _EmptyState();
              }

              // חשב סטטיסטיקות
              final totalSpent = receipts.fold<double>(
                0,
                (sum, r) => sum + r.totalAmount,
              );
              final avgPerTrip =
                  receipts.isNotEmpty ? totalSpent / receipts.length : 0.0;

              return Column(
                children: [
                  // 🏷️ כותרת inline עם מיון
                  Padding(
                    padding: const EdgeInsets.all(kSpacingMedium),
                    child: Row(
                      children: [
                        Icon(Icons.receipt_long, size: 24, color: cs.primary),
                        const SizedBox(width: kSpacingSmall),
                        Expanded(
                          child: Text(
                            strings.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        // מיון
                        PopupMenuButton<String>(
                          icon: Icon(Icons.sort, color: cs.primary),
                          tooltip: strings.sortTooltip,
                          onSelected: (value) {
                            setState(() => _sortBy = value);
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'date',
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 18),
                                  const SizedBox(width: kSpacingSmall),
                                  Text(strings.sortByDate),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'store',
                              child: Row(
                                children: [
                                  const Icon(Icons.store, size: 18),
                                  const SizedBox(width: kSpacingSmall),
                                  Text(strings.sortByStore),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'amount',
                              child: Row(
                                children: [
                                  const Icon(Icons.attach_money, size: 18),
                                  const SizedBox(width: kSpacingSmall),
                                  Text(strings.sortByAmount),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 🔍 חיפוש
                  Padding(
                    padding: const EdgeInsets.all(kSpacingMedium),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: strings.searchHint,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kBorderRadius),
                        ),
                        filled: true,
                        fillColor: cs.surface,
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                    ),
                  ),

                  // 📊 סטטיסטיקות
                  Builder(
                    builder: (context) {
                      final successColor =
                          theme.extension<AppBrand>()?.success ?? kStickyGreen;
                      final accentColor =
                          theme.extension<AppBrand>()?.accent ?? cs.tertiary;
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: kSpacingMedium),
                        padding: const EdgeInsets.all(kSpacingMedium),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(kBorderRadius),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatItem(
                              icon: Icons.receipt_long,
                              label: strings.shoppingsLabel,
                              value: '${receipts.length}',
                              color: cs.primary,
                            ),
                            _StatItem(
                              icon: Icons.payments,
                              label: strings.totalLabel,
                              value: '₪${totalSpent.toStringAsFixed(0)}',
                              color: successColor,
                            ),
                            _StatItem(
                              icon: Icons.trending_up,
                              label: strings.averageLabel,
                              value: '₪${avgPerTrip.toStringAsFixed(0)}',
                              color: accentColor,
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: kSpacingSmall),

                  // 📋 רשימת קבלות
                  Expanded(
                    child: receipts.isEmpty
                        ? Center(
                            child: Text(
                              strings.noResults,
                              style: TextStyle(color: cs.onSurfaceVariant),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(kSpacingMedium),
                            itemCount: receipts.length,
                            itemBuilder: (context, index) {
                              final receipt = receipts[index];
                              return _ReceiptTile(
                                receipt: receipt,
                                onTap: () => _openReceiptDetails(receipt),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
          ),
        ),
      ],
    );
  }

  /// סינון ומיון קבלות
  List<Receipt> _filterAndSortReceipts(List<Receipt> receipts) {
    var filtered = receipts.toList();

    // סינון לפי חיפוש
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        return r.storeName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // מיון
    switch (_sortBy) {
      case 'date':
        filtered.sort((a, b) => b.date.compareTo(a.date)); // חדש קודם
        break;
      case 'store':
        filtered.sort((a, b) => a.storeName.compareTo(b.storeName));
        break;
      case 'amount':
        filtered.sort((a, b) => b.totalAmount.compareTo(a.totalAmount)); // גבוה קודם
        break;
    }

    return filtered;
  }

  void _openReceiptDetails(Receipt receipt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptDetailsScreen(receipt: receipt),
      ),
    );
  }
}

// ========================================
// Widget: כרטיס קבלה
// ========================================

class _ReceiptTile extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback onTap;

  const _ReceiptTile({
    required this.receipt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final strings = AppStrings.shoppingHistory;
    // ✅ FIX: Use locale from context
    final locale = Localizations.localeOf(context).languageCode;
    // ✅ FIX: Theme-aware success color
    final successColor = theme.extension<AppBrand>()?.success ?? kStickyGreen;

    return Padding(
      padding: const EdgeInsets.only(bottom: kSpacingSmall),
      child: StickyNote(
        color: receipt.isVirtual ? kStickyGreen : kStickyYellow,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(kBorderRadius),
          child: Padding(
            padding: const EdgeInsets.all(kSpacingMedium),
            child: Row(
              children: [
                // אייקון
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    // ✅ FIX: Theme-aware color
                    color: receipt.isVirtual
                        ? successColor.withValues(alpha: 0.2)
                        : cs.primaryContainer,
                    borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                  ),
                  child: Icon(
                    receipt.isVirtual ? Icons.shopping_cart : Icons.receipt,
                    // ✅ FIX: Theme-aware color
                    color: receipt.isVirtual ? successColor : cs.primary,
                  ),
                ),

                const SizedBox(width: kSpacingMedium),

                // פרטים
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receipt.storeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: kFontSizeMedium,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              // ✅ FIX: Theme-aware color
                              size: 12, color: cs.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            // ✅ FIX: Use locale from context
                            DateFormat('dd/MM/yyyy', locale)
                                .format(receipt.date),
                            style: TextStyle(
                              fontSize: kFontSizeSmall,
                              // ✅ FIX: Theme-aware color
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: kSpacingSmall),
                          Icon(Icons.shopping_bag,
                              // ✅ FIX: Theme-aware color
                              size: 12, color: cs.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            // ✅ FIX: Use AppStrings
                            strings.itemsCount(receipt.items.length),
                            style: TextStyle(
                              fontSize: kFontSizeSmall,
                              // ✅ FIX: Theme-aware color
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // סכום
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₪${receipt.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: kFontSizeMedium,
                        color: cs.primary,
                      ),
                    ),
                    if (receipt.isVirtual)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          // ✅ FIX: Theme-aware color
                          color: successColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          // ✅ FIX: Use AppStrings
                          strings.virtualTag,
                          style: TextStyle(
                            fontSize: kFontSizeTiny,
                            // ✅ FIX: Theme-aware color
                            color: successColor,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: kSpacingSmall),

                // ✅ FIX: RTL-aware arrow icon
                Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========================================
// Widget: סטטיסטיקה
// ========================================

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: kFontSizeLarge,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: kFontSizeTiny,
            // ✅ FIX: Theme-aware color
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ========================================
// Widget: Empty State
// ========================================

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final strings = AppStrings.shoppingHistory;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 80,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: kSpacingMedium),
            Text(
              strings.emptyTitle,
              style: TextStyle(
                fontSize: kFontSizeLarge,
                fontWeight: FontWeight.bold,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: kSpacingSmall),
            Text(
              strings.emptySubtitle,
              style: TextStyle(
                fontSize: kFontSizeSmall,
                color: cs.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// Widget: Error State
// ========================================

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final strings = AppStrings.shoppingHistory;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              // ✅ FIX: Theme-aware error color
              color: cs.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: kSpacingMedium),
            Text(
              message,
              style: TextStyle(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingMedium),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(strings.retryButton),
            ),
          ],
        ),
      ),
    );
  }
}
