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

/// 🔧 קורא reminderTime עם תמיכה ב-snake_case + מתייחס ל-"" כ-null
Object? _readReminderTime(Map<dynamic, dynamic> json, String key) {
  final value = json['reminder_time'] ?? json['reminderTime'];
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

  /// 🇮🇱 מספר טלפון (פורמט ישראלי 05XXXXXXXX)
  /// 🇬🇧 Phone number (Israeli format 05XXXXXXXX)
  /// 🔄 readValue: מתייחס ל-"" כ-null
  @JsonKey(readValue: _readPhone)
  final String? phone;

  /// 🇮🇱 מזהה משק בית (מאפשר שיתוף נתונים)
  /// 🇬🇧 Household ID (enables data sharing)
  /// 🔄 readValue: תמיכה ב-snake_case וגם camelCase
  @JsonKey(name: 'household_id', readValue: _readHouseholdId)
  final String householdId;

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
  /// 🔧 תומך ב-int, double, String עם פסיק (500, 500.5, "500,5")
  @FlexDoubleConverter()
  @JsonKey(name: 'weekly_budget', readValue: _readWeeklyBudget)
  final double weeklyBudget;

  /// 🇮🇱 האם מנהל משק הבית
  /// 🇬🇧 Is household admin
  @JsonKey(name: 'is_admin')
  final bool isAdmin;

  // === 🆕 שדות Onboarding (נשמרים בשרת) ===

  /// 🇮🇱 גודל המשפחה (1-10)
  /// 🇬🇧 Family size (1-10)
  @JsonKey(name: 'family_size')
  final int familySize;

  /// 🇮🇱 תדירות קניות בשבוע (1-7)
  /// 🇬🇧 Shopping frequency per week (1-7)
  @JsonKey(name: 'shopping_frequency')
  final int shoppingFrequency;

  /// 🇮🇱 ימי קנייה קבועים (0=ראשון, 6=שבת)
  /// 🇬🇧 Fixed shopping days (0=Sunday, 6=Saturday)
  @JsonKey(name: 'shopping_days')
  final List<int> shoppingDays;

  /// 🇮🇱 האם יש ילדים במשפחה
  /// 🇬🇧 Whether family has children
  @JsonKey(name: 'has_children')
  final bool hasChildren;

  /// 🇮🇱 האם לשתף רשימות עם בני משפחה
  /// 🇬🇧 Whether to share lists with family members
  @JsonKey(name: 'share_lists')
  final bool shareLists;

  /// 🇮🇱 זמן תזכורת (פורמט HH:MM)
  /// 🇬🇧 Reminder time (HH:MM format)
  /// 🔄 readValue: מתייחס ל-"" כ-null + snake_case
  @JsonKey(name: 'reminder_time', readValue: _readReminderTime)
  final String? reminderTime;

  /// 🇮🇱 האם עבר את תהליך ה-Onboarding
  /// 🇬🇧 Whether completed onboarding process
  @JsonKey(name: 'seen_onboarding')
  final bool seenOnboarding;

  /// 🇮🇱 האם ראה את הדרכת הבית
  /// 🇬🇧 Whether seen home tutorial
  @JsonKey(name: 'seen_tutorial')
  final bool seenTutorial;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.householdId,
    required this.joinedAt,
    this.lastLoginAt,
    this.profileImageUrl,
    this.preferredStores = const [],
    this.favoriteProducts = const [],
    this.weeklyBudget = 0.0,
    this.isAdmin = false,
    // 🆕 Onboarding fields
    this.familySize = 2,
    this.shoppingFrequency = 2,
    this.shoppingDays = const [],
    this.hasChildren = false,
    this.shareLists = false,
    this.reminderTime,
    this.seenOnboarding = false,
    this.seenTutorial = false,
  });

  /// 🇮🇱 משתמש ריק (ברירת מחדל)
  /// 🇬🇧 Empty user (default)
  UserEntity.empty()
      : id = '',
        name = '',
        email = '',
        phone = null,
        householdId = '',
        joinedAt = DateTime(1970),
        lastLoginAt = null,
        profileImageUrl = null,
        preferredStores = const [],
        favoriteProducts = const [],
        weeklyBudget = 0.0,
        isAdmin = false,
        // 🆕 Onboarding fields
        familySize = 2,
        shoppingFrequency = 2,
        shoppingDays = const [],
        hasChildren = false,
        shareLists = false,
        reminderTime = null,
        seenOnboarding = false,
        seenTutorial = false;

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
    // 🆕 Onboarding fields (optional)
    List<String>? preferredStores,
    int? familySize,
    int? shoppingFrequency,
    List<int>? shoppingDays,
    bool? hasChildren,
    bool? shareLists,
    String? reminderTime,
    bool? seenOnboarding,
    bool? seenTutorial,
  }) {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      householdId: householdId ?? 'house_$id',
      joinedAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      preferredStores: preferredStores ?? const [],
      isAdmin: true, // משתמש חדש הוא admin של משק הבית שלו
      // 🆕 Onboarding fields
      familySize: familySize ?? 2,
      shoppingFrequency: shoppingFrequency ?? 2,
      shoppingDays: shoppingDays ?? const [],
      hasChildren: hasChildren ?? false,
      shareLists: shareLists ?? false,
      reminderTime: reminderTime,
      seenOnboarding: seenOnboarding ?? false,
      seenTutorial: seenTutorial ?? false,
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
  /// 🔧 תומך ב-Map<dynamic,dynamic> (Firestore) וגם Map<String,dynamic>
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
    List<String>? preferredStores,
    List<String>? favoriteProducts,
    double? weeklyBudget,
    bool? isAdmin,
    // 🆕 Onboarding fields
    int? familySize,
    int? shoppingFrequency,
    List<int>? shoppingDays,
    bool? hasChildren,
    bool? shareLists,
    String? reminderTime,
    bool clearReminderTime = false,
    bool? seenOnboarding,
    bool? seenTutorial,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: clearPhone ? null : (phone ?? this.phone),
      householdId: householdId ?? this.householdId,
      profileImageUrl: clearProfileImageUrl ? null : (profileImageUrl ?? this.profileImageUrl),
      joinedAt: joinedAt ?? this.joinedAt,
      lastLoginAt: clearLastLoginAt ? null : (lastLoginAt ?? this.lastLoginAt),
      preferredStores: preferredStores ?? this.preferredStores,
      favoriteProducts: favoriteProducts ?? this.favoriteProducts,
      weeklyBudget: weeklyBudget ?? this.weeklyBudget,
      isAdmin: isAdmin ?? this.isAdmin,
      // 🆕 Onboarding fields
      familySize: familySize ?? this.familySize,
      shoppingFrequency: shoppingFrequency ?? this.shoppingFrequency,
      shoppingDays: shoppingDays ?? this.shoppingDays,
      hasChildren: hasChildren ?? this.hasChildren,
      shareLists: shareLists ?? this.shareLists,
      reminderTime: clearReminderTime ? null : (reminderTime ?? this.reminderTime),
      seenOnboarding: seenOnboarding ?? this.seenOnboarding,
      seenTutorial: seenTutorial ?? this.seenTutorial,
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
