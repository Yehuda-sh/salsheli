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
import '../models/shopping_list.dart';

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

  /// 🇮🇱 אייקון מותאם לפי סטטוס הרשימה
  /// 🇬🇧 Status-based icon with tooltip for accessibility
  Widget _statusIcon() {
    final IconData iconData;
    final Color color;
    final String tooltip;

    switch (list.status) {
      case ShoppingList.statusCompleted:
        iconData = Icons.check_circle;
        color = Colors.green;
        tooltip = 'רשימה הושלמה';
        break;
      case ShoppingList.statusArchived:
        iconData = Icons.archive;
        color = Colors.grey;
        tooltip = 'רשימה בארכיון';
        break;
      default:
        iconData = Icons.shopping_cart;
        color = Colors.blue;
        tooltip = 'רשימה פעילה';
    }

    return Tooltip(
      message: tooltip,
      child: Icon(iconData, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatted = DateFormat(
      'dd/MM/yyyy – HH:mm',
    ).format(list.updatedDate);

    return Dismissible(
      key: Key(list.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.redAccent,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        // ✅ שמירת כל הנתונים לפני מחיקה
        final deletedList = list;
        
        // ✅ מחיקה מיידית
        onDelete?.call();
        
        // ✅ הצגת Snackbar עם אפשרות Undo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('הרשימה "${deletedList.name}" נמחקה'),
            action: SnackBarAction(
              label: 'בטל',
              onPressed: () {
                // ✅ שחזור הרשימה
                onRestore?.call(deletedList);
              },
            ),
            duration: const Duration(seconds: 5),
          ),
        );
        
        // ✅ מאשר מחיקה מיידית (כבר מחקנו)
        return true;
      },
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            InkWell(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              onTap: onTap,
              child: ListTile(
                leading: _statusIcon(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        list.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (list.isShared)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.group,
                              size: 16,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'משותפת',
                              style: TextStyle(
                                color: theme.colorScheme.onSecondaryContainer,
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
                    Text(
                      'פריטים: ${list.items.length} • עודכן: $dateFormatted',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    if (list.items.isNotEmpty)
                      LinearProgressIndicator(
                        value: list.items.isEmpty 
                            ? 0.0 
                            : list.items.where((item) => item.isChecked).length / list.items.length,
                        minHeight: 4,
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
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: InkWell(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                  onTap: onStartShopping,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_checkout,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'התחל קנייה',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            // 📝 הודעה אם הרשימה ריקה
            else if (list.status == ShoppingList.statusActive && list.items.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'הוסף מוצרים כדי להתחיל',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
