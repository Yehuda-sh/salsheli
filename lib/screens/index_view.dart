// lib/screens/index_view.dart — Index view — animated splash/loading screen with logo and rotating messages

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/ui_constants.dart';
import '../l10n/app_strings.dart';
import '../widgets/common/notebook_background.dart';

// ───────────────────────────────────────────────────────────────────────────
// Logo / pulse / loading-indicator dimensions used by IndexLoadingView.
// (Local to this file — they describe specific look-and-feel, not tokens.)
// ───────────────────────────────────────────────────────────────────────────
const double _kLogoSize = kButtonHeight + 24; // 72
const double _kLogoIconSize = kButtonHeight + 8; // 56 — ~78% icon-to-circle ratio
const double _kLogoPulseScale = 1.5;
const double _kLogoPulseAmplitude = 0.2;
const double _kLogoShadowBlur = 20.0;
const Offset _kLogoShadowOffset = Offset(0, 10);
const Duration _kMessageSwitchDuration = Duration(milliseconds: 500);
const double _kMessageBlurMax = 4.0;

// Wave painter configuration
const double _kWaveStepPx = 2.0; // sample step (1px is overkill, 2px is identical visually)
const double _kWaveAmplitudeFront = 20.0;
const double _kWaveAmplitudeBack = 15.0;
const double _kWaveYOffsetFront = 0.5; // fraction of canvas height
const double _kWaveYOffsetBack = 0.7;
const double _kWaveHeight = 150.0;
const double _kTwoPi = 2 * math.pi;

// Decorative tint alpha — intentionally below kOpacitySubtle (0.12) for ambient
// elements (pulse halo, wave fills) that should be barely perceptible.
const double _kDecorativeTintAlpha = 0.08;
const double _kDecorativeTintAlphaHalf = 0.04; // back wave is half-strength

/// 📋 מסך טעינה מונפש
class IndexLoadingView extends StatefulWidget {
  const IndexLoadingView({super.key});

  @override
  State<IndexLoadingView> createState() => _IndexLoadingViewState();
}

