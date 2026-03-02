// 📄 lib/core/ui_constants.dart
//
// קבועי UI מרכזיים לעיצוב עקבי באפליקציה.
// - Spacing (גריד גמיש - ערכים נפוצים לפי צורך עיצובי)
// - Colors (פלטת Sticky Notes + רקעים)
// - Sizes (כפתורים, אייקונים, אווטארים)
// - Durations (אנימציות, snackbars)
//
// 📋 Features:
// - הגדרת רמות Glassmorphism (Low/Medium/High)
// - קבועי Haptic Feedback
// - צבעי Dark Mode מופחתי רוויה (Desaturated)
// - Border Radius מורחב (כולל Super)
//
// 📝 Version: 4.0
// 📅 Updated: 22/02/2026

import 'dart:ui';

// ═══════════════════════════════════════════════════════════════════════════
// SPACING (Flexible Grid - ערכים מותאמים לעיצוב, לא 8dp מדויק)
// ═══════════════════════════════════════════════════════════════════════════

const double kSpacingXTiny = 4.0;      // 4dp - Extra tiny spacing
const double kSpacingTiny = 6.0;       // 6dp - Tiny spacing (fine-tuned)
const double kSpacingSmall = 8.0;      // 8dp - Small spacing
const double kSpacingSmallPlus = 12.0; // 12dp - Between small and medium
const double kSpacingMedium = 16.0;    // 16dp - Default spacing ⭐
const double kSpacingLarge = 24.0;     // 24dp - Large spacing
const double kSpacingXLarge = 32.0;    // 32dp - Extra large spacing

// ═══════════════════════════════════════════════════════════════════════════
// COLORS - Sticky Notes Palette (Light Mode)
// ═══════════════════════════════════════════════════════════════════════════

const Color kStickyYellow = Color(0xFFFFF59D);  // Primary, Logo
const Color kStickyPink = Color(0xFFF48FB1);    // Alerts, Delete
const Color kStickyGreen = Color(0xFFA5D6A7);   // Success, Add
const Color kStickyCyan = Color(0xFF80DEEA);    // Info, Secondary
const Color kStickyPurple = Color(0xFFCE93D8);  // Creative features
const Color kStickyOrange = Color(0xFFFFAB91);  // Warnings
const Color kStickyGray = Color(0xFFE0E0E0);    // Neutral, Actions

// ═══════════════════════════════════════════════════════════════════════════
// COLORS - Sticky Notes Palette (Dark Mode - Desaturated ~17%)
// ═══════════════════════════════════════════════════════════════════════════
// הפחתת רוויה (Saturation) ב-15-20% למניעת "ריצוד" בעיניים
// ומראה יוקרתי יותר ב-Dark Mode.

const Color kStickyYellowDark = Color(0xFFC6AF3E);  // Primary, Logo (muted gold)
const Color kStickyPinkDark = Color(0xFFB3265E);    // Alerts, Delete (muted rose)
const Color kStickyGreenDark = Color(0xFF6DB471);   // Success, Add (muted sage)
const Color kStickyCyanDark = Color(0xFF109FB0);    // Info, Secondary (muted teal)
const Color kStickyPurpleDark = Color(0xFF9433A4);  // Creative features (muted plum)
const Color kStickyOrangeDark = Color(0xFFEC6135);  // Warnings (muted coral)

// ═══════════════════════════════════════════════════════════════════════════
// COLORS - Notebook Lines
// ═══════════════════════════════════════════════════════════════════════════

const Color kNotebookBlue = Color(0xFF4285F4);   // Blue notebook lines
const Color kNotebookBlueSoft = Color(0xFF9CA8B8); // Soft grayish-blue lines (Hybrid Premium)
const Color kNotebookRed = Color(0xFFE53935);    // Red notebook line

// ═══════════════════════════════════════════════════════════════════════════
// Notebook Background Properties
// ═══════════════════════════════════════════════════════════════════════════
// שימוש: color.withValues(alpha: kNotebookLineOpacity)

/// שקיפות קווים כחולים — `color.withValues(alpha: kNotebookLineOpacity)`
const double kNotebookLineOpacity = 0.5;

/// שקיפות עדינה (Hybrid Premium: 3-8%) — `color.withValues(alpha: kNotebookLineOpacitySubtle)`
const double kNotebookLineOpacitySubtle = 0.06;

/// רווח בין קווים כחולים (מותאם לגובה שורת פריט)
const double kNotebookLineSpacing = 48.0;

/// שקיפות קו אדום — `color.withValues(alpha: kNotebookRedLineOpacity)`
const double kNotebookRedLineOpacity = 0.4;

