// 📄 File: lib/data/onboarding_data.dart
//
// 🎯 Purpose: מודל נתוני Onboarding + שמירה/טעינה/ניהול העדפות
//
// 📋 Features:
//     - מודל OnboardingData עם וולידציה מלאה לכל שדה
//     - כתיבה מקבילית (Parallel Persistence) עם Future.wait
//     - Deep Cloning ב-copyWith (בטיחות רפרנסים)
//     - שיפור בטיחות טיפוסים (Type Safety)
//     - Schema versioning למיגרציות עתידיות
//     - Store category helpers
//     - TimeOfDay helpers
//     - Namespacing למפתחות (onboarding.*)
//
// 💡 Usage:
//     ```dart
//     final data = await OnboardingData.load();
//     final updated = data.copyWith(familySize: 4);
//     await updated.save();
//     await OnboardingData.markAsCompleted();
//     ```
//
// 🔗 Related:
//     - lib/data/child.dart - מודל Child
//     - lib/config/stores_config.dart - קונפיגורציית חנויות
//     - lib/core/constants.dart - קבועים גלובליים
//
// 📜 History:
//     - v1.0: מודל ראשוני
//     - v2.0: וולידציה, logging, schema versioning
//     - v2.2 (03/11/2025): Store category helpers
//     - v3.0 (22/02/2026): Parallel persistence, deep copy, isEmpty, RegExp validation
//
// Version: 3.0
// Last Updated: 22/02/2026

import 'dart:convert'; // ✅ להמרת JSON

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/stores_config.dart';
import '../core/constants.dart';
import 'child.dart';

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
  static const children = 'onboarding.children'; // רשימת ילדים עם שמות
  static const shareLists = 'onboarding.shareLists';
  static const reminderTime = 'onboarding.reminderTime'; // פורמט: HH:MM
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
/// - סינון ערכים לא תקינים (חנויות/קטגוריות לא קיימות)
/// - Logging מפורט (kDebugMode only)
/// - ניהול סטטוס "סיים Onboarding"
/// - Namespacing למניעת התנגשויות
/// - Schema versioning למיגרציות
/// - Store category helpers (v2.2)
class OnboardingData {
  final int familySize;
  final Set<String> preferredStores;
  final int shoppingFrequency; // פעמים בשבוע (1-7)
  final Set<int> shoppingDays; // ימים קבועים (0=ראשון, 6=שבת)
  final bool hasChildren;
  final List<Child> children; // ✅ NEW - רשימת ילדים עם שמות וגילאים
  final bool shareLists;
  final String reminderTime; // פורמט: HH:MM

  OnboardingData({
    int? familySize,
    Set<String>? preferredStores,
    int? shoppingFrequency,
    Set<int>? shoppingDays,
    this.hasChildren = false,
    List<Child>? children,
    this.shareLists = false,
    String? reminderTime,
  })  : familySize = _validateFamilySize(familySize ?? 2),
        preferredStores = _filterValidStores(preferredStores ?? {}),
        shoppingFrequency = _validateShoppingFrequency(shoppingFrequency ?? 2),
        shoppingDays = _filterValidDays(shoppingDays ?? {}),
        children = children ?? [], // ✅ לא מסננים כאן - רק בשמירה
        reminderTime = _validateTime(reminderTime ?? '09:00');

  // ========================================
  // וולידציה
  // ========================================

  /// בדיקת תקינות גודל משפחה
  static int _validateFamilySize(int size) {
    if (size < kMinFamilySize) {
      if (kDebugMode) {
      }
      return kMinFamilySize;
    }
    if (size > kMaxFamilySize) {
      if (kDebugMode) {
      }
      return kMaxFamilySize;
    }
    return size;
  }

  /// בדיקת תקינות תדירות קניות
  static int _validateShoppingFrequency(int frequency) {
    if (frequency < 1) {
      if (kDebugMode) {
      }
      return 1;
    }
    if (frequency > 7) {
      if (kDebugMode) {
      }
      return 7;
    }
    return frequency;
  }

