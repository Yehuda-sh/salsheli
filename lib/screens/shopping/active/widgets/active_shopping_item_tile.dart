// 📄 lib/screens/shopping/active/widgets/active_shopping_item_tile.dart
//
// 🎯 Single item tile for active shopping mode
//    Swipe-to-check, status indicators, haptic feedback
//
// 🔗 Related: active_shopping_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/ui_constants.dart';
import '../../../../theme/app_theme.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../models/enums/shopping_item_status.dart';
import '../../../../models/unified_list_item.dart';
import '../../../../widgets/common/product_thumbnail.dart';

class ActiveShoppingItemTile extends StatelessWidget {
  final UnifiedListItem item;
  final ShoppingItemStatus status;
  final void Function(ShoppingItemStatus) onStatusChanged;
  final void Function(int newQuantity) onQuantityChanged;

  const ActiveShoppingItemTile({
    super.key,
    required this.item,
    required this.status,
    required this.onStatusChanged,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();

    // 🎨 צבע רקע לפי סטטוס
    Color? backgroundColor;
    switch (status) {
      case ShoppingItemStatus.purchased:
        backgroundColor = (brand?.stickyGreen ?? kStickyGreen).withValues(alpha: 0.15);
        break;
      case ShoppingItemStatus.outOfStock:
        backgroundColor = cs.error.withValues(alpha: 0.15);
        break;
      case ShoppingItemStatus.notNeeded:
        backgroundColor = cs.onSurfaceVariant.withValues(alpha: 0.2);
        break;
      default:
        backgroundColor = null;
    }

    return Dismissible(
      key: ValueKey('swipe_${item.id}'),
      confirmDismiss: (direction) async {
        unawaited(HapticFeedback.lightImpact());
        if (direction == DismissDirection.startToEnd) {
          onStatusChanged(status == ShoppingItemStatus.outOfStock
              ? ShoppingItemStatus.pending
              : ShoppingItemStatus.outOfStock);
        } else {
          onStatusChanged(status == ShoppingItemStatus.notNeeded
              ? ShoppingItemStatus.pending
              : ShoppingItemStatus.notNeeded);
        }
        return false;
      },
      background: Container(
        height: kNotebookLineSpacing,
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsetsDirectional.only(start: kSpacingMedium),
        decoration: BoxDecoration(
          color: cs.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.remove_shopping_cart, color: cs.error, size: kIconSizeMedium),
            const SizedBox(width: kSpacingXTiny),
            Text(
              AppStrings.shopping.legendOutOfStock,
              style: TextStyle(color: cs.error, fontSize: kFontSizeSmall, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
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
            const SizedBox(width: kSpacingXTiny),
            Icon(Icons.block, color: cs.onSurfaceVariant, size: kIconSizeMedium),
          ],
        ),
      ),
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
            // ═══════════════════════════════════════
            // 🟢 Zone 1: Status icon + Main body (tap = toggle purchased)
            // ═══════════════════════════════════════
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  unawaited(HapticFeedback.mediumImpact());
                  onStatusChanged(status == ShoppingItemStatus.purchased
                      ? ShoppingItemStatus.pending
                      : ShoppingItemStatus.purchased);
                },
                child: Row(
                  children: [
                    // Status icon
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: kSpacingXTiny),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _statusIcon,
                          key: ValueKey(status),
                          color: _statusColor(cs, brand),
                          size: kIconSizeMediumPlus,
                        ),
                      ),
                    ),
                    const SizedBox(width: kSpacingXTiny),
                    // Product image
                    ProductThumbnail(
                      barcode: item.barcode,
                      category: item.category ?? '',
                      size: kIconSizeLarge,
                    ),
                    const SizedBox(width: kSpacingSmall),
                    // Product name with animated strikethrough
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: theme.textTheme.bodyLarge!.copyWith(
                          decoration: status == ShoppingItemStatus.purchased
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: brand?.stickyGreen ?? kStickyGreen,
                          decorationThickness: 2.0,
                          color: status == ShoppingItemStatus.purchased ||
                                  status == ShoppingItemStatus.notNeeded
                              ? cs.onSurfaceVariant.withValues(alpha: 0.6)
                              : cs.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: kFontSizeBody,
                          letterSpacing: 0.3,
                          height: 1.2,
                        ),
                        child: Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ═══════════════════════════════════════
            // 🔢 Zone 2: Quantity pill (tap = open picker)
            // ═══════════════════════════════════════
            GestureDetector(
              onTap: () {
                unawaited(HapticFeedback.lightImpact());
                _showQuantityEditor(context, theme, cs);
              },
              child: Container(
                width: 48,
                height: 32,
                margin: const EdgeInsets.symmetric(horizontal: kSpacingXTiny),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(kBorderRadius),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
                ),
                alignment: Alignment.center,
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

            // ═══════════════════════════════════════
            // ⋮ Zone 3: Three-dot menu
            // ═══════════════════════════════════════
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              iconSize: kIconSizeMedium,
              icon: Icon(Icons.more_vert, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
              onSelected: (value) {
                unawaited(HapticFeedback.lightImpact());
                switch (value) {
                  case 'outOfStock':
                    onStatusChanged(status == ShoppingItemStatus.outOfStock
                        ? ShoppingItemStatus.pending
                        : ShoppingItemStatus.outOfStock);
                    break;
                  case 'notNeeded':
                    onStatusChanged(status == ShoppingItemStatus.notNeeded
                        ? ShoppingItemStatus.pending
                        : ShoppingItemStatus.notNeeded);
                    break;
                  case 'edit':
                    _showQuantityEditor(context, theme, cs);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'outOfStock',
                  child: Row(
                    children: [
                      Icon(Icons.remove_shopping_cart,
                          color: status == ShoppingItemStatus.outOfStock ? cs.error : cs.onSurface, size: kIconSizeMedium),
                      const SizedBox(width: kSpacingSmall),
                      Text(status == ShoppingItemStatus.outOfStock
                          ? AppStrings.shopping.legendPending
                          : AppStrings.shopping.legendOutOfStock),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'notNeeded',
                  child: Row(
                    children: [
                      Icon(Icons.block,
                          color: status == ShoppingItemStatus.notNeeded ? cs.onSurfaceVariant : cs.onSurface, size: kIconSizeMedium),
                      const SizedBox(width: kSpacingSmall),
                      Text(status == ShoppingItemStatus.notNeeded
                          ? AppStrings.shopping.legendPending
                          : AppStrings.shopping.legendNotNeeded),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: cs.primary, size: kIconSizeMedium),
                      const SizedBox(width: kSpacingSmall),
                      Text(AppStrings.shopping.editQuantity),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // Helpers
  // ═══════════════════════════════════════

  IconData get _statusIcon {
    switch (status) {
      case ShoppingItemStatus.purchased:
        return Icons.check_circle;
      case ShoppingItemStatus.outOfStock:
        return Icons.remove_shopping_cart;
      case ShoppingItemStatus.notNeeded:
        return Icons.block;
      default:
        return Icons.circle_outlined;
    }
  }

  Color _statusColor(ColorScheme cs, AppBrand? brand) {
    switch (status) {
      case ShoppingItemStatus.purchased:
        return brand?.stickyGreen ?? kStickyGreen;
      case ShoppingItemStatus.outOfStock:
        return cs.error;
      case ShoppingItemStatus.notNeeded:
        return cs.onSurfaceVariant;
      default:
        return cs.outline.withValues(alpha: 0.5);
    }
  }

  // ═══════════════════════════════════════
  // Quantity Picker with Quick-Pick Chips
  // ═══════════════════════════════════════

  void _showQuantityEditor(BuildContext context, ThemeData theme, ColorScheme _) {
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();
    int qty = item.quantity ?? 1;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kBorderRadiusLarge)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: kSpacingLarge, vertical: kSpacingMedium),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: kSpacingXLarge + kSpacingSmall,
                      height: kSpacingXTiny,
                      decoration: BoxDecoration(
                        color: cs.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                      ),
                    ),
                    const SizedBox(height: kSpacingMedium),
                    // Product name
                    Text(
                      item.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: kSpacingLarge),

                    // 🏷️ Quick-pick chips
                    Wrap(
                      spacing: kSpacingSmall,
                      children: [1, 2, 4, 6, 12].map((q) {
                        final isSelected = qty == q;
                        return ChoiceChip(
                          label: Text('$q'),
                          selected: isSelected,
                          onSelected: (_) {
                            unawaited(HapticFeedback.lightImpact());
                            setSheetState(() => qty = q);
                          },
                          selectedColor: cs.primaryContainer,
                          labelStyle: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: kSpacingMedium),

                    // +/- buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filled(
                          onPressed: qty > 1
                              ? () {
                                  unawaited(HapticFeedback.lightImpact());
                                  setSheetState(() => qty--);
                                }
                              : null,
                          style: IconButton.styleFrom(
                            backgroundColor: cs.errorContainer,
                            foregroundColor: cs.onErrorContainer,
                            minimumSize: const Size(48, 48),
                          ),
                          icon: const Icon(Icons.remove, size: kIconSizeMedium),
                        ),
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
                        IconButton.filled(
                          onPressed: qty < 99
                              ? () {
                                  unawaited(HapticFeedback.lightImpact());
                                  setSheetState(() => qty++);
                                }
                              : null,
                          style: IconButton.styleFrom(
                            backgroundColor: (brand?.stickyGreen ?? kStickyGreen).withValues(alpha: 0.2),
                            foregroundColor: brand?.stickyGreen ?? kStickyGreen,
                            minimumSize: const Size(48, 48),
                          ),
                          icon: const Icon(Icons.add, size: kIconSizeMedium),
                        ),
                      ],
                    ),
                    const SizedBox(height: kSpacingLarge),

                    // Confirm button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          onQuantityChanged(qty);
                          Navigator.pop(ctx);
                        },
                        child: Text(AppStrings.common.confirm),
                      ),
                    ),
                    const SizedBox(height: kSpacingSmall),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
