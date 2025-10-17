// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_location_memory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductLocationMemory _$ProductLocationMemoryFromJson(
        Map<String, dynamic> json) =>
    ProductLocationMemory(
      productName: json['product_name'] as String,
      defaultLocation: json['default_location'] as String,
      category: json['category'] as String?,
      usageCount: (json['usage_count'] as num?)?.toInt() ?? 1,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      householdId: json['household_id'] as String?,
    );

Map<String, dynamic> _$ProductLocationMemoryToJson(
        ProductLocationMemory instance) =>
    <String, dynamic>{
      'product_name': instance.productName,
      'default_location': instance.defaultLocation,
      'category': instance.category,
      'usage_count': instance.usageCount,
      'last_updated': instance.lastUpdated.toIso8601String(),
      'household_id': instance.householdId,
    };