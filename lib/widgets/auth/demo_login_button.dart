// 📄 File: lib/widgets/auth/demo_login_button.dart
// תיאור: כפתור כניסה מהירה עם משתמשים אמיתיים מ-Firebase
//
// עדכונים (05/10/2025):
// ✅ שימוש ב-Firebase Authentication
// ✅ 3 משתמשים מוכנים: יוני, שרה, דני
// ✅ התחברות אמיתית עם אימייל וסיסמה
// ✅ טעינה אוטומטית של נתוני דמו

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_context.dart';
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
      'householdId': 'house_demo',
    },
    'sarah': {
      'email': 'sarah@demo.com',
      'password': 'Demo123!',
      'name': 'שרה',
      'householdId': 'house_demo',
    },
    'danny': {
      'email': 'danny@demo.com',
      'password': 'Demo123!',
      'name': 'דני',
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

      // 4. מציג הודעת הצלחה
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ התחברת בהצלחה כ${demoUser['name']}!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
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
              subtitle: Text(user['email']!),
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

    return Column(
      children: [
        // כפתור בחירת משתמש
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _showUserSelectionDialog,
          icon: const Icon(Icons.person_outline, size: 20),
          label: Text(
            'משתמש נוכחי: ${currentUser['name']}',
            style: const TextStyle(fontSize: 14),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // כפתור התחברות
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _handleDemoLogin,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.rocket_launch_outlined, size: 20),
          label: Text(
            _isLoading ? 'מתחבר...' : 'התחבר עם חשבון דמו',
            style: const TextStyle(fontSize: 14),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}
