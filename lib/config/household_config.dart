// 📄 File: lib/config/household_config.dart
//
// 🎯 מטרה: הגדרות סוגי קבוצות/משקי בית
//
// 📋 כולל:
// - 11 סוגי קבוצות (5 מקוריים + 6 חדשים)
// - תיאורים מפורטים (i18n ready)
// - אייקונים מותאמים
// - Helper methods לבדיקה וסינון
//
// 🔄 שימוש:
// ```dart
// import 'package:salsheli/config/household_config.dart';
// import 'package:salsheli/l10n/app_strings.dart';
// 
// // רשימת כל הסוגים
// final types = HouseholdConfig.allTypes;
// 
// // קבלת תיאור (i18n)
// final label = HouseholdConfig.getLabel('family');
// 
// // אייקון
// final icon = HouseholdConfig.getIcon('family');
// 
// // Helper methods
// final isValid = HouseholdConfig.isValid('family'); // true
// final fallback = HouseholdConfig.getTypeOrDefault(null); // 'family'
// final primary = HouseholdConfig.primaryTypes; // ללא 'other'
// ```
//
// Version: 2.0 - i18n Integration + 6 סוגים חדשים
// Created: 08/10/2025
// Updated: 08/10/2025

import 'package:flutter/material.dart';
import 'package:salsheli/l10n/app_strings.dart';

/// תצורת סוגי קבוצות/משקי בית
/// 
/// תומך ב-11 סוגים:
/// - 5 מקוריים: משפחה, ועד בית, ועד גן, שותפים, אחר
/// - 6 חדשים: חברים, עמיתים, שכנים, ועד כיתה, מועדון, משפחה מורחבת
class HouseholdConfig {
  HouseholdConfig._(); // מונע יצירת instances

  // ========================================
  // IDs של סוגי קבוצות
  // ========================================
  
  // Original 5
  static const String family = 'family';
  static const String buildingCommittee = 'building_committee';
  static const String kindergartenCommittee = 'kindergarten_committee';
  static const String roommates = 'roommates';
  static const String other = 'other';
  
  // New 6
  static const String friends = 'friends';
  static const String colleagues = 'colleagues';
  static const String neighbors = 'neighbors';
  static const String classCommittee = 'class_committee';
  static const String club = 'club';
  static const String extendedFamily = 'extended_family';

  // ========================================
  // רשימת כל הסוגים (11)
  // ========================================
  
  static const List<String> allTypes = [
    family,
    buildingCommittee,
    kindergartenCommittee,
    roommates,
    friends,
    colleagues,
    neighbors,
    classCommittee,
    club,
    extendedFamily,
    other,
  ];

  // ========================================
  // קבלת תווית בעברית (i18n ready)
  // ========================================
  
  /// מחזיר תווית מתורגמת לסוג הקבוצה
  /// 
  /// דוגמאות:
  /// ```dart
  /// getLabel('family')  // 'משפחה'
  /// getLabel('friends') // 'חברים'
  /// getLabel('invalid') // 'invalid'
  /// ```
  static String getLabel(String type) {
    final h = AppStrings.household;
    switch (type) {
      // Original 5
      case family:
        return h.typeFamily;
      case buildingCommittee:
        return h.typeBuildingCommittee;
      case kindergartenCommittee:
        return h.typeKindergartenCommittee;
      case roommates:
        return h.typeRoommates;
      case other:
        return h.typeOther;
      
      // New 6
      case friends:
        return h.typeFriends;
      case colleagues:
        return h.typeColleagues;
      case neighbors:
        return h.typeNeighbors;
      case classCommittee:
        return h.typeClassCommittee;
      case club:
        return h.typeClub;
      case extendedFamily:
        return h.typeExtendedFamily;
      
      default:
        return type; // fallback
    }
  }

  // ========================================
  // קבלת אייקון
  // ========================================
  
