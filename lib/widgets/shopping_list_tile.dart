// 📄 File: lib/widgets/shopping_list_tile.dart
//
// 🇮🇱 ווידג'ט להצגת רשימת קניות:
//     - מציג שם רשימה, מספר פריטים, תאריך עדכון.
//     - תומך במחיקה ב-Swipe (כולל Undo).
//     - מציג אייקון מותאם לפי סטטוס הרשימה.
//     - מציג פס התקדמות (כמה פריטים כבר נקנו).
//     - תומך בלחיצה כדי לפתוח את הרשימה.
//
// 🇬🇧 Widget for displaying a shopping list:
//     - Shows list name, item count, last update date.
//     - Supports swipe-to-delete with Undo action.
//     - Displays icon based on list status.
//     - Shows progress bar (checked vs total items).
//     - Supports tap to navigate into the list.
//

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/shopping_list.dart';

class ShoppingListTile extends StatelessWidget {
  final ShoppingList list;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ShoppingListTile({
    super.key,
    required this.list,
    this.onTap,
    this.onDelete,
  });

  /// 🇮🇱 אייקון מותאם לפי סטטוס הרשימה
  /// 🇬🇧 Status-based icon
  Icon _statusIcon() {
    switch (list.status) {
      case ShoppingList.statusCompleted:
        return const Icon(Icons.check_circle, color: Colors.green);
      case ShoppingList.statusArchived:
        return const Icon(Icons.archive, color: Colors.grey);
      default:
        return const Icon(Icons.shopping_cart, color: Colors.blue);
    }
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
        // מבקש אישור מחיקה עם Undo
        final scaffold = ScaffoldMessenger.of(context);
        bool confirm = false;

        final snackBar = SnackBar(
          content: Text('הרשימה "${list.name}" נמחקה'),
          action: SnackBarAction(
            label: 'בטל',
            onPressed: () {
              confirm = false;
            },
          ),
          duration: const Duration(seconds: 3),
        );

        onDelete?.call();
        scaffold.showSnackBar(snackBar);

        await Future.delayed(const Duration(seconds: 3));
        return confirm;
      },
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
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
                  'פריטים: ${list.itemCount} • עודכן: $dateFormatted',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                if (list.itemCount > 0)
                  LinearProgressIndicator(
                    value: list.progress,
                    minHeight: 4,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }
}
