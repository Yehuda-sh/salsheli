// 📄 lib/widgets/dialogs/expiry_alert_dialog.dart
//
// דיאלוג התראת תפוגה קרובה - מוצג בכניסה לאפליקציה.
// כולל צבעים לפי דחיפות, כפתור "אל תציג שוב היום", ועיצוב sticky note.
//
// ✅ תיקונים:
//    - צבעים מ-Theme (scheme.error/brand.warning) במקום Colors קשיחים
//    - חישוב ימים מבוסס תאריך בלבד (ללא שעות)
//    - barrierDismissible: false למניעת סגירה בטעות
//    - כל הטקסטים מ-AppStrings
//    - "הצג עוד X מוצרים" הפך לכפתור לחיץ
//
// 🔗 Related: InventoryItem, InventoryProvider, StickyNote, AppBrand

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/inventory_item.dart';
import '../../theme/app_theme.dart';
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
/// מחזיר פריטים שפג תוקפם או עומדים לפוג תוך [daysThreshold] ימים.
/// מגביל פריטים שפגו לפני [maxDaysExpired] ימים (ברירת מחדל: 30).
List<InventoryItem> filterExpiringItems(
  List<InventoryItem> items, {
  int daysThreshold = 7,
  int maxDaysExpired = 30,
}) {
  final today = _dateOnly(DateTime.now());
  final threshold = today.add(Duration(days: daysThreshold));
  final oldestExpired = today.subtract(Duration(days: maxDaysExpired));

  return items.where((item) {
    if (item.expiryDate == null) return false;
    final expiryDate = _dateOnly(item.expiryDate!);
    // ✅ Inclusive: כולל גם את הגבולות (עד 7 ימים כולל, עד 30 יום אחורה כולל)
    return !expiryDate.isBefore(oldestExpired) && !expiryDate.isAfter(threshold);
  }).toList()
    // מיון: פג תוקף ראשון, אחריו הקרובים ביותר
    ..sort((a, b) {
      if (a.expiryDate == null) return 1;
      if (b.expiryDate == null) return -1;
      return a.expiryDate!.compareTo(b.expiryDate!);
    });
}

