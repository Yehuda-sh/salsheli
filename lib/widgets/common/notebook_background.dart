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
// - מרווח 40px בין קווים
// - קו אדום במרחק 60px משמאל
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
/// כולל קו אדום משמאל למראה אותנטי.
/// 
/// הרכיב משתמש ב-CustomPaint לציור יעיל של הקווים.
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
    debugPrint('📄 NotebookBackground.build()');
    return SizedBox.expand(
      child: CustomPaint(
        painter: _NotebookPainter(context),
      ),
    );
  }
}

/// Painter עבור רקע המחברת
/// 
/// מצייר:
/// 1. קווים אופקיים כחולים (כמו שורות במחברת)
/// 2. קו אדום אנכי משמאל (כמו במחברת בית ספר)
/// 
/// הצבעים לקוחים מ-AppBrand כדי לתמוך ב-theming.
class _NotebookPainter extends CustomPainter {
  final BuildContext context;

  _NotebookPainter(this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final brand = Theme.of(context).extension<AppBrand>();

    // קווים כחולים כמו במחברת אמיתית 📘
    final bluePaint = Paint()
      ..color = (brand?.notebookBlue ?? kNotebookBlue)
          .withValues(alpha: kNotebookLineOpacity)
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

    // קו אדום משמאל (כמו במחברת אמיתית) 📕
    final redLinePaint = Paint()
      ..color = (brand?.notebookRed ?? kNotebookRed)
          .withValues(alpha: kNotebookRedLineOpacity)
      ..strokeWidth = kNotebookRedLineWidth;

    canvas.drawLine(
      const Offset(kNotebookRedLineOffset, 0),
      Offset(kNotebookRedLineOffset, size.height),
      redLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
