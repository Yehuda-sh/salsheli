// lib/widgets/common/offline_banner.dart — Offline banner — connectivity status bar shown when device is offline

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
      if (!mounted || _isOffline == offline) return;

      final wasOffline = _isOffline;
      setState(() => _isOffline = offline);

      // Confirm the recovery transition with a brief snackbar — without
      // it, the banner just silently disappears and the user is left
      // wondering whether their connection actually came back.
      if (wasOffline && !offline) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(AppStrings.layout.connectionRestored),
            duration: const Duration(seconds: 2),
          ));
      }
    });
    // Check initial state
    _connectivity.checkConnectivity().then((results) {
      if (mounted) {
        setState(() => _isOffline =
            results.every((r) => r == ConnectivityResult.none));
      }
    }).catchError((Object e) {
      debugPrint('OfflineBanner: connectivity check failed — $e');
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
          // liveRegion + excludeSemantics: announces "offline" once when
          // the banner first appears (canonical use case for liveRegion —
          // a dynamic error state that the user couldn't otherwise know
          // about), and hides the icon + Text below from being read a
          // second time as standalone nodes.
          ? Semantics(
              liveRegion: true,
              excludeSemantics: true,
              label: AppStrings.layout.offline,
              child: Container(
                width: double.infinity,
                color: cs.errorContainer,
                padding: const EdgeInsets.symmetric(
                  vertical: kSpacingTiny,
                  horizontal: kSpacingMedium,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off,
                        size: kIconSizeSmall, color: cs.onErrorContainer),
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
              ),
            )
          : const SizedBox(width: double.infinity, height: 0),
    );
  }
}
