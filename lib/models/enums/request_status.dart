/// סטטוס של בקשה
enum RequestStatus {
  /// ממתין לאישור
  pending,
  
  /// אושר
  approved,
  
  /// נדחה
  rejected;

  /// שם בעברית
  String get hebrewName {
    switch (this) {
      case RequestStatus.pending:
        return 'ממתין לאישור';
      case RequestStatus.approved:
        return 'אושר';
      case RequestStatus.rejected:
        return 'נדחה';
    }
  }

  /// אימוג'י לסטטוס
  String get emoji {
    switch (this) {
      case RequestStatus.pending:
        return '🔵';
      case RequestStatus.approved:
        return '✅';
      case RequestStatus.rejected:
        return '❌';
    }
  }

  /// האם הבקשה עדיין ממתינה
  bool get isPending => this == RequestStatus.pending;

  /// האם הבקשה אושרה
  bool get isApproved => this == RequestStatus.approved;

  /// האם הבקשה נדחתה
  bool get isRejected => this == RequestStatus.rejected;
}
