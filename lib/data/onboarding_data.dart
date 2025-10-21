// 📄 File: lib/data/onboarding_data.dart
// תיאור: מודל נתוני Onboarding + פונקציות שמירה/טעינה/ניהול
//
// Version: 2.0 - Enhanced with validation, namespacing, and schema versioning
// Last Updated: 15/10/2025
//
// כולל:
// - מודל OnboardingData עם כל שדות ההעדפות
// - פונקציות save/load/reset לעבודה עם SharedPreferences
// - ניהול סטטוס "סיים Onboarding"
// - וולידציה מלאה לכל השדות + סינון ערכים לא תקינים
// - Logging מפורט לדיבוג (kDebugMode only)
// - Namespacing למפתחות (onboarding.*)
// - Schema versioning למיגרציות עתידיות
// - TimeOfDay helpers
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
//
// // TimeOfDay helpers
// final time = OnboardingData.parseTime('09:30'); // TimeOfDay(hour: 9, minute: 30)
// final str = OnboardingData.formatTime(TimeOfDay(hour: 9, minute: 30)); // '09:30'
// ```

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../config/stores_config.dart';

// ========================================
// מפתחות SharedPreferences
// ========================================

/// מפתחות לשמירה ב-SharedPreferences
///
/// ⚠️ CRITICAL: אל תשנה שמות מפתחות ללא מיגרציה!
/// 
/// כל המפתחות במקום אחד - קל לניהול ומניעת שגיאות.
/// כל מפתח מתחיל ב-`onboarding.` למניעת התנגשויות עם Providers אחרים.
/// 
/// **תאימות לאחור:**
/// אם צריך לשנות שם מפתח:
/// 1. הוסף מפתח חדש
/// 2. הוסף לוגיקת מיגרציה ב-load() שמעתיקה מישן לחדש
/// 3. לאחר מספר גרסאות, מחק את הישן
class OnboardingPrefsKeys {
  // מניעת instances
  const OnboardingPrefsKeys._();

  // Schema version - לעדכון עתידי של מבנה נתונים
  static const schemaVersion = 'onboarding.schemaVersion';
  
  // נתוני Onboarding
  static const seenOnboarding = 'onboarding.seenOnboarding';
  static const familySize = 'onboarding.familySize';
  static const preferredStores = 'onboarding.preferredStores';
  static const shoppingFrequency = 'onboarding.shoppingFrequency'; // פעמים בשבוע
  static const shoppingDays = 'onboarding.shoppingDays'; // ימים קבועים (0-6)
  static const hasChildren = 'onboarding.hasChildren';
  static const childrenAges = 'onboarding.childrenAges'; // גילאי ילדים
  static const shareLists = 'onboarding.shareLists';
  static const reminderTime = 'onboarding.reminderTime'; // פורמט: HH:MM
}

// ========================================
// Schema Version
// ========================================

/// גרסת Schema נוכחית
/// 
/// כשמשנים את מבנה הנתונים (מוסיפים שדות, משנים טיפוסים, וכו'):
/// 1. העלה את המספר
/// 2. הוסף לוגיקת מיגרציה ב-load()
const int kCurrentSchemaVersion = 1;

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
/// - סינון ערכים לא תקינים (חנויות/קטגוריות לא קיימות)
/// - Logging מפורט (kDebugMode only)
/// - ניהול סטטוס "סיים Onboarding"
/// - Namespacing למניעת התנגשויות
/// - Schema versioning למיגרציות
class OnboardingData {
  final int familySize;
  final Set<String> preferredStores;
  final int shoppingFrequency; // פעמים בשבוע (1-7)
  final Set<int> shoppingDays; // ימים קבועים (0=ראשון, 6=שבת)
  final bool hasChildren;
  final Set<String> childrenAges; // גילאי ילדים
  final bool shareLists;
  final String reminderTime; // פורמט: HH:MM

