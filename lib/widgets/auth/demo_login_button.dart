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

import 'package:flutter/foundation.dart';
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
  // ⚠️ DEMO USERS ONLY - לא לייצור אמיתי!
  // אלו משתמשי בדיקה עם credentials גלויים למטרות פיתוח בלבד
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

  /// מבצע התחברות עם משתמש דמו נבחר דרך Firebase Auth.
  /// 
  /// התהליך:
  /// 1. מתחבר עם Firebase Auth
  /// 2. שומר ב-SharedPreferences
  /// 3. מציג הודעת הצלחה
  /// 4. מנווט לדף הבית
  /// 
  /// Throws [Exception] במקרה של כשל בהתחברות.
  Future<void> _handleDemoLogin() async {
    setState(() => _isLoading = true);

    try {
      final demoUser = _demoUsers[_selectedUser]!;
      final email = demoUser['email']!;
      final password = demoUser['password']!;

      if (kDebugMode) {
        debugPrint('🔐 DemoLogin: מתחבר כ-${demoUser['fullName']} ($email)');
      }

      // 1. התחברות עם Firebase Auth
      final userContext = context.read<UserContext>();
      await userContext.signIn(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        debugPrint('✅ DemoLogin: התחברות הושלמה');
      }

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
            padding: const EdgeInsets.symmetric(vertical: kSpacingXTiny), // 📐 padding מצומצם
            child: Column(
              children: [
                Text(
                  'בחר משתמש ממשפחת לוי:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: kFontSizeTiny, // 📐 הקטנה
                  ),
                ),
                const SizedBox(height: kSpacingXTiny), // spacing מינימלי בתוך כפתור קומפקטי
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
                    const SizedBox(width: kSpacingXSmall),
                    
                    // כפתור מיכל (אמא)
                    _buildQuickUserButton(
                      context: context,
                      userId: 'michal',
                      icon: Icons.person,
                      label: 'מיכל',
                      subtitle: 'אמא',
                      isSelected: _selectedUser == 'michal',
                    ),
                    const SizedBox(width: kSpacingXSmall),
                    
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

  /// בונה כפתור בחירה למשתמש ספציפי בסגנון מינימליסטי.
  /// 
  /// Parameters:
  /// - [userId]: מזהה המשתמש (avi/michal/tomer)
  /// - [icon]: אייקון להצגה
  /// - [label]: שם המשתמש
  /// - [subtitle]: תפקיד במשפחה (אבא/אמא/בן)
  /// - [isSelected]: האם המשתמש נבחר כרגע
  /// 
  /// Returns כפתור בעיצוב Sticky Notes עם visual feedback.
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
          constraints: const BoxConstraints(minHeight: 44), // ♿ נגישות - tap area
          padding: const EdgeInsets.symmetric(
            horizontal: kSpacingXTiny, // 6px
            vertical: kSpacingXTiny, // 6px
          ),
          decoration: BoxDecoration(
            color: isSelected 
                ? cs.primary.withValues(alpha: kOpacityVeryLow)
                : Colors.white.withValues(alpha: kOpacityMedium),
            borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            border: Border.all(
              color: isSelected 
                  ? cs.primary
                  : cs.outline.withValues(alpha: kOpacityLow),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: kIconSizeSmall,
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(height: kSpacingXTiny),
              Text(
                label,
                style: TextStyle(
                  fontSize: kFontSizeTiny, // 11px - נגישות
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? cs.primary : cs.onSurfaceVariant,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: kFontSizeTiny, // 11px - נגישות
                  fontWeight: FontWeight.w400,
                  color: isSelected 
                      ? cs.primary.withValues(alpha: kOpacityHigh)
                      : cs.onSurfaceVariant.withValues(alpha: kOpacityMedium),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
