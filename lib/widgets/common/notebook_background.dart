// 📄 lib/widgets/common/notebook_background.dart
//
// רקע מחברת עם קווים - CustomPaint יעיל.
//
// ✅ פרמטרים חדשים:
//    - lineOpacity: עוצמת הקווים (ברירת מחדל: kNotebookLineOpacity)
//    - lineColor: צבע קווים מותאם (ברירת מחדל: מ-AppBrand)
//    - showRedLine: הצגת קו אדום (ברירת מחדל: true)
//    - fadeEdges: fade עדין למעלה ולמטה (ברירת מחדל: false)
//
// 🔗 Related: ui_constants.dart, app_theme.dart (AppBrand)

import 'package:flutter/material.dart';
import '../../core/ui_constants.dart';
import '../../theme/app_theme.dart';

/// רקע בסגנון מחברת עם קווים אופקיים וקו אדום אנכי
///
/// מציג רקע נייר עם קווים כמו במחברת בית ספר אמיתית.
///
/// ```dart
/// NotebookBackground(
///   lineOpacity: kNotebookLineOpacitySubtle,
///   lineColor: kNotebookBlueSoft,
///   showRedLine: false,
///   fadeEdges: true,
/// )
/// ```
///
/// דוגמה (קלאסי - כמו קודם):
/// ```dart
/// const NotebookBackground() // ברירת מחדל = קווים בולטים
/// ```
class NotebookBackground extends StatelessWidget {
  /// עוצמת הקווים האופקיים (0.0 = שקוף, 1.0 = מלא)
  /// ברירת מחדל: kNotebookLineOpacity (0.5)
  final double? lineOpacity;

  /// צבע הקווים האופקיים (אופציונלי)
  /// ברירת מחדל: מ-AppBrand.notebookBlue
  final Color? lineColor;

  /// האם להציג קו אדום אנכי
  /// ברירת מחדל: true
  final bool showRedLine;

  /// עוצמת הקו האדום (0.0 = שקוף, 1.0 = מלא)
  /// ברירת מחדל: kNotebookRedLineOpacity (0.4)
  final double? redLineOpacity;

  /// רוחב הקו האדום
  /// ברירת מחדל: kNotebookRedLineWidth (2.0)
  final double? redLineWidth;

  /// האם להוסיף fade עדין למעלה ולמטה
  /// ברירת מחדל: false
  final bool fadeEdges;

  const NotebookBackground({
    super.key,
    this.lineOpacity,
    this.lineColor,
    this.showRedLine = true,
    this.redLineOpacity,
    this.redLineWidth,
    this.fadeEdges = false,
  });

  /// גרסה עדינה למסכי Auth — קווים חלשים, בלי קו אדום, עם fade
  const NotebookBackground.subtle({
    super.key,
  })  : lineOpacity = 0.10,
        lineColor = kNotebookBlueSoft,
        showRedLine = false,
        redLineOpacity = null,
        redLineWidth = null,
        fadeEdges = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<AppBrand>();
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final effectiveLineColor = lineColor ?? brand?.notebookBlue ?? kNotebookBlue;
    final effectiveLineOpacity = lineOpacity ?? kNotebookLineOpacity;

    // ✅ ExcludeSemantics - רקע דקורטיבי, לא רלוונטי לקוראי מסך
    // ✅ RepaintBoundary - מונע רינדור חוזר כשהתוכן מעל משתנה
    Widget background = ExcludeSemantics(
      child: RepaintBoundary(
        child: SizedBox.expand(
          child: CustomPaint(
            painter: _NotebookPainter(
              paperBackground: brand?.paperBackground ??
                  (theme.brightness == Brightness.dark ? kDarkPaperBackground : kPaperBackground),
              notebookBlue: effectiveLineColor,
              lineOpacity: effectiveLineOpacity,
              notebookRed: brand?.notebookRed ?? kNotebookRed,
              redLineOpacity: redLineOpacity ?? kNotebookRedLineOpacity,
              redLineWidth: redLineWidth ?? kNotebookRedLineWidth,
              isRtl: isRtl,
              showRedLine: showRedLine,
            ),
          ),
        ),
      ),
    );

    // Fade edges - gradient עדין למעלה ולמטה
    if (fadeEdges) {
      final bgColor = brand?.paperBackground ??
          (theme.brightness == Brightness.dark ? kDarkPaperBackground : kPaperBackground);

      background = Stack(
        children: [
          background,
          // Fade למעלה
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 80,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      bgColor,
                      bgColor.withValues(alpha: 0),
                    ],
                  ),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          // Fade למטה
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      bgColor,
                      bgColor.withValues(alpha: 0),
                    ],
                  ),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      );
    }

    return background;
  }
}

/// Painter עבור רקע המחברת
class _NotebookPainter extends CustomPainter {
  final Color paperBackground;
  final Color notebookBlue;
  final double lineOpacity;
  final Color notebookRed;
  final double redLineOpacity;
  final double redLineWidth;
  final bool isRtl;
  final bool showRedLine;

  _NotebookPainter({
    required this.paperBackground,
    required this.notebookBlue,
    required this.lineOpacity,
    required this.notebookRed,
    required this.redLineOpacity,
    required this.redLineWidth,
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
      ..strokeWidth = 1.0;

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
        ..color = notebookRed.withValues(alpha: redLineOpacity)
        ..strokeWidth = redLineWidth;

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
        redLineOpacity != oldDelegate.redLineOpacity ||
        redLineWidth != oldDelegate.redLineWidth ||
        isRtl != oldDelegate.isRtl ||
        showRedLine != oldDelegate.showRedLine;
  }
}
