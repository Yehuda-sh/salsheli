// 📄 File: lib/widgets/common/offline_banner.dart
// 🎯 Purpose: באנר הודעת מצב ללא אינטרנט
//
// ✨ Features:
// - עיצוב Glassmorphic (Frosted Orange)
// - משוב Haptic מובנה בשינוי סטטוס
// - תמיכה ב-AppBrand colors
// - אנימציית כניסה מלוטשת
//
// 📋 כולל:
// - מוצג כש-isOffline = true
// - אנימציית כניסה/יציאה חלקה
// - עיצוב מותאם לאפליקציה
// - אפשרות להתאמה אישית
//
// 🔗 Related: ConnectivityMixin, AppLayout
//
// Version: 4.0 - Hybrid Premium (Glassmorphic + Sensory)
// Last Updated: 22/02/2026

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';

/// 📡 באנר הודעה על מצב ללא אינטרנט
///
/// מוצג בראש המסך כאשר אין חיבור לאינטרנט.
/// כולל אנימציית כניסה/יציאה חלקה ומשוב Haptic.
///
/// Example:
/// ```dart
/// Column(
///   children: [
///     OfflineBanner(isOffline: !hasConnection),
///     // ...rest of content
///   ],
/// )
/// ```
class OfflineBanner extends StatefulWidget {
  /// האם לא מחובר לאינטרנט
  final bool isOffline;

  /// טקסט מותאם (אופציונלי)
  final String? message;

  /// צבע רקע (ברירת מחדל: errorContainer מה-Theme)
  final Color? backgroundColor;

  /// צבע טקסט (ברירת מחדל: onErrorContainer מה-Theme)
  final Color? textColor;

  /// callback לניסיון חוזר (אופציונלי)
  final VoidCallback? onRetry;

  const OfflineBanner({
    super.key,
    required this.isOffline,
    this.message,
    this.backgroundColor,
    this.textColor,
    this.onRetry,
  });

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  @override
  void didUpdateWidget(OfflineBanner oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 📳 Haptic כבד כשנכנסים למצב Offline
    if (widget.isOffline && !oldWidget.isOffline) {
      unawaited(HapticFeedback.heavyImpact());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: widget.isOffline
          ? _OfflineBannerContent(
              message: widget.message,
              backgroundColor: widget.backgroundColor,
              textColor: widget.textColor,
              onRetry: widget.onRetry,
            )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: -1.0, end: 0, curve: Curves.easeOutCubic)
          : const SizedBox.shrink(),
    );
  }
}

/// 🎨 תוכן הבאנר - Glassmorphic Frosted Orange
class _OfflineBannerContent extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onRetry;

  const _OfflineBannerContent({
    this.message,
    this.backgroundColor,
    this.textColor,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();

    final bgColor = (backgroundColor ?? brand?.warningContainer ?? cs.errorContainer)
        .withValues(alpha: 0.85);
    final fgColor = textColor ?? brand?.onWarningContainer ?? cs.onErrorContainer;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              bottom: BorderSide(
                color: cs.outlineVariant.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: kSpacingMedium,
                vertical: kSpacingSmall,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    color: fgColor,
                    size: 20,
                  ),
                  const Gap(kSpacingSmall),
                  Expanded(
                    child: Text(
                      message ?? AppStrings.layout.offline,
                      style: TextStyle(
                        color: fgColor,
                        fontWeight: FontWeight.w500,
                        fontSize: kFontSizeBody,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onRetry != null)
                    TextButton.icon(
                      onPressed: () {
                        unawaited(HapticFeedback.lightImpact());
                        onRetry!();
                      },
                      icon: Icon(
                        Icons.refresh,
                        color: fgColor,
                        size: 18,
                      ),
                      label: Text(
                        AppStrings.common.retry,
                        style: TextStyle(
                          color: fgColor,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 🌐 Wrapper שמוסיף OfflineBanner מעל כל מסך
///
/// שימוש נוח יותר לעטיפת מסכים שלמים.
///
/// Example:
/// ```dart
/// OfflineAwareScaffold(
///   isOffline: !hasConnection,
///   appBar: AppBar(title: Text('My Screen')),
///   body: MyContent(),
/// )
/// ```
class OfflineAwareScaffold extends StatelessWidget {
  final bool isOffline;
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final VoidCallback? onRetry;
  final bool extendBodyBehindAppBar;

  const OfflineAwareScaffold({
    super.key,
    required this.isOffline,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.onRetry,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      body: Column(
        children: [
          OfflineBanner(
            isOffline: isOffline,
            onRetry: onRetry,
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
