// 📄 File: lib/models/shared_user.dart
//
// 🇮🇱 מודל למשתמש משותף ברשימה:
//     - מייצג משתמש שיש לו גישה לרשימת קניות משותפת
//     - כולל תפקיד (owner/admin/editor/viewer)
//     - תומך במבנה Map (userId כמפתח) לגישה מהירה ב-Firestore
//     - מכיל מטאדאטה (cache) של שם/אימייל/אווטאר
//
// 🇬🇧 Model for shared list user:
//     - Represents a user with access to a shared shopping list
//     - Includes role (owner/admin/editor/viewer)
//     - Supports Map structure (userId as key) for fast Firestore access
//     - Contains metadata (cache) for name/email/avatar
//
// 🏗️ Firestore Structure:
//     shared_users: {
//       "user123": { role: "admin", shared_at: Timestamp, user_name: "יוני" },
//       "user456": { role: "viewer", shared_at: Timestamp, user_name: "דנה" }
//     }
//
// Version: 1.1 - Safe casting, userId validation, equality fix, permission helpers
// Last Updated: 30/12/2025

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'enums/user_role.dart';

part 'shared_user.g.dart';

/// Converter that handles both Timestamp and String for DateTime
///
/// 🔧 **חשוב:** toJson מחזיר Timestamp לשמירה ב-Firestore (לא String).
/// זה מאפשר מיון ופילטרים נכונים לפי תאריך.
class FlexibleDateTimeConverter implements JsonConverter<DateTime, dynamic> {
  const FlexibleDateTimeConverter();

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

  /// 🔧 מחזיר Timestamp עבור Firestore (לא ISO String)
  @override
  dynamic toJson(DateTime object) => Timestamp.fromDate(object);
}

/// 🔧 Nullable version of FlexibleDateTimeConverter
///
/// לשימוש עם שדות DateTime אופציונליים כמו reviewedAt
class NullableFlexibleDateTimeConverter implements JsonConverter<DateTime?, dynamic> {
  const NullableFlexibleDateTimeConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) {
      return json.toDate();
    } else if (json is String) {
      return DateTime.parse(json);
    } else if (json is DateTime) {
      return json;
    }
    return null; // לא זורק - פשוט מחזיר null
  }

  @override
  dynamic toJson(DateTime? object) => object != null ? Timestamp.fromDate(object) : null;
}

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
@JsonSerializable()
class SharedUser {
  /// מזהה המשתמש (המפתח במפה - לא נשמר ב-JSON של הערך)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String userId;

  /// תפקיד המשתמש ברשימה
  final UserRole role;

  /// מתי שותף
  @FlexibleDateTimeConverter()
  @JsonKey(name: 'shared_at')
  final DateTime sharedAt;

  // === מטאדאטה (cache) ===

  /// שם המשתמש (cache)
  @JsonKey(name: 'user_name')
  final String? userName;

  /// אימייל המשתמש (cache)
  @JsonKey(name: 'user_email')
  final String? userEmail;

  /// אווטאר המשתמש (cache)
  @JsonKey(name: 'user_avatar')
  final String? userAvatar;

  /// 🆕 האם יכול להתחיל קנייה (ניתן ע"י owner/admin)
  /// 🇬🇧 Can start shopping (granted by owner/admin)
  ///
  /// ברירת מחדל: false - רק owner/admin יכולים להתחיל קנייה.
  /// כשמופעל: גם editor יכול להתחיל קנייה ברשימה זו.
  @JsonKey(name: 'can_start_shopping', defaultValue: false)
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

  /// יצירה מ-Map entry (userId הוא המפתח)
  ///
  /// 🔧 ממיר בבטחה מ-Map<dynamic, dynamic> ל-Map<String, dynamic>
  /// כדי לתמוך בנתונים מ-Firestore שיכולים להגיע עם טיפוסים שונים.
  ///
  /// Example:
  /// ```dart
  /// final entry = MapEntry('user123', {'role': 'admin', 'shared_at': ...});
  /// final user = SharedUser.fromMapEntry(entry);
  /// ```
  factory SharedUser.fromMapEntry(MapEntry<String, dynamic> entry) {
    // 🔧 המרה בטוחה - entry.value יכול להיות Map<dynamic, dynamic> מ-Firestore
    final rawValue = entry.value;
    final Map<String, dynamic> json;
    if (rawValue is Map<String, dynamic>) {
      json = rawValue;
    } else if (rawValue is Map) {
      json = Map<String, dynamic>.from(
        rawValue.map((k, v) => MapEntry(k.toString(), v)),
      );
    } else {
      throw ArgumentError('Cannot convert ${rawValue.runtimeType} to Map<String, dynamic>');
    }
    final user = SharedUser.fromJson(json);
    return user.copyWith(userId: entry.key);
  }

  /// המרה ל-Map entry (userId הופך למפתח)
  ///
  /// ⚠️ זורק AssertionError אם userId ריק - חייב להיות מוגדר לפני שמירה.
  ///
  /// Example:
  /// ```dart
  /// final entry = sharedUser.toMapEntry();
  /// // entry.key = 'user123'
  /// // entry.value = {'role': 'admin', 'shared_at': ...}
  /// ```
  MapEntry<String, Map<String, dynamic>> toMapEntry() {
    assert(userId.isNotEmpty, 'userId cannot be empty when converting to MapEntry');
    return MapEntry(userId, toJson());
  }

  /// Copy with
  SharedUser copyWith({
    String? userId,
    UserRole? role,
    DateTime? sharedAt,
    String? userName,
    String? userEmail,
    String? userAvatar,
    bool? canStartShopping,
  }) {
    return SharedUser(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      sharedAt: sharedAt ?? this.sharedAt,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userAvatar: userAvatar ?? this.userAvatar,
      canStartShopping: canStartShopping ?? this.canStartShopping,
    );
  }

  // === Permission Helpers ===
  // 🔧 קיצורים נוחים להרשאות - מבוססים על ה-role

  /// האם הוא הבעלים של הרשימה
  bool get isOwner => role == UserRole.owner;

  /// האם יכול לערוך פריטים (owner/admin/editor)
  bool get canEdit => role == UserRole.owner || role == UserRole.admin || role == UserRole.editor;

  /// האם יכול לשתף/לנהל משתמשים (owner/admin)
  bool get canShare => role == UserRole.owner || role == UserRole.admin;

  /// האם יכול לבצע פעולות ישירות ללא אישור (owner/admin)
  bool get canActDirectly => role.canAddDirectly;

  /// האם רק צופה (viewer)
  bool get isViewerOnly => role == UserRole.viewer;

  /// 🆕 האם יכול להתחיל קנייה
  /// 🇬🇧 Can this user start shopping
  ///
  /// owner/admin - תמיד יכולים
  /// editor - רק אם canStartShopping מופעל
  /// viewer - לעולם לא
  bool get canShop => role == UserRole.owner || role == UserRole.admin || (role == UserRole.editor && canStartShopping);

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
