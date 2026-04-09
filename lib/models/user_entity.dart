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
// Version: 1.1 - DateTime converters, FlexDoubleConverter, empty string handling
// Last Updated: 13/01/2026

import 'package:flutter/foundation.dart' show immutable;
import 'package:json_annotation/json_annotation.dart';

import 'timestamp_converter.dart'
    show FlexibleDateTimeConverter, NullableFlexibleDateTimeConverter, FlexDoubleConverter;

part 'user_entity.g.dart';

// ════════════════════════════════════════════
// JSON Read Helpers (backward compat + empty string handling)
// ════════════════════════════════════════════

/// 🔧 קורא phone + מתייחס ל-"" כ-null
Object? _readPhone(Map<dynamic, dynamic> json, String key) {
  final value = json['phone'];
  if (value == null) return null;
  if (value is String && value.trim().isEmpty) return null;
  return value;
}

/// 🔧 קורא profileImageUrl עם תמיכה ב-snake_case + מתייחס ל-"" כ-null
Object? _readProfileImageUrl(Map<dynamic, dynamic> json, String key) {
  final value = json['profile_image_url'] ?? json['profileImageUrl'];
  if (value == null) return null;
  if (value is String && value.trim().isEmpty) return null;
  return value;
}

/// 🔧 קורא joinedAt עם תמיכה ב-snake_case
Object? _readJoinedAt(Map<dynamic, dynamic> json, String key) =>
    json['joined_at'] ?? json['joinedAt'];

/// 🔧 קורא lastLoginAt עם תמיכה ב-snake_case
Object? _readLastLoginAt(Map<dynamic, dynamic> json, String key) =>
    json['last_login_at'] ?? json['lastLoginAt'];

/// 🔧 קורא householdId עם תמיכה ב-snake_case
Object? _readHouseholdId(Map<dynamic, dynamic> json, String key) =>
    json['household_id'] ?? json['householdId'];

/// 🔧 קורא weeklyBudget עם תמיכה ב-snake_case
Object? _readWeeklyBudget(Map<dynamic, dynamic> json, String key) =>
    json['weekly_budget'] ?? json['weeklyBudget'];

/// 🔧 קורא householdName עם תמיכה ב-snake_case + מתייחס ל-"" כ-null
Object? _readHouseholdName(Map<dynamic, dynamic> json, String key) {
  final value = json['household_name'] ?? json['householdName'];
  if (value == null) return null;
  if (value is String && value.trim().isEmpty) return null;
  return value;
}

/// 🇮🇱 מודל ישות משתמש
/// 🇬🇧 User entity model
@immutable
@JsonSerializable()
class UserEntity {
  /// 🇮🇱 מזהה ייחודי למשתמש
  /// 🇬🇧 Unique user identifier
  @JsonKey(defaultValue: '')
  final String id;

  /// 🇮🇱 שם המשתמש המלא
  /// 🇬🇧 Full user name
  @JsonKey(defaultValue: '')
  final String name;

  /// 🇮🇱 כתובת דוא"ל
  /// 🇬🇧 Email address
  @JsonKey(defaultValue: '')
  final String email;

  /// 🇮🇱 מספר טלפון (פורמט ישראלי 05XXXXXXXX)
  /// 🇬🇧 Phone number (Israeli format 05XXXXXXXX)
  /// 🔄 readValue: מתייחס ל-"" כ-null
  @JsonKey(readValue: _readPhone)
  final String? phone;

  /// 🇮🇱 מזהה משק בית (מאפשר שיתוף נתונים)
  /// 🇬🇧 Household ID (enables data sharing)
  /// 🔄 readValue: תמיכה ב-snake_case וגם camelCase
  @JsonKey(name: 'household_id', readValue: _readHouseholdId, defaultValue: '')
  final String householdId;

  /// 🇮🇱 שם הקבוצה/משפחה (אופציונלי)
  /// 🇬🇧 Household display name (optional)
  /// 🔄 readValue: מתייחס ל-"" כ-null + snake_case
  @JsonKey(name: 'household_name', readValue: _readHouseholdName)
  final String? householdName;

  /// 🇮🇱 כתובת תמונת פרופיל (אופציונלי)
  /// 🇬🇧 Profile image URL (optional)
  /// 🔄 readValue: מתייחס ל-"" כ-null + snake_case
  @JsonKey(name: 'profile_image_url', readValue: _readProfileImageUrl)
  final String? profileImageUrl;

  /// 🇮🇱 תאריך הצטרפות
  /// 🇬🇧 Join date
  /// 🔧 תומך ב-Timestamp (Firestore) + String (ISO) + DateTime
  @FlexibleDateTimeConverter()
  @JsonKey(name: 'joined_at', readValue: _readJoinedAt)
  final DateTime joinedAt;

  /// 🇮🇱 תאריך התחברות אחרונה (אופציונלי)
  /// 🇬🇧 Last login date (optional)
  /// 🔧 תומך ב-Timestamp (Firestore) + String (ISO) + DateTime + null
  @NullableFlexibleDateTimeConverter()
  @JsonKey(name: 'last_login_at', readValue: _readLastLoginAt)
  final DateTime? lastLoginAt;

  /// 🇮🇱 רשימת מוצרים מועדפים (barcodes)
  /// 🇬🇧 List of favorite products (barcodes)
  @JsonKey(name: 'favorite_products', defaultValue: <String>[])
  final List<String> favoriteProducts;

