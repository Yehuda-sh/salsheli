// 📄 lib/widgets/shopping/shopping_list_urgency.dart
//
// לוגיקת חישוב דחיפות + משקולת מיון (sortWeight) לפי תאריך יעד.
// מופרד מ-ShoppingListTile לקריאות וטסטביליות.
//
// Sort Weights:
//   0 — ללא תאריך יעד
//   1 — עתיד רחוק (7+ ימים)
//   2 — בקרוב (2-7 ימים)
//   3 — מחר
//   4 — היום
//   5 — עבר (Overdue)
//
// 🔗 Related: ShoppingListTile, ShoppingListTags, ShoppingListsProvider

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

  /// משקולת מיון (Sort Weight) לפי דחיפות — תמיד מחזיר int (ללא null)
  ///
  /// מיועד ל-ShoppingListsProvider כדי למיין רשימות ללא חישוב תאריכים חוזר.
  /// רשימות ללא תאריך יעד מקבלות משקל 0 ויורדות לתחתית.
  ///
  /// שימוש ב-Provider:
  /// ```dart
  /// lists.sort((a, b) =>
  ///   ShoppingListUrgency.sortWeight(b).compareTo(ShoppingListUrgency.sortWeight(a)));
  /// ```
  static int sortWeight(ShoppingList list) {
    if (list.targetDate == null) return 0;

    // נרמול לתאריכים בלבד — אותו נרמול כמו ב-fromList למניעת divergence
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = list.targetDate!;
    final targetDay = DateTime(target.year, target.month, target.day);

    if (targetDay.isBefore(today)) return 5; // Overdue
    final daysLeft = targetDay.difference(today).inDays;

    if (daysLeft == 0) return 4; // היום
    if (daysLeft == 1) return 3; // מחר
    if (daysLeft <= 7) return 2; // בקרוב
    return 1; // עתיד רחוק
  }
}
