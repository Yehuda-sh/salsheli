// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Template _$TemplateFromJson(Map<String, dynamic> json) => Template(
  id: json['id'] as String,
  type: json['type'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  icon: json['icon'] as String,
  defaultFormat: json['default_format'] as String? ?? 'shared',
  defaultItems:
      (json['default_items'] as List<dynamic>?)
          ?.map((e) => TemplateItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  isSystem: json['is_system'] as bool? ?? false,
  createdBy: json['created_by'] as String,
  householdId: json['household_id'] as String?,
  createdDate: const TimestampConverter().fromJson(
    json['created_date'] as Object,
  ),
  updatedDate: const TimestampConverter().fromJson(
    json['updated_date'] as Object,
  ),
  sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TemplateToJson(Template instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'name': instance.name,
  'description': instance.description,
  'icon': instance.icon,
  'default_format': instance.defaultFormat,
  'default_items': instance.defaultItems.map((e) => e.toJson()).toList(),
  'is_system': instance.isSystem,
  'created_by': instance.createdBy,
  'household_id': instance.householdId,
  'created_date': const TimestampConverter().toJson(instance.createdDate),
  'updated_date': const TimestampConverter().toJson(instance.updatedDate),
  'sort_order': instance.sortOrder,
};

TemplateItem _$TemplateItemFromJson(Map<String, dynamic> json) => TemplateItem(
  name: json['name'] as String,
  category: json['category'] as String?,
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
  unit: json['unit'] as String? ?? 'יח׳',
  note: json['note'] as String?,
);

Map<String, dynamic> _$TemplateItemToJson(TemplateItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'category': instance.category,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'note': instance.note,
    };
