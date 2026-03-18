// 📄 lib/widgets/common/offline_banner.dart
//
// 🔌 באנר "אין חיבור לאינטרנט" — מוצג בראש המסך כשאין רשת
// אנימציית slide-down/up חלקה

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';

class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isOffline = false;
  late final Connectivity _connectivity;
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final offline = results.every((r) => r == ConnectivityResult.none);
      if (mounted && _isOffline != offline) {
        setState(() => _isOffline = offline);
      }
    });
    // Check initial state
    _connectivity.checkConnectivity().then((results) {
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
    final cs = Theme.of(context).colorScheme;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _isOffline
          ? Container(
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
                    AppStrings.layout.offline,
                    style: TextStyle(
                      fontSize: kFontSizeSmall,
                      color: cs.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox(width: double.infinity, height: 0),
    );
  }
}
