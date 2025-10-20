// 📄 File: lib/screens/index_screen.dart - V4.0 THEME-RESPONSIVE
// 🎯 Purpose: מסך פתיחה ראשוני - Splash screen שבודק מצב משתמש ומנווט למסך המתאים
//
// ✨ שיפורים חדשים (v4.0):
// 1. 🎨 Dark Mode Support - gradient responsive לתצורת theme
// 2. 🌈 Gradient Colors מקבועים - kSplashGradient*
// 3. 🎨 ColorScheme Integration - כל הצבעים מה-theme
// 4. 💫 Enhanced Wave Animation - מקבל ColorScheme
//
// ✨ שיפורים קודמים (v3.0):
// 1. 🎨 Gradient Background מהמם - כחול-סגול-ורוד
// 2. 🎬 Logo Animation - fade in + scale + rotate
// 3. 💫 Pulsing Circle - העיגול פועם
// 4. ✨ Shimmer Effect - גלי אור על הלוגו
// 5. 📝 Animated Loading Messages - הודעות שמתחלפות
// 6. 🌊 Wave Animation - גלים בתחתית
// 7. ❌ Error State מעוצב - עם retry
// 8. 🎯 Staggered Animations - הכל בסדר
//
// 📋 Flow Logic (עודכן 09/10/2025):
// 1. משתמש מחובר (UserContext.isLoggedIn)? → /home (ישר לאפליקציה)
// 2. לא מחובר + לא ראה onboarding? → WelcomeScreen (הצגת יתרונות)
// 3. לא מחובר + ראה onboarding? → /login (התחברות)
//
// 🔗 Related:
// - UserContext - מקור האמת היחיד למצב משתמש (Firebase Auth)
// - WelcomeScreen - מסך קבלת פנים ראשוני
// - LoginScreen - מסך התחברות (/login)
// - HomeScreen - מסך ראשי (/home)
// - SharedPreferences - אחסון seenOnboarding (מקומי בלבד)
//
// 💡 Features:
// - Single Source of Truth - UserContext בלבד (לא SharedPreferences.userId!)
// - Real-time sync - מגיב לשינויים ב-Firebase Auth אוטומטית
// - Wait for initial load - ממתין עד ש-Firebase מסיים לטעון
// - Error handling עם fallback
// - Modern Splash Screen עם אנימציות מדהימות
// - Accessibility labels
// - Logging מפורט
// - Dark Mode Support - כל הצבעים responsive
//
// ⚠️ Critical Changes (20/10/2025 - v4):
// - 🎨 Dark Mode: gradient colors מתאימים ל-theme
// - 🌈 קבועים: kSplashGradient* במקום hardcoded
// - 🎨 ColorScheme: cs.onPrimary, cs.surface, cs.error וכו'
// - 💫 Wave Painter: מקבל ColorScheme parameter
//
// ⚠️ Critical Changes (14/10/2025 - v3):
// - ⏱️ Fixed Race Condition: 600ms delay before navigation check (allows Firebase Auth to load)
// - ✨ Gradient background מדהים
// - ✨ Logo animations (fade, scale, rotate)
// - ✨ Pulsing circle effect
// - ✨ Shimmer waves על הלוגו
// - ✨ הודעות טעינה מתחלפות
// - ✨ Wave animation בתחתית
// - ✨ Error state מעוצב עם retry

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/ui_constants.dart';
import '../l10n/app_strings.dart';
import '../providers/user_context.dart';
import 'welcome_screen.dart';

