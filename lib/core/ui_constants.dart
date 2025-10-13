// 📄 File: lib/core/ui_constants.dart
//
// 🎯 מטרה: קבועי UI גלובליים - מידות, ריווחים, רדיוסים
//
// 📋 כולל:
// - גבהים סטנדרטיים לכפתורים
// - ריווחים קבועים (קטן, בינוני, גדול)
// - רדיוסי פינות
//
// 📝 הערות:
// - השתמש בקבועים האלה במקום ערכים קשיחים בקוד
// - שמירה על עיצוב אחיד בכל האפליקציה
//
// Version: 1.0
// Last Updated: 06/10/2025

import 'package:flutter/material.dart';

// ========================================
// גבהים
// ========================================

/// גובה סטנדרטי לכפתורים
const double kButtonHeight = 48.0;

/// גובה כפתור קטן
const double kButtonHeightSmall = 36.0;

/// גובה כפתור גדול
const double kButtonHeightLarge = 56.0;

// ========================================
// ריווחים
// ========================================

/// ריווח קטן (8px)
const double kSpacingSmall = 8.0;

/// ריווח בינוני (16px)
const double kSpacingMedium = 16.0;

/// ריווח גדול (24px)
const double kSpacingLarge = 24.0;

/// ריווח קטן מאוד (4px)
const double kSpacingTiny = 4.0;

/// ריווח קטן-קטן (6px) - בין Tiny ל-Small
const double kSpacingXTiny = 6.0;

/// ריווח קטן-בינוני (10px) - בין Small ל-SmallPlus
const double kSpacingXSmall = 10.0;

/// ריווח ענק (32px)
const double kSpacingXLarge = 32.0;

/// ריווח ענק מאוד (40px)
const double kSpacingXXLarge = 40.0;

/// ריווח קטן-פלוס (12px) - בין Small ל-Medium
const double kSpacingSmallPlus = 12.0;

/// ריווח גדול כפול (48px)
const double kSpacingDoubleLarge = 48.0;

// ========================================
// רדיוסי פינות
// ========================================

/// רדיוס פינות רגיל (12px)
const double kBorderRadius = 12.0;

/// רדיוס פינות קטן (8px)
const double kBorderRadiusSmall = 8.0;

/// רדיוס פינות גדול (16px)
const double kBorderRadiusLarge = 16.0;

/// רדיוס פינות עגול מלא (999px)
const double kBorderRadiusFull = 999.0;

// ========================================
// עובי גבולות
// ========================================

/// עובי גבול רגיל
const double kBorderWidth = 1.0;

/// עובי גבול דק
const double kBorderWidthThin = 0.5;

/// עובי גבול עבה
const double kBorderWidthThick = 2.0;

/// עובי גבול עבה מאוד (4px) - הדגשה חזקה
const double kBorderWidthExtraThick = 4.0;

/// עובי גבול focused (שדות קלט)
const double kBorderWidthFocused = 2.0;

// ========================================
// גדלי פונט
// ========================================

/// גודל פונט קטן (14px)
const double kFontSizeSmall = 14.0;

/// גודל פונט body רגיל (16px)
const double kFontSizeBody = 16.0;

/// גודל פונט בינוני (18px)
const double kFontSizeMedium = 18.0;

/// גודל פונט גדול (20px)
const double kFontSizeLarge = 20.0;

/// גודל פונט גדול מאוד (22px)
const double kFontSizeXLarge = 22.0;

/// גודל פונט תצוגה ענק (32px) - כותרות ראשיות
const double kFontSizeDisplay = 32.0;

/// גודל פונט זעיר (11px)
const double kFontSizeTiny = 11.0;

// ========================================
// Padding לכפתורים ו-Inputs
// ========================================

/// Padding אופקי לכפתורים (20px)
const double kButtonPaddingHorizontal = 20.0;

/// Padding אנכי לכפתורים (14px)
const double kButtonPaddingVertical = 14.0;

/// Padding לשדות קלט (14px)
const double kInputPadding = 14.0;

/// Padding התחלה ל-ListTile (16px)
const double kListTilePaddingStart = 16.0;

/// Padding סוף ל-ListTile (12px)
const double kListTilePaddingEnd = 12.0;

/// Card margin אנכי (8px) - זהה ל-kSpacingSmall
const double kCardMarginVertical = 8.0;