/// רוחב קו אדום
const double kNotebookRedLineWidth = 2.0;

/// מרחק קו אדום מהקצה (קרוב יותר למקסום שטח תוכן)
const double kNotebookRedLineOffset = 48.0;

// ═══════════════════════════════════════════════════════════════════════════
// GLASS / BLUR EFFECT PROPERTIES (Glassmorphism Levels)
// ═══════════════════════════════════════════════════════════════════════════

/// טשטוש עדין — רקע קל, tooltips
const double kGlassBlurLow = 5.0;

/// טשטוש רגיל — bottom sheets, headers צפים
const double kGlassBlurMedium = 10.0;

/// טשטוש חזק — modals, overlays מרכזיים
const double kGlassBlurHigh = 20.0;

/// Alias לתאימות לאחור — שווה ל-[kGlassBlurMedium]
const double kGlassBlurSigma = kGlassBlurMedium;

/// שקיפות אפקט Highlighter על כותרות — `color.withValues(alpha: kHighlightOpacity)`
const double kHighlightOpacity = 0.3;

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

const Duration kAnimationDurationShort = Duration(milliseconds: 150);  // Short animation
const Duration kAnimationDurationMedium = Duration(milliseconds: 350); // Medium animation
const Duration kAnimationDurationSlow = Duration(milliseconds: 2000);  // Slow animation (shimmer)

const Duration kSnackBarDuration = Duration(seconds: 3);      // Default SnackBar
const Duration kSnackBarDurationShort = Duration(seconds: 2); // Short SnackBar
const Duration kSnackBarDurationLong = Duration(seconds: 5);  // Long SnackBar

const Duration kDoubleTapTimeout = Duration(seconds: 2);      // Double-tap detection timeout

// ═══════════════════════════════════════════════════════════════════════════
// HAPTIC DELAYS
// ═══════════════════════════════════════════════════════════════════════════

/// השהיה מינימלית לפני משוב רטט (מונע קריאות כפולות)
const Duration kHapticFeedbackDelay = Duration(milliseconds: 10);

/// השהיה לפני רטט בלחיצה ארוכה (long press)
const Duration kHapticLongPressDelay = Duration(milliseconds: 50);

// ═══════════════════════════════════════════════════════════════════════════
// SNACKBAR MARGINS
// ═══════════════════════════════════════════════════════════════════════════

const double kSnackBarBottomMargin = 80.0;      // Bottom margin (above nav bar)
const double kSnackBarHorizontalMargin = 16.0;  // Left & right margins

// ═══════════════════════════════════════════════════════════════════════════
// FAB MARGINS
// ═══════════════════════════════════════════════════════════════════════════

const double kFabMargin = 16.0;                 // FAB margin from edges

// ═══════════════════════════════════════════════════════════════════════════
// INPUT PADDING
// ═══════════════════════════════════════════════════════════════════════════

const double kInputPadding = 16.0;  // Standard input padding

// ═══════════════════════════════════════════════════════════════════════════
// BORDER RADIUS
// ═══════════════════════════════════════════════════════════════════════════

const double kBorderRadius = 12.0;       // Default border radius
const double kBorderRadiusSmall = 8.0;   // Small border radius
const double kBorderRadiusUnified = 14.0; // Unified border radius (Hybrid Premium)
const double kBorderRadiusLarge = 16.0;  // Large border radius

/// עיגול גדול לאלמנטים צפים ובאנרים מרכזיים
const double kBorderRadiusSuper = 24.0;

// ═══════════════════════════════════════════════════════════════════════════
// BORDER WIDTH
// ═══════════════════════════════════════════════════════════════════════════

const double kBorderWidthFocused = 2.0;      // Border width when focused
const double kBorderWidthThick = 3.0;        // Thick border
const double kBorderWidthExtraThick = 4.0;   // Extra thick border

// ═══════════════════════════════════════════════════════════════════════════
// ELEVATION
// ═══════════════════════════════════════════════════════════════════════════

const double kCardElevation = 2.0;       // Card elevation (default)
const double kCardElevationLow = 1.0;       // Low card elevation
const double kCardElevationHigh = 4.0;      // High card elevation

// ═══════════════════════════════════════════════════════════════════════════
// OPACITY
// ═══════════════════════════════════════════════════════════════════════════
// שימוש: color.withValues(alpha: kOpacityMedium)

