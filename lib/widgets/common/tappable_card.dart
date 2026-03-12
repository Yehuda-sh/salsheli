// 📄 lib/widgets/common/tappable_card.dart
//
// כרטיס אינטראקטיבי עם אנימציות scale + elevation בלחיצה.
// - TappableCard - גרסה מלאה עם כל האפשרויות
// - SimpleTappableCard REMOVED → use TappableCard(animateElevation: false)
//
// Features:
//   - בידוד RepaintBoundary לאנימציות scale/elevation
//   - חתימות Haptic מרובות (Selection vs Medium) באמצעות ButtonHaptic
//   - אנימציית גובה מותאמת (Smooth Elevation)
//   - אופטימיזציית Hit-Test עם splashColor עדין
//
// 🔗 Related: AnimatedButton, dashboard_card.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import 'animated_button.dart' show ButtonHaptic;

// Re-export ButtonHaptic for callers that import tappable_card.dart
export 'animated_button.dart' show ButtonHaptic;

/// 🎴 TappableCard - Interactive Card with Scale & Elevation Animation
///
/// Wraps a Card or any widget to add:
/// - Scale animation (0.98) on tap - "pressed inward" feel
/// - Elevation animation (2 → 0) on tap - consistent with scale
/// - InkWell for ripple effect and accessibility
/// - Haptic feedback (configurable via ButtonHaptic)
/// - Mouse cursor for desktop
/// - Smooth 150ms animation
/// - RepaintBoundary for isolated repaints
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

  /// Callback when card is long-pressed (optional)
  final VoidCallback? onLongPress;

  /// Card widget or any widget to wrap
  final Widget child;

  /// Scale animation target (default: 0.98)
  final double scaleTarget;

  /// Animation duration (default: 150ms)
  final Duration duration;

  /// Haptic feedback pattern (default: selection - crisp tick on tap)
  /// Use ButtonHaptic.none to disable.
  final ButtonHaptic haptic;

  /// Curve for animation (default: easeInOut)
  final Curve curve;

  /// Enable elevation animation (default: true)
  final bool animateElevation;

  /// Initial elevation (default: 2)
  final double initialElevation;

  /// Pressed elevation (default: 0) - goes DOWN to feel "pressed inward"
  final double pressedElevation;

  /// Enable scale animation (default: true)
  final bool animateScale;

  /// Tooltip text for accessibility (optional)
  final String? tooltip;

  /// Semantic label for screen readers (optional)
  final String? semanticLabel;

  /// Show Material ripple effect on tap (default: true)
  final bool showRipple;

  /// Border radius for ripple clipping (default: kBorderRadiusLarge)
  final double borderRadius;

  const TappableCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleTarget = 0.98,
    this.duration = const Duration(milliseconds: 150),
    this.haptic = ButtonHaptic.selection,
    this.curve = Curves.easeInOut,
    this.animateElevation = true,
    this.initialElevation = 2,
    this.pressedElevation = 0, // ✅ Goes DOWN for consistent "pressed" feel
    this.animateScale = true,
    this.tooltip,
    this.semanticLabel,
    this.showRipple = true, // ✅ Enable ripple by default
    this.borderRadius = kBorderRadiusLarge, // ✅ Configurable border radius
  });

  @override
  State<TappableCard> createState() => _TappableCardState();
}

/// Internal state for TappableCard
///
/// Manages:
/// - Pressed state tracking (_isPressed)
/// - InkWell for ripple effect and accessibility
/// - Animation state changes
/// - Haptic feedback triggers (ButtonHaptic)
/// - Mouse cursor for desktop
/// - mounted checks for safety
class _TappableCardState extends State<TappableCard> {
  /// Track if card is pressed
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isClickable = widget.onTap != null;
    final hasLongPress = widget.onLongPress != null;
    final isInteractive = isClickable || hasLongPress;

    // ✅ Build the animated content with RepaintBoundary
    final animatedContent = RepaintBoundary(
      child: _buildAnimatedChild(),
    );