/// Card padding צפוף (14px) - קטן מעט מ-kSpacingMedium
const double kCardPaddingTight = 14.0;

/// Dialog padding (horizontal: 16, vertical: 24)
const EdgeInsets kPaddingDialog = EdgeInsets.symmetric(horizontal: 16, vertical: 24);

// ========================================
// Accessibility
// ========================================

/// גודל מינימלי לכפתורים/אלמנטים ניתנים ללחיצה (48x48)
const double kMinTouchTarget = 48.0;

// ========================================
// אייקונים
// ========================================

/// גודל אייקון רגיל
const double kIconSize = 24.0;

/// גודל אייקון קטן
const double kIconSizeSmall = 16.0;

/// גודל אייקון בינוני (20px)
const double kIconSizeMedium = 20.0;

/// גודל אייקון גדול
const double kIconSizeLarge = 32.0;

/// גודל אייקון ענק (למסכי welcome/onboarding)
const double kIconSizeXLarge = 80.0;

/// גודל אייקון ענק מאוד
const double kIconSizeXXLarge = 100.0;

/// גודל אייקון בינוני-גדול (56px) - לוגו במסך welcome
const double kIconSizeMassive = 56.0;

/// גודל אייקון פרופיל (36px)
const double kIconSizeProfile = 36.0;

/// גודל אייקון פנימי בלוגו (48px)
const double kLogoIconInnerSize = 48.0;

/// גודל אייקון social login (20px)
const double kSocialIconSize = 20.0;

/// padding מסביב ללוגו ליצירת זוהר (20px)
const double kLogoGlowPadding = 20.0;

// ========================================
// גדלי רכיבים נוספים
// ========================================

/// גובה לשורת Chips/Filters (50px)
const double kChipHeight = 50.0;

/// גודל Avatar/תמונות פרופיל (48px)
const double kAvatarSize = 48.0;

/// רדיוס Avatar (36px)
const double kAvatarRadius = 36.0;

/// רדיוס Avatar קטן (20px)
const double kAvatarRadiusSmall = 20.0;

/// רדיוס Avatar זעיר (18px) - לרשימות
const double kAvatarRadiusTiny = 18.0;

/// רוחב שדה כמות/מספר (80px)
const double kQuantityFieldWidth = 80.0;

// ========================================
// Charts & Graphs
// ========================================

/// רדיוס גרף עוגה (80px)
const double kPieChartRadius = 80.0;

/// גודל נקודת Legend (12px)
const double kLegendDotSize = 12.0;

// ========================================
// Durations (משכי זמן)
// ========================================

/// משך זמן לאנימציות קצרות (200ms)
const Duration kAnimationDurationShort = Duration(milliseconds: 200);

/// משך זמן לאנימציות בינוניות (300ms)
const Duration kAnimationDurationMedium = Duration(milliseconds: 300);

/// משך זמן לאנימציות ארוכות (500ms)
const Duration kAnimationDurationLong = Duration(milliseconds: 500);

/// משך זמן לאנימציות איטיות (2500ms) - shimmer, pulse
const Duration kAnimationDurationSlow = Duration(milliseconds: 2500);

// ========================================
// Progress Indicators
// ========================================

/// גובה מינימלי ל-LinearProgressIndicator
const double kProgressIndicatorHeight = 6.0;

/// שקיפות רקע ל-Progress Indicators (0.18)
const double kProgressIndicatorBackgroundAlpha = 0.18;

/// מספר מקסימלי של קבלות להצגת התקדמות (100%)
const int kMaxReceiptsForProgress = 10;

/// זמן המתנה ללחיצה כפולה (2 שניות)
const Duration kDoubleTapTimeout = Duration(seconds: 2);

/// זמן הצגת SnackBar רגיל (2 שניות)
const Duration kSnackBarDuration = Duration(seconds: 2);

/// זמן הצגת SnackBar ארוך (5 שניות)
const Duration kSnackBarDurationLong = Duration(seconds: 5);

// ========================================
// SnackBar
// ========================================

/// מרווח תחתון ל-SnackBar (מעל Bottom Navigation)
const double kSnackBarBottomMargin = 80.0;

/// מרווחים אופקיים ל-SnackBar
const double kSnackBarHorizontalMargin = 16.0;

// ========================================
// Elevation (גובה צל)
// ========================================

/// Elevation רגיל לכרטיסים
const double kCardElevation = 2.0;

