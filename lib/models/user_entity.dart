// 📄 File: lib/models/user_entity.dart
import 'package:json_annotation/json_annotation.dart';

part 'user_entity.g.dart';

@JsonSerializable()
class UserEntity {
  final String id;
  final String name;
  final String email;

  @JsonKey(name: 'household_id')
  final String householdId;

  final String? profileImageUrl;

  @JsonKey(name: 'joined_at')
  final DateTime joinedAt;

  @JsonKey(name: 'last_login_at')
  final DateTime? lastLoginAt;

  @JsonKey(defaultValue: [])
  final List<String> preferredStores;

  @JsonKey(defaultValue: [])
  final List<String> favoriteProducts;

  @JsonKey(defaultValue: 0.0)
  final double weeklyBudget;

  @JsonKey(defaultValue: false)
  final bool isAdmin;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.householdId,
    required this.joinedAt,
    this.lastLoginAt,
    this.profileImageUrl,
    this.preferredStores = const [],
    this.favoriteProducts = const [],
    this.weeklyBudget = 0.0,
    this.isAdmin = false,
  });

  /// ✅ Empty (default user)
  UserEntity.empty()
    : id = '',
      name = '',
      email = '',
      householdId = '',
      joinedAt = DateTime(1970, 1, 1),
      lastLoginAt = null,
      profileImageUrl = null,
      preferredStores = const [],
      favoriteProducts = const [],
      weeklyBudget = 0.0,
      isAdmin = false;

  /// 🧪 Demo user
  factory UserEntity.demo({
    required String id,
    required String name,
    String? email,
    String? householdId,
  }) {
    return UserEntity(
      id: id,
      name: name,
      email: email ?? '$id@example.com',
      householdId: householdId ?? 'house_${id.hashCode.abs()}',
      joinedAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      preferredStores: const [],
      favoriteProducts: const [],
      weeklyBudget: 0.0,
      isAdmin: false,
    );
  }

  // ---- JSON ----
  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);

  Map<String, dynamic> toJson() => _$UserEntityToJson(this);

  static List<UserEntity> listFromJson(List<dynamic>? arr) => (arr ?? [])
      .whereType<Map<String, dynamic>>()
      .map((j) => UserEntity.fromJson(j))
      .toList();

  static List<Map<String, dynamic>> listToJson(List<UserEntity> list) =>
      list.map((u) => u.toJson()).toList(growable: false);

  // ---- Copy ----
  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? householdId,
    String? profileImageUrl,
    DateTime? joinedAt,
    DateTime? lastLoginAt,
    List<String>? preferredStores,
    List<String>? favoriteProducts,
    double? weeklyBudget,
    bool? isAdmin,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      householdId: householdId ?? this.householdId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      joinedAt: joinedAt ?? this.joinedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferredStores: preferredStores ?? this.preferredStores,
      favoriteProducts: favoriteProducts ?? this.favoriteProducts,
      weeklyBudget: weeklyBudget ?? this.weeklyBudget,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  @override
  String toString() =>
      'UserEntity(id: $id, name: $name, email: $email, householdId: $householdId, budget: $weeklyBudget, isAdmin: $isAdmin)';
}