const double kOpacityMinimal = 0.05; // Minimal opacity (shimmer effect)
const double kOpacityVeryLow = 0.1;  // Very low opacity
const double kOpacityLow = 0.2;      // Low opacity
const double kOpacityLight = 0.3;   // Light opacity
const double kOpacityMedium = 0.5;  // Medium opacity

// ═══════════════════════════════════════════════════════════════════════════
// PROGRESS INDICATOR
// ═══════════════════════════════════════════════════════════════════════════

const double kProgressIndicatorHeight = 4.0;  // Linear progress indicator height

/// שקיפות רקע — `color.withValues(alpha: kProgressIndicatorBackgroundAlpha)`
const double kProgressIndicatorBackgroundAlpha = 0.2;

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
const double kFontSizeMedium = 14.0;  // Medium text (between small and body)
const double kFontSizeBody = 16.0;    // Body text
const double kFontSizeLarge = 20.0;   // Large text
const double kFontSizeXLarge = 28.0;  // Extra large text (titles)

// ═══════════════════════════════════════════════════════════════════════════
// ICON SIZES
// ═══════════════════════════════════════════════════════════════════════════
// Note: kIconSize is an alias for kIconSizeMedium (both 24.0)
// Use kIconSize for semantic default, kIconSizeMedium for explicit sizing

const double kIconSizeSmall = 16.0;    // Small icons
const double kIconSizeMedium = 24.0;   // Medium icons (Material default)
const double kIconSize = kIconSizeMedium; // Alias: default icon size
const double kIconSizeProfile = 32.0;  // Profile icons
const double kIconSizeLarge = 36.0;    // Large icons
const double kIconSizeXLarge = 48.0;   // Extra large icons
const double kIconSizeXXLarge = 64.0;  // Extra extra large icons

// ═══════════════════════════════════════════════════════════════════════════
// AVATAR SIZES
// ═══════════════════════════════════════════════════════════════════════════

const double kAvatarRadiusTiny = 12.0;   // Tiny avatar radius
const double kAvatarRadiusSmall = 16.0;  // Small avatar radius
const double kAvatarRadius = 32.0;       // Default avatar radius

// ═══════════════════════════════════════════════════════════════════════════
// FORM FIELD SIZES
// ═══════════════════════════════════════════════════════════════════════════

const double kFieldWidthNarrow = 80.0;   // Narrow field width (quantity inputs)
const double kChipHeight = 48.0;          // Filter chip container height

// ═══════════════════════════════════════════════════════════════════════════
// STICKY BUTTON STYLES
// ═══════════════════════════════════════════════════════════════════════════

const double kStickyButtonRadius = 12.0;  // Border radius for sticky buttons

// ═══════════════════════════════════════════════════════════════════════════
// SHADOW STYLES
// ═══════════════════════════════════════════════════════════════════════════

const double kStickyShadowPrimaryOpacity = 0.3;   // Primary shadow opacity
const double kStickyShadowPrimaryBlur = 6.0;      // Primary shadow blur radius
const double kStickyShadowPrimaryOffsetX = 2.0;   // Primary shadow X offset
const double kStickyShadowPrimaryOffsetY = 4.0;   // Primary shadow Y offset
const double kStickyShadowSecondaryOpacity = 0.15; // Secondary shadow opacity
const double kStickyShadowSecondaryBlur = 10.0;    // Secondary shadow blur radius
const double kStickyShadowSecondaryOffsetY = 8.0;  // Secondary shadow Y offset

// ═══════════════════════════════════════════════════════════════════════════
// STICKY NOTE STYLES
// ═══════════════════════════════════════════════════════════════════════════

const double kStickyNoteRadius = 2.0;     // Border radius for sticky notes
const double kStickyLogoSize = 80.0;      // Size of sticky note logo (width & height)
const double kStickyLogoIconSize = 40.0;  // Icon size in sticky logo

// Logo Shadow Styles
const double kStickyLogoShadowPrimaryOpacity = 0.4;   // Logo primary shadow opacity
const double kStickyLogoShadowPrimaryBlur = 8.0;      // Logo primary shadow blur
const double kStickyLogoShadowPrimaryOffsetY = 4.0;   // Logo primary shadow Y offset
const double kStickyLogoShadowSecondaryOpacity = 0.2; // Logo secondary shadow opacity
const double kStickyLogoShadowSecondaryBlur = 12.0;   // Logo secondary shadow blur
const double kStickyLogoShadowSecondaryOffsetY = 8.0; // Logo secondary shadow Y offset

// Logo Glow Effect
const double kLogoGlowPadding = 32.0;  // Padding around logo for glow effect
const double kShimmerAngle = 0.0;      // Shimmer effect angle (radians)
