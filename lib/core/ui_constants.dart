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

/// ריווח ענק (32px)
const double kSpacingXLarge = 32.0;

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

// ========================================
// אייקונים
// ========================================

/// גודל אייקון רגיל
const double kIconSize = 24.0;

/// גודל אייקון קטן
const double kIconSizeSmall = 16.0;

/// גודל אייקון גדול
const double kIconSizeLarge = 32.0;

// ========================================
// Durations (משכי זמן)
// ========================================

/// משך זמן לאנימציות קצרות (200ms)
const Duration kAnimationDurationShort = Duration(milliseconds: 200);

/// משך זמן לאנימציות בינוניות (300ms)
const Duration kAnimationDurationMedium = Duration(milliseconds: 300);

/// משך זמן לאנימציות ארוכות (500ms)
const Duration kAnimationDurationLong = Duration(milliseconds: 500);

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
// ```
