// 📄 lib/core/constants.dart
//
// קבועים לוגיים של האפליקציה (לא UI).
// - Data limits עם severity levels
// - Query limits
//
// 📋 Features:
// - ניהול מגבלות סמנטי (Soft vs Hard Limits)
// - סטטוסים לניצול מכסה (LimitStatus)
//
// 🔗 Related: ui_constants.dart (UI), repository_constants.dart (Firestore)
//
// 📝 Version: 4.1
// 📅 Updated: 25/03/2026

// ═══════════════════════════════════════════════════════════════════════════
// DATA LIMITS
// ═══════════════════════════════════════════════════════════════════════════

/// מקסימום פריטים ברשימת קניות אחת
const int kMaxItemsPerList = 200;

/// מקסימום פריטים במזווה
const int kMaxItemsPerPantry = 500;

/// מקסימום רשימות פעילות למשתמש
const int kMaxActiveListsPerUser = 30;

/// מקסימום משתמשים משותפים לרשימה (מניעת עומס על Sync)
const int kMaxSharedUsersPerList = 20;

/// מקסימום מיקומי אחסון במזווה למשק בית
const int kMaxLocationsPerHousehold = 30;

// ═══════════════════════════════════════════════════════════════════════════
// QUERY LIMITS
// ═══════════════════════════════════════════════════════════════════════════

/// מקסימום משתמשים לטעינה בשאילתת משק בית
const int kQueryLimitHousehold = 50;

/// מקסימום משתמשים לטעינה בשאילתה כללית
const int kQueryLimitAllUsers = 100;

/// מקסימום דפוסי קניות אחרונים לטעינה
const int kMaxRecentPatterns = 10;

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

// ═══════════════════════════════════════════════════════════════════════════
// DEFAULT VALUES
// ═══════════════════════════════════════════════════════════════════════════

/// Default unit for products — matches AppStrings.inventory.defaultUnit
/// ('יח\'' in HE, 'pcs' in EN).
/// Used as fallback when unit is missing from Firestore data.
const String kDefaultProductUnit = 'יח\'';
