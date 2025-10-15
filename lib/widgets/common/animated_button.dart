import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🎯 AnimatedButton - Interactive Button with Scale & Haptic Feedback
/// 
/// Wraps any button widget to add:
/// - Scale animation (0.95) on tap
/// - Haptic feedback (haptic.call)
/// - Smooth 150ms animation
/// - Works with all button types
/// 
/// Usage:
/// ```dart
/// AnimatedButton(
///   onPressed: () => print('Pressed!'),
///   child: ElevatedButton(
///     onPressed: null,  // AnimatedButton handles this
///     child: Text('Press Me'),
///   ),
/// )
/// ```

class AnimatedButton extends StatefulWidget {
  /// Callback when button is tapped
  final VoidCallback onPressed;

  /// Button widget to wrap (ElevatedButton, OutlinedButton, TextButton, etc.)
  final Widget child;

  /// Scale animation target (default: 0.95)
  final double scaleTarget;

  /// Animation duration (default: 150ms)
  final Duration duration;

  /// Enable haptic feedback (default: true)
  final bool hapticFeedback;

  /// Curve for animation (default: easeInOut)
  final Curve curve;

  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.scaleTarget = 0.95,
    this.duration = const Duration(milliseconds: 150),
    this.hapticFeedback = true,
    this.curve = Curves.easeInOut,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  /// Track if button is pressed
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleTarget : 1.0,
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child,
      ),
    );
  }

  /// Handle tap down - trigger animation and haptic feedback
  void _onTapDown() {
    if (!mounted) return;
    setState(() => _isPressed = true);
    
    // ✅ Haptic feedback on tap
    if (widget.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  /// Handle tap up - trigger callback
  void _onTapUp() {
    if (!mounted) return;
    setState(() => _isPressed = false);
    widget.onPressed();
  }

  /// Handle tap cancel
  void _onTapCancel() {
    if (!mounted) return;
    setState(() => _isPressed = false);
  }
}
