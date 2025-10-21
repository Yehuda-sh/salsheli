// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Receipt _$ReceiptFromJson(Map<String, dynamic> json) => Receipt(
  id: json['id'] as String? ?? '',
  storeName: json['store_name'] as String? ?? 'חנות ללא שם',
  date: const IsoDateTimeConverter().fromJson(json['date'] as String),
  createdDate: const IsoDateTimeNullableConverter().fromJson(
    json['created_date'] as String?,
  ),
  totalAmount: const FlexDoubleConverter().fromJson(json['total_amount']),
  items: (json['items'] as List<dynamic>)
      .map((e) => ReceiptItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  originalUrl: json['original_url'] as String? ?? '',
  fileUrl: json['file_url'] as String? ?? '',
  linkedShoppingListId: json['linked_shopping_list_id'] as String?,
  isVirtual: json['is_virtual'] as bool? ?? false,
  createdBy: json['created_by'] as String?,
  householdId: json['household_id'] as String,
);

Map<String, dynamic> _$ReceiptToJson(Receipt instance) => <String, dynamic>{
  'id': instance.id,
  'store_name': instance.storeName,
  'date': const IsoDateTimeConverter().toJson(instance.date),
  'created_date': const IsoDateTimeNullableConverter().toJson(
    instance.createdDate,
  ),
  'total_amount': const FlexDoubleConverter().toJson(instance.totalAmount),
  'items': instance.items.map((e) => e.toJson()).toList(),
  'original_url': instance.originalUrl,
  'file_url': instance.fileUrl,
  'linked_shopping_list_id': instance.linkedShoppingListId,
  'is_virtual': instance.isVirtual,
  'created_by': instance.createdBy,
  'household_id': instance.householdId,
};

ReceiptItem _$ReceiptItemFromJson(Map<String, dynamic> json) => ReceiptItem(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? '',
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
  unitPrice: json['unit_price'] == null
      ? 0.0
      : const FlexDoubleConverter().fromJson(json['unit_price']),
  isChecked: json['is_checked'] as bool? ?? false,
  barcode: json['barcode'] as String?,
  manufacturer: json['manufacturer'] as String?,
  category: json['category'] as String?,
  unit: json['unit'] as String?,
  checkedBy: json['checked_by'] as String?,
  checkedAt: const IsoDateTimeNullableConverter().fromJson(
    json['checked_at'] as String?,
  ),
);

Map<String, dynamic> _$ReceiptItemToJson(
  ReceiptItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'quantity': instance.quantity,
  'unit_price': const FlexDoubleConverter().toJson(instance.unitPrice),
  'is_checked': instance.isChecked,
  'barcode': instance.barcode,
  'manufacturer': instance.manufacturer,
  'category': instance.category,
  'unit': instance.unit,
  'checked_by': instance.checkedBy,
  'checked_at': const IsoDateTimeNullableConverter().toJson(instance.checkedAt),
};
