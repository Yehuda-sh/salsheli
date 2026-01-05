// 📄 File: lib/services/onboarding_service.dart
// תיאור: שירות ייעודי לניהול נתוני Onboarding
//
// אחריות:
// - שמירה וטעינה של כל העדפות המשתמש מה-onboarding
// - ניהול סטטוס השלמת ה-onboarding
// - מקום אחד ויחיד לכל מה שקשור להעדפות onboarding
//
// ✅ תיקונים:
//    - OnboardingResult typed result במקום bool
//    - Factory constructors לכל סוג תוצאה
//
// 📝 Version: 1.1
// תלויות: OnboardingData, SharedPreferences

import 'package:flutter/foundation.dart';
import '../data/onboarding_data.dart';

// ========================================
// 🆕 Typed Result for Onboarding
// ========================================

/// סוגי תוצאות מפעולות Onboarding
///
/// מאפשר ל-UI להבחין בין מצבים שונים:
/// ```dart
/// final result = await onboardingService.savePreferencesResult(data);
/// switch (result.type) {
///   case OnboardingResultType.success:
///     // המשך לעמוד הבא
///     break;
///   case OnboardingResultType.storageError:
///     // הצג שגיאת שמירה
///     break;
///   case OnboardingResultType.validationError:
///     // הצג שגיאת וולידציה
///     break;
/// }
/// ```
enum OnboardingResultType {
  /// הצלחה
  success,

  /// שגיאת SharedPreferences
  storageError,

  /// שגיאת וולידציה בנתונים
  validationError,
}

/// תוצאת פעולת Onboarding - Type-Safe!
///
/// כוללת:
/// - [type] - סוג התוצאה (enum)
/// - [data] - נתוני Onboarding (אם יש)
/// - [errorMessage] - הודעת שגיאה (לדיבוג)
class OnboardingResult {
  final OnboardingResultType type;
  final OnboardingData? data;
  final String? errorMessage;

  const OnboardingResult._({
    required this.type,
    this.data,
    this.errorMessage,
  });

  /// הצלחה ללא נתונים (למשל markAsCompleted)
  factory OnboardingResult.success() {
    return const OnboardingResult._(
      type: OnboardingResultType.success,
    );
  }

  /// הצלחה עם נתוני Onboarding
  factory OnboardingResult.successWithData(OnboardingData data) {
    return OnboardingResult._(
      type: OnboardingResultType.success,
      data: data,
    );
  }

  /// שגיאת שמירה/טעינה
  factory OnboardingResult.storageError(String message) {
    return OnboardingResult._(
      type: OnboardingResultType.storageError,
      errorMessage: message,
    );
  }

  /// שגיאת וולידציה
  factory OnboardingResult.validationError(String message) {
    return OnboardingResult._(
      type: OnboardingResultType.validationError,
      errorMessage: message,
    );
  }

  /// האם הצליח
  bool get isSuccess => type == OnboardingResultType.success;

  /// האם יש נתונים
  bool get hasData => data != null;

  /// האם יש שגיאה
  bool get isError =>
      type == OnboardingResultType.storageError ||
      type == OnboardingResultType.validationError;
}

