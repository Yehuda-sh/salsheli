// 📄 File: lib/widgets/common/notebook_background.dart
// 🎯 Purpose: רקע מחברת עם קווים כחולים וקו אדום
//
// 📋 Features:
// - קווים אופקיים כחולים כמו במחברת אמיתית
// - קו אדום אנכי משמאל
// - שימוש בקבועים מ-ui_constants.dart
// - צבעים מ-AppBrand
// - נגיש וקל לשימוש
//
// 🔗 Related:
// - ui_constants.dart - קבועי גדלים וצבעים
// - app_theme.dart - AppBrand
//
// 🎨 Design:
// - קווים כחולים בהירים (opacity 0.5)
// - קו אדום בולט (opacity 0.4)
// - מרווח 48px בין קווים (kNotebookLineSpacing)
// - קו אדום במרחק 60px משמאל (kNotebookRedLineOffset)
//
// Usage:
// ```dart
// Stack(
//   children: [
//     NotebookBackground(),
//     // תוכן שלך כאן
//   ],
// )
// ```
//
// Version: 1.0 - Sticky Notes Design System (15/10/2025)

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
/// ✅ תיקונים:
///    - צבע רקע מ-AppBrand.paperBackground (תומך Dark Mode)
///    - קו אדום במיקום RTL-aware (ימין באפליקציה עברית)
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

    return SizedBox.expand(
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
    );
  }
}

/// Painter עבור רקע המחברת
///
/// מצייר:
/// 1. קווים אופקיים כחולים (כמו שורות במחברת)
/// 2. קו אדום אנכי (מימין ב-RTL, משמאל ב-LTR)
///
/// ✅ תיקונים:
///    - צבע רקע מ-AppBrand.paperBackground (לא מ-brightness)
///    - קו אדום RTL-aware (ימין באפליקציה עברית)
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
