// 📄 lib/widgets/shopping/shopping_list_tile.dart
//
// ווידג'ט להצגת רשימת קניות - שם, פריטים, התקדמות ותאריך.
// כולל כפתור "התחל קנייה" ותפריט פעולות (עריכה, מחיקה).
//
// 🔗 Related: ShoppingList, ShoppingListsScreen, TappableCard

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memozap/l10n/app_strings.dart';
import 'package:memozap/widgets/common/tappable_card.dart';
import '../../core/status_colors.dart';
import '../../core/ui_constants.dart';
import '../../models/shopping_list.dart';

class ShoppingListTile extends StatelessWidget {
  final ShoppingList list;
  final VoidCallback? onTap;
  final Future<void> Function()? onDelete;
  final Future<void> Function(ShoppingList list)? onRestore;
  final VoidCallback? onStartShopping;
  final VoidCallback? onEdit;

  const ShoppingListTile({
    super.key,
    required this.list,
    this.onTap,
    this.onDelete,
    this.onRestore,
    this.onStartShopping,
    this.onEdit,
  });

  /// 🇮🇱 חישוב דחיפות לפי תאריך יעד
  /// 🇬🇧 Calculate urgency based on target date
  ///
  /// לוגיקה:
  /// - null targetDate: מחזיר null (אין דחיפות)
  /// - targetDate בעבר: אדום "עבר!"
  /// - targetDate היום: אדום "היום!"
  /// - targetDate מחר: כתום "מחר"
  /// - targetDate 1-7 ימים: כתום "עוד X ימים"
  /// - targetDate 7+ ימים: ירוק "עוד X ימים"
  ///
  /// Returns: Record עם status, text, icon או null
  ({String status, String text, IconData icon})? _getUrgencyData() {
    if (list.targetDate == null) return null;

    // נרמול לתאריכים בלבד (ללא שעות) למניעת באגים
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = list.targetDate!;
    final targetDay = DateTime(target.year, target.month, target.day);

    // אם התאריך עבר (לפני היום)
    if (targetDay.isBefore(today)) {
      return (status: 'error', text: AppStrings.shopping.urgencyPassed, icon: Icons.warning);
    }

    final daysLeft = targetDay.difference(today).inDays;

    if (daysLeft == 0) {
      // היום!
      return (status: 'error', text: AppStrings.shopping.urgencyToday, icon: Icons.access_time);
    } else if (daysLeft == 1) {
      // מחר
      return (status: 'warning', text: AppStrings.shopping.urgencyTomorrow, icon: Icons.access_time);
    } else if (daysLeft <= 7) {
      // בקרוב (2-7 ימים)
      return (status: 'warning', text: AppStrings.shopping.urgencyDaysLeft(daysLeft), icon: Icons.access_time);
    } else {
      // יש זמן (7+ ימים)
      return (status: 'success', text: AppStrings.shopping.urgencyDaysLeft(daysLeft), icon: Icons.check_circle_outline);
    }
  }

