// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_shopper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActiveShopper _$ActiveShopperFromJson(Map<String, dynamic> json) =>
    ActiveShopper(
      userId: _readUserId(json, 'user_id') as String? ?? '',
      joinedAt: const TimestampConverter()
          .fromJson(_readJoinedAt(json, 'joined_at') as Object),
      isStarter: _readIsStarter(json, 'is_starter') as bool? ?? false,
      isActive: _readIsActive(json, 'is_active') as bool? ?? true,
    );

Map<String, dynamic> _$ActiveShopperToJson(ActiveShopper instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'joined_at': const TimestampConverter().toJson(instance.joinedAt),
      'is_starter': instance.isStarter,
      'is_active': instance.isActive,
    };
