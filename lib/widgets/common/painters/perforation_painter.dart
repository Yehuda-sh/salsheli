// 📄 lib/widgets/common/painters/perforation_painter.dart
// Version 4.0 - Hybrid Premium | 22/02/2026
//
// CustomPainter שמצייר קו פרפורציה (מקווקו) אופקי.
// נותן תחושה של "חלק שניתן לתלישה" בכרטיסי פתקים.
//
// 🔗 Related: NotebookBackground, ShoppingListTile

import 'package:flutter/material.dart';

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

    final y = size.height / 2;
    var x = 0.0;
    final step = dashWidth + dashGap;

    while (x < size.width) {
      canvas.drawLine(
        Offset(x, y),
        Offset((x + dashWidth).clamp(0, size.width), y),
        paint,
      );
      x += step;
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
