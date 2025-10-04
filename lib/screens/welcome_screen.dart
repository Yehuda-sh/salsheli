// 📄 File: lib/screens/welcome_screen.dart
// תיאור: מסך קבלת פנים - מציג לוגו, יתרונות, וכפתורי התחברות/הרשמה
//
// עדכונים:
// ✅ תיעוד מלא בראש הקובץ
// ✅ שימוש ב-NavigationService במקום קריאות ישירות ל-SharedPreferences
// ✅ שימוש ברכיב BenefitTile משותף
// ✅ שימוש ברכיב AuthButton משותף
// ✅ צבע רקע מה-Theme (welcomeBackground)
// ✅ לוגיקה פשוטה יותר - פונקציה אחת לניווט

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common/benefit_tile.dart';
import '../widgets/auth/auth_button.dart';
import '../services/navigation_service.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? theme.colorScheme.primary;
    final bgColor = brand?.welcomeBackground ?? const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // לוגו
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_basket_outlined,
                    size: 56,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 24),

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
                const SizedBox(height: 12),

                // תיאור
                Text(
                  'הכלי המושלם לתכנון קניות\nחיסכון בזמן וכסף',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),

                // רשימת יתרונות (שימוש ברכיב משותף)
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

                const SizedBox(height: 48),

                // כפתור התחברות (רכיב משותף)
                AuthButton.primary(
                  label: 'התחברות',
                  icon: Icons.login,
                  onPressed: () => NavigationService.goToLogin(context),
                ),
                const SizedBox(height: 12),

                // כפתור הרשמה (רכיב משותף)
                AuthButton.secondary(
                  label: 'הרשמה',
                  icon: Icons.app_registration_outlined,
                  onPressed: () => NavigationService.goToOnboarding(context),
                ),
                const SizedBox(height: 16),

                // כפתור דילוג
                TextButton(
                  onPressed: () => NavigationService.skip(context),
                  child: Text(
                    'דלג לעכשיו',
                    style: TextStyle(color: Colors.white60, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 32),

                // אפשרויות Social Login (דמו בלבד)
                Text('או התחבר עם:', style: TextStyle(color: Colors.white60)),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialLoginButton(
                      icon: Icons.g_mobiledata,
                      label: 'Google',
                      onPressed: () => NavigationService.goToLogin(context),
                    ),
                    const SizedBox(width: 16),
                    _SocialLoginButton(
                      icon: Icons.facebook,
                      label: 'Facebook',
                      onPressed: () => NavigationService.goToLogin(context),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// כפתור Social Login פנימי (דמו)
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
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white70,
        side: const BorderSide(color: Colors.white30),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
