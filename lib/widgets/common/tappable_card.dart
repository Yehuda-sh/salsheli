import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🎴 TappableCard - Interactive Card with Scale & Elevation Animation
///
/// Wraps a Card or any widget to add:
/// - Scale animation (0.98) on tap
/// - Elevation animation (2 → 4 → 2)
/// - Haptic feedback
/// - Smooth 150ms animation
/// - Perfect for dashboard cards
///
/// Usage:
/// ```dart
/// TappableCard(
///   onTap: () => print('Card tapped!'),
///   child: Card(
///     child: ListTile(
///       title: Text('Interactive Card'),
///     ),
///   ),
/// )
/// ```

class TappableCard extends StatefulWidget {
  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Card widget or any widget to wrap
  final Widget child;

  /// Scale animation target (default: 0.98)
  final double scaleTarget;

  /// Animation duration (default: 150ms)
  final Duration duration;

  /// Enable haptic feedback (default: true)
  final bool hapticFeedback;

  /// Curve for animation (default: easeInOut)
  final Curve curve;

  /// Enable elevation animation (default: true)
  final bool animateElevation;

  /// Initial elevation (default: 2)
  final double initialElevation;

  /// Pressed elevation (default: 4)
  final double pressedElevation;

  /// Enable scale animation (default: true)
  final bool animateScale;

  const TappableCard({
    super.key,
    required this.child,
    this.onTap,
    this.scaleTarget = 0.98,
    this.duration = const Duration(milliseconds: 150),
    this.hapticFeedback = true,
    this.curve = Curves.easeInOut,
    this.animateElevation = true,
    this.initialElevation = 2,
    this.pressedElevation = 4,
    this.animateScale = true,
  });

  @override
  State<TappableCard> createState() => _TappableCardState();
}

class _TappableCardState extends State<TappableCard> {
  /// Track if card is pressed
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _onTapDown() : null,
      onTapUp: widget.onTap != null ? (_) => _onTapUp() : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      child: _buildAnimatedChild(),
    );
  }

  /// Build animated child with scale and elevation
  Widget _buildAnimatedChild() {
    // If child is already a Card, don't wrap in another
    bool isCard = widget.child is Card;

    Widget content = widget.child;

    // Apply elevation animation if enabled and child is Card
    if (widget.animateElevation && isCard) {
      content = AnimatedCard(
        isPressed: _isPressed,
        duration: widget.duration,
        curve: widget.curve,
        initialElevation: widget.initialElevation,
        pressedElevation: widget.pressedElevation,
        child: widget.child,
      );
    }

    // Apply scale animation if enabled
    if (widget.animateScale) {
      content = AnimatedScale(
        scale: _isPressed ? widget.scaleTarget : 1.0,
        duration: widget.duration,
        curve: widget.curve,
        child: content,
      );
    }

    return content;
  }

  /// Handle tap down
  void _onTapDown() {
    if (!mounted) return;
    setState(() => _isPressed = true);

    // Haptic feedback
    if (widget.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  /// Handle tap up - trigger callback
  void _onTapUp() {
    if (!mounted) return;
    setState(() => _isPressed = false);
    widget.onTap?.call();
  }

  /// Handle tap cancel
  void _onTapCancel() {
    if (!mounted) return;
    setState(() => _isPressed = false);
  }
}

/// 🎴 AnimatedCard - Internal widget for elevation animation
///
/// Handles elevation animation for Card widgets specifically.
/// This is used internally by TappableCard.

class AnimatedCard extends StatelessWidget {
  final Widget child;
  final bool isPressed;
  final Duration duration;
  final Curve curve;
  final double initialElevation;
  final double pressedElevation;

  const AnimatedCard({
    super.key,
    required this.child,
    required this.isPressed,
    required this.duration,
    required this.curve,
    required this.initialElevation,
    required this.pressedElevation,
  });

  @override
  Widget build(BuildContext context) {
    // Extract Card properties and rebuild with animated elevation
    if (child is Card) {
      final card = child as Card;

      return AnimatedContainer(
        duration: duration,
        curve: curve,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: isPressed ? 0.1 : 0.08,
              ),
              offset: Offset(0, isPressed ? 2 : 4),
              blurRadius: isPressed ? 4 : 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Card(
          elevation: isPressed ? pressedElevation : initialElevation,
          shape: card.shape,
          color: card.color,
          margin: card.margin,
          semanticContainer: card.semanticContainer,
          clipBehavior: card.clipBehavior,
          child: card.child,
        ),
      );
    }

    // Fallback: just return child as-is if not a Card
    return child;
  }
}

/// 🎴 SimpleTappableCard - Simpler version without elevation animation
///
/// Use this if you want only scale animation without elevation.
///
/// Usage:
/// ```dart
/// SimpleTappableCard(
///   onTap: () => print('Tapped!'),
///   child: Container(...),
/// )
/// ```

class SimpleTappableCard extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  final double scaleTarget;
  final Duration duration;
  final bool hapticFeedback;

  const SimpleTappableCard({
    super.key,
    required this.child,
    this.onTap,
    this.scaleTarget = 0.98,
    this.duration = const Duration(milliseconds: 150),
    this.hapticFeedback = true,
  });

  @override
  State<SimpleTappableCard> createState() => _SimpleTappableCardState();
}

class _SimpleTappableCardState extends State<SimpleTappableCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _onTapDown() : null,
      onTapUp: widget.onTap != null ? (_) => _onTapUp() : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleTarget : 1.0,
        duration: widget.duration,
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }

  void _onTapDown() {
    if (!mounted) return;
    setState(() => _isPressed = true);

    if (widget.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp() {
    if (!mounted) return;
    setState(() => _isPressed = false);
    widget.onTap?.call();
  }

  void _onTapCancel() {
    if (!mounted) return;
    setState(() => _isPressed = false);
  }
}
