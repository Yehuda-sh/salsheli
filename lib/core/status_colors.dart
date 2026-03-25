// 📄 lib/core/status_colors.dart
//
// צבעי סטטוס סמנטיים - עטיפה ל-Theme (AppBrand + ColorScheme).
// מספק API אחיד לצבעי success/error/warning/pending/info.
//
// Version: 4.1 (25/03/2026)
// 🔗 Related: app_theme.dart (AppBrand), ColorScheme

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// ========================================
// Type-Safe Status Enum
// ========================================

/// סוגי סטטוס תקפים
enum StatusType {
  success,
  error,
  warning,
  pending,
  info,
}

// ========================================
// Status Color Set (single Theme lookup)
// ========================================

/// סט צבעים מלא לסטטוס — נוצר מ-Theme lookup יחיד
///
/// ```dart
/// final colors = StatusColorSet.of(StatusType.success, context);
/// Container(color: colors.container, child: Text('OK', style: TextStyle(color: colors.onContainer)));
/// ```
class StatusColorSet {
  const StatusColorSet({
    required this.color,
    required this.container,
    required this.onContainer,
  });

  final Color color;
  final Color container;
  final Color onContainer;

  /// יוצר סט צבעים מלא ב-Theme lookup יחיד
  factory StatusColorSet.of(StatusType type, BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<AppBrand>();
    final cs = theme.colorScheme;

    return switch (type) {
      StatusType.success => StatusColorSet(
          color: brand?.success ?? StatusColors._successFallback,
          container: brand?.successContainer ?? StatusColors._successContainerFallback,
          onContainer: brand?.onSuccessContainer ?? StatusColors._onSuccessContainerFallback,
        ),
      StatusType.error => StatusColorSet(
          color: cs.error,
          container: cs.errorContainer,
          onContainer: cs.onErrorContainer,
        ),
      StatusType.warning => StatusColorSet(
          color: brand?.warning ?? StatusColors._warningFallback,
          container: brand?.warningContainer ?? StatusColors._warningContainerFallback,
          onContainer: brand?.onWarningContainer ?? StatusColors._onWarningContainerFallback,
        ),
      StatusType.pending => StatusColorSet(
          color: cs.outline,
          container: cs.surfaceContainerHighest,
          onContainer: cs.onSurfaceVariant,
        ),
      StatusType.info => StatusColorSet(
          color: cs.secondary,
          container: cs.secondaryContainer,
          onContainer: cs.onSecondaryContainer,
        ),
    };
  }
}

/// צבעי סטטוס סמנטיים - Theme-Aware
///
/// ✅ משתמש ב-Theme כמקור אמת יחיד!
/// - success/warning → מ-AppBrand (תומך Dynamic Color)
/// - error → מ-ColorScheme.error
/// - pending → מ-ColorScheme.outline (ניטרלי, תומך Dynamic Color)
/// - info → מ-ColorScheme.secondary (תומך Dynamic Color)
class StatusColors {
  const StatusColors._();

  // ========================================
  // צבעי Fallback (צבעי מותג - כשאין AppBrand זמין)
  // ========================================

  static const _successFallback = Color(0xFF4A9050);
  static const _warningFallback = Color(0xFFE8892A);
  static const _successContainerFallback = Color(0xFFD0E8D2);
  static const _warningContainerFallback = Color(0xFFFFE4BF);
  static const _onSuccessContainerFallback = Color(0xFF2B6530);
  static const _onWarningContainerFallback = Color(0xFFD4601A);

  // ========================================
  // Color API
  // ========================================

  /// מחזיר צבע סטטוס
  static Color getColor(StatusType type, BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<AppBrand>();
    final cs = theme.colorScheme;

    return switch (type) {
      StatusType.success => brand?.success ?? _successFallback,
      StatusType.error => cs.error,
      StatusType.warning => brand?.warning ?? _warningFallback,
      StatusType.pending => cs.outline,
      StatusType.info => cs.secondary,
    };
  }

  /// מחזיר צבע container
  static Color getContainer(StatusType type, BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<AppBrand>();
    final cs = theme.colorScheme;

    return switch (type) {
      StatusType.success => brand?.successContainer ?? _successContainerFallback,
      StatusType.error => cs.errorContainer,
      StatusType.warning => brand?.warningContainer ?? _warningContainerFallback,
      StatusType.pending => cs.surfaceContainerHighest,
      StatusType.info => cs.secondaryContainer,
    };
  }

  /// מחזיר צבע טקסט על container
  static Color getOnContainer(StatusType type, BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<AppBrand>();
    final cs = theme.colorScheme;

    return switch (type) {
      StatusType.success => brand?.onSuccessContainer ?? _onSuccessContainerFallback,
      StatusType.error => cs.onErrorContainer,
      StatusType.warning => brand?.onWarningContainer ?? _onWarningContainerFallback,
      StatusType.pending => cs.onSurfaceVariant,
      StatusType.info => cs.onSecondaryContainer,
    };
  }
}
