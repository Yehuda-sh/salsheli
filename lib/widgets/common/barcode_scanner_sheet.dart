// 📄 lib/widgets/common/barcode_scanner_sheet.dart
//
// Bottom sheet עם סורק ברקוד — MobileScanner + scan-guide overlay + torch.

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';

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

class _BarcodeScannerSheetState extends State<BarcodeScannerSheet>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _hasScanned = false;
  bool _torchOn = false;

  late final AnimationController _lineAnim;

  @override
  void initState() {
    super.initState();
    _lineAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _lineAnim.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned || !mounted) return;
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null || barcode.isEmpty) return;

    _hasScanned = true;
    unawaited(HapticFeedback.mediumImpact());
    Navigator.pop(context, BarcodeScanResult(barcode));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final strings = AppStrings.shopping;
    final viewportHeight = MediaQuery.of(context).size.height * 0.35;

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
              color: cs.outline.withValues(alpha: kOpacityLight),
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            ),
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            strings.scanBarcode,
            style: TextStyle(
              fontSize: kFontSizeLarge,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: kSpacingXTiny),

          // Instruction text
          Text(
            strings.scanHint,
            style: TextStyle(
              fontSize: kFontSizeSmall,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: kSpacingSmall),

          // Scanner viewport + overlay
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kBorderRadiusLarge),
              child: SizedBox(
                height: viewportHeight,
                child: Stack(
                  children: [
                    // Camera feed
                    MobileScanner(
                      controller: _controller,
                      onDetect: _onDetect,
                      errorBuilder: (context, _) => Container(
                        color: cs.errorContainer,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.no_photography_outlined, size: kIconSizeXLarge, color: cs.onErrorContainer),
                              const SizedBox(height: kSpacingSmall),
                              Text(
                                strings.cameraError,
                                style: TextStyle(color: cs.onErrorContainer, fontSize: kFontSizeSmall),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Semi-transparent overlay with transparent scan window
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ScanOverlayPainter(
                          borderColor: cs.primary,
                          overlayColor: Colors.black.withValues(alpha: 0.4),
                        ),
                      ),
                    ),

                    // Animated scan line
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _lineAnim,
                        builder: (context, _) {
                          return CustomPaint(
                            painter: _ScanLinePainter(
                              progress: _lineAnim.value,
                              lineColor: cs.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: kSpacingSmall),

          // Torch + Cancel buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 🔦 Torch toggle
                IconButton(
                  onPressed: () {
                    _controller.toggleTorch();
                    if (mounted) setState(() => _torchOn = !_torchOn);
                  },
                  icon: Icon(
                    _torchOn ? Icons.flash_on : Icons.flash_off,
                    color: _torchOn ? cs.primary : cs.onSurfaceVariant,
                  ),
                  tooltip: strings.toggleFlash,
                ),
                // ביטול
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppStrings.common.cancel),
                ),
              ],
            ),
          ),
          const SizedBox(height: kSpacingSmall),
        ],
      ),
    );
  }
}

/// Paints the darkened overlay with a clear rectangular scan window in
/// the center, plus four corner brackets to guide the user.
class _ScanOverlayPainter extends CustomPainter {
  final Color borderColor;
  final Color overlayColor;

  _ScanOverlayPainter({required this.borderColor, required this.overlayColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Scan window — 70% of width, centered, golden-ratio height
    final windowW = size.width * 0.70;
    final windowH = windowW * 0.45; // landscape barcode aspect
    final left = (size.width - windowW) / 2;
    final top = (size.height - windowH) / 2;
    final scanRect = Rect.fromLTWH(left, top, windowW, windowH);

    // Dark overlay with cutout
    final overlayPaint = Paint()..color = overlayColor;
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(kBorderRadius))),
      ),
      overlayPaint,
    );

    // Corner brackets (like a camera viewfinder)
    final bracketPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    const bracketLen = 20.0;
    const r = kBorderRadius;

    // Top-left corner
    canvas.drawArc(Rect.fromLTWH(left, top, r * 2, r * 2), math.pi, math.pi / 2, false, bracketPaint);
    canvas.drawLine(Offset(left, top + r), Offset(left, top + bracketLen), bracketPaint);
    canvas.drawLine(Offset(left + r, top), Offset(left + bracketLen, top), bracketPaint);

    // Top-right corner
    canvas.drawArc(Rect.fromLTWH(left + windowW - r * 2, top, r * 2, r * 2), -math.pi / 2, math.pi / 2, false, bracketPaint);
    canvas.drawLine(Offset(left + windowW, top + r), Offset(left + windowW, top + bracketLen), bracketPaint);
    canvas.drawLine(Offset(left + windowW - r, top), Offset(left + windowW - bracketLen, top), bracketPaint);

    // Bottom-left corner
    canvas.drawArc(Rect.fromLTWH(left, top + windowH - r * 2, r * 2, r * 2), math.pi / 2, math.pi / 2, false, bracketPaint);
    canvas.drawLine(Offset(left, top + windowH - r), Offset(left, top + windowH - bracketLen), bracketPaint);
    canvas.drawLine(Offset(left + r, top + windowH), Offset(left + bracketLen, top + windowH), bracketPaint);

    // Bottom-right corner
    canvas.drawArc(Rect.fromLTWH(left + windowW - r * 2, top + windowH - r * 2, r * 2, r * 2), 0, math.pi / 2, false, bracketPaint);
    canvas.drawLine(Offset(left + windowW, top + windowH - r), Offset(left + windowW, top + windowH - bracketLen), bracketPaint);
    canvas.drawLine(Offset(left + windowW - r, top + windowH), Offset(left + windowW - bracketLen, top + windowH), bracketPaint);
  }

  @override
  bool shouldRepaint(covariant _ScanOverlayPainter old) =>
      borderColor != old.borderColor || overlayColor != old.overlayColor;
}

/// Paints a horizontal scanning line that sweeps up and down inside the
/// scan window, giving visual feedback that the scanner is active.
class _ScanLinePainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  final Color lineColor;

  _ScanLinePainter({required this.progress, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final windowW = size.width * 0.70;
    final windowH = windowW * 0.45;
    final left = (size.width - windowW) / 2;
    final top = (size.height - windowH) / 2;

    // Line sweeps vertically within the scan window
    final y = top + (windowH * progress);
    final lineGradient = LinearGradient(
      colors: [
        lineColor.withValues(alpha: 0.0),
        lineColor.withValues(alpha: 0.7),
        lineColor.withValues(alpha: 0.7),
        lineColor.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.2, 0.8, 1.0],
    );

    final linePaint = Paint()
      ..shader = lineGradient.createShader(
        Rect.fromLTWH(left + kSpacingMedium, y - 1, windowW - kSpacingLarge, 2),
      );

    canvas.drawRect(
      Rect.fromLTWH(left + kSpacingMedium, y - 1, windowW - kSpacingLarge, 2),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter old) => progress != old.progress;
}
