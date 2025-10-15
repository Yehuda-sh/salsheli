// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryItem _$InventoryItemFromJson(Map<String, dynamic> json) =>
    InventoryItem(
      id: json['id'] as String,
      productName: json['productName'] as String? ?? 'מוצר לא ידוע',
      category: json['category'] as String? ?? 'כללי',
      location: json['location'] as String? ?? 'כללי',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unit: json['unit'] as String? ?? "יח'",
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
