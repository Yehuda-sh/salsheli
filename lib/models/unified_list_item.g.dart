// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnifiedListItem _$UnifiedListItemFromJson(Map<String, dynamic> json) =>
    UnifiedListItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: $enumDecode(_$ItemTypeEnumMap, json['type'],
          unknownValue: ItemType.unknown),
      isChecked: json['isChecked'] as bool? ?? false,
      category: json['category'] as String?,
      notes: json['notes'] as String?,
      imageUrl: _readImageUrl(json, 'image_url') as String?,
      productData:
          _readProductData(json, 'productData') as Map<String, dynamic>?,
      taskData: _readTaskData(json, 'taskData') as Map<String, dynamic>?,
      checkedBy: _readCheckedBy(json, 'checked_by') as String?,
      checkedAt: const NullableFlexibleDateTimeConverter()
          .fromJson(_readCheckedAt(json, 'checked_at')),
    );

Map<String, dynamic> _$UnifiedListItemToJson(UnifiedListItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$ItemTypeEnumMap[instance.type]!,
      'isChecked': instance.isChecked,
      'category': instance.category,
      'notes': instance.notes,
      'image_url': instance.imageUrl,
      'productData': instance.productData,
      'taskData': instance.taskData,
      'checked_by': instance.checkedBy,
      'checked_at': const NullableFlexibleDateTimeConverter()
          .toJson(instance.checkedAt),
    };

const _$ItemTypeEnumMap = {
  ItemType.product: 'product',
  ItemType.task: 'task',
  ItemType.unknown: 'unknown',
};
