// 📄 File: lib/models/notification.dart
//
// Version: 4.0 (22/02/2026)
//
// 🇮🇱 מודל התראה באפליקציה — "UI-aware notification":
//     - הזמנות לרשימות
//     - אישור/דחייה של בקשות
//     - שינויי תפקיד והסרות
//     - התראות מזווה (מלאי נמוך)
//
// 🇬🇧 App notification model — UI-aware:
//     - List invitations
//     - Request approvals/rejections
//     - Role changes and removals
//     - Pantry alerts (low stock)
//
// ✨ Features:
//     - StatusType linkage (semantic status per notification type)
//     - Haptic Hints (recommendedHaptic per priority)
//     - Priority Mapping (NotificationPriority enum)
//     - Extended actionData helpers (productId, volunteerName, etc.)
//
// 📅 History:
//     v4.0 (22/02/2026) — StatusType linkage, Priority enum, Haptic hints, extended helpers
//     v3.0              — actionData converter, immutable factory, copyWith
//
// 🔗 Related:
//     - NotificationsProvider (providers/notifications_provider.dart)
//     - NotificationsRepository (repositories/notifications_repository.dart)
//     - NotificationsList (screens/notifications/)
//     - StatusColors (core/status_colors.dart)
//
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../core/status_colors.dart';
import 'timestamp_converter.dart';

part 'notification.g.dart';

// ---- JSON Converters ----

/// 🔧 ממיר ל-actionData עם:
/// - null → {} ריק
/// - המרת keys ל-String (Firestore לפעמים מחזיר `Map<dynamic, dynamic>`)
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

// ---- Priority Enum ----

/// 🔔 רמת דחיפות ההתראה
///
/// קובעת את עוצמת הרטט ואת סדר המיון ב-UI:
/// - [urgent] — דורש פעולה מיידית (userRemoved, voteTie)
/// - [high] — חשוב אבל לא קריטי (invite, roleChanged, lowStock)
/// - [normal] — אינפורמטיבי רגיל (requestApproved, newVote)
/// - [low] — רקע / מידע כללי (memberLeft, unknown)
enum NotificationPriority {
  low,
  normal,
  high,
  urgent;

  /// האם דורש תשומת לב מיידית
  bool get isUrgent => this == urgent;

  /// האם חשוב (urgent או high)
  bool get isImportant => this == urgent || this == high;
}

// ---- Notification Model ----

/// 🇮🇱 מודל התראה באפליקציה — UI-aware
/// 🇬🇧 App notification model — UI-aware
@immutable
@JsonSerializable(explicitToJson: true)
class AppNotification {
  static const _sentinel = Object();

  @JsonKey(defaultValue: '')
  final String id;
  
  @JsonKey(name: 'user_id', defaultValue: '')
  final String userId; // מי מקבל את ההתראה
  
  @JsonKey(name: 'household_id', defaultValue: '')
  final String householdId;

  /// סוג ההתראה
  /// ✅ unknownEnumValue: מונע קריסה אם מגיע סוג חדש מהשרת
  @JsonKey(unknownEnumValue: NotificationType.unknown)
  final NotificationType type;
  
  @JsonKey(defaultValue: '')
  final String title; // כותרת (עברית)
  @JsonKey(defaultValue: '')
  final String message; // הודעה מפורטת
  
  /// נתונים נוספים (listId, requestId, etc)
  /// 🔒 Unmodifiable via _ActionDataConverter
  /// 🔧 Handles: null → {}, `Map<dynamic,dynamic>` → `Map<String,dynamic>`
  @JsonKey(name: 'action_data')
  @_ActionDataConverter()
  final Map<String, dynamic> actionData;

  @JsonKey(name: 'is_read', defaultValue: false)
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
    Object? readAt = _sentinel,
    Object? senderId = _sentinel,
    Object? senderName = _sentinel,
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
      readAt: readAt == _sentinel ? this.readAt : readAt as DateTime?,
      senderId: senderId == _sentinel ? this.senderId : senderId as String?,
      senderName: senderName == _sentinel ? this.senderName : senderName as String?,
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

  // ---- v4.0: Extended actionData Getters ----

  /// מזהה המוצר (למזווה / "מי מביא")
  String? get productId => _getData('productId', 'product_id');

