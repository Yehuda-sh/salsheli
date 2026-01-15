// 📄 File: lib/models/enums/request_type.dart
//
// 🇮🇱 סוגי בקשות שמשתמש (Editor) יכול לשלוח לאישור:
//     - addItem: בקשה להוסיף פריט חדש לרשימה
//     - editItem: בקשה לערוך פריט קיים (שם, כמות, מחיר)
//     - deleteItem: בקשה למחוק פריט מהרשימה
//     - inviteToList: הזמנת משתמש להצטרף לרשימה/משפחה
//     - unknown: fallback לערכים לא מוכרים מהשרת
//
// 🇬🇧 Request types that user (Editor) can send for approval:
//     - addItem: Request to add new item to list
//     - editItem: Request to edit existing item (name, quantity, price)
//     - deleteItem: Request to delete item from list
//     - inviteToList: Invite user to join list/household
//     - unknown: fallback for unknown server values
//
// 🔗 Related:
//     - PendingRequest (models/pending_request.dart)
//     - PendingRequestsService (services/pending_requests_service.dart)
//     - request_status.dart - סטטוסי בקשות (pending/approved/rejected)
//

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

  /// 👥 הזמנה להצטרף לרשימה/משפחה
  inviteToList('inviteToList'),

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
  bool get isInviteRequest => this == RequestType.inviteToList;
}
