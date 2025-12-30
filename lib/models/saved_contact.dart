// 📄 File: lib/models/saved_contact.dart
//
// 🎯 Purpose: מודל לאיש קשר שמור לשיתוף רשימות
//
// 📋 Features:
// - שמירת פרטי משתמשים שהוזמנו בעבר
// - גישה מהירה להזמנה חוזרת
// - תמיכה ב-JSON serialization (Timestamp ל-Firestore)
//
// 🔗 Related:
// - shared_user.dart - משתמש משותף ברשימה (משתמש באותו Converter)
// - share_list_service.dart - שירות שיתוף
//
// Version: 1.1 - Use shared FlexibleDateTimeConverter, fix initials
// Last Updated: 30/12/2025

import 'package:json_annotation/json_annotation.dart';

import 'shared_user.dart' show FlexibleDateTimeConverter;

part 'saved_contact.g.dart';

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
  @FlexibleDateTimeConverter()
  @JsonKey(name: 'added_at')
  final DateTime addedAt;

  /// מתי הוזמן לאחרונה (לצורך מיון)
  @FlexibleDateTimeConverter()
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
  ///
  /// 🔧 תומך בשמות עבריים, מקפים, ורווחים כפולים
  String get initials {
    if (userName != null && userName!.isNotEmpty) {
      // נקה רווחים מיותרים ופצל לפי רווח או מקף
      final cleaned = userName!.trim().replaceAll(RegExp(r'\s+'), ' ');
      final parts = cleaned.split(RegExp(r'[\s\-]+')).where((p) => p.isNotEmpty).toList();
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      if (parts.isNotEmpty && parts[0].isNotEmpty) {
        return parts[0][0].toUpperCase();
      }
    }
    if (userEmail.isNotEmpty) {
      return userEmail[0].toUpperCase();
    }
    return '?';
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
