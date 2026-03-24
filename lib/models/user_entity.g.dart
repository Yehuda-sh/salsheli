// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserEntity _$UserEntityFromJson(Map<String, dynamic> json) => UserEntity(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: _readPhone(json, 'phone') as String?,
      householdId: _readHouseholdId(json, 'household_id') as String? ?? '',
      joinedAt: const FlexibleDateTimeConverter()
          .fromJson(_readJoinedAt(json, 'joined_at')),
      lastLoginAt: const NullableFlexibleDateTimeConverter()
          .fromJson(_readLastLoginAt(json, 'last_login_at')),
      profileImageUrl:
          _readProfileImageUrl(json, 'profile_image_url') as String?,
      favoriteProducts: (json['favorite_products'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      weeklyBudget: _readWeeklyBudget(json, 'weekly_budget') == null
          ? 0.0
          : const FlexDoubleConverter()
              .fromJson(_readWeeklyBudget(json, 'weekly_budget')),
      isAdmin: json['is_admin'] as bool? ?? false,
      seenOnboarding: json['seen_onboarding'] as bool? ?? false,
      seenTutorial: json['seen_tutorial'] as bool? ?? false,
      householdName: _readHouseholdName(json, 'household_name') as String?,
    );

Map<String, dynamic> _$UserEntityToJson(UserEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'household_id': instance.householdId,
      'household_name': instance.householdName,
      'profile_image_url': instance.profileImageUrl,
      'joined_at': const FlexibleDateTimeConverter().toJson(instance.joinedAt),
      'last_login_at': const NullableFlexibleDateTimeConverter()
          .toJson(instance.lastLoginAt),
      'favorite_products': instance.favoriteProducts,
      'weekly_budget':
          const FlexDoubleConverter().toJson(instance.weeklyBudget),
      'is_admin': instance.isAdmin,
      'seen_onboarding': instance.seenOnboarding,
      'seen_tutorial': instance.seenTutorial,
    };
