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
// ⚠️ Critical Changes (20/11/2025):
// - 🔧 Fixed Race Condition: Now checks Firebase Auth directly to detect if user is logged in
//   but UserContext hasn't synced yet. Waits for UserContext to update before navigating.
// - 🐛 Previous issue: User would land on WelcomeScreen despite being logged in because
//   _checkAndNavigate() ran before UserContext.isLoggedIn became true

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/user_context.dart';
import 'index_view.dart';
import 'welcome_screen.dart';

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

    // ⚡ טעינה אסינכרונית משופרת - delay חכם ל-Firebase Auth
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final userContext = Provider.of<UserContext>(context, listen: false);

      // 🔧 אם Firebase כבר טעון - אין צורך ב-delay
      if (!userContext.isLoading) {
        _setupListener();
        return;
      }

      // ⏱️ אחרת - המתן עד 600ms לתת ל-Firebase זמן
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
    if (!_hasNavigated && mounted) {
      _checkAndNavigate();
    }
  }

  Future<void> _checkAndNavigate() async {
    if (_hasNavigated) return; // כבר ניווטנו

    try {
      // ✅ מקור אמת יחיד - UserContext!
      final userContext = Provider.of<UserContext>(context, listen: false);

      // 🔥 בדיקה נוספת: האם Firebase Auth מצביע על משתמש מחובר?
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

      // ⏳ אם UserContext עדיין טוען, נחכה
      if (userContext.isLoading) {
        return; // ה-listener יקרא לנו שוב כש-isLoading ישתנה
      }

      // 🔧 FIX: אם Firebase Auth מצביע על משתמש אבל UserContext עדיין לא עדכן - נחכה!
      if (firebaseUser != null && !userContext.isLoggedIn) {
        return; // ה-listener יקרא לנו שוב כשה-UserContext יתעדכן
      }

      // ✅ מצב 1: משתמש מחובר → ישר לדף הבית
      if (userContext.isLoggedIn) {
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

      if (!seenOnboarding) {
        // ✅ מצב 2: לא ראה welcome → שולח לשם
        _hasNavigated = true;
        userContext.removeListener(_onUserContextChanged);
        unawaited(
          navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          ),
        );
        return;
      }

      // ✅ מצב 3: ראה welcome אבל לא מחובר → שולח ל-login
      _hasNavigated = true;
      userContext.removeListener(_onUserContextChanged);
      unawaited(navigator.pushReplacementNamed('/login'));
    } catch (e) {
      // ✅ במקרה של שגיאה - הצג מסך שגיאה
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  /// retry לאחר שגיאה
  void _retry() {
    setState(() {
      _hasError = false;
      _hasNavigated = false;
    });
    _checkAndNavigate();
  }

  @override
  void dispose() {
    // 🔧 בטל Timer אם עדיין רץ
    _delayTimer?.cancel();

    // ✅ ניקוי listener - רק אם הוסף
    if (_listenerAdded) {
      try {
        final userContext = Provider.of<UserContext>(context, listen: false);
        userContext.removeListener(_onUserContextChanged);
      } catch (e) {
        // Silent failure - widget already disposed
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
