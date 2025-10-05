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
import '../../providers/shopping_lists_provider.dart';
import '../../providers/receipt_provider.dart';
import '../../services/navigation_service.dart';
import '../../data/rich_demo_data.dart';

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
      final householdId = demoUser['householdId']!;

      debugPrint('🔐 DemoLogin: מתחבר כ-${demoUser['name']} ($email)');

      // 1. התחברות עם Firebase Auth
      final userContext = context.read<UserContext>();
      await userContext.signIn(
        email: email,
        password: password,
      );

      if (!userContext.isLoggedIn) {
        throw Exception('שגיאה בהתחברות');
      }

      debugPrint('✅ DemoLogin: התחברות הושלמה - ${userContext.userId}');

      // 2. טוען את נתוני הדמו העשירים
      final demoData = await loadRichDemoData(
        userContext.userId!,
        householdId,
      );

      // 3. טוען רשימות קניות
      if (mounted) {
        final listsProvider = context.read<ShoppingListsProvider>();
        for (var list in demoData['shoppingLists']) {
          await listsProvider.updateList(list);
        }
        debugPrint('✅ DemoLogin: טען ${demoData['shoppingLists'].length} רשימות');
      }

      // 4. טוען קבלות
      if (mounted) {
        try {
          final receiptProvider = context.read<ReceiptProvider>();
          for (var receipt in demoData['receipts']) {
            await receiptProvider.updateReceipt(receipt);
          }
          debugPrint('✅ DemoLogin: טען ${demoData['receipts'].length} קבלות');
        } catch (e) {
          debugPrint('⚠️ DemoLogin: ReceiptProvider לא זמין - $e');
        }
      }

      // 5. ProductsProvider ו-SuggestionsProvider יטענו אוטומטית (ProxyProvider)
      debugPrint('🔄 DemoLogin: ProductsProvider יטען אוטומטית');

      // 6. שומר ב-SharedPreferences
      await NavigationService.saveUserId(userContext.userId!);
      await NavigationService.markOnboardingSeen();

      // 7. מציג הודעת הצלחה
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ התחברת בהצלחה כ${demoUser['name']}!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // 8. ניווט לדף הבית
      if (mounted) {
        await NavigationService.goToHome(context);
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
              title: Text(user['name']!),
              subtitle: Text(user['email']!),
              onChanged: (value) => Navigator.pop(context, value),
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
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
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
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }
}
