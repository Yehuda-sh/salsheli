import 'package:flutter/material.dart';
import 'package:salsheli/core/ui_constants.dart';
import 'package:flutter/services.dart';
import 'package:salsheli/config/filters_config.dart';
import 'package:salsheli/core/status_colors.dart';
import 'package:salsheli/l10n/app_strings.dart';
import 'package:salsheli/models/enums/shopping_item_status.dart';
import 'package:salsheli/models/unified_list_item.dart';
import 'package:salsheli/theme/app_theme.dart';

class ActiveShoppingItemTile extends StatelessWidget {
  final UnifiedListItem item;
  final ShoppingItemStatus status;
  final void Function(ShoppingItemStatus) onStatusChanged;
  final void Function(int newQuantity) onQuantityChanged;

  const _ActiveShoppingItemTile({
    required this.item,
    required this.status,
    required this.onStatusChanged,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // 🎨 צבע רקע לפי סטטוס
    Color? backgroundColor;
    switch (status) {
      case ShoppingItemStatus.purchased:
        backgroundColor = StatusColors.success.withValues(alpha: 0.15);
        break;
      case ShoppingItemStatus.outOfStock:
        backgroundColor = StatusColors.error.withValues(alpha: 0.15);
        break;
      case ShoppingItemStatus.notNeeded:
        backgroundColor = cs.onSurfaceVariant.withValues(alpha: 0.2);
        break;
      default:
        backgroundColor = null;
    }

    // 🆕 Swipe-to-reveal: לחיצה = קניתי, החלקה = חושפת כפתורים
    return Dismissible(
      key: ValueKey('swipe_${item.id}'),
      confirmDismiss: (direction) async {
        unawaited(HapticFeedback.lightImpact());
        if (direction == DismissDirection.startToEnd) {
          // החלקה ימינה (RTL: startToEnd = ימין) → אין במלאי
          if (status == ShoppingItemStatus.outOfStock) {
            onStatusChanged(ShoppingItemStatus.pending);
          } else {
            onStatusChanged(ShoppingItemStatus.outOfStock);
          }
        } else {
          // החלקה שמאלה → לא צריך
          if (status == ShoppingItemStatus.notNeeded) {
            onStatusChanged(ShoppingItemStatus.pending);
          } else {
            onStatusChanged(ShoppingItemStatus.notNeeded);
          }
        }
        return false; // לא להסיר מהרשימה
      },
      // רקע החלקה ימינה — אין במלאי
      background: Container(
        height: kNotebookLineSpacing,
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsetsDirectional.only(start: kSpacingMedium),
        decoration: BoxDecoration(
          color: StatusColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.remove_shopping_cart, color: StatusColors.error, size: 20),
            const SizedBox(width: 4),
            Text(
              AppStrings.shopping.legendOutOfStock,
              style: TextStyle(color: StatusColors.error, fontSize: kFontSizeSmall, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      // רקע החלקה שמאלה — לא צריך
      secondaryBackground: Container(
        height: kNotebookLineSpacing,
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: kSpacingMedium),
        decoration: BoxDecoration(
          color: cs.onSurfaceVariant.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.shopping.legendNotNeeded,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: kFontSizeSmall, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 4),
            Icon(Icons.block, color: cs.onSurfaceVariant, size: 20),
          ],
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          unawaited(HapticFeedback.selectionClick());
          if (status == ShoppingItemStatus.purchased) {
            onStatusChanged(ShoppingItemStatus.pending);
          } else {
            onStatusChanged(ShoppingItemStatus.purchased);
          }
        },
        child: Container(
          height: kNotebookLineSpacing,
          decoration: backgroundColor != null
              ? BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                )
              : null,
          child: Row(
            children: [
              // ✅ אינדיקטור סטטוס (לא כפתור — לחיצה על כל השורה)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    status == ShoppingItemStatus.purchased
                        ? Icons.check_circle
                        : status == ShoppingItemStatus.outOfStock
                            ? Icons.remove_shopping_cart
                            : status == ShoppingItemStatus.notNeeded
                                ? Icons.block
                                : Icons.circle_outlined,
                    key: ValueKey(status),
                    color: status == ShoppingItemStatus.purchased
                        ? StatusColors.success
                        : status == ShoppingItemStatus.outOfStock
                            ? StatusColors.error
                            : status == ShoppingItemStatus.notNeeded
                                ? cs.onSurfaceVariant
                                : cs.outline.withValues(alpha: 0.5),
                    size: 28,
                  ),
                ),
              ),

              const SizedBox(width: kSpacingSmall),

              // 📝 שם המוצר + כמות
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: Duration(milliseconds: 200),
                  style: theme.textTheme.bodyLarge!.copyWith(
                    decoration: status == ShoppingItemStatus.purchased
                        ? TextDecoration.lineThrough
                        : null,
                    color: status == ShoppingItemStatus.purchased ||
                            status == ShoppingItemStatus.notNeeded
                        ? cs.onSurfaceVariant.withValues(alpha: 0.6)
                        : cs.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: kFontSizeBody,
                    letterSpacing: 0.3,
                    height: 1.1,
                  ),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                      SizedBox(width: 8),
                      // 🔢 תג כמות — לחיץ לעריכה מהירה
                      GestureDetector(
                        onTap: () => _showQuantityEditor(context, theme, cs),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(kBorderRadius),
                            border: Border.all(
                              color: cs.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            '×${item.quantity ?? 1}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onPrimaryContainer,
                              fontSize: kFontSizeMedium,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔢 עריכת כמות מהירה — bottom sheet עם +/−
  void _showQuantityEditor(BuildContext context, ThemeData theme, ColorScheme cs) {
    final cs = Theme.of(context).colorScheme;
    int qty = item.quantity ?? 1;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kBorderRadiusLarge)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSpacingLarge, vertical: kSpacingMedium),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ידית
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                  ),
                  const SizedBox(height: kSpacingMedium),
                  // שם המוצר
                  Text(
                    item.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: kSpacingLarge),
                  // +/- כמות
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // כפתור מינוס
                      IconButton.filled(
                        onPressed: qty > 1
                            ? () {
                                setSheetState(() => qty--);
                              }
                            : null,
                        style: IconButton.styleFrom(
                          backgroundColor: cs.errorContainer,
                          foregroundColor: cs.onErrorContainer,
                          minimumSize: const Size(48, 48),
                        ),
                        icon: Icon(Icons.remove, size: 24),
                      ),
                      // כמות נוכחית
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: kSpacingLarge),
                        child: Text(
                          '$qty',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                      ),
                      // כפתור פלוס
                      IconButton.filled(
                        onPressed: qty < 99
                            ? () {
                                setSheetState(() => qty++);
                              }
                            : null,
                        style: IconButton.styleFrom(
                          backgroundColor: StatusColors.success.withValues(alpha: 0.2),
                          foregroundColor: StatusColors.success,
                          minimumSize: const Size(48, 48),
                        ),
                        icon: const Icon(Icons.add, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: kSpacingLarge),
                  // כפתור אישור
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        onQuantityChanged(qty);
                        Navigator.pop(ctx);
                      },
                      child: const Text('אישור'),
                    ),
                  ),
                  const SizedBox(height: kSpacingSmall),
                ],
              ),
            );
          },
        );
      },
    );
  }
}



/// תוצאת דיאלוג סיכום קנייה
