// 📄 File: lib/models/notification.dart
//
// 🇮🇱 מודל התראה באפליקציה:
//     - הזמנות לרשימות וקבוצות
//     - אישור/דחייה של בקשות
//     - שינויי תפקיד והסרות
//     - התראות מזווה (מלאי נמוך)
//
// 🇬🇧 App notification model:
//     - List and group invitations
//     - Request approvals/rejections
//     - Role changes and removals
//     - Pantry alerts (low stock)
//
// 🔗 Related:
//     - NotificationsProvider (providers/notifications_provider.dart)
//     - NotificationsRepository (repositories/notifications_repository.dart)
//     - NotificationsList (screens/notifications/)
//
import 'package:flutter/foundation.dart' show immutable;
import 'package:json_annotation/json_annotation.dart';

import 'timestamp_converter.dart';

part 'notification.g.dart';

// ---- JSON Converters ----

/// 🔧 ממיר ל-actionData עם:
/// - null → {} ריק
/// - המרת keys ל-String (Firestore לפעמים מחזיר Map<dynamic, dynamic>)
/// - עטיפה ב-Map.unmodifiable
class _ActionDataConverter
    implements JsonConverter<Map<String, dynamic>, Object?> {
  const _ActionDataConverter();

  @override
  Map<String, dynamic> fromJson(Object? json) {
    if (json == null) return const {};
    if (json is! Map) return const {};

    // המרה בטוחה + unmodifiable
    return Map.unmodifiable(
      Map<String, dynamic>.from(
        json.map((k, v) => MapEntry(k.toString(), v)),
      ),
    );
  }

  @override
  Object toJson(Map<String, dynamic> data) => data;
}

/// 🇮🇱 מודל התראה באפליקציה
/// 🇬🇧 App notification model
@immutable
@JsonSerializable(explicitToJson: true)
class AppNotification {
  final String id;
  
  @JsonKey(name: 'user_id')
  final String userId; // מי מקבל את ההתראה
  
  @JsonKey(name: 'household_id')
  final String householdId;

  /// סוג ההתראה
  /// ✅ unknownEnumValue: מונע קריסה אם מגיע סוג חדש מהשרת
  @JsonKey(unknownEnumValue: NotificationType.unknown)
  final NotificationType type;
  
  final String title; // כותרת (עברית)
  final String message; // הודעה מפורטת
  
  /// נתונים נוספים (listId, requestId, etc)
  /// 🔒 Unmodifiable via _ActionDataConverter
  /// 🔧 Handles: null → {}, Map<dynamic,dynamic> → Map<String,dynamic>
  @JsonKey(name: 'action_data')
  @_ActionDataConverter()
  final Map<String, dynamic> actionData;

  @JsonKey(name: 'is_read')
  final bool isRead;

  /// תאריך יצירה
  /// 🔧 תומך גם ב-Timestamp (Firestore) וגם ב-ISO string (FCM)
  @JsonKey(name: 'created_at')
  @TimestampConverter()
  final DateTime createdAt;

  /// תאריך קריאה
  /// 🔧 תומך גם ב-Timestamp (Firestore) וגם ב-ISO string (FCM)
  @JsonKey(name: 'read_at')
  @NullableTimestampConverter()
  final DateTime? readAt;

  /// מזהה השולח - לצורך "השתק שולח"
  @JsonKey(name: 'sender_id')
  final String? senderId;

  /// שם השולח - להצגה
  @JsonKey(name: 'sender_name')
  final String? senderName;

  /// 🔒 Private constructor - משתמש ב-factory AppNotification() לאכיפת immutability
  const AppNotification._({
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
    this.senderId,
    this.senderName,
  });

  /// 🔧 Factory constructor - עוטף actionData ב-Map.unmodifiable
  factory AppNotification({
    required String id,
    required String userId,
    required String householdId,
    required NotificationType type,
    required String title,
    required String message,
    required Map<String, dynamic> actionData,
    bool isRead = false,
    required DateTime createdAt,
    DateTime? readAt,
    String? senderId,
    String? senderName,
  }) {
    return AppNotification._(
      id: id,
      userId: userId,
      householdId: householdId,
      type: type,
      title: title,
      message: message,
      actionData: Map.unmodifiable(actionData),
      isRead: isRead,
      createdAt: createdAt,
      readAt: readAt,
      senderId: senderId,
      senderName: senderName,
    );
  }

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
    String? senderId,
    String? senderName,
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
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
    );
  }

  // ---- Helpers ----

  bool get isUnread => !isRead;

  /// 🔧 קורא מ-actionData עם תמיכה ב-camelCase וגם snake_case
  String? _getData(String camelCase, String snakeCase) =>
      (actionData[camelCase] ?? actionData[snakeCase]) as String?;

  /// מזהה הרשימה
  String? get listId => _getData('listId', 'list_id');

  /// מזהה הבקשה
  String? get requestId => _getData('requestId', 'request_id');

  /// שם הרשימה
  String? get listName => _getData('listName', 'list_name');

  /// שם המזמין
  String? get inviterName => _getData('inviterName', 'inviter_name');

  /// תפקיד חדש
  String? get newRole => _getData('newRole', 'new_role');

  /// מזהה הקבוצה (לקבוצות)
  String? get groupId => _getData('groupId', 'group_id');

  /// שם הקבוצה (לקבוצות)
  String? get groupName => _getData('groupName', 'group_name');
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

  /// ❓ סוג לא מוכר (fallback למניעת קריסה)
  /// Used when server returns an unknown notification type
  @JsonValue('unknown')
  unknown,
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
      case NotificationType.unknown:
        return '❓';
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
      case NotificationType.unknown:
        return 'לא ידוע';
    }
  }

  /// האם זה סוג תקין (לא unknown)
  bool get isKnown => this != NotificationType.unknown;
}
