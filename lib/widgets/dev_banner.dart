// 📄 lib/widgets/dev_banner.dart
//
// באנר DEV - מוצג רק במצב פיתוח. CustomPainter ribbon עם glass gradient,
// flutter_animate pulse + shimmer, ו-RepaintBoundary לאיזול אנימציה.
//
// עיצוב:
//   - _RibbonPainter: shadow רך + gradient fill + white glass highlight
//   - שקיפות ב-withValues(alpha:) לכל הגדרות הצבע
//   - אנימציה: fade pulse (0.78↔1.0, 2.4s) + shimmer בזווית הריבון
//   - RepaintBoundary: מונע re-render של עץ הווידג'טים בכל פריים
//   - IgnorePointer: לא חוסם לחיצות על אלמנטים מתחתיו
//
// 🔗 Related: AppConfig, main.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:memozap/config/app_config.dart';

/// 🏷️ באנר DEV - Glassmorphic ribbon בפינה ימנית עליונה
///
/// שימוש:
/// ```dart
/// Stack(
///   children: [
///     child,
///     const DevBanner(),
///   ],
/// )
/// ```
class DevBanner extends StatelessWidget {
  const DevBanner({super.key});

  // גודל תיבת הריבון — ריבוע 88×88
  static const double _size = 88.0;

  @override
  Widget build(BuildContext context) {
    // לא מציג כלום ב-production
    if (AppConfig.isProduction) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ribbonColor = isDark ? Colors.orange.shade600 : Colors.orange.shade700;

    return Positioned(
      top: 0,
      right: 0,
      child: IgnorePointer(
        // 🎨 RepaintBoundary — מאזל את אנימציית הלופ מעץ הווידג'טים
        child: RepaintBoundary(
          child: SizedBox(
            width: _size,
            height: _size,
            child: Stack(
              children: [
                // 🖌️ Ribbon: shadow רך + gradient fill + glass highlight
                CustomPaint(
                  painter: _RibbonPainter(color: ribbonColor),
                  size: const Size(_size, _size),
                ),

                // 🏷️ DEV — מרוכז על האלכסון, מסובב 45° שעון-הפוך
                Align(
                  // מרכז חישובי על אמצע האלכסון: midpoint of (0.25*w,0)→(w,0.75*h)
                  alignment: const Alignment(0.25, -0.25),
                  child: Transform.rotate(
                    angle: -math.pi / 4, // קריאה מימין-למעלה לשמאל-למטה
                    child: Text(
                      'DEV',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
              // ✨ Pulse (0.78↔1.0) + shimmer עדין בזווית הריבון — controller אחד
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fade(begin: 0.78, end: 1.0, duration: 2400.ms, curve: Curves.easeInOut)
              .shimmer(
                duration: 2400.ms,
                color: Colors.white.withValues(alpha: 0.18),
                angle: math.pi / 4, // shimmer רץ לאורך אלכסון הריבון
              ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🖌️ Ribbon Painter
// ═══════════════════════════════════════════════════════════════════════════

/// ציור ריבון אלכסוני בפינה ימנית עליונה.
///
/// שלוש שכבות ציור:
/// 1. Shadow רך (blur: 5, alpha: 0.18)
/// 2. Gradient fill (semi-transparent, topRight → bottomLeft)
/// 3. Glass highlight (white sheen, alpha 0.38 → 0.0)
class _RibbonPainter extends CustomPainter {
  final Color color;

  _RibbonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 1️⃣ Shadow רך מאחורי הריבון
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // 2️⃣ Gradient fill — semi-transparent, עמוק יותר בצד הגחון
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            color.withValues(alpha: 0.96),
            color.withValues(alpha: 0.80),
          ],
        ).createShader(rect),
    );

    // 3️⃣ Glass highlight — פס לבן עדין לאורך הקצה העליון (מדמה אור)
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.white.withValues(alpha: 0.38),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.42],
        ).createShader(rect),
    );
  }

  /// משולש ימני-עליון עם פינה מעוגלת עדינה בקצה החד
  Path _buildPath(Size size) {
    const double r = 3.0; // רדיוס עיגול הפינה הימנית-עליונה

    final path = Path();
    path.moveTo(size.width * 0.25, 0); // נקודת התחלה על הקצה העליון
    path.lineTo(size.width - r, 0); // ניגש לפינה
    path.arcToPoint(
      // פינה ימנית-עליונה מעוגלת
      Offset(size.width, r),
      radius: const Radius.circular(r),
    );
    path.lineTo(size.width, size.height * 0.75); // יורד לאורך הקצה הימני
    path.close(); // אלכסון חזרה לנקודת ההתחלה

    return path;
  }

  @override
  bool shouldRepaint(covariant _RibbonPainter old) => old.color != color;
}
