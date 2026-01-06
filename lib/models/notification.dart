import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

/// 📬 Notification Model
/// 
/// Types:
/// - invite: User invited to list
/// - request_approved: Editor's request approved
/// - request_rejected: Editor's request rejected
/// - role_changed: User role updated
/// - user_removed: User removed from list
/// 
/// Version: 1.0
/// Created: 04/11/2025

@JsonSerializable(explicitToJson: true)
class AppNotification {
  final String id;
  
  @JsonKey(name: 'user_id')
  final String userId; // מי מקבל את ההתראה
  
  @JsonKey(name: 'household_id')
  final String householdId;
  
  final NotificationType type;
  
  final String title; // כותרת (עברית)
  final String message; // הודעה מפורטת
  
  @JsonKey(name: 'action_data')
  final Map<String, dynamic> actionData; // נתונים נוספים (listId, requestId, etc)
  
  @JsonKey(name: 'is_read')
  final bool isRead;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'read_at')
  final DateTime? readAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.householdId,
    required this.type,
    required this.title,
    required this.message,
    required this.actionData,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
  });

  // JSON serialization
  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);

  // copyWith
  AppNotification copyWith({
    String? id,
    String? userId,
    String? householdId,
    NotificationType? type,
    String? title,
    String? message,
    Map<String, dynamic>? actionData,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      householdId: householdId ?? this.householdId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      actionData: actionData ?? this.actionData,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  // Helpers
  bool get isUnread => !isRead;
  
  String? get listId => actionData['listId'] as String?;
  String? get requestId => actionData['requestId'] as String?;
  String? get listName => actionData['listName'] as String?;
  String? get inviterName => actionData['inviterName'] as String?;
  String? get newRole => actionData['newRole'] as String?;
}

/// 📋 Notification Types
@JsonEnum()
enum NotificationType {
  @JsonValue('invite')
  invite, // הזמנה לרשימה משותפת

  @JsonValue('request_approved')
  requestApproved, // בקשה אושרה

  @JsonValue('request_rejected')
  requestRejected, // בקשה נדחתה

  @JsonValue('role_changed')
  roleChanged, // תפקיד השתנה

  @JsonValue('user_removed')
  userRemoved, // הוסרת מהרשימה

  // === Stage 6: New notification types ===

  @JsonValue('group_invite')
  groupInvite, // הזמנה לקבוצה

  @JsonValue('group_invite_rejected')
  groupInviteRejected, // 🆕 הזמנה לקבוצה נדחתה

  @JsonValue('who_brings_volunteer')
  whoBringsVolunteer, // מישהו התנדב להביא פריט

  @JsonValue('new_vote')
  newVote, // מישהו הצביע בהצבעה

  @JsonValue('vote_tie')
  voteTie, // תיקו בהצבעה (לבעלים)

  @JsonValue('member_left')
  memberLeft, // חבר עזב את הקבוצה (לאדמינים)

  @JsonValue('low_stock')
  lowStock, // מלאי נמוך במזווה
}

/// Extension for display
extension NotificationTypeExtension on NotificationType {
  String get emoji {
    switch (this) {
      case NotificationType.invite:
        return '✉️';
      case NotificationType.requestApproved:
        return '✅';
      case NotificationType.requestRejected:
        return '❌';
      case NotificationType.roleChanged:
        return '🔄';
      case NotificationType.userRemoved:
        return '🚫';
      case NotificationType.groupInvite:
        return '👥';
      case NotificationType.groupInviteRejected:
        return '🚫';
      case NotificationType.whoBringsVolunteer:
        return '🙋';
      case NotificationType.newVote:
        return '🗳️';
      case NotificationType.voteTie:
        return '⚖️';
      case NotificationType.memberLeft:
        return '👋';
      case NotificationType.lowStock:
        return '📦';
    }
  }

  String get hebrewName {
    switch (this) {
      case NotificationType.invite:
        return 'הזמנה';
      case NotificationType.requestApproved:
        return 'בקשה אושרה';
      case NotificationType.requestRejected:
        return 'בקשה נדחתה';
      case NotificationType.roleChanged:
        return 'שינוי תפקיד';
      case NotificationType.userRemoved:
        return 'הסרה';
      case NotificationType.groupInvite:
        return 'הזמנה לקבוצה';
      case NotificationType.groupInviteRejected:
        return 'הזמנה נדחתה';
      case NotificationType.whoBringsVolunteer:
        return 'התנדבות';
      case NotificationType.newVote:
        return 'הצבעה';
      case NotificationType.voteTie:
        return 'תיקו';
      case NotificationType.memberLeft:
        return 'עזיבה';
      case NotificationType.lowStock:
        return 'מלאי נמוך';
    }
  }
}
