// 📄 File: lib/config/list_type_groups.dart
//
// Purpose: קיבוץ סוגי רשימות לקבוצות לצורך תצוגה ב-UI
//
// Features:
// - 3 קבוצות עיקריות: קניות יומיומיות, קניות מיוחדות, אירועים
// - Helper methods לקבלת קבוצה של type
// - סדר תצוגה מומלץ לכל קבוצה
// - אייקונים וצבעים לכל קבוצה
// - i18n ready (שמות ותיאורים דרך AppStrings)
//
// Usage:
// ```dart
// import 'package:salsheli/config/list_type_groups.dart';
// import 'package:salsheli/l10n/app_strings.dart';
// 
// // קבלת קבוצה של type
// final group = ListTypeGroups.getGroup(ListType.birthday);
// // → ListTypeGroup.events
//
// // קבלת כל הסוגים בקבוצה
// final types = ListTypeGroups.getTypesInGroup(ListTypeGroup.events);
// // → [birthday, party, wedding, picnic, holiday, gifts]
//
// // שם הקבוצה (i18n)
// final name = ListTypeGroups.getGroupName(ListTypeGroup.events);
// // → 'אירועים' (מ-AppStrings)
//
// // אייקון הקבוצה
// final icon = ListTypeGroups.getGroupIcon(ListTypeGroup.events);
// // → '🎉'
// ```
//
// Version: 2.0 - i18n Integration
// Created: 08/10/2025
// Updated: 08/10/2025

import '../core/constants.dart';
import '../l10n/app_strings.dart';

/// קבוצות סוגי רשימות לתצוגה ב-UI
enum ListTypeGroup {
  shopping,   // קניות יומיומיות
  specialty,  // קניות מיוחדות
  events,     // אירועים
}

/// מחלקת עזר לניהול קבוצות סוגי רשימות
/// 
/// מקבצת את 21 סוגי הרשימות ל-3 קבוצות לוגיות:
/// - shopping (2): super, pharmacy
/// - specialty (12): hardware, clothing, electronics...
/// - events (6): birthday, party, wedding...
class ListTypeGroups {
  // מניעת יצירת instances
  const ListTypeGroups._();

  // ========================================
  // מיפוי Types לקבוצות
  // ========================================

  /// קניות יומיומיות - כל יום (2 סוגים)
  static const _shoppingTypes = [
    ListType.super_,
    ListType.pharmacy,
  ];

  /// קניות מיוחדות - ספציפיות (12 סוגים)
  static const _specialtyTypes = [
    ListType.hardware,
    ListType.clothing,
    ListType.electronics,
    ListType.pets,
    ListType.cosmetics,
    ListType.stationery,
    ListType.toys,
    ListType.books,
    ListType.sports,
    ListType.homeDecor,
    ListType.automotive,
    ListType.baby,
  ];

  /// אירועים - מסיבות וחגים (6 סוגים)
  static const _eventTypes = [
    ListType.birthday,
    ListType.party,
    ListType.wedding,
    ListType.picnic,
    ListType.holiday,
    ListType.gifts,
  ];

  // ========================================
  // Public API
  // ========================================

  /// מחזיר את הקבוצה של type מסוים
  /// 
  /// דוגמאות:
  /// ```dart
  /// getGroup(ListType.super_)    // ListTypeGroup.shopping
  /// getGroup(ListType.birthday)  // ListTypeGroup.events
  /// getGroup(ListType.hardware)  // ListTypeGroup.specialty
  /// ```
  static ListTypeGroup getGroup(String type) {
    if (_shoppingTypes.contains(type)) {
      return ListTypeGroup.shopping;
    } else if (_eventTypes.contains(type)) {
      return ListTypeGroup.events;
    } else {
      return ListTypeGroup.specialty;
    }
  }

  /// מחזיר את כל הסוגים בקבוצה
  /// 
  /// דוגמאות:
  /// ```dart
  /// getTypesInGroup(ListTypeGroup.shopping)
  /// // [super_, pharmacy]
  /// 
  /// getTypesInGroup(ListTypeGroup.events)
  /// // [birthday, party, wedding, picnic, holiday, gifts]
  /// ```
  static List<String> getTypesInGroup(ListTypeGroup group) {
    switch (group) {
      case ListTypeGroup.shopping:
        return _shoppingTypes;
      case ListTypeGroup.specialty:
        return _specialtyTypes;
      case ListTypeGroup.events:
        return _eventTypes;
    }
  }

