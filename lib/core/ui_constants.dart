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

/// רוחב שדה כמות/מספר (80px)
const double kQuantityFieldWidth = 80.0;

// ========================================
// Durations (משכי זמן)
// ========================================

/// משך זמן לאנימציות קצרות (200ms)
const Duration kAnimationDurationShort = Duration(milliseconds: 200);

/// משך זמן לאנימציות בינוניות (300ms)
const Duration kAnimationDurationMedium = Duration(milliseconds: 300);

/// משך זמן לאנימציות ארוכות (500ms)
const Duration kAnimationDurationLong = Duration(milliseconds: 500);

// ========================================
// Progress Indicators
// ========================================

/// גובה מינימלי ל-LinearProgressIndicator
const double kProgressIndicatorHeight = 6.0;

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