  /// 🏷️ ווידג׳ט תג סוג רשימה
  /// 🇬🇧 List type tag widget
  ///
  /// מציג תג עם סוג הרשימה - משתמש ב-getters מהמודל
  Widget _buildListTypeTag(BuildContext context) {
    final theme = Theme.of(context);
    // שימוש ב-getters מהמודל
    final typeEmoji = list.typeEmoji;
    final typeColor = list.stickyColor;
    final typeLabel = list.typeName;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: 4),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        border: Border.all(
          color: typeColor.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(typeEmoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            typeLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔘 כפתור פעולה בתחתית הכרטיס
  /// "התחל קנייה" אם יש מוצרים, "הוסף מוצרים" אם ריק
  Widget _buildBottomActionButton(BuildContext context, ThemeData theme) {
    final hasItems = list.items.isNotEmpty;
    final icon = hasItems ? Icons.shopping_cart_checkout : Icons.add_circle_outline;
    final label = hasItems
        ? AppStrings.shopping.startShoppingButton
        : AppStrings.shopping.addProductsToStart;
    final onPressed = hasItems ? onStartShopping : onTap;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2))),
      ),
      child: SimpleTappableCard(
        onTap: onPressed,
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(kBorderRadius)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmallPlus),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: kIconSizeMedium),
                const SizedBox(width: kSpacingSmall),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: kFontSizeBody,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🏷️ תג "משותפת"
  Widget _buildSharedTag(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingTiny),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group, size: kIconSizeSmall, color: theme.colorScheme.onSecondaryContainer),
          const SizedBox(width: kSpacingTiny),
          Text(
            AppStrings.shopping.sharedLabel,
            style: TextStyle(
              color: theme.colorScheme.onSecondaryContainer,
              fontSize: kFontSizeTiny,
            ),
          ),
        ],
      ),
    );
  }

  /// 🇮🇱 ווידג׳ט תג דחיפות
  /// 🇬🇧 Urgency tag widget
  ///
  /// תצוגה:
  /// - Container עם border + background צבע
  /// - Icon מהקוד (warning, access_time וכו')
  /// - טקסט דחיפות ("היום!", "עוד 3 ימים" וכו')
  /// - Typography: bodySmall, bold, kFontSizeTiny
  ///
  /// Returns: Widget או null אם אין targetDate
  Widget? _buildUrgencyTag(BuildContext context) {
    final urgencyData = _getUrgencyData();
    if (urgencyData == null) return null;

    final theme = Theme.of(context);
    final statusColor = StatusColors.getStatusColor(urgencyData.status, context);
    final overlayColor = StatusColors.getStatusOverlay(urgencyData.status, context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingTiny),
      decoration: BoxDecoration(
        color: overlayColor,
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(urgencyData.icon, size: kIconSizeSmall, color: statusColor),
          const SizedBox(width: kSpacingTiny),
          Text(
            urgencyData.text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: kFontSizeTiny,
            ),
          ),
        ],
      ),
    );
  }

  /// 🗑️ הצגת דיאלוג אישור מחיקה
  void _showDeleteConfirmation(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    final successColor = StatusColors.getStatusColor('success', context);
    final errorColor = StatusColors.getStatusColor('error', context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.shopping.deleteListTitle),
        content: Text(AppStrings.shopping.deleteListMessage(list.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppStrings.common.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              // שומרים את הרשימה לפני המחיקה לצורך Undo
              final deletedList = list;
              debugPrint('🗑️ ShoppingListTile: מוחק רשימה "${deletedList.name}" (${deletedList.id})');

              try {
                await onDelete?.call();

                messenger.showSnackBar(
                  SnackBar(
                    content: Text(AppStrings.shopping.listDeleted(deletedList.name)),
                    backgroundColor: successColor,
                    action: SnackBarAction(
                      label: AppStrings.shopping.undoButton,
                      onPressed: () {
                        debugPrint('🔄 ShoppingListTile: Undo - משחזר רשימה "${deletedList.name}"');
                        onRestore?.call(deletedList);
                      },
                    ),
                    duration: const Duration(seconds: 5),
                  ),
                );
              } catch (e) {
                debugPrint('❌ שגיאה במחיקה: $e');
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(AppStrings.shopping.deleteError),
                    backgroundColor: errorColor,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppStrings.shopping.deleteButton),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatted = DateFormat('dd/MM/yyyy – HH:mm').format(list.updatedDate);
    final checkedCount = list.items.where((item) => item.isChecked).length;
    final totalCount = list.items.length;

    return Semantics(
      label: '${list.name}, ${totalCount} פריטים, ${checkedCount} סומנו',
      button: true,
      child: Material(
        elevation: 1, // צל עדין יותר
        borderRadius: BorderRadius.circular(kBorderRadius),
        // 🎨 רקע צהבהב חם - כמו נייר ממו
        color: kStickyYellow.withValues(alpha: 0.4),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kBorderRadius),
            // גבול עדין בצבע הסוג
            border: Border.all(
              color: list.stickyColor.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              InkWell(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(kBorderRadius)),
                onTap: onTap,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmallPlus),
                  title: Text(
                    list.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: kSpacingTiny),
                      // תגים בשורה נפרדת עם Wrap למסכים קטנים
                      Wrap(
                        spacing: kSpacingSmall,
                        runSpacing: kSpacingTiny,
                        children: [
                          _buildListTypeTag(context),
                          if (_buildUrgencyTag(context) case final urgencyTag?)
                            urgencyTag,
                          if (list.isShared)
                            _buildSharedTag(context),
                        ],
                      ),
                      const SizedBox(height: kSpacingSmall),
                      Text(AppStrings.shopping.itemsAndDate(list.items.length, dateFormatted), style: theme.textTheme.bodySmall),
                      const SizedBox(height: kSpacingTiny),
                      if (list.items.isNotEmpty)
                        LinearProgressIndicator(
                          value: list.items.where((item) => item.isChecked).length / list.items.length,
                          minHeight: kSpacingTiny,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          color: theme.colorScheme.primary,
                        ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    tooltip: 'אפשרויות נוספות',
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'delete':
                          _showDeleteConfirmation(context);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 20),
                            const SizedBox(width: 8),
                            Text(AppStrings.shopping.editListButton),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, size: 20, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(AppStrings.shopping.deleteListButton, style: const TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ⭐ כפתור פעולה - רק לרשימות פעילות
              if (list.status == ShoppingList.statusActive)
                _buildBottomActionButton(context, theme),
            ],
          ),
        ),
      ),
    );
  }
}
