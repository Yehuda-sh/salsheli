// 📄 File: lib/widgets/common/app_dialog.dart
//
// Premium dialog wrapper — blur backdrop + scale/fade transition.
// All app dialogs should use AppDialog.show() for consistent look.

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
