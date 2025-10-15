// 📄 File: lib/widgets/auth/demo_login_button.dart
// תיאור: כפתור כניסה מהירה עם משתמשים אמיתיים מ-Firebase
//
// עדכונים (14/10/2025): ⭐
// ✅ UI משופר - כפתורים בשתי שורות
// ✅ טקסט קצר יותר - "יוני (דמו)"
// ✅ Responsive - מתאים למסכים קטנים
// ✅ Visual feedback משופר
//
// עדכונים קודמים (05/10/2025):
// ✅ שימוש ב-Firebase Authentication
// ✅ 3 משתמשים מוכנים: יוני, שרה, דני
// ✅ התחברות אמיתית עם אימייל וסיסמה
// ✅ טעינה אוטומטית של נתוני דמו

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_context.dart';
import '../../core/ui_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// כפתור כניסה מהירה למשתמש דמו
///
/// 3 משתמשים זמינים:
/// 1. יוני - yoni@demo.com (סיסמה: Demo123!)
/// 2. שרה - sarah@demo.com (סיסמה: Demo123!)
/// 3. דני - danny@demo.com (סיסמה: Demo123!)
class DemoLoginButton extends StatefulWidget {
  const DemoLoginButton({super.key});

  @override
  State<DemoLoginButton> createState() => _DemoLoginButtonState();
}

class _DemoLoginButtonState extends State<DemoLoginButton> {
  bool _isLoading = false;
  String _selectedUser = 'yoni'; // ברירת מחדל

  // משתמשי דמו זמינים
  final Map<String, Map<String, String>> _demoUsers = {
    'yoni': {
      'email': 'yoni@demo.com',
      'password': 'Demo123!',
      'name': 'יוני',
      'shortName': 'יוני', // ⭐ חדש - שם קצר
      'householdId': 'house_demo',
    },
    'sarah': {
      'email': 'sarah@demo.com',
      'password': 'Demo123!',
      'name': 'שרה',
      'shortName': 'שרה', // ⭐ חדש
      'householdId': 'house_demo',
    },
    'danny': {
      'email': 'danny@demo.com',
      'password': 'Demo123!',
      'name': 'דני',
      'shortName': 'דני', // ⭐ חדש
      'householdId': 'house_demo',
    },
  };

