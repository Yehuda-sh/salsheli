// 📄 File: lib/core/status_colors.dart
//
// 🎯 מטרה: צבעי סטטוס סמנטיים לאפליקציה
//
// 📋 כולל:
// - צבעי סטטוס למצבי פריטים (pending, success, error, warning)
// - צבעים עקביים בכל האפליקציה
//
// 📝 הערות:
// - צבעים סמנטיים: ירוק=הצלחה, אדום=שגיאה, כתום=אזהרה, אפור=ממתין
// - תומך בLight/Dark themes
//
// Usage Example:
// ```dart
// import 'package:salsheli/core/status_colors.dart';
// 
// Icon(Icons.check, color: StatusColors.success)
// Icon(Icons.error, color: StatusColors.error)
// ```
//
// Version: 1.0
// Last Updated: 08/10/2025

import 'package:flutter/material.dart';

/// צבעי סטטוס סמנטיים
/// 
/// צבעים קבועים לשימוש במצבי סטטוס שונים:
/// - pending (אפור) - פריט ממתין לפעולה
/// - success (ירוק) - פעולה הצליחה / פריט נקנה
/// - error (אדום) - שגיאה / לא במלאי
/// - warning (כתום) - אזהרה / פריט דחוי
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

  // ========================================
  // גוונים נוספים (אופציונלי)
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
}

// ========================================
// 💡 דוגמאות שימוש
// ========================================
//
// ```dart
// // שימוש בסיסי
// Icon(Icons.check_circle, color: StatusColors.success)
// Icon(Icons.error_outline, color: StatusColors.error)
// Icon(Icons.schedule, color: StatusColors.warning)
// Icon(Icons.radio_button_unchecked, color: StatusColors.pending)
//
// // עם Theme mode
// final isDark = Theme.of(context).brightness == Brightness.dark;
// final color = isDark ? StatusColors.successDark : StatusColors.successLight;
//
// // עם Container
// Container(
//   color: StatusColors.success.withValues(alpha: 0.1),
//   child: Text('הצלחה', style: TextStyle(color: StatusColors.success)),
// )
// ```
