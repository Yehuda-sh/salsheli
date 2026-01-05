// 📄 lib/widgets/common/notebook_background.dart
//
// רקע מחברת עם קווים כחולים וקו אדום - CustomPaint יעיל.
// קווים אופקיים כחולים + קו אדום אנכי RTL-aware.
//
// ✅ תיקונים:
//    - הוספת RepaintBoundary לביצועים (מונע רינדור חוזר)
//    - הוספת ExcludeSemantics (רקע דקורטיבי, לא לקוראי מסך)
//    - צבע רקע מ-AppBrand.paperBackground (תומך Dark Mode)
//    - קו אדום RTL-aware (ימין באפליקציה עברית)
//
// 🔗 Related: ui_constants.dart, app_theme.dart (AppBrand)

import 'package:flutter/material.dart';
import '../../core/ui_constants.dart';
import '../../theme/app_theme.dart';

/// רקע בסגנון מחברת עם קווים אופקיים וקו אדום אנכי
///
/// מציג רקע נייר עם קווים כחולים כמו במחברת בית ספר אמיתית,
/// כולל קו אדום מצד שמאל (או ימין ב-RTL) למראה אותנטי.
///
/// הרכיב משתמש ב-CustomPaint לציור יעיל של הקווים.
///
/// Features:
/// - RepaintBoundary למניעת רינדור חוזר מיותר
/// - ExcludeSemantics - רקע דקורטיבי, לא לקוראי מסך
/// - צבע רקע מ-AppBrand.paperBackground (תומך Dark Mode)
/// - קו אדום RTL-aware (ימין באפליקציה עברית)
///
/// דוגמה:
/// ```dart
/// Scaffold(
///   body: Stack(
///     children: [
///       NotebookBackground(), // רקע מחברת
///       SafeArea(
///         child: YourContent(), // התוכן שלך
///       ),
///     ],
///   ),
/// )
/// ```
class NotebookBackground extends StatelessWidget {
  const NotebookBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<AppBrand>();
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    // ✅ ExcludeSemantics - רקע דקורטיבי, לא רלוונטי לקוראי מסך
    // ✅ RepaintBoundary - מונע רינדור חוזר כשהתוכן מעל משתנה
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: SizedBox.expand(
          child: CustomPaint(
            painter: _NotebookPainter(
              // ✅ צבע רקע מ-AppBrand (תומך Dark Mode)
              paperBackground: brand?.paperBackground ??
                  (theme.brightness == Brightness.dark ? kDarkPaperBackground : kPaperBackground),
              notebookBlue: brand?.notebookBlue ?? kNotebookBlue,
              notebookRed: brand?.notebookRed ?? kNotebookRed,
              isRtl: isRtl,
            ),
          ),
        ),
      ),
    );
  }
}

/// Painter עבור רקע המחברת
///
/// מצייר:
/// 1. רקע נייר (מ-AppBrand.paperBackground)
/// 2. קווים אופקיים כחולים (כמו שורות במחברת)
/// 3. קו אדום אנכי (מימין ב-RTL, משמאל ב-LTR)
class _NotebookPainter extends CustomPainter {
  final Color paperBackground;
  final Color notebookBlue;
  final Color notebookRed;
  final bool isRtl;

  _NotebookPainter({
    required this.paperBackground,
    required this.notebookBlue,
    required this.notebookRed,
    required this.isRtl,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ✅ רקע נייר מ-Theme (כבר מחושב לפי Dark/Light)
    final bgPaint = Paint()..color = paperBackground;

    canvas.drawRect(
      Offset.zero & size,
      bgPaint,
    );

    // קווים כחולים כמו במחברת אמיתית 📘
    final bluePaint = Paint()
      ..color = notebookBlue.withValues(alpha: kNotebookLineOpacity)
      ..strokeWidth = 1.0;

    // קווים אופקיים כמו במחברת
    for (double y = kNotebookLineSpacing;
        y < size.height;
        y += kNotebookLineSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        bluePaint,
      );
    }

    // ✅ קו אדום - RTL-aware (ימין באפליקציה עברית) 📕
    final redLinePaint = Paint()
      ..color = notebookRed.withValues(alpha: kNotebookRedLineOpacity)
      ..strokeWidth = kNotebookRedLineWidth;

    // מיקום הקו: מימין ב-RTL, משמאל ב-LTR
    final redLineX = isRtl
        ? size.width - kNotebookRedLineOffset
        : kNotebookRedLineOffset;

    canvas.drawLine(
      Offset(redLineX, 0),
      Offset(redLineX, size.height),
      redLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _NotebookPainter oldDelegate) {
    return paperBackground != oldDelegate.paperBackground ||
        notebookBlue != oldDelegate.notebookBlue ||
        notebookRed != oldDelegate.notebookRed ||
        isRtl != oldDelegate.isRtl;
  }
}
