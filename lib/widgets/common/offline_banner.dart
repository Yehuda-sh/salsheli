// 📄 File: lib/widgets/common/offline_banner.dart
// 🎯 Purpose: באנר הודעת מצב ללא אינטרנט
//
// 📋 Features:
// - מוצג כש-isOffline = true
// - אנימציית כניסה/יציאה חלקה
// - עיצוב מותאם לאפליקציה
// - אפשרות להתאמה אישית
//
// 📝 Version: 1.0
// 📅 Created: 01/2026

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';

/// 📡 באנר הודעה על מצב ללא אינטרנט
///
/// מוצג בראש המסך כאשר אין חיבור לאינטרנט.
/// כולל אנימציית כניסה/יציאה חלקה.
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
class OfflineBanner extends StatelessWidget {
  /// האם לא מחובר לאינטרנט
  final bool isOffline;

  /// טקסט מותאם (אופציונלי)
  final String? message;

  /// צבע רקע (ברירת מחדל: כתום)
  final Color? backgroundColor;

  /// צבע טקסט (ברירת מחדל: לבן)
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
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: isOffline
          ? _OfflineBannerContent(
              message: message,
              backgroundColor: backgroundColor,
              textColor: textColor,
              onRetry: onRetry,
            )
              .animate()
              .fadeIn(duration: 200.ms)
              .slideY(begin: -0.5, end: 0, curve: Curves.easeOut)
          : const SizedBox.shrink(),
    );
  }
}

/// 🎨 תוכן הבאנר
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
    final bgColor = backgroundColor ?? Colors.orange.shade700;
    final fgColor = textColor ?? Colors.white;

    return Material(
      color: bgColor,
      elevation: 2,
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
              const SizedBox(width: kSpacingSmall),
              Expanded(
                child: Text(
                  message ?? AppStrings.layout.offline,
                  style: TextStyle(
                    color: fgColor,
                    fontWeight: FontWeight.w500,
                    fontSize: kFontSizeBody,
                  ),
                ),
              ),
              if (onRetry != null)
                TextButton.icon(
                  onPressed: onRetry,
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

  const OfflineAwareScaffold({
    super.key,
    required this.isOffline,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
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
