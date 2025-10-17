// 📄 File: lib/screens/receipts/receipt_view_screen.dart
// 🎯 Purpose: מסך תצוגת קבלה בודדת - Receipt View Screen
//
// 📋 Features:
// ✅ תצוגה מפורטת של קבלה
// ✅ רשימת פריטים עם מחירים
// ✅ סיכום כללי
// ✅ Empty State
// ✅ RTL Support מלא
// ✅ Logging מפורט
//
// 🔗 Dependencies:
// - Receipt model - מודל הקבלה
//
// 🎨 Material 3:
// - צבעים דרך Theme/ColorScheme
// - ui_constants לעיצוב
// - RTL support

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/receipt.dart';
import '../../core/ui_constants.dart';

class ReceiptViewScreen extends StatelessWidget {
  final Receipt receipt;

  const ReceiptViewScreen({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    debugPrint('🧾 ReceiptViewScreen: מציג קבלה "${receipt.storeName}"');
    debugPrint('   📋 ${receipt.items.length} פריטים | סה"כ: ₪${receipt.totalAmount}');
    
    final cs = Theme.of(context).colorScheme;
    final dateStr = DateFormat('dd/MM/yyyy', 'he_IL').format(receipt.date);
    final currency = NumberFormat.currency(locale: 'he_IL', symbol: '₪');

    final itemsCount = receipt.items.length;
    final totalQty = receipt.items.fold<int>(0, (s, it) => s + it.quantity);
    final totalAmount = receipt.totalAmount;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: Text('קבלה מ-${receipt.storeName}'),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
          actions: [
            IconButton(
              tooltip: 'שיתוף (בקרוב)',
              onPressed: () {
                debugPrint('📤 ReceiptViewScreen: שיתוף קבלה (בקרוב)');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('שיתוף קבלה — בקרוב'),
                    duration: kSnackBarDuration,
                  ),
                );
              },
              icon: const Icon(Icons.ios_share),
            ),
          ],
        ),
        body: Column(
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                kSpacingMedium,
                kSpacingMedium,
                kSpacingMedium,
                kSpacingSmallPlus,
              ),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                border: Border(
                  bottom: BorderSide(
                    color: cs.outlineVariant.withValues(alpha: 0.4),
                    width: kBorderWidth,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(Icons.store_mall_directory, color: cs.primary),
                      const SizedBox(width: kSpacingSmall),
                      Expanded(
                        child: Text(
                          receipt.storeName,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: kFontSizeMedium,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: kSpacingSmall),
                  Wrap(
                    spacing: kSpacingSmall,
                    runSpacing: kSpacingSmall,
                    alignment: WrapAlignment.end,
                    children: [
                      _Chip(
                        icon: Icons.event,
                        label: dateStr,
                        color: cs.primary,
                      ),
                      _Chip(
                        icon: Icons.inventory_2_outlined,
                        label: '$itemsCount פריטים',
                        color: cs.secondary,
                      ),
                      _Chip(
                        icon: Icons.calculate_outlined,
                        label: '$totalQty יחידות',
                        color: cs.tertiary,
                      ),
                    ],
                  ),
                  const SizedBox(height: kSpacingSmallPlus),
                  Row(
                    children: [
                      Text(
                        currency.format(totalAmount),
                        style: TextStyle(
                          fontSize: kFontSizeXLarge,
                          fontWeight: FontWeight.w900,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(width: kSpacingSmall),
                      Text(
                        'סה״כ לתשלום',
                        style: TextStyle(
                          fontSize: kFontSizeSmall,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Items list
            Expanded(
              child: receipt.items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(height: kSpacingSmallPlus),
                          Text(
                            'אין פריטים בקבלה',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kSpacingSmallPlus,
                        vertical: kSpacingSmall,
                      ),
                      itemCount: receipt.items.length,
                      separatorBuilder: (_, index) => Divider(
                        height: kBorderWidth,
                        color: cs.outlineVariant.withValues(alpha: 0.2),
                      ),
                      itemBuilder: (context, index) {
                        final it = receipt.items[index];
                        final lineTotal = it.totalPrice; // מניח שקיים במודל
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: kSpacingSmall,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: cs.primary.withValues(alpha: 0.12),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            it.name ?? 'ללא שם',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${it.quantity} × ${currency.format(it.unitPrice)}',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                          trailing: Text(
                            currency.format(lineTotal),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        );
                      },
                    ),
            ),

            // Footer summary bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                kSpacingMedium,
                kSpacingSmallPlus,
                kSpacingMedium,
                kSpacingSmallPlus,
              ),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                border: Border(
                  top: BorderSide(
                    color: cs.outlineVariant.withValues(alpha: 0.4),
                    width: kBorderWidth,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.summarize_outlined, color: cs.primary),
                  const SizedBox(width: kSpacingSmall),
                  Expanded(
                    child: Text(
                      'סה״כ: $itemsCount פריטים • $totalQty יחידות',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(width: kSpacingSmallPlus),
                  Text(
                    currency.format(totalAmount),
                    style: TextStyle(
                      fontSize: kFontSizeMedium,
                      fontWeight: FontWeight.w900,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            debugPrint('📤 ReceiptViewScreen: FAB ייצוא/שיתוף (בקרוב)');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ייצוא/שיתוף קבלה — בקרוב'),
                duration: kSnackBarDuration,
              ),
            );
          },
          icon: const Icon(Icons.share),
          label: const Text('שתף'),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kSpacingSmallPlus,
        vertical: kSpacingXTiny,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(kBorderRadiusLarge + kSpacingSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: kIconSizeSmall, color: color),
          const SizedBox(width: kSpacingXTiny),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: kFontSizeTiny,
            ),
          ),
        ],
      ),
    );
  }
}
