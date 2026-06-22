// lib/screens/auth/widgets/timed_loading_overlay.dart — Auth loading overlay with a "taking longer" escape hatch

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/ui_constants.dart';
import '../../../l10n/app_strings.dart';
import 'loading_overlay.dart';

/// Full-screen auth loading overlay (glass blur + spinner) with a built-in
/// escape hatch: after [timeout] it surfaces a "taking longer than expected"
/// message + Cancel, so a stuck auth call never traps the user behind an
/// indefinite spinner.
///
/// Mounted only while loading (`if (isLoading) ...`), so the timer is managed
/// automatically by the widget lifecycle — no timer bookkeeping in the screen.
/// The screen still owns the abandon/race guard via [onCancel].
class TimedLoadingOverlay extends StatefulWidget {
  /// Spinner accent color.
  final Color color;

  /// Called when the user taps Cancel on the escape hatch.
  final VoidCallback onCancel;

  /// How long to wait before showing the escape hatch.
  final Duration timeout;

  const TimedLoadingOverlay({
    super.key,
    required this.color,
    required this.onCancel,
    this.timeout = const Duration(seconds: 10),
  });

  @override
  State<TimedLoadingOverlay> createState() => _TimedLoadingOverlayState();
}

class _TimedLoadingOverlayState extends State<TimedLoadingOverlay> {
  Timer? _timer;
  bool _takingLong = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.timeout, () {
      if (mounted) setState(() => _takingLong = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: kGlassBlurMedium, sigmaY: kGlassBlurMedium),
      child: Container(
        // 0.25 scrim — מעמעם את הטופס מאחורי ה-blur בלי להחשיך לגמרי
        // (ה-BackdropFilter כבר עושה את עיקר העבודה).
        color: cs.scrim.withValues(alpha: 0.25),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingOverlay(color: widget.color),
              // ⏳ מופיע רק אם הטעינה נתקעת — מוצא למשתמש.
              if (_takingLong) ...[
                const SizedBox(height: kSpacingLarge),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    AppStrings.auth.loadingTakingLong,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: kOpacityStrong),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: kSpacingSmall),
                OutlinedButton(
                  onPressed: widget.onCancel,
                  child: Text(AppStrings.common.cancel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