// 🔧 Wrapper ללוגים - פועל רק ב-debug mode
void _log(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen>
    with TickerProviderStateMixin {
  bool _hasNavigated = false; // מונע navigation כפול
  bool _hasError = false; // מצב שגיאה

  // 🎬 Animation Controllers
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _textController;
  late AnimationController _waveController;

  // ⏱️ Animation Durations (constants for better maintainability)
  static const _logoAnimationDuration = Duration(milliseconds: 1200);
  static const _pulseAnimationDuration = Duration(milliseconds: 2000);
  static const _shimmerAnimationDuration = Duration(milliseconds: 2000);
  static const _textAnimationDuration = Duration(milliseconds: 1000);
  static const _waveAnimationDuration = Duration(milliseconds: 3000);
  static const _messageRotationDelay = Duration(seconds: 2);
  static const _gradientAnimationDuration = Duration(milliseconds: 1500);
  static const _errorAnimationDuration = Duration(milliseconds: 800);
  static const _switcherAnimationDuration = Duration(milliseconds: 500);

  // 📝 הודעות טעינה
  final List<String> _loadingMessages = [
    'בודק מצב...',
    'מתחבר...',
    'כמעט מוכן...',
  ];
  int _currentMessageIndex = 0;

  @override
  void initState() {
    super.initState();
    _log('🚀 IndexScreen.initState() - מתחיל Splash Screen מודרני');

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

    _textController = AnimationController(
      vsync: this,
      duration: _textAnimationDuration,
    );

    _waveController = AnimationController(
      vsync: this,
      duration: _waveAnimationDuration,
    )..repeat();

    // 🚀 Start animations
    _logoController.forward();
    _textController.forward();

    // 📝 התחל להחליף הודעות
    _startMessageRotation();

    // ⚡ טעינה אסינכרונית משופרת - עם delay ל-Firebase Auth
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ⏱️ המתנה של 600ms כדי לתת ל-Firebase Auth זמן להחזיר את המשתמש
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          _setupListener();
        }
      });
    });
  }

  /// מחליף הודעות טעינה
  void _startMessageRotation() {
    Future.delayed(_messageRotationDelay, () {
      if (!mounted || _hasNavigated) return;

      setState(() {
        _currentMessageIndex = (_currentMessageIndex + 1) % _loadingMessages.length;
      });

      _textController.reset();
      _textController.forward();

      _startMessageRotation(); // המשך rotation
    });
  }

  /// מגדיר listener ל-UserContext שיגיב לשינויים
  void _setupListener() {
    final userContext = Provider.of<UserContext>(context, listen: false);

    // ✅ האזן לשינויים ב-UserContext
    userContext.addListener(_onUserContextChanged);

    // ✅ בדוק מיידית אם כבר נטען
    _checkAndNavigate();
  }

  /// מופעל כל פעם ש-UserContext משתנה
  void _onUserContextChanged() {
    _log('👂 IndexScreen: UserContext השתנה');
    if (!_hasNavigated && mounted) {
      _checkAndNavigate();
    }
  }

  Future<void> _checkAndNavigate() async {
    if (_hasNavigated) return; // כבר ניווטנו

    _log('\n🏗️ IndexScreen._checkAndNavigate() - מתחיל...');

    try {
      // ✅ מקור אמת יחיד - UserContext!
      final userContext = Provider.of<UserContext>(context, listen: false);

      _log('   📊 UserContext state:');
      _log('      isLoggedIn: ${userContext.isLoggedIn}');
      _log('      user: ${userContext.user?.email ?? "null"}');
      _log('      isLoading: ${userContext.isLoading}');

      // ⏳ אם UserContext עדיין טוען, נחכה
      if (userContext.isLoading) {
        _log('   ⏳ UserContext טוען, ממתין לסיום...');
        return; // ה-listener יקרא לנו שוב כש-isLoading ישתנה
      }

      // ✅ מצב 1: משתמש מחובר → ישר לדף הבית
      if (userContext.isLoggedIn) {
        _log(
            '   ✅ משתמש מחובר (${userContext.userEmail}) → ניווט ל-/home');
        _hasNavigated = true;
        if (mounted) {
          // הסר את ה-listener לפני ניווט
          userContext.removeListener(_onUserContextChanged);
          Navigator.of(context).pushReplacementNamed('/home');
        }
        return;
      }

      // ✅ מצב 2-3: לא מחובר → בודק אם ראה welcome
      // (seenOnboarding נשאר מקומי - לא צריך sync בין מכשירים)
      final prefs = await SharedPreferences.getInstance();
      final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
      _log('   📋 seenOnboarding (local): $seenOnboarding');

      if (!seenOnboarding) {
        // ✅ מצב 2: לא ראה welcome → שולח לשם
        _log('   ➡️ לא ראה onboarding → ניווט ל-WelcomeScreen');
        _hasNavigated = true;
        if (mounted) {
          userContext.removeListener(_onUserContextChanged);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          );
        }
        return;
      }

      // ✅ מצב 3: ראה welcome אבל לא מחובר → שולח ל-login
      _log('   ➡️ ראה onboarding אבל לא מחובר → ניווט ל-/login');
      _hasNavigated = true;
      if (mounted) {
        userContext.removeListener(_onUserContextChanged);
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      // ✅ במקרה של שגיאה - הצג מסך שגיאה
      _log('❌ שגיאה ב-IndexScreen._checkAndNavigate: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  /// retry לאחר שגיאה
  void _retry() {
    _log('🔄 IndexScreen: retry לאחר שגיאה');
    setState(() {
      _hasError = false;
      _hasNavigated = false;
    });
    _checkAndNavigate();
  }

  @override
  void dispose() {
    _log('🗑️ IndexScreen.dispose()');
    // ✅ ניקוי listener
    try {
      final userContext = Provider.of<UserContext>(context, listen: false);
      userContext.removeListener(_onUserContextChanged);
    } catch (e) {
      // אם כבר נמחק, לא נורא
    }

    // ✅ ניקוי animation controllers
    _logoController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _textController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // 🎨 Gradient Background מהמם
          _buildGradientBackground(),

          // 🌊 Wave Animation בתחתית
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildWaveAnimation(),
          ),

          // 📋 תוכן ראשי
          SafeArea(
            child: Center(
              child: _hasError ? _buildErrorState(cs) : _buildLoadingState(cs),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎨 Gradient Background - Dark Mode Responsive
  Widget _buildGradientBackground() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: _gradientAnimationDuration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        // 🌙 תמיכה ב-Dark Mode
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final startColor = isDark ? kSplashGradientStartDark : kSplashGradientStart;
        final middleColor = isDark ? kSplashGradientMiddleDark : kSplashGradientMiddle;
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

  /// 🌊 Wave Animation - Theme-Aware
  Widget _buildWaveAnimation() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        final cs = Theme.of(context).colorScheme;
        return CustomPaint(
          painter: _WavePainter(_waveController.value, cs),
          size: Size(MediaQuery.of(context).size.width, 150),
        );
      },
    );
  }

  /// 📋 מצב טעינה
  Widget _buildLoadingState(ColorScheme cs) {
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

  /// 💫 Logo מונפש עם Pulsing Circle - Theme-Aware
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
              // 💫 Pulsing Circle (חיצוני) - Theme-Aware
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

              // ✨ Shimmer Effect - Theme-Aware
              AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  return Container(
                    width: kButtonHeight + 24,
                    height: kButtonHeight + 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment(-1 + (_shimmerController.value * 2), -1),
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

              // 🎯 Logo עצמו - Theme-Aware
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

  /// 📝 שם האפליקציה מונפש - Theme-Aware
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

  /// 🔄 Loading Indicator עם הודעות מתחלפות - Theme-Aware
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
            // עיגול טעינה - Theme-Aware
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

            // הודעת טעינה מתחלפת - Theme-Aware
            AnimatedSwitcher(
              duration: _switcherAnimationDuration,
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
                _loadingMessages[_currentMessageIndex],
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

  /// ❌ מצב שגיאה מעוצב - Theme-Aware
  Widget _buildErrorState(ColorScheme cs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: _errorAnimationDuration,
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
            // אייקון שגיאה - Theme-Aware
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

            // טקסט - Theme-Aware
            Text(
              'אופס! משהו השתבש',
              style: TextStyle(
                fontSize: kFontSizeLarge,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: kSpacingSmall),
            Text(
              'לא הצלחנו לטעון את האפליקציה',
              style: TextStyle(
                fontSize: kFontSizeBody,
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: kSpacingXLarge),

            // כפתור retry - Theme-Aware
            Semantics(
              button: true,
              label: 'נסה שוב לטעון את האפליקציה',
              hint: 'לחץ כדי לנסות שוב',
              child: ElevatedButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh),
                label: const Text('נסה שוב'),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: kSpacingXLarge,
                  vertical: kSpacingMedium,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                ),
                elevation: 5,
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🌊 Custom Painter לגלים - Theme-Aware
class _WavePainter extends CustomPainter {
  final double animationValue;
  final ColorScheme colorScheme;

  _WavePainter(this.animationValue, this.colorScheme);

  @override
  void paint(Canvas canvas, Size size) {
    // גל ראשון - Theme-Aware
    final paint = Paint()
      ..color = colorScheme.onPrimary.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.5);

    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.5 +
            math.sin((i / size.width * 2 * math.pi) + (animationValue * 2 * math.pi)) *
                20,
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // גל שני - Theme-Aware
    final paint2 = Paint()
      ..color = colorScheme.onPrimary.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.7);

    for (double i = 0; i <= size.width; i++) {
      path2.lineTo(
        i,
        size.height * 0.7 +
            math.sin(
                    (i / size.width * 2 * math.pi) +
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
  bool shouldRepaint(_WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
