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
import '../theme/app_theme.dart';
import '../widgets/common/benefit_tile.dart';
import '../widgets/auth/auth_button.dart';
import '../services/navigation_service.dart';
import '../core/constants.dart';

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
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(kSpacingLarge + 8), // 32
            child: Column(
              children: [
                SizedBox(height: kSpacingLarge + 16), // 40

                // לוגו עם Accessibility
                Semantics(
                  label: 'לוגו אפליקציית סל שלי',
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_basket_outlined,
                      size: 56,
                      color: accent,
                    ),
                  ),
                ),
                SizedBox(height: kSpacingLarge),

                // כותרת
                Text(
                  'סל שלי',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
                SizedBox(height: kSpacingSmall + 4), // 12

                // תיאור
                Text(
                  'הכלי המושלם לתכנון קניות\nחיסכון בזמן וכסף',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: kSpacingLarge * 2), // 48

                // רשימת יתרונות
                const BenefitTile(
                  icon: Icons.checklist_outlined,
                  title: 'רשימות חכמות',
                  subtitle: 'צרו רשימות קניות בקלות ושתפו עם בני הבית.',
                ),
                const BenefitTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'סריקת קבלות ותקציב',
                  subtitle: 'מעקב הוצאות חכם וחיסכון אמיתי.',
                ),
                const BenefitTile(
                  icon: Icons.inventory_2_outlined,
                  title: 'ניהול מזווה חכם',
                  subtitle: 'אל תקנו פעמיים—ראו מה כבר יש בבית.',
                ),

                SizedBox(height: kSpacingLarge * 2), // 48

                // כפתור התחברות
                AuthButton.primary(
                  label: 'התחברות',
                  icon: Icons.login,
                  onPressed: () {
                    debugPrint('🔐 WelcomeScreen: התחברות נלחץ');
                    NavigationService.goToLogin(context);
                  },
                ),
                SizedBox(height: kSpacingSmall + 4), // 12

                // כפתור הרשמה
                AuthButton.secondary(
                  label: 'הרשמה',
                  icon: Icons.app_registration_outlined,
                  onPressed: () {
                    debugPrint('📝 WelcomeScreen: הרשמה נלחץ');
                    NavigationService.goToOnboarding(context);
                  },
                ),
                SizedBox(height: kSpacingMedium),

                // כפתור דילוג - Touch target 48px
                Tooltip(
                  message: 'דלג לעכשיו',
                  child: SizedBox(
                    height: kButtonHeight,
                    child: TextButton(
                      onPressed: () {
                        debugPrint('⏭️  WelcomeScreen: דילוג נלחץ');
                        NavigationService.skip(context);
                      },
                      child: const Text(
                        'דלג לעכשיו',
                        style: TextStyle(color: Colors.white60, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: kSpacingLarge + 8), // 32

                // אפשרויות Social Login
                const Text(
                  'או התחבר עם:',
                  style: TextStyle(color: Colors.white60),
                ),
                SizedBox(height: kSpacingMedium),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialLoginButton(
                      icon: Icons.g_mobiledata,
                      label: 'Google',
                      onPressed: () {
                        debugPrint('🌐 WelcomeScreen: Google login נלחץ');
                        NavigationService.goToLogin(context);
                      },
                    ),
                    SizedBox(width: kSpacingMedium),
                    _SocialLoginButton(
                      icon: Icons.facebook,
                      label: 'Facebook',
                      onPressed: () {
                        debugPrint('🌐 WelcomeScreen: Facebook login נלחץ');
                        NavigationService.goToLogin(context);
                      },
                    ),
                  ],
                ),

                SizedBox(height: kSpacingLarge),
              ],
            ),
          ),
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
      label: 'התחבר עם $label',
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
              horizontal: 20,
              vertical: kSpacingSmall + 4, // 12
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
