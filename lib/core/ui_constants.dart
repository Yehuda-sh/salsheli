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
// Version: 2.1
// Created: 31/10/2025
// Last Updated: 29/10/2025
//
// ⭐ Version 2.1 Changes (29/10/2025):
// - Added kDoubleTapTimeout (2 seconds) for double-tap detection
// - Added SnackBar margins (kSnackBarBottomMargin, kSnackBarHorizontalMargin)
// - Added Border Radius constants (kBorderRadiusSmall/Medium/Large)

import 'dart:ui';

// ═══════════════════════════════════════════════════════════════════════════
// SPACING (8dp Grid System)
// ═══════════════════════════════════════════════════════════════════════════

const double kSpacingXTiny = 4.0;   // Extra tiny spacing
const double kSpacingTiny = 6.0;    // Tiny spacing
const double kSpacingSmall = 8.0;   // Small spacing
const double kSpacingSmallPlus = 12.0; // Between small and medium
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
// COLORS - Notebook Lines
// ═══════════════════════════════════════════════════════════════════════════

const Color kNotebookBlue = Color(0xFF4285F4);   // Blue notebook lines
const Color kNotebookRed = Color(0xFFE53935);    // Red notebook line

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
// BUTTON PADDING
// ═══════════════════════════════════════════════════════════════════════════

const double kButtonPaddingHorizontal = 24.0;  // Horizontal button padding
const double kButtonPaddingVertical = 12.0;    // Vertical button padding

// ═══════════════════════════════════════════════════════════════════════════
// CARD MARGINS
// ═══════════════════════════════════════════════════════════════════════════

const double kCardMarginVertical = 8.0;  // Vertical card margin

// ═══════════════════════════════════════════════════════════════════════════
// LIST TILE PADDING
// ═══════════════════════════════════════════════════════════════════════════

const double kListTilePaddingStart = 16.0;  // ListTile start padding (RTL)
const double kListTilePaddingEnd = 8.0;     // ListTile end padding (RTL)

// ═══════════════════════════════════════════════════════════════════════════
// DURATIONS
// ═══════════════════════════════════════════════════════════════════════════

const Duration kAnimationDuration = Duration(milliseconds: 250);       // Default animation
const Duration kAnimationDurationShort = Duration(milliseconds: 150);  // Short animation
const Duration kAnimationDurationLong = Duration(milliseconds: 500);   // Long animation

const Duration kSnackBarDuration = Duration(seconds: 3);      // Default SnackBar
const Duration kSnackBarDurationShort = Duration(seconds: 2); // Short SnackBar
const Duration kSnackBarDurationLong = Duration(seconds: 5);  // Long SnackBar

const Duration kDoubleTapTimeout = Duration(seconds: 2);      // Double-tap detection timeout

// ═══════════════════════════════════════════════════════════════════════════
// SNACKBAR MARGINS
// ═══════════════════════════════════════════════════════════════════════════

const double kSnackBarBottomMargin = 80.0;      // Bottom margin (above nav bar)
const double kSnackBarHorizontalMargin = 16.0;  // Left & right margins

// ═══════════════════════════════════════════════════════════════════════════
// INPUT PADDING
// ═══════════════════════════════════════════════════════════════════════════

const double kInputPadding = 16.0;  // Standard input padding

// ═══════════════════════════════════════════════════════════════════════════
// BORDER RADIUS
// ═══════════════════════════════════════════════════════════════════════════

const double kBorderRadius = 12.0;       // Default border radius
const double kBorderRadiusSmall = 8.0;   // Small border radius
const double kBorderRadiusMedium = 12.0; // Medium border radius
const double kBorderRadiusLarge = 16.0;  // Large border radius

// ═══════════════════════════════════════════════════════════════════════════
// BORDER WIDTH
// ═══════════════════════════════════════════════════════════════════════════

const double kBorderWidthFocused = 2.0;  // Border width when focused

// ═══════════════════════════════════════════════════════════════════════════
// OPACITY
// ═══════════════════════════════════════════════════════════════════════════

const double kOpacityLight = 0.3;   // Light opacity
const double kOpacityMedium = 0.5;  // Medium opacity

// ═══════════════════════════════════════════════════════════════════════════
// PROGRESS INDICATOR
// ═══════════════════════════════════════════════════════════════════════════

const double kProgressIndicatorHeight = 4.0;  // Linear progress indicator height

// ═══════════════════════════════════════════════════════════════════════════
// SPLASH GRADIENT COLORS
// ═══════════════════════════════════════════════════════════════════════════

// Light mode gradient
const Color kSplashGradientStart = Color(0xFF4A90E2);   // Blue
const Color kSplashGradientMiddle = Color(0xFF9B59B6);  // Purple
const Color kSplashGradientEnd = Color(0xFFE91E63);     // Pink

// Dark mode gradient
const Color kSplashGradientStartDark = Color(0xFF1E3A8A);  // Dark blue
const Color kSplashGradientMiddleDark = Color(0xFF6B21A8); // Dark purple
const Color kSplashGradientEndDark = Color(0xFF9F1239);    // Dark pink

// ═══════════════════════════════════════════════════════════════════════════
// TYPOGRAPHY
// ═══════════════════════════════════════════════════════════════════════════

const double kFontSizeTiny = 10.0;    // Tiny text (smaller than small)
const double kFontSizeSmall = 12.0;   // Small text
const double kFontSizeBody = 16.0;    // Body text
const double kFontSizeLarge = 20.0;   // Large text
const double kFontSizeXLarge = 28.0;  // Extra large text (titles)

// ═══════════════════════════════════════════════════════════════════════════
// ICON SIZES
// ═══════════════════════════════════════════════════════════════════════════

const double kIconSizeSmall = 16.0;    // Small icons
const double kIconSizeMedium = 24.0;   // Medium icons (default)
const double kIconSizeXLarge = 48.0;   // Extra large icons
const double kIconSizeXXLarge = 64.0;  // Extra extra large icons
