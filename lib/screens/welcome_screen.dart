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
// Version: 6.2 - Ultra Compact + Title Padding (20/10/2025) 🎨📝
// - 📏 Maximum optimization: 4 benefits + 2 buttons, no scrolling!
// - 👀 Logo scale: 0.75 | Spacing: kSpacingSmall | Buttons: 44px
// - 💬 Shorter texts: 1-2 words titles, concise subtitles
// - 📦 Padding vertical: 0 | No spacing before buttons
// - 🎯 Title note padding: 8px (saved -16px!)

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/common/notebook_background.dart';
import '../widgets/common/sticky_note.dart';
import '../widgets/common/sticky_button.dart';
import '../widgets/common/benefit_tile.dart';

import '../widgets/common/tappable_card.dart';
import '../core/ui_constants.dart';
import '../l10n/app_strings.dart';

// 🔧 Wrapper ללוגים - פועל רק ב-debug mode
void _log(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  /// מטפל בלחיצה על כפתור התחברות
  static void _handleLogin(BuildContext context) {
    _log('🔐 WelcomeScreen: התחברות נלחץ');
    Navigator.pushNamed(context, '/login').catchError((error) {
      _log('❌ שגיאה בניווט ל-login: $error');
      return null;
    });
  }

  /// מטפל בלחיצה על כפתור הרשמה
  static void _handleRegister(BuildContext context) {
    _log('📝 WelcomeScreen: הרשמה נלחץ');
    Navigator.pushNamed(context, '/onboarding').catchError((error) {
      _log('❌ שגיאה בניווט ל-onboarding: $error');
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    _log('🏠 WelcomeScreen.build()');

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
                padding: const EdgeInsets.symmetric(
                  horizontal: kSpacingMedium,
                  vertical: 0,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: kSpacingSmall),

                    // 📝 לוגו על פתק צהוב - קומפקטי מאוד
                    Hero(
                      tag: 'app_logo',
                      child: Transform.scale(
                        scale: 0.75,
                        child: StickyNoteLogo(
                          color: brand?.stickyYellow ?? kStickyYellow,
                          icon: Icons.shopping_basket_outlined,
                          iconColor: accent,
                          rotation: -0.03,
                        ),
                      ),
                    ),
                    const SizedBox(height: kSpacingSmall),

                    // 📋 כותרת על פתק לבן - קומפקטי
                    StickyNote(
                      color: Colors.white,
                      rotation: -0.02,
                      padding: kSpacingSmall, // 8px במקום 16px
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
                          const SizedBox(height: kSpacingXTiny), // 6px
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
                      onTap: () => _log('💛 benefit 1 tapped'),
                      child: BenefitTile(
                        icon: Icons.people_outline,
                        title: AppStrings.welcome.benefit1Title,
                        subtitle: AppStrings.welcome.benefit1Subtitle,
                        color: brand?.stickyYellow ?? kStickyYellow,
                        rotation: 0.01,
                        iconColor: accent,
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.2, end: 0.0, curve: Curves.easeOut),
                    const SizedBox(height: kSpacingSmall),
                    TappableCard(
                      onTap: () => _log('🌸 benefit 2 tapped'),
                      child: BenefitTile(
                        icon: Icons.camera_alt_outlined,
                        title: AppStrings.welcome.benefit2Title,
                        subtitle: AppStrings.welcome.benefit2Subtitle,
                        color: brand?.stickyPink ?? kStickyPink,
                        rotation: -0.015,
                        iconColor: accent,
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.2, end: 0.0, curve: Curves.easeOut),
                    const SizedBox(height: kSpacingSmall),
                    TappableCard(
                      onTap: () => _log('💚 benefit 3 tapped'),
                      child: BenefitTile(
                        icon: Icons.inventory_2_outlined,
                        title: AppStrings.welcome.benefit3Title,
                        subtitle: AppStrings.welcome.benefit3Subtitle,
                        color: brand?.stickyGreen ?? kStickyGreen,
                        rotation: 0.01,
                        iconColor: accent,
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(begin: 0.2, end: 0.0, curve: Curves.easeOut),
                    const SizedBox(height: kSpacingSmall),
                    TappableCard(
                      onTap: () => _log('💙 benefit 4 tapped'),
                      child: BenefitTile(
                        icon: Icons.receipt_long_outlined,
                        title: AppStrings.welcome.benefit4Title,
                        subtitle: AppStrings.welcome.benefit4Subtitle,
                        color: brand?.stickyCyan ?? kStickyCyan,
                        rotation: -0.015,
                        iconColor: accent,
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 400.ms).slideY(begin: 0.2, end: 0.0, curve: Curves.easeOut),

                    // 🔘 כפתורי פעולה בסגנון פתקים - קומפקטיים
                    StickyButton(
                      color: accent,
                      label: AppStrings.welcome.loginButton,
                      icon: Icons.login,
                      height: 44,
                      onPressed: () => _handleLogin(context),
                    ),
                    const SizedBox(height: kSpacingSmall),
                    StickyButton(
                      color: Colors.white,
                      textColor: accent,
                      label: AppStrings.welcome.registerButton,
                      icon: Icons.app_registration_outlined,
                      height: 44,
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
