// lib/widgets/common/animated_button.dart — Animated button — scale-down press effect (0.97-0.98) for CTA buttons

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
  // Press state lives in a ValueNotifier rather than setState so a tap
  // doesn't rebuild this whole subtree. Only the AnimatedScale (and
  // optionally AnimatedOpacity) under ValueListenableBuilder rebuild
  // when the value changes — the child button stays put.
  final ValueNotifier<bool> _isPressed = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isPressed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ConstrainedBox enforces a 44x44 minimum *layout* size — it keeps
    // the button from shrinking smaller than the Material recommended
    // tap target. The actual tap handling lives in the child widget
    // (FilledButton, IconButton, etc.); this wrapper only adds visuals.
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 44,
        minHeight: 44,
      ),
      // Listener uses HitTestBehavior.deferToChild (its default), so
      // press detection follows the child's hit-test rules — a small
      // child won't get presses for the full 44x44 layout box.
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        // RepaintBoundary isolates scale/opacity repaints from the
        // surrounding tree.
        child: RepaintBoundary(
          child: ValueListenableBuilder<bool>(
            valueListenable: _isPressed,
            // Pass the static child once so ValueListenableBuilder can
            // skip rebuilding it when the press flag flips.
            child: widget.child,
            builder: (context, isPressed, staticChild) {
              // AnimatedOpacity is only inserted when the caller asked
              // for opacity dimming (opacityTarget != 1.0). With the
              // default 1.0 it would tween from 1.0→1.0 every frame —
              // a no-op layer that still costs.
              Widget animated = staticChild!;
              if (widget.opacityTarget != 1.0) {
                animated = AnimatedOpacity(
                  opacity: isPressed ? widget.opacityTarget : 1.0,
                  duration: widget.duration,
                  curve: widget.curve,
                  child: animated,
                );
              }
              return AnimatedScale(
                scale: isPressed ? widget.scaleTarget : 1.0,
                duration: widget.duration,
                curve: widget.curve,
                child: animated,
              );
            },
          ),
        ),
      ),
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    // 🛡️ Disabled = no response at all
    if (!mounted || !widget.enabled) return;

    _isPressed.value = true;

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
    _isPressed.value = false;
    // ⚠️ No onPressed call - the child button handles the action
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (!mounted) return;
    _isPressed.value = false;
  }
}
