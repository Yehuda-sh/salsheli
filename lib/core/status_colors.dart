// 📄 lib/core/status_colors.dart
//
// צבעי סטטוס סמנטיים עם תמיכה ב-Light/Dark themes.
// - pending (אפור), success (ירוק), error (אדום), warning (כתום), info (כחול)
// - getStatusColor() / getStatusOverlay() - theme-aware אוטומטי
// - גרסאות overlay לרקעים עם שקיפות

import 'package:flutter/material.dart';

/// צבעי סטטוס סמנטיים
///
/// צבעים קבועים לשימוש במצבי סטטוס שונים:
/// - pending (אפור) - פריט ממתין לפעולה
/// - success (ירוק) - פעולה הצליחה / פריט נקנה
/// - error (אדום) - שגיאה / כשלון
/// - warning (כתום) - אזהרה / דחיפות
/// - info (כחול) - מידע / רשימה פעילה
///
/// 📍 שימוש בפרויקט:
/// - lib/widgets/shopping_list_tile.dart (סטטוס רשימות, דחיפות, borders, SnackBars)
/// - lib/screens/shopping/create/create_list_screen.dart (SnackBars, error states)
class StatusColors {
  // מניעת instances
  const StatusColors._();

  // ========================================
  // צבעי סטטוס בסיסיים
  // ========================================

  /// אפור - ממתין לפעולה
  static const pending = Colors.grey;

  /// ירוק - הצלחה
  static const success = Colors.green;

  /// אדום - שגיאה / כשלון
  static const error = Colors.red;

  /// כתום - אזהרה / דחייה
  static const warning = Colors.orange;

  /// כחול - מידע / לא צריך
  static const info = Colors.blueGrey;

  // ========================================
  // גוונים נוספים (Light/Dark variants)
  // ========================================

  /// אפור בהיר - pending בLight mode
  static const pendingLight = Color(0xFF9E9E9E); // Colors.grey.shade400

  /// אפור כהה - pending בDark mode
  static const pendingDark = Color(0xFF757575); // Colors.grey.shade600

  /// ירוק בהיר - success בLight mode
  static const successLight = Color(0xFF66BB6A); // Colors.green.shade400

  /// ירוק כהה - success בDark mode
  static const successDark = Color(0xFF4CAF50); // Colors.green.shade500

  /// אדום בהיר - error בLight mode
  static const errorLight = Color(0xFFEF5350); // Colors.red.shade400

  /// אדום כהה - error בDark mode
  static const errorDark = Color(0xFFF44336); // Colors.red.shade500

  /// כתום בהיר - warning בLight mode
  static const warningLight = Color(0xFFFFA726); // Colors.orange.shade400

  /// כתום כהה - warning בDark mode
  static const warningDark = Color(0xFFFF9800); // Colors.orange.shade500

  /// כחול בהיר - info בLight mode
  static const infoLight = Color(0xFF78909C); // Colors.blueGrey.shade400

  /// כחול כהה - info בDark mode
  static const infoDark = Color(0xFF607D8B); // Colors.blueGrey.shade500

  // ========================================
  // צבעי Overlay (רקעים עם שקיפות)
  // ========================================

  /// ירוק overlay - לרקע הצלחה (10% שקיפות)
  static final successOverlay = successLight.withValues(alpha: 0.1);

  /// ירוק overlay כהה - לרקע הצלחה בDark mode (15% שקיפות)
  static final successOverlayDark = successDark.withValues(alpha: 0.15);

  /// אדום overlay - לרקע שגיאה (10% שקיפות)
  static final errorOverlay = errorLight.withValues(alpha: 0.1);

  /// אדום overlay כהה - לרקע שגיאה בDark mode (15% שקיפות)
  static final errorOverlayDark = errorDark.withValues(alpha: 0.15);

  /// כתום overlay - לרקע אזהרה (10% שקיפות)
  static final warningOverlay = warningLight.withValues(alpha: 0.1);

