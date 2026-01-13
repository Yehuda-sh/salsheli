// 📄 lib/core/status_colors.dart
//
// צבעי סטטוס סמנטיים - עטיפה ל-Theme (AppBrand + ColorScheme).
// מספק API אחיד לצבעי success/error/warning/pending/info.
//
// 🔗 Related: app_theme.dart (AppBrand), ColorScheme

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// ========================================
// 🔧 Type-Safe Status Enum
// ========================================

/// סוגי סטטוס תקפים - מונע טייפואים בקוד!
///
/// **Usage (type-safe):**
/// ```dart
/// StatusColors.getColor(StatusType.success, context)
/// ```
///
/// **Legacy (string-based):**
/// ```dart
/// StatusColors.getStatusColor('success', context) // עדיין עובד
/// ```
enum StatusType {
  success,
  error,
  warning,
  pending,
  info;

  /// המרה מ-String ל-StatusType (עם fallback)
  ///
  /// ✅ סלחני לפורמטים שונים:
  /// - "success" / "SUCCESS" / " success "
  /// - "StatusType.success" / "ShoppingItemStatus.purchased"
  static StatusType fromString(String value) {
    // 🔧 נרמול: trim + lowercase + קח רק את החלק האחרון אחרי נקודה
    var normalized = value.trim().toLowerCase();
    if (normalized.contains('.')) {
      normalized = normalized.split('.').last;
    }

    // 🔄 מיפוי aliases נפוצים (למשל מ-ShoppingItemStatus)
    const aliases = {
      'purchased': 'success',
      'outofstock': 'error',
      'notneeded': 'pending',
    };
    normalized = aliases[normalized] ?? normalized;

    return StatusType.values.firstWhere(
      (e) => e.name == normalized,
      orElse: () {
        if (kDebugMode) {
          debugPrint(
            '⚠️ StatusType.fromString: Unknown status "$value" (normalized: "$normalized") - '
            'falling back to pending. '
            'Valid: ${StatusType.values.map((e) => e.name).join(", ")}',
          );
        }
        return StatusType.pending;
      },
    );
  }
}

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
  // 🆕 Type-Safe API (מומלץ לשימוש!)
  // ========================================

  /// 🆕 מחזיר צבע סטטוס - Type-Safe!
  ///
  /// **Usage:**
  /// ```dart
  /// Icon(
  ///   Icons.check_circle,
  ///   color: StatusColors.getColor(StatusType.success, context),
  /// )
  /// ```
  static Color getColor(StatusType type, BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<AppBrand>();
    final cs = theme.colorScheme;

    switch (type) {
      case StatusType.success:
        return brand?.success ?? _successFallback;
      case StatusType.error:
        return cs.error;
      case StatusType.warning:
        return brand?.warning ?? _warningFallback;
      case StatusType.pending:
        return cs.outline;
      case StatusType.info:
        return cs.secondary;
    }
  }

  /// 🆕 מחזיר צבע container - Type-Safe!
  static Color getContainer(StatusType type, BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<AppBrand>();
    final cs = theme.colorScheme;

    switch (type) {
      case StatusType.success:
        return brand?.successContainer ?? _successContainerFallback;
      case StatusType.error:
        return cs.errorContainer;
      case StatusType.warning:
        return brand?.warningContainer ?? _warningContainerFallback;
      case StatusType.pending:
        return cs.surfaceContainerHighest;
      case StatusType.info:
        return cs.secondaryContainer;
    }
  }

  /// 🆕 מחזיר צבע טקסט על container - Type-Safe!
  static Color getOnContainer(StatusType type, BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<AppBrand>();
    final cs = theme.colorScheme;

    switch (type) {
      case StatusType.success:
        return brand?.onSuccessContainer ?? _onSuccessContainerFallback;
      case StatusType.error:
        // ✅ FIX: שימוש ב-Theme (cs.onErrorContainer)
        // Material 3 מספק ניגודיות טובה גם ב-Light וגם ב-Dark Mode
        return cs.onErrorContainer;
      case StatusType.warning:
        return brand?.onWarningContainer ?? _onWarningContainerFallback;
      case StatusType.pending:
        return cs.onSurfaceVariant;
      case StatusType.info:
        return cs.onSecondaryContainer;
    }
  }

  // ========================================
  // Legacy String API (לתאימות אחורה)
  // ========================================

  /// @deprecated השתמש ב-getColor(StatusType, context) במקום
  ///
  /// מחזיר את צבע הסטטוס המתאים לפי Theme
  static Color getStatusColor(String status, BuildContext context) {
    return getColor(StatusType.fromString(status), context);
  }

  /// @deprecated השתמש ב-getContainer(StatusType, context) במקום
  static Color getStatusContainer(String status, BuildContext context) {
    return getContainer(StatusType.fromString(status), context);
  }

  /// @deprecated השתמש ב-getOnContainer(StatusType, context) במקום
  static Color getOnStatusContainer(String status, BuildContext context) {
    return getOnContainer(StatusType.fromString(status), context);
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