  /// שם המוצר
  String? get productName => _getData('productName', 'product_name');

  /// שם המתנדב (ל-whoBringsVolunteer)
  String? get volunteerName => _getData('volunteerName', 'volunteer_name');

  /// סיבה (להסרה / דחייה)
  String? get reason => _getData('reason', 'reason');

  // ---- v4.0: Navigation ----

  /// האם ניתן לנווט מההתראה ליעד
  ///
  /// בודק שיש גם סוג שתומך בניווט וגם נתונים מספיקים ב-actionData
  bool get canNavigate {
    switch (type) {
      case NotificationType.invite:
      case NotificationType.requestApproved:
      case NotificationType.roleChanged:
      case NotificationType.whoBringsVolunteer:
      case NotificationType.newVote:
      case NotificationType.voteTie:
        return listId != null;
      case NotificationType.lowStock:
        return productId != null;
      case NotificationType.requestRejected:
      case NotificationType.userRemoved:
      case NotificationType.memberLeft:
      case NotificationType.unknown:
        return false;
    }
  }

  // ---- v4.0: Presentation Getters ----

  /// סוג הסטטוס הסמנטי — לצביעה אוטומטית ב-UI
  ///
  /// מאציל ל-[NotificationTypeExtension.statusType]
  StatusType get statusType => type.statusType;

  /// רמת הדחיפות — למיון ורטט
  NotificationPriority get priority => switch (type) {
    NotificationType.userRemoved => NotificationPriority.urgent,
    NotificationType.voteTie => NotificationPriority.urgent,
    NotificationType.invite => NotificationPriority.high,
    NotificationType.roleChanged => NotificationPriority.high,
    NotificationType.lowStock => NotificationPriority.high,
    NotificationType.requestApproved => NotificationPriority.normal,
    NotificationType.requestRejected => NotificationPriority.normal,
    NotificationType.whoBringsVolunteer => NotificationPriority.normal,
    NotificationType.newVote => NotificationPriority.normal,
    NotificationType.memberLeft => NotificationPriority.low,
    NotificationType.unknown => NotificationPriority.low,
  };

  /// שם הרטט המומלץ — לשימוש ב-HapticFeedback
  ///
  /// - `'heavy'` → urgent (userRemoved, voteTie)
  /// - `'medium'` → high (invite, roleChanged, lowStock)
  /// - `'light'` → normal (requestApproved, newVote, etc.)
  /// - `'selection'` → low (memberLeft, unknown)
  String get recommendedHaptic => switch (priority) {
    NotificationPriority.urgent => 'heavy',
    NotificationPriority.high => 'medium',
    NotificationPriority.normal => 'light',
    NotificationPriority.low => 'selection',
  };
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

  @JsonValue('who_brings_volunteer')
  whoBringsVolunteer, // מישהו התנדב להביא פריט

  @JsonValue('new_vote')
  newVote, // מישהו הצביע בהצבעה

  @JsonValue('vote_tie')
  voteTie, // תיקו בהצבעה (לבעלים)

  @JsonValue('member_left')
  memberLeft, // חבר עזב (לאדמינים)

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

  // ---- v4.0: StatusType Linkage ----

  /// סוג הסטטוס הסמנטי — מיפוי ל-[StatusType]
  ///
  /// - error: userRemoved, requestRejected, voteTie
  /// - warning: lowStock, roleChanged
  /// - success: requestApproved, whoBringsVolunteer
  /// - info: invite, newVote, memberLeft, unknown
  StatusType get statusType {
    switch (this) {
      case NotificationType.userRemoved:
      case NotificationType.requestRejected:
      case NotificationType.voteTie:
        return StatusType.error;
      case NotificationType.lowStock:
      case NotificationType.roleChanged:
        return StatusType.warning;
      case NotificationType.requestApproved:
      case NotificationType.whoBringsVolunteer:
        return StatusType.success;
      case NotificationType.invite:
      case NotificationType.newVote:
      case NotificationType.memberLeft:
      case NotificationType.unknown:
        return StatusType.info;
    }
  }

  /// צבע ברירת מחדל לפי סטטוס — דורש [BuildContext]
  ///
  /// עוטף את [StatusColors.getColor] עם [statusType]
  Color defaultColor(BuildContext context) =>
      StatusColors.getColor(statusType, context);
}
