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
@immutable
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
  @JsonKey(name: 'profile_image_url')
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
  @JsonKey(name: 'preferred_stores')
  final List<String> preferredStores;

  /// 🇮🇱 רשימת מוצרים מועדפים (barcodes)
  /// 🇬🇧 List of favorite products (barcodes)
  @JsonKey(name: 'favorite_products')
  final List<String> favoriteProducts;

  /// 🇮🇱 תקציב שבועי מתוכנן (₪)
  /// 🇬🇧 Planned weekly budget (₪)
  @JsonKey(name: 'weekly_budget')
  final double weeklyBudget;

  /// 🇮🇱 האם מנהל משק הבית
  /// 🇬🇧 Is household admin
  @JsonKey(name: 'is_admin')
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

  /// 🇮🇱 יצירת משתמש חדש
  /// 🇬🇧 Create new user
  factory UserEntity.newUser({
    required String id,
    required String email,
    required String name,
    String? householdId,
  }) {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      householdId: householdId ?? 'house_$id',
      joinedAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      preferredStores: const [],
      favoriteProducts: const [],
      weeklyBudget: 0.0,
      isAdmin: true, // משתמש חדש הוא admin של משק הבית שלו
    );
  }

  // ---- JSON Serialization ----

  /// 🇮🇱 יצירה מ-JSON
  /// 🇬🇧 Create from JSON
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      debugPrint('📥 UserEntity.fromJson:');
      debugPrint('   id: ${json['id']}');
      debugPrint('   name: ${json['name']}');
      debugPrint('   email: ${json['email']}');
      debugPrint('   household_id: ${json['household_id']}');
    }
    return _$UserEntityFromJson(json);
  }

  /// 🇮🇱 המרה ל-JSON
  /// 🇬🇧 Convert to JSON
  Map<String, dynamic> toJson() {
    if (kDebugMode) {
      debugPrint('📤 UserEntity.toJson:');
      debugPrint('   id: $id');
      debugPrint('   name: $name');
      debugPrint('   email: $email');
      debugPrint('   household_id: $householdId');
    }
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
    bool clearProfileImageUrl = false,
    DateTime? joinedAt,
    DateTime? lastLoginAt,
    bool clearLastLoginAt = false,
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
      profileImageUrl: clearProfileImageUrl ? null : (profileImageUrl ?? this.profileImageUrl),
      joinedAt: joinedAt ?? this.joinedAt,
      lastLoginAt: clearLastLoginAt ? null : (lastLoginAt ?? this.lastLoginAt),
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
