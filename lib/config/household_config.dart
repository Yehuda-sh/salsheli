// 📄 File: lib/config/household_config.dart
//
// 🎯 מטרה: הגדרות סוגי קבוצות/משקי בית
//
// 📋 כולל:
// - סוגי קבוצות (משפחה, ועד בית, ועד גן, שותפים)
// - תיאורים
// - אייקונים
//
// 🔄 שימוש:
// ```dart
// import 'package:salsheli/config/household_config.dart';
// 
// // רשימת כל הסוגים
// final types = HouseholdConfig.allTypes;
// 
// // קבלת תיאור
// final label = HouseholdConfig.getLabel('family');
// 
// // אייקון
// final icon = HouseholdConfig.getIcon('family');
// ```
//
// Version: 1.0
// Created: 08/10/2025

import 'package:flutter/material.dart';

/// תצורת סוגי קבוצות/משקי בית
class HouseholdConfig {
  HouseholdConfig._(); // מונע יצירת instances

  // ========================================
  // IDs של סוגי קבוצות
  // ========================================
  
  static const String family = 'family';
  static const String buildingCommittee = 'building_committee';
  static const String kindergartenCommittee = 'kindergarten_committee';
  static const String roommates = 'roommates';
  static const String other = 'other';

  // ========================================
  // רשימת כל הסוגים
  // ========================================
  
  static const List<String> allTypes = [
    family,
    buildingCommittee,
    kindergartenCommittee,
    roommates,
    other,
  ];

  // ========================================
  // קבלת תווית בעברית
  // ========================================
  
  static String getLabel(String type) {
    switch (type) {
      case family:
        return 'משפחה';
      case buildingCommittee:
        return 'ועד בית';
      case kindergartenCommittee:
        return 'ועד גן';
      case roommates:
        return 'שותפים';
      case other:
        return 'אחר';
      default:
        return type;
    }
  }

  // ========================================
  // קבלת אייקון
  // ========================================
  
  static IconData getIcon(String type) {
    switch (type) {
      case family:
        return Icons.family_restroom;
      case buildingCommittee:
        return Icons.apartment;
      case kindergartenCommittee:
        return Icons.child_care;
      case roommates:
        return Icons.people;
      case other:
        return Icons.groups;
      default:
        return Icons.group;
    }
  }

  // ========================================
  // קבלת תיאור
  // ========================================
  
  static String getDescription(String type) {
    switch (type) {
      case family:
        return 'משפחה משותפת';
      case buildingCommittee:
        return 'ניהול קניות לועד בית';
      case kindergartenCommittee:
        return 'ניהול קניות לועד גן';
      case roommates:
        return 'שותפים לדירה';
      case other:
        return 'קבוצה מותאמת אישית';
      default:
        return '';
    }
  }

  // ========================================
  // בדיקת תקינות
  // ========================================
  
  static bool isValid(String type) {
    return allTypes.contains(type);
  }
}
