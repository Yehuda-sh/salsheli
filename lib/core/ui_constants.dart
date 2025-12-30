// 📄 lib/core/ui_constants.dart
//
// קבועי UI מרכזיים לעיצוב עקבי באפליקציה.
// - Spacing (מבוסס 8dp grid)
// - Colors (פלטת Sticky Notes + רקעים)
// - Sizes (כפתורים, אייקונים, אווטארים)
// - Durations (אנימציות, snackbars)

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
// COLORS - Sticky Notes Palette (Dark Mode)
// ═══════════════════════════════════════════════════════════════════════════

const Color kStickyYellowDark = Color(0xFFD4B830);  // Primary, Logo (darker yellow)
const Color kStickyPinkDark = Color(0xFFC2185B);    // Alerts, Delete (darker pink)
const Color kStickyGreenDark = Color(0xFF66BB6A);   // Success, Add (darker green)
const Color kStickyCyanDark = Color(0xFF00ACC1);    // Info, Secondary (darker cyan)
const Color kStickyPurpleDark = Color(0xFF9C27B0);  // Creative features (darker purple)
const Color kStickyOrangeDark = Color(0xFFFF5722);  // Warnings (darker orange)

// ═══════════════════════════════════════════════════════════════════════════
// COLORS - Notebook Lines
// ═══════════════════════════════════════════════════════════════════════════

const Color kNotebookBlue = Color(0xFF4285F4);   // Blue notebook lines
const Color kNotebookRed = Color(0xFFE53935);    // Red notebook line

// Notebook Background Properties
const double kNotebookLineOpacity = 0.5;         // Opacity for blue lines
const double kNotebookLineSpacing = 48.0;        // Spacing between blue lines (fits item row)
const double kNotebookRedLineOpacity = 0.4;      // Opacity for red line
const double kNotebookRedLineWidth = 2.0;        // Width of red line
const double kNotebookRedLineOffset = 60.0;      // Offset of red line from left

// Glass/Blur Effect Properties
const double kGlassBlurSigma = 10.0;             // Blur sigma for frosted glass effect
const double kHighlightOpacity = 0.3;            // Opacity for highlighter effect on headers

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
const Duration kAnimationDurationMedium = Duration(milliseconds: 350); // Medium animation
const Duration kAnimationDurationLong = Duration(milliseconds: 500);   // Long animation
const Duration kAnimationDurationSlow = Duration(milliseconds: 2000);  // Slow animation (shimmer)

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
const double kBorderRadiusMedium = 12.0; // Medium border radius
const double kBorderRadiusLarge = 16.0;  // Large border radius

// ═══════════════════════════════════════════════════════════════════════════
// BORDER WIDTH
// ═══════════════════════════════════════════════════════════════════════════

const double kBorderWidth = 1.0;            // Default border width
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

const double kOpacityMinimal = 0.05; // Minimal opacity (shimmer effect)
const double kOpacityVeryLow = 0.1;  // Very low opacity
const double kOpacityLow = 0.2;      // Low opacity
const double kOpacityLight = 0.3;   // Light opacity
const double kOpacityMedium = 0.5;  // Medium opacity

// ═══════════════════════════════════════════════════════════════════════════
// PROGRESS INDICATOR
// ═══════════════════════════════════════════════════════════════════════════

const double kProgressIndicatorHeight = 4.0;  // Linear progress indicator height
const double kProgressIndicatorBackgroundAlpha = 0.2;  // Background opacity

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

const double kIconSizeSmall = 16.0;    // Small icons
const double kIconSize = 24.0;         // Default icon size (alias for Medium)
const double kIconSizeMedium = 24.0;   // Medium icons (default)
const double kIconSizeLarge = 36.0;    // Large icons
const double kIconSizeProfile = 32.0;  // Profile icons
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
