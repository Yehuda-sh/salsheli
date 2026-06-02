// lib/widgets/common/app_wordmark.dart — Two-tone "MemoZap" wordmark in the Caveat hand — "Memo" brand blue, "Zap" action green

import 'package:flutter/material.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';

/// The app name rendered in the Caveat handwriting font, two-tone: the
/// name is split at its inner capital so "Memo" (the calm note) wears the
/// brand blue and "Zap" (energy/speed) wears the action green — encoding
/// both halves of the name and rhyming with the primary green CTAs.
///
/// Degrades to a single colour if the name ever stops being CamelCase.
/// Used on Welcome, the app-bar title, and the index/splash screens so the
/// brand reads identically everywhere (one source of truth).
class AppWordmark extends StatelessWidget {
  final double fontSize;

  const AppWordmark({super.key, this.fontSize = kFontSizeDisplay});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();

    final name = AppStrings.appName;
    final splitIdx = name.lastIndexOf(RegExp(r'[A-Z]'));
    final first = splitIdx > 0 ? name.substring(0, splitIdx) : name;
    final second = splitIdx > 0 ? name.substring(splitIdx) : '';

    final base = TextStyle(
      fontFamily: 'Caveat',
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      // Tuned for the Caveat hand: a touch of tracking + tight line-height
      // so it reads as one mark.
      letterSpacing: 0.5,
      height: 1.0,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: first, style: base.copyWith(color: cs.primary)),
          TextSpan(text: second, style: base.copyWith(color: brand?.success ?? cs.primary)),
        ],
      ),
    );
  }
}
