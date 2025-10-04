// 📄 File: lib/services/onboarding_service.dart
// תיאור: שירות ייעודי לניהול נתוני Onboarding
//
// אחריות:
// - שמירה וטעינה של כל העדפות המשתמש מה-onboarding
// - ניהול סטטוס השלמת ה-onboarding
// - מקום אחד ויחיד לכל מה שקשור להעדפות onboarding
//
// תלויות: OnboardingData, SharedPreferences

import 'package:flutter/foundation.dart';
import '../data/onboarding_data.dart';

/// שירות לניהול נתוני Onboarding
///
/// השירות מספק API פשוט לשמירה וטעינה של העדפות המשתמש
/// שנאספו במהלך תהליך ה-Onboarding.
///
/// **שימוש:**
/// ```dart
/// final service = OnboardingService();
///
/// // בדיקה אם עבר onboarding
/// final hasSeen = await service.hasCompletedOnboarding();
///
/// // שמירת נתונים
/// await service.savePreferences(data);
///
/// // טעינת נתונים
/// final data = await service.loadPreferences();
/// ```
class OnboardingService {
  // Singleton pattern
  static final OnboardingService _instance = OnboardingService._internal();
  factory OnboardingService() => _instance;
  OnboardingService._internal();

  // ========================================
  // Public API
  // ========================================

  /// בדיקה: האם המשתמש כבר השלים את ה-onboarding?
  ///
  /// משתמש בפונקציה החדשה מ-OnboardingData
  Future<bool> hasCompletedOnboarding() async {
    debugPrint('🔍 OnboardingService: בודק סטטוס onboarding');
    return await OnboardingData.hasSeenOnboarding();
  }

  /// סימון שהמשתמש השלים את ה-onboarding
  ///
  /// משתמש בפונקציה החדשה מ-OnboardingData
  Future<bool> markAsCompleted() async {
    debugPrint('✓ OnboardingService: מסמן onboarding כהושלם');
    return await OnboardingData.markAsCompleted();
  }

  /// שמירת כל העדפות ה-onboarding
  ///
  /// מקבל אובייקט OnboardingData ושומר את כל השדות שלו.
  /// גם מסמן אוטומטית שה-onboarding הושלם.
  ///
  /// מחזיר true אם השמירה הצליחה, false אחרת.
  Future<bool> savePreferences(OnboardingData data) async {
    debugPrint('💾 OnboardingService: שומר העדפות onboarding');

    try {
      // שמירת הנתונים באמצעות המודל
      final savedData = await data.save();

      // סימון שהonboarding הושלם
      final markedCompleted = await markAsCompleted();

      final success = savedData && markedCompleted;

      if (success) {
        debugPrint('✅ OnboardingService: שמירה הושלמה בהצלחה');
      } else {
        debugPrint('❌ OnboardingService: שמירה נכשלה');
      }

      return success;
    } catch (e) {
      debugPrint('❌ OnboardingService: שגיאה בשמירה - $e');
      return false;
    }
  }

  /// טעינת העדפות ה-onboarding
  ///
  /// מחזיר אובייקט OnboardingData עם הערכים השמורים,
  /// או OnboardingData עם ערכי ברירת מחדל אם אין נתונים שמורים.
  Future<OnboardingData> loadPreferences() async {
    debugPrint('📂 OnboardingService: טוען העדפות onboarding');

    try {
      final data = await OnboardingData.load();
      debugPrint('✅ OnboardingService: טעינה הושלמה');
      return data;
    } catch (e) {
      debugPrint('⚠️ OnboardingService: שגיאה בטעינה, משתמש בברירות מחדל - $e');
      return OnboardingData();
    }
  }

  /// איפוס מלא של כל נתוני ה-onboarding
  ///
  /// שימושי לצורך:
  /// - דיבאג ובדיקות
  /// - "התחל מחדש" בהגדרות
  /// - logout מלא
  ///
  /// משתמש בפונקציה החדשה מ-OnboardingData
  Future<bool> resetPreferences() async {
    debugPrint('🗑️ OnboardingService: מאפס את כל נתוני ה-onboarding');

    try {
      final result = await OnboardingData.reset();

      if (result) {
        debugPrint('✅ OnboardingService: איפוס הושלם בהצלחה');
      } else {
        debugPrint('❌ OnboardingService: איפוס נכשל');
      }

      return result;
    } catch (e) {
      debugPrint('❌ OnboardingService: שגיאה באיפוס - $e');
      return false;
    }
  }
}
