// 📄 File: lib/screens/index_screen.dart
// 🎯 Purpose: מסך פתיחה ראשוני - Splash screen שבודק מצב משתמש ומנווט למסך המתאים
//
// 📋 Flow Logic:
// 1. userId קיים? → /home (ישר לאפליקציה)
// 2. seenOnboarding? לא → WelcomeScreen (הצגת יתרונות)
// 3. אחרת → /login (התחברות)
//
// 🔗 Related:
// - WelcomeScreen - מסך קבלת פנים ראשוני
// - LoginScreen - מסך התחברות (/login)
// - HomeScreen - מסך ראשי (/home)
// - SharedPreferences - אחסון מצב משתמש
//
// 💡 Features:
// - בדיקת סדר נכון (userId קודם!)
// - Error handling עם fallback
// - Loading indicator עם הודעה
// - Accessibility labels
// - Logging מפורט
//
// ⚠️ Critical:
// - תמיד בודק userId לפני seenOnboarding (MOBILE_GUIDELINES)
// - mounted checks לפני כל navigation
// - try/catch עם fallback ל-WelcomeScreen

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome_screen.dart';

// קבועים מקומיים (הועברו מ-constants.dart שנמחק)
const double kButtonHeight = 48.0;
const double kSpacingSmall = 8.0;
const double kSpacingMedium = 16.0;

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('🚀 IndexScreen.initState()');
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
              // לוגו עם Accessibility
              Semantics(
                label: 'לוגו אפליקציית Salsheli',
                child: Container(
                  width: kButtonHeight + 24, // 72
                  height: kButtonHeight + 24, // 72
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_basket_outlined,
                    size: kButtonHeight - 12, // 36
                    color: cs.primary,
                  ),
                ),
              ),
              SizedBox(height: kSpacingMedium),
              
              // שם האפליקציה
              Semantics(
                header: true,
                child: Text(
                  'Salsheli',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ),
              SizedBox(height: kSpacingSmall + 4), // 12
              
              // Progress indicator עם accessibility
              Semantics(
                label: 'טוען את האפליקציה',
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                    SizedBox(height: kSpacingSmall),
                    Text(
                      'טוען...',
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
