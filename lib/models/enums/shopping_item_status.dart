// 📄 File: lib/models/enums/shopping_item_status.dart
//
// 🎯 Purpose: מצבי פריט בקנייה פעילה
//
// 🇮🇱 תיאור:
// Enum המגדיר את כל המצבים האפשריים של פריט במהלך קנייה פעילה.
// משמש במסך ActiveShoppingScreen לסימון מצב כל מוצר.
//
// 📊 מצבים:
// - pending (⬜) - ממתין לקנייה
// - purchased (✅) - נקנה והוכנס לעגלה
// - outOfStock (❌) - לא היה במלאי בחנות
// - deferred (⏭️) - החלטתי לדחות לפעם הבאה
// - notNeeded (🚫) - החלטתי שלא צריך בכלל
//
// Version: 1.4 - Added JsonEnum for safe serialization
// Last Updated: 04/01/2026

import 'package:json_annotation/json_annotation.dart';

/// מצבי פריט בקנייה פעילה
@JsonEnum(valueField: 'value')
enum ShoppingItemStatus {
  /// ⬜ ממתין - עדיין לא נקנה
  pending('pending'),

  /// ✅ נקנה - הוכנס לעגלה הפיזית
  purchased('purchased'),

  /// ❌ לא במלאי - לא היה בחנות
  outOfStock('outOfStock'),

  /// ⏭️ דחוי - החלטתי לא לקנות עכשיו
  deferred('deferred'),

  /// 🚫 לא צריך - החלטתי שלא צריך בכלל
  notNeeded('notNeeded');

  const ShoppingItemStatus(this.value);
  final String value;

  // Note: label, icon and color were removed - use AppStrings/StatusColors
  // in UI layer if localized status names or visual properties are needed.

  /// האם הפריט הושלם (נקנה/דחוי/לא במלאי/לא צריך)
  bool get isCompleted =>
      this == ShoppingItemStatus.purchased ||
      this == ShoppingItemStatus.outOfStock ||
      this == ShoppingItemStatus.deferred ||
      this == ShoppingItemStatus.notNeeded;
}
