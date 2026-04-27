// lib/models/shared_user.dart — Shared user model — user role in a shared list (owner/admin/editor/viewer)

import 'package:flutter/foundation.dart' show immutable;
import 'package:json_annotation/json_annotation.dart';

import 'enums/user_role.dart';
import 'timestamp_converter.dart' show FlexibleDateTimeConverter;

part 'shared_user.g.dart';

// ---- JSON Read Helpers (backward compatibility) ----

/// 🔧 קורא sharedAt עם תמיכה ב-camelCase וגם snake_case
Object? _readSharedAt(Map<dynamic, dynamic> json, String key) =>
    json['shared_at'] ?? json['sharedAt'];

/// 🔧 קורא userName עם תמיכה ב-camelCase וגם snake_case
Object? _readUserName(Map<dynamic, dynamic> json, String key) =>
    json['user_name'] ?? json['userName'];

/// 🔧 קורא userEmail עם תמיכה ב-camelCase וגם snake_case
Object? _readUserEmail(Map<dynamic, dynamic> json, String key) =>
    json['user_email'] ?? json['userEmail'];

/// 🔧 קורא userAvatar עם תמיכה ב-user_avatar, avatar_url וגם userAvatar
/// 📌 מתייחס ל-"" ו-"  " כ-null כדי לא לחסום fallback
Object? _readUserAvatar(Map<dynamic, dynamic> json, String key) {
  final userAvatar = json['user_avatar'];
  if (userAvatar != null && userAvatar is String && userAvatar.trim().isNotEmpty) {
    return userAvatar;
  }

  final avatarUrl = json['avatar_url'];
  if (avatarUrl != null && avatarUrl is String && avatarUrl.trim().isNotEmpty) {
    return avatarUrl;
  }

  final camelCase = json['userAvatar'];
  if (camelCase != null && camelCase is String && camelCase.trim().isNotEmpty) {
    return camelCase;
  }

  return null;
}

/// 🔧 קורא canStartShopping עם תמיכה ב-camelCase וגם snake_case
Object? _readCanStartShopping(Map<dynamic, dynamic> json, String key) =>
    json['can_start_shopping'] ?? json['canStartShopping'];

/// משתמש משותף ברשימה
///
/// במבנה Map החדש, ה-userId הוא המפתח במפה (לא חלק מהאובייקט).
/// הערך במפה מכיל: role, sharedAt, ומטאדאטה (cache).
///
/// מבנה ב-Firestore:
/// ```json
/// "shared_users": {
///   "user123": { "role": "admin", "shared_at": ..., "user_name": "יוני" },
///   "user456": { "role": "viewer", "shared_at": ..., "user_name": "דנה" }
/// }
/// ```
@immutable
@JsonSerializable()
class SharedUser {
  static const _sentinel = Object();

  /// מזהה המשתמש (המפתח במפה - לא נשמר ב-JSON של הערך)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String userId;

  /// תפקיד המשתמש ברשימה
  /// ✅ unknownEnumValue: מונע קריסה אם מגיע ערך לא מוכר מהשרת
  @JsonKey(unknownEnumValue: UserRole.unknown)
  final UserRole role;

  /// מתי שותף
  /// 🔄 readValue: תמיכה ב-shared_at וגם sharedAt (תאימות לאחור)
  @FlexibleDateTimeConverter()
  @JsonKey(name: 'shared_at', readValue: _readSharedAt)
  final DateTime sharedAt;

  // === מטאדאטה (cache) ===

  /// שם המשתמש (cache)
  /// 🔄 readValue: תמיכה ב-user_name וגם userName (תאימות לאחור)
  @JsonKey(name: 'user_name', readValue: _readUserName)
  final String? userName;

  /// אימייל המשתמש (cache)
  /// 🔄 readValue: תמיכה ב-user_email וגם userEmail (תאימות לאחור)
  @JsonKey(name: 'user_email', readValue: _readUserEmail)
  final String? userEmail;

  /// אווטאר המשתמש (cache)
  /// 🔄 readValue: תמיכה ב-user_avatar, avatar_url וגם userAvatar (אחידות פרויקט)
  @JsonKey(name: 'user_avatar', readValue: _readUserAvatar)
  final String? userAvatar;

  /// 🆕 האם יכול להתחיל קנייה (ניתן ע"י owner/admin)
  /// 🇬🇧 Can start shopping (granted by owner/admin)
  ///
  /// ברירת מחדל: false - רק owner/admin יכולים להתחיל קנייה.
  /// כשמופעל: גם editor יכול להתחיל קנייה ברשימה זו.
  /// 🔄 readValue: תמיכה ב-can_start_shopping וגם canStartShopping
  @JsonKey(name: 'can_start_shopping', defaultValue: false, readValue: _readCanStartShopping)
  final bool canStartShopping;

  const SharedUser({
    this.userId = '', // Will be set from Map key via copyWith
    required this.role,
    required this.sharedAt,
    this.userName,
    this.userEmail,
    this.userAvatar,
    this.canStartShopping = false,
  });

  /// JSON serialization (for Map value - without userId)
  factory SharedUser.fromJson(Map<String, dynamic> json) => _$SharedUserFromJson(json);

  Map<String, dynamic> toJson() => _$SharedUserToJson(this);

  /// Copy with
  SharedUser copyWith({
    String? userId,
    UserRole? role,
    DateTime? sharedAt,
    Object? userName = _sentinel,
    Object? userEmail = _sentinel,
    Object? userAvatar = _sentinel,
    bool? canStartShopping,
  }) {
    return SharedUser(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      sharedAt: sharedAt ?? this.sharedAt,
      userName: userName == _sentinel ? this.userName : userName as String?,
      userEmail: userEmail == _sentinel ? this.userEmail : userEmail as String?,
      userAvatar: userAvatar == _sentinel ? this.userAvatar : userAvatar as String?,
      canStartShopping: canStartShopping ?? this.canStartShopping,
    );
  }

  // === Equality ===
  // 🔧 שוויון לפי userId בלבד - אותו משתמש נחשב זהה גם אם role או sharedAt שונים.
  // זה מאפשר שימוש נכון ב-Set/Map ומניעת כפילויות.

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SharedUser && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'SharedUser(userId: $userId, role: $role, userName: $userName)';
  }
}
