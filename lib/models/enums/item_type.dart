// 📄 File: lib/models/enums/item_type.dart
//
// 🇮🇱 סוגי פריטים ברשימת קניות:
//     - product: מוצר לקנייה (חלב, לחם, וכו')
//     - task: משימה (להזמין DJ, לשכור צלם, וכו')
//     - unknown: fallback לערכים לא מוכרים מהשרת
//
// 🇬🇧 Shopping list item types:
//     - product: Product to buy (milk, bread, etc.)
//     - task: Task to do (book DJ, rent photographer, etc.)
//     - unknown: fallback for unknown server values
//
// 🔗 Related:
//     - UnifiedListItem (models/unified_list_item.dart)
//     - ShoppingList (models/shopping_list.dart)
//

import 'package:json_annotation/json_annotation.dart';

/// 🇮🇱 סוגי פריטים ברשימה
/// 🇬🇧 Item types in list
@JsonEnum(valueField: 'value')
enum ItemType {
  /// 🛒 מוצר לקנייה
  product('product'),

  /// ✅ משימה לביצוע
  task('task'),

  /// ❓ סוג לא מוכר (fallback למניעת קריסה)
  /// Used when server returns an unknown type value
  unknown('unknown');

  const ItemType(this.value);
  final String value;

  /// האם זה סוג תקין (לא unknown)
  bool get isKnown => this != ItemType.unknown;
}
