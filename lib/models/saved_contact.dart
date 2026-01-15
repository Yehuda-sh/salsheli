// 📄 File: lib/models/saved_contact.dart
//
// 🎯 Purpose: מודל לאיש קשר שמור לשיתוף רשימות
//
// 📋 Features:
// - שמירת פרטי משתמשים שהוזמנו בעבר
// - גישה מהירה להזמנה חוזרת
// - תמיכה ב-JSON serialization (Timestamp ל-Firestore)
// - תאימות לאחור (camelCase + snake_case)
//
// 🔗 Related:
// - shared_user.dart - משתמש משותף ברשימה
// - share_list_service.dart - שירות שיתוף
// - timestamp_converter.dart - Converters מרכזיים
//
// Version: 1.2 - Backward compat, nullable lastInvitedAt, emoji-safe initials
// Last Updated: 13/01/2026

import 'package:flutter/foundation.dart' show immutable;
import 'package:json_annotation/json_annotation.dart';

import 'timestamp_converter.dart'
    show FlexibleDateTimeConverter, NullableFlexibleDateTimeConverter;

part 'saved_contact.g.dart';

// ---- JSON Read Helpers (backward compatibility) ----

/// 🔧 קורא userId עם תמיכה ב-camelCase וגם snake_case
Object? _readUserId(Map<dynamic, dynamic> json, String key) =>
    json['user_id'] ?? json['userId'];

/// 🔧 קורא userName עם תמיכה ב-camelCase וגם snake_case
Object? _readUserName(Map<dynamic, dynamic> json, String key) =>
    json['user_name'] ?? json['userName'];

/// 🔧 קורא userEmail עם תמיכה ב-camelCase וגם snake_case
Object? _readUserEmail(Map<dynamic, dynamic> json, String key) =>
    json['user_email'] ?? json['userEmail'];

/// 🔧 קורא userPhone עם תמיכה ב-camelCase וגם snake_case
Object? _readUserPhone(Map<dynamic, dynamic> json, String key) =>
    json['user_phone'] ?? json['userPhone'];

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

/// 🔧 קורא addedAt עם תמיכה ב-camelCase וגם snake_case
Object? _readAddedAt(Map<dynamic, dynamic> json, String key) =>
    json['added_at'] ?? json['addedAt'];

/// 🔧 קורא lastInvitedAt עם תמיכה ב-camelCase וגם snake_case
Object? _readLastInvitedAt(Map<dynamic, dynamic> json, String key) =>
    json['last_invited_at'] ?? json['lastInvitedAt'];

/// איש קשר שמור לשיתוף קל של רשימות
///
/// מאפשר למשתמש לשמור אנשי קשר שהוזמנו בעבר
/// ולהזמין אותם בקלות לרשימות חדשות ללא הקלדה חוזרת.
@immutable
@JsonSerializable()
class SavedContact {
  /// מזהה ייחודי של איש הקשר (userId של המשתמש המוזמן)
  /// 🔄 readValue: תמיכה ב-user_id וגם userId (תאימות לאחור)
  @JsonKey(name: 'user_id', readValue: _readUserId)
  final String userId;

  /// שם המשתמש
  /// 🔄 readValue: תמיכה ב-user_name וגם userName (תאימות לאחור)
  @JsonKey(name: 'user_name', readValue: _readUserName)
  final String? userName;

  /// אימייל המשתמש
  /// 🔄 readValue: תמיכה ב-user_email וגם userEmail (תאימות לאחור)
  @JsonKey(name: 'user_email', readValue: _readUserEmail)
  final String userEmail;

  /// טלפון המשתמש
  /// 🔄 readValue: תמיכה ב-user_phone וגם userPhone (תאימות לאחור)
  @JsonKey(name: 'user_phone', readValue: _readUserPhone)
  final String? userPhone;

  /// אווטאר המשתמש
  /// 🔄 readValue: תמיכה ב-user_avatar, avatar_url וגם userAvatar (אחידות פרויקט)
  @JsonKey(name: 'user_avatar', readValue: _readUserAvatar)
  final String? userAvatar;

  /// מתי נוסף לאנשי הקשר
  /// 🔄 readValue: תמיכה ב-added_at וגם addedAt (תאימות לאחור)
  @FlexibleDateTimeConverter()
  @JsonKey(name: 'added_at', readValue: _readAddedAt)
  final DateTime addedAt;

  /// מתי הוזמן לאחרונה (לצורך מיון)
  /// 📌 nullable - נתונים ישנים אולי לא יכילו את השדה הזה
  /// 🔄 readValue: תמיכה ב-last_invited_at וגם lastInvitedAt (תאימות לאחור)
  @NullableFlexibleDateTimeConverter()
  @JsonKey(name: 'last_invited_at', readValue: _readLastInvitedAt)
  final DateTime? lastInvitedAt;

  const SavedContact({
    required this.userId,
    this.userName,
    required this.userEmail,
    this.userPhone,
    this.userAvatar,
    required this.addedAt,
    this.lastInvitedAt,
  });

  /// יצירת איש קשר חדש מפרטי משתמש
  factory SavedContact.fromUserDetails({
    required String userId,
    String? userName,
    required String userEmail,
    String? userPhone,
    String? userAvatar,
  }) {
    final now = DateTime.now();
    return SavedContact(
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
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

  /// 🔧 תאריך הזמנה אחרונה (עם fallback ל-addedAt)
  /// 🇬🇧 Effective last invited date (falls back to addedAt if null)
  ///
  /// שימושי למיון - נתונים ישנים אולי לא יכילו lastInvitedAt
  DateTime get effectiveLastInvitedAt => lastInvitedAt ?? addedAt;

  /// ראשי תיבות לאווטאר
  ///
  /// 🔧 תומך בשמות עבריים, מקפים, רווחים כפולים ואמוג׳י
  /// משתמש ב-runes לטיפול בטוח בתווים מיוחדים
  String get initials {
    if (userName != null && userName!.isNotEmpty) {
      // נקה רווחים מיותרים ופצל לפי רווח או מקף
      final cleaned = userName!.trim().replaceAll(RegExp(r'\s+'), ' ');
      final parts =
          cleaned.split(RegExp(r'[\s\-]+')).where((p) => p.isNotEmpty).toList();
      if (parts.length >= 2) {
        return '${_firstChar(parts[0])}${_firstChar(parts[1])}'.toUpperCase();
      }
      if (parts.isNotEmpty && parts[0].isNotEmpty) {
        return _firstChar(parts[0]).toUpperCase();
      }
    }
    if (userEmail.isNotEmpty) {
      return _firstChar(userEmail).toUpperCase();
    }
    return '?';
  }

  /// 🔧 מחלץ תו ראשון בצורה בטוחה (תומך באמוג׳י)
  static String _firstChar(String s) {
    if (s.isEmpty) return '';
    // runes מחזיר Unicode code points - בטוח יותר מ-[0]
    return String.fromCharCode(s.runes.first);
  }

  /// Copy with
  SavedContact copyWith({
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? userAvatar,
    DateTime? addedAt,
    DateTime? lastInvitedAt,
  }) {
    return SavedContact(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
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