  /// שם הקבוצה בעברית (i18n ready)
  /// 
  /// דוגמאות:
  /// ```dart
  /// getGroupName(ListTypeGroup.shopping)   // 'קניות יומיומיות'
  /// getGroupName(ListTypeGroup.specialty)  // 'קניות מיוחדות'
  /// getGroupName(ListTypeGroup.events)     // 'אירועים'
  /// ```
  static String getGroupName(ListTypeGroup group) {
    final g = AppStrings.listTypeGroups;
    switch (group) {
      case ListTypeGroup.shopping:
        return g.nameShopping;
      case ListTypeGroup.specialty:
        return g.nameSpecialty;
      case ListTypeGroup.events:
        return g.nameEvents;
    }
  }

  /// אייקון הקבוצה (אימוג'י)
  /// 
  /// דוגמאות:
  /// ```dart
  /// getGroupIcon(ListTypeGroup.shopping)   // '🛒'
  /// getGroupIcon(ListTypeGroup.specialty)  // '🎯'
  /// getGroupIcon(ListTypeGroup.events)     // '🎉'
  /// ```
  static String getGroupIcon(ListTypeGroup group) {
    switch (group) {
      case ListTypeGroup.shopping:
        return '🛒';
      case ListTypeGroup.specialty:
        return '🎯';
      case ListTypeGroup.events:
        return '🎉';
    }
  }

  /// תיאור הקבוצה (i18n ready)
  /// 
  /// דוגמאות:
  /// ```dart
  /// getGroupDescription(ListTypeGroup.shopping)
  /// // 'קניות שוטפות ויומיומיות'
  /// 
  /// getGroupDescription(ListTypeGroup.specialty)
  /// // 'קניות בחנויות מיוחדות'
  /// ```
  static String getGroupDescription(ListTypeGroup group) {
    final g = AppStrings.listTypeGroups;
    switch (group) {
      case ListTypeGroup.shopping:
        return g.descShopping;
      case ListTypeGroup.specialty:
        return g.descSpecialty;
      case ListTypeGroup.events:
        return g.descEvents;
    }
  }

  /// כל הקבוצות בסדר תצוגה
  static const List<ListTypeGroup> allGroups = [
    ListTypeGroup.shopping,
    ListTypeGroup.specialty,
    ListTypeGroup.events,
  ];

  // ========================================
  // Helper Methods
  // ========================================

  /// בדיקה אם type הוא אירוע
  /// 
  /// דוגמה:
  /// ```dart
  /// isEvent(ListType.birthday)  // true
  /// isEvent(ListType.super_)    // false
  /// ```
  static bool isEvent(String type) {
    return _eventTypes.contains(type);
  }

  /// בדיקה אם type הוא קנייה יומיומית
  /// 
  /// דוגמה:
  /// ```dart
  /// isShopping(ListType.super_)     // true
  /// isShopping(ListType.hardware)   // false
  /// ```
  static bool isShopping(String type) {
    return _shoppingTypes.contains(type);
  }

  /// בדיקה אם type הוא קנייה מיוחדת
  /// 
  /// דוגמה:
  /// ```dart
  /// isSpecialty(ListType.hardware)  // true
  /// isSpecialty(ListType.super_)    // false
  /// ```
  static bool isSpecialty(String type) {
    return _specialtyTypes.contains(type);
  }

  /// מחזיר את מספר הסוגים בקבוצה
  /// 
  /// דוגמה:
  /// ```dart
  /// getGroupSize(ListTypeGroup.shopping)   // 2
  /// getGroupSize(ListTypeGroup.specialty)  // 12
  /// getGroupSize(ListTypeGroup.events)     // 6
  /// ```
  static int getGroupSize(ListTypeGroup group) {
    return getTypesInGroup(group).length;
  }

  /// בדיקה אם קבוצה היא הגדולה ביותר
  /// 
  /// דוגמה:
  /// ```dart
  /// isLargestGroup(ListTypeGroup.specialty)  // true (12 סוגים)
  /// isLargestGroup(ListTypeGroup.shopping)   // false (2 סוגים)
  /// ```
  static bool isLargestGroup(ListTypeGroup group) {
    return group == ListTypeGroup.specialty; // 12 types
  }
}
