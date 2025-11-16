// 📄 File: lib/core/constants.dart
//
// 🎯 Core Constants for MemoZap
// 
// Application-wide constants for business logic:
// - Family size limits
// - Children age groups  
// - Schema versioning
// - Category emojis
// - Storage locations
//
// Note: UI constants (colors, spacing) are in ui_constants.dart
// Note: Firestore constants are in repositories/constants/repository_constants.dart
//
// Version: 1.1
// Created: 29/10/2025
// Last Updated: 03/11/2025
// Changes: Updated kCategoryEmojis to match filters_config.dart categories

// ═══════════════════════════════════════════════════════════════════════════
// FAMILY SIZE
// ═══════════════════════════════════════════════════════════════════════════

const int kMinFamilySize = 1;
const int kMaxFamilySize = 10;

// ═══════════════════════════════════════════════════════════════════════════
// CHILDREN AGES
// ═══════════════════════════════════════════════════════════════════════════

/// Valid children age groups for onboarding
const Set<String> kValidChildrenAges = {
  '0-1',   // תינוקות
  '2-3',   // גיל הרך
  '4-6',   // גן
  '7-12',  // בית ספר
  '13-18', // נוער
};

// ═══════════════════════════════════════════════════════════════════════════
// SCHEMA VERSION
// ═══════════════════════════════════════════════════════════════════════════

/// Current schema version for data migrations
const int kCurrentSchemaVersion = 1;

// ═══════════════════════════════════════════════════════════════════════════
// STORAGE LOCATIONS
// ═══════════════════════════════════════════════════════════════════════════

/// מיקומי אחסון במזווה
const Map<String, Map<String, String>> kStorageLocations = {
  'main_pantry': {
    'name': 'מזווה',
    'emoji': '🏠',
  },
  'refrigerator': {
    'name': 'מקרר',
    'emoji': '❄️',
  },
  'freezer': {
    'name': 'מקפיא',
    'emoji': '🧊',
  },
  'countertop': {
    'name': 'משטח',
    'emoji': '🍎',
  },
};

// ═══════════════════════════════════════════════════════════════════════════
// CATEGORY EMOJIS
// ═══════════════════════════════════════════════════════════════════════════

/// אמוג'י לפי קטגוריה (מסונכרן עם filters_config.dart)
/// 
/// Categories match the product JSON files in assets/data/categories/
const Map<String, String> kCategoryEmojis = {
  'coffee_tea': '☕',
  'dairy': '🥛',
  'fruits': '🍎',
  'meat_fish': '🥩',
  'other': '📦',
  'personal_hygiene': '🧴',
  'rice_pasta': '🍝',
  'spices_baking': '🧂',
  'sweets_snacks': '🍬',
  'vegetables': '🥬',
};
