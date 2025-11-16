// 📄 File: lib/screens/index_screen.dart - V4.0 LOGIC-ONLY
// 🎯 Purpose: מסך פתיחה ראשוני - Splash screen שבודק מצב משתמש ומנווט למסך המתאים
//
// ✨ שיפור מבני (v4.0):
// - 🧹 Separation of Concerns: הפרדת לוגיקה מעיצוב
// - 📁 View Components: כל האנימציות ב-index_view.dart
// - 🎯 Logic Only: קובץ זה מכיל רק את ההחלטות והניווט
//
// 📋 Flow Logic (עודכן 09/10/2025):
// 1. משתמש מחובר (UserContext.isLoggedIn)? → /home (ישר לאפליקציה)
// 2. לא מחובר + לא ראה onboarding? → WelcomeScreen (הצגת יתרונות)
// 3. לא מחובר + ראה onboarding? → /login (התחברות)
//
// 🔗 Related:
// - index_view.dart - מרכיבים חזותיים (אנימציות)
// - UserContext - מקור האמת היחיד למצב משתמש (Firebase Auth)
// - WelcomeScreen - מסך קבלת פנים ראשוני
// - LoginScreen - מסך התחברות (/login)
// - MainNavigationScreen - מסך ראשי עם ניווט (/home)
// - SharedPreferences - אחסון seenOnboarding (מקומי בלבד)
//
// 💡 Features:
// - Single Source of Truth - UserContext בלבד (לא SharedPreferences.userId!)
// - Real-time sync - מגיב לשינויים ב-Firebase Auth אוטומטית
// - Wait for initial load - ממתין עד ש-Firebase מסיים לטעון
// - Error handling עם fallback
// - Logging מפורט
//
// ⚠️ Critical Changes (14/10/2025):
// - ⏱️ Fixed Race Condition: 600ms delay before navigation check (allows Firebase Auth to load)

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/user_context.dart';
import 'index_view.dart';
import 'welcome_screen.dart';

// 🔧 Wrapper ללוגים - פועל רק ב-debug mode
void _log(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  bool _hasNavigated = false; // מונע navigation כפול
  bool _hasError = false; // מצב שגיאה
  bool _listenerAdded = false; // עוקב אחרי הוספת listener
  Timer? _delayTimer; // Timer לביטול במקרה של dispose

  @override
  void initState() {
    super.initState();
    _log('🚀 IndexScreen.initState() - מתחיל Splash Screen');

    // ⚡ טעינה אסינכרונית משופרת - delay חכם ל-Firebase Auth
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final userContext = Provider.of<UserContext>(context, listen: false);

      // 🔧 אם Firebase כבר טעון - אין צורך ב-delay
      if (!userContext.isLoading) {
        _log('   ⚡ Firebase כבר טעון - מדלג על delay');
        _setupListener();
        return;
      }

      // ⏱️ אחרת - המתן עד 600ms לתת ל-Firebase זמן
      _log('   ⏳ Firebase טוען - ממתין עד 600ms');
      _delayTimer = Timer(const Duration(milliseconds: 600), () {
        if (mounted) {
          _setupListener();
        }
      });
    });
  }

  /// מגדיר listener ל-UserContext שיגיב לשינויים
  void _setupListener() {
    final userContext = Provider.of<UserContext>(context, listen: false);

    // ✅ האזן לשינויים ב-UserContext
    userContext.addListener(_onUserContextChanged);
    _listenerAdded = true; // 🔧 מסמן שהוספנו listener

    // ✅ בדוק מיידית אם כבר נטען
    _checkAndNavigate();
  }

  /// מופעל כל פעם ש-UserContext משתנה
  void _onUserContextChanged() {
    _log('👂 IndexScreen: UserContext השתנה');
    if (!_hasNavigated && mounted) {
      _checkAndNavigate();
    }
  }

  Future<void> _checkAndNavigate() async {
    if (_hasNavigated) return; // כבר ניווטנו

    _log('\n🏗️ IndexScreen._checkAndNavigate() - מתחיל...');

    try {
      // ✅ מקור אמת יחיד - UserContext!
      final userContext = Provider.of<UserContext>(context, listen: false);

      _log('   📊 UserContext state:');
      _log('      isLoggedIn: ${userContext.isLoggedIn}');
      _log('      user: ${userContext.user?.email ?? "null"}');
      _log('      isLoading: ${userContext.isLoading}');

      // ⏳ אם UserContext עדיין טוען, נחכה
      if (userContext.isLoading) {
        _log('   ⏳ UserContext טוען, ממתין לסיום...');
        return; // ה-listener יקרא לנו שוב כש-isLoading ישתנה
      }

      // ✅ מצב 1: משתמש מחובר → ישר לדף הבית
      if (userContext.isLoggedIn) {
        _log('   ✅ משתמש מחובר (${userContext.userEmail}) → ניווט ל-/home');
        _hasNavigated = true;
        if (mounted) {
          // הסר את ה-listener לפני ניווט
          userContext.removeListener(_onUserContextChanged);
          unawaited(Navigator.of(context).pushReplacementNamed('/home'));
        }
        return;
      }

      // 🔒 Capture navigator BEFORE any await (prevents crashes if widget disposed during await)
      final navigator = Navigator.of(context);

      // ✅ מצב 2-3: לא מחובר → בודק אם ראה welcome
      // (seenOnboarding נשאר מקומי - לא צריך sync בין מכשירים)
      final prefs = await SharedPreferences.getInstance();

      // Check mounted after await
      if (!mounted) return;

      final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
      _log('   📋 seenOnboarding (local): $seenOnboarding');

      if (!seenOnboarding) {
        // ✅ מצב 2: לא ראה welcome → שולח לשם
        _log('   ➡️ לא ראה onboarding → ניווט ל-WelcomeScreen');
        _hasNavigated = true;
        userContext.removeListener(_onUserContextChanged);
        unawaited(navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        ));
        return;
      }

      // ✅ מצב 3: ראה welcome אבל לא מחובר → שולח ל-login
      _log('   ➡️ ראה onboarding אבל לא מחובר → ניווט ל-/login');
      _hasNavigated = true;
      userContext.removeListener(_onUserContextChanged);
      unawaited(navigator.pushReplacementNamed('/login'));
    } catch (e) {
      // ✅ במקרה של שגיאה - הצג מסך שגיאה
      _log('❌ שגיאה ב-IndexScreen._checkAndNavigate: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  /// retry לאחר שגיאה
  void _retry() {
    _log('🔄 IndexScreen: retry לאחר שגיאה');
    setState(() {
      _hasError = false;
      _hasNavigated = false;
    });
    _checkAndNavigate();
  }

  @override
  void dispose() {
    _log('🗑️ IndexScreen.dispose()');

    // 🔧 בטל Timer אם עדיין רץ
    _delayTimer?.cancel();

    // ✅ ניקוי listener - רק אם הוסף
    if (_listenerAdded) {
      try {
        final userContext = Provider.of<UserContext>(context, listen: false);
        userContext.removeListener(_onUserContextChanged);
      } catch (e) {
        _log('⚠️ שגיאה בהסרת listener: $e');
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 הצגת המסך המתאים - לוגיקה פשוטה!
    if (_hasError) {
      return IndexErrorView(onRetry: _retry);
    }

    return const IndexLoadingView();
  }
}
