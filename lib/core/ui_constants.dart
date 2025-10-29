// 📄 File: lib/core/ui_constants.dart
//
// 🎨 UI Constants for MemoZap
// 
// Centralized constants for consistent UI design:
// - Spacing (8dp grid system)
// - Colors (Sticky Notes palette + backgrounds)
// - Sizes (buttons, touch targets, etc.)
// - Durations (animations, snackbars)
//
// Note: These constants are used across the app for consistency.
// Refer to DESIGN.md for full design system documentation.
//
// Version: 2.0
// Created: 31/10/2025
// Last Updated: 29/10/2025

import 'dart:ui';

// ═══════════════════════════════════════════════════════════════════════════
// SPACING (8dp Grid System)
// ═══════════════════════════════════════════════════════════════════════════

const double kSpacingXTiny = 4.0;   // Extra tiny spacing
const double kSpacingTiny = 6.0;    // Tiny spacing
const double kSpacingSmall = 8.0;   // Small spacing
const double kSpacingMedium = 16.0; // Default spacing ⭐
const double kSpacingLarge = 24.0;  // Large spacing
const double kSpacingXLarge = 32.0; // Extra large spacing

// ═══════════════════════════════════════════════════════════════════════════
// COLORS - Sticky Notes Palette
// ═══════════════════════════════════════════════════════════════════════════

const Color kStickyYellow = Color(0xFFFFF59D);  // Primary, Logo
const Color kStickyPink = Color(0xFFF48FB1);    // Alerts, Delete
const Color kStickyGreen = Color(0xFFA5D6A7);   // Success, Add
const Color kStickyCyan = Color(0xFF80DEEA);    // Info, Secondary
const Color kStickyPurple = Color(0xFFCE93D8);  // Creative features
const Color kStickyOrange = Color(0xFFFFAB91);  // Warnings

// ═══════════════════════════════════════════════════════════════════════════
// COLORS - Backgrounds
// ═══════════════════════════════════════════════════════════════════════════

const Color kPaperBackground = Color(0xFFF5F5F5);      // Light mode paper
const Color kDarkPaperBackground = Color(0xFF1E1E1E);  // Dark mode paper

// ═══════════════════════════════════════════════════════════════════════════
// SIZES
// ═══════════════════════════════════════════════════════════════════════════

const double kButtonHeight = 48.0;       // Standard button height
const double kButtonHeightSmall = 36.0;  // Compact button height
const double kButtonHeightLarge = 56.0;  // Prominent button height
const double kMinTouchTarget = 44.0;     // Minimum touch target (accessibility)

// ═══════════════════════════════════════════════════════════════════════════
// DURATIONS
// ═══════════════════════════════════════════════════════════════════════════

const Duration kAnimationDuration = Duration(milliseconds: 250);       // Default animation
const Duration kAnimationDurationShort = Duration(milliseconds: 150);  // Short animation
const Duration kAnimationDurationLong = Duration(milliseconds: 500);   // Long animation

const Duration kSnackBarDuration = Duration(seconds: 3);      // Default SnackBar
const Duration kSnackBarDurationShort = Duration(seconds: 2); // Short SnackBar
const Duration kSnackBarDurationLong = Duration(seconds: 5);  // Long SnackBar
