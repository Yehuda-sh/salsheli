// 📄 File: lib/config/household_config.dart
//
// 🏠 Household Configuration
//
// Defines types of households and their properties:
// - Family (משפחה)
// - Building Committee (ועד בית)
// - Kindergarten Committee (ועד גן)
//
// Used in settings for household type selection.
//
// Version: 1.0
// Created: 2/11/2025

import 'package:flutter/material.dart';

class HouseholdConfig {
  // Household types
  static const String family = 'family';
  static const String building = 'building';
  static const String kindergarten = 'kindergarten';

  // All available types
  static const List<String> allTypes = [family, building, kindergarten];

  // Get icon for household type
  static IconData getIcon(String type) {
    switch (type) {
      case family:
        return Icons.family_restroom;
      case building:
        return Icons.apartment;
      case kindergarten:
        return Icons.child_care;
      default:
        return Icons.group;
    }
  }

  // Get Hebrew label for household type
  static String getLabel(String type) {
    switch (type) {
      case family:
        return 'משפחה';
      case building:
        return 'ועד בית';
      case kindergarten:
        return 'ועד גן';
      default:
        return 'קבוצה';
    }
  }
}
