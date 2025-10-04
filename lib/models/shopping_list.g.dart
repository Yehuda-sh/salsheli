// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShoppingList _$ShoppingListFromJson(Map<String, dynamic> json) => ShoppingList(
      id: json['id'] as String,
      name: json['name'] as String,
      updatedDate: DateTime.parse(json['updatedDate'] as String),
      status: json['status'] as String? ?? 'active',
      type: json['type'] as String? ?? 'super',
      budget: (json['budget'] as num?)?.toDouble(),
      isShared: json['isShared'] as bool? ?? false,
      createdBy: json['createdBy'] as String,
      sharedWith: (json['sharedWith'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ReceiptItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ShoppingListToJson(ShoppingList instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'updatedDate': instance.updatedDate.toIso8601String(),
      'status': instance.status,
      'type': instance.type,
      'budget': instance.budget,
      'isShared': instance.isShared,
      'createdBy': instance.createdBy,
      'sharedWith': instance.sharedWith,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };
