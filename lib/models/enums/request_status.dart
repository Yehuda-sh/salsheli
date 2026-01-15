// 📄 File: lib/models/enums/request_status.dart
//
// 🇮🇱 סטטוסים של בקשות שיתוף/הצטרפות:
//     - pending: ממתין לאישור (ברירת מחדל לבקשות חדשות)
//     - approved: אושר (המשתמש נוסף לרשימה/משק בית)
//     - rejected: נדחה (הבקשה לא אושרה)
//     - unknown: fallback לערכים לא מוכרים מהשרת
//
// 🇬🇧 Sharing/join request statuses:
//     - pending: Awaiting approval (default for new requests)
//     - approved: Approved (user added to list/household)
//     - rejected: Rejected (request not approved)
//     - unknown: fallback for unknown server values
//
// 🔗 Related:
//     - PendingRequest (models/pending_request.dart)
//     - PendingRequestsService (services/pending_requests_service.dart)
//     - PendingRequestsScreen (screens/sharing/pending_requests_screen.dart)
//

import 'package:json_annotation/json_annotation.dart';

/// 🇮🇱 סטטוס בקשה (שיתוף/הצטרפות)
/// 🇬🇧 Request status (sharing/joining)
@JsonEnum(valueField: 'value')
enum RequestStatus {
  /// ⏳ ממתין לאישור
  pending('pending'),

  /// ✅ אושר
  approved('approved'),

  /// ❌ נדחה
  rejected('rejected'),

  /// ❓ סטטוס לא מוכר (fallback למניעת קריסה)
  /// Used when server returns an unknown status value
  unknown('unknown');

  const RequestStatus(this.value);
  final String value;

  // Note: hebrewName and emoji were removed - use AppStrings in UI layer
  // if localized status names are needed.

  /// האם הבקשה עדיין ממתינה (כולל unknown - כדי שלא ייעלמו מה-UI)
  /// ⚠️ unknown נחשב כ-pending כי עדיף להציג בקשה "ממתינה" מאשר להעלים אותה
  bool get isPending => this == RequestStatus.pending || this == RequestStatus.unknown;

  /// האם הבקשה אושרה
  bool get isApproved => this == RequestStatus.approved;

  /// האם הבקשה נדחתה
  bool get isRejected => this == RequestStatus.rejected;

  /// האם הבקשה טופלה (אושרה או נדחתה)
  bool get isResolved => isApproved || isRejected;

  /// האם זה סטטוס תקין (לא unknown)
  bool get isKnown => this != RequestStatus.unknown;
}
