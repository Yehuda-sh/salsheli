// lib/models/enums/request_type.dart — Request type enum — addItem, editItem, deleteItem, inviteToList/Household, unknown

import 'package:json_annotation/json_annotation.dart';

/// 🇮🇱 סוגי בקשות לאישור
/// 🇬🇧 Request types for approval
@JsonEnum(valueField: 'value')
enum RequestType {
  /// ➕ בקשה להוסיף פריט חדש
  addItem('addItem'),

  /// ✏️ בקשה לערוך פריט קיים
  editItem('editItem'),

  /// 🗑️ בקשה למחוק פריט
  deleteItem('deleteItem'),

  /// 👥 הזמנה להצטרף לרשימה (legacy)
  inviteToList('inviteToList'),

  /// 🏠 הזמנה להצטרף לבית
  inviteToHousehold('inviteToHousehold'),

  /// ❓ סוג לא מוכר (fallback למניעת קריסה)
  /// Used when server returns an unknown type value
  unknown('unknown');

  const RequestType(this.value);
  final String value;

  // Note: hebrewName and emoji were removed - use AppStrings in UI layer
  // if localized type names are needed.

  /// האם זה סוג תקין (לא unknown)
  bool get isKnown => this != RequestType.unknown;

  /// האם זו בקשה הקשורה לפריט (add/edit/delete)
  bool get isItemRequest =>
      this == RequestType.addItem ||
      this == RequestType.editItem ||
      this == RequestType.deleteItem;

  /// האם זו בקשת הזמנה
  bool get isInviteRequest =>
      this == RequestType.inviteToList ||
      this == RequestType.inviteToHousehold;
}