  OnboardingData({
    int? familySize,
    Set<String>? preferredStores,
    int? shoppingFrequency,
    Set<int>? shoppingDays,
    this.hasChildren = false,
    Set<String>? childrenAges,
    this.shareLists = false,
    String? reminderTime,
  })  : familySize = _validateFamilySize(familySize ?? 2),
        preferredStores = _filterValidStores(preferredStores ?? {}),
        shoppingFrequency = _validateShoppingFrequency(shoppingFrequency ?? 2),
        shoppingDays = _filterValidDays(shoppingDays ?? {}),
        childrenAges = _filterValidAges(childrenAges ?? {}),
        reminderTime = _validateTime(reminderTime ?? '09:00');

  // ========================================
  // וולידציה
  // ========================================

  /// בדיקת תקינות גודל משפחה
  static int _validateFamilySize(int size) {
    if (size < kMinFamilySize) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ OnboardingData: גודל משפחה קטן מדי ($size), משתמש במינימום $kMinFamilySize',
        );
      }
      return kMinFamilySize;
    }
    if (size > kMaxFamilySize) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ OnboardingData: גודל משפחה גדול מדי ($size), משתמש במקסימום $kMaxFamilySize',
        );
      }
      return kMaxFamilySize;
    }
    return size;
  }

  /// בדיקת תקינות תדירות קניות
  static int _validateShoppingFrequency(int frequency) {
    if (frequency < 1) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ OnboardingData: תדירות קטנה מדי ($frequency), משתמש במינימום 1',
        );
      }
      return 1;
    }
    if (frequency > 7) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ OnboardingData: תדירות גדולה מדי ($frequency), משתמש במקסימום 7',
        );
      }
      return 7;
    }
    return frequency;
  }

  /// סינון ימי קניות תקינים בלבד (0-6)
  static Set<int> _filterValidDays(Set<int> days) {
    final validDays = days.where((day) => day >= 0 && day <= 6).toSet();
    
    if (kDebugMode && days.length != validDays.length) {
      final invalid = days.difference(validDays);
      debugPrint(
        '⚠️ OnboardingData: הוסרו ימים לא תקינים: ${invalid.join(', ')}',
      );
    }
    
    return validDays;
  }

  /// סינון גילאי ילדים תקינים בלבד
  static Set<String> _filterValidAges(Set<String> ages) {
    const validAges = {'babies', 'toddlers', 'children', 'teens'};
    final filtered = ages.where(validAges.contains).toSet();
    
    if (kDebugMode && ages.length != filtered.length) {
      final invalid = ages.difference(filtered);
      debugPrint(
        '⚠️ OnboardingData: הוסרו גילאים לא תקינים: ${invalid.join(', ')}',
      );
    }
    
    return filtered;
  }

  /// סינון חנויות תקינות בלבד
  /// 
  /// מסיר חנויות שלא קיימות ב-StoresConfig.allStores
  static Set<String> _filterValidStores(Set<String> stores) {
    final validStores = stores.where(StoresConfig.isValid).toSet();
    
    if (kDebugMode && stores.length != validStores.length) {
      final invalid = stores.difference(validStores);
      debugPrint(
        '⚠️ OnboardingData: הוסרו חנויות לא תקינות: ${invalid.join(', ')}',
      );
    }
    
    return validStores;
  }



  /// בדיקת תקינות פורמט זמן
  /// 
  /// מקבל: "HH:MM" (24h format)
  /// מחזיר: "HH:MM" תקין עם אפסים מובילים, או "09:00" אם לא תקין
  static String _validateTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) throw const FormatException('פורמט לא תקין');

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        throw RangeError('שעה או דקה לא חוקיות');
      }

      // מחזיר בפורמט תקין עם אפסים מובילים
      final formatted = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      
      // אם הפורמט השתנה (למשל "9:5" → "09:05"), לוג אזהרה
      if (kDebugMode && formatted != time) {
        debugPrint(
          '⚠️ OnboardingData: פורמט זמן תוקן מ-"$time" ל-"$formatted"',
        );
      }
      
      return formatted;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ OnboardingData: פורמט זמן שגוי ($time), משתמש בברירת מחדל 09:00',
        );
      }
      return '09:00';
    }
  }

  // ========================================
  // TimeOfDay Helpers
  // ========================================

  /// המרת String לפורמט TimeOfDay (לשימוש ב-UI)
  /// 
  /// דוגמה:
  /// ```dart
  /// final time = OnboardingData.parseTime('09:30');
  /// // TimeOfDay(hour: 9, minute: 30)
  /// ```
  static TimeOfDay? parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return null;
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
      
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  /// המרת TimeOfDay לפורמט String (לשמירה)
  /// 
  /// דוגמה:
  /// ```dart
  /// final str = OnboardingData.formatTime(TimeOfDay(hour: 9, minute: 30));
  /// // "09:30"
  /// ```
  static String formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// קבלת TimeOfDay מהנתונים
  TimeOfDay? get reminderTimeOfDay => parseTime(reminderTime);

  // ========================================
  // פונקציות עזר
  // ========================================

  /// יצירת עותק מעודכן של המודל
  OnboardingData copyWith({
    int? familySize,
    Set<String>? preferredStores,
    int? shoppingFrequency,
    Set<int>? shoppingDays,
    bool? hasChildren,
    Set<String>? childrenAges,
    bool? shareLists,
    String? reminderTime,
  }) {
    return OnboardingData(
      familySize: familySize ?? this.familySize,
      preferredStores: preferredStores ?? this.preferredStores,
      shoppingFrequency: shoppingFrequency ?? this.shoppingFrequency,
      shoppingDays: shoppingDays ?? this.shoppingDays,
      hasChildren: hasChildren ?? this.hasChildren,
      childrenAges: childrenAges ?? this.childrenAges,
      shareLists: shareLists ?? this.shareLists,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  /// המרה ל-Map (לצורך JSON)
  /// 
  /// רשימות ממוינות לדטרמיניזם
  Map<String, dynamic> toJson() {
    return {
      'familySize': familySize,
      'preferredStores': preferredStores.toList()..sort(),
      'shoppingFrequency': shoppingFrequency,
      'shoppingDays': shoppingDays.toList()..sort(),
      'hasChildren': hasChildren,
      'childrenAges': childrenAges.toList()..sort(),
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
        'frequency: $shoppingFrequency, '
        'days: ${shoppingDays.length}, '
        'hasChildren: $hasChildren, '
        'childrenAges: ${childrenAges.length}, '
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
  /// כולל logging מפורט לדיבוג (kDebugMode).
  /// 
  /// ⚠️ לא אטומי: אם שדה אחד נכשל, חלק מהשדות כבר נשמרו.
  Future<bool> save() async {
    try {
      if (kDebugMode) {
        debugPrint('💾 OnboardingData: מתחיל שמירה...');
      }
      
      final prefs = await SharedPreferences.getInstance();

      // וולידציה נוספת לפני שמירה (למניעת שמירה ידנית שגויה)
      final validatedTime = _validateTime(reminderTime);
      final validatedStores = _filterValidStores(preferredStores);
      final validatedDays = _filterValidDays(shoppingDays);
      final validatedAges = _filterValidAges(childrenAges);

      // שמירת schema version
      await prefs.setInt(OnboardingPrefsKeys.schemaVersion, kCurrentSchemaVersion);

      // רשימת שדות שנכשלו (לשיפור logging)
      final failedFields = <String>[];

      // שמירת כל השדות בזה אחר זה עם logging
      if (!await _saveField(
        prefs,
        OnboardingPrefsKeys.familySize,
        () => prefs.setInt(OnboardingPrefsKeys.familySize, familySize),
      )) {failedFields.add('familySize');}

      if (!await _saveField(
        prefs,
        OnboardingPrefsKeys.preferredStores,
        () => prefs.setStringList(
          OnboardingPrefsKeys.preferredStores,
          validatedStores.toList()..sort(), // ממוין לדטרמיניזם
        ),
      )) {failedFields.add('preferredStores');}

      if (!await _saveField(
        prefs,
        OnboardingPrefsKeys.shoppingFrequency,
        () => prefs.setInt(
          OnboardingPrefsKeys.shoppingFrequency,
          shoppingFrequency,
        ),
      )) {failedFields.add('shoppingFrequency');}

      if (!await _saveField(
        prefs,
        OnboardingPrefsKeys.shoppingDays,
        () => prefs.setString(
          OnboardingPrefsKeys.shoppingDays,
          validatedDays.toList().join(','), // שמירה כ-CSV
        ),
      )) {failedFields.add('shoppingDays');}

      if (!await _saveField(
        prefs,
        OnboardingPrefsKeys.hasChildren,
        () => prefs.setBool(OnboardingPrefsKeys.hasChildren, hasChildren),
      )) {failedFields.add('hasChildren');}

      if (!await _saveField(
        prefs,
        OnboardingPrefsKeys.childrenAges,
        () => prefs.setStringList(
          OnboardingPrefsKeys.childrenAges,
          validatedAges.toList()..sort(),
        ),
      )) {failedFields.add('childrenAges');}

      if (!await _saveField(
        prefs,
        OnboardingPrefsKeys.shareLists,
        () => prefs.setBool(OnboardingPrefsKeys.shareLists, shareLists),
      )) {failedFields.add('shareLists');}

      if (!await _saveField(
        prefs,
        OnboardingPrefsKeys.reminderTime,
        () => prefs.setString(OnboardingPrefsKeys.reminderTime, validatedTime),
      )) {failedFields.add('reminderTime');}

      final success = failedFields.isEmpty;

      if (kDebugMode) {
        if (success) {
          debugPrint('✅ OnboardingData: כל השדות נשמרו בהצלחה');
          debugPrint('   📊 נתונים: $this');
        } else {
          debugPrint(
            '❌ OnboardingData: שגיאה בשמירת השדות הבאים: ${failedFields.join(', ')}',
          );
        }
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ OnboardingData: שגיאה כללית בשמירה - $e');
      }
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
      if (kDebugMode) {
        if (result) {
          debugPrint('   ✓ נשמר: $key');
        } else {
          debugPrint('   ✗ נכשל: $key');
        }
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('   ✗ שגיאה ב-$key: $e');
      }
      return false;
    }
  }

  /// טעינת העדפות מ-SharedPreferences
  ///
  /// מחזיר OnboardingData עם הערכים השמורים,
  /// או ערכי ברירת מחדל אם אין נתונים שמורים.
  /// 
  /// כולל סינון ערכים לא תקינים וlogging מפורט על שימוש בברירות מחדל.
  static Future<OnboardingData> load() async {
    try {
      if (kDebugMode) {
        debugPrint('📂 OnboardingData: טוען נתונים...');
      }
      
      final prefs = await SharedPreferences.getInstance();

      // בדיקת schema version למיגרציות עתידיות
      final schemaVersion = prefs.getInt(OnboardingPrefsKeys.schemaVersion) ?? 1;
      if (kDebugMode && schemaVersion != kCurrentSchemaVersion) {
        debugPrint(
          '🔄 OnboardingData: Schema version $schemaVersion (נוכחי: $kCurrentSchemaVersion)',
        );
      }

      // טעינת נתונים עם אזהרות ספציפיות
      final familySizeValue = prefs.getInt(OnboardingPrefsKeys.familySize);
      if (kDebugMode && familySizeValue == null) {
        debugPrint('   ⚠️ familySize לא נמצא, משתמש בברירת מחדל: 2');
      }

      final storesValue = prefs.getStringList(OnboardingPrefsKeys.preferredStores);
      if (kDebugMode && (storesValue == null || storesValue.isEmpty)) {
        debugPrint('   ⚠️ preferredStores ריק, משתמש בברירת מחדל: []');
      }

      final frequencyValue = prefs.getInt(OnboardingPrefsKeys.shoppingFrequency);
      if (kDebugMode && frequencyValue == null) {
        debugPrint('   ⚠️ shoppingFrequency לא נמצא, משתמש בברירת מחדל: 2');
      }

      final daysValue = prefs.getString(OnboardingPrefsKeys.shoppingDays);
      final daysSet = daysValue != null && daysValue.isNotEmpty
          ? daysValue.split(',').map((s) => int.tryParse(s)).whereType<int>().toSet()
          : <int>{};
      if (kDebugMode && (daysValue == null || daysValue.isEmpty)) {
        debugPrint('   ⚠️ shoppingDays ריק, משתמש בברירת מחדל: []');
      }

      final hasChildrenValue = prefs.getBool(OnboardingPrefsKeys.hasChildren);
      if (kDebugMode && hasChildrenValue == null) {
        debugPrint('   ⚠️ hasChildren לא נמצא, משתמש בברירת מחדל: false');
      }

      final agesValue = prefs.getStringList(OnboardingPrefsKeys.childrenAges);
      if (kDebugMode && (agesValue == null || agesValue.isEmpty)) {
        debugPrint('   ⚠️ childrenAges ריק, משתמש בברירת מחדל: []');
      }

      final reminderValue = prefs.getString(OnboardingPrefsKeys.reminderTime);
      if (kDebugMode && reminderValue == null) {
        debugPrint('   ⚠️ reminderTime לא נמצא, משתמש בברירת מחדל: 09:00');
      }

      final data = OnboardingData(
        familySize: familySizeValue,
        preferredStores: (storesValue ?? []).toSet(),
        shoppingFrequency: frequencyValue,
        shoppingDays: daysSet,
        hasChildren: hasChildrenValue ?? false,
        childrenAges: (agesValue ?? []).toSet(),
        shareLists: prefs.getBool(OnboardingPrefsKeys.shareLists) ?? false,
        reminderTime: reminderValue,
      );

      if (kDebugMode) {
        debugPrint('✅ OnboardingData: נתונים נטענו בהצלחה');
        debugPrint('   📊 נתונים: $data');
      }
      
      return data;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ OnboardingData: שגיאה בטעינה, משתמש בברירות מחדל - $e',
        );
      }
      return OnboardingData();
    }
  }

  /// איפוס לערכי ברירת מחדל
  static OnboardingData defaults() {
    if (kDebugMode) {
      debugPrint('🔄 OnboardingData: יוצר ברירות מחדל');
    }
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
      if (kDebugMode) {
        debugPrint('✓ OnboardingData: מסמן onboarding כהושלם');
      }
      
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.setBool(
        OnboardingPrefsKeys.seenOnboarding,
        true,
      );

      if (kDebugMode) {
        if (result) {
          debugPrint('✅ OnboardingData: סימון הושלם בהצלחה');
        } else {
          debugPrint('❌ OnboardingData: נכשל בסימון');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ OnboardingData: שגיאה בסימון - $e');
      }
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

      if (kDebugMode) {
        debugPrint(
          '🔍 OnboardingData: בדיקת סטטוס - ${hasSeen ? "עבר" : "לא עבר"}',
        );
      }
      
      return hasSeen;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ OnboardingData: שגיאה בבדיקת סטטוס - $e');
      }
      return false; // ברירת מחדל - נראה את ה-onboarding
    }
  }

  /// איפוס מלא - מחיקת כל הנתונים
  ///
  /// שימושי לפיתוח או כשמשתמש רוצה להתחיל מחדש.
  /// מחזיר true אם האיפוס הצליח.
  static Future<bool> reset() async {
    try {
      if (kDebugMode) {
        debugPrint('🗑️ OnboardingData: מתחיל איפוס מלא...');
      }
      
      final prefs = await SharedPreferences.getInstance();

      final keys = [
        OnboardingPrefsKeys.schemaVersion,
        OnboardingPrefsKeys.seenOnboarding,
        OnboardingPrefsKeys.familySize,
        OnboardingPrefsKeys.preferredStores,
        OnboardingPrefsKeys.shoppingFrequency,
        OnboardingPrefsKeys.shoppingDays,
        OnboardingPrefsKeys.hasChildren,
        OnboardingPrefsKeys.childrenAges,
        OnboardingPrefsKeys.shareLists,
        OnboardingPrefsKeys.reminderTime,
      ];

      for (final key in keys) {
        await prefs.remove(key);
        if (kDebugMode) {
          debugPrint('   🗑️ מחק: $key');
        }
      }

      if (kDebugMode) {
        debugPrint('✅ OnboardingData: איפוס הושלם בהצלחה');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ OnboardingData: שגיאה באיפוס - $e');
      }
      return false;
    }
  }
}
