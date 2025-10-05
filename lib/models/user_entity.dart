// 📄 File: lib/models/user_entity.dart
//
// 🇮🇱 מודל ישות משתמש:
//     - מייצג משתמש באפליקציה עם כל הפרטים האישיים והעדפות.
//     - כולל שיוך למשק בית (household), תקציב שבועי, וחנויות מועדפות.
//     - מאפשר שיתוף נתונים בין משתמשים באותו משק בית.
//     - נתמך ע"י JSON לצורך סנכרון עם שרת ושמירה מקומית.
//
// 💡 רעיונות עתידיים:
//     - הוספת מטבע למשתמשים בינלאומיים (ILS, USD, EUR).
//     - העדפות שפה למשתמש (עברית, אנגלית, ערבית).
//     - אזכורים וניהול התראות.
//     - מעקב אחר מגמות קנייה אישיות (insights).
//     - ניהול הרשאות בתוך משק הבית (viewer, editor, admin).
//
// 🇬🇧 User entity model:
//     - Represents an app user with personal details and preferences.
//     - Includes household association, weekly budget, and favorite stores.
//     - Enables data sharing between users in the same household.
//     - Supports JSON for server sync and local storage.
//
// 💡 Future ideas:
//     - Add currency support for international users (ILS, USD, EUR).
//     - User language preferences (Hebrew, English, Arabic).
//     - Reminders and notification management.
//     - Personal shopping trend tracking (insights).
//     - Household permission management (viewer, editor, admin).
//

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_entity.g.dart';

/// 🇮🇱 מודל ישות משתמש
/// 🇬🇧 User entity model
@JsonSerializable()
class UserEntity {
  /// 🇮🇱 מזהה ייחודי למשתמש
  /// 🇬🇧 Unique user identifier
  final String id;

  /// 🇮🇱 שם המשתמש המלא
  /// 🇬🇧 Full user name
  final String name;

  /// 🇮🇱 כתובת דוא"ל
  /// 🇬🇧 Email address
  final String email;

  /// 🇮🇱 מזהה משק בית (מאפשר שיתוף נתונים)
  /// 🇬🇧 Household ID (enables data sharing)
  @JsonKey(name: 'household_id')
  final String householdId;

  /// 🇮🇱 כתובת תמונת פרופיל (אופציונלי)
  /// 🇬🇧 Profile image URL (optional)
  final String? profileImageUrl;

  /// 🇮🇱 תאריך הצטרפות
  /// 🇬🇧 Join date
  @JsonKey(name: 'joined_at')
  final DateTime joinedAt;

  /// 🇮🇱 תאריך התחברות אחרונה (אופציונלי)
  /// 🇬🇧 Last login date (optional)
  @JsonKey(name: 'last_login_at')
  final DateTime? lastLoginAt;

  /// 🇮🇱 רשימת חנויות מועדפות (IDs)
  /// 🇬🇧 List of preferred stores (IDs)
  @JsonKey(defaultValue: [])
  final List<String> preferredStores;

  /// 🇮🇱 רשימת מוצרים מועדפים (barcodes)
  /// 🇬🇧 List of favorite products (barcodes)
  @JsonKey(defaultValue: [])
  final List<String> favoriteProducts;

  /// 🇮🇱 תקציב שבועי מתוכנן (₪)
  /// 🇬🇧 Planned weekly budget (₪)
  @JsonKey(defaultValue: 0.0)
  final double weeklyBudget;

  /// 🇮🇱 האם מנהל משק הבית
  /// 🇬🇧 Is household admin
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

  /// 🇮🇱 משתמש ריק (ברירת מחדל)
  /// 🇬🇧 Empty user (default)
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

  /// 🇮🇱 משתמש דמה לבדיקות
  /// 🇬🇧 Demo user for testing
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

  // ---- JSON Serialization ----

  /// 🇮🇱 יצירה מ-JSON
  /// 🇬🇧 Create from JSON
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    debugPrint('📥 UserEntity.fromJson:');
    debugPrint('   id: ${json['id']}');
    debugPrint('   name: ${json['name']}');
    debugPrint('   email: ${json['email']}');
    debugPrint('   household_id: ${json['household_id']}');
    return _$UserEntityFromJson(json);
  }

  /// 🇮🇱 המרה ל-JSON
  /// 🇬🇧 Convert to JSON
  Map<String, dynamic> toJson() {
    debugPrint('📤 UserEntity.toJson:');
    debugPrint('   id: $id');
    debugPrint('   name: $name');
    debugPrint('   email: $email');
    debugPrint('   household_id: $householdId');
    return _$UserEntityToJson(this);
  }

  /// 🇮🇱 המרת רשימה מ-JSON
  /// 🇬🇧 Convert list from JSON
  static List<UserEntity> listFromJson(List<dynamic>? arr) => (arr ?? [])
      .whereType<Map<String, dynamic>>()
      .map((j) => UserEntity.fromJson(j))
      .toList();

  /// 🇮🇱 המרת רשימה ל-JSON
  /// 🇬🇧 Convert list to JSON
  static List<Map<String, dynamic>> listToJson(List<UserEntity> list) =>
      list.map((u) => u.toJson()).toList(growable: false);

  // ---- Copy & Update ----

  /// 🇮🇱 יצירת עותק עם שינויים
  /// 🇬🇧 Create a copy with updates
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
