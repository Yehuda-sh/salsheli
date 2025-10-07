// 📄 File: lib/data/onboarding_data.dart
// תיאור: מודל נתוני Onboarding + פונקציות שמירה/טעינה/ניהול
//
// כולל:
// - מודל OnboardingData עם כל שדות ההעדפות
// - פונקציות save/load/reset לעבודה עם SharedPreferences
// - ניהול סטטוס "סיים Onboarding"
// - וולידציה מלאה לכל השדות
// - Logging מפורט לדיבוג
//
// שימוש:
// ```dart
// // טעינת נתונים
// final data = await OnboardingData.load();
//
// // עדכון
// final updated = data.copyWith(familySize: 4);
// await updated.save();
//
// // סימון סיום
// await OnboardingData.markAsCompleted();
//
// // בדיקה אם עבר onboarding
// final hasSeenIt = await OnboardingData.hasSeenOnboarding();
// ```

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

// ========================================
// מפתחות SharedPreferences
// ========================================

/// מפתחות לשמירה ב-SharedPreferences
///
/// כל המפתחות במקום אחד - קל לניהול ומניעת שגיאות
class OnboardingPrefsKeys {
  static const seenOnboarding = 'seenOnboarding';
  static const familySize = 'familySize';
  static const preferredStores = 'preferredStores';
  static const monthlyBudget = 'monthlyBudget';
  static const importantCategories = 'importantCategories';
  static const shareLists = 'shareLists';
  static const reminderTime = 'reminderTime'; // פורמט: HH:MM
}

// ========================================
// מודל נתונים
// ========================================

/// מודל נתוני Onboarding
///
/// מכיל את כל ההעדפות שנאספות במהלך תהליך ה-onboarding.
/// המודל יודע לשמור ולטעון את עצמו מ-SharedPreferences.
///
/// **תכונות:**
/// - Validation אוטומטי לכל השדות
/// - Logging מפורט
/// - ניהול סטטוס "סיים Onboarding"
class OnboardingData {
  final int familySize;
  final Set<String> preferredStores;
  final double monthlyBudget;
  final Set<String> importantCategories;
  final bool shareLists;
  final String reminderTime; // פורמט: HH:MM

  OnboardingData({
    int? familySize,
    this.preferredStores = const <String>{},
    double? monthlyBudget,
    this.importantCategories = const <String>{},
    this.shareLists = false,
    String? reminderTime,
  }) : familySize = _validateFamilySize(familySize ?? 2),
       monthlyBudget = _validateBudget(monthlyBudget ?? 2000.0),
       reminderTime = _validateTime(reminderTime ?? '09:00');

  // ========================================
  // וולידציה
  // ========================================

  /// בדיקת תקינות גודל משפחה
  static int _validateFamilySize(int size) {
    if (size < kMinFamilySize) {
      debugPrint(
        '⚠️ OnboardingData: גודל משפחה קטן מדי ($size), משתמש במינימום',
      );
      return kMinFamilySize;
    }
    if (size > kMaxFamilySize) {
      debugPrint(
        '⚠️ OnboardingData: גודל משפחה גדול מדי ($size), משתמש במקסימום',
      );
      return kMaxFamilySize;
    }
    return size;
  }

  /// בדיקת תקינות תקציב
  static double _validateBudget(double budget) {
    if (budget < kMinMonthlyBudget) {
      debugPrint('⚠️ OnboardingData: תקציב קטן מדי ($budget), משתמש במינימום');
      return kMinMonthlyBudget;
    }
    if (budget > kMaxMonthlyBudget) {
      debugPrint('⚠️ OnboardingData: תקציב גדול מדי ($budget), משתמש במקסימום');
      return kMaxMonthlyBudget;
    }
    return budget;
  }

