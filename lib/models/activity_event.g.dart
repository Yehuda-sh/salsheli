// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityEvent _$ActivityEventFromJson(Map<String, dynamic> json) =>
    ActivityEvent(
      id: json['id'] as String? ?? '',
      householdId: json['household_id'] as String? ?? '',
      type: $enumDecode(_$ActivityTypeEnumMap, json['type'],
          unknownValue: ActivityType.unknown),
      actorId: json['actor_id'] as String? ?? '',
      actorName: json['actor_name'] as String? ?? '',
      createdAt:
          const FlexibleDateTimeConverter().fromJson(json['created_at']),
      data: const _EventDataConverter().fromJson(json['data']),
    );

Map<String, dynamic> _$ActivityEventToJson(ActivityEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'household_id': instance.householdId,
      'type': _$ActivityTypeEnumMap[instance.type]!,
      'actor_id': instance.actorId,
      'actor_name': instance.actorName,
      'created_at':
          const FlexibleDateTimeConverter().toJson(instance.createdAt),
      'data': const _EventDataConverter().toJson(instance.data),
    };

const _$ActivityTypeEnumMap = {
  ActivityType.shoppingCompleted: 'shopping_completed',
  ActivityType.shoppingStarted: 'shopping_started',
  ActivityType.shoppingJoined: 'shopping_joined',
  ActivityType.listCreated: 'list_created',
  ActivityType.itemAdded: 'item_added',
  ActivityType.stockUpdated: 'stock_updated',
  ActivityType.memberLeft: 'member_left',
  ActivityType.roleChanged: 'role_changed',
  ActivityType.unknown: 'unknown',
};
