// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryItem _$InventoryItemFromJson(Map<String, dynamic> json) =>
    InventoryItem(
      id: json['id'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      category: json['category'] as String? ?? 'other',
      location: json['location'] as String? ?? 'other',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unit: json['unit'] as String? ?? "יח'",
      minQuantity: (json['min_quantity'] as num?)?.toInt() ?? 2,
      expiryDate:
          const NullableTimestampConverter().fromJson(json['expiry_date']),
      notes: json['notes'] as String?,
      isRecurring: json['is_recurring'] as bool? ?? false,
      lastPurchased:
          const NullableTimestampConverter().fromJson(json['last_purchased']),
      purchaseCount: (json['purchase_count'] as num?)?.toInt() ?? 0,
      emoji: _readEmoji(json, 'emoji') as String?,
      updatedAt:
          const NullableTimestampConverter().fromJson(json['updated_at']),
      lastUpdatedBy: json['last_updated_by'] as String?,
    );

Map<String, dynamic> _$InventoryItemToJson(InventoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_name': instance.productName,
      'category': instance.category,
      'location': instance.location,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'min_quantity': instance.minQuantity,
      'expiry_date':
          const NullableTimestampConverter().toJson(instance.expiryDate),
      'notes': instance.notes,
      'is_recurring': instance.isRecurring,
      'last_purchased':
          const NullableTimestampConverter().toJson(instance.lastPurchased),
      'purchase_count': instance.purchaseCount,
      'emoji': instance.emoji,
      'updated_at':
          const NullableTimestampConverter().toJson(instance.updatedAt),
      'last_updated_by': instance.lastUpdatedBy,
    };
