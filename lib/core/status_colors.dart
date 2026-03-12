// 📄 lib/core/status_colors.dart
//
// צבעי סטטוס סמנטיים - עטיפה ל-Theme (AppBrand + ColorScheme).
// מספק API אחיד לצבעי success/error/warning/pending/info.
// ✨ v4.0: מיפוי רטט סנסורי (Sensory Haptic Mapping), API אחיד ל-Status Containers,
//          תאימות מלאה ל-Material 3 ו-AppBrand
//
// Version: 4.0 (22/02/2026)
// 🔗 Related: app_theme.dart (AppBrand), ColorScheme

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
enum StatusType {
  success,
  error,
  warning,
  pending,
  info;

  /// האם הסטטוס קריטי (דורש תשומת לב מיידית)
  bool get isCritical => this == error || this == warning;

  /// המרה מ-String ל-StatusType (עם fallback)
  ///
  /// ✅ סלחני לפורמטים שונים:
  /// - "success" / "SUCCESS" / " success "
  /// - "StatusType.success"
  static StatusType fromString(String value) {
    // 🔧 נרמול: trim + lowercase + קח רק את החלק האחרון אחרי נקודה
    var normalized = value.trim().toLowerCase();
    if (normalized.contains('.')) {
      normalized = normalized.split('.').last;
    }

    return StatusType.values.firstWhere(
      (e) => e.name == normalized,
      orElse: () {
        if (kDebugMode) {
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

  /// ירוק מותג - Fallback ל-success (desaturated 10% למראה יוקרתי)
  static const _successFallback = Color(0xFF4A9050); // Green 700 desaturated

  /// כתום מותג - Fallback ל-warning (desaturated 10% למראה יוקרתי)
  static const _warningFallback = Color(0xFFE8892A); // Orange 700 desaturated

  /// Container fallbacks (גרסאות בהירות יותר, desaturated)
  static const _successContainerFallback = Color(0xFFD0E8D2); // Green 100 desaturated
  static const _warningContainerFallback = Color(0xFFFFE4BF); // Orange 100 desaturated

  /// OnContainer fallbacks (גרסאות כהות לטקסט, desaturated)
  static const _onSuccessContainerFallback = Color(0xFF2B6530); // Green 900 desaturated
  static const _onWarningContainerFallback = Color(0xFFD4601A); // Orange 900 desaturated

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
  // 🆕 Icon API (v4.0)
  // ========================================

  /// מחזיר אייקון ברירת מחדל לסטטוס
  ///
  /// ```dart
  /// Icon(StatusColors.getIcon(StatusType.success))
  /// ```
  static IconData getIcon(StatusType type) {
    switch (type) {
      case StatusType.success:
        return Icons.check_circle;
      case StatusType.error:
        return Icons.error;
      case StatusType.warning:
        return Icons.warning_amber_rounded;
      case StatusType.pending:
        return Icons.schedule;
      case StatusType.info:
        return Icons.info_outline;
    }
  }

  // ========================================
  // 🆕 Sensory Haptic Mapping (v4.0)
  // ========================================

  /// מפעיל רטט סנסורי המותאם לסוג הסטטוס
  ///
  /// - **success**: lightImpact — רטט עדין של אישור
  /// - **error**: heavyImpact כפול — רטט "שגיאה" מורגש
  /// - **warning**: mediumImpact — רטט ביניים לתשומת לב
  /// - **info/pending**: selectionClick — קליק עדין
  ///
  /// ```dart
  /// StatusColors.triggerHaptic(StatusType.error);
  /// ```
  static void triggerHaptic(StatusType type) {
    switch (type) {
      case StatusType.success:
        unawaited(HapticFeedback.lightImpact());
      case StatusType.error:
        unawaited(HapticFeedback.heavyImpact());
        Future.delayed(
          const Duration(milliseconds: 100),
          () => unawaited(HapticFeedback.heavyImpact()),
        );
      case StatusType.warning:
        unawaited(HapticFeedback.mediumImpact());
      case StatusType.info:
      case StatusType.pending:
        unawaited(HapticFeedback.selectionClick());
    }
  }
}
