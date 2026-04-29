// lib/screens/auth/widgets/loading_overlay.dart — Loading overlay — full-screen translucent overlay with spinner during auth

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/ui_constants.dart';
import '../../../l10n/app_strings.dart';

class LoadingOverlay extends StatefulWidget {
  final Color color;

  const LoadingOverlay({super.key, required this.color});

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
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _messages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
              _messages[_messageIndex],
              key: ValueKey(_messageIndex),
              style: TextStyle(
                color: cs.onSurface,
                fontSize: kFontSizeMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
