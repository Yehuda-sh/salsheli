import 'package:flutter/material.dart';
import 'package:memozap/theme/design_tokens.dart';

/// 🎬 Page Transitions אחידים לכל האפליקציה
///
/// שימוש:
/// ```dart
/// Navigator.push(context, AppPageTransition(page: MyScreen()));
/// ```

/// Fade transition — ברירת מחדל
class AppPageTransition extends PageRouteBuilder {
  AppPageTransition({required Widget page})
      : super(
          transitionDuration: AppTokens.durationMedium,
          reverseTransitionDuration: AppTokens.durationFast,
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: child,
          ),
        );
}

/// Slide from bottom — לדיאלוגים ו-sheets
class AppSlideUpTransition extends PageRouteBuilder {
  AppSlideUpTransition({required Widget page})
      : super(
          transitionDuration: AppTokens.durationMedium,
          reverseTransitionDuration: AppTokens.durationFast,
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, anim, __, child) {
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));

            return SlideTransition(
              position: slide,
              child: FadeTransition(
                opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                child: child,
              ),
            );
          },
        );
}

/// Shared axis — למעבר בין tabs/sections
class AppSharedAxisTransition extends PageRouteBuilder {
  AppSharedAxisTransition({required Widget page})
      : super(
          transitionDuration: AppTokens.durationMedium,
          reverseTransitionDuration: AppTokens.durationFast,
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, anim, __, child) {
            final fade = CurvedAnimation(parent: anim, curve: Curves.easeOut);
            final scale = Tween<double>(begin: 0.94, end: 1.0)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));

            return FadeTransition(
              opacity: fade,
              child: ScaleTransition(scale: scale, child: child),
            );
          },
        );
}