  /// בדיקת תקינות פורמט זמן
  static String _validateTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) throw FormatException('פורמט לא תקין');

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        throw RangeError('שעה או דקה לא חוקיות');
      }

      // מחזיר בפורמט תקין עם אפסים מובילים
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } catch (e) {
      debugPrint(
        '⚠️ OnboardingData: פורמט זמן שגוי ($time), משתמש בברירת מחדל 09:00',
      );
      return '09:00';
    }
  }

  // ========================================
  // פונקציות עזר
  // ========================================

  /// יצירת עותק מעודכן של המודל
  OnboardingData copyWith({
    int? familySize,
    Set<String>? preferredStores,
    double? monthlyBudget,
    Set<String>? importantCategories,
    bool? shareLists,
    String? reminderTime,
  }) {
    return OnboardingData(
      familySize: familySize ?? this.familySize,
      preferredStores: preferredStores ?? this.preferredStores,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      importantCategories: importantCategories ?? this.importantCategories,
      shareLists: shareLists ?? this.shareLists,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  /// המרה ל-Map (לצורך JSON)
  Map<String, dynamic> toJson() {
    return {
      'familySize': familySize,
      'preferredStores': preferredStores.toList(),
      'monthlyBudget': monthlyBudget,
      'importantCategories': importantCategories.toList(),
      'shareLists': shareLists,
      'reminderTime': reminderTime,
    };
  }

  /// המרה למחרוזת קריאה (לדיבוג)
  @override
  String toString() {
    return 'OnboardingData('
        'familySize: $familySize, '
        'stores: ${preferredStores.length}, '
        'budget: $monthlyBudget, '
        'categories: ${importantCategories.length}, '
        'shareLists: $shareLists, '
        'reminderTime: $reminderTime'
        ')';
  }

  // ========================================
  // שמירה וטעינה
  // ========================================

  /// שמירת כל ההעדפות ל-SharedPreferences
  ///
  /// מחזיר true אם השמירה הצליחה, false אחרת.
  /// כולל logging מפורט לדיבוג.
  Future<bool> save() async {
    try {
      debugPrint('💾 OnboardingData: מתחיל שמירה...');
      final prefs = await SharedPreferences.getInstance();

      // שמירת כל השדות בזה אחר זה עם logging
      final success =
          await _saveField(
            prefs,
            OnboardingPrefsKeys.familySize,
            () => prefs.setInt(OnboardingPrefsKeys.familySize, familySize),
          ) &&
          await _saveField(
            prefs,
            OnboardingPrefsKeys.preferredStores,
            () => prefs.setStringList(
              OnboardingPrefsKeys.preferredStores,
              preferredStores.toList(),
            ),
          ) &&
          await _saveField(
            prefs,
            OnboardingPrefsKeys.monthlyBudget,
            () => prefs.setDouble(
              OnboardingPrefsKeys.monthlyBudget,
              monthlyBudget,
            ),
          ) &&
          await _saveField(
            prefs,
            OnboardingPrefsKeys.importantCategories,
            () => prefs.setStringList(
              OnboardingPrefsKeys.importantCategories,
              importantCategories.toList(),
            ),
          ) &&
          await _saveField(
            prefs,
            OnboardingPrefsKeys.shareLists,
            () => prefs.setBool(OnboardingPrefsKeys.shareLists, shareLists),
          ) &&
          await _saveField(
            prefs,
            OnboardingPrefsKeys.reminderTime,
            () =>
                prefs.setString(OnboardingPrefsKeys.reminderTime, reminderTime),
          );

      if (success) {
        debugPrint('✅ OnboardingData: כל השדות נשמרו בהצלחה');
        debugPrint('   📊 נתונים: $this');
      } else {
        debugPrint('❌ OnboardingData: שגיאה בשמירת אחד השדות');
      }

      return success;
    } catch (e) {
      debugPrint('❌ OnboardingData: שגיאה כללית בשמירה - $e');
      return false;
    }
  }

  /// פונקציה פנימית לשמירת שדה בודד עם logging
  Future<bool> _saveField(
    SharedPreferences prefs,
    String key,
    Future<bool> Function() saveFn,
  ) async {
    try {
      final result = await saveFn();
      if (result) {
        debugPrint('   ✓ נשמר: $key');
      } else {
        debugPrint('   ✗ נכשל: $key');
      }
      return result;
    } catch (e) {
      debugPrint('   ✗ שגיאה ב-$key: $e');
      return false;
    }
  }

  /// טעינת העדפות מ-SharedPreferences
  ///
  /// מחזיר OnboardingData עם הערכים השמורים,
  /// או ערכי ברירת מחדל אם אין נתונים שמורים.
  static Future<OnboardingData> load() async {
    try {
      debugPrint('📂 OnboardingData: טוען נתונים...');
      final prefs = await SharedPreferences.getInstance();

      final data = OnboardingData(
        familySize: prefs.getInt(OnboardingPrefsKeys.familySize),
        preferredStores:
            (prefs.getStringList(OnboardingPrefsKeys.preferredStores) ?? [])
                .toSet(),
        monthlyBudget: prefs.getDouble(OnboardingPrefsKeys.monthlyBudget),
        importantCategories:
            (prefs.getStringList(OnboardingPrefsKeys.importantCategories) ?? [])
                .toSet(),
        shareLists: prefs.getBool(OnboardingPrefsKeys.shareLists) ?? false,
        reminderTime: prefs.getString(OnboardingPrefsKeys.reminderTime),
      );

      debugPrint('✅ OnboardingData: נתונים נטענו בהצלחה');
      debugPrint('   📊 נתונים: $data');
      return data;
    } catch (e) {
      debugPrint('⚠️ OnboardingData: שגיאה בטעינה, משתמש בברירות מחדל - $e');
      return OnboardingData();
    }
  }

  /// איפוס לערכי ברירת מחדל
  static OnboardingData defaults() {
    debugPrint('🔄 OnboardingData: יוצר ברירות מחדל');
    return OnboardingData();
  }

  // ========================================
  // ניהול סטטוס Onboarding
  // ========================================

  /// סימון שהמשתמש סיים את תהליך ה-Onboarding
  ///
  /// קורא לזה בסוף תהליך ה-onboarding כדי שהמשתמש
  /// לא יראה אותו שוב בפעם הבאה.
  static Future<bool> markAsCompleted() async {
    try {
      debugPrint('✓ OnboardingData: מסמן onboarding כהושלם');
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.setBool(
        OnboardingPrefsKeys.seenOnboarding,
        true,
      );

      if (result) {
        debugPrint('✅ OnboardingData: סימון הושלם בהצלחה');
      } else {
        debugPrint('❌ OnboardingData: נכשל בסימון');
      }

      return result;
    } catch (e) {
      debugPrint('❌ OnboardingData: שגיאה בסימון - $e');
      return false;
    }
  }

  /// בדיקה האם המשתמש כבר עבר את ה-Onboarding
  ///
  /// מחזיר true אם המשתמש כבר עבר את התהליך.
  static Future<bool> hasSeenOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeen =
          prefs.getBool(OnboardingPrefsKeys.seenOnboarding) ?? false;

      debugPrint(
        '🔍 OnboardingData: בדיקת סטטוס - ${hasSeen ? "עבר" : "לא עבר"}',
      );
      return hasSeen;
    } catch (e) {
      debugPrint('⚠️ OnboardingData: שגיאה בבדיקת סטטוס - $e');
      return false; // ברירת מחדל - נראה את ה-onboarding
    }
  }

  /// איפוס מלא - מחיקת כל הנתונים
  ///
  /// שימושי לפיתוח או כשמשתמש רוצה להתחיל מחדש.
  /// מחזיר true אם האיפוס הצליח.
  static Future<bool> reset() async {
    try {
      debugPrint('🗑️ OnboardingData: מתחיל איפוס מלא...');
      final prefs = await SharedPreferences.getInstance();

      final keys = [
        OnboardingPrefsKeys.seenOnboarding,
        OnboardingPrefsKeys.familySize,
        OnboardingPrefsKeys.preferredStores,
        OnboardingPrefsKeys.monthlyBudget,
        OnboardingPrefsKeys.importantCategories,
        OnboardingPrefsKeys.shareLists,
        OnboardingPrefsKeys.reminderTime,
      ];

      for (final key in keys) {
        await prefs.remove(key);
        debugPrint('   🗑️ מחק: $key');
      }

      debugPrint('✅ OnboardingData: איפוס הושלם בהצלחה');
      return true;
    } catch (e) {
      debugPrint('❌ OnboardingData: שגיאה באיפוס - $e');
      return false;
    }
  }
}
