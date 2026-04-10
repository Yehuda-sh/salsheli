// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_suggestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SmartSuggestion _$SmartSuggestionFromJson(Map<String, dynamic> json) =>
    SmartSuggestion(
      id: json['id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      barcode: json['barcode'] as String? ?? '',
      category: json['category'] as String? ?? 'other',
      currentStock: (json['current_stock'] as num?)?.toInt() ?? 0,
      threshold: (json['threshold'] as num?)?.toInt() ?? 5,
      quantityNeeded: (json['quantity_needed'] as num?)?.toInt() ?? 1,
      unit: json['unit'] as String? ?? "יח'",
      status: $enumDecodeNullable(_$SuggestionStatusEnumMap, json['status'],
              unknownValue: SuggestionStatus.unknown) ??
          SuggestionStatus.pending,
      suggestedAt:
          const FlexibleDateTimeConverter().fromJson(json['suggested_at']),
      dismissedUntil: const NullableFlexibleDateTimeConverter()
          .fromJson(json['dismissed_until']),
      addedAt:
          const NullableFlexibleDateTimeConverter().fromJson(json['added_at']),
      addedToListId: json['added_to_list_id'] as String?,
    );

Map<String, dynamic> _$SmartSuggestionToJson(SmartSuggestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'product_name': instance.productName,
      'barcode': instance.barcode,
      'category': instance.category,
      'current_stock': instance.currentStock,
      'threshold': instance.threshold,
      'quantity_needed': instance.quantityNeeded,
      'unit': instance.unit,
      'status': _$SuggestionStatusEnumMap[instance.status]!,
      'suggested_at':
          const FlexibleDateTimeConverter().toJson(instance.suggestedAt),
      'dismissed_until': const NullableFlexibleDateTimeConverter()
          .toJson(instance.dismissedUntil),
      'added_at':
          const NullableFlexibleDateTimeConverter().toJson(instance.addedAt),
      'added_to_list_id': instance.addedToListId,
    };

const _$SuggestionStatusEnumMap = {
  SuggestionStatus.pending: 'pending',
  SuggestionStatus.added: 'added',
  SuggestionStatus.dismissed: 'dismissed',
  SuggestionStatus.deleted: 'deleted',
  SuggestionStatus.unknown: 'unknown',
};
