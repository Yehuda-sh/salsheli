// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomLocation _$CustomLocationFromJson(Map<String, dynamic> json) =>
    CustomLocation(
      key: json['key'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String? ?? "📍",
    );

Map<String, dynamic> _$CustomLocationToJson(CustomLocation instance) =>
    <String, dynamic>{
      'key': instance.key,
      'name': instance.name,
      'emoji': instance.emoji,
    };
