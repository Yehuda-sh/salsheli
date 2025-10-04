// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiShoppingList _$ApiShoppingListFromJson(Map<String, dynamic> json) =>
    ApiShoppingList(
      id: json['id'] as String,
      name: json['name'] as String,
      householdId: json['household_id'] as String,
      updatedDate: json['updated_date'] as String?,
      status: json['status'] as String?,
      type: json['type'] as String?,
      budget: (json['budget'] as num?)?.toDouble(),
      isShared: json['is_shared'] as bool?,
      createdBy: json['created_by'] as String?,
      sharedWith: (json['shared_with'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => ApiReceiptItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ApiShoppingListToJson(ApiShoppingList instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'updated_date': instance.updatedDate,
      'household_id': instance.householdId,
      'status': instance.status,
      'type': instance.type,
      'budget': instance.budget,
      'is_shared': instance.isShared,
      'created_by': instance.createdBy,
      'shared_with': instance.sharedWith,
      'items': instance.items?.map((e) => e.toJson()).toList(),
    };

ApiReceiptItem _$ApiReceiptItemFromJson(Map<String, dynamic> json) =>
    ApiReceiptItem(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      isChecked: json['is_checked'] as bool?,
      barcode: json['barcode'] as String?,
    );

Map<String, dynamic> _$ApiReceiptItemToJson(ApiReceiptItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'is_checked': instance.isChecked,
      'barcode': instance.barcode,
    };
