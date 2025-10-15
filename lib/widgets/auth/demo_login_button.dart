// 📄 File: lib/widgets/auth/demo_login_button.dart
// תיאור: כפתור כניסה מהירה עם משפחת לוי - משתמשים אמיתיים מ-Firebase
//
// עדכונים (15/10/2025): 👨‍👩‍👧‍👦 משפחת לוי!
// ✅ עודכן עם משפחת לוי החדשה (5 משתמשים)
// ✅ Sticky Notes Design System!
// ✅ כפתורי בחירה בפתקים צבעוניים
// ✅ כפתור התחברות ב-StickyButton
// ✅ Visual feedback משופר
// ✅ רווחים מצומצמים למסך אחד 📐
//
// עדכונים קודמים (14/10/2025):
// ✅ UI משופר - כפתורים בשתי שורות
// ✅ טקסט קצר יותר
// ✅ Responsive - מתאים למסכים קטנים

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_context.dart';
import '../../core/ui_constants.dart';
import '../common/sticky_note.dart';
import '../common/sticky_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// כפתור כניסה מהירה למשתמש דמו - משפחת לוי 👨‍👩‍👧‍👦
///
/// משתמשים זמינים:
/// 1. אבי לוי (אבא) - avi.levi@demo.com (סיסמה: Demo2025!)
/// 2. מיכל לוי (אמא) - michal.levi@demo.com (סיסמה: Demo2025!)
/// 3. תומר לוי (בן) - tomer.levi@demo.com (סיסמה: Demo2025!)
class DemoLoginButton extends StatefulWidget {
  const DemoLoginButton({super.key});

  @override
  State<DemoLoginButton> createState() => _DemoLoginButtonState();
}

class _DemoLoginButtonState extends State<DemoLoginButton> {
  bool _isLoading = false;
  String _selectedUser = 'avi'; // ברירת מחדל - אבי (אבא)

  // 👨‍👩‍👧‍👦 משפחת לוי - משתמשי דמו זמינים
  final Map<String, Map<String, String>> _demoUsers = {
    'avi': {
      'email': 'avi.levi@demo.com',
      'password': 'Demo2025!',
      'name': 'אבי',
      'fullName': 'אבי לוי',
      'shortName': 'אבי',
      'householdId': 'house_levi_demo',
      'role': 'אבא',
    },
    'michal': {
      'email': 'michal.levi@demo.com',
      'password': 'Demo2025!',
      'name': 'מיכל',
      'fullName': 'מיכל לוי',
      'shortName': 'מיכל',
      'householdId': 'house_levi_demo',
      'role': 'אמא',
    },
    'tomer': {
      'email': 'tomer.levi@demo.com',
      'password': 'Demo2025!',
      'name': 'תומר',
      'fullName': 'תומר לוי',
      'shortName': 'תומר',
      'householdId': 'house_levi_demo',
      'role': 'בן',
    },
  };

  /// טעינת משתמש דמו עם Firebase Authentication
  Future<void> _handleDemoLogin() async {
    setState(() => _isLoading = true);

    try {
      final demoUser = _demoUsers[_selectedUser]!;
      final email = demoUser['email']!;
      final password = demoUser['password']!;

      debugPrint('🔐 DemoLogin: מתחבר כ-${demoUser['fullName']} ($email)');

      // 1. התחברות עם Firebase Auth
      final userContext = context.read<UserContext>();
      await userContext.signIn(
        email: email,
        password: password,
      );

      debugPrint('✅ DemoLogin: התחברות הושלמה');

      // 2. שומר ב-SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userContext.userId!);
      await prefs.setBool('seen_onboarding', true);

      // 3. מציג הודעת הצלחה משופרת
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 24),
                const SizedBox(width: kSpacingSmall),
                Expanded(
                  child: Text(
                    '✅ התחברת בהצלחה כ${demoUser['fullName']}!',
                    style: const TextStyle(fontSize: kFontSizeSmall),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            margin: const EdgeInsets.all(kSpacingMedium),
          ),
        );
      }

      // 4. ניווט לדף הבית
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 24),
                const SizedBox(width: kSpacingSmall),
                Expanded(
                  child: Text(
                    'שגיאה: ${e.toString().replaceAll('Exception: ', '')}',
                    style: const TextStyle(fontSize: kFontSizeSmall),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            margin: const EdgeInsets.all(kSpacingMedium),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _demoUsers[_selectedUser]!;
    final theme = Theme.of(context);

    // 🎨 UI עם Sticky Notes Design System - compact version 📐
    return Column(
      children: [
        // 📝 שורה 1: כפתורי בחירה בפתקים צבעוניים - compact
        StickyNote(
          color: kStickyPurple, // פתק סגול לבחירת משתמש
          rotation: -0.01,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6), // 📐 padding מצומצם
            child: Column(
              children: [
                Text(
                  'בחר משתמש ממשפחת לוי:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: kFontSizeTiny, // 📐 הקטנה
                  ),
                ),
                const SizedBox(height: 6), // 📐 רווח מצומצם
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // כפתור אבי (אבא)
                    _buildQuickUserButton(
                      context: context,
                      userId: 'avi',
                      icon: Icons.person,
                      label: 'אבי',
                      subtitle: 'אבא',
                      isSelected: _selectedUser == 'avi',
                    ),
                    const SizedBox(width: kSpacingXSmall), // 📐 רווח מצומצם
                    
                    // כפתור מיכל (אמא)
                    _buildQuickUserButton(
                      context: context,
                      userId: 'michal',
                      icon: Icons.person,
                      label: 'מיכל',
                      subtitle: 'אמא',
                      isSelected: _selectedUser == 'michal',
                    ),
                    const SizedBox(width: kSpacingXSmall), // 📐 רווח מצומצם
                    
                    // כפתור תומר (בן)
                    _buildQuickUserButton(
                      context: context,
                      userId: 'tomer',
                      icon: Icons.person,
                      label: 'תומר',
                      subtitle: 'בן',
                      isSelected: _selectedUser == 'tomer',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: kSpacingSmall), // 📐 צמצום מ-Medium ל-Small

        // 🔘 שורה 2: כפתור התחברות - StickyButton לבן - compact
        StickyButton(
          color: Colors.white,
          textColor: theme.colorScheme.primary,
          label: _isLoading 
              ? 'מתחבר...' 
              : 'כניסה כ${currentUser['shortName']} 🚀', // 📐 טקסט קצר יותר
          icon: Icons.rocket_launch_outlined,
          onPressed: _isLoading ? () {} : () => _handleDemoLogin(),
          height: 44, // 📐 הקטנת גובה הכפתור
        ),
      ],
    );
  }

  /// 🎨 בניית כפתור מהיר למשתמש - בסגנון מינימליסטי וקומפקטי 📐
  Widget _buildQuickUserButton({
    required BuildContext context,
    required String userId,
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Expanded(
      child: InkWell(
        onTap: _isLoading 
            ? null 
            : () => setState(() => _selectedUser = userId),
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6, // 📐 padding מצומצם
            vertical: 6, // 📐 padding מצומצם
          ),
          decoration: BoxDecoration(
            color: isSelected 
                ? cs.primary.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            border: Border.all(
              color: isSelected 
                  ? cs.primary
                  : cs.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: kIconSizeSmall, // 📐 הקטנה
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10, // 📐 הקטנה מאוד
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? cs.primary : cs.onSurfaceVariant,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 8, // 📐 הקטנה מאוד
                  fontWeight: FontWeight.w400,
                  color: isSelected 
                      ? cs.primary.withValues(alpha: 0.7)
                      : cs.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
