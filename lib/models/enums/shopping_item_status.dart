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
  String get label {
    switch (this) {
      case ShoppingItemStatus.pending:
        return AppStrings.shopping.itemStatusPending;
      case ShoppingItemStatus.purchased:
        return AppStrings.shopping.itemStatusPurchased;
      case ShoppingItemStatus.outOfStock:
        return AppStrings.shopping.itemStatusOutOfStock;
      case ShoppingItemStatus.deferred:
        return AppStrings.shopping.itemStatusDeferred;
    }
  }

  /// אייקון ויזואלי
  IconData get icon {
    switch (this) {
      case ShoppingItemStatus.pending:
        return Icons.radio_button_unchecked;
      case ShoppingItemStatus.purchased:
        return Icons.check_circle;
      case ShoppingItemStatus.outOfStock:
        return Icons.remove_shopping_cart;
      case ShoppingItemStatus.deferred:
        return Icons.schedule;
    }
  }

  /// צבע מותאם
  Color get color {
    switch (this) {
      case ShoppingItemStatus.pending:
        return StatusColors.pending;
      case ShoppingItemStatus.purchased:
        return StatusColors.success;
      case ShoppingItemStatus.outOfStock:
        return StatusColors.error;
      case ShoppingItemStatus.deferred:
        return StatusColors.warning;
    }
  }

  /// האם הפריט הושלם (נקנה/דחוי/לא במלאי)
  bool get isCompleted =>
      this == ShoppingItemStatus.purchased ||
      this == ShoppingItemStatus.outOfStock ||
      this == ShoppingItemStatus.deferred;
}
