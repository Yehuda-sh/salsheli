// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserEntity _$UserEntityFromJson(Map<String, dynamic> json) => UserEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      householdId: json['household_id'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      lastLoginAt: json['last_login_at'] == null
          ? null
          : DateTime.parse(json['last_login_at'] as String),
      profileImageUrl: json['profileImageUrl'] as String?,
      preferredStores: (json['preferredStores'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      favoriteProducts: (json['favoriteProducts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      weeklyBudget: (json['weeklyBudget'] as num?)?.toDouble() ?? 0.0,
      isAdmin: json['isAdmin'] as bool? ?? false,
    );

Map<String, dynamic> _$UserEntityToJson(UserEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'household_id': instance.householdId,
      'profileImageUrl': instance.profileImageUrl,
      'joined_at': instance.joinedAt.toIso8601String(),
      'last_login_at': instance.lastLoginAt?.toIso8601String(),
      'preferredStores': instance.preferredStores,
      'favoriteProducts': instance.favoriteProducts,
      'weeklyBudget': instance.weeklyBudget,
      'isAdmin': instance.isAdmin,
    };