  /// 🇮🇱 תקציב שבועי מתוכנן (₪)
  /// 🇬🇧 Planned weekly budget (₪)
  /// 🔧 תומך ב-int, double, String עם פסיק (500, 500.5, "500,5")
  @FlexDoubleConverter()
  @JsonKey(name: 'weekly_budget', readValue: _readWeeklyBudget)
  final double weeklyBudget;

  /// 🇮🇱 האם מנהל משק הבית
  /// 🇬🇧 Is household admin
  @JsonKey(name: 'is_admin', defaultValue: false)
  final bool isAdmin;

  /// 🇮🇱 האם עבר את תהליך ה-Onboarding
  /// 🇬🇧 Whether completed onboarding process
  @JsonKey(name: 'seen_onboarding', defaultValue: false)
  final bool seenOnboarding;

  /// 🇮🇱 האם ראה את הדרכת הבית
  /// 🇬🇧 Whether seen home tutorial
  @JsonKey(name: 'seen_tutorial', defaultValue: false)
  final bool seenTutorial;

  /// 🇮🇱 האם משק בית אישי (לא משותף)
  /// 🇬🇧 Whether this is a solo (non-shared) household
  /// null = ישנים שלא עודכנו עדיין (fallback to heuristic)
  @JsonKey(name: 'is_solo')
  final bool? isSolo;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.householdId,
    required this.joinedAt,
    this.lastLoginAt,
    this.profileImageUrl,
    this.favoriteProducts = const [],
    this.weeklyBudget = 0.0,
    this.isAdmin = false,
    this.seenOnboarding = false,
    this.seenTutorial = false,
    this.householdName,
    this.isSolo,
  });

  /// 🇮🇱 משתמש ריק (ברירת מחדל)
  /// 🇬🇧 Empty user (default)
  UserEntity.empty()
      : id = '',
        name = '',
        email = '',
        phone = null,
        householdId = '',
        householdName = null,
        joinedAt = DateTime(1970),
        lastLoginAt = null,
        profileImageUrl = null,
        favoriteProducts = const [],
        weeklyBudget = 0.0,
        isAdmin = false,
        seenOnboarding = false,
        seenTutorial = false,
        isSolo = null;

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
    );
  }

  /// 🇮🇱 יצירת משתמש חדש
  /// 🇬🇧 Create new user
  factory UserEntity.newUser({
    required String id,
    required String email,
    required String name,
    String? phone,
    String? householdId,
    bool? seenOnboarding,
    bool? seenTutorial,
    String? householdName,
    String? profileImageUrl,
    bool? isSolo,
  }) {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      householdId: householdId ?? 'house_$id',
      joinedAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isAdmin: true,
      seenOnboarding: seenOnboarding ?? false,
      seenTutorial: seenTutorial ?? false,
      householdName: householdName,
      profileImageUrl: profileImageUrl,
      isSolo: isSolo ?? true,
    );
  }

  // ---- JSON Serialization ----

  /// 🇮🇱 יצירה מ-JSON
  /// 🇬🇧 Create from JSON
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return _$UserEntityFromJson(json);
  }

  /// 🇮🇱 המרה ל-JSON
  /// 🇬🇧 Convert to JSON
  Map<String, dynamic> toJson() {
    return _$UserEntityToJson(this);
  }

  /// 🇮🇱 המרת רשימה מ-JSON
  /// 🇬🇧 Convert list from JSON
  /// 🔧 תומך ב-`Map<dynamic,dynamic>` (Firestore) וגם `Map<String,dynamic>`
  static List<UserEntity> listFromJson(List<dynamic>? arr) => (arr ?? [])
      .whereType<Map>()
      .map((m) => UserEntity.fromJson(Map<String, dynamic>.from(m)))
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
    String? phone,
    bool clearPhone = false,
    String? householdId,
    String? profileImageUrl,
    bool clearProfileImageUrl = false,
    DateTime? joinedAt,
    DateTime? lastLoginAt,
    bool clearLastLoginAt = false,
    List<String>? favoriteProducts,
    double? weeklyBudget,
    bool? isAdmin,
    bool? seenOnboarding,
    bool? seenTutorial,
    String? householdName,
    bool clearHouseholdName = false,
    bool? isSolo,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: clearPhone ? null : (phone ?? this.phone),
      householdId: householdId ?? this.householdId,
      householdName: clearHouseholdName ? null : (householdName ?? this.householdName),
      profileImageUrl: clearProfileImageUrl ? null : (profileImageUrl ?? this.profileImageUrl),
      joinedAt: joinedAt ?? this.joinedAt,
      lastLoginAt: clearLastLoginAt ? null : (lastLoginAt ?? this.lastLoginAt),
      favoriteProducts: favoriteProducts ?? this.favoriteProducts,
      weeklyBudget: weeklyBudget ?? this.weeklyBudget,
      isAdmin: isAdmin ?? this.isAdmin,
      seenOnboarding: seenOnboarding ?? this.seenOnboarding,
      seenTutorial: seenTutorial ?? this.seenTutorial,
      isSolo: isSolo ?? this.isSolo,
    );
  }

  @override
  String toString() =>
      'UserEntity(id: $id, name: $name, email: $email, householdId: $householdId, budget: $weeklyBudget, isAdmin: $isAdmin)';

  /// 🔧 שוויון לפי id בלבד
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
