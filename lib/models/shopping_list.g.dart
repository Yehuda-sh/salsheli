// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShoppingList _$ShoppingListFromJson(Map<String, dynamic> json) => ShoppingList(
  id: json['id'] as String,
  name: json['name'] as String,
  updatedDate: const TimestampConverter().fromJson(
    json['updated_date'] as Object,
  ),
  createdDate: _$JsonConverterFromJson<Object, DateTime>(
    json['created_date'],
    const TimestampConverter().fromJson,
  ),
  status: json['status'] as String? ?? 'active',
  type: json['type'] as String? ?? 'super',
  budget: (json['budget'] as num?)?.toDouble(),
  eventDate: _$JsonConverterFromJson<Object, DateTime>(
    json['event_date'],
    const TimestampConverter().fromJson,
  ),
  targetDate: _$JsonConverterFromJson<Object, DateTime>(
    json['target_date'],
    const TimestampConverter().fromJson,
  ),
  isShared: json['is_shared'] as bool? ?? false,
  createdBy: json['created_by'] as String,
  sharedWith:
      (json['shared_with'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  items: (json['items'] as List<dynamic>)
      .map((e) => UnifiedListItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  templateId: json['template_id'] as String?,
  format: json['format'] as String? ?? 'shared',
  createdFromTemplate: json['created_from_template'] as bool? ?? false,
  activeShoppers:
      (json['active_shoppers'] as List<dynamic>?)
          ?.map((e) => ActiveShopper.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  sharedUsers:
      (json['shared_users'] as List<dynamic>?)
          ?.map((e) => SharedUser.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  pendingRequests:
      (json['pending_requests'] as List<dynamic>?)
          ?.map((e) => PendingRequest.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$ShoppingListToJson(
  ShoppingList instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'updated_date': const TimestampConverter().toJson(instance.updatedDate),
  'created_date': const TimestampConverter().toJson(instance.createdDate),
  'status': instance.status,
  'type': instance.type,
  'budget': instance.budget,
  'is_shared': instance.isShared,
  'created_by': instance.createdBy,
  'shared_with': instance.sharedWith,
  'event_date': _$JsonConverterToJson<Object, DateTime>(
    instance.eventDate,
    const TimestampConverter().toJson,
  ),
  'target_date': _$JsonConverterToJson<Object, DateTime>(
    instance.targetDate,
    const TimestampConverter().toJson,
  ),
  'items': instance.items.map((e) => e.toJson()).toList(),
  'template_id': instance.templateId,
  'format': instance.format,
  'created_from_template': instance.createdFromTemplate,
  'active_shoppers': instance.activeShoppers.map((e) => e.toJson()).toList(),
  'shared_users': instance.sharedUsers.map((e) => e.toJson()).toList(),
  'pending_requests': instance.pendingRequests.map((e) => e.toJson()).toList(),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
