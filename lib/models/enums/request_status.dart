/// סטטוס של בקשה
enum RequestStatus {
  /// ממתין לאישור
  pending,

  /// אושר
  approved,

  /// נדחה
  rejected;

  // Note: hebrewName and emoji were removed - use AppStrings in UI layer
  // if localized status names are needed.

  /// האם הבקשה עדיין ממתינה
  bool get isPending => this == RequestStatus.pending;

  /// האם הבקשה אושרה
  bool get isApproved => this == RequestStatus.approved;

  /// האם הבקשה נדחתה
  bool get isRejected => this == RequestStatus.rejected;
}
