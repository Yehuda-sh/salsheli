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
      profileImageUrl: json['profile_image_url'] as String?,
      preferredStores: (json['preferred_stores'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      favoriteProducts: (json['favorite_products'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      weeklyBudget: (json['weekly_budget'] as num?)?.toDouble() ?? 0.0,
      isAdmin: json['is_admin'] as bool? ?? false,
    );

Map<String, dynamic> _$UserEntityToJson(UserEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'household_id': instance.householdId,
      'profile_image_url': instance.profileImageUrl,
      'joined_at': instance.joinedAt.toIso8601String(),
      'last_login_at': instance.lastLoginAt?.toIso8601String(),
      'preferred_stores': instance.preferredStores,
      'favorite_products': instance.favoriteProducts,
      'weekly_budget': instance.weeklyBudget,
      'is_admin': instance.isAdmin,
    };
