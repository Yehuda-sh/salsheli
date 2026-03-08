// 📄 lib/screens/index_view.dart
//
// Version: 4.0 (22/02/2026)
//
// 🇮🇱 **מרכיבים חזותיים למסך הפתיחה** — IndexLoadingView, IndexErrorView.
//
// ✨ Features:
//     - NotebookBackground hint (opacity ~0.05) — רקע מחברת עדין
//     - RepaintBoundary — בידוד אנימציות גלים ולוגו
//     - flutter_animate — fadeIn → slideY → shimmer לשם האפליקציה
//     - Blur transition — אפקט טשטוש בהחלפת הודעות
//     - Haptic Feedback — vibrate on error, lightImpact on retry, selectionClick on logo
//     - Glassmorphism — כרטיס שגיאה עם BackdropFilter
//     - Gradient curve: easeInOutCubic (נשימה עדינה)
//
// 📅 History:
//     v4.0 (22/02/2026) — NotebookBackground hint, RepaintBoundary, flutter_animate,
//                          blur messages, haptic feedback, glassmorphism error card
//     v3.0              — Splash gradient, wave animation, message rotation
//
// 🔗 Related: index_screen, ui_constants, AppStrings.index, notebook_background

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/ui_constants.dart';
import '../l10n/app_strings.dart';
import '../widgets/common/notebook_background.dart';

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
  static const _gradientAnimationDuration = Duration(milliseconds: 1500);

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
          // 🎨 Gradient Background
          _buildGradientBackground(context),

          // v4.0: 📓 NotebookBackground hint — רקע מחברת עדין מאוד
          const Opacity(
            opacity: 0.05,
            child: NotebookBackground(
              lineOpacity: 0.10,
              lineColor: kNotebookBlueSoft,
              showRedLine: false,
              fadeEdges: true,
            ),
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

  /// 🎨 Gradient Background - Dark Mode Responsive
  /// v4.0: Curves.easeInOutCubic for smoother "breathing" gradient
  Widget _buildGradientBackground(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: _gradientAnimationDuration,
      curve: Curves.easeInOutCubic,
      builder: (context, value, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final startColor =
            isDark ? kSplashGradientStartDark : kSplashGradientStart;
        final middleColor =
            isDark ? kSplashGradientMiddleDark : kSplashGradientMiddle;
        final endColor = isDark ? kSplashGradientEndDark : kSplashGradientEnd;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(cs.outline, startColor, value)!,
                Color.lerp(cs.outline, middleColor, value)!,
                Color.lerp(cs.outline, endColor, value)!,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  /// 🌊 Wave Animation
  Widget _buildWaveAnimation(BuildContext context) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        final cs = Theme.of(context).colorScheme;
        return CustomPaint(
          painter: WavePainter(_waveController.value, cs),
          size: Size(MediaQuery.of(context).size.width, 150),
        );
      },
    );
  }

  /// 📋 תוכן טעינה מרכזי
  Widget _buildLoadingContent(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 💫 Logo עם Pulsing Circle
        // v4.0: RepaintBoundary — בידוד אנימציות לוגו + shimmer
        RepaintBoundary(
          child: _buildAnimatedLogo(cs),
        ),
        const SizedBox(height: kSpacingXLarge),

        // 📝 שם האפליקציה
        // v4.0: flutter_animate — fadeIn → slideY → shimmer
        _buildAppName(cs),
        const SizedBox(height: kSpacingSmallPlus),

        // 🔄 Progress indicator
        _buildLoadingIndicator(cs),
      ],
    );
  }

  /// 💫 Logo מונפש עם Pulsing Circle
  Widget _buildAnimatedLogo(ColorScheme cs) {
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
              // 💫 Pulsing Circle (חיצוני)
              AnimatedBuilder(
                animation: pulseAnimation,
                builder: (context, child) {
                  final scale = 1.0 + (pulseAnimation.value * 0.2);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: (kButtonHeight + 24) * 1.5,
                      height: (kButtonHeight + 24) * 1.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.onPrimary.withValues(alpha: 0.1),
                      ),
                    ),
                  );
                },
              ),

              // ✨ Shimmer Effect
              AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  return Container(
                    width: kButtonHeight + 24,
                    height: kButtonHeight + 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment(
                            -1 + (_shimmerController.value * 2), -1),
                        end: Alignment(1 + (_shimmerController.value * 2), 1),
                        colors: [
                          cs.onPrimary.withValues(alpha: 0.0),
                          cs.onPrimary.withValues(alpha: 0.3),
                          cs.onPrimary.withValues(alpha: 0.0),
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
                  width: kButtonHeight + 24,
                  height: kButtonHeight + 24,
                  decoration: BoxDecoration(
                    color: cs.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: cs.shadow.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.shopping_basket_outlined,
                    size: kButtonHeight - 12,
                    color: cs.primary,
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
  Widget _buildAppName(ColorScheme cs) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      header: true,
      child: Text(
        AppStrings.index.appName,
        style: TextStyle(
          fontSize: kFontSizeXLarge,
          fontWeight: FontWeight.bold,
          color: cs.onPrimary,
          shadows: [
            Shadow(
              color: cs.shadow.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
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
          color: cs.onPrimary.withValues(alpha: kOpacityLow),
          angle: kShimmerAngle,
        );
  }

  /// 🔄 Loading Indicator עם הודעות מתחלפות
  /// v4.0: Blur transition בהחלפת הודעות
  Widget _buildLoadingIndicator(ColorScheme cs) {
    final cs = Theme.of(context).colorScheme;
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
      child: Semantics(
        label: AppStrings.index.loadingLabel,
        child: Column(
          children: [
            // עיגול טעינה
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  cs.onPrimary.withValues(alpha: 0.9),
                ),
              ),
            ),
            const SizedBox(height: kSpacingMedium),

            // v4.0: הודעת טעינה מתחלפת עם blur transition
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, animChild) {
                    final blurValue = (1.0 - animation.value) * 4;
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
                  color: cs.onPrimary.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      color: cs.shadow.withValues(alpha: 0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
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

    return Scaffold(
      body: Stack(
        children: [
          // v4.0: Gradient background (same as loading screen)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDark ? kSplashGradientStartDark : kSplashGradientStart,
                  isDark ? kSplashGradientMiddleDark : kSplashGradientMiddle,
                  isDark ? kSplashGradientEndDark : kSplashGradientEnd,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
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
                // v4.0: Glassmorphism error card
                child: Padding(
                  padding: const EdgeInsets.all(kSpacingXLarge),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: kGlassBlurLow,
                        sigmaY: kGlassBlurLow,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(kSpacingXLarge),
                        decoration: BoxDecoration(
                          color: cs.surface.withValues(alpha: 0.85),
                          borderRadius:
                              BorderRadius.circular(kBorderRadiusLarge),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: cs.shadow.withValues(alpha: 0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // אייקון שגיאה
                            Container(
                              padding: const EdgeInsets.all(kSpacingLarge),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    cs.error.withValues(alpha: 0.7),
                                    cs.error,
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.error_outline,
                                size: kIconSizeXXLarge,
                                color: cs.onError,
                              ),
                            ),
                            SizedBox(height: kSpacingLarge),

                            // טקסט
                            Text(
                              AppStrings.index.errorTitle,
                              style: TextStyle(
                                fontSize: kFontSizeLarge,
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                            SizedBox(height: kSpacingSmall),
                            Text(
                              AppStrings.index.errorMessage,
                              style: TextStyle(
                                fontSize: kFontSizeBody,
                                color: cs.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: kSpacingXLarge),

                            // v4.0: כפתור retry עם haptic lightImpact
                            ElevatedButton.icon(
                              onPressed: () {
                                unawaited(HapticFeedback.lightImpact());
                                widget.onRetry();
                              },
                              icon: Icon(Icons.refresh),
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
    // גל ראשון
    final paint = Paint()
      ..color = colorScheme.onPrimary.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.5);

    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.5 +
            math.sin((i / size.width * 2 * math.pi) +
                    (animationValue * 2 * math.pi)) *
                20,
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // גל שני
    final paint2 = Paint()
      ..color = colorScheme.onPrimary.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.7);

    for (double i = 0; i <= size.width; i++) {
      path2.lineTo(
        i,
        size.height * 0.7 +
            math.sin((i / size.width * 2 * math.pi) +
                    (animationValue * 2 * math.pi) +
                    math.pi) *
                15,
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
