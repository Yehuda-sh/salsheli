import 'package:flutter/material.dart';

class LoadingOverlay extends StatefulWidget {
  final Color color;

  const _LoadingOverlay({required this.color});

  @override
  State<LoadingOverlay> createState() => LoadingOverlayState();
}

class LoadingOverlayState extends State<LoadingOverlay> {
  static const _messages = [
    'בודק פרטים...',
    'מתחבר לשרת...',
    'כמעט שם...',
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
        SizedBox(height: kSpacingMedium),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
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
