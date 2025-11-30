// 📄 File: lib/widgets/shopping/shopping_list_tile.dart
//
// 🇮🇱 ווידג'ט להצגת רשימת קניות:
//     - מציג שם רשימה, מספר פריטים, תאריך עדכון.
//     - תומך במחיקה ב-Swipe (כולל Undo).
//     - מציג אייקון מותאם לפי סטטוס הרשימה.
//     - מציג פס התקדמות (כמה פריטים כבר נקנו).
//     - תומך בלחיצה כדי לפתוח את הרשימה.
//     - כפתור "התחל קנייה" לרשימות פעילות.
//
// 🇬🇧 Widget for displaying a shopping list:
//     - Shows list name, item count, last update date.
//     - Supports swipe-to-delete with Undo action.
//     - Displays icon based on list status.
//     - Shows progress bar (checked vs total items).
//     - Supports tap to navigate into the list.
//     - "Start Shopping" button for active lists.
//
// 📖 Usage:
// ```dart
// ShoppingListTile(
//   list: myShoppingList,
//   onTap: () => Navigator.push(...),
//   onDelete: () => provider.deleteList(list.id),
//   onRestore: (list) => provider.restoreList(list),
//   onStartShopping: () => Navigator.push(...),
// )
// ```

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
  final VoidCallback? onDelete;
  final Function(ShoppingList)? onRestore;
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

  /// 🎨 אייקון לפי סוג הרשימה
  /// מחזיר אייקון ייחודי לכל סוג רשימה
  Widget _getListIcon(BuildContext context) {
    // ✅ שימוש ב-getters מהמודל (במקום switch case)
    final iconData = list.typeIcon;
    final iconColor = list.stickyColor;

    return Container(
      padding: const EdgeInsets.all(kSpacingSmall),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: kIconSizeMedium),
    );
  }



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

    final now = DateTime.now();
    final target = list.targetDate!;

    // אם התאריך עבר
    if (target.isBefore(now)) {
      return (status: 'error', text: AppStrings.shopping.urgencyPassed, icon: Icons.warning);
    }

    final daysLeft = target.difference(now).inDays;

    if (daysLeft == 0) {
      // היום!
      return (status: 'error', text: AppStrings.shopping.urgencyToday, icon: Icons.access_time);
    } else if (daysLeft <= 1) {
      // מחר
      return (status: 'warning', text: AppStrings.shopping.urgencyTomorrow, icon: Icons.access_time);
    } else if (daysLeft <= 7) {
      // בקרוב (1-7 ימים)
      return (status: 'warning', text: AppStrings.shopping.urgencyDaysLeft(daysLeft), icon: Icons.access_time);
    } else {
      // יש זמן (7+ ימים)
      return (status: 'success', text: AppStrings.shopping.urgencyDaysLeft(daysLeft), icon: Icons.check_circle_outline);
    }
  }

  /// 🏷️ ווידג׳ט תג סוג רשימה
  /// 🇬🇧 List type tag widget
  ///
  /// מציג תג עם סוג הרשימה - תומך בכל 8 הסוגים החדשים
  Widget _buildListTypeTag(BuildContext context) {
    final String typeLabel;
    final Color typeColor;
    final String typeEmoji;

    switch (list.type) {
      case ShoppingList.typeSupermarket:
        typeEmoji = '🛒';
        typeLabel = AppStrings.shopping.typeSupermarket;
        typeColor = kStickyGreen;
        break;
      case ShoppingList.typePharmacy:
        typeEmoji = '💊';
        typeLabel = AppStrings.shopping.typePharmacy;
        typeColor = kStickyCyan;
        break;
      case ShoppingList.typeGreengrocer:
        typeEmoji = '🥬';
        typeLabel = AppStrings.shopping.typeGreengrocer;
        typeColor = kStickyGreen;
        break;
      case ShoppingList.typeButcher:
        typeEmoji = '🥩';
        typeLabel = AppStrings.shopping.typeButcher;
        typeColor = kStickyPink;
        break;
      case ShoppingList.typeBakery:
        typeEmoji = '🍞';
        typeLabel = AppStrings.shopping.typeBakery;
        typeColor = kStickyYellow;
        break;
      case ShoppingList.typeMarket:
        typeEmoji = '🧺';
        typeLabel = AppStrings.shopping.typeMarket;
        typeColor = kStickyYellow;
        break;
      case ShoppingList.typeHousehold:
        typeEmoji = '🏠';
        typeLabel = AppStrings.shopping.typeHousehold;
        typeColor = kStickyPurple;
        break;
      case ShoppingList.typeOther:
      default:
        typeEmoji = '📦';
        typeLabel = AppStrings.shopping.typeOther;
        typeColor = kStickyPurple;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: 4),
      decoration: BoxDecoration(
        color: typeColor,
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(typeEmoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            typeLabel,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
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
            onPressed: () {
              Navigator.pop(dialogContext);

              debugPrint('🗑️ ShoppingListTile: מוחק רשימה "${list.name}" (${list.id})');

              try {
                final deletedList = list;
                onDelete?.call();

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

    return Material(
        elevation: kCardElevation,
        borderRadius: BorderRadius.circular(kBorderRadius),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kBorderRadius),
            border: BorderDirectional(
              start: BorderSide(
                color: list.status == ShoppingList.statusCompleted
                    ? StatusColors.getStatusColor('success', context)
                    : list.status == ShoppingList.statusArchived
                    ? StatusColors.getStatusColor('pending', context)
                    : theme.colorScheme.primary,
                width: kBorderWidthExtraThick,
              ),
            ),
          ),
          child: Column(
            children: [
              InkWell(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(kBorderRadius)),
                onTap: onTap,
                child: ListTile(
                  leading: _getListIcon(context),
                  contentPadding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmallPlus),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          list.name,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      // תג סוג רשימה
                      _buildListTypeTag(context),
                      const SizedBox(width: kSpacingSmall),
                      // תג דחיפות
                      if (_buildUrgencyTag(context) case final urgencyTag?) ...[
                        urgencyTag,
                        const SizedBox(width: kSpacingSmall),
                      ],
                      // תג משותפת
                      if (list.isShared)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingTiny),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                          ),
                          child: Row(
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
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.shopping.itemsAndDate(list.items.length, dateFormatted), style: theme.textTheme.bodySmall),
                      const SizedBox(height: kSpacingTiny),
                      if (list.items.isNotEmpty)
                        LinearProgressIndicator(
                          value: list.items.isEmpty
                              ? 0.0
                              : list.items.where((item) => item.isChecked).length / list.items.length,
                          minHeight: kSpacingTiny,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          color: theme.colorScheme.primary,
                        ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
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

              // ⭐ כפתור "התחל קנייה" - רק לרשימות פעילות עם מוצרים
              if (list.status == ShoppingList.statusActive && list.items.isNotEmpty)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2))),
                  ),
                  child: SimpleTappableCard(
                    onTap: onStartShopping,
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(kBorderRadius)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmallPlus),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_checkout, color: theme.colorScheme.primary, size: kIconSizeMedium),
                            const SizedBox(width: kSpacingSmall),
                            Text(
                              AppStrings.shopping.startShoppingButton,
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
                )
              // 📝 כפתור להוספת מוצרים - רשימה ריקה
              else if (list.status == ShoppingList.statusActive && list.items.isEmpty)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2))),
                  ),
                  child: SimpleTappableCard(
                    onTap: () {
                      debugPrint('➕ ShoppingListTile: כפתור "הוסף מוצרים" נלחץ - רשימה: ${list.name}');
                      onTap?.call();
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(kBorderRadius)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(kSpacingSmallPlus),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline, size: kIconSizeMedium, color: theme.colorScheme.primary),
                            const SizedBox(width: kSpacingSmall),
                            Text(
                              AppStrings.shopping.addProductsToStart,
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
                ),
            ],
          ),
        ),
    );
  }
}
