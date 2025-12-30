// 📄 lib/core/status_colors.dart
//
// צבעי סטטוס סמנטיים - עטיפה ל-Theme (AppBrand + ColorScheme).
// מספק API אחיד לצבעי success/error/warning/pending/info.
//
// 🔗 Related: app_theme.dart (AppBrand), ColorScheme

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// צבעי סטטוס סמנטיים - Theme-Aware
///
/// ✅ משתמש ב-Theme כמקור אמת יחיד!
/// - success/warning → מ-AppBrand (תומך Dynamic Color)
/// - error → מ-ColorScheme.error
/// - pending → מ-ColorScheme.outline (ניטרלי, תומך Dynamic Color)
/// - info → מ-ColorScheme.secondary (תומך Dynamic Color)
///
/// 📍 שימוש בפרויקט:
/// - lib/widgets/shopping_list_tile.dart (סטטוס רשימות, דחיפות)
/// - lib/screens/shopping/create/create_list_screen.dart (SnackBars)
class StatusColors {
  const StatusColors._();

  // ========================================
  // צבעי Fallback (צבעי מותג - כשאין AppBrand זמין)
  // ========================================

  /// ירוק מותג - Fallback ל-success (מתואם ל-app_theme.dart)
  static const _successFallback = Color(0xFF388E3C); // Green 700

  /// כתום מותג - Fallback ל-warning (מתואם ל-app_theme.dart)
  static const _warningFallback = Color(0xFFF57C00); // Orange 700

  /// Container fallbacks (גרסאות בהירות יותר)
  static const _successContainerFallback = Color(0xFFC8E6C9); // Green 100
  static const _warningContainerFallback = Color(0xFFFFE0B2); // Orange 100

  /// OnContainer fallbacks (גרסאות כהות לטקסט)
  static const _onSuccessContainerFallback = Color(0xFF1B5E20); // Green 900
  static const _onWarningContainerFallback = Color(0xFFE65100); // Orange 900

  // ========================================
  // פונקציות עזר (Theme-Aware)
  // ========================================

  /// מחזיר את צבע הסטטוס המתאים לפי Theme
  ///
  /// **Status types:**
  /// - 'success' - הצלחה (ירוק מ-AppBrand)
  /// - 'error' - שגיאה (אדום מ-ColorScheme)
  /// - 'warning' - אזהרה (כתום מ-AppBrand)
  /// - 'pending' - ממתין (outline מ-ColorScheme)
  /// - 'info' - מידע (secondary מ-ColorScheme)
  ///
  /// **Usage:**
  /// ```dart
  /// Icon(
  ///   Icons.check_circle,
  ///   color: StatusColors.getStatusColor('success', context),
  /// )
  /// ```
  static Color getStatusColor(String status, BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<AppBrand>();
    final cs = theme.colorScheme;

    switch (status.toLowerCase()) {
      case 'success':
        // ✅ מ-AppBrand (תומך Dynamic Color)
        return brand?.success ?? _successFallback;
      case 'error':
        // ✅ מ-ColorScheme (תומך Dynamic Color)
        return cs.error;
      case 'warning':
        // ✅ מ-AppBrand (תומך Dynamic Color)
        return brand?.warning ?? _warningFallback;
      case 'pending':
        // ✅ ניטרלי - outline מ-Theme (תומך Dynamic Color)
        return cs.outline;
      case 'info':
        // ✅ secondary מ-Theme (תומך Dynamic Color)
        return cs.secondary;
      default:
        if (kDebugMode) {
          debugPrint(
            '⚠️ StatusColors.getStatusColor: Unknown status "$status" - '
            'falling back to pending. '
            'Valid: success, error, warning, pending, info',
          );
        }
        return cs.outline;
    }
  }

