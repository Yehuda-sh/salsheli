// 📄 lib/widgets/shopping/shopping_list_urgency.dart
//
// לוגיקת חישוב דחיפות לפי תאריך יעד.
// מופרד מ-ShoppingListTile לקריאות וטסטביליות.
//
// 🔗 Related: ShoppingListTile, ShoppingListTags

import 'package:flutter/material.dart';
import '../../core/status_colors.dart';
import '../../l10n/app_strings.dart';
import '../../models/shopping_list.dart';

/// נתוני דחיפות - סטטוס (type-safe), טקסט ואייקון
typedef UrgencyData = ({StatusType status, String text, IconData icon});

/// חישוב דחיפות רשימת קניות לפי תאריך יעד
///
/// לוגיקה:
/// - null targetDate → null (אין דחיפות)
/// - עבר → אדום "עבר!"
/// - היום → אדום "היום!"
/// - מחר → כתום "מחר"
/// - 2-7 ימים → כתום "עוד X ימים"
/// - 7+ ימים → ירוק "עוד X ימים"
class ShoppingListUrgency {
  ShoppingListUrgency._();

  /// מחשב דחיפות מ-ShoppingList
  ///
  /// Returns null אם אין targetDate
  static UrgencyData? fromList(ShoppingList list) {
    if (list.targetDate == null) return null;

    // נרמול לתאריכים בלבד (ללא שעות) למניעת באגים
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = list.targetDate!;
    final targetDay = DateTime(target.year, target.month, target.day);

    // אם התאריך עבר (לפני היום)
    if (targetDay.isBefore(today)) {
      return (
        status: StatusType.error,
        text: AppStrings.shopping.urgencyPassed,
        icon: Icons.warning,
      );
    }

    final daysLeft = targetDay.difference(today).inDays;

    if (daysLeft == 0) {
      return (
        status: StatusType.error,
        text: AppStrings.shopping.urgencyToday,
        icon: Icons.access_time,
      );
    } else if (daysLeft == 1) {
      return (
        status: StatusType.warning,
        text: AppStrings.shopping.urgencyTomorrow,
        icon: Icons.access_time,
      );
    } else if (daysLeft <= 7) {
      return (
        status: StatusType.warning,
        text: AppStrings.shopping.urgencyDaysLeft(daysLeft),
        icon: Icons.access_time,
      );
    } else {
      return (
        status: StatusType.success,
        text: AppStrings.shopping.urgencyDaysLeft(daysLeft),
        icon: Icons.check_circle_outline,
      );
    }
  }
}
