// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomLocation _$CustomLocationFromJson(Map<String, dynamic> json) =>
    CustomLocation(
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
      emoji: _readEmoji(json, 'emoji') as String? ?? '📍',
      createdBy: json['createdBy'] as String?,
    );

Map<String, dynamic> _$CustomLocationToJson(CustomLocation instance) {
  final val = <String, dynamic>{
    'key': instance.key,
    'name': instance.name,
    'emoji': instance.emoji,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('createdBy', instance.createdBy);
  return val;
}
