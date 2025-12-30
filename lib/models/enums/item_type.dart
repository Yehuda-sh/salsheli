// 📄 File: lib/models/enums/item_type.dart
//
// 🇮🇱 סוגי פריטים ברשימת קניות:
//     - product: מוצר לקנייה (חלב, לחם, וכו')
//     - task: משימה (להזמין DJ, לשכור צלם, וכו')
//
// 🇬🇧 Shopping list item types:
//     - product: Product to buy (milk, bread, etc.)
//     - task: Task to do (book DJ, rent photographer, etc.)
//

/// 🇮🇱 סוגי פריטים ברשימה
/// 🇬🇧 Item types in list
enum ItemType {
  /// 🛒 מוצר לקנייה
  product,

  /// ✅ משימה לביצוע
  task;

  // Note: hebrewName and emoji were removed - use AppStrings in UI layer
  // if localized type names are needed.
}
