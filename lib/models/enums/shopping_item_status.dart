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
// Version: 1.3 - Removed UI properties (label/icon/color)
// Last Updated: 29/12/2025

/// מצבי פריט בקנייה פעילה
enum ShoppingItemStatus {
  /// ⬜ ממתין - עדיין לא נקנה
  pending,

  /// ✅ נקנה - הוכנס לעגלה הפיזית
  purchased,

  /// ❌ לא במלאי - לא היה בחנות
  outOfStock,

  /// ⏭️ דחוי - החלטתי לא לקנות עכשיו
  deferred,

  /// 🚫 לא צריך - החלטתי שלא צריך בכלל
  notNeeded;

  // Note: label, icon and color were removed - use AppStrings/StatusColors
  // in UI layer if localized status names or visual properties are needed.

  /// האם הפריט הושלם (נקנה/דחוי/לא במלאי/לא צריך)
  bool get isCompleted =>
      this == ShoppingItemStatus.purchased ||
      this == ShoppingItemStatus.outOfStock ||
      this == ShoppingItemStatus.deferred ||
      this == ShoppingItemStatus.notNeeded;
}
