// 📄 lib/widgets/common/tappable_card.dart
//
// כרטיס אינטראקטיבי עם אנימציות scale + elevation בלחיצה.
// - TappableCard - גרסה מלאה עם כל האפשרויות
// - SimpleTappableCard - גרסה פשוטה (רק scale)
//
// ✅ תיקונים:
//    - הסרת כפילות צללים (רק elevation, ללא BoxShadow)
//    - תחושת לחיצה עקבית: scale ↓ + elevation ↓ (נלחץ פנימה)
//    - InkWell במקום GestureDetector לנגישות טובה יותר
//    - צבע צל מ-Theme (scheme.shadow) במקום Colors.black
//    - MouseRegion עם cursor לדסקטופ
//    - curve כפרמטר ב-SimpleTappableCard
//    - הוספת onLongPress parameter
//    - הוספת tooltip parameter לנגישות
//    - הוספת semanticLabel parameter לקוראי מסך
//    - הוספת Focus widget לניווט מקלדת
//
// 🔗 Related: AnimatedButton, dashboard_card.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';

/// 🎴 TappableCard - Interactive Card with Scale & Elevation Animation
///
/// Wraps a Card or any widget to add:
/// - Scale animation (0.98) on tap - "pressed inward" feel
/// - Elevation animation (2 → 0) on tap - consistent with scale
/// - InkWell for ripple effect and accessibility
/// - Haptic feedback
/// - Mouse cursor for desktop
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

  /// Callback when card is long-pressed (optional)
  final VoidCallback? onLongPress;

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
    this.hapticFeedback = true,
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
/// - Haptic feedback triggers
/// - Mouse cursor for desktop
/// - mounted checks for safety
class _TappableCardState extends State<TappableCard> {
  /// Track if card is pressed
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isClickable = widget.onTap != null;
    final hasLongPress = widget.onLongPress != null;

    // ✅ Build the animated content
    final animatedContent = _buildAnimatedChild();

    // ✅ Build the interactive widget with either InkWell (ripple) or GestureDetector
    Widget result;
    if (widget.showRipple && isClickable) {
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
                    onTapDown: (_) => _onTapDown(),
                    onTapUp: (_) => _onTapUp(),
                    onTapCancel: _onTapCancel,
                    onLongPress: hasLongPress ? _onLongPress : null,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
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
        cursor: isClickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTapDown: isClickable ? (_) => _onTapDown() : null,
          onTapUp: isClickable ? (_) => _onTapUp() : null,
          onTapCancel: isClickable ? _onTapCancel : null,
          onLongPress: hasLongPress ? _onLongPress : null,
          child: animatedContent,
        ),
      );
    }

    // ✅ Wrap with Focus for keyboard navigation
    if (isClickable) {
      result = Focus(
        canRequestFocus: true,
        child: result,
      );
    }

    // ✅ Wrap with Semantics for accessibility
    result = Semantics(
      button: isClickable,
      enabled: isClickable,
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

  /// Handle tap down
  void _onTapDown() {
    if (!mounted) return;
    setState(() => _isPressed = true);

    // Haptic feedback
    if (widget.hapticFeedback) {
      unawaited(HapticFeedback.lightImpact());
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

  /// Handle long press
  void _onLongPress() {
    if (!mounted) return;
    if (widget.hapticFeedback) {
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
/// - Uses scheme.shadow instead of hardcoded Colors.black

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
            shadowColor: scheme.shadow, // ✅ Theme-aware shadow color
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

/// 🎴 SimpleTappableCard - Simpler version without elevation animation
///
/// Use this if you want only scale animation without elevation.
/// Includes mouse cursor for desktop and accessibility support.
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
  final VoidCallback? onLongPress;
  final Widget child;
  final double scaleTarget;
  final Duration duration;
  final bool hapticFeedback;

  /// ✅ Added curve parameter for consistency with TappableCard
  final Curve curve;

  /// Tooltip text for accessibility (optional)
  final String? tooltip;

  /// Semantic label for screen readers (optional)
  final String? semanticLabel;

  /// Show Material ripple effect on tap (default: true)
  final bool showRipple;

  /// Border radius for ripple effect (default: 12)
  final double borderRadius;

  const SimpleTappableCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleTarget = 0.98,
    this.duration = const Duration(milliseconds: 150),
    this.hapticFeedback = true,
    this.curve = Curves.easeInOut,
    this.tooltip,
    this.semanticLabel,
    this.showRipple = true, // ✅ Enable ripple by default
    this.borderRadius = kBorderRadius, // ✅ Use ui_constants
  });

  @override
  State<SimpleTappableCard> createState() => _SimpleTappableCardState();
}

/// Internal state for SimpleTappableCard
///
/// Manages:
/// - Pressed state tracking (_isPressed)
/// - Scale animation only (no elevation)
/// - Mouse cursor for desktop
/// - Haptic feedback triggers
/// - mounted checks for safety
class _SimpleTappableCardState extends State<SimpleTappableCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isClickable = widget.onTap != null;
    final hasLongPress = widget.onLongPress != null;

    // ✅ Build the animated content
    final animatedContent = AnimatedScale(
      scale: _isPressed ? widget.scaleTarget : 1.0,
      duration: widget.duration,
      curve: widget.curve,
      child: widget.child,
    );

    // ✅ Build the interactive widget with either InkWell (ripple) or GestureDetector
    Widget result;
    if (widget.showRipple && isClickable) {
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
                    onTapDown: (_) => _onTapDown(),
                    onTapUp: (_) => _onTapUp(),
                    onTapCancel: _onTapCancel,
                    onLongPress: hasLongPress ? _onLongPress : null,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
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
        cursor: isClickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTapDown: isClickable ? (_) => _onTapDown() : null,
          onTapUp: isClickable ? (_) => _onTapUp() : null,
          onTapCancel: isClickable ? _onTapCancel : null,
          onLongPress: hasLongPress ? _onLongPress : null,
          child: animatedContent,
        ),
      );
    }

    // ✅ Wrap with Focus for keyboard navigation
    if (isClickable) {
      result = Focus(
        canRequestFocus: true,
        child: result,
      );
    }

    // ✅ Wrap with Semantics for accessibility
    result = Semantics(
      button: isClickable,
      enabled: isClickable,
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

  void _onTapDown() {
    if (!mounted) return;
    setState(() => _isPressed = true);

    if (widget.hapticFeedback) {
      unawaited(HapticFeedback.lightImpact());
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

  void _onLongPress() {
    if (!mounted) return;
    if (widget.hapticFeedback) {
      unawaited(HapticFeedback.mediumImpact());
    }
    widget.onLongPress?.call();
  }
}
