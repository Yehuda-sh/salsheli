// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    AppNotification(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      householdId: json['household_id'] as String? ?? '',
      type: $enumDecode(_$NotificationTypeEnumMap, json['type'],
          unknownValue: NotificationType.unknown),
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      actionData: const _ActionDataConverter().fromJson(json['action_data']),
      isRead: json['is_read'] as bool? ?? false,
      createdAt:
          const TimestampConverter().fromJson(json['created_at'] as Object),
      readAt: const NullableTimestampConverter().fromJson(json['read_at']),
      senderId: json['sender_id'] as String?,
      senderName: json['sender_name'] as String?,
    );

Map<String, dynamic> _$AppNotificationToJson(AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'household_id': instance.householdId,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'message': instance.message,
      'action_data': const _ActionDataConverter().toJson(instance.actionData),
      'is_read': instance.isRead,
      'created_at': const TimestampConverter().toJson(instance.createdAt),
      'read_at': const NullableTimestampConverter().toJson(instance.readAt),
      'sender_id': instance.senderId,
      'sender_name': instance.senderName,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.invite: 'invite',
  NotificationType.requestApproved: 'request_approved',
  NotificationType.requestRejected: 'request_rejected',
  NotificationType.roleChanged: 'role_changed',
  NotificationType.userRemoved: 'user_removed',
  NotificationType.whoBringsVolunteer: 'who_brings_volunteer',
  NotificationType.newVote: 'new_vote',
  NotificationType.voteTie: 'vote_tie',
  NotificationType.memberLeft: 'member_left',
  NotificationType.lowStock: 'low_stock',
  NotificationType.unknown: 'unknown',
};
