// 📄 lib/screens/index_view.dart
//
// מרכיבים חזותיים למסך הפתיחה - IndexLoadingView, IndexErrorView.
// כולל אנימציות logo, גלים, gradient, והודעות טעינה מתחלפות.
//
// 🔗 Related: index_screen, ui_constants, AppStrings.index

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/ui_constants.dart';
import '../l10n/app_strings.dart';

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

          // 🌊 Wave Animation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildWaveAnimation(context),
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
  Widget _buildGradientBackground(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: _gradientAnimationDuration,
      curve: Curves.easeOut,
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
                Color.lerp(Colors.grey, startColor, value)!,
                Color.lerp(Colors.grey, middleColor, value)!,
                Color.lerp(Colors.grey, endColor, value)!,
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
        _buildAnimatedLogo(cs),
        const SizedBox(height: kSpacingXLarge),

        // 📝 שם האפליקציה
        _buildAppName(cs),
        const SizedBox(height: kSpacingSmallPlus),

        // 🔄 Progress indicator
        _buildLoadingIndicator(cs),
      ],
    );
  }

  /// 💫 Logo מונפש עם Pulsing Circle
  Widget _buildAnimatedLogo(ColorScheme cs) {
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
  Widget _buildAppName(ColorScheme cs) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
        ),
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
        ),
        child: Semantics(
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
        ),
      ),
    );
  }

  /// 🔄 Loading Indicator עם הודעות מתחלפות
  Widget _buildLoadingIndicator(ColorScheme cs) {
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

            // הודעת טעינה מתחלפת
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
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
class IndexErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const IndexErrorView({
    required this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
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
            child: Container(
              margin: const EdgeInsets.all(kSpacingXLarge),
              padding: const EdgeInsets.all(kSpacingXLarge),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(kBorderRadiusLarge),
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
                  const SizedBox(height: kSpacingLarge),

                  // טקסט
                  Text(
                    AppStrings.index.errorTitle,
                    style: TextStyle(
                      fontSize: kFontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
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

                  // כפתור retry
                  Semantics(
                    button: true,
                    label: AppStrings.index.retryLabel,
                    hint: AppStrings.index.retryHint,
                    child: ElevatedButton.icon(
                      onPressed: onRetry,
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
                  ),
                ],
              ),
            ),
          ),
        ),
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
    // 🔧 FIX: בדיקה גם על colorScheme - להגיב לשינויי Theme
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.colorScheme != colorScheme;
  }
}
