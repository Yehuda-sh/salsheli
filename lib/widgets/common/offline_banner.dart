// 📄 lib/widgets/common/offline_banner.dart
//
// 🔌 באנר "אין חיבור לאינטרנט" — מוצג בראש המסך כשאין רשת

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../core/ui_constants.dart';

class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isOffline = false;
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final offline = results.every((r) => r == ConnectivityResult.none);
      if (mounted && _isOffline != offline) {
        setState(() => _isOffline = offline);
      }
    });
    // Check initial state
    Connectivity().checkConnectivity().then((results) {
      if (mounted) {
        setState(() => _isOffline =
            results.every((r) => r == ConnectivityResult.none));
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOffline) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      color: cs.errorContainer,
      padding: const EdgeInsets.symmetric(
        vertical: kSpacingTiny,
        horizontal: kSpacingMedium,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: kIconSizeSmall, color: cs.onErrorContainer),
          const SizedBox(width: kSpacingSmall),
          Text(
            'אין חיבור לאינטרנט',
            style: TextStyle(
              fontSize: kFontSizeSmall,
              color: cs.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
