// lib/screens/auth/widgets/loading_overlay.dart — Loading overlay — full-screen translucent overlay with spinner during auth

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/ui_constants.dart';
import '../../../l10n/app_strings.dart';

/// כשנמשיך לחכות מעבר ל-window הזה, ה-overlay מחליף את הטקסט
/// ל-"לוקח יותר מהצפוי" וחושף כפתור Cancel — אם ה-caller מספק
/// `onCancel`. Firebase Auth מתחזק עד ל-120s על reCAPTCHA retries,
/// ובלי escape hatch המסך נראה תקוע.
const Duration _kShowCancelAfter = Duration(seconds: 8);

class LoadingOverlay extends StatefulWidget {
  final Color color;

  /// אם null — לא נציג כפתור Cancel גם אחרי 8s (התנהגות תאימה לאחור).
  final VoidCallback? onCancel;

  const LoadingOverlay({
    super.key,
    required this.color,
    this.onCancel,
  });

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  late final List<String> _messages = [
    AppStrings.auth.loadingCheckingDetails,
    AppStrings.auth.loadingConnecting,
    AppStrings.auth.loadingAlmostThere,
  ];

  int _messageIndex = 0;
  bool _showCancel = false;
  Timer? _cycleTimer;
  Timer? _cancelTimer;

  @override
  void initState() {
    super.initState();
    _cycleTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _messages.length;
        });
      }
    });
    // Reveal the "taking longer" copy + Cancel button once we've blown
    // past the typical signup happy-path window. We don't tear down the
    // cycle timer — the long-loading copy replaces the cycling text in
    // the build method.
    _cancelTimer = Timer(_kShowCancelAfter, () {
      if (mounted) {
        setState(() => _showCancel = true);
      }
    });
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    _cancelTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // liveRegion + excludeSemantics: announce "loading" once when the
    // overlay first appears (canonical CLAUDE.md A11y use case — a
    // dynamic loading state). The cycling messages below are theatrical
    // for visual users only — letting them feed back into TalkBack
    // would re-read every 1500ms, which is just noise.
    return Semantics(
      liveRegion: true,
      excludeSemantics: true,
      label: AppStrings.common.loading,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: widget.color),
          const SizedBox(height: kSpacingMedium),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _showCancel
                  ? AppStrings.auth.loadingTakingLonger
                  : _messages[_messageIndex],
              key: ValueKey(_showCancel ? -1 : _messageIndex),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: kFontSizeMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (_showCancel && widget.onCancel != null) ...[
            const SizedBox(height: kSpacingMedium),
            TextButton(
              onPressed: widget.onCancel,
              child: Text(AppStrings.auth.loadingCancelButton),
            ),
          ],
        ],
      ),
    );
  }
}
