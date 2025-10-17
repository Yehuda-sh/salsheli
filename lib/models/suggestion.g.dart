// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Suggestion _$SuggestionFromJson(Map<String, dynamic> json) => Suggestion(
  id: json['id'] as String,
  productName: json['product_name'] as String,
  reason: json['reason'] as String? ?? 'frequently_bought',
  category: json['category'] as String? ?? 'כללי',
  suggestedQuantity: (json['suggested_quantity'] as num?)?.toInt() ?? 1,
  unit: json['unit'] as String? ?? 'יחידות',
  priority: json['priority'] as String? ?? 'medium',
  source: json['source'] as String? ?? 'inventory',
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$SuggestionToJson(Suggestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_name': instance.productName,
      'reason': instance.reason,
      'category': instance.category,
      'suggested_quantity': instance.suggestedQuantity,
      'unit': instance.unit,
      'priority': instance.priority,
      'source': instance.source,
      'created_at': instance.createdAt.toIso8601String(),
    };