    // ✅ Build the interactive widget with either InkWell (ripple) or GestureDetector
    Widget result;
    if (widget.showRipple && isInteractive) {
      // Use Stack to overlay ripple WITHOUT clipping the content's shadows
      // ✅ Content (with BoxShadow) is NOT clipped
      // ✅ Only the ripple overlay is clipped to rounded corners
      // ✅ InkWell handles ALL events (ripple + action from same source)
      result = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Stack(
          children: [
            // Content layer - NOT clipped (shadows preserved)
            animatedContent,
            // Ripple overlay - clipped to rounded corners, handles all events
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: _onTap,
                    onTapDown: (_) => _onTapDown(),
                    onTapCancel: _onTapCancel,
                    onLongPress: hasLongPress ? _onLongPress : null,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    // ✅ Subtle primary splash for premium feel
                    splashColor: cs.primary.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Fallback to GestureDetector (no ripple)
      result = MouseRegion(
        cursor: isInteractive
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: isInteractive ? _onTap : null,
          onTapDown: isInteractive ? (_) => _onTapDown() : null,
          onTapCancel: isInteractive ? _onTapCancel : null,
          onLongPress: hasLongPress ? _onLongPress : null,
          child: animatedContent,
        ),
      );
    }

    // ✅ Wrap with Semantics for accessibility
    result = Semantics(
      button: isInteractive,
      enabled: isInteractive,
      label: widget.semanticLabel,
      hint: hasLongPress ? AppStrings.layout.longPressHint : null,
      child: result,
    );

    // ✅ Wrap with Tooltip if provided
    if (widget.tooltip != null) {
      result = Tooltip(
        message: widget.tooltip!,
        child: result,
      );
    }

    return result;
  }

  /// Build animated child with scale and elevation
  Widget _buildAnimatedChild() {
    // If child is already a Card, don't wrap in another
    final isCard = widget.child is Card;

    Widget content = widget.child;

    // Apply elevation animation if enabled and child is Card
    if (widget.animateElevation && isCard) {
      content = _AnimatedCard(
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

  /// Handle tap down - haptic based on ButtonHaptic pattern
  void _onTapDown() {
    if (!mounted) return;
    setState(() => _isPressed = true);

    // ✅ Haptic pattern via ButtonHaptic enum
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

  /// Handle tap - trigger callback (fires for touch, keyboard, and assistive tech)
  void _onTap() {
    if (!mounted) return;
    setState(() => _isPressed = false);
    widget.onTap?.call();
  }

  /// Handle tap cancel
  void _onTapCancel() {
    if (!mounted) return;
    setState(() => _isPressed = false);
  }

  /// Handle long press - mediumImpact for secondary action emphasis
  void _onLongPress() {
    if (!mounted) return;
    if (widget.haptic != ButtonHaptic.none) {
      unawaited(HapticFeedback.mediumImpact());
    }
    widget.onLongPress?.call();
  }
}

/// 🎴 _AnimatedCard - Internal widget for elevation animation
///
/// Handles elevation animation for Card widgets specifically.
/// This is used internally by TappableCard.
///
/// ✅ Fixes:
/// - Removed BoxShadow (was duplicating Card's built-in shadow)
/// - Elevation goes DOWN when pressed for "pressed inward" feel
/// - Uses scheme.shadow with withValues(alpha:) for refined shadow
class _AnimatedCard extends StatelessWidget {
  final Widget child;
  final bool isPressed;
  final Duration duration;
  final Curve curve;
  final double initialElevation;
  final double pressedElevation;

  const _AnimatedCard({
    required this.child,
    required this.isPressed,
    required this.duration,
    required this.curve,
    required this.initialElevation,
    required this.pressedElevation,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Extract Card properties and rebuild with animated elevation
    if (child is Card) {
      final card = child as Card;

      // ✅ Use TweenAnimationBuilder for smooth elevation animation
      // No BoxShadow - Card handles its own shadow via elevation
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: initialElevation,
          end: isPressed ? pressedElevation : initialElevation,
        ),
        duration: duration,
        curve: curve,
        builder: (context, elevation, _) {
          return Card(
            elevation: elevation,
            // ✅ Theme-aware shadow with refined alpha
            shadowColor: scheme.shadow.withValues(alpha: 0.3),
            shape: card.shape,
            color: card.color,
            margin: card.margin,
            semanticContainer: card.semanticContainer,
            clipBehavior: card.clipBehavior,
            child: card.child,
          );
        },
      );
    }

    // Fallback: just return child as-is if not a Card
    return child;
  }
}
// ✅ SimpleTappableCard REMOVED — use TappableCard(animateElevation: false) instead
