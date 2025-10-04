// 📄 File: lib/screens/index_screen.dart
// תיאור: מסך פתיחה ראשוני - בודק מצב משתמש ומנווט למסך המתאים
//
// שינויים:
// ✅ סדר בדיקות מתוקן: userId לפני seenOnboarding
// ✅ הוסר עיכוב מלאכותי (800ms)
// ✅ נוסף טיפול בשגיאות
// ✅ ניווט פשוט יותר

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome_screen.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndNavigate();
  }

  Future<void> _checkAndNavigate() async {
    debugPrint('\n🏗️ IndexScreen._checkAndNavigate() - מתחיל...');
    try {
      final prefs = await SharedPreferences.getInstance();

      // ✅ סדר נכון: בודק userId קודם!
      final userId = prefs.getString('userId');
      debugPrint('   1️⃣ בודק userId: ${userId ?? "null"}');
      
      if (userId != null) {
        // משתמש מחובר → ישר לדף הבית
        debugPrint('   ✅ משתמש מחובר ($userId) → ניווט ל-/home');
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
        return;
      }

      // אם לא מחובר, בודק אם ראה welcome
      final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
      debugPrint('   2️⃣ בודק seenOnboarding: $seenOnboarding');
      
      if (!seenOnboarding) {
        // לא ראה welcome → שולח לשם
        debugPrint('   ➡️ לא ראה onboarding → ניווט ל-WelcomeScreen');
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          );
        }
        return;
      }

      // ראה welcome אבל לא מחובר → שולח ל-login
      debugPrint('   ➡️ ראה onboarding אבל לא מחובר → ניווט ל-/login');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      // ✅ במקרה של שגיאה - שולח ל-welcome (ברירת מחדל בטוחה)
      debugPrint('❌ שגיאה ב-IndexScreen: $e');
      debugPrint('   ➡️ ניווט ל-WelcomeScreen (ברירת מחדל)');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_basket_outlined,
                  size: 36,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Salsheli',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              const CircularProgressIndicator(strokeWidth: 3),
            ],
          ),
        ),
      ),
    );
  }
}
