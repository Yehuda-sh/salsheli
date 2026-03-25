// 📄 File: lib/widgets/common/app_dialog.dart
//
// 🎯 Purpose: Premium dialog helper — glassmorphism + realistic shadows
//
// Usage:
//   AppDialog.show(
//     context: context,
//     child: MyDialogContent(),
//   );
//
// Features:
//   - BackdropFilter blur (notebook lines visible behind)
//   - Premium drop shadow (soft, wide, floating feel)
//   - Scale+Fade transition
//   - Consistent barrier color across all dialogs
//
// Version: 1.0
// Created: 22/03/2026

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/ui_constants.dart';

/// 🎯 Premium dialog helper — glassmorphism + realistic shadows
class AppDialog {
  AppDialog._();

  /// הצגת דיאלוג premium עם blur + shadow
  ///
  /// [child] — תוכן הדיאלוג (AlertDialog, Dialog, או כל widget)
  /// [barrierDismissible] — האם לחיצה על הרקע סוגרת (default: true)
  /// [useScaleTransition] — אנימציית scale+fade (default: true)
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
    bool useScaleTransition = true,
  }) {
    final cs = Theme.of(context).colorScheme;

    return showGeneralDialog<T>(
      context: context,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierDismissible: barrierDismissible,
      barrierColor: cs.scrim.withValues(alpha: kDialogBarrierAlpha),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: kDialogBlurSigma,
            sigmaY: kDialogBlurSigma,
          ),
          child: child,
        );
      },
      transitionBuilder: useScaleTransition
          ? (context, animation, secondaryAnimation, child) {
              return ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            }
          : null,
    );
  }
}
