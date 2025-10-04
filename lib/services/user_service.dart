// lib/services/user_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_entity.dart';

/// שירות ניהול משתמש מקומי (SharedPreferences)
/// - שמירת אובייקט משתמש מלא כ-JSON
/// - שליפת/מחיקת משתמש
/// - עוזרים ל-userId ול-onboarding
class UserService {
  static const String _userKey = 'current_user';
  static const String _userIdKey = 'userId'; // בשימוש באזורים אחרים באפליקציה
  static const String _seenOnboardingKey = 'seenOnboarding';

  /// שומר את המשתמש הנוכחי (JSON) וגם את ה-userId לצורך תאימות.
  Future<bool> saveUser(UserEntity user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final okJson = await prefs.setString(_userKey, jsonEncode(user.toJson()));
      final okId = await prefs.setString(_userIdKey, user.id);
      return okJson && okId;
    } catch (_) {
      return false;
    }
  }

  /// מחזיר את המשתמש ששמור ב-SharedPreferences, או null אם אין/פגום.
  Future<UserEntity?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_userKey);
      if (raw == null || raw.isEmpty) return null;

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;

      return UserEntity.fromJson(decoded);
    } catch (_) {
      // JSON לא תקין או מפתח חסר
      return null;
    }
  }

  /// מוחק את המשתמש מהאחסון המקומי.
  Future<bool> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ok1 = await prefs.remove(_userKey);
      // לא תמיד נרצה למחוק userId (לוגיקת אפליקציה). כאן נשמור תאימות וננקה גם אותו:
      final ok2 = await prefs.remove(_userIdKey);
      return ok1 && ok2;
    } catch (_) {
      return false;
    }
  }

  // -----------------------
  // עוזרים ל-userId / Onboarding
  // -----------------------

  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<bool> setCurrentUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_userIdKey, id);
  }

  Future<bool> clearCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_userIdKey);
  }

  Future<bool> getSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_seenOnboardingKey) ?? false;
  }

  Future<bool> setSeenOnboarding(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_seenOnboardingKey, value);
  }

  // -----------------------
  // עדכונים קטנים לאובייקט
  // -----------------------

  /// מעדכן למשתמש הנוכחי את שעת ההתחברות האחרונה ושומר.
  Future<bool> touchLastLoginNow() async {
    final user = await getUser();
    if (user == null) return false;
    final updated = user.copyWith(lastLoginAt: DateTime.now());
    return saveUser(updated);
  }

  /// עדכון קשיח לשדות פרופיל נפוצים ושמירה.
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? profileImageUrl,
    double? weeklyBudget,
    List<String>? preferredStores,
    List<String>? favoriteProducts,
    bool? isAdmin,
  }) async {
    final user = await getUser();
    if (user == null) return false;

    final updated = user.copyWith(
      name: name,
      email: email,
      profileImageUrl: profileImageUrl,
      weeklyBudget: weeklyBudget,
      preferredStores: preferredStores,
      favoriteProducts: favoriteProducts,
      isAdmin: isAdmin,
    );

    return saveUser(updated);
  }
}
