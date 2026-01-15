// 📄 File: lib/models/enums/shopping_item_status.dart
//
// 🇮🇱 מצבי פריט בקנייה פעילה (ActiveShoppingScreen):
//     - pending: ממתין לקנייה (ברירת מחדל)
//     - purchased: נקנה והוכנס לעגלה
//     - outOfStock: לא היה במלאי בחנות
//     - notNeeded: המשתמש החליט שלא צריך
//
// 🇬🇧 Shopping item statuses during active shopping:
//     - pending: Waiting to be purchased (default)
//     - purchased: Bought and added to cart
//     - outOfStock: Not available in store
//     - notNeeded: User decided not needed
//
// 📝 Note: This enum is used INTERNALLY only (in-memory state).
//          NOT serialized to server → no @JsonEnum or unknownEnumValue needed.
//
// 🔗 Related:
//     - ActiveShoppingScreen (screens/shopping/active/active_shopping_screen.dart)
//     - StatusColors (core/status_colors.dart)
//     - AppStrings.shopping (l10n/app_strings.dart)
//

/// 🇮🇱 מצבי פריט בקנייה פעילה
/// 🇬🇧 Shopping item statuses during active shopping
///
/// ⚠️ Internal only - לא נשמר לשרת, רק state מקומי במסך קנייה
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
