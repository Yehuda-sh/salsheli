// 📄 lib/widgets/common/animated_button.dart
// Version 1.0
//
// Wrapper שמוסיף אנימציית לחיצה (scale + opacity) + haptic feedback אופציונלי.
// **אפקט בלבד** - לא מפעיל את הפעולה, הכפתור הפנימי מטפל בלחיצה.
//
// Features:
//   - תמיכה בדרגות Haptic מרובות (Patterns): none, light, medium, selection
//   - אופטימיזציית RepaintBoundary למניעת render מיותר
//   - ניהול מצב לחיצה חכם (Press Opacity)
//
// ✅ שימוש:
//    - CTA / כפתורים חשובים: עם haptic: ButtonHaptic.light
//    - כפתורים רגילים / אייקונים: בלי haptic, עם scale עדין יותר
//
// 🔗 Related: FilledButton, ElevatedButton, IconButton

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Haptic feedback intensity for AnimatedButton.
enum ButtonHaptic {
  /// No haptic feedback.
  none,

  /// Light impact - subtle tap (recommended for CTA).
  light,

  /// Medium impact - noticeable tap (confirmation actions).
  medium,

  /// Selection click - crisp tick (toggle/selection actions).
  selection,
}

class AnimatedButton extends StatefulWidget {
  /// Button widget to wrap (FilledButton, ElevatedButton, IconButton, etc.)
  /// The child handles the actual tap - this wrapper only adds visual feedback.
  final Widget child;

  /// Is the button enabled? (affects animation and haptic)
  /// Should match the child button's enabled state.
  final bool enabled;

  /// Scale animation target (default: 0.98 - subtle)
  /// For icon buttons, use 0.99 or 1.0 (disabled).
  final double scaleTarget;

  /// Opacity target when pressed (default: 1.0 - no dimming)
  /// Use 0.85–0.95 for a subtle press-dimming effect.
  final double opacityTarget;

  /// Animation duration (default: 100ms - snappy)
  final Duration duration;

  /// Haptic feedback pattern (default: none - conservative)
  /// Use ButtonHaptic.light for CTA / important actions.
  final ButtonHaptic haptic;

  /// Curve for animation (default: easeOut - natural feel)
  final Curve curve;

  const AnimatedButton({
    super.key,
    required this.child,
    this.enabled = true,
    this.scaleTarget = 0.98,
    this.opacityTarget = 1.0,
    this.duration = const Duration(milliseconds: 100),
    this.haptic = ButtonHaptic.none,
    this.curve = Curves.easeOut,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // 🔧 ConstrainedBox ensures minimum 44x44 hit area (accessibility standard)
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 44,
        minHeight: 44,
      ),
      // 🔧 Listener with deferToChild - only responds on actual child area
      // The child button still receives the tap and handles the action
      child: Listener(
        behavior: HitTestBehavior.deferToChild,
        onPointerDown: _onPointerDown,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        // 🎨 RepaintBoundary isolates scale/opacity repaints from parent tree
        child: RepaintBoundary(
          child: AnimatedScale(
            scale: _isPressed ? widget.scaleTarget : 1.0,
            duration: widget.duration,
            curve: widget.curve,
            child: AnimatedOpacity(
              opacity: _isPressed ? widget.opacityTarget : 1.0,
              duration: widget.duration,
              curve: widget.curve,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    // 🛡️ Disabled = no response at all
    if (!mounted || !widget.enabled) return;

    setState(() => _isPressed = true);

    // ✨ Haptic pattern based on button importance
    switch (widget.haptic) {
      case ButtonHaptic.none:
        break;
      case ButtonHaptic.light:
        unawaited(HapticFeedback.lightImpact());
      case ButtonHaptic.medium:
        unawaited(HapticFeedback.mediumImpact());
      case ButtonHaptic.selection:
        unawaited(HapticFeedback.selectionClick());
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
