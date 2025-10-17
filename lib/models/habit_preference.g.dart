// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_preference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HabitPreference _$HabitPreferenceFromJson(Map<String, dynamic> json) =>
    HabitPreference(
      id: json['id'] as String,
      preferredProduct: json['preferred_product'] as String,
      genericName: json['generic_name'] as String,
      frequencyDays: (json['frequency_days'] as num).toInt(),
      lastPurchased: const TimestampConverter().fromJson(
        json['last_purchased'] as Object,
      ),
      createdDate: const TimestampConverter().fromJson(
        json['created_date'] as Object,
      ),
      updatedDate: const TimestampConverter().fromJson(
        json['updated_date'] as Object,
      ),
    );

Map<String, dynamic> _$HabitPreferenceToJson(
  HabitPreference instance,
) => <String, dynamic>{
  'id': instance.id,
  'preferred_product': instance.preferredProduct,
  'generic_name': instance.genericName,
  'frequency_days': instance.frequencyDays,
  'last_purchased': const TimestampConverter().toJson(instance.lastPurchased),
  'created_date': const TimestampConverter().toJson(instance.createdDate),
  'updated_date': const TimestampConverter().toJson(instance.updatedDate),
};
