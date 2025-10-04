// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryItem _$InventoryItemFromJson(Map<String, dynamic> json) =>
    InventoryItem(
      id: json['id'] as String,
      productName: json['productName'] as String,
      category: json['category'] as String,
      location: json['location'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unit: json['unit'] as String,
    );

Map<String, dynamic> _$InventoryItemToJson(InventoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productName': instance.productName,
      'category': instance.category,
      'location': instance.location,
      'quantity': instance.quantity,
      'unit': instance.unit,
    };