  /// סינון ימי קניות תקינים בלבד (0-6)
  static Set<int> _filterValidDays(Set<int> days) {
    final validDays = days.where((day) => day >= 0 && day <= 6).toSet();
    
    if (kDebugMode && days.length != validDays.length) {
      // final invalid = days.difference(validDays);
    }
    
    return validDays;
  }

  /// סינון ילדים תקינים בלבד
  ///
  /// מסיר ילדים עם שמות ריקים או גילאים לא תקינים
  static List<Child> _filterValidChildren(List<Child> children) {
    final filtered = children.where((child) {
      // שם לא יכול להיות ריק
      if (child.name.trim().isEmpty) return false;
      // קטגוריית גיל חייבת להיות תקינה
      if (!kValidChildrenAges.contains(child.ageCategory)) return false;
      return true;
    }).toList();

    if (kDebugMode && children.length != filtered.length) {
    }

    return filtered;
  }

  /// נורמליזציה של חנויות
  ///
  /// ✅ רשימה פתוחה - לא מסננים חנויות לא מוכרות!
  /// - חנות מוכרת (שם עברי או קוד) → ממירים לקוד קנוני
  /// - חנות לא מוכרת → שומרים את הטקסט כמו שהוא
  static Set<String> _filterValidStores(Set<String> stores) {
    final normalized = stores.map(StoresConfig.resolve).toSet();

    if (kDebugMode) {
      final unknown = normalized.where((s) => !StoresConfig.isKnown(s)).toList();
      if (unknown.isNotEmpty) {
      }
    }

    return normalized;
  }



  /// ✅ v3.0: RegExp for fast HH:MM format pre-check
  static final _timeRegExp = RegExp(r'^\d{1,2}:\d{1,2}$');

  /// בדיקת תקינות פורמט זמן
  ///
  /// מקבל: "HH:MM" (24h format)
  /// מחזיר: "HH:MM" תקין עם אפסים מובילים, או "09:00" אם לא תקין
  static String _validateTime(String time) {
    // ✅ v3.0: RegExp pre-check - fast fail for invalid format
    if (!_timeRegExp.hasMatch(time)) {
      if (kDebugMode) {
      }
      return '09:00';
    }

    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      if (kDebugMode) {
      }
      return '09:00';
    }

    // מחזיר בפורמט תקין עם אפסים מובילים
    final formatted = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    // אם הפורמט השתנה (למשל "9:5" → "09:05"), לוג אזהרה
    if (kDebugMode && formatted != time) {
    }

    return formatted;
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

  /// בדיקה אם כל השדות בערכי ברירת מחדל (המשתמש לא מילא העדפות)
  ///
  /// בודק אם כל הרשימות ריקות ואין ילדים.
  /// שדות מספריים (familySize, shoppingFrequency) לא נבדקים
  /// כי ערכי ברירת המחדל שלהם יכולים להיות גם בחירות מכוונות.
  bool get isEmpty =>
      preferredStores.isEmpty &&
      shoppingDays.isEmpty &&
      !hasChildren &&
      children.isEmpty;

  // ========================================
  // פונקציות עזר
  // ========================================