/// Elevation נמוך (כמעט שטוח)
const double kCardElevationLow = 1.0;

/// Elevation גבוה (בולט)
const double kCardElevationHigh = 4.0;

// ========================================
// Skeleton Loading
// ========================================

/// רוחב skeleton לכותרת (200px)
const double kSkeletonTitleWidth = 200.0;

/// גובה skeleton לכותרת (20px)
const double kSkeletonTitleHeight = 20.0;

/// רוחב skeleton לתת-כותרת (150px)
const double kSkeletonSubtitleWidth = 150.0;

/// גובה skeleton לתת-כותרת (16px)
const double kSkeletonSubtitleHeight = 16.0;

/// גובה skeleton לתוכן (40px)
const double kSkeletonContentHeight = 40.0;

/// משך אנימציית shimmer (1200ms)
const Duration kSkeletonShimmerDuration = Duration(milliseconds: 1200);

/// שקיפות אפקט shimmer (0.5)
const double kSkeletonShimmerAlpha = 0.5;

/// זווית אפקט shimmer (45 מעלות)
const double kShimmerAngle = 45.0;

/// עיכוב בין skeleton cards (100ms)
const Duration kSkeletonStaggerDelay = Duration(milliseconds: 100);

// ========================================
// Receipt Parsing
// ========================================

/// אורך מינימלי לשורה בקבלה (תווים)
const int kMinReceiptLineLength = 3;

/// מחיר מקסימלי לפריט בקבלה (₪)
const double kMaxReceiptPrice = 10000.0;

/// הפרש מקסימלי בין סכום פריטים לסה"כ (₪)
const double kMaxReceiptTotalDifference = 1.0;

/// מספר שורות מקסימלי לבדיקת שם חנות
const int kMaxStoreLinesCheck = 5;

/// אורך מקסימלי לשם חנות מהשורה הראשונה
const int kMaxStoreNameLength = 30;

// ========================================
// Dialog Constraints
// ========================================

/// גובה מקסימלי לדיאלוג תוכן (280px)
const double kDialogMaxHeight = 280.0;

/// רוחב מקסימלי לדיאלוג (400px)
const double kDialogMaxWidth = 400.0;

// ========================================
// Opacity/Alpha Values
// ========================================

/// שקיפות נמוכה (0.2) - גבולות עדינים
const double kOpacityLight = 0.2;

/// שקיפות נמוכה-בינונית (0.3) - רקעים עדינים
const double kOpacityLow = 0.3;

/// שקיפות בינונית (0.5) - overlays
const double kOpacityMedium = 0.5;

/// שקיפות גבוהה (0.6) - טקסט משני
const double kOpacityHigh = 0.6;

/// שקיפות גבוהה מאוד (0.9) - טקסט בהיר על רקע כהה
const double kOpacityVeryHigh = 0.9;

/// שקיפות בינונית-גבוהה (0.85) - טקסט משני בהיר
const double kOpacityMediumHigh = 0.85;

/// שקיפות נמוכה מאוד (0.15) - זוהר עדין
const double kOpacityVeryLow = 0.15;

/// שקיפות מינימלית (0.05) - אפקטים עדינים מאוד
const double kOpacityMinimal = 0.05;

/// שקיפות רגילה (0.95) - רקעים כמעט אטומים
const double kOpacityAlmostFull = 0.95;

/// שקיפות קרובה לאטום (0.98) - רקעים כמעט מלאים
const double kOpacityNearFull = 0.98;

// ========================================
// Date/Time Ranges
// ========================================

/// טווח מקסימלי לתאריך אירוע עתידי (365 ימים)
const Duration kMaxEventDateRange = Duration(days: 365);

// ========================================
// 💡 דוגמאות שימוש
// ========================================
//
// ```dart
// // כפתור עם גובה סטנדרטי
// SizedBox(
//   height: kButtonHeight,
//   child: ElevatedButton(...),
// )
//
// // ריווח בין elements
// SizedBox(height: kSpacingMedium)
//
// // Container עם פינות מעוגלות
// Container(
//   decoration: BoxDecoration(
//     borderRadius: BorderRadius.circular(kBorderRadius),
//   ),
// )
//
// // Receipt Parsing
// if (line.length < kMinReceiptLineLength) continue;
// if (price > kMaxReceiptPrice) continue;
// ```
