// 📄 lib/screens/history/receipt_details_screen.dart
//
// מסך פרטי קבלה - צפייה בקנייה בודדת.
// מציג רשימת פריטים, סיכום מחירים, תאריך וחנות.
//
// Version 1.0 - No AppBar (Immersive)
// Last Updated: 13/01/2026
//
// 🔗 Related: Receipt, ShoppingHistoryScreen

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/receipt.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_note.dart';

class ReceiptDetailsScreen extends StatelessWidget {
  final Receipt receipt;

  const ReceiptDetailsScreen({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final strings = AppStrings.receiptDetails;
    // ✅ FIX: Use locale from context instead of hardcoded 'he'
    final locale = Localizations.localeOf(context).languageCode;
    // ✅ FIX: Theme-aware success color for virtual receipts
    final successColor = theme.extension<AppBrand>()?.success ?? kStickyGreen;

    return Stack(
      children: [
        const NotebookBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(kSpacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🏷️ כותרת inline
                  Padding(
                    padding: const EdgeInsets.only(bottom: kSpacingMedium),
                    child: Row(
                      children: [
                        // כפתור חזרה
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: cs.onSurface),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Icon(Icons.receipt_long, size: 24, color: cs.primary),
                        const SizedBox(width: kSpacingSmall),
                        Expanded(
                          child: Text(
                            receipt.storeName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // === כותרת קבלה ===
                  StickyNote(
                    color: receipt.isVirtual ? kStickyGreen : kStickyYellow,
                    child: Padding(
                      padding: const EdgeInsets.all(kSpacingMedium),
                      child: Column(
                        children: [
                          // אייקון
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              // ✅ FIX: Theme-aware colors
                              color: receipt.isVirtual
                                  ? successColor.withValues(alpha: 0.2)
                                  : cs.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              receipt.isVirtual
                                  ? Icons.shopping_cart
                                  : Icons.receipt_long,
                              size: 40,
                              color: receipt.isVirtual ? successColor : cs.primary,
                            ),
                          ),

                          const SizedBox(height: kSpacingMedium),

                          // שם חנות
                          Text(
                            receipt.storeName,
                            style: const TextStyle(
                              fontSize: kFontSizeLarge,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: kSpacingSmall),

                          // תאריך
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 16, color: cs.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                // ✅ FIX: Use locale from context
                                DateFormat('EEEE, dd/MM/yyyy', locale)
                                    .format(receipt.date),
                                style: TextStyle(
                                  fontSize: kFontSizeSmall,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: kSpacingSmall),

                          // תגיות
                          Wrap(
                            spacing: kSpacingSmall,
                            children: [
                              if (receipt.isVirtual)
                                _Tag(
                                  label: strings.virtualTag,
                                  color: successColor,
                                  icon: Icons.auto_awesome,
                                ),
                              if (receipt.linkedShoppingListId != null)
                                _Tag(
                                  label: strings.linkedToListTag,
                                  color: cs.tertiary,
                                  icon: Icons.link,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: kSpacingMedium),

                  // === סיכום ===
                  StickyNote(
                    color: kStickyCyan,
                    child: Padding(
                      padding: const EdgeInsets.all(kSpacingMedium),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _SummaryItem(
                            label: strings.itemsLabel,
                            value: '${receipt.items.length}',
                            icon: Icons.shopping_bag,
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: cs.outlineVariant,
                          ),
                          _SummaryItem(
                            label: strings.totalLabel,
                            value: '₪${receipt.totalAmount.toStringAsFixed(2)}',
                            icon: Icons.payments,
                            highlight: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: kSpacingMedium),

                  // === רשימת פריטים ===
                  Text(
                    strings.itemsSectionTitle,
                    style: TextStyle(
                      fontSize: kFontSizeMedium,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),

                  const SizedBox(height: kSpacingSmall),

                  if (receipt.items.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(kSpacingLarge),
                        child: Text(
                          strings.noItemsMessage,
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ),
                    )
                  else
                    ...receipt.items.map((item) => _ItemTile(item: item)),

                  const SizedBox(height: kSpacingLarge),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ========================================
// Widget: תגית
// ========================================

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _Tag({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: kFontSizeTiny,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// Widget: פריט סיכום
// ========================================

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(
          icon,
          // ✅ FIX: Theme-aware color instead of Colors.grey
          color: highlight ? cs.primary : cs.onSurfaceVariant,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? kFontSizeLarge : kFontSizeMedium,
            fontWeight: FontWeight.bold,
            color: highlight ? cs.primary : cs.onSurface,
          ),
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
// Widget: שורת פריט
// ========================================

class _ItemTile extends StatelessWidget {
  final ReceiptItem item;

  const _ItemTile({required this.item});

  /// ✅ FIX: Format quantity to avoid "1.0" display
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
    final strings = AppStrings.receiptDetails;
    // ✅ FIX: Theme-aware success color
    final successColor = theme.extension<AppBrand>()?.success ?? kStickyGreen;
    // ✅ FIX: Detect dark mode for background
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      padding: const EdgeInsets.all(kSpacingMedium),
      decoration: BoxDecoration(
        // ✅ FIX: Theme-aware background color
        color: isDark
            ? cs.surfaceContainerHigh
            : cs.surface,
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Checkbox (אם נקנה)
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              // ✅ FIX: Theme-aware colors
              color: item.isChecked
                  ? successColor
                  : cs.outlineVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: item.isChecked
                ? Icon(Icons.check, color: cs.onPrimary, size: 16)
                : null,
          ),

          const SizedBox(width: kSpacingMedium),

          // שם וכמות
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name ?? strings.unknownItemName,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    decoration: item.isChecked ? TextDecoration.lineThrough : null,
                    color: item.isChecked
                        ? cs.onSurface.withValues(alpha: 0.5)
                        : cs.onSurface,
                  ),
                  // ✅ FIX: Overflow protection
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (item.category != null)
                  Text(
                    item.category!,
                    style: TextStyle(
                      fontSize: kFontSizeTiny,
                      // ✅ FIX: Theme-aware color
                      color: cs.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),

          // כמות
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              // ✅ FIX: Format quantity to avoid "×1.0"
              '×${_formatQuantity(item.quantity)}',
              style: TextStyle(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: kFontSizeSmall,
              ),
            ),
          ),

          const SizedBox(width: kSpacingSmall),

          // מחיר
          Text(
            '₪${item.totalPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}
