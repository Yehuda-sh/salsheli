// 📄 File: lib/services/user_service.dart
// 📋 Description: ניהול משתמש מקומי דרך SharedPreferences
// 🎯 Purpose: שמירה/טעינה/מחיקה של משתמש + userId + onboarding state
// 📱 Mobile Only

import 'dart:convert';
import 'package:flutter/foundation.dart';
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
  static Future<bool> saveUser(UserEntity user) async {
    debugPrint('💾 UserService.saveUser()');
    debugPrint('   👤 User: ${user.email} (id: ${user.id})');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final okJson = await prefs.setString(_userKey, jsonEncode(user.toJson()));
      final okId = await prefs.setString(_userIdKey, user.id);
      final success = okJson && okId;
      
      if (success) {
        debugPrint('✅ UserService.saveUser: נשמר בהצלחה');
      } else {
        debugPrint('❌ UserService.saveUser: נכשל בשמירה');
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ UserService.saveUser: שגיאה - $e');
      return false;
    }
  }

  /// מחזיר את המשתמש ששמור ב-SharedPreferences, או null אם אין/פגום.
  static Future<UserEntity?> getUser() async {
    debugPrint('📥 UserService.getUser()');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_userKey);
      
      if (raw == null || raw.isEmpty) {
        debugPrint('   ⚠️ אין משתמש שמור');
        return null;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        debugPrint('   ❌ JSON לא תקין');
        return null;
      }

      final user = UserEntity.fromJson(decoded);
      debugPrint('✅ UserService.getUser: ${user.email}');
      return user;
    } catch (e) {
      debugPrint('❌ UserService.getUser: שגיאה - $e');
      return null;
    }
  }

  /// מוחק את המשתמש מהאחסון המקומי.
  static Future<bool> clearUser() async {
    debugPrint('🗑️ UserService.clearUser()');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final ok1 = await prefs.remove(_userKey);
      final ok2 = await prefs.remove(_userIdKey);
      final success = ok1 && ok2;
      
      if (success) {
        debugPrint('✅ UserService.clearUser: נמחק בהצלחה');
      } else {
        debugPrint('❌ UserService.clearUser: נכשל במחיקה');
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ UserService.clearUser: שגיאה - $e');
      return false;
    }
  }

  // -----------------------
  // עוזרים ל-userId / Onboarding
  // -----------------------

  static Future<String?> getCurrentUserId() async {
    debugPrint('📥 UserService.getCurrentUserId()');
    
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);
    
    if (userId != null) {
      debugPrint('   ✅ userId: $userId');
    } else {
      debugPrint('   ⚠️ אין userId');
    }
    
    return userId;
  }

  static Future<bool> setCurrentUserId(String id) async {
    debugPrint('💾 UserService.setCurrentUserId()');
    debugPrint('   userId: $id');
    
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.setString(_userIdKey, id);
    
    if (success) {
      debugPrint('✅ UserService.setCurrentUserId: נשמר');
    } else {
      debugPrint('❌ UserService.setCurrentUserId: נכשל');
    }
    
    return success;
  }

  static Future<bool> clearCurrentUserId() async {
    debugPrint('🗑️ UserService.clearCurrentUserId()');
    
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.remove(_userIdKey);
    
    if (success) {
      debugPrint('✅ UserService.clearCurrentUserId: נמחק');
    } else {
      debugPrint('❌ UserService.clearCurrentUserId: נכשל');
    }
    
    return success;
  }

  static Future<bool> getSeenOnboarding() async {
    debugPrint('📥 UserService.getSeenOnboarding()');
    
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_seenOnboardingKey) ?? false;
    
    debugPrint('   ${seen ? "✅" : "⚠️"} seenOnboarding: $seen');
    return seen;
  }

  static Future<bool> setSeenOnboarding(bool value) async {
    debugPrint('💾 UserService.setSeenOnboarding()');
    debugPrint('   value: $value');
    
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.setBool(_seenOnboardingKey, value);
    
    if (success) {
      debugPrint('✅ UserService.setSeenOnboarding: נשמר');
    } else {
      debugPrint('❌ UserService.setSeenOnboarding: נכשל');
    }
    
    return success;
  }

  // -----------------------
  // עדכונים קטנים לאובייקט
  // -----------------------

  /// מעדכן למשתמש הנוכחי את שעת ההתחברות האחרונה ושומר.
  static Future<bool> touchLastLoginNow() async {
    debugPrint('🔄 UserService.touchLastLoginNow()');
    
    final user = await getUser();
    if (user == null) {
      debugPrint('   ❌ אין משתמש');
      return false;
    }
    
    final updated = user.copyWith(lastLoginAt: DateTime.now());
    final success = await saveUser(updated);
    
    if (success) {
      debugPrint('✅ UserService.touchLastLoginNow: עודכן');
    }
    
    return success;
  }

  /// עדכון קשיח לשדות פרופיל נפוצים ושמירה.
  static Future<bool> updateProfile({
    String? name,
    String? email,
    String? profileImageUrl,
    double? weeklyBudget,
    List<String>? preferredStores,
    List<String>? favoriteProducts,
    bool? isAdmin,
  }) async {
    debugPrint('✏️ UserService.updateProfile()');
    debugPrint('   name: $name, email: $email');
    
    final user = await getUser();
    if (user == null) {
      debugPrint('   ❌ אין משתמש');
      return false;
    }

    final updated = user.copyWith(
      name: name,
      email: email,
      profileImageUrl: profileImageUrl,
      weeklyBudget: weeklyBudget,
      preferredStores: preferredStores,
      favoriteProducts: favoriteProducts,
      isAdmin: isAdmin,
    );

    final success = await saveUser(updated);
    
    if (success) {
      debugPrint('✅ UserService.updateProfile: עודכן');
    }
    
    return success;
  }
}
