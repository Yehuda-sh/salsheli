// 📄 lib/widgets/common/animated_button.dart
//
// Wrapper שמוסיף אנימציית לחיצה (scale) + haptic feedback אופציונלי.
// **אפקט בלבד** - לא מפעיל את הפעולה, הכפתור הפנימי מטפל בלחיצה.
//
// ✅ שימוש:
//    - CTA / כפתורים חשובים: עם hapticFeedback: true
//    - כפתורים רגילים / אייקונים: בלי haptic, עם scale עדין יותר
//
// 🔗 Related: FilledButton, ElevatedButton, IconButton

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimatedButton extends StatefulWidget {
  /// Button widget to wrap (FilledButton, ElevatedButton, IconButton, etc.)
  /// The child handles the actual tap - this wrapper only adds visual feedback.
  final Widget child;

  /// Is the button enabled? (affects animation and haptic)
  /// Should match the child button's enabled state.
  final bool enabled;

  /// Scale animation target (default: 0.98 - subtle, WhatsApp-like)
  /// For icon buttons, use 0.99 or 1.0 (disabled).
  final double scaleTarget;

  /// Animation duration (default: 100ms - snappy)
  final Duration duration;

  /// Enable haptic feedback (default: false - conservative)
  /// Enable only for CTA / important actions.
  final bool hapticFeedback;

  /// Curve for animation (default: easeOut - natural feel)
  final Curve curve;

  const AnimatedButton({
    super.key,
    required this.child,
    this.enabled = true,
    this.scaleTarget = 0.98,
    this.duration = const Duration(milliseconds: 100),
    this.hapticFeedback = false,
    this.curve = Curves.easeOut,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // 🔧 Listener with deferToChild - only responds on actual child area
    // The child button still receives the tap and handles the action
    return Listener(
      behavior: HitTestBehavior.deferToChild,
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleTarget : 1.0,
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child,
      ),
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    // 🛡️ Disabled = no response at all
    if (!mounted || !widget.enabled) return;

    setState(() => _isPressed = true);

    // ✨ Haptic only when explicitly enabled (CTA buttons)
    if (widget.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!mounted) return;
    setState(() => _isPressed = false);
    // ⚠️ No onPressed call - the child button handles the action
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (!mounted) return;
    setState(() => _isPressed = false);
  }
}
