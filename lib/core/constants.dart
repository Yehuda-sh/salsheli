// 📄 lib/core/constants.dart
//
// קבועים לוגיים של האפליקציה (לא UI).
// - Family size limits, Children age groups, Schema version
// - Data limits עם severity levels
//
// 📋 Features:
// - ניהול מגבלות סמנטי (Soft vs Hard Limits)
// - סטטוסים לניצול מכסה (LimitStatus)
// - מיפוי גילאים משופר (Map עם תיאורים סמנטיים)
//
// 🔗 Related: ui_constants.dart (UI), repository_constants.dart (Firestore)
//
// 📝 Version: 4.0
// 📅 Updated: 22/02/2026

// ═══════════════════════════════════════════════════════════════════════════
// FAMILY SIZE
// ═══════════════════════════════════════════════════════════════════════════

/// גודל משפחה מינימלי
const int kMinFamilySize = 1;

/// גודל משפחה מקסימלי
const int kMaxFamilySize = 10;

// ═══════════════════════════════════════════════════════════════════════════
// SCHEMA VERSION
// ═══════════════════════════════════════════════════════════════════════════

/// Current schema version for data migrations
const int kCurrentSchemaVersion = 1;

// ═══════════════════════════════════════════════════════════════════════════
// DATA LIMITS
// ═══════════════════════════════════════════════════════════════════════════

/// מקסימום פריטים ברשימת קניות אחת
const int kMaxItemsPerList = 200;

/// מקסימום פריטים במזווה
const int kMaxItemsPerPantry = 500;

/// מקסימום רשימות פעילות למשתמש
const int kMaxActiveListsPerUser = 100;

/// מקסימום משתמשים משותפים לרשימה (מניעת עומס על Sync)
const int kMaxSharedUsersPerList = 20;

/// מקסימום מיקומי אחסון במזווה למשק בית
const int kMaxLocationsPerHousehold = 30;

// ═══════════════════════════════════════════════════════════════════════════
// LIMIT STATUS (Severity Levels)
// ═══════════════════════════════════════════════════════════════════════════

/// סטטוס ניצול מכסה — לשימוש ב-UI להצגת אזהרות מדורגות
enum LimitStatus {
  /// מצב תקין — אין צורך בהתראה
  safe,

  /// אזהרה עדינה (צהוב) — מתקרבים למגבלה
  warning,

  /// אזהרה דחופה (אדום) — קרובים מאוד למגבלה
  critical,

  /// מלא — הגענו למקסימום, לא ניתן להוסיף
  full,
}

// ═══════════════════════════════════════════════════════════════════════════
// WARNING THRESHOLDS
// ═══════════════════════════════════════════════════════════════════════════

/// סף מצב תקין (עד 50%)
const double kLimitSafeThreshold = 0.5;

/// סף אזהרה עדינה (80%) — נועד לשימוש ב-UI
const double kLimitWarningThreshold = 0.8;

/// סף אזהרה דחופה (95%) — קרוב מאוד למגבלה
const double kLimitCriticalThreshold = 0.95;

// ═══════════════════════════════════════════════════════════════════════════
// LIMIT FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

/// מחזיר את סטטוס ניצול המכסה
///
/// **Usage (UI layer):**
/// ```dart
/// final status = getLimitStatus(list.items.length, kMaxItemsPerList);
/// switch (status) {
///   case LimitStatus.warning:  // הצג אזהרה צהובה
///   case LimitStatus.critical: // הצג אזהרה אדומה
///   case LimitStatus.full:     // חסום הוספה
///   case LimitStatus.safe:     // הכל תקין
/// }
/// ```
LimitStatus getLimitStatus(int current, int max) {
  if (max <= 0) return LimitStatus.safe;
  if (current >= max) return LimitStatus.full;
  final usage = current / max;
  if (usage >= kLimitCriticalThreshold) return LimitStatus.critical;
  if (usage >= kLimitWarningThreshold) return LimitStatus.warning;
  return LimitStatus.safe;
}
