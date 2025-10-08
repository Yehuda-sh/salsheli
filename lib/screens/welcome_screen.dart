// 📄 File: lib/screens/welcome_screen.dart
// 🎯 Purpose: מסך קבלת פנים - מציג לוגו, יתרונות, וכפתורי התחברות/הרשמה
//
// 📋 Features:
// - לוגו מעוצב עם אייקון
// - 3 יתרונות עיקריים (BenefitTile)
// - כפתורי התחברות/הרשמה (AuthButton)
// - כפתור דילוג
// - Social login buttons (demo only)
// - Logging מלא
// - Touch targets 48px
// - Accessibility labels
//
// 🔗 Related:
// - NavigationService - ניווט מרכזי
// - BenefitTile - רכיב יתרונות משותף
// - AuthButton - רכיב כפתורי auth משותף
// - AppTheme - ערכות נושא
//
// 🎨 Design:
// - רקע כהה (welcomeBackground מה-Theme)
// - טקסט לבן עם אפקטי opacity
// - ריווחים מ-constants.dart

import 'package:flutter/material.dart';
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

    return Scaffold(
      body: Container(
        // 🌈 גרדיאנט עדין ברקע - עומק ויזואלי
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              bgColor,
              bgColor.withValues(alpha: 0.95),
              const Color(0xFF1E293B), // Slate 800
              bgColor.withValues(alpha: 0.98),
              bgColor,
            ],
            stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(kSpacingXLarge),
              child: Column(
                children: [
                  const SizedBox(height: kSpacingMedium), // צומצם מ-40 ל-16

                  // לוגו עם Accessibility + זוהר ואנימציה
                  Semantics(
                    label: AppStrings.welcome.logoLabel,
                    child: _AnimatedLogo(accent: accent),
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
                      color: Colors.white.withValues(alpha: 0.9), // בהיר יותר!
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
                    subtitleColor: Colors.white.withValues(alpha: 0.85),
                    iconColor: accent,
                  ),
                  BenefitTile(
                    icon: Icons.camera_alt_outlined,
                    title: AppStrings.welcome.benefit2Title,
                    subtitle: AppStrings.welcome.benefit2Subtitle,
                    titleColor: Colors.white,
                    subtitleColor: Colors.white.withValues(alpha: 0.85),
                    iconColor: accent,
                  ),
                  BenefitTile(
                    icon: Icons.inventory_2_outlined,
                    title: AppStrings.welcome.benefit3Title,
                    subtitle: AppStrings.welcome.benefit3Subtitle,
                    titleColor: Colors.white,
                    subtitleColor: Colors.white.withValues(alpha: 0.85),
                    iconColor: accent,
                  ),

                  const SizedBox(height: kSpacingLarge), // צומצם מ-48 ל-24

                  // כפתור התחברות
                  AuthButton.primary(
                    label: AppStrings.welcome.loginButton,
                    icon: Icons.login,
                    onPressed: () {
                      debugPrint('🔐 WelcomeScreen: התחברות נלחץ');
                      Navigator.pushNamed(context, '/login');
                    },
                  ),
                  const SizedBox(height: kSpacingSmallPlus),

                  // כפתור הרשמה
                  AuthButton.secondary(
                    label: AppStrings.welcome.registerButton,
                    icon: Icons.app_registration_outlined,
                    onPressed: () {
                      debugPrint('📝 WelcomeScreen: הרשמה נלחץ');
                      Navigator.pushNamed(context, '/onboarding');
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
                        onPressed: () {
                          debugPrint('🌐 WelcomeScreen: Google login נלחץ');
                          Navigator.pushNamed(context, '/login');
                        },
                      ),
                      const SizedBox(width: kSpacingMedium),
                      _SocialLoginButton(
                        icon: Icons.facebook,
                        label: AppStrings.welcome.facebookButton,
                        onPressed: () {
                          debugPrint('🌐 WelcomeScreen: Facebook login נלחץ');
                          Navigator.pushNamed(context, '/login');
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
      width: kIconSizeXLarge + 20, // 100px (קטן יותר)
      height: kIconSizeXLarge + 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // זוהר רדיאלי סביב הלוגו
        gradient: RadialGradient(
          colors: [
            accent.withValues(alpha: 0.3),
            accent.withValues(alpha: 0.15),
            accent.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        ),
      ),
      child: Center(
        child: Container(
          width: kIconSizeXLarge, // 80px
          height: kIconSizeXLarge,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.4),
                blurRadius: 24,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: accent.withValues(alpha: 0.2),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Icon(
            Icons.shopping_basket_outlined,
            size: 48, // קטן יותר ביחס
            color: accent,
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(),
            )
            .shimmer(
              duration: 2500.ms,
              color: accent.withValues(alpha: 0.3),
              angle: 45,
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
          icon: Icon(icon, size: 20),
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
