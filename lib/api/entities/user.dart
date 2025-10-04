// 📄 File: lib/api/entities/user.dart
// תיאור: Entity של משתמש מה-API
// 🇮🇱 ישות משתמש אמיתית מה־API.
// 🇬🇧 User entity as returned from the API.

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// משתמש (API Entity)
/// 
/// 🎯 משמש לתקשורת עם Firebase/API
/// 📝 מומר ל-UserEntity (מודל מקומי) דרך mappers
/// 
/// **שדות:**
/// - `id` - מזהה ייחודי
/// - `email` - כתובת מייל (מנורמלת לאותיות קטנות)
/// - `householdId` - מזהה משק בית (אופציונלי)
@JsonSerializable(explicitToJson: true)
class User {
  final String id;
  final String email;
  @JsonKey(name: 'household_id')
  final String? householdId;

  const User({
    required this.id,
    required this.email,
    this.householdId,
  });

  /// Convenience: whether user is linked to a household.
  bool get hasHousehold => (householdId != null && householdId!.isNotEmpty);

  /// JSON → User (with email normalization)
  factory User.fromJson(Map<String, dynamic> json) {
    debugPrint('📥 User.fromJson: ${json['email']}');
    final user = _$UserFromJson(json);
    // Normalize email after deserialization
    return User(
      id: user.id,
      email: user.email.trim().toLowerCase(),
      householdId: user.householdId,
    );
  }

  /// User → JSON
  Map<String, dynamic> toJson() {
    debugPrint('📤 User.toJson: $email');
    return _$UserToJson(this);
  }

  /// Immutable copy
  User copyWith({String? id, String? email, String? householdId}) {
    return User(
      id: id ?? this.id,
      email: (email ?? this.email).trim().toLowerCase(),
      householdId: householdId ?? this.householdId,
    );
  }

  @override
  String toString() =>
      'User(id: $id, email: $email, householdId: $householdId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
