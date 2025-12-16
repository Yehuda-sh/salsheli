// 📄 File: lib/widgets/dialogs/low_stock_alert_dialog.dart
// 🎯 Purpose: דיאלוג התראת מלאי נמוך - מוצג בכניסה לאפליקציה
//
// 📋 Features:
// - הצגת רשימת פריטים במלאי נמוך
// - כפתור הוספה לרשימת קניות
// - כפתור "אל תציג שוב היום"
// - עיצוב sticky note
//
// 🔗 Related:
// - inventory_provider.dart - קבלת פריטים במלאי נמוך
// - select_list_dialog.dart - בחירת רשימה להוספה
//
// Version: 1.0
// Created: 16/12/2025

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/ui_constants.dart';
import '../../models/inventory_item.dart';
import '../common/sticky_note.dart';

/// מפתח שמירה להסתרת התראה היום
const _kLastDismissedKey = 'low_stock_alert_last_dismissed';

/// תוצאת הדיאלוג
enum LowStockAlertResult {
  /// הוסף לרשימת קניות
  addToList,

  /// עבור למזווה
  goToPantry,

  /// סגור (אל תציג שוב היום)
  dismissToday,

  /// סגור רגיל
  dismiss,
}

/// בודק אם צריך להציג התראת מלאי נמוך
///
/// מחזיר true אם:
/// 1. יש לפחות [minItems] פריטים במלאי נמוך
/// 2. ההתראה לא הוסתרה היום
Future<bool> shouldShowLowStockAlert({
  required List<InventoryItem> lowStockItems,
  int minItems = 3,
}) async {
  if (lowStockItems.length < minItems) return false;

  try {
    final prefs = await SharedPreferences.getInstance();
    final lastDismissed = prefs.getString(_kLastDismissedKey);

    if (lastDismissed != null) {
      final dismissedDate = DateTime.tryParse(lastDismissed);
      if (dismissedDate != null) {
        final today = DateTime.now();
        // אם הוסתר היום - לא להציג
        if (dismissedDate.year == today.year &&
            dismissedDate.month == today.month &&
            dismissedDate.day == today.day) {
          return false;
        }
      }
    }

    return true;
  } catch (e) {
    return true; // במקרה של שגיאה - הצג
  }
}

/// מציג דיאלוג התראת מלאי נמוך
///
/// Example:
/// ```dart
/// final lowStockItems = inventoryProvider.lowStockItems;
/// if (await shouldShowLowStockAlert(lowStockItems: lowStockItems)) {
///   final result = await showLowStockAlertDialog(
///     context: context,
///     lowStockItems: lowStockItems,
///   );
///   // handle result...
/// }
/// ```
Future<LowStockAlertResult?> showLowStockAlertDialog({
  required BuildContext context,
  required List<InventoryItem> lowStockItems,
}) async {
  return showDialog<LowStockAlertResult>(
    context: context,
    barrierDismissible: true, // Allow dismiss by tapping outside
    builder: (context) => _LowStockAlertDialog(
      lowStockItems: lowStockItems,
    ),
  );
}

class _LowStockAlertDialog extends StatelessWidget {
  final List<InventoryItem> lowStockItems;

  const _LowStockAlertDialog({
    required this.lowStockItems,
  });

  Future<void> _dismissToday(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLastDismissedKey, DateTime.now().toIso8601String());
    } catch (e) {
      // ignore
    }
    if (context.mounted) {
      Navigator.of(context).pop(LowStockAlertResult.dismissToday);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final itemCount = lowStockItems.length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          child: StickyNote(
            color: kStickyOrange,
            child: Padding(
              padding: const EdgeInsets.all(kSpacingMedium),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // === כותרת ===
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(kBorderRadius),
                        ),
                        child: const Text(
                          '⚠️',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: kSpacingSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'מלאי נמוך',
                              style: TextStyle(
                                fontSize: kFontSizeLarge,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$itemCount מוצרים עומדים להיגמר',
                              style: TextStyle(
                                fontSize: kFontSizeSmall,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // כפתור סגירה
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () =>
                            Navigator.of(context).pop(LowStockAlertResult.dismiss),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),

                  const SizedBox(height: kSpacingMedium),

                  // === רשימת פריטים ===
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(kSpacingSmall),
                      itemCount: lowStockItems.length > 5 ? 5 : lowStockItems.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = lowStockItems[index];
                        return _LowStockItemTile(item: item);
                      },
                    ),
                  ),

                  // הודעה אם יש יותר מ-5 פריטים
                  if (lowStockItems.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(top: kSpacingSmall),
                      child: Text(
                        'ועוד ${lowStockItems.length - 5} מוצרים...',
                        style: TextStyle(
                          fontSize: kFontSizeSmall,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: kSpacingMedium),

                  // === כפתורי פעולה ===
                  Row(
                    children: [
                      // הוסף לרשימה
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.of(context).pop(LowStockAlertResult.addToList);
                          },
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('הוסף לרשימה'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                          ),
                        ),
                      ),

                      const SizedBox(width: kSpacingSmall),

                      // עבור למזווה
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            Navigator.of(context).pop(LowStockAlertResult.goToPantry);
                          },
                          child: const Text('למזווה'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: kSpacingSmall),

                  // אל תציג שוב היום
                  TextButton(
                    onPressed: () => _dismissToday(context),
                    child: Text(
                      'אל תציג שוב היום',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: kFontSizeSmall,
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
}

/// שורת פריט במלאי נמוך
class _LowStockItemTile extends StatelessWidget {
  final InventoryItem item;

  const _LowStockItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpacingTiny),
      child: Row(
        children: [
          // אייקון אזהרה
          const Icon(
            Icons.warning_amber,
            color: Colors.orange,
            size: 18,
          ),
          const SizedBox(width: kSpacingSmall),

          // שם המוצר
          Expanded(
            child: Text(
              item.productName,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // כמות
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: kSpacingSmall,
              vertical: kSpacingXTiny,
            ),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            ),
            child: Text(
              '${item.quantity} ${item.unit}',
              style: TextStyle(
                color: Colors.red.shade800,
                fontWeight: FontWeight.bold,
                fontSize: kFontSizeSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