  /// כתום overlay כהה - לרקע אזהרה בDark mode (15% שקיפות)
  static final warningOverlayDark = warningDark.withValues(alpha: 0.15);

  /// אפור overlay - לרקע pending (10% שקיפות)
  static final pendingOverlay = pendingLight.withValues(alpha: 0.1);

  /// אפור overlay כהה - לרקע pending בDark mode (15% שקיפות)
  static final pendingOverlayDark = pendingDark.withValues(alpha: 0.15);

  /// כחול overlay - לרקע מידע (10% שקיפות)
  static final infoOverlay = infoLight.withValues(alpha: 0.1);

  /// כחול overlay כהה - לרקע מידע בDark mode (15% שקיפות)
  static final infoOverlayDark = infoDark.withValues(alpha: 0.15);

  // ========================================
  // פונקציות עזר (Theme-Aware)
  // ========================================

  /// מחזיר את צבע הסטטוס המתאים לפי theme mode
  ///
  /// **Status types:**
  /// - 'success' - הצלחה (ירוק)
  /// - 'error' - שגיאה (אדום)
  /// - 'warning' - אזהרה (כתום)
  /// - 'pending' - ממתין (אפור)
  /// - 'info' - מידע (כחול)
  ///
  /// **Fallback:** סטטוס לא ידוע יחזיר `pending` + debug warning
  ///
  /// **Usage:**
  /// ```dart
  /// Icon(
  ///   Icons.check_circle,
  ///   color: StatusColors.getStatusColor('success', context),
  /// )
  /// ```
  static Color getStatusColor(String status, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (status.toLowerCase()) {
      case 'success':
        return isDark ? successDark : successLight;
      case 'error':
        return isDark ? errorDark : errorLight;
      case 'warning':
        return isDark ? warningDark : warningLight;
      case 'pending':
        return isDark ? pendingDark : pendingLight;
      case 'info':
        return isDark ? infoDark : infoLight;
      default:
        // ⚠️ Warning: סטטוס לא ידוע - עוזר לתפוס typos!
        debugPrint(
          '⚠️ StatusColors.getStatusColor: Unknown status "$status" - '
          'falling back to pending. '
          'Valid: success, error, warning, pending, info',
        );
        return isDark ? pendingDark : pendingLight;
    }
  }

  /// מחזיר את צבע ה-overlay (רקע עם שקיפות) המתאים לפי theme mode
  ///
  /// **Status types:**
  /// - 'success' - הצלחה (ירוק)
  /// - 'error' - שגיאה (אדום)
  /// - 'warning' - אזהרה (כתום)
  /// - 'pending' - ממתין (אפור)
  /// - 'info' - מידע (כחול)
  ///
  /// **Fallback:** סטטוס לא ידוע יחזיר `pendingOverlay` + debug warning
  ///
  /// **Usage:**
  /// ```dart
  /// Container(
  ///   color: StatusColors.getStatusOverlay('success', context),
  ///   child: Text('הושלם'),
  /// )
  /// ```
  static Color getStatusOverlay(String status, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (status.toLowerCase()) {
      case 'success':
        return isDark ? successOverlayDark : successOverlay;
      case 'error':
        return isDark ? errorOverlayDark : errorOverlay;
      case 'warning':
        return isDark ? warningOverlayDark : warningOverlay;
      case 'pending':
        return isDark ? pendingOverlayDark : pendingOverlay;
      case 'info':
        return isDark ? infoOverlayDark : infoOverlay;
      default:
        // ⚠️ Warning: סטטוס לא ידוע - עוזר לתפוס typos!
        debugPrint(
          '⚠️ StatusColors.getStatusOverlay: Unknown status "$status" - '
          'falling back to pending. '
          'Valid: success, error, warning, pending, info',
        );
        return isDark ? pendingOverlayDark : pendingOverlay;
    }
  }
}
