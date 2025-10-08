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
//
// 🎨 כל מצב כולל:
// - label - טקסט בעברית
// - icon - אייקון ויזואלי
// - color - צבע מותאם
//
// Usage Example:
// ```dart
// ShoppingItemStatus status = ShoppingItemStatus.purchased;
// Text(status.label); // "נקנה"
// Icon(status.icon, color: status.color);
// ```
//
// Version: 1.1 - Dart 3 pattern matching
// Last Updated: 09/10/2025

import 'package:flutter/material.dart';

import '../../core/status_colors.dart';
import '../../l10n/app_strings.dart';

/// מצבי פריט בקנייה פעילה
enum ShoppingItemStatus {
  /// ⬜ ממתין - עדיין לא נקנה
  pending,

  /// ✅ נקנה - הוכנס לעגלה הפיזית
  purchased,

  /// ❌ לא במלאי - לא היה בחנות
  outOfStock,

  /// ⏭️ דחוי - החלטתי לא לקנות עכשיו
  deferred;

  /// טקסט בעברית
  String get label => switch (this) {
        ShoppingItemStatus.pending => AppStrings.shopping.itemStatusPending,
        ShoppingItemStatus.purchased => AppStrings.shopping.itemStatusPurchased,
        ShoppingItemStatus.outOfStock => AppStrings.shopping.itemStatusOutOfStock,
        ShoppingItemStatus.deferred => AppStrings.shopping.itemStatusDeferred,
      };

  /// אייקון ויזואלי
  IconData get icon => switch (this) {
        ShoppingItemStatus.pending => Icons.radio_button_unchecked,
        ShoppingItemStatus.purchased => Icons.check_circle,
        ShoppingItemStatus.outOfStock => Icons.remove_shopping_cart,
        ShoppingItemStatus.deferred => Icons.schedule,
      };

  /// צבע מותאם
  Color get color => switch (this) {
        ShoppingItemStatus.pending => StatusColors.pending,
        ShoppingItemStatus.purchased => StatusColors.success,
        ShoppingItemStatus.outOfStock => StatusColors.error,
        ShoppingItemStatus.deferred => StatusColors.warning,
      };

  /// האם הפריט הושלם (נקנה/דחוי/לא במלאי)
  bool get isCompleted =>
      this == ShoppingItemStatus.purchased ||
      this == ShoppingItemStatus.outOfStock ||
      this == ShoppingItemStatus.deferred;
}