  /// מחזיר אייקון Material מתאים לסוג הקבוצה
  /// 
  /// דוגמאות:
  /// ```dart
  /// getIcon('family')       // Icons.family_restroom
  /// getIcon('colleagues')   // Icons.business_center
  /// getIcon('invalid')      // Icons.group
  /// ```
  static IconData getIcon(String type) {
    switch (type) {
      // Original 5
      case family:
        return Icons.family_restroom;
      case buildingCommittee:
        return Icons.apartment;
      case kindergartenCommittee:
        return Icons.child_care;
      case roommates:
        return Icons.people_alt; // ✅ שופר: יותר ספציפי
      case other:
        return Icons.group_add; // ✅ שופר: מדגיש "מותאם אישית"
      
      // New 6
      case friends:
        return Icons.people_outline;
      case colleagues:
        return Icons.business_center;
      case neighbors:
        return Icons.location_city;
      case classCommittee:
        return Icons.school;
      case club:
        return Icons.groups_2;
      case extendedFamily:
        return Icons.groups_3;
      
      default:
        return Icons.group; // fallback
    }
  }

  // ========================================
  // קבלת תיאור מפורט (i18n ready)
  // ========================================
  
  /// מחזיר תיאור מפורט לסוג הקבוצה
  /// 
  /// דוגמאות:
  /// ```dart
  /// getDescription('family')
  /// // 'ניהול קניות וצרכים משותפים למשפחה'
  /// 
  /// getDescription('colleagues')
  /// // 'רכישות משותפות וארגון ארוחות לצוות העבודה'
  /// ```
  static String getDescription(String type) {
    final h = AppStrings.household;
    switch (type) {
      // Original 5
      case family:
        return h.descFamily;
      case buildingCommittee:
        return h.descBuildingCommittee;
      case kindergartenCommittee:
        return h.descKindergartenCommittee;
      case roommates:
        return h.descRoommates;
      case other:
        return h.descOther;
      
      // New 6
      case friends:
        return h.descFriends;
      case colleagues:
        return h.descColleagues;
      case neighbors:
        return h.descNeighbors;
      case classCommittee:
        return h.descClassCommittee;
      case club:
        return h.descClub;
      case extendedFamily:
        return h.descExtendedFamily;
      
      default:
        return ''; // fallback
    }
  }

  // ========================================
  // בדיקת תקינות
  // ========================================
  
  /// בודק אם הסוג תקין (קיים ברשימה)
  /// 
  /// דוגמאות:
  /// ```dart
  /// isValid('family')   // true
  /// isValid('invalid')  // false
  /// isValid(null)       // false
  /// ```
  static bool isValid(String? type) {
    return type != null && allTypes.contains(type);
  }

  // ========================================
  // Helper Methods
  // ========================================
  
  /// מחזיר את הסוג או 'family' אם invalid
  /// 
  /// שימושי לטעינת הגדרות עם fallback:
  /// ```dart
  /// final type = prefs.getString('household_type');
  /// final validType = HouseholdConfig.getTypeOrDefault(type);
  /// // אם type == null או invalid → 'family'
  /// ```
  static String getTypeOrDefault(String? type) {
    return isValid(type) ? type! : family;
  }

  /// בודק אם הסוג הוא 'אחר' (fallback)
  /// 
  /// ```dart
  /// isOtherType('other')  // true
  /// isOtherType('family') // false
  /// ```
  static bool isOtherType(String type) {
    return type == other;
  }

  /// מחזיר רשימת סוגים ללא 'אחר'
  /// 
  /// שימושי למסכי בחירה - מציג רק סוגים עיקריים:
  /// ```dart
  /// final types = HouseholdConfig.primaryTypes;
  /// // [family, buildingCommittee, ..., extendedFamily]
  /// // ללא 'other'
  /// ```
  static List<String> get primaryTypes {
    return allTypes.where((t) => t != other).toList();
  }

  /// בודק אם הסוג קשור למשפחה
  /// 
  /// ```dart
  /// isFamilyRelated('family')         // true
  /// isFamilyRelated('extendedFamily') // true
  /// isFamilyRelated('colleagues')     // false
  /// ```
  static bool isFamilyRelated(String type) {
    return type == family || type == extendedFamily;
  }

  /// בודק אם הסוג קשור לוועדים
  /// 
  /// ```dart
  /// isCommitteeType('buildingCommittee')      // true
  /// isCommitteeType('kindergartenCommittee')  // true
  /// isCommitteeType('classCommittee')         // true
  /// isCommitteeType('family')                 // false
  /// ```
  static bool isCommitteeType(String type) {
    return type == buildingCommittee ||
        type == kindergartenCommittee ||
        type == classCommittee;
  }
}
