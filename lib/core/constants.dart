// 📄 File: lib/core/constants.dart
//
// 🎯 Core Constants for MemoZap
// 
// Application-wide constants for business logic:
// - Family size limits
// - Children age groups  
// - Schema versioning
//
// Note: UI constants (colors, spacing) are in ui_constants.dart
// Note: Firestore constants are in repositories/constants/repository_constants.dart
//
// Version: 1.0
// Created: 29/10/2025
// Last Updated: 29/10/2025

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
  '0-2',   // תינוקות
  '3-5',   // פעוטות
  '6-12',  // ילדים
  '13-18', // נוער
};

// ═══════════════════════════════════════════════════════════════════════════
// SCHEMA VERSION
// ═══════════════════════════════════════════════════════════════════════════

/// Current schema version for data migrations
const int kCurrentSchemaVersion = 1;
