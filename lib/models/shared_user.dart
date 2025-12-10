import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'enums/user_role.dart';

part 'shared_user.g.dart';

/// Converter that handles both Timestamp and String for DateTime
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

  @override
  dynamic toJson(DateTime object) => object.toIso8601String();
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

  const SharedUser({
    this.userId = '', // Will be set from Map key via copyWith
    required this.role,
    required this.sharedAt,
    this.userName,
    this.userEmail,
    this.userAvatar,
  });

  /// JSON serialization (for Map value - without userId)
  factory SharedUser.fromJson(Map<String, dynamic> json) =>
      _$SharedUserFromJson(json);

  Map<String, dynamic> toJson() => _$SharedUserToJson(this);

  /// יצירה מ-Map entry (userId הוא המפתח)
  ///
  /// Example:
  /// ```dart
  /// final entry = MapEntry('user123', {'role': 'admin', 'shared_at': ...});
  /// final user = SharedUser.fromMapEntry(entry);
  /// ```
  factory SharedUser.fromMapEntry(MapEntry<String, dynamic> entry) {
    final json = Map<String, dynamic>.from(entry.value as Map);
    final user = SharedUser.fromJson(json);
    return user.copyWith(userId: entry.key);
  }

  /// המרה ל-Map entry (userId הופך למפתח)
  ///
  /// Example:
  /// ```dart
  /// final entry = sharedUser.toMapEntry();
  /// // entry.key = 'user123'
  /// // entry.value = {'role': 'admin', 'shared_at': ...}
  /// ```
  MapEntry<String, Map<String, dynamic>> toMapEntry() {
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
  }) {
    return SharedUser(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      sharedAt: sharedAt ?? this.sharedAt,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userAvatar: userAvatar ?? this.userAvatar,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SharedUser &&
        other.userId == userId &&
        other.role == role &&
        other.sharedAt == sharedAt;
  }

  @override
  int get hashCode => userId.hashCode ^ role.hashCode ^ sharedAt.hashCode;

  @override
  String toString() {
    return 'SharedUser(userId: $userId, role: $role, userName: $userName)';
  }
}