  /// טעינת משתמש דמו עם Firebase Authentication
  Future<void> _handleDemoLogin() async {
    setState(() => _isLoading = true);

    try {
      final demoUser = _demoUsers[_selectedUser]!;
      final email = demoUser['email']!;
      final password = demoUser['password']!;

      debugPrint('🔐 DemoLogin: מתחבר כ-${demoUser['name']} ($email)');

      // 1. התחברות עם Firebase Auth
      final userContext = context.read<UserContext>();
      await userContext.signIn(
        email: email,
        password: password,
      );

      // ✅ signIn() זורק Exception אם נכשל, אחרת מצליח
      // ה-listener של authStateChanges יעדכן את isLoggedIn אוטומטית
      debugPrint('✅ DemoLogin: התחברות הושלמה');

      // 2. ה-Providers יטענו אוטומטית את הנתונים מ-Firebase
      // ShoppingListsProvider, ReceiptProvider, ProductsProvider - כולם מקשיבים ל-UserContext
      debugPrint('🔄 DemoLogin: Providers יטענו את הנתונים מ-Firebase');

      // 3. שומר ב-SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userContext.userId!);
      await prefs.setBool('seen_onboarding', true);

      // 4. מציג הודעת הצלחה משופרת ⭐
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 24), // ⭐ אייקון
                const SizedBox(width: kSpacingSmall),
                Expanded(
                  child: Text(
                    '✅ התחברת בהצלחה כ${demoUser['name']}!',
                    style: const TextStyle(fontSize: kFontSizeSmall),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating, // ⭐ floating
            shape: RoundedRectangleBorder( // ⭐ פינות מעוגלות
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            margin: const EdgeInsets.all(kSpacingMedium), // ⭐ margin
          ),
        );
      }

      // 5. ניווט לדף הבית
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
                const Icon(Icons.error_outline, color: Colors.white, size: 24), // ⭐ אייקון
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
            behavior: SnackBarBehavior.floating, // ⭐ floating
            shape: RoundedRectangleBorder( // ⭐ פינות מעוגלות
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            margin: const EdgeInsets.all(kSpacingMedium), // ⭐ margin
          ),
        );
      }
    }
  }

  /// מציג דיאלוג לבחירת משתמש
  Future<void> _showUserSelectionDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('בחר משתמש דמו'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _demoUsers.entries.map((entry) {
            final user = entry.value;
            return RadioListTile<String>(
              value: entry.key,
              groupValue: _selectedUser,
              onChanged: (value) {
                if (value != null) {
                  Navigator.pop(context, value);
                }
              },
              title: Text(user['name']!),
              subtitle: Text(user['email']!, style: const TextStyle(fontSize: kFontSizeSmall)),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
        ],
      ),
    );

    if (result != null && result != _selectedUser) {
      setState(() => _selectedUser = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _demoUsers[_selectedUser]!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // 🎨 UI משופר - שתי שורות של כפתורים ⭐ (שיפור #7)
    return Column(
      children: [
        // 🎯 שורה 1: 3 כפתורים מהירים למשתמשים ⭐ חדש!
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // כפתור יוני
            _buildQuickUserButton(
              context: context,
              userId: 'yoni',
              icon: Icons.person,
              label: 'יוני',
              isSelected: _selectedUser == 'yoni',
            ),
            const SizedBox(width: kSpacingSmall),
            
            // כפתור שרה
            _buildQuickUserButton(
              context: context,
              userId: 'sarah',
              icon: Icons.person,
              label: 'שרה',
              isSelected: _selectedUser == 'sarah',
            ),
            const SizedBox(width: kSpacingSmall),
            
            // כפתור דני
            _buildQuickUserButton(
              context: context,
              userId: 'danny',
              icon: Icons.person,
              label: 'דני',
              isSelected: _selectedUser == 'danny',
            ),
          ],
        ),
        const SizedBox(height: kSpacingSmall),

        // 🎯 שורה 2: כפתור התחברות מרכזי ⭐ משופר
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _handleDemoLogin,
            icon: _isLoading
                ? const SizedBox(
                    width: kIconSizeSmall,
                    height: kIconSizeSmall,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.rocket_launch_outlined, size: kIconSizeMedium),
            label: Text(
              _isLoading 
                  ? 'מתחבר...' 
                  : 'התחבר כ${currentUser['shortName']} (דמו)', // ⭐ טקסט קצר!
              style: const TextStyle(
                fontSize: kFontSizeSmall,
                fontWeight: FontWeight.w600, // ⭐ מודגש קצת
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: kSpacingMedium,
                vertical: kSpacingSmallPlus,
              ),
              side: BorderSide(
                color: cs.primary.withValues(alpha: 0.5),
                width: 2, // ⭐ גבול עבה יותר
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kBorderRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 🎨 בניית כפתור מהיר למשתמש ⭐ חדש!
  Widget _buildQuickUserButton({
    required BuildContext context,
    required String userId,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Expanded(
      child: OutlinedButton(
        onPressed: _isLoading 
            ? null 
            : () => setState(() => _selectedUser = userId),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: kSpacingXSmall,
            vertical: kSpacingSmall,
          ),
          backgroundColor: isSelected 
              ? cs.primary.withValues(alpha: 0.1) // ⭐ רקע כשנבחר
              : null,
          side: BorderSide(
            color: isSelected 
                ? cs.primary // ⭐ גבול צבעוני כשנבחר
                : cs.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1, // ⭐ גבול עבה יותר כשנבחר
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: kIconSizeMedium,
              color: isSelected ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: kFontSizeTiny,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
