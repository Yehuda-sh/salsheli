// 📄 File: lib/widgets/common/animated_button.dart
//
// 🎯 Purpose: כפתור עם אנימציית לחיצה (scale effect)
//
// 📋 Features:
// - Scale Animation - scale ל-0.95 בלחיצה (150ms)
// - Haptic Feedback - רטט קל בלחיצה
// - Touch States - onTapDown, onTapUp, onTapCancel
// - Curve - Curves.easeInOut לאנימציה חלקה
// - Zero Performance Impact - רק כשלוחצים
//
// 🔗 Related:
// - welcome_screen.dart - כפתורי התחברות/הרשמה
// - ui_constants.dart - kAnimationDurationFast (150ms)
//
// 💡 Usage:
// ```dart
// // במקום ElevatedButton רגיל
// AnimatedButton(
//   onPressed: _onSave,
//   child: ElevatedButton(
//     onPressed: null, // ה-AnimatedButton מטפל ב-onPressed
//     child: Text('שמור'),
//   ),
// )
//
// // עם כל סוג כפתור
// AnimatedButton(
//   onPressed: _onDelete,
//   child: OutlinedButton(
//     onPressed: null,
//     child: Text('מחק'),
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

/// כפתור עם אנימציית scale בלחיצה
///
/// עוטף כל סוג כפתור (ElevatedButton, OutlinedButton, TextButton וכו')
/// ומוסיף אנימציית scale ל-0.95 כשלוחצים עליו.
///
/// **אפקט:** הכפתור "נלחץ" מעט פנימה, נותן משוב ויזואלי מיידי למשתמש
///
/// **תכונות:**
/// - 150ms animation (מהיר ומדויק)
/// - Haptic feedback (רטט קל)
/// - Smooth curve (easeInOut)
/// - Works עם כל סוג כפתור
class AnimatedButton extends StatefulWidget {
  /// הכפתור לעטוף (ElevatedButton, OutlinedButton וכו')
  final Widget child;

  /// פונקציה לקריאה כשלוחצים
  final VoidCallback? onPressed;

  /// האם להפעיל haptic feedback (ברירת מחדל: true)
  final bool enableHaptic;

  /// scale factor בלחיצה (ברירת מחדל: 0.95)
  final double scaleFactor;

  const AnimatedButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.enableHaptic = true,
    this.scaleFactor = 0.95,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
      debugPrint('🎯 AnimatedButton: onTapDown');
    }
  }

  void _onTapUp(TapUpDetails details) async {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      debugPrint('🎯 AnimatedButton: onTapUp');
      
      // רטט קל למשוב מישושי
      if (widget.enableHaptic) {
        await HapticFeedback.lightImpact();
      }
      
      // קריאה ל-onPressed
      widget.onPressed!();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      debugPrint('🎯 AnimatedButton: onTapCancel');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleFactor : 1.0,
        duration: kAnimationDurationFast,
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}
