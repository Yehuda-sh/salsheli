// 📄 File: lib/core/constants.dart
//
// 🎯 Core Constants for MemoZap
//
// Application-wide constants for business logic:
// - Family size limits
// - Children age groups
// - Schema versioning
//
// Note: UI constants (colors, spacing) → ui_constants.dart
// Note: Firestore constants → repositories/constants/repository_constants.dart
// Note: Category config → config/filters_config.dart
// Note: Storage locations → config/storage_locations_config.dart
//
// Version: 1.2
// Created: 29/10/2025
// Last Updated: 30/11/2025

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
  '0-1', // תינוקות
  '2-3', // גיל הרך
  '4-6', // גן
  '7-12', // בית ספר
  '13-18', // נוער
};

// ═══════════════════════════════════════════════════════════════════════════
// SCHEMA VERSION
// ═══════════════════════════════════════════════════════════════════════════

/// Current schema version for data migrations
const int kCurrentSchemaVersion = 1;
