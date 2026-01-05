// 📄 File: lib/widgets/dialogs/recurring_product_dialog.dart
// 🎯 Purpose: דיאלוג הצעה להפוך מוצר למוצר קבוע
//
// 📋 Features:
// - הצגת סטטיסטיקות קנייה
// - אפשרות לאשר / לדחות
// - "אל תשאל שוב על מוצר זה"
// - עיצוב sticky note
//
// ✅ תיקונים:
//    - המרה ל-StatefulWidget עם _isProcessing flag
//    - תמיכה ב-Dark Mode (kStickyGreenDark)
//    - הוספת Semantics wrapper לדיאלוג
//    - הוספת Tooltips לכפתורים
//    - הוספת unawaited() לקריאות HapticFeedback
//    - החלפת Colors.* בצבעים מה-Theme
//    - הוספת barrierDismissible: false
//
// 🔗 Related:
// - recurring_product_service.dart - לוגיקת זיהוי
// - inventory_provider.dart - עדכון מוצר
//
// TODO: העבר מחרוזות ל-AppStrings

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/ui_constants.dart';
import '../../models/inventory_item.dart';
import '../../theme/app_theme.dart';
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
    // ✅ מניעת סגירה בלחיצה מחוץ לדיאלוג
    barrierDismissible: false,
    builder: (context) => _RecurringProductDialog(item: item),
  );
}

class _RecurringProductDialog extends StatefulWidget {
  final InventoryItem item;

  const _RecurringProductDialog({required this.item});

  @override
  State<_RecurringProductDialog> createState() =>
      _RecurringProductDialogState();
}

class _RecurringProductDialogState extends State<_RecurringProductDialog> {
  bool _isProcessing = false;

  /// אישור - הפוך למוצר קבוע
  void _confirmRecurring() {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    unawaited(HapticFeedback.mediumImpact());
    Navigator.of(context).pop(RecurringProductResult.confirm);
  }

  /// דחייה - אל תשאל שוב על מוצר זה
  void _dismissProduct() {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    unawaited(HapticFeedback.lightImpact());
    Navigator.of(context).pop(RecurringProductResult.dismiss);
  }

  /// דחייה זמנית - שאל אחר כך
  void _askLater() {
    if (_isProcessing) return;
    unawaited(HapticFeedback.selectionClick());
    Navigator.of(context).pop(RecurringProductResult.later);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final isDark = theme.brightness == Brightness.dark;

    // ✅ צבעים מה-Theme + Dark Mode
    final stickyColor = isDark ? kStickyGreenDark : kStickyGreen;
    final successColor = brand?.success ?? scheme.primary;
    final warningColor = brand?.warning ?? scheme.tertiary;

    // ✅ Semantics label
    final dialogLabel =
        'הצעה להפוך את ${widget.item.productName} למוצר קבוע';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Semantics(
        label: dialogLabel,
        container: true,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: StickyNote(
              color: stickyColor,
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
                            color: scheme.tertiaryContainer,
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
                              Text(
                                'מוצר פופולרי!',
                                style: TextStyle(
                                  fontSize: kFontSizeLarge,
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface,
                                ),
                              ),
                              Text(
                                'נראה שאתה קונה את זה לעתים קרובות',
                                style: TextStyle(
                                  fontSize: kFontSizeSmall,
                                  color: scheme.onSurfaceVariant,
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
                        color: scheme.surface.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                        border: Border.all(
                          color: successColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          // שם המוצר
                          Text(
                            widget.item.productName,
                            style: TextStyle(
                              fontSize: kFontSizeMedium,
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
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
                                value: '${widget.item.purchaseCount}',
                                label: 'קניות',
                                color: scheme.primary,
                              ),
                              const SizedBox(width: kSpacingMedium),
                              if (widget.item.lastPurchased != null)
                                _StatBadge(
                                  icon: Icons.calendar_today,
                                  value: _formatLastPurchase(
                                    widget.item.lastPurchased!,
                                  ),
                                  label: 'קנייה אחרונה',
                                  color: scheme.tertiary,
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
                        color: scheme.tertiaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: warningColor,
                            size: 20,
                          ),
                          const SizedBox(width: kSpacingSmall),
                          Expanded(
                            child: Text(
                              'מוצר קבוע יתווסף אוטומטית לרשימות קניות חדשות',
                              style: TextStyle(
                                fontSize: kFontSizeSmall,
                                color: scheme.onTertiaryContainer,
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
                        Tooltip(
                          message: 'לא להציע מוצר זה כמוצר קבוע',
                          child: TextButton(
                            onPressed: _isProcessing ? null : _dismissProduct,
                            child: Text(
                              'לא, תודה',
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                          ),
                        ),

                        const Spacer(),

                        // אישור
                        Tooltip(
                          message: 'הפוך למוצר קבוע',
                          child: ElevatedButton.icon(
                            onPressed: _isProcessing ? null : _confirmRecurring,
                            icon: const Icon(Icons.star),
                            label: const Text('הפוך לקבוע'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheme.tertiary,
                              foregroundColor: scheme.onTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // === אפשרות לדחות ===
                    Tooltip(
                      message: 'תזכיר לי בפעם הבאה',
                      child: TextButton(
                        onPressed: _isProcessing ? null : _askLater,
                        child: Text(
                          'שאל אותי אחר כך',
                          style: TextStyle(
                            fontSize: kFontSizeSmall,
                            color: scheme.onSurfaceVariant,
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
      ),
    );
  }
}

/// תג סטטיסטיקה קטן
///
/// ✅ צבעים מ-Theme במקום Colors קשיחים
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
    final scheme = Theme.of(context).colorScheme;

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
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
