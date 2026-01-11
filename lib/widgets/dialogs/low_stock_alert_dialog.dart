// 📄 lib/widgets/dialogs/low_stock_alert_dialog.dart
//
// דיאלוג התראת מלאי נמוך - מוצג בכניסה לאפליקציה.
// כולל הוספה לרשימת קניות, כפתור "אל תציג שוב היום", ועיצוב sticky note.
//
// ✅ תיקונים:
//    - הוספת unawaited() לקריאות HapticFeedback
//    - תמיכה ב-Dark Mode (kStickyOrangeDark)
//    - הסרת Directionality wrapper - נתן ל-Locale לקבוע
//    - המרה ל-StatefulWidget עם _isProcessing flag
//    - מחרוזות קשיחות הועברו ל-AppStrings
//    - כפתור X משונה לסגירה רגילה (לא "אל תציג שוב היום")
//    - "עוד X מוצרים" הפך לכפתור לחיץ
//    - צבע כמות משתמש ב-warningContainer (לא errorContainer)
//    - הוספת Semantics ו-Tooltips לנגישות
//
// 🔗 Related: InventoryItem, InventoryProvider, StickyNote

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/inventory_item.dart';
import '../../theme/app_theme.dart';
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
    // ✅ מניעת סגירה בלחיצה מחוץ לדיאלוג
    barrierDismissible: false,
    builder: (context) => _LowStockAlertDialog(
      lowStockItems: lowStockItems,
    ),
  );
}

class _LowStockAlertDialog extends StatefulWidget {
  final List<InventoryItem> lowStockItems;

  const _LowStockAlertDialog({
    required this.lowStockItems,
  });

  @override
  State<_LowStockAlertDialog> createState() => _LowStockAlertDialogState();
}

class _LowStockAlertDialogState extends State<_LowStockAlertDialog> {
  bool _isProcessing = false;

  /// ✅ סגירה רגילה - לא שומר "אל תציג שוב היום"
  void _dismiss() {
    if (_isProcessing) return;
    Navigator.of(context).pop(LowStockAlertResult.dismiss);
  }

  /// ✅ סגירה עם "אל תציג שוב היום"
  Future<void> _dismissToday() async {
    // ✅ מניעת לחיצות כפולות
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kLastDismissedKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      // ignore
    }

    if (!mounted) return;

