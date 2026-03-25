// 📄 lib/screens/auth/widgets/loading_overlay.dart
//
// 🎯 Animated loading overlay for auth screens
//    Cycles through progress messages with AnimatedSwitcher
//
// 🔗 Related: login_screen.dart, register_screen.dart

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

    return Column(
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
    );
  }
}