// 🔧 Wrapper לlogs - פועל רק ב-debug mode
void _log(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}

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
  // 🆕 Typed Result API (Recommended)
  // ========================================

  /// בדיקה: האם המשתמש כבר השלים את ה-onboarding?
  ///
  /// משתמש בפונקציה החדשה מ-OnboardingData
  Future<bool> hasCompletedOnboarding() async {
    _log('🔍 OnboardingService: בודק סטטוס onboarding');
    return await OnboardingData.hasSeenOnboarding();
  }

  /// סימון שהמשתמש השלים את ה-onboarding
  ///
  /// ✅ מחזיר [OnboardingResult] עם סוג תוצאה ברור
  Future<OnboardingResult> markAsCompletedResult() async {
    _log('✓ OnboardingService: מסמן onboarding כהושלם');

    try {
      final success = await OnboardingData.markAsCompleted();

      if (success) {
        _log('✅ OnboardingService: סימון הושלם בהצלחה');
        return OnboardingResult.success();
      } else {
        _log('❌ OnboardingService: סימון נכשל');
        return OnboardingResult.storageError('Failed to mark as completed');
      }
    } catch (e) {
      _log('❌ OnboardingService: שגיאה בסימון - $e');
      return OnboardingResult.storageError(e.toString());
    }
  }

  /// שמירת כל העדפות ה-onboarding
  ///
  /// ✅ מחזיר [OnboardingResult] עם סוג תוצאה ברור
  ///
  /// Example:
  /// ```dart
  /// final result = await onboardingService.savePreferencesResult(data);
  /// if (result.isSuccess) {
  ///   // המשך לעמוד הבא
  /// } else if (result.type == OnboardingResultType.storageError) {
  ///   // הצג שגיאת שמירה
  /// }
  /// ```
  Future<OnboardingResult> savePreferencesResult(OnboardingData data) async {
    _log('💾 OnboardingService: שומר העדפות onboarding');

    try {
      // שמירת הנתונים באמצעות המודל
      final savedData = await data.save();

      if (!savedData) {
        _log('❌ OnboardingService: שמירת נתונים נכשלה');
        return OnboardingResult.storageError('Failed to save preferences');
      }

      // סימון שהonboarding הושלם
      final markedCompleted = await OnboardingData.markAsCompleted();

      if (!markedCompleted) {
        _log('❌ OnboardingService: סימון השלמה נכשל');
        return OnboardingResult.storageError('Failed to mark as completed');
      }

      _log('✅ OnboardingService: שמירה הושלמה בהצלחה');
      return OnboardingResult.successWithData(data);
    } catch (e) {
      _log('❌ OnboardingService: שגיאה בשמירה - $e');
      return OnboardingResult.storageError(e.toString());
    }
  }

  /// טעינת העדפות ה-onboarding
  ///
  /// ✅ מחזיר [OnboardingResult] עם סוג תוצאה ברור
  ///
  /// Example:
  /// ```dart
  /// final result = await onboardingService.loadPreferencesResult();
  /// if (result.isSuccess && result.hasData) {
  ///   // השתמש ב-result.data
  /// } else if (result.type == OnboardingResultType.storageError) {
  ///   // טפל בשגיאה
  /// }
  /// ```
  Future<OnboardingResult> loadPreferencesResult() async {
    _log('📂 OnboardingService: טוען העדפות onboarding');

    try {
      final data = await OnboardingData.load();
      _log('✅ OnboardingService: טעינה הושלמה');
      return OnboardingResult.successWithData(data);
    } catch (e) {
      _log('❌ OnboardingService: שגיאה בטעינה - $e');
      return OnboardingResult.storageError(e.toString());
    }
  }

  /// איפוס מלא של כל נתוני ה-onboarding
  ///
  /// ✅ מחזיר [OnboardingResult] עם סוג תוצאה ברור
  ///
  /// שימושי לצורך:
  /// - דיבאג ובדיקות
  /// - "התחל מחדש" בהגדרות
  /// - logout מלא
  Future<OnboardingResult> resetPreferencesResult() async {
    _log('🗑️ OnboardingService: מאפס את כל נתוני ה-onboarding');

    try {
      final success = await OnboardingData.reset();

      if (success) {
        _log('✅ OnboardingService: איפוס הושלם בהצלחה');
        return OnboardingResult.success();
      } else {
        _log('❌ OnboardingService: איפוס נכשל');
        return OnboardingResult.storageError('Failed to reset preferences');
      }
    } catch (e) {
      _log('❌ OnboardingService: שגיאה באיפוס - $e');
      return OnboardingResult.storageError(e.toString());
    }
  }

  // ========================================
  // 🔙 Legacy API (Deprecated)
  // ========================================

  /// @deprecated השתמש ב-markAsCompletedResult() במקום
  @Deprecated('Use markAsCompletedResult() instead')
  Future<bool> markAsCompleted() async {
    final result = await markAsCompletedResult();
    return result.isSuccess;
  }

  /// @deprecated השתמש ב-savePreferencesResult() במקום
  @Deprecated('Use savePreferencesResult() instead')
  Future<bool> savePreferences(OnboardingData data) async {
    final result = await savePreferencesResult(data);
    return result.isSuccess;
  }

  /// @deprecated השתמש ב-loadPreferencesResult() במקום
  @Deprecated('Use loadPreferencesResult() instead')
  Future<OnboardingData> loadPreferences() async {
    final result = await loadPreferencesResult();
    return result.data ?? OnboardingData();
  }

  /// @deprecated השתמש ב-resetPreferencesResult() במקום
  @Deprecated('Use resetPreferencesResult() instead')
  Future<bool> resetPreferences() async {
    final result = await resetPreferencesResult();
    return result.isSuccess;
  }
}
