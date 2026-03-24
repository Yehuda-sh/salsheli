// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SavedContact _$SavedContactFromJson(Map<String, dynamic> json) => SavedContact(
      userId: _readUserId(json, 'user_id') as String? ?? '',
      userName: _readUserName(json, 'user_name') as String?,
      userEmail: _readUserEmail(json, 'user_email') as String? ?? '',
      userPhone: _readUserPhone(json, 'user_phone') as String?,
      userAvatar: _readUserAvatar(json, 'user_avatar') as String?,
      addedAt: const FlexibleDateTimeConverter()
          .fromJson(_readAddedAt(json, 'added_at')),
      lastInvitedAt: const NullableFlexibleDateTimeConverter()
          .fromJson(_readLastInvitedAt(json, 'last_invited_at')),
    );

Map<String, dynamic> _$SavedContactToJson(SavedContact instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'user_name': instance.userName,
      'user_email': instance.userEmail,
      'user_phone': instance.userPhone,
      'user_avatar': instance.userAvatar,
      'added_at': const FlexibleDateTimeConverter().toJson(instance.addedAt),
      'last_invited_at': const NullableFlexibleDateTimeConverter()
          .toJson(instance.lastInvitedAt),
    };
