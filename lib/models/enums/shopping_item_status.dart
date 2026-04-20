// lib/models/enums/shopping_item_status.dart — Shopping item status — pending, purchased, outOfStock, notNeeded

enum ShoppingItemStatus {
  /// ⬜ ממתין - עדיין לא נקנה
  pending,

  /// ✅ נקנה - הוכנס לעגלה הפיזית
  purchased,

  /// ❌ לא במלאי - לא היה בחנות
  outOfStock,

  /// 🚫 לא צריך - החלטתי שלא צריך בכלל
  notNeeded;

  // Note: label, icon and color were removed - use AppStrings/StatusColors
  // in UI layer if localized status names or visual properties are needed.

  /// האם הפריט הושלם (טופל ע"י המשתמש)
  bool get isCompleted =>
      this == ShoppingItemStatus.purchased ||
      this == ShoppingItemStatus.outOfStock ||
      this == ShoppingItemStatus.notNeeded;

  /// האם הפריט עדיין ממתין לטיפול
  bool get isPending => this == ShoppingItemStatus.pending;

  /// האם הפריט נקנה בהצלחה
  bool get isPurchased => this == ShoppingItemStatus.purchased;

  /// האם הפריט לא היה זמין
  bool get isUnavailable => this == ShoppingItemStatus.outOfStock;
}
