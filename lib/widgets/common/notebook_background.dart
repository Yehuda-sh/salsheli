// lib/widgets/common/notebook_background.dart — Notebook background — lined paper with red margin line (app signature design)

import 'package:flutter/material.dart';
import '../../core/ui_constants.dart';
import '../../theme/app_theme.dart';

/// רקע בסגנון מחברת עם קווים אופקיים וקו אדום אנכי
///
/// מציג רקע נייר עם קווים כמו במחברת בית ספר אמיתית.
///
/// ```dart
/// const NotebookBackground()         // קלאסי — קווים בולטים + קו אדום
/// const NotebookBackground.subtle()  // עדין — למסכי Auth, בלי קו אדום, עם fade
/// ```
///
/// שתי הווריאציות הן StatelessWidget, RTL-aware (הקו האדום
/// עובר לימין במצב RTL), ועטופות ב-RepaintBoundary + ExcludeSemantics.
class NotebookBackground extends StatelessWidget {
  /// `true` רק עבור [NotebookBackground.subtle] — בוחר צבעים רכים, מסתיר
  /// את הקו האדום, ומוסיף fade בקצוות.
  final bool _isSubtle;

  const NotebookBackground({super.key}) : _isSubtle = false;

  /// גרסה עדינה למסכי Auth — קווים חלשים, בלי קו אדום, עם fade.
  /// Theme-aware: uses [kNotebookBlueSoft] in light mode and
  /// [kNotebookBlueSoftDark] in dark mode.
  const NotebookBackground.subtle({super.key}) : _isSubtle = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<AppBrand>();
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final bgColor = brand?.paperBackground ??
        (theme.brightness == Brightness.dark
            ? kDarkPaperBackground
            : kPaperBackground);

    final Color lineColor;
    final double lineOpacity;
    if (_isSubtle) {
      lineColor = theme.brightness == Brightness.dark
          ? kNotebookBlueSoftDark
          : kNotebookBlueSoft;
      // Lower than kNotebookLineOpacity so auth screens don't compete
      // with the form fields for visual attention.
      lineOpacity = 0.10;
    } else {
      lineColor = brand?.notebookBlue ?? kNotebookBlue;
      lineOpacity = kNotebookLineOpacity;
    }

    // ✅ ExcludeSemantics - רקע דקורטיבי, לא רלוונטי לקוראי מסך
    // ✅ RepaintBoundary - מונע רינדור חוזר כשהתוכן מעל משתנה
    Widget background = ExcludeSemantics(
      child: RepaintBoundary(
        child: SizedBox.expand(
          child: CustomPaint(
            painter: _NotebookPainter(
              paperBackground: bgColor,
              notebookBlue: lineColor,
              lineOpacity: lineOpacity,
              notebookRed: brand?.notebookRed ?? kNotebookRed,
              isRtl: isRtl,
              showRedLine: !_isSubtle,
            ),
          ),
        ),
      ),
    );

    // Fade gradient בקצוות — רק לגרסה העדינה.
    if (_isSubtle) {
      background = Stack(
        children: [
          background,
          _buildFadeEdge(bgColor, top: true),
          _buildFadeEdge(bgColor, top: false),
        ],
      );
    }

    return background;
  }

  /// Fade gradient edge (top or bottom)
  Widget _buildFadeEdge(Color bgColor, {required bool top}) {
    return Positioned(
      top: top ? 0 : null,
      bottom: top ? null : 0,
      left: 0,
      right: 0,
      height: 80,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: top ? Alignment.topCenter : Alignment.bottomCenter,
              end: top ? Alignment.bottomCenter : Alignment.topCenter,
              colors: [bgColor, bgColor.withValues(alpha: 0)],
            ),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

/// Painter עבור רקע המחברת
class _NotebookPainter extends CustomPainter {
  final Color paperBackground;
  final Color notebookBlue;
  final double lineOpacity;
  final Color notebookRed;
  final bool isRtl;
  final bool showRedLine;

  _NotebookPainter({
    required this.paperBackground,
    required this.notebookBlue,
    required this.lineOpacity,
    required this.notebookRed,
    required this.isRtl,
    required this.showRedLine,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // רקע נייר
    final bgPaint = Paint()..color = paperBackground;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // קווים אופקיים
    final bluePaint = Paint()
      ..color = notebookBlue.withValues(alpha: lineOpacity)
      ..strokeWidth = kNotebookLineStrokeWidth;

    for (double y = kNotebookLineSpacing;
        y < size.height;
        y += kNotebookLineSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        bluePaint,
      );
    }

    // קו אדום אנכי (RTL-aware)
    if (showRedLine) {
      final redLinePaint = Paint()
        ..color = notebookRed.withValues(alpha: kNotebookRedLineOpacity)
        ..strokeWidth = kNotebookRedLineWidth;

      final redLineX = isRtl
          ? size.width - kNotebookRedLineOffset
          : kNotebookRedLineOffset;

      canvas.drawLine(
        Offset(redLineX, 0),
        Offset(redLineX, size.height),
        redLinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NotebookPainter oldDelegate) {
    return paperBackground != oldDelegate.paperBackground ||
        notebookBlue != oldDelegate.notebookBlue ||
        lineOpacity != oldDelegate.lineOpacity ||
        notebookRed != oldDelegate.notebookRed ||
        isRtl != oldDelegate.isRtl ||
        showRedLine != oldDelegate.showRedLine;
  }
}
