// lib/models/enums/request_status.dart — Request status enum — pending, approved, rejected, unknown

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