class _IndexLoadingViewState extends State<IndexLoadingView>
    with TickerProviderStateMixin {
  // 🎬 Animation Controllers
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _waveController;

  // ⏱️ Timer להחלפת הודעות
  Timer? _messageTimer;

  // ⏱️ Animation Durations
  static const _logoAnimationDuration = Duration(milliseconds: 1200);
  static const _pulseAnimationDuration = Duration(milliseconds: 2000);
  static const _shimmerAnimationDuration = Duration(milliseconds: 2000);
  static const _waveAnimationDuration = Duration(milliseconds: 3000);
  static const _messageRotationDelay = Duration(seconds: 2);

  // 📝 אינדקס הודעת טעינה נוכחית
  int _currentMessageIndex = 0;

  @override
  void initState() {
    super.initState();

    // 🎬 Initialize Animation Controllers
    _logoController = AnimationController(
      vsync: this,
      duration: _logoAnimationDuration,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: _pulseAnimationDuration,
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: _shimmerAnimationDuration,
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: _waveAnimationDuration,
    )..repeat();

    // v4.0: Haptic selectionClick when logo elastic animation completes
    _logoController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        unawaited(HapticFeedback.selectionClick());
      }
    });

    // 🚀 Start animations
    _logoController.forward();

    // 📝 התחל להחליף הודעות
    _startMessageRotation();
  }

  /// מחליף הודעות טעינה (AnimatedSwitcher מטפל באנימציה)
  void _startMessageRotation() {
    final messages = AppStrings.index.loadingMessages;
    if (messages.isEmpty) return; // defensive: avoid % 0 crash if list ever empties
    _messageTimer = Timer.periodic(_messageRotationDelay, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _currentMessageIndex = (_currentMessageIndex + 1) % messages.length;
      });
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _logoController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🎨 Splash background — matches native splash for invisible handoff
          _buildSplashBackground(context),

          // v4.0: 📓 NotebookBackground hint — רקע מחברת עדין מאוד
          const Opacity(
            opacity: 0.05,
            child: NotebookBackground.subtle(),
          ),

          // 🌊 Wave Animation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            // v4.0: RepaintBoundary — בידוד אנימציית גלים מעץ הרינדור
            child: RepaintBoundary(
              child: _buildWaveAnimation(context),
            ),
          ),

          // 📋 תוכן ראשי
          SafeArea(
            child: Center(
              child: _buildLoadingContent(context),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎨 Solid splash-coloured background.
  ///
  /// Matches the native splash (pubspec.yaml flutter_native_splash) so the
  /// native → Flutter handoff is invisible — no flash.
  Widget _buildSplashBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? kSplashBackgroundDark : kSplashBackground;
    return Container(color: bg);
  }

  /// 🌊 Wave Animation
  Widget _buildWaveAnimation(BuildContext context) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        final cs = Theme.of(context).colorScheme;
        return CustomPaint(
          painter: WavePainter(_waveController.value, cs),
          size: Size(MediaQuery.of(context).size.width, _kWaveHeight),
        );
      },
    );
  }

  /// 📋 תוכן טעינה מרכזי
  Widget _buildLoadingContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 💫 Logo עם Pulsing Circle
        // v4.0: RepaintBoundary — בידוד אנימציות לוגו + shimmer
        RepaintBoundary(
          child: _buildAnimatedLogo(),
        ),
        const SizedBox(height: kSpacingXLarge),

        // 📝 שם האפליקציה
        // v4.0: flutter_animate — fadeIn → slideY → shimmer
        _buildAppName(),
        const SizedBox(height: kSpacingSmallPlus),

        // 🔄 Progress indicator
        _buildLoadingIndicator(),
      ],
    );
  }

  /// 💫 Logo מונפש עם Pulsing Circle
  Widget _buildAnimatedLogo() {
    final cs = Theme.of(context).colorScheme;
    final scaleAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    final fadeAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    final pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    return ScaleTransition(
      scale: Tween<double>(begin: 0.0, end: 1.0).animate(scaleAnimation),
      child: FadeTransition(
        opacity: fadeAnimation,
        child: RotationTransition(
          turns: Tween<double>(begin: 0.0, end: 0.1).animate(
            CurvedAnimation(
              parent: _logoController,
              curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 💫 Pulsing Circle (חיצוני) — primary tint, soft on cream
              AnimatedBuilder(
                animation: pulseAnimation,
                builder: (context, child) {
                  final scale = 1.0 + (pulseAnimation.value * _kLogoPulseAmplitude);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: _kLogoSize * _kLogoPulseScale,
                      height: _kLogoSize * _kLogoPulseScale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.primary.withValues(alpha: _kDecorativeTintAlpha),
                      ),
                    ),
                  );
                },
              ),

              // ✨ Shimmer Effect — primary tint sweeping over the cream surface
              AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  return Container(
                    width: _kLogoSize,
                    height: _kLogoSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment(
                            -1 + (_shimmerController.value * 2), -1),
                        end: Alignment(1 + (_shimmerController.value * 2), 1),
                        colors: [
                          cs.primary.withValues(alpha: 0.0),
                          cs.primary.withValues(alpha: kOpacitySubtle),
                          cs.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // 🎯 Logo עצמו
              Semantics(
                label: AppStrings.index.logoLabel,
                child: Container(
                  width: _kLogoSize,
                  height: _kLogoSize,
                  decoration: BoxDecoration(
                    color: cs.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: cs.shadow.withValues(alpha: kOpacityLow),
                        blurRadius: _kLogoShadowBlur,
                        offset: _kLogoShadowOffset,
                      ),
                    ],
                  ),
                  // Real brand logo — keeps continuity with the native
                  // splash (which already shows logo.png). The previous
                  // generic Material icon broke that visual handoff.
                  padding: const EdgeInsets.all(kSpacingTiny),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: _kLogoIconSize,
                    height: _kLogoIconSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📝 שם האפליקציה מונפש
  /// v4.0: flutter_animate — fadeIn → slideY → shimmer (replaces manual SlideTransition)
  Widget _buildAppName() {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      header: true,
      child: Text(
        AppStrings.index.appName,
        style: TextStyle(
          fontFamily: 'Caveat',
          fontSize: kFontSizeDisplay,
          fontWeight: FontWeight.w700,
          color: cs.primary,
          letterSpacing: 0.5,
          height: 1.0,
        ),
      ),
    )
        .animate(delay: 400.ms)
        .fadeIn(duration: 500.ms, curve: Curves.easeIn)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        )
        .then(delay: 1.seconds)
        .shimmer(
          duration: kAnimationDurationSlow,
          color: cs.primary.withValues(alpha: kOpacityLow),
          angle: kShimmerAngle,
        );
  }

  /// 🔄 Loading Indicator עם הודעות מתחלפות
  /// v4.0: Blur transition בהחלפת הודעות
  Widget _buildLoadingIndicator() {
    final cs = Theme.of(context).colorScheme;
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
      child: Semantics(
        label: AppStrings.index.loadingLabel,
        // The cycling messages are theatrical — they rotate every 2s
        // for visual users, but a screen reader doesn't need to
        // re-read them on each swap. excludeSemantics keeps the
        // single loadingLabel announcement and hides the inner Text
        // changes from TalkBack/VoiceOver. Same pattern as
        // auth/widgets/loading_overlay.
        excludeSemantics: true,
        child: Column(
          children: [
            // עיגול טעינה — primary tint readable on cream
            SizedBox(
              width: kIconSizeLarge + kSpacingXTiny,
              height: kIconSizeLarge + kSpacingXTiny,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  cs.primary.withValues(alpha: kOpacityStrong),
                ),
              ),
            ),
            const SizedBox(height: kSpacingMedium),

            // v4.0: הודעת טעינה מתחלפת עם blur transition
            AnimatedSwitcher(
              duration: _kMessageSwitchDuration,
              transitionBuilder: (child, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, animChild) {
                    final blurValue = (1.0 - animation.value) * _kMessageBlurMax;
                    return ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: blurValue,
                        sigmaY: blurValue,
                      ),
                      child: animChild,
                    );
                  },
                  child: FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                );
              },
              child: Text(
                AppStrings.index.loadingMessages[_currentMessageIndex],
                key: ValueKey<int>(_currentMessageIndex),
                style: TextStyle(
                  fontSize: kFontSizeBody,
                  color: cs.onSurface.withValues(alpha: kOpacityStrong),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ❌ מסך שגיאה מעוצב
/// v4.0: Gradient background, glassmorphism card, haptic feedback
class IndexErrorView extends StatefulWidget {
  final VoidCallback onRetry;

  const IndexErrorView({
    required this.onRetry,
    super.key,
  });

  @override
  State<IndexErrorView> createState() => _IndexErrorViewState();
}

class _IndexErrorViewState extends State<IndexErrorView> {
  @override
  void initState() {
    super.initState();
    // v4.0: Haptic vibrate when error appears
    unawaited(HapticFeedback.vibrate());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? kSplashBackgroundDark : kSplashBackground;

    return Scaffold(
      body: Stack(
        children: [
          // Same cream/dark bg as IndexLoadingView — no jarring color jump
          // when load fails and the view swaps in.
          Container(color: bg),

          // Subtle notebook hint, matches loading view.
          const Opacity(
            opacity: 0.05,
            child: NotebookBackground.subtle(),
          ),

          // Content
          SafeArea(
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(kSpacingXLarge),
                  // liveRegion announces title+message to screen readers
                  // when this view replaces the loading view.
                  child: Semantics(
                    liveRegion: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Same logo container as loading — no animations,
                        // calm presence, preserves brand identity.
                        Container(
                          width: _kLogoSize,
                          height: _kLogoSize,
                          decoration: BoxDecoration(
                            color: cs.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: cs.shadow.withValues(alpha: kOpacityLow),
                                blurRadius: _kLogoShadowBlur,
                                offset: _kLogoShadowOffset,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(kSpacingTiny),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: _kLogoIconSize,
                            height: _kLogoIconSize,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: kSpacingXLarge),

                        // App name (same Caveat header as loading)
                        Text(
                          AppStrings.index.appName,
                          style: TextStyle(
                            fontFamily: 'Caveat',
                            fontSize: kFontSizeDisplay,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                            letterSpacing: 0.5,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: kSpacingLarge),

                        // Softer connectivity icon — error_outline with
                        // a red gradient circle felt alarming for what is
                        // usually just a transient sync hiccup.
                        Icon(
                          Icons.cloud_off_outlined,
                          size: kIconSizeXLarge,
                          color: cs.error,
                        ),
                        const SizedBox(height: kSpacingMedium),

                        Text(
                          AppStrings.index.errorTitle,
                          style: TextStyle(
                            fontSize: kFontSizeLarge,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: kSpacingSmall),
                        Text(
                          AppStrings.index.errorMessage,
                          style: TextStyle(
                            fontSize: kFontSizeBody,
                            color: cs.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: kSpacingXLarge),

                        ElevatedButton.icon(
                          onPressed: () {
                            unawaited(HapticFeedback.lightImpact());
                            widget.onRetry();
                          },
                          icon: const Icon(Icons.refresh),
                          label: Text(AppStrings.index.retryButton),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: kSpacingXLarge,
                              vertical: kSpacingMedium,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(kBorderRadiusLarge),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🌊 Custom Painter לגלים
class WavePainter extends CustomPainter {
  final double animationValue;
  final ColorScheme colorScheme;

  WavePainter(this.animationValue, this.colorScheme);

  @override
  void paint(Canvas canvas, Size size) {
    final phase = animationValue * _kTwoPi;
    final widthInv = _kTwoPi / size.width;

    // גל ראשון
    final paint = Paint()
      ..color = colorScheme.primary.withValues(alpha: _kDecorativeTintAlpha)
      ..style = PaintingStyle.fill;

    final yFront = size.height * _kWaveYOffsetFront;
    final path = Path()..moveTo(0, yFront);
    for (double i = 0; i <= size.width; i += _kWaveStepPx) {
      path.lineTo(
        i,
        yFront + math.sin(i * widthInv + phase) * _kWaveAmplitudeFront,
      );
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // גל שני
    final paint2 = Paint()
      ..color = colorScheme.primary.withValues(alpha: _kDecorativeTintAlphaHalf)
      ..style = PaintingStyle.fill;

    final yBack = size.height * _kWaveYOffsetBack;
    final path2 = Path()..moveTo(0, yBack);
    for (double i = 0; i <= size.width; i += _kWaveStepPx) {
      path2.lineTo(
        i,
        yBack + math.sin(i * widthInv + phase + math.pi) * _kWaveAmplitudeBack,
      );
    }
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    // בדיקה על colorScheme כדי להגיב לשינויי Theme
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.colorScheme != colorScheme;
  }
}
