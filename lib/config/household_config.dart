// 📄 File: lib/config/household_config.dart
//
// 🎯 תיאור: הגדרות סוגי קבוצות/משקי בית
//
// 🔧 תכונות:
// ✅ סוגי קבוצות: משפחה, ועד בית, ועד גן
// ✅ אייקון ותווית לכל סוג
// ✅ רשימת כל הסוגים הזמינים
//
// Version: 1.0
// Created: 20/10/2025

import 'package:flutter/material.dart';

/// קונפיגורציה של סוגי קבוצות/משקי בית
class HouseholdConfig {
  // סוגי קבוצות
  static const String family = 'family';
  static const String buildingCommittee = 'building_committee';
  static const String kindergartenCommittee = 'kindergarten_committee';

  /// רשימת כל הסוגים הזמינים
  static const List<String> allTypes = [
    family,
    buildingCommittee,
    kindergartenCommittee,
  ];

  /// מחזיר אייקון לפי סוג הקבוצה
  static IconData getIcon(String type) {
    switch (type) {
      case family:
        return Icons.family_restroom;
      case buildingCommittee:
        return Icons.apartment;
      case kindergartenCommittee:
        return Icons.school;
      default:
        return Icons.group;
    }
  }

  /// מחזיר תווית לפי סוג הקבוצה
  static String getLabel(String type) {
    switch (type) {
      case family:
        return 'משפחה';
      case buildingCommittee:
        return 'ועד בית';
      case kindergartenCommittee:
        return 'ועד גן';
      default:
        return 'קבוצה';
    }
  }
}
