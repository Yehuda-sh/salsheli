// 📄 File: lib/api/entities/user.dart
//
// 🇮🇱 ישות משתמש אמיתית מה־API.
// 🇬🇧 User entity as returned from the API.
//

class User {
  final String id;
  final String email;
  final String? householdId;

  const User({required this.id, required this.email, this.householdId});

  /// Convenience: whether user is linked to a household.
  bool get hasHousehold => (householdId != null && householdId!.isNotEmpty);

  /// JSON → User (defensive casting + email normalization)
  factory User.fromJson(Map<String, dynamic> json) {
    final rawEmail = (json['email'] ?? '').toString().trim().toLowerCase();
    return User(
      id: (json['id'] ?? '').toString(),
      email: rawEmail,
      householdId: json['household_id']?.toString(),
    );
  }

  /// User → JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'household_id': householdId,
  };

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
