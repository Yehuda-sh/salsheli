import 'package:json_annotation/json_annotation.dart';

/// סטטוס של בקשה
@JsonEnum(valueField: 'value')
enum RequestStatus {
  /// ממתין לאישור
  pending('pending'),

  /// אושר
  approved('approved'),

  /// נדחה
  rejected('rejected');

  const RequestStatus(this.value);
  final String value;

  // Note: hebrewName and emoji were removed - use AppStrings in UI layer
  // if localized status names are needed.

  /// האם הבקשה עדיין ממתינה
  bool get isPending => this == RequestStatus.pending;

  /// האם הבקשה אושרה
  bool get isApproved => this == RequestStatus.approved;

  /// האם הבקשה נדחתה
  bool get isRejected => this == RequestStatus.rejected;
}
