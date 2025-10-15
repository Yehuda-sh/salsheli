// 📄 File: lib/widgets/common/tappable_card.dart
//
// 🎯 Purpose: כרטיס אינטראקטיבי עם אפקט לחיצה
//
// 📋 Features:
// - Scale Animation - scale ל-0.98 בלחיצה
// - Elevation Animation - elevation עולה בלחיצה
// - Haptic Feedback - רטט קל
// - Smooth Curves - אנימציה חלקה
// - Zero Performance Impact - רק כשלוחצים
//
// 🔗 Related:
// - welcome_screen.dart - יתרונות (BenefitTile)
// - ui_constants.dart - kAnimationDurationFast (150ms)
//
// 💡 Usage:
// ```dart
// TappableCard(
//   onTap: () => _navigateToDetails(),
//   child: Card(
//     child: ListTile(
//       title: Text('כותרת'),
//       subtitle: Text('תיאור'),
//     ),
//   ),
// )
// ```
//
// 📚 Design Pattern: Micro Animations
// זה חלק מ-Modern UI/UX Patterns (AI_DEV_GUIDELINES v8.0)
//
// Version: 1.0 - Initial (15/10/2025)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/ui_constants.dart';

/// כרטיס אינטראקטיבי עם אנימציית לחיצה
///
/// עוטף Card או כל widget אחר ומוסיף:
/// - Scale effect (0.98)
/// - Elevation animation
/// - Haptic feedback
///
/// **אפקט:** הכרטיס "נלחץ" מעט, נותן תחושה של כפתור
class TappableCard extends StatefulWidget {
  /// התוכן של הכרטיס
  final Widget child;

  /// פונקציה לקריאה כשלוחצים
  final VoidCallback onTap;

  /// האם להפעיל haptic feedback (ברירת מחדל: true)
  final bool enableHaptic;

  /// scale factor בלחיצה (ברירת מחדל: 0.98)
  final double scaleFactor;

  /// elevation התחלתית (ברירת מחדל: 2.0)
  final double initialElevation;

  /// elevation בלחיצה (ברירת מחדל: 4.0)
  final double pressedElevation;

  const TappableCard({
    super.key,
    required this.child,
    required this.onTap,
    this.enableHaptic = true,
    this.scaleFactor = 0.98,
    this.initialElevation = 2.0,
    this.pressedElevation = 4.0,
  });

  @override
  State<TappableCard> createState() => _TappableCardState();
}

class _TappableCardState extends State<TappableCard> {
  double _scale = 1.0;
  double _elevation = 2.0;

  @override
  void initState() {
    super.initState();
    _elevation = widget.initialElevation;
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = widget.scaleFactor;
      _elevation = widget.pressedElevation;
    });
    debugPrint('🃏 TappableCard: onTapDown');
  }

  void _onTapUp(TapUpDetails details) async {
    setState(() {
      _scale = 1.0;
      _elevation = widget.initialElevation;
    });
    debugPrint('🃏 TappableCard: onTapUp');
    
    // רטט קל למשוב מישושי
    if (widget.enableHaptic) {
      await HapticFeedback.lightImpact();
    }
    
    // קריאה ל-onTap
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
      _elevation = widget.initialElevation;
    });
    debugPrint('🃏 TappableCard: onTapCancel');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: kAnimationDurationFast,
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_scale, _scale, _scale),
        child: Material(
          elevation: _elevation,
          borderRadius: BorderRadius.circular(kBorderRadius),
          color: Colors.transparent,
          child: widget.child,
        ),
      ),
    );
  }
}
