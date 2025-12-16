// 📄 File: lib/widgets/dialogs/expiry_alert_dialog.dart
// 🎯 Purpose: דיאלוג התראת תפוגה קרובה - מוצג בכניסה לאפליקציה
//
// 📋 Features:
// - הצגת מוצרים שפג תוקפם או עומדים לפוג
// - צבעים לפי דחיפות (אדום - פג, כתום - קרוב)
// - כפתור "אל תציג שוב היום"
// - עיצוב sticky note
//
// 🔗 Related:
// - inventory_provider.dart - קבלת פריטים לפי תפוגה
// - inventory_settings_dialog.dart - הגדרת ימים להתראה
//
// Version: 1.0
// Created: 16/12/2025

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/ui_constants.dart';
import '../../models/inventory_item.dart';
import '../common/sticky_note.dart';

/// מפתח שמירה להסתרת התראה היום
const _kLastDismissedKey = 'expiry_alert_last_dismissed';

/// תוצאת הדיאלוג
enum ExpiryAlertResult {
  /// עבור למזווה
  goToPantry,

  /// סגור (אל תציג שוב היום)
  dismissToday,

  /// סגור רגיל
  dismiss,
}

/// בודק אם צריך להציג התראת תפוגה
///
/// מחזיר true אם:
/// 1. יש פריטים שפג תוקפם או עומדים לפוג
/// 2. ההתראה לא הוסתרה היום
Future<bool> shouldShowExpiryAlert({
  required List<InventoryItem> expiringItems,
}) async {
  if (expiringItems.isEmpty) return false;

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

/// מסנן פריטים לפי תפוגה
///
/// מחזיר פריטים שפג תוקפם או עומדים לפוג תוך [daysThreshold] ימים
List<InventoryItem> filterExpiringItems(
  List<InventoryItem> items, {
  int daysThreshold = 7,
}) {
  final now = DateTime.now();
  final threshold = now.add(Duration(days: daysThreshold));

  return items.where((item) {
    if (item.expiryDate == null) return false;
    return item.expiryDate!.isBefore(threshold);
  }).toList()
    // מיון: פג תוקף ראשון, אחריו הקרובים ביותר
    ..sort((a, b) {
      if (a.expiryDate == null) return 1;
      if (b.expiryDate == null) return -1;
      return a.expiryDate!.compareTo(b.expiryDate!);
    });
}

/// מציג דיאלוג התראת תפוגה
///
/// Example:
/// ```dart
/// final expiringItems = filterExpiringItems(inventoryProvider.items);
/// if (await shouldShowExpiryAlert(expiringItems: expiringItems)) {
///   final result = await showExpiryAlertDialog(
///     context: context,
///     expiringItems: expiringItems,
///   );
///   // handle result...
/// }
/// ```
Future<ExpiryAlertResult?> showExpiryAlertDialog({
  required BuildContext context,
  required List<InventoryItem> expiringItems,
}) async {
  return showDialog<ExpiryAlertResult>(
    context: context,
    builder: (context) => _ExpiryAlertDialog(
      expiringItems: expiringItems,
    ),
  );
}

class _ExpiryAlertDialog extends StatelessWidget {
  final List<InventoryItem> expiringItems;

  const _ExpiryAlertDialog({
    required this.expiringItems,
  });

  Future<void> _dismissToday(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLastDismissedKey, DateTime.now().toIso8601String());
    } catch (e) {
      // ignore
    }
    if (context.mounted) {
      Navigator.of(context).pop(ExpiryAlertResult.dismissToday);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ספירת פגי תוקף וקרובים לתפוגה
    final expiredCount = expiringItems.where((i) => i.isExpired).length;
    final expiringSoonCount = expiringItems.length - expiredCount;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          child: StickyNote(
            color: expiredCount > 0 ? kStickyPink : kStickyOrange,
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
                          color: expiredCount > 0
                              ? Colors.red.shade100
                              : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(kBorderRadius),
                        ),
                        child: Text(
                          expiredCount > 0 ? '⚠️' : '⏰',
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: kSpacingSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expiredCount > 0 ? 'פג תוקף!' : 'תפוגה קרובה',
                              style: TextStyle(
                                fontSize: kFontSizeLarge,
                                fontWeight: FontWeight.bold,
                                color: expiredCount > 0
                                    ? Colors.red.shade800
                                    : Colors.orange.shade800,
                              ),
                            ),
                            Text(
                              _buildSubtitle(expiredCount, expiringSoonCount),
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
                            Navigator.of(context).pop(ExpiryAlertResult.dismiss),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),

                  const SizedBox(height: kSpacingMedium),

                  // === רשימת פריטים ===
                  Container(
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(kSpacingSmall),
                      itemCount:
                          expiringItems.length > 6 ? 6 : expiringItems.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = expiringItems[index];
                        return _ExpiryItemTile(item: item);
                      },
                    ),
                  ),

                  // הודעה אם יש יותר מ-6 פריטים
                  if (expiringItems.length > 6)
                    Padding(
                      padding: const EdgeInsets.only(top: kSpacingSmall),
                      child: Text(
                        'ועוד ${expiringItems.length - 6} מוצרים...',
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
                  ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).pop(ExpiryAlertResult.goToPantry);
                    },
                    icon: const Icon(Icons.inventory_2),
                    label: const Text('עבור למזווה'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          expiredCount > 0 ? Colors.red : Colors.orange,
                      foregroundColor: Colors.white,
                    ),
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

  String _buildSubtitle(int expiredCount, int expiringSoonCount) {
    final parts = <String>[];
    if (expiredCount > 0) {
      parts.add('$expiredCount פג תוקף');
    }
    if (expiringSoonCount > 0) {
      parts.add('$expiringSoonCount קרוב לתפוגה');
    }
    return parts.join(' | ');
  }
}

/// שורת פריט בתפוגה
class _ExpiryItemTile extends StatelessWidget {
  final InventoryItem item;

  const _ExpiryItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isExpired = item.isExpired;
    final daysUntilExpiry = item.expiryDate != null
        ? item.expiryDate!.difference(DateTime.now()).inDays
        : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpacingTiny),
      child: Row(
        children: [
          // אייקון לפי מצב
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isExpired ? Colors.red.shade100 : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isExpired ? '⛔' : '⏰',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: kSpacingSmall),

          // שם המוצר
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isExpired ? Colors.red.shade800 : null,
                    decoration: isExpired ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatExpiryText(isExpired, daysUntilExpiry),
                  style: TextStyle(
                    fontSize: kFontSizeTiny,
                    color: isExpired
                        ? Colors.red.shade600
                        : Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),

          // תאריך תפוגה
          if (item.expiryDate != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: kSpacingSmall,
                vertical: kSpacingXTiny,
              ),
              decoration: BoxDecoration(
                color: isExpired ? Colors.red.shade100 : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(kBorderRadiusSmall),
              ),
              child: Text(
                DateFormat('dd/MM').format(item.expiryDate!),
                style: TextStyle(
                  color:
                      isExpired ? Colors.red.shade800 : Colors.orange.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: kFontSizeSmall,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatExpiryText(bool isExpired, int daysUntilExpiry) {
    if (isExpired) {
      final daysAgo = -daysUntilExpiry;
      if (daysAgo == 0) return 'פג היום';
      if (daysAgo == 1) return 'פג אתמול';
      return 'פג לפני $daysAgo ימים';
    } else {
      if (daysUntilExpiry == 0) return 'פג היום!';
      if (daysUntilExpiry == 1) return 'פג מחר';
      return 'פג בעוד $daysUntilExpiry ימים';
    }
  }
}
