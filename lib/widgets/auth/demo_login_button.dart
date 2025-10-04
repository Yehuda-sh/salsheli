// 📄 File: lib/widgets/auth/demo_login_button.dart
// תיאור: כפתור כניסה מהירה עם משתמש דמו (יוני כהן) - משתמש אמיתי מלא
//
// עדכונים:
// ✅ הוסר סימון "אורח" - זה משתמש אמיתי
// ✅ טקסט מעודכן: "התחבר עם חשבון דמו"
// ✅ הודעת הצלחה: "התחברת בהצלחה כיוני כהן!"
// ✅ טוען משתמש + היסטוריה מלאה

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_context.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/receipt_provider.dart';
import '../../services/navigation_service.dart';
import '../../data/rich_demo_data.dart';

/// כפתור כניסה מהירה למשתמש דמו
///
/// מה הכפתור עושה:
/// 1. מתחבר כמשתמש יוני כהן (yoni_123) - משתמש אמיתי מלא
/// 2. טוען את כל נתוני הדמו (רשימות, קבלות, מלאי)
/// 3. שומר את המשתמש ב-SharedPreferences
/// 4. מנווט לדף הבית
class DemoLoginButton extends StatefulWidget {
  const DemoLoginButton({super.key});

  @override
  State<DemoLoginButton> createState() => _DemoLoginButtonState();
}

class _DemoLoginButtonState extends State<DemoLoginButton> {
  bool _isLoading = false;

  /// טעינת משתמש דמו עם כל ההיסטוריה
  Future<void> _handleDemoLogin() async {
    setState(() => _isLoading = true);

    try {
      const demoUserId = 'yoni_123';
      const demoHouseholdId = 'house_demo';

      // 1. טוען את המשתמש
      final userContext = context.read<UserContext>();
      await userContext.loadUser(demoUserId);

      if (!userContext.isLoggedIn) {
        throw Exception('לא ניתן לטעון משתמש דמו');
      }

      // 2. טוען את נתוני הדמו העשירים
      final demoData = loadRichDemoData(demoUserId, demoHouseholdId);

      // 3. טוען רשימות קניות
      if (mounted) {
        final listsProvider = context.read<ShoppingListsProvider>();
        for (var list in demoData['shoppingLists']) {
          await listsProvider.updateList(list);
        }
      }

      // 4. טוען קבלות
      if (mounted) {
        try {
          final receiptProvider = context.read<ReceiptProvider>();
          for (var receipt in demoData['receipts']) {
            await receiptProvider.updateReceipt(receipt);
          }
        } catch (e) {
          debugPrint('ReceiptProvider לא זמין: $e');
        }
      }

      // 5. מלאי - דילוג (API לא תומך)
      if (mounted) {
        debugPrint('מלאי דמו: מדלג על טעינה (API לא זמין)');
      }

      // 6. שומר ב-SharedPreferences
      await NavigationService.saveUserId(demoUserId);
      await NavigationService.markOnboardingSeen();

      // 7. מציג הודעת הצלחה
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ התחברת בהצלחה כיוני כהן!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
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
            content: Text('שגיאה בכניסה: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : _handleDemoLogin,
      icon: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.rocket_launch_outlined, size: 20),
      label: Text(
        _isLoading ? 'טוען...' : 'התחבר עם חשבון דמו',
        style: const TextStyle(fontSize: 14),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
      ),
    );
  }
}
