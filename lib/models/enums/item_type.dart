// lib/models/enums/item_type.dart — Item type enum — product, task, unknown (with unknownValue fallback)

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