/// ✅ Helper: תאריך בלי שעה (למניעת חישוב שגוי של ימים)
DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// ✅ חישוב ימים עד תפוגה מבוסס תאריך בלבד
int _daysUntilExpiry(DateTime expiryDate) {
  final today = _dateOnly(DateTime.now());
  final expiry = _dateOnly(expiryDate);
  return expiry.difference(today).inDays;
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
    // ✅ מניעת סגירה בלחיצה מחוץ לדיאלוג
    barrierDismissible: false,
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
    final scheme = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();

    // ✅ ספירה מבוססת daysUntilExpiry לעקביות עם התצוגה
    final expiredCount = expiringItems.where((i) {
      if (i.expiryDate == null) return false;
      return _daysUntilExpiry(i.expiryDate!) < 0;
    }).length;
    final expiringSoonCount = expiringItems.length - expiredCount;

    // ✅ צבעים מה-Theme במקום Colors קשיחים
    final isExpiredMode = expiredCount > 0;
    final stickyColor = isExpiredMode
        ? (brand?.stickyPink ?? kStickyPink)
        : (brand?.stickyYellow ?? kStickyYellow);
    final accentColor = isExpiredMode ? scheme.error : (brand?.warning ?? scheme.tertiary);
    final containerColor = isExpiredMode
        ? scheme.errorContainer
        : (brand?.warningContainer ?? scheme.tertiaryContainer);
    final onContainerColor = isExpiredMode
        ? scheme.onErrorContainer
        : (brand?.onWarningContainer ?? scheme.onTertiaryContainer);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          child: StickyNote(
            color: stickyColor,
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
                          color: containerColor,
                          borderRadius: BorderRadius.circular(kBorderRadius),
                        ),
                        child: Text(
                          isExpiredMode ? '⚠️' : '⏰',
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: kSpacingSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isExpiredMode
                                  ? AppStrings.inventory.expiryAlertTitleExpired
                                  : AppStrings.inventory.expiryAlertTitleExpiringSoon,
                              style: TextStyle(
                                fontSize: kFontSizeLarge,
                                fontWeight: FontWeight.bold,
                                color: onContainerColor,
                              ),
                            ),
                            Text(
                              AppStrings.inventory.expiryAlertSubtitle(
                                expiredCount,
                                expiringSoonCount,
                              ),
                              style: TextStyle(
                                fontSize: kFontSizeSmall,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ✅ כפתור סגירה - מתנהג כמו "אל תציג שוב היום" לחוויה שקטה יותר
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => _dismissToday(context),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),

                  const SizedBox(height: kSpacingMedium),

                  // === רשימת פריטים ===
                  Container(
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      color: scheme.surface.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(kSpacingSmall),
                      itemCount: expiringItems.length > 6 ? 6 : expiringItems.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = expiringItems[index];
                        return _ExpiryItemTile(
                          item: item,
                          scheme: scheme,
                          brand: brand,
                        );
                      },
                    ),
                  ),

                  // ✅ "הצג עוד X מוצרים" כפתור לחיץ
                  if (expiringItems.length > 6)
                    Padding(
                      padding: const EdgeInsets.only(top: kSpacingSmall),
                      child: TextButton(
                        onPressed: () {
                          unawaited(HapticFeedback.selectionClick());
                          Navigator.of(context).pop(ExpiryAlertResult.goToPantry);
                        },
                        child: Text(
                          AppStrings.inventory.expiryAlertMoreItems(
                            expiringItems.length - 6,
                          ),
                          style: TextStyle(
                            fontSize: kFontSizeSmall,
                            color: accentColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: kSpacingMedium),

                  // === כפתורי פעולה ===
                  ElevatedButton.icon(
                    onPressed: () {
                      unawaited(HapticFeedback.mediumImpact());
                      Navigator.of(context).pop(ExpiryAlertResult.goToPantry);
                    },
                    icon: const Icon(Icons.inventory_2),
                    label: Text(AppStrings.inventory.expiryAlertGoToPantry),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: isExpiredMode
                          ? scheme.onError
                          : (brand?.onWarningContainer ?? scheme.onTertiary),
                    ),
                  ),

                  const SizedBox(height: kSpacingSmall),

                  // אל תציג שוב היום
                  TextButton(
                    onPressed: () => _dismissToday(context),
                    child: Text(
                      AppStrings.inventory.expiryAlertDismissToday,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
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

/// שורת פריט בתפוגה
class _ExpiryItemTile extends StatelessWidget {
  final InventoryItem item;
  final ColorScheme scheme;
  final AppBrand? brand;

  const _ExpiryItemTile({
    required this.item,
    required this.scheme,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ חישוב ימים מבוסס תאריך בלבד - מקור אמת אחד
    final daysUntilExpiry =
        item.expiryDate != null ? _daysUntilExpiry(item.expiryDate!) : 0;
    final isExpired = daysUntilExpiry < 0;

    // ✅ צבעים מה-Theme
    final containerColor = isExpired
        ? scheme.errorContainer
        : (brand?.warningContainer ?? scheme.tertiaryContainer);
    final textColor = isExpired
        ? scheme.onErrorContainer
        : (brand?.onWarningContainer ?? scheme.onTertiaryContainer);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpacingTiny),
      child: Row(
        children: [
          // אייקון לפי מצב
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: containerColor,
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
                    color: isExpired ? scheme.error : scheme.onSurface,
                    decoration: isExpired ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatExpiryText(isExpired, daysUntilExpiry),
                  style: TextStyle(
                    fontSize: kFontSizeTiny,
                    color: textColor,
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
                color: containerColor,
                borderRadius: BorderRadius.circular(kBorderRadiusSmall),
              ),
              child: Text(
                DateFormat('dd/MM').format(item.expiryDate!),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: kFontSizeSmall,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// ✅ פורמט טקסט תפוגה מ-AppStrings
  String _formatExpiryText(bool isExpired, int daysUntilExpiry) {
    if (isExpired) {
      final daysAgo = -daysUntilExpiry;
      if (daysAgo == 0) return AppStrings.inventory.expiryExpiredToday;
      if (daysAgo == 1) return AppStrings.inventory.expiryExpiredYesterday;
      return AppStrings.inventory.expiryExpiredDaysAgo(daysAgo);
    } else {
      if (daysUntilExpiry == 0) return AppStrings.inventory.expiryExpiresToday;
      if (daysUntilExpiry == 1) return AppStrings.inventory.expiryExpiresTomorrow;
      return AppStrings.inventory.expiryExpiresInDays(daysUntilExpiry);
    }
  }
}