  /// יצירת עותק מעודכן של המודל
  ///
  /// ✅ v3.0: Deep copy - יוצר עותקים חדשים של Sets ו-Lists
  /// למניעת שיתוף רפרנסים בין instances
  OnboardingData copyWith({
    int? familySize,
    Set<String>? preferredStores,
    int? shoppingFrequency,
    Set<int>? shoppingDays,
    bool? hasChildren,
    List<Child>? children,
    bool? shareLists,
    String? reminderTime,
  }) {
    return OnboardingData(
      familySize: familySize ?? this.familySize,
      preferredStores: preferredStores ?? Set.of(this.preferredStores),
      shoppingFrequency: shoppingFrequency ?? this.shoppingFrequency,
      shoppingDays: shoppingDays ?? Set.of(this.shoppingDays),
      hasChildren: hasChildren ?? this.hasChildren,
      children: children ?? List.of(this.children),
      shareLists: shareLists ?? this.shareLists,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  // ========================================
  // Store Category Helpers
  // ========================================

  /// קבלת חנויות מועדפות לפי קטגוריה
  /// 
  /// דוגמה:
  /// ```dart
  /// final supermarkets = data.getStoresByCategory(StoreCategory.supermarket);
  /// // ['שופרסל', 'רמי לוי']
  /// ```
  List<String> getStoresByCategory(StoreCategory category) {
    return preferredStores
        .where((store) => StoresConfig.getCategory(store) == category)
        .toList();
  }

  /// קבלת כל הקטגוריות שהמשתמש בחר חנויות מהן
  /// 
  /// מחזיר Set של קטגוריות ייחודיות.
  /// 
  /// דוגמה:
  /// ```dart
  /// final categories = data.getPreferredCategories();
  /// // {StoreCategory.supermarket, StoreCategory.pharmacy}
  /// ```
  Set<StoreCategory> getPreferredCategories() {
    return preferredStores
        .map(StoresConfig.getCategory)
        .whereType<StoreCategory>()
        .toSet();
  }

  /// בדיקה אם יש חנויות מועדפות בקטגוריה מסוימת
  /// 
  /// דוגמה:
  /// ```dart
  /// if (data.hasStoresInCategory(StoreCategory.pharmacy)) {
  ///   print('משתמש קונה בבית מרקחת');
  /// }
  /// ```
  bool hasStoresInCategory(StoreCategory category) {
    return preferredStores.any(
      (store) => StoresConfig.getCategory(store) == category,
    );
  }

  /// קבלת חנויות מקובצות לפי קטגוריה
  /// 
  /// חוזר Map שבו כל קטגוריה מצביעה על רשימת החנויות שלה.
  /// שימושי ל-UI מקובץ.
  /// 
  /// דוגמה:
  /// ```dart
  /// final grouped = data.getStoresGroupedByCategory();
  /// // {
  /// //   StoreCategory.supermarket: ['שופרסל', 'רמי לוי'],
  /// //   StoreCategory.pharmacy: ['סופר פארם'],
  /// // }
  /// ```
  Map<StoreCategory, List<String>> getStoresGroupedByCategory() {
    final grouped = <StoreCategory, List<String>>{};
    
    for (final store in preferredStores) {
      final category = StoresConfig.getCategory(store);
      if (category != null) {
        grouped.putIfAbsent(category, () => []).add(store);
      }
    }
    
    return grouped;
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
      'children': children.map((c) => c.toJson()).toList(),
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
        'children: ${children.length}, '
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
      }
      
      final prefs = await SharedPreferences.getInstance();

      // וולידציה נוספת לפני שמירה (למניעת שמירה ידנית שגויה)
      final validatedTime = _validateTime(reminderTime);
      final validatedStores = _filterValidStores(preferredStores);
      final validatedDays = _filterValidDays(shoppingDays);
      final validatedChildren = _filterValidChildren(children);

      // שמירת schema version
      await prefs.setInt(OnboardingPrefsKeys.schemaVersion, kCurrentSchemaVersion);

      // ✅ v3.0: שמירה מקבילית עם Future.wait
      const fieldNames = [
        'familySize', 'preferredStores', 'shoppingFrequency', 'shoppingDays',
        'hasChildren', 'children', 'shareLists', 'reminderTime',
      ];

      final results = await Future.wait([
        _saveField(prefs, OnboardingPrefsKeys.familySize,
            () => prefs.setInt(OnboardingPrefsKeys.familySize, familySize)),
        _saveField(prefs, OnboardingPrefsKeys.preferredStores,
            () => prefs.setStringList(OnboardingPrefsKeys.preferredStores,
                validatedStores.toList()..sort())),
        _saveField(prefs, OnboardingPrefsKeys.shoppingFrequency,
            () => prefs.setInt(OnboardingPrefsKeys.shoppingFrequency,
                shoppingFrequency)),
        _saveField(prefs, OnboardingPrefsKeys.shoppingDays,
            () => prefs.setString(OnboardingPrefsKeys.shoppingDays,
                validatedDays.toList().join(','))),
        _saveField(prefs, OnboardingPrefsKeys.hasChildren,
            () => prefs.setBool(OnboardingPrefsKeys.hasChildren, hasChildren)),
        _saveField(prefs, OnboardingPrefsKeys.children,
            () => prefs.setString(OnboardingPrefsKeys.children,
                jsonEncode(validatedChildren.map((c) => c.toJson()).toList()))),
        _saveField(prefs, OnboardingPrefsKeys.shareLists,
            () => prefs.setBool(OnboardingPrefsKeys.shareLists, shareLists)),
        _saveField(prefs, OnboardingPrefsKeys.reminderTime,
            () => prefs.setString(OnboardingPrefsKeys.reminderTime, validatedTime)),
      ]);

      final failedFields = <String>[
        for (var i = 0; i < results.length; i++)
          if (!results[i]) fieldNames[i],
      ];

      final success = failedFields.isEmpty;

      if (kDebugMode) {
        if (success) {
        } else {
        }
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
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
        } else {
        }
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
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
      }
      
      final prefs = await SharedPreferences.getInstance();

      // בדיקת schema version למיגרציות עתידיות
      final schemaVersion = prefs.getInt(OnboardingPrefsKeys.schemaVersion) ?? 1;
      if (kDebugMode && schemaVersion != kCurrentSchemaVersion) {
      }

      // טעינת נתונים עם אזהרות ספציפיות
      final familySizeValue = prefs.getInt(OnboardingPrefsKeys.familySize);
      if (kDebugMode && familySizeValue == null) {
      }

      final storesValue = prefs.getStringList(OnboardingPrefsKeys.preferredStores);
      if (kDebugMode && (storesValue == null || storesValue.isEmpty)) {
      }

      final frequencyValue = prefs.getInt(OnboardingPrefsKeys.shoppingFrequency);
      if (kDebugMode && frequencyValue == null) {
      }

      final daysValue = prefs.getString(OnboardingPrefsKeys.shoppingDays);
      final daysSet = daysValue != null && daysValue.isNotEmpty
          ? daysValue.split(',').map(int.tryParse).whereType<int>().toSet()
          : <int>{};
      if (kDebugMode && (daysValue == null || daysValue.isEmpty)) {
      }

      final hasChildrenValue = prefs.getBool(OnboardingPrefsKeys.hasChildren);
      if (kDebugMode && hasChildrenValue == null) {
      }

      // ✅ טעינת ילדים מ-JSON
      final childrenValue = prefs.getString(OnboardingPrefsKeys.children);
      List<Child> childrenList = [];
      if (childrenValue != null && childrenValue.isNotEmpty) {
        try {
          final jsonList = jsonDecode(childrenValue) as List<dynamic>;
          childrenList = jsonList.map((json) => Child.fromJson(json as Map<String, dynamic>)).toList();
        } catch (e) {
          if (kDebugMode) {
          }
        }
      }
      if (kDebugMode && childrenList.isEmpty) {
      }

      final reminderValue = prefs.getString(OnboardingPrefsKeys.reminderTime);
      if (kDebugMode && reminderValue == null) {
      }

      final data = OnboardingData(
        familySize: familySizeValue,
        preferredStores: (storesValue ?? []).toSet(),
        shoppingFrequency: frequencyValue,
        shoppingDays: daysSet,
        hasChildren: hasChildrenValue ?? false,
        children: childrenList,
        shareLists: prefs.getBool(OnboardingPrefsKeys.shareLists) ?? false,
        reminderTime: reminderValue,
      );

      if (kDebugMode) {
      }
      
      return data;
    } catch (e) {
      if (kDebugMode) {
      }
      return OnboardingData();
    }
  }

  /// איפוס לערכי ברירת מחדל
  static OnboardingData defaults() {
    if (kDebugMode) {
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
      }
      
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.setBool(
        OnboardingPrefsKeys.seenOnboarding,
        true,
      );

      if (kDebugMode) {
        if (result) {
        } else {
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
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
      }
      
      return hasSeen;
    } catch (e) {
      if (kDebugMode) {
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
        OnboardingPrefsKeys.children,
        OnboardingPrefsKeys.shareLists,
        OnboardingPrefsKeys.reminderTime,
      ];

      // ✅ v3.0: מחיקה מקבילית עם Future.wait
      await Future.wait(keys.map((key) async {
        await prefs.remove(key);
        if (kDebugMode) {
        }
      }));

      if (kDebugMode) {
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
      }
      return false;
    }
  }
}
