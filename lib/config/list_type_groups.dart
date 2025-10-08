// 📄 File: lib/config/list_type_groups.dart
//
// Purpose: קיבוץ סוגי רשימות לקבוצות לצורך תצוגה ב-UI
//
// Features:
// - 3 קבוצות עיקריות: קניות יומיומיות, קניות מיוחדות, אירועים
// - Helper methods לקבלת קבוצה של type
// - סדר תצוגה מומלץ לכל קבוצה
// - אייקונים וצבעים לכל קבוצה
//
// Usage:
// ```dart
// // קבלת קבוצה של type
// final group = ListTypeGroups.getGroup(ListType.birthday);
// // → ListTypeGroup.events
//
// // קבלת כל הסוגים בקבוצה
// final types = ListTypeGroups.getTypesInGroup(ListTypeGroup.events);
// // → [birthday, party, wedding, picnic, holiday, gifts]
//
// // שם הקבוצה בעברית
// final name = ListTypeGroups.getGroupName(ListTypeGroup.events);
// // → 'אירועים'
//
// // אייקון הקבוצה
// final icon = ListTypeGroups.getGroupIcon(ListTypeGroup.events);
// // → '🎉'
// ```
//
// Version: 1.0
// Last Updated: 08/10/2025

import '../core/constants.dart';

/// קבוצות סוגי רשימות לתצוגה ב-UI
enum ListTypeGroup {
  shopping,   // קניות יומיומיות
  specialty,  // קניות מיוחדות
  events,     // אירועים
}

class ListTypeGroups {
  // מניעת יצירת instances
  const ListTypeGroups._();

  // ========================================
  // מיפוי Types לקבוצות
  // ========================================

  /// קניות יומיומיות - כל יום
  static const _shoppingTypes = [
    ListType.super_,
    ListType.pharmacy,
  ];

  /// קניות מיוחדות - ספציפיות
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

  /// אירועים - מסיבות וחגים
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

  /// שם הקבוצה בעברית
  static String getGroupName(ListTypeGroup group) {
    switch (group) {
      case ListTypeGroup.shopping:
        return 'קניות יומיומיות';
      case ListTypeGroup.specialty:
        return 'קניות מיוחדות';
      case ListTypeGroup.events:
        return 'אירועים';
    }
  }

  /// אייקון הקבוצה
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

  /// תיאור הקבוצה
  static String getGroupDescription(ListTypeGroup group) {
    switch (group) {
      case ListTypeGroup.shopping:
        return 'קניות שוטפות ויומיומיות';
      case ListTypeGroup.specialty:
        return 'קניות בחנויות מיוחדות';
      case ListTypeGroup.events:
        return 'רשימות לאירועים ומסיבות';
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
  static bool isEvent(String type) {
    return _eventTypes.contains(type);
  }

  /// בדיקה אם type הוא קנייה יומיומית
  static bool isShopping(String type) {
    return _shoppingTypes.contains(type);
  }

  /// בדיקה אם type הוא קנייה מיוחדת
  static bool isSpecialty(String type) {
    return _specialtyTypes.contains(type);
  }
}