  /// מחזיר את צבע ה-container (רקע) המתאים לפי Theme
  ///
  /// **Usage:**
  /// ```dart
  /// Container(
  ///   color: StatusColors.getStatusContainer('success', context),
  ///   child: Text('הושלם'),
  /// )
  /// ```
  static Color getStatusContainer(String status, BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<AppBrand>();
    final cs = theme.colorScheme;

    switch (status.toLowerCase()) {
      case 'success':
        // ✅ מ-AppBrand (תומך Dynamic Color)
        return brand?.successContainer ?? _successContainerFallback;
      case 'error':
        // ✅ מ-ColorScheme (תומך Dynamic Color)
        return cs.errorContainer;
      case 'warning':
        // ✅ מ-AppBrand (תומך Dynamic Color)
        return brand?.warningContainer ?? _warningContainerFallback;
      case 'pending':
        // ✅ surfaceContainerHighest - רקע ניטרלי בולט (תומך Dynamic Color)
        return cs.surfaceContainerHighest;
      case 'info':
        // ✅ secondaryContainer מ-Theme (תומך Dynamic Color)
        return cs.secondaryContainer;
      default:
        if (kDebugMode) {
          debugPrint(
            '⚠️ StatusColors.getStatusContainer: Unknown status "$status" - '
            'falling back to pending.',
          );
        }
        return cs.surfaceContainerHighest;
    }
  }

  /// מחזיר את צבע הטקסט על container המתאים לפי Theme
  ///
  /// **Usage:**
  /// ```dart
  /// Text(
  ///   'הושלם',
  ///   style: TextStyle(
  ///     color: StatusColors.getOnStatusContainer('success', context),
  ///   ),
  /// )
  /// ```
  static Color getOnStatusContainer(String status, BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<AppBrand>();
    final cs = theme.colorScheme;

    switch (status.toLowerCase()) {
      case 'success':
        return brand?.onSuccessContainer ?? _onSuccessContainerFallback;
      case 'error':
        return cs.onErrorContainer;
      case 'warning':
        return brand?.onWarningContainer ?? _onWarningContainerFallback;
      case 'pending':
        // ✅ onSurfaceVariant - רך יותר מ-onSurface (מתאים לתגיות/badges)
        return cs.onSurfaceVariant;
      case 'info':
        // ✅ onSecondaryContainer מ-Theme (תומך Dynamic Color)
        return cs.onSecondaryContainer;
      default:
        return cs.onSurfaceVariant;
    }
  }

  // ========================================
  // Legacy API (לתאימות אחורה)
  // ========================================

  /// @deprecated השתמש ב-getStatusContainer במקום
  static Color getStatusOverlay(String status, BuildContext context) {
    return getStatusContainer(status, context);
  }

  // ========================================
  // Static Getters (Fallback colors - לשימוש ללא context)
  // ========================================
  //
  // ⚠️ שימו לב: צבעים אלה הם fallback בלבד!
  // לצבעים Theme-aware השתמשו ב-getStatusColor/getStatusContainer.
  // צבעים אלה שימושיים ב:
  // - const widgets
  // - מקומות שאין גישה ל-context
  // - ערכי ברירת מחדל

  /// ירוק הצלחה (fallback)
  static const Color success = _successFallback;

  /// אדום שגיאה (fallback - Material error)
  static const Color error = Color(0xFFD32F2F); // Red 700

  /// כתום אזהרה (fallback)
  static const Color warning = _warningFallback;

  /// אפור ממתין (fallback - outline equivalent)
  static const Color pending = Color(0xFF757575); // Grey 600

  /// כחול מידע (fallback - secondary equivalent)
  static const Color info = Color(0xFF1976D2); // Blue 700

  // Container variants (רקעים בהירים)

  /// רקע הצלחה (fallback)
  static const Color successContainer = _successContainerFallback;

  /// רקע שגיאה (fallback)
  static const Color errorContainer = Color(0xFFFFCDD2); // Red 100

  /// רקע אזהרה (fallback)
  static const Color warningContainer = _warningContainerFallback;

  /// רקע ממתין (fallback)
  static const Color pendingContainer = Color(0xFFEEEEEE); // Grey 200

  /// רקע מידע (fallback)
  static const Color infoContainer = Color(0xFFBBDEFB); // Blue 100

  // Overlay variants (שכבות עם שקיפות)

  /// שכבת הצלחה (fallback)
  static Color get successOverlay => success.withValues(alpha: 0.15);

  /// שכבת שגיאה (fallback)
  static Color get errorOverlay => error.withValues(alpha: 0.15);

  /// שכבת אזהרה (fallback)
  static Color get warningOverlay => warning.withValues(alpha: 0.15);

  /// שכבת ממתין (fallback)
  static Color get pendingOverlay => pending.withValues(alpha: 0.15);

  /// שכבת מידע (fallback)
  static Color get infoOverlay => info.withValues(alpha: 0.15);
}
