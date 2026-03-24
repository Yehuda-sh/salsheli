// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharedUser _$SharedUserFromJson(Map<String, dynamic> json) => SharedUser(
      role: $enumDecode(_$UserRoleEnumMap, json['role'],
          unknownValue: UserRole.unknown),
      sharedAt: const FlexibleDateTimeConverter()
          .fromJson(_readSharedAt(json, 'shared_at')),
      userName: _readUserName(json, 'user_name') as String?,
      userEmail: _readUserEmail(json, 'user_email') as String?,
      userAvatar: _readUserAvatar(json, 'user_avatar') as String?,
      canStartShopping:
          _readCanStartShopping(json, 'can_start_shopping') as bool? ?? false,
    );

Map<String, dynamic> _$SharedUserToJson(SharedUser instance) =>
    <String, dynamic>{
      'role': _$UserRoleEnumMap[instance.role]!,
      'shared_at': const FlexibleDateTimeConverter().toJson(instance.sharedAt),
      'user_name': instance.userName,
      'user_email': instance.userEmail,
      'user_avatar': instance.userAvatar,
      'can_start_shopping': instance.canStartShopping,
    };

const _$UserRoleEnumMap = {
  UserRole.owner: 'owner',
  UserRole.admin: 'admin',
  UserRole.editor: 'editor',
  UserRole.viewer: 'viewer',
  UserRole.unknown: 'unknown',
};
