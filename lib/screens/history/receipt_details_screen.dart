// 📄 File: lib/screens/history/receipt_details_screen.dart
//
// 🎯 Purpose: מסך פרטי קבלה - צפייה בפרטי קנייה בודדת
//
// ✨ Features:
// - 📋 רשימת פריטים שנקנו
// - 💰 סיכום מחירים
// - 📅 תאריך וחנות
// - 🖼️ תמונת קבלה (אם קיימת)
// - 🎨 עיצוב Sticky Note
//
// Version: 1.0
// Created: 16/12/2025

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../core/ui_constants.dart';
import '../../models/receipt.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_note.dart';

class ReceiptDetailsScreen extends StatelessWidget {
  final Receipt receipt;

  const ReceiptDetailsScreen({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Stack(
      children: [
        const NotebookBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: cs.primary,
            foregroundColor: Colors.white,
            title: Text(
              receipt.storeName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(kSpacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                            color: receipt.isVirtual
                                ? Colors.green.withValues(alpha: 0.2)
                                : cs.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            receipt.isVirtual
                                ? Icons.shopping_cart
                                : Icons.receipt_long,
                            size: 40,
                            color:
                                receipt.isVirtual ? Colors.green : cs.primary,
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
                            const Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('EEEE, dd/MM/yyyy', 'he')
                                  .format(receipt.date),
                              style: TextStyle(
                                fontSize: kFontSizeSmall,
                                color: Colors.grey.shade700,
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
                              const _Tag(
                                label: 'וירטואלי',
                                color: Colors.green,
                                icon: Icons.auto_awesome,
                              ),
                            if (receipt.linkedShoppingListId != null)
                              const _Tag(
                                label: 'מקושר לרשימה',
                                color: Colors.blue,
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
                          label: 'פריטים',
                          value: '${receipt.items.length}',
                          icon: Icons.shopping_bag,
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey.withValues(alpha: 0.3),
                        ),
                        _SummaryItem(
                          label: 'סה"כ',
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
                  'פריטים',
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
                        'אין פריטים בקבלה',
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
          color: highlight ? cs.primary : Colors.grey,
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
            color: Colors.grey.shade600,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      padding: const EdgeInsets.all(kSpacingMedium),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Checkbox (אם נקנה)
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: item.isChecked
                  ? Colors.green
                  : Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: item.isChecked
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),

          const SizedBox(width: kSpacingMedium),

          // שם וכמות
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name ?? 'פריט ללא שם',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    decoration: item.isChecked ? TextDecoration.lineThrough : null,
                    color: item.isChecked
                        ? cs.onSurface.withValues(alpha: 0.5)
                        : cs.onSurface,
                  ),
                ),
                if (item.category != null)
                  Text(
                    item.category!,
                    style: TextStyle(
                      fontSize: kFontSizeTiny,
                      color: Colors.grey.shade600,
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
              '×${item.quantity}',
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
