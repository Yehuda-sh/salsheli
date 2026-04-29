// lib/widgets/common/app_dialog.dart — App dialog — themed AlertDialog wrapper with notebook styling

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/ui_constants.dart';

/// Premium dialog wrapper with blur backdrop and scale+fade transition
class AppDialog {
  AppDialog._();

  /// הצגת דיאלוג עם blur backdrop ואנימציית scale+fade
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
  }) {
    final cs = Theme.of(context).colorScheme;

    return showGeneralDialog<T>(
      context: context,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierDismissible: barrierDismissible,
      barrierColor: cs.scrim.withValues(alpha: kDialogBarrierAlpha),
      transitionDuration: kDialogTransitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) {
        // SizedBox.expand forces the BackdropFilter to occupy the full
        // screen. Without it, BackdropFilter sizes to the inner dialog
        // (a small AlertDialog ~300px wide) and the blur only covers
        // that rectangle — the rest of the screen behind the barrier
        // stays sharp, breaking the "premium" feel the wrapper is
        // supposed to deliver.
        return SizedBox.expand(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: kDialogBlurSigma,
              sigmaY: kDialogBlurSigma,
            ),
            child: child,
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
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
      },
    );
  }
}