    Navigator.of(context).pop(LowStockAlertResult.dismissToday);
  }

  /// ✅ הוספה לרשימת קניות
  void _addToList() {
    if (_isProcessing) return;
    unawaited(HapticFeedback.mediumImpact());
    Navigator.of(context).pop(LowStockAlertResult.addToList);
  }

  /// ✅ מעבר למזווה
  void _goToPantry() {
    if (_isProcessing) return;
    unawaited(HapticFeedback.selectionClick());
    Navigator.of(context).pop(LowStockAlertResult.goToPantry);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final isDark = theme.brightness == Brightness.dark;
    final itemCount = widget.lowStockItems.length;

    // ✅ צבעים מה-Theme במקום Colors קשיחים + Dark Mode
    final warningContainerColor = brand?.warningContainer ?? scheme.tertiaryContainer;
    final onWarningContainerColor = brand?.onWarningContainer ?? scheme.onTertiaryContainer;
    final stickyColor = isDark ? kStickyOrangeDark : kStickyOrange;

    // ✅ Semantics wrapper לנגישות - מחרוזות מ-AppStrings
    final dialogLabel = AppStrings.inventory.lowStockAlertSemanticLabel(itemCount);

    // ✅ הסרת Directionality - נתן ל-Locale של האפליקציה לקבוע
    return Semantics(
      label: dialogLabel,
      container: true,
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
                          color: warningContainerColor,
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
                            Text(
                              AppStrings.inventory.lowStockAlertTitle,
                              style: TextStyle(
                                fontSize: kFontSizeLarge,
                                fontWeight: FontWeight.bold,
                                color: onWarningContainerColor,
                              ),
                            ),
                            Text(
                              AppStrings.inventory.lowStockAlertSubtitle(itemCount),
                              style: TextStyle(
                                fontSize: kFontSizeSmall,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ✅ כפתור סגירה - סגירה רגילה (לא "אל תציג שוב היום")
                      Tooltip(
                        message: AppStrings.inventory.lowStockAlertCloseTooltip,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _isProcessing ? null : _dismiss,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: kSpacingMedium),

                  // === רשימת פריטים ===
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: scheme.surface.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(kSpacingSmall),
                      itemCount: widget.lowStockItems.length > 5
                          ? 5
                          : widget.lowStockItems.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = widget.lowStockItems[index];
                        return _LowStockItemTile(
                          item: item,
                          scheme: scheme,
                          brand: brand,
                        );
                      },
                    ),
                  ),

                  // ✅ "הצג עוד X מוצרים" כפתור לחיץ
                  if (widget.lowStockItems.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(top: kSpacingSmall),
                      child: TextButton(
                        onPressed: _goToPantry,
                        child: Text(
                          AppStrings.inventory.lowStockAlertMoreItems(
                            widget.lowStockItems.length - 5,
                          ),
                          style: TextStyle(
                            fontSize: kFontSizeSmall,
                            color: brand?.warning ?? scheme.tertiary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: kSpacingMedium),

                  // === כפתורי פעולה ===
                  Row(
                    children: [
                      // הוסף לרשימה
                      Expanded(
                        flex: 2,
                        child: Tooltip(
                          message: AppStrings.inventory.lowStockAlertAddToListTooltip,
                          child: ElevatedButton.icon(
                            onPressed: _isProcessing ? null : _addToList,
                            icon: const Icon(Icons.add_shopping_cart),
                            label: Text(AppStrings.inventory.lowStockAlertAddToList),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheme.primary,
                              foregroundColor: scheme.onPrimary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: kSpacingSmall),

                      // עבור למזווה
                      Expanded(
                        child: Tooltip(
                          message: AppStrings.inventory.lowStockAlertGoToPantryTooltip,
                          child: OutlinedButton(
                            onPressed: _isProcessing ? null : _goToPantry,
                            child: Text(AppStrings.inventory.lowStockAlertGoToPantry),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: kSpacingSmall),

                  // אל תציג שוב היום
                  Tooltip(
                    message: AppStrings.inventory.lowStockAlertDismissTodayTooltip,
                    child: TextButton(
                      onPressed: _isProcessing ? null : _dismissToday,
                      child: Text(
                        AppStrings.inventory.lowStockAlertDismissToday,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: kFontSizeSmall,
                        ),
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
  final ColorScheme scheme;
  final AppBrand? brand;

  const _LowStockItemTile({
    required this.item,
    required this.scheme,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ צבעים מה-Theme - warningContainer במקום errorContainer
    final warningColor = brand?.warning ?? scheme.tertiary;
    final warningContainerColor = brand?.warningContainer ?? scheme.tertiaryContainer;
    final onWarningContainerColor = brand?.onWarningContainer ?? scheme.onTertiaryContainer;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpacingTiny),
      child: Row(
        children: [
          // אייקון אזהרה
          Icon(
            Icons.warning_amber,
            color: warningColor,
            size: 18,
          ),
          const SizedBox(width: kSpacingSmall),

          // שם המוצר
          Expanded(
            child: Text(
              item.productName,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: scheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // ✅ כמות - משתמש ב-warningContainer (לא errorContainer)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: kSpacingSmall,
              vertical: kSpacingXTiny,
            ),
            decoration: BoxDecoration(
              color: warningContainerColor,
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            ),
            child: Text(
              '${item.quantity} ${item.unit}',
              style: TextStyle(
                color: onWarningContainerColor,
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
