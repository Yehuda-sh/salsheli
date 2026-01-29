// 📄 lib/screens/history/shopping_history_screen.dart
//
// מסך היסטוריית קניות - צפייה בקבלות קודמות.
// כולל חיפוש, מיון, וסטטיסטיקות הוצאות.
// שילוב: רקע מחברת + עיצוב Material נקי (AppBar + Cards)
//
// Version: 3.0 - ExpansionTile instead of separate screen
// Last Updated: 27/01/2026
// 🔗 Related: ReceiptProvider, Receipt

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/receipt.dart';
import '../../providers/receipt_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/notebook_background.dart';

class ShoppingHistoryScreen extends StatefulWidget {
  const ShoppingHistoryScreen({super.key});

  @override
  State<ShoppingHistoryScreen> createState() => _ShoppingHistoryScreenState();
}

class _ShoppingHistoryScreenState extends State<ShoppingHistoryScreen> {
  String _filterPeriod = 'month'; // month, 3months, all
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
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
        title: Text(strings.title),
        centerTitle: true,
        actions: [
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
                    const Icon(Icons.list_alt, size: 18),
                    const SizedBox(width: kSpacingSmall),
                    Text(strings.sortByList),
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
      body: Consumer<ReceiptProvider>(
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

              if (provider.receipts.isEmpty) {
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
                  // 🔍 סינון לפי תקופה
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kSpacingMedium,
                      vertical: kSpacingSmall,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilterChip(
                          label: Text(strings.filterThisMonth),
                          selected: _filterPeriod == 'month',
                          onSelected: (_) => setState(() => _filterPeriod = 'month'),
                        ),
                        const SizedBox(width: kSpacingSmall),
                        FilterChip(
                          label: Text(strings.filterThreeMonths),
                          selected: _filterPeriod == '3months',
                          onSelected: (_) => setState(() => _filterPeriod = '3months'),
                        ),
                        const SizedBox(width: kSpacingSmall),
                        FilterChip(
                          label: Text(strings.filterAll),
                          selected: _filterPeriod == 'all',
                          onSelected: (_) => setState(() => _filterPeriod = 'all'),
                        ),
                      ],
                    ),
                  ),

                  // 📊 סטטיסטיקות
                  Builder(
                    builder: (context) {
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
                              color: cs.primary,
                            ),
                            _StatItem(
                              icon: Icons.trending_up,
                              label: strings.averageLabel,
                              value: '₪${avgPerTrip.toStringAsFixed(0)}',
                              // ✅ FIX: צבע כהה יותר לקריאות טובה
                              color: cs.onPrimaryContainer,
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
                              return _ReceiptTile(receipt: receipt);
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// סינון ומיון קבלות
  List<Receipt> _filterAndSortReceipts(List<Receipt> receipts) {
    var filtered = receipts.toList();

    // סינון לפי תקופה (לפי חודש קלנדרי, לא חלון נע)
    final now = DateTime.now();
    switch (_filterPeriod) {
      case 'month':
        // תחילת החודש הנוכחי
        final firstOfMonth = DateTime(now.year, now.month, 1);
        filtered = filtered.where((r) => !r.date.isBefore(firstOfMonth)).toList();
        break;
      case '3months':
        // תחילת 3 חודשים אחורה (כולל החודש הנוכחי)
        final firstOf3MonthsAgo = DateTime(now.year, now.month - 2, 1);
        filtered = filtered.where((r) => !r.date.isBefore(firstOf3MonthsAgo)).toList();
        break;
      case 'all':
        // לא לסנן
        break;
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
}

// ========================================
// Widget: כרטיס קבלה מתרחב
// ========================================

class _ReceiptTile extends StatelessWidget {
  final Receipt receipt;

  const _ReceiptTile({required this.receipt});

  /// Format quantity to avoid "1.0" display
  String _formatQuantity(num quantity) {
    if (quantity == quantity.toInt()) {
      return quantity.toInt().toString();
    }
    return quantity.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final strings = AppStrings.shoppingHistory;
    final locale = Localizations.localeOf(context).languageCode;
    final successColor = theme.extension<AppBrand>()?.success ?? Colors.green;

    return Padding(
      padding: const EdgeInsets.only(bottom: kSpacingSmall),
      child: Card(
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: kSpacingMedium,
            vertical: kSpacingSmall,
          ),
          childrenPadding: const EdgeInsets.only(
            left: kSpacingMedium,
            right: kSpacingMedium,
            bottom: kSpacingMedium,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: receipt.isVirtual
                  ? successColor.withValues(alpha: 0.2)
                  : cs.primaryContainer,
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            ),
            child: Icon(
              receipt.isVirtual ? Icons.shopping_cart : Icons.receipt,
              color: receipt.isVirtual ? successColor : cs.primary,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  receipt.storeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: kFontSizeMedium,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '₪${receipt.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: kFontSizeMedium,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          subtitle: Row(
            children: [
              Icon(Icons.calendar_today, size: 12, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd/MM/yyyy', locale).format(receipt.date),
                style: TextStyle(fontSize: kFontSizeSmall, color: cs.onSurfaceVariant),
              ),
              const SizedBox(width: kSpacingSmall),
              Icon(Icons.shopping_bag, size: 12, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                strings.itemsCount(receipt.items.length),
                style: TextStyle(fontSize: kFontSizeSmall, color: cs.onSurfaceVariant),
              ),
              if (receipt.isVirtual) ...[
                const SizedBox(width: kSpacingSmall),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: successColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    strings.virtualTag,
                    style: TextStyle(fontSize: kFontSizeTiny, color: successColor),
                  ),
                ),
              ],
            ],
          ),
          // רשימת פריטים בהרחבה
          children: [
            const Divider(height: 1),
            const SizedBox(height: kSpacingSmall),
            if (receipt.items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(kSpacingMedium),
                child: Text(
                  AppStrings.receiptDetails.noItemsMessage,
                  style: TextStyle(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...receipt.items.map((item) => _buildItemRow(context, item, cs, successColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, ReceiptItem item, ColorScheme cs, Color successColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kSpacingSmall),
      child: Row(
        children: [
          // Checkbox indicator
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: item.isChecked
                  ? successColor
                  : cs.outlineVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: item.isChecked
                ? Icon(Icons.check, color: cs.onPrimary, size: 14)
                : null,
          ),
          const SizedBox(width: kSpacingSmall),
          // כמות - מיד אחרי ה-checkbox
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '×${_formatQuantity(item.quantity)}',
              style: TextStyle(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: kFontSizeSmall,
              ),
            ),
          ),
          const SizedBox(width: kSpacingSmall),
          // שם פריט
          Expanded(
            child: Text(
              item.name ?? '?',
              style: TextStyle(
                decoration: item.isChecked ? TextDecoration.lineThrough : null,
                color: item.isChecked
                    ? cs.onSurface.withValues(alpha: 0.5)
                    : cs.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // מחיר
          Text(
            '₪${item.totalPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: cs.primary,
              fontSize: kFontSizeSmall,
            ),
          ),
        ],
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
