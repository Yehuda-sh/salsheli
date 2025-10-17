// 📄 File: lib/screens/welcome_screen.dart
// 🎯 Purpose: מסך קבלת פנים - מציג לוגו, יתרונות, וכפתורי התחברות/הרשמה
//
// 📋 Features:
// - עיצוב Sticky Notes מלא 🎨📝
// - שימוש ברכיבים משותפים חדשים
// - רקע מחברת עם קווים כחולים
// - פתקים צבעוניים עם צללים מציאותיים
// - נגישות מלאה
// - אנימציות חלקות
//
// 🔗 Related:
// - NotebookBackground - רקע מחברת
// - StickyNote / StickyNoteLogo - פתקים
// - StickyButton - כפתורים
// - BenefitTile - רכיב יתרונות
// - ui_constants.dart - קבועים
// - app_theme.dart - AppBrand
//
// 🎨 Design:
// - עיצוב Sticky Notes System 2025
// - רקע נייר קרם עם קווים כחולים
// - פתקים צבעוניים: צהוב, לבן, ורוד, ירוק
// - צללים מציאותיים לאפקט הדבקה
// - סיבובים קלים לכל פתק
//
// Version: 5.0 - Sticky Notes with Shared Components (15/10/2025) 🎨📝

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/common/notebook_background.dart';
import '../widgets/common/sticky_note.dart';
import '../widgets/common/sticky_button.dart';
import '../widgets/common/benefit_tile.dart';

import '../widgets/common/tappable_card.dart';
import '../core/ui_constants.dart';
import '../l10n/app_strings.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  /// מטפל בלחיצה על כפתור התחברות
  static void _handleLogin(BuildContext context) {
    debugPrint('🔐 WelcomeScreen: התחברות נלחץ');
    Navigator.pushNamed(context, '/login').catchError((error) {
      debugPrint('❌ שגיאה בניווט ל-login: $error');
      return null;
    });
  }

  /// מטפל בלחיצה על כפתור הרשמה
  static void _handleRegister(BuildContext context) {
    debugPrint('📝 WelcomeScreen: הרשמה נלחץ');
    Navigator.pushNamed(context, '/onboarding').catchError((error) {
      debugPrint('❌ שגיאה בניווט ל-onboarding: $error');
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏠 WelcomeScreen.build()');

    final theme = Theme.of(context);
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: brand?.paperBackground ?? kPaperBackground,
      body: Stack(
        children: [
          // 📄 רקע נייר עם קווים
          const NotebookBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(kSpacingMedium),
                child: Column(
                  children: [
                    const SizedBox(height: kSpacingMedium),

                    // 📝 לוגו על פתק צהוב
                    Hero(
                      tag: 'app_logo',
                      child: StickyNoteLogo(
                        color: brand?.stickyYellow ?? kStickyYellow,
                        icon: Icons.shopping_basket_outlined,
                        iconColor: accent,
                        rotation: -0.03,
                      ),
                    ),
                    const SizedBox(height: kSpacingMedium),

                    // 📋 כותרת על פתק לבן
                    StickyNote(
                      color: Colors.white,
                      rotation: -0.02,
                      child: Column(
                        children: [
                          Text(
                            AppStrings.welcome.title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(height: kSpacingSmall),
                          Text(
                            AppStrings.welcome.subtitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: kSpacingLarge),

                    // 📌 יתרונות כפתקים צבעוניים עם אנימציות כניסה
                    TappableCard(
                      onTap: () => debugPrint('💛 benefit 1 tapped'),
                      child: BenefitTile(
                        icon: Icons.people_outline,
                        title: AppStrings.welcome.benefit1Title,
                        subtitle: AppStrings.welcome.benefit1Subtitle,
                        color: brand?.stickyYellow ?? kStickyYellow,
                        rotation: 0.01,
                        iconColor: accent,
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.2, end: 0.0, curve: Curves.easeOut),
                    const SizedBox(height: kSpacingMedium),
                    TappableCard(
                      onTap: () => debugPrint('🌸 benefit 2 tapped'),
                      child: BenefitTile(
                        icon: Icons.camera_alt_outlined,
                        title: AppStrings.welcome.benefit2Title,
                        subtitle: AppStrings.welcome.benefit2Subtitle,
                        color: brand?.stickyPink ?? kStickyPink,
                        rotation: -0.015,
                        iconColor: accent,
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.2, end: 0.0, curve: Curves.easeOut),
                    const SizedBox(height: kSpacingMedium),
                    TappableCard(
                      onTap: () => debugPrint('💚 benefit 3 tapped'),
                      child: BenefitTile(
                        icon: Icons.inventory_2_outlined,
                        title: AppStrings.welcome.benefit3Title,
                        subtitle: AppStrings.welcome.benefit3Subtitle,
                        color: brand?.stickyGreen ?? kStickyGreen,
                        rotation: 0.01,
                        iconColor: accent,
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(begin: 0.2, end: 0.0, curve: Curves.easeOut),

                    const SizedBox(height: kSpacingLarge),

                    // 🔘 כפתורי פעולה בסגנון פתקים
                    StickyButton(
                      color: accent,
                      label: AppStrings.welcome.loginButton,
                      icon: Icons.login,
                      onPressed: () => _handleLogin(context),
                    ),
                    const SizedBox(height: kSpacingMedium),
                    StickyButton(
                      color: Colors.white,
                      textColor: accent,
                      label: AppStrings.welcome.registerButton,
                      icon: Icons.app_registration_outlined,
                      onPressed: () => _handleRegister(context),
                    ),
                    const SizedBox(height: kSpacingLarge),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
