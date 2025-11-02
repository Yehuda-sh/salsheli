// 📄 File: lib/widgets/shopping_list_tile.dart
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
import '../../core/status_colors.dart';
import '../../core/ui_constants.dart';
import '../../models/shopping_list.dart';

class ShoppingListTile extends StatelessWidget {
  final ShoppingList list;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Function(ShoppingList)? onRestore;
  final VoidCallback? onStartShopping;

  const ShoppingListTile({
    super.key,
    required this.list,
    this.onTap,
    this.onDelete,
    this.onRestore,
    this.onStartShopping,
  });

  /// 🎨 אייקון לפי סוג הרשימה
  /// מחזיר אייקון ייחודי לכל סוג רשימה
  Widget _getListIcon(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (list.type) {
      case ShoppingList.typeSupermarket:
        iconData = Icons.shopping_cart;
        iconColor = kStickyGreen;
        break;
      case ShoppingList.typePharmacy:
        iconData = Icons.medication;
        iconColor = kStickyCyan;
        break;
      case ShoppingList.typeGreengrocer:
        iconData = Icons.local_florist;
        iconColor = kStickyGreen;
        break;
      case ShoppingList.typeButcher:
        iconData = Icons.set_meal;
        iconColor = kStickyPink;
        break;
      case ShoppingList.typeBakery:
        iconData = Icons.bakery_dining;
        iconColor = kStickyYellow;
        break;
      case ShoppingList.typeMarket:
        iconData = Icons.store;
        iconColor = kStickyYellow;
        break;
      case ShoppingList.typeHousehold:
        iconData = Icons.home;
        iconColor = kStickyPurple;
        break;
      case ShoppingList.typeOther:
      default:
        iconData = Icons.shopping_bag;
        iconColor = kStickyPurple;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(kSpacingSmall),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: kIconSizeMedium),
    );
  }

  /// 🇮🇱 אייקון מותאם לפי סטטוס הרשימה (לא בשימוש - הוחלף ב-_getListIcon)
  /// 🇬🇧 Status-based icon with tooltip for accessibility
  ///
  /// תומך ב-3 סטטוסים:
  /// - statusCompleted: ✓ ירוק
  /// - statusArchived: 📦 אפור
  /// - statusActive (default): 🛒 כחול
  ///
  /// כל icon כולל Tooltip בעברית לנגישות
  ///
  /// Returns: Icon widget עם Tooltip
  Widget _statusIcon(BuildContext context) {
    final IconData iconData;
    final String status;
    final String tooltip;

    switch (list.status) {
      case ShoppingList.statusCompleted:
        iconData = Icons.check_circle;
        status = 'success';
        tooltip = 'רשימה הושלמה';
        break;
      case ShoppingList.statusArchived:
        iconData = Icons.archive;
        status = 'pending';
        tooltip = 'רשימה בארכיון';
        break;
      default:
        iconData = Icons.shopping_cart;
        status = 'info';
        tooltip = 'רשימה פעילה';
    }

    return Tooltip(
      message: tooltip,
      child: Icon(iconData, color: StatusColors.getStatusColor(status, context)),
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
  /// Returns: Map עם 'color', 'text', 'icon' או null
  Map<String, dynamic>? _getUrgencyData() {
    if (list.targetDate == null) return null;

    final now = DateTime.now();
    final target = list.targetDate!;

    // אם התאריך עבר
    if (target.isBefore(now)) {
      return {'status': 'error', 'text': 'עבר!', 'icon': Icons.warning};
    }

    final daysLeft = target.difference(now).inDays;

    if (daysLeft == 0) {
      // היום!
      return {'status': 'error', 'text': 'היום!', 'icon': Icons.access_time};
    } else if (daysLeft <= 1) {
      // מחר
      return {'status': 'warning', 'text': 'מחר', 'icon': Icons.access_time};
    } else if (daysLeft <= 7) {
      // בקרוב (1-7 ימים)
      return {'status': 'warning', 'text': 'עוד $daysLeft ימים', 'icon': Icons.access_time};
    } else {
      // יש זמן (7+ ימים)
      return {'status': 'success', 'text': 'עוד $daysLeft ימים', 'icon': Icons.check_circle_outline};
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
        typeLabel = 'סופרמרקט';
        typeColor = kStickyGreen;
        break;
      case ShoppingList.typePharmacy:
        typeEmoji = '💊';
        typeLabel = 'בית מרקחת';
        typeColor = kStickyCyan;
        break;
      case ShoppingList.typeGreengrocer:
        typeEmoji = '🥬';
        typeLabel = 'ירקן';
        typeColor = kStickyGreen;
        break;
      case ShoppingList.typeButcher:
        typeEmoji = '🥩';
        typeLabel = 'אטליז';
        typeColor = kStickyPink;
        break;
      case ShoppingList.typeBakery:
        typeEmoji = '🍞';
        typeLabel = 'מאפייה';
        typeColor = kStickyYellow;
        break;
      case ShoppingList.typeMarket:
        typeEmoji = '🧺';
        typeLabel = 'שוק';
        typeColor = kStickyYellow;
        break;
      case ShoppingList.typeHousehold:
        typeEmoji = '🏠';
        typeLabel = 'כלי בית';
        typeColor = kStickyPurple;
        break;
      case ShoppingList.typeOther:
      default:
        typeEmoji = '📦';
        typeLabel = 'אחר';
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
    final status = urgencyData['status'] as String;
    final statusColor = StatusColors.getStatusColor(status, context);
    final overlayColor = StatusColors.getStatusOverlay(status, context);

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
          Icon(urgencyData['icon'] as IconData, size: kIconSizeSmall, color: statusColor),
          const SizedBox(width: kSpacingTiny),
          Text(
            urgencyData['text'] as String,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatted = DateFormat('dd/MM/yyyy – HH:mm').format(list.updatedDate);

    return Dismissible(
      key: Key(list.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.symmetric(horizontal: kButtonPaddingHorizontal),
        color: Colors.redAccent,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        debugPrint('🗑️ ShoppingListTile.confirmDismiss: מוחק רשימה "${list.name}" (${list.id})');
        debugPrint('   📊 סטטוס: ${list.status} | פריטים: ${list.items.length}');

        try {
          // ✅ שמירת כל הנתונים לפני מחיקה
          final deletedList = list;

          // ✅ מחיקה מיידית
          onDelete?.call();
          debugPrint('   ✅ onDelete() הופעל');

          // ✅ הצגת Snackbar עם אפשרות Undo
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('הרשימה "${deletedList.name}" נמחקה'),
              backgroundColor: StatusColors.getStatusColor('success', context),
              action: SnackBarAction(
                label: 'בטל',
                onPressed: () {
                  debugPrint('🔄 ShoppingListTile: Undo - משחזר רשימה "${deletedList.name}"');
                  try {
                    // ✅ שחזור הרשימה
                    onRestore?.call(deletedList);
                    debugPrint('   ✅ רשימה שוחזרה בהצלחה');
                  } catch (e) {
                    debugPrint('   ❌ שגיאה בשחזור: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('שגיאה בשחזור הרשימה'),
                        backgroundColor: StatusColors.getStatusColor('error', context),
                      ),
                    );
                  }
                },
              ),
              duration: const Duration(seconds: 5),
            ),
          );

          // ✅ מאשר מחיקה מיידית (כבר מחקנו)
          return true;
        } catch (e) {
          debugPrint('❌ ShoppingListTile.confirmDismiss: שגיאה במחיקה - $e');

          // הצג הודעת שגיאה
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('שגיאה במחיקת הרשימה'),
              backgroundColor: StatusColors.getStatusColor('error', context),
            ),
          );

          // ביטול מחיקה
          return false;
        }
      },
      child: Material(
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
                      if (_buildUrgencyTag(context) != null) ...[
                        _buildUrgencyTag(context)!,
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
                                'משותפת',
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
                      Text('פריטים: ${list.items.length} • עודכן: $dateFormatted', style: theme.textTheme.bodySmall),
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
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),

              // ⭐ כפתור "התחל קנייה" - רק לרשימות פעילות עם מוצרים
              if (list.status == ShoppingList.statusActive && list.items.isNotEmpty)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2))),
                  ),
                  child: InkWell(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(kBorderRadius)),
                    onTap: onStartShopping,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmallPlus),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_checkout, color: theme.colorScheme.primary, size: kIconSizeMedium),
                          const SizedBox(width: kSpacingSmall),
                          Text(
                            'התחל קנייה',
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
                )
              // 📝 כפתור להוספת מוצרים - רשימה ריקה
              else if (list.status == ShoppingList.statusActive && list.items.isEmpty)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2))),
                  ),
                  child: InkWell(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(kBorderRadius)),
                    onTap: () {
                      debugPrint('➕ ShoppingListTile: כפתור "הוסף מוצרים" נלחץ - רשימה: ${list.name}');
                      onTap?.call();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(kSpacingSmallPlus),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline, size: kIconSizeMedium, color: theme.colorScheme.primary),
                          const SizedBox(width: kSpacingSmall),
                          Text(
                            'הוסף מוצרים כדי להתחיל',
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
            ],
          ),
        ),
      ),
    );
  }
}
