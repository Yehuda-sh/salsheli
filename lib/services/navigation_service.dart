// 📄 File: lib/services/navigation_service.dart
// תיאור: שירות לניהול ניווט וסימון Onboarding
//
// מטרה: ריכוז הלוגיקה של SharedPreferences + Navigation במקום אחד
// במקום שכל מסך יקרא ישירות ל-SharedPreferences

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// שירות לניהול ניווט ומצב Onboarding
class NavigationService {
  // מפתחות SharedPreferences
  static const String _keySeenOnboarding = 'seenOnboarding';
  static const String _keyUserId = 'userId';

  /// סימון שהמשתמש ראה את מסך ה-Onboarding
  static Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySeenOnboarding, true);
  }

  /// בדיקה האם המשתמש ראה את ה-Onboarding
  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySeenOnboarding) ?? false;
  }

  /// שמירת userId
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
  }

  /// קריאת userId השמור
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  /// ניקוי כל הנתונים (Logout)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// ניווט עם סימון Onboarding
  /// מסמן שהמשתמש ראה את ה-Onboarding ומנווט למסך הבא
  static Future<void> navigateAfterOnboarding(
    BuildContext context,
    String routeName, {
    bool replacement = true,
  }) async {
    // סימון ש-Onboarding נראה
    await markOnboardingSeen();

    // בדיקה שה-context עדיין תקף
    if (!context.mounted) return;

    // ניווט
    if (replacement) {
      Navigator.pushReplacementNamed(context, routeName);
    } else {
      Navigator.pushNamed(context, routeName);
    }
  }

  /// ניווט ל-Login עם סימון
  static Future<void> goToLogin(BuildContext context) async {
    await navigateAfterOnboarding(context, '/login');
  }

  /// ניווט ל-Register עם סימון
  static Future<void> goToRegister(BuildContext context) async {
    await navigateAfterOnboarding(context, '/register');
  }

  /// ניווט ל-Onboarding עם סימון
  static Future<void> goToOnboarding(BuildContext context) async {
    await navigateAfterOnboarding(context, '/onboarding');
  }

  /// ניווט ל-Home
  static Future<void> goToHome(BuildContext context) async {
    await navigateAfterOnboarding(context, '/home');
  }

  /// דילוג (Skip) - מסמן ומנווט ל-Login
  static Future<void> skip(BuildContext context) async {
    await navigateAfterOnboarding(context, '/login');
  }
}
