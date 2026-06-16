// lib/widgets/common/painters/perforation_painter.dart — Perforation painter — dotted tear-line effect for receipt/sticky note edges

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/ui_constants.dart';

/// Painter שמצייר קו אופקי מקווקו (perforation / tear line)
///
/// שימוש:
/// ```dart
/// CustomPaint(
///   size: const Size(double.infinity, 1),
///   painter: PerforationPainter(
///     color: theme.colorScheme.outline.withValues(alpha: 0.3),
///   ),
/// )
/// ```
class PerforationPainter extends CustomPainter {
  /// צבע הקו המקווקו
  final Color color;

  /// רוחב כל מקטע (dash)
  final double dashWidth;

  /// רווח בין מקטעים
  final double dashGap;

  /// עובי הקו
  final double strokeWidth;

  const PerforationPainter({
    required this.color,
    this.dashWidth = 4.0,
    this.dashGap = 3.0,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final maxX = size.width;
    final y = size.height / 2;
    final step = dashWidth + dashGap;
    // Skip a trailing dash that would render as a stub of half a dash
    // or less. With strokeCap.round even a 2px remainder reads as a
    // floating dot — the previous implementation `clamp`d the end x
    // and let the stub through, which broke the rhythm of the tear
    // line. The `<=` is intentional: a stub of exactly half a dash
    // gets dropped along with anything thinner.
    final minVisibleDash = dashWidth / 2;

    for (var x = 0.0; x < maxX; x += step) {
      final endX = math.min(x + dashWidth, maxX);
      if (endX - x <= minVisibleDash) break;
      canvas.drawLine(Offset(x, y), Offset(endX, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant PerforationPainter oldDelegate) {
    return color != oldDelegate.color ||
        dashWidth != oldDelegate.dashWidth ||
        dashGap != oldDelegate.dashGap ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}

/// The app's standard dashed "tear line" (perforation divider).
///
/// Wraps [PerforationPainter] so call sites don't repeat the CustomPaint +
/// color boilerplate, and the line looks identical everywhere. Full width by
/// default (a divider between sections); pass [width] for a short inline mark
/// (e.g. the little tear before a "total" label).
class PerforationLine extends StatelessWidget {
  /// Line width. Defaults to full width; pass a fixed value for a short mark.
  final double width;

  const PerforationLine({super.key, this.width = double.infinity});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, 1),
      painter: PerforationPainter(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: kOpacityLight),
      ),
    );
  }
}
