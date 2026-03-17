import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/ui_constants.dart';
import '../../../../l10n/app_strings.dart';

/// תוצאת סריקת ברקוד
class BarcodeScanResult {
  final String barcode;
  BarcodeScanResult(this.barcode);
}

/// Bottom sheet עם סורק ברקוד
class BarcodeScannerSheet extends StatefulWidget {
  const BarcodeScannerSheet({super.key});

  @override
  State<BarcodeScannerSheet> createState() => _BarcodeScannerSheetState();
}

class _BarcodeScannerSheetState extends State<BarcodeScannerSheet> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null || barcode.isEmpty) return;

    _hasScanned = true;
    unawaited(HapticFeedback.mediumImpact());
    Navigator.pop(context, BarcodeScanResult(barcode));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          const SizedBox(height: kSpacingSmall),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            ),
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            AppStrings.shopping.scanBarcode,
            style: TextStyle(
              fontSize: kFontSizeLarge,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: kSpacingSmall),

          // Scanner viewport
          ClipRRect(
            borderRadius: BorderRadius.circular(kBorderRadius),
            child: SizedBox(
              height: 250,
              child: MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
              ),
            ),
          ),
          const SizedBox(height: kSpacingMedium),

          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.common.cancel),
          ),
          const SizedBox(height: kSpacingSmall),
        ],
      ),
    );
  }
}
