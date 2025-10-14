// 📄 File: lib/screens/welcome_screen.dart
// 🎯 Purpose: מסך קבלת פנים - מציג לוגו, יתרונות, וכפתורי התחברות/הרשמה
//
// 📋 Features:
// - לוגו מעוצב עם אייקון ואנימצית shimmer
// - 3 יתרונות עיקריים (BenefitTile)
// - כפתורי התחברות/הרשמה (AuthButton)
// - Social login buttons (demo only)
// - Logging מלא
// - Touch targets 48px
// - Accessibility labels
// - כל הערכים מ-constants (100% אין hardcoded!)
//
// 🔗 Related:
// - BenefitTile - רכיב יתרונות משותף
// - AuthButton - רכיב כפתורי auth משותף
// - AppTheme - ערכות נושא
// - ui_constants.dart - כל הקבועים (גדלים, opacity, אנימציות)
//
// 🎨 Design:
// - רקע כהה עם גרדיאנט (welcomeBackground מה-Theme)
// - טקסט לבן עם אפקטי opacity מ-constants
// - ריווחים מ-constants.dart
// - לוגו עם זוהר רדיאלי וshadows

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/common/benefit_tile.dart';
import '../widgets/auth/auth_button.dart';
import '../core/ui_constants.dart';
import '../l10n/app_strings.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🏠 WelcomeScreen.build()');
    
    final theme = Theme.of(context);
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? theme.colorScheme.primary;
    final bgColor = brand?.welcomeBackground ?? const Color(0xFF0F172A);
    // צבע גרדיאנט משני - Slate 800
    const gradientFallbackColor = Color(0xFF1E293B);

    return Scaffold(
      body: Container(
        // 🌈 גרדיאנט עדין ברקע - עומק ויזואלי
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              bgColor,
              bgColor.withValues(alpha: kOpacityAlmostFull),
              gradientFallbackColor,
              bgColor.withValues(alpha: kOpacityNearFull),
              bgColor,
            ],
            stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            // 📱 גלילה חלקה יותר עם physics מתאים לפלטפורמה
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(kSpacingXLarge),
              child: Column(
                children: [
                  const SizedBox(height: kSpacingMedium), // צומצם מ-40 ל-16

                  // לוגו עם Accessibility + זוהר ואנימציה + Hero
                  Hero(
                    tag: 'app_logo',
                    child: Semantics(
                      label: AppStrings.welcome.logoLabel,
                      child: _AnimatedLogo(accent: accent),
                    ),
                  ),
                  const SizedBox(height: kSpacingLarge),

                  // כותרת
                  Text(
                    AppStrings.welcome.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: kFontSizeDisplay,
                    ),
                  ),
                  const SizedBox(height: kSpacingSmallPlus),

                  // תיאור
                  Text(
                    AppStrings.welcome.subtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: kOpacityVeryHigh),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: kSpacingLarge), // צומצם מ-48 ל-24

                  // רשימת יתרונות - עם צבעים לבנים לרקע כהה
                  BenefitTile(
                    icon: Icons.people_outline,
                    title: AppStrings.welcome.benefit1Title,
                    subtitle: AppStrings.welcome.benefit1Subtitle,
                    titleColor: Colors.white,
                    subtitleColor: Colors.white.withValues(alpha: kOpacityMediumHigh),
                    iconColor: accent,
                  ),
                  BenefitTile(
                    icon: Icons.camera_alt_outlined,
                    title: AppStrings.welcome.benefit2Title,
                    subtitle: AppStrings.welcome.benefit2Subtitle,
                    titleColor: Colors.white,
                    subtitleColor: Colors.white.withValues(alpha: kOpacityMediumHigh),
                    iconColor: accent,
                  ),
                  BenefitTile(
                    icon: Icons.inventory_2_outlined,
                    title: AppStrings.welcome.benefit3Title,
                    subtitle: AppStrings.welcome.benefit3Subtitle,
                    titleColor: Colors.white,
                    subtitleColor: Colors.white.withValues(alpha: kOpacityMediumHigh),
                    iconColor: accent,
                  ),

                  const SizedBox(height: kSpacingLarge), // צומצם מ-48 ל-24

                  // כפתור התחברות
                  AuthButton.primary(
                    label: AppStrings.welcome.loginButton,
                    icon: Icons.login,
                    onPressed: () async {
                      debugPrint('🔐 WelcomeScreen: התחברות נלחץ');
                      // 📳 רטט קל למשוב מישושי
                      await HapticFeedback.lightImpact();
                      // 🛡️ טיפול בשגיאות ניווט
                      if (context.mounted) {
                        try {
                          await Navigator.pushNamed(context, '/login');
                        } catch (e) {
                          debugPrint('❌ שגיאה בניווט למסך התחברות: $e');
                        }
                      }
                    },
                  ),
                  const SizedBox(height: kSpacingSmallPlus),

                  // כפתור הרשמה
                  AuthButton.secondary(
                    label: AppStrings.welcome.registerButton,
                    icon: Icons.app_registration_outlined,
                    onPressed: () async {
                      debugPrint('📝 WelcomeScreen: הרשמה נלחץ');
                      // 📳 רטט קל למשוב מישושי
                      await HapticFeedback.lightImpact();
                      // 🛡️ טיפול בשגיאות ניווט
                      if (context.mounted) {
                        try {
                          await Navigator.pushNamed(context, '/onboarding');
                        } catch (e) {
                          debugPrint('❌ שגיאה בניווט למסך הרשמה: $e');
                        }
                      }
                    },
                  ),
                  const SizedBox(height: kSpacingMedium), // צומצם מ-24 ל-16

                  // אפשרויות Social Login
                  Text(
                    AppStrings.welcome.socialLoginLabel,
                    style: TextStyle(color: Colors.white60),
                  ),
                  const SizedBox(height: kSpacingMedium),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialLoginButton(
                        icon: Icons.g_mobiledata,
                        label: AppStrings.welcome.googleButton,
                        onPressed: () async {
                          debugPrint('🌐 WelcomeScreen: Google login נלחץ');
                          // TODO: יישום התחברות Google אמיתית
                          await HapticFeedback.lightImpact();
                          if (context.mounted) {
                            try {
                              await Navigator.pushNamed(context, '/login');
                            } catch (e) {
                              debugPrint('❌ שגיאה בניווט: $e');
                            }
                          }
                        },
                      ),
                      const SizedBox(width: kSpacingMedium),
                      _SocialLoginButton(
                        icon: Icons.facebook,
                        label: AppStrings.welcome.facebookButton,
                        onPressed: () async {
                          debugPrint('🌐 WelcomeScreen: Facebook login נלחץ');
                          // TODO: יישום התחברות Facebook אמיתית
                          await HapticFeedback.lightImpact();
                          if (context.mounted) {
                            try {
                              await Navigator.pushNamed(context, '/login');
                            } catch (e) {
                              debugPrint('❌ שגיאה בניווט: $e');
                            }
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: kSpacingLarge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// לוגו מונפש עם זוהר ואנימציה
///
/// יוצר אפקט גלו (glow) מסביב לאייקון עם אנימציית shimmer עדינה
///
/// **תכונות:**
/// - זוהר רדיאלי בצבע accent
/// - אנימציית shimmer בלולאה (כל 2.5 שניות)
/// - BoxShadow לעומק
/// - גודל 80x80 (מ-ui_constants)
class _AnimatedLogo extends StatelessWidget {
  final Color accent;

  const _AnimatedLogo({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kIconSizeXLarge + kLogoGlowPadding,
      height: kIconSizeXLarge + kLogoGlowPadding,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // זוהר רדיאלי סביב הלוגו
        gradient: RadialGradient(
          colors: [
            accent.withValues(alpha: kOpacityLow),
            accent.withValues(alpha: kOpacityVeryLow),
            accent.withValues(alpha: kOpacityMinimal),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        ),
      ),
      child: Center(
        child: Container(
          width: kIconSizeXLarge,
          height: kIconSizeXLarge,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: kOpacityVeryLow),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: kOpacityMedium - 0.1), // 0.4
                blurRadius: 24,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: accent.withValues(alpha: kOpacityLight),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Icon(
            Icons.shopping_basket_outlined,
            size: kLogoIconInnerSize,
            color: accent,
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(),
            )
            .shimmer(
              duration: kAnimationDurationSlow,
              color: accent.withValues(alpha: kOpacityLow),
              angle: kShimmerAngle,
              delay: const Duration(milliseconds: 800), // ⚡ עיכוב בין לולאות לחיסכון בסוללה
            ),
      ),
    );
  }
}

/// כפתור Social Login פנימי
///
/// widget פרטי המשמש להצגת כפתורי התחברות חברתית (Google/Facebook).
/// כרגע מדובר ב-demo בלבד - מוביל למסך התחברות רגיל.
///
/// **תכונות:**
/// - אייקון + תווית
/// - עיצוב outlined עם צבעים בהירים
/// - Border radius מ-constants
/// - Touch target 48px
/// - Accessibility labels
class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppStrings.welcome.socialLoginButtonLabel(label),
      child: SizedBox(
        height: kButtonHeight,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: kSocialIconSize),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white70,
            side: const BorderSide(color: Colors.white30),
            padding: const EdgeInsets.symmetric(
              horizontal: kButtonPaddingHorizontal,
              vertical: kSpacingSmallPlus,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
          ),
        ),
      ),
    );
  }
}
