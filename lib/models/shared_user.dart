import 'package:json_annotation/json_annotation.dart';
import 'enums/user_role.dart';

part 'shared_user.g.dart';

/// משתמש משותף ברשימה
@JsonSerializable()
class SharedUser {
  /// מזהה המשתמש
  @JsonKey(name: 'user_id')
  final String userId;

  /// תפקיד המשתמש ברשימה
  final UserRole role;

  /// מתי שותף
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
    required this.userId,
    required this.role,
    required this.sharedAt,
    this.userName,
    this.userEmail,
    this.userAvatar,
  });

  /// JSON serialization
  factory SharedUser.fromJson(Map<String, dynamic> json) =>
      _$SharedUserFromJson(json);

  Map<String, dynamic> toJson() => _$SharedUserToJson(this);

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
