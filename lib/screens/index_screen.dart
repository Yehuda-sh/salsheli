// 📄 File: lib/screens/index_screen.dart
// 🎯 Purpose: מסך פתיחה ראשוני - Splash screen שבודק מצב משתמש ומנווט למסך המתאים
//
// 📋 Flow Logic (עודכן 09/10/2025):
// 1. משתמש מחובר (UserContext.isLoggedIn)? → /home (ישר לאפליקציה)
// 2. לא מחובר + לא ראה onboarding? → WelcomeScreen (הצגת יתרונות)
// 3. לא מחובר + ראה onboarding? → /login (התחברות)
//
// 🔗 Related:
// - UserContext - מקור האמת היחיד למצב משתמש (Firebase Auth)
// - WelcomeScreen - מסך קבלת פנים ראשוני
// - LoginScreen - מסך התחברות (/login)
// - HomeScreen - מסך ראשי (/home)
// - SharedPreferences - אחסון seenOnboarding (מקומי בלבד)
//
// 💡 Features:
// - Single Source of Truth - UserContext בלבד (לא SharedPreferences.userId!)
// - Real-time sync - מגיב לשינויים ב-Firebase Auth אוטומטית
// - Wait for initial load - ממתין עד ש-Firebase מסיים לטעון
// - Error handling עם fallback
// - Loading indicator עם הודעה
// - Accessibility labels
// - Logging מפורט
//
// ⚠️ Critical Changes (09/10/2025 - v2):
// - ✅ עבר מ-SharedPreferences.userId ל-UserContext.isLoggedIn
// - ✅ seenOnboarding נשאר מקומי (לא צריך sync בין מכשירים)
// - ✅ תיקון Race Condition - ממתין ל-UserContext לטעון
// - ✅ Listener ל-UserContext - מגיב לשינויים אוטומטית
// - ✅ mounted checks לפני כל navigation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/ui_constants.dart';
import '../l10n/app_strings.dart';
import '../providers/user_context.dart';
import 'welcome_screen.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  bool _hasNavigated = false; // מונע navigation כפול

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 IndexScreen.initState()');
    
    // ✅ מחכה לבניית הUI לפני שמשתמש ב-Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupListener();
    });
  }

  /// מגדיר listener ל-UserContext שיגיב לשינויים
  void _setupListener() {
    final userContext = Provider.of<UserContext>(context, listen: false);
    
    // ✅ האזן לשינויים ב-UserContext
    userContext.addListener(_onUserContextChanged);
    
    // ✅ בדוק מיידית אם כבר נטען
    _checkAndNavigate();
  }

  /// מופעל כל פעם ש-UserContext משתנה
  void _onUserContextChanged() {
    debugPrint('👂 IndexScreen: UserContext השתנה');
    if (!_hasNavigated && mounted) {
      _checkAndNavigate();
    }
  }

  Future<void> _checkAndNavigate() async {
    if (_hasNavigated) return; // כבר ניווטנו
    
    debugPrint('\n🏗️ IndexScreen._checkAndNavigate() - מתחיל...');
    
    try {
      // ✅ מקור אמת יחיד - UserContext!
      final userContext = Provider.of<UserContext>(context, listen: false);
      
      debugPrint('   📊 UserContext state:');
      debugPrint('      isLoggedIn: ${userContext.isLoggedIn}');
      debugPrint('      user: ${userContext.user?.email ?? "null"}');
      debugPrint('      isLoading: ${userContext.isLoading}');

      // ⏳ אם UserContext עדיין טוען, נחכה
      if (userContext.isLoading) {
        debugPrint('   ⏳ UserContext טוען, ממתין לסיום...');
        return; // ה-listener יקרא לנו שוב כש-isLoading ישתנה
      }

      // ✅ מצב 1: משתמש מחובר → ישר לדף הבית
      if (userContext.isLoggedIn) {
        debugPrint('   ✅ משתמש מחובר (${userContext.userEmail}) → ניווט ל-/home');
        _hasNavigated = true;
        if (mounted) {
          // הסר את ה-listener לפני ניווט
          userContext.removeListener(_onUserContextChanged);
          Navigator.of(context).pushReplacementNamed('/home');
        }
        return;
      }

      // ✅ מצב 2-3: לא מחובר → בודק אם ראה welcome
      // (seenOnboarding נשאר מקומי - לא צריך sync בין מכשירים)
      final prefs = await SharedPreferences.getInstance();
      final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
      debugPrint('   📋 seenOnboarding (local): $seenOnboarding');
      
      if (!seenOnboarding) {
        // ✅ מצב 2: לא ראה welcome → שולח לשם
        debugPrint('   ➡️ לא ראה onboarding → ניווט ל-WelcomeScreen');
        _hasNavigated = true;
        if (mounted) {
          userContext.removeListener(_onUserContextChanged);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          );
        }
        return;
      }

      // ✅ מצב 3: ראה welcome אבל לא מחובר → שולח ל-login
      debugPrint('   ➡️ ראה onboarding אבל לא מחובר → ניווט ל-/login');
      _hasNavigated = true;
      if (mounted) {
        userContext.removeListener(_onUserContextChanged);
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      // ✅ במקרה של שגיאה - שולח ל-welcome (ברירת מחדל בטוחה)
      debugPrint('❌ שגיאה ב-IndexScreen._checkAndNavigate: $e');
      debugPrint('   ➡️ ניווט ל-WelcomeScreen (ברירת מחדל)');
      _hasNavigated = true;
      if (mounted) {
        final userContext = Provider.of<UserContext>(context, listen: false);
        userContext.removeListener(_onUserContextChanged);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    // ✅ ניקוי listener
    try {
      final userContext = Provider.of<UserContext>(context, listen: false);
      userContext.removeListener(_onUserContextChanged);
    } catch (e) {
      // אם כבר נמחק, לא נורא
    }
    super.dispose();
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
                label: AppStrings.index.logoLabel,
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
                  AppStrings.index.appName,
                  style: TextStyle(
                    fontSize: kFontSizeXLarge,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ),
              SizedBox(height: kSpacingSmallPlus),
              
              // Progress indicator עם accessibility
              Semantics(
                label: AppStrings.index.loadingLabel,
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                    SizedBox(height: kSpacingSmall),
                    Text(
                      AppStrings.index.loading,
                      style: TextStyle(
                        fontSize: kFontSizeSmall,
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
