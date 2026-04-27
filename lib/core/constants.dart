// lib/core/constants.dart — App-wide limits, status enum, and default values

const int kMaxItemsPerList = 200;

/// מקסימום פריטים במזווה
const int kMaxItemsPerPantry = 500;

/// מקסימום רשימות פעילות למשתמש
const int kMaxActiveListsPerUser = 30;

// ═══════════════════════════════════════════════════════════════════════════
// QUERY LIMITS
// ═══════════════════════════════════════════════════════════════════════════

/// מקסימום משתמשים לטעינה בשאילתת משק בית
const int kQueryLimitHousehold = 50;

/// מקסימום משתמשים לטעינה בשאילתה כללית
const int kQueryLimitAllUsers = 100;

/// מקסימום דפוסי קניות אחרונים לטעינה (Firestore query limit)
const int kMaxRecentPatterns = 10;

// ═══════════════════════════════════════════════════════════════════════════
// LIMIT STATUS (Severity Levels)
// ═══════════════════════════════════════════════════════════════════════════

/// סטטוס ניצול מכסה — להצגת אזהרות מדורגות (UI ומודלים)
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

/// סף אזהרה עדינה (80%) — נקרא מתוך getLimitStatus
const double kLimitWarningThreshold = 0.8;

/// סף אזהרה דחופה (95%) — נקרא מתוך getLimitStatus
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

/// Default unit for products — canonical Hebrew value persisted to Firestore.
/// UI display uses AppStrings.inventory.defaultUnit ('יח\'' in HE, 'pcs' in EN).
/// Used as fallback when unit is missing from Firestore data, and as the
/// hardcoded `@JsonKey(defaultValue: 'יח\'')` in models (json_serializable
/// requires literal — keep models in sync if this changes).
const String kDefaultProductUnit = 'יח\'';
