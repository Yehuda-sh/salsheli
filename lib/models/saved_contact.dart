// 📄 File: lib/models/saved_contact.dart
//
// 🎯 Purpose: מודל לאיש קשר שמור לשיתוף רשימות
//
// 📋 Features:
// - שמירת פרטי משתמשים שהוזמנו בעבר
// - גישה מהירה להזמנה חוזרת
// - תמיכה ב-JSON serialization
//
// 🔗 Related:
// - shared_user.dart - משתמש משותף ברשימה
// - share_list_service.dart - שירות שיתוף
//
// Version: 1.0
// Created: 30/11/2025

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'saved_contact.g.dart';

/// Converter that handles both Timestamp and String for DateTime
class _FlexibleDateTimeConverter implements JsonConverter<DateTime, dynamic> {
  const _FlexibleDateTimeConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) {
      return json.toDate();
    } else if (json is String) {
      return DateTime.parse(json);
    } else if (json is DateTime) {
      return json;
    }
    throw ArgumentError('Cannot convert $json to DateTime');
  }

  @override
  dynamic toJson(DateTime object) => object.toIso8601String();
}

/// איש קשר שמור לשיתוף קל של רשימות
///
/// מאפשר למשתמש לשמור אנשי קשר שהוזמנו בעבר
/// ולהזמין אותם בקלות לרשימות חדשות ללא הקלדה חוזרת.
@JsonSerializable()
class SavedContact {
  /// מזהה ייחודי של איש הקשר (userId של המשתמש המוזמן)
  @JsonKey(name: 'user_id')
  final String userId;

  /// שם המשתמש
  @JsonKey(name: 'user_name')
  final String? userName;

  /// אימייל המשתמש
  @JsonKey(name: 'user_email')
  final String userEmail;

  /// אווטאר המשתמש
  @JsonKey(name: 'user_avatar')
  final String? userAvatar;

  /// מתי נוסף לאנשי הקשר
  @_FlexibleDateTimeConverter()
  @JsonKey(name: 'added_at')
  final DateTime addedAt;

  /// מתי הוזמן לאחרונה (לצורך מיון)
  @_FlexibleDateTimeConverter()
  @JsonKey(name: 'last_invited_at')
  final DateTime lastInvitedAt;

  const SavedContact({
    required this.userId,
    this.userName,
    required this.userEmail,
    this.userAvatar,
    required this.addedAt,
    required this.lastInvitedAt,
  });

  /// יצירת איש קשר חדש מפרטי משתמש
  factory SavedContact.fromUserDetails({
    required String userId,
    String? userName,
    required String userEmail,
    String? userAvatar,
  }) {
    final now = DateTime.now();
    return SavedContact(
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userAvatar: userAvatar,
      addedAt: now,
      lastInvitedAt: now,
    );
  }

  /// JSON serialization
  factory SavedContact.fromJson(Map<String, dynamic> json) =>
      _$SavedContactFromJson(json);

  Map<String, dynamic> toJson() => _$SavedContactToJson(this);

  /// שם לתצוגה - שם או אימייל אם אין שם
  String get displayName => userName ?? userEmail;

  /// ראשי תיבות לאווטאר
  String get initials {
    if (userName != null && userName!.isNotEmpty) {
      final parts = userName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return userName![0].toUpperCase();
    }
    return userEmail[0].toUpperCase();
  }

  /// Copy with
  SavedContact copyWith({
    String? userId,
    String? userName,
    String? userEmail,
    String? userAvatar,
    DateTime? addedAt,
    DateTime? lastInvitedAt,
  }) {
    return SavedContact(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userAvatar: userAvatar ?? this.userAvatar,
      addedAt: addedAt ?? this.addedAt,
      lastInvitedAt: lastInvitedAt ?? this.lastInvitedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavedContact && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'SavedContact(userId: $userId, userName: $userName, userEmail: $userEmail)';
  }
}
