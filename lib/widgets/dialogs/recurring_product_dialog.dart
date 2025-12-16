// 📄 File: lib/widgets/dialogs/recurring_product_dialog.dart
// 🎯 Purpose: דיאלוג הצעה להפוך מוצר למוצר קבוע
//
// 📋 Features:
// - הצגת סטטיסטיקות קנייה
// - אפשרות לאשר / לדחות
// - "אל תשאל שוב על מוצר זה"
// - עיצוב sticky note
//
// 🔗 Related:
// - recurring_product_service.dart - לוגיקת זיהוי
// - inventory_provider.dart - עדכון מוצר
//
// Version: 1.0
// Created: 16/12/2025

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/ui_constants.dart';
import '../../models/inventory_item.dart';
import '../common/sticky_note.dart';

/// תוצאת הדיאלוג
enum RecurringProductResult {
  /// המשתמש אישר - הפוך למוצר קבוע
  confirm,

  /// המשתמש דחה - אל תשאל על המוצר הזה שוב
  dismiss,

  /// המשתמש סגר - שאל שוב בפעם הבאה
  later,
}

/// מציג דיאלוג להצעת מוצר קבוע
///
/// Example:
/// ```dart
/// final candidate = await RecurringProductService.getTopRecurringCandidate(items);
/// if (candidate != null) {
///   final result = await showRecurringProductDialog(
///     context: context,
///     item: candidate,
///   );
///
///   if (result == RecurringProductResult.confirm) {
///     await inventoryProvider.updateItem(
///       candidate.copyWith(isRecurring: true),
///     );
///   } else if (result == RecurringProductResult.dismiss) {
///     await RecurringProductService.dismissProduct(candidate.id);
///   }
/// }
/// ```
Future<RecurringProductResult?> showRecurringProductDialog({
  required BuildContext context,
  required InventoryItem item,
}) async {
  return showDialog<RecurringProductResult>(
    context: context,
    builder: (context) => _RecurringProductDialog(item: item),
  );
}

class _RecurringProductDialog extends StatelessWidget {
  final InventoryItem item;

  const _RecurringProductDialog({required this.item});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: StickyNote(
            color: kStickyGreen,
            child: Padding(
              padding: const EdgeInsets.all(kSpacingMedium),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // === כותרת ===
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(kBorderRadius),
                        ),
                        child: const Text(
                          '⭐',
                          style: TextStyle(fontSize: 28),
                        ),
                      ),
                      const SizedBox(width: kSpacingSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'מוצר פופולרי!',
                              style: TextStyle(
                                fontSize: kFontSizeLarge,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'נראה שאתה קונה את זה לעתים קרובות',
                              style: TextStyle(
                                fontSize: kFontSizeSmall,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: kSpacingMedium),

                  // === פרטי המוצר ===
                  Container(
                    padding: const EdgeInsets.all(kSpacingMedium),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        // שם המוצר
                        Text(
                          item.productName,
                          style: const TextStyle(
                            fontSize: kFontSizeMedium,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: kSpacingSmall),

                        // סטטיסטיקות
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _StatBadge(
                              icon: Icons.shopping_cart,
                              value: '${item.purchaseCount}',
                              label: 'קניות',
                              color: Colors.blue,
                            ),
                            const SizedBox(width: kSpacingMedium),
                            if (item.lastPurchased != null)
                              _StatBadge(
                                icon: Icons.calendar_today,
                                value: _formatLastPurchase(item.lastPurchased!),
                                label: 'קנייה אחרונה',
                                color: Colors.purple,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: kSpacingMedium),

                  // === הסבר ===
                  Container(
                    padding: const EdgeInsets.all(kSpacingSmall),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            color: Colors.amber, size: 20),
                        const SizedBox(width: kSpacingSmall),
                        Expanded(
                          child: Text(
                            'מוצר קבוע יתווסף אוטומטית לרשימות קניות חדשות',
                            style: TextStyle(
                              fontSize: kFontSizeSmall,
                              color: Colors.brown.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: kSpacingLarge),

                  // === כפתורי פעולה ===
                  Row(
                    children: [
                      // אל תשאל שוב
                      TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context)
                              .pop(RecurringProductResult.dismiss);
                        },
                        child: Text(
                          'לא, תודה',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),

                      const Spacer(),

                      // אישור
                      ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(context)
                              .pop(RecurringProductResult.confirm);
                        },
                        icon: const Icon(Icons.star),
                        label: const Text('הפוך לקבוע'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  // === אפשרות לדחות ===
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(RecurringProductResult.later);
                    },
                    child: Text(
                      'שאל אותי אחר כך',
                      style: TextStyle(
                        fontSize: kFontSizeSmall,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatLastPurchase(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return 'היום';
    if (diff == 1) return 'אתמול';
    if (diff < 7) return 'לפני $diff ימים';
    if (diff < 30) return 'לפני ${(diff / 7).floor()} שבועות';
    return 'לפני ${(diff / 30).floor()} חודשים';
  }
}

/// תג סטטיסטיקה קטן
class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(kSpacingSmall),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: kSpacingTiny),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: kFontSizeMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: kSpacingXTiny),
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
