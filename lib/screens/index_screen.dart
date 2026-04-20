// lib/screens/index_screen.dart — Index screen — auth routing: logged in→home, seen onboarding→login, else→welcome

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/user_context.dart';
import 'index_view.dart';
import 'welcome/welcome_screen.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  bool _hasNavigated = false; // מונע navigation כפול
  bool _hasError = false; // מצב שגיאה
  bool _listenerAdded = false; // עוקב אחרי הוספת listener
  bool _isChecking = false; // מונע בדיקות מקבילות
  Timer? _delayTimer; // Timer לביטול במקרה של dispose
  Timer? _syncTimeoutTimer; // ✅ Timeout למצב "תקוע" (Firebase מחובר, UserContext לא)
  DateTime? _waitingForSyncSince; // ✅ מתי התחלנו לחכות לסנכרון
  UserContext? _userContext; // ✅ שמור reference — בטוח לשימוש ב-dispose

  // ⏱️ קבועים
  static const _initialDelayMs = 600;
  static const _syncTimeoutSeconds = 8; // timeout לסנכרון Firebase↔UserContext

  @override
  void initState() {
    super.initState();

    // ⚡ טעינה אסינכרונית משופרת - delay חכם ל-Firebase Auth
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _userContext = Provider.of<UserContext>(context, listen: false);
      final userContext = _userContext!;

      // 🔧 אם Firebase כבר טעון - אין צורך ב-delay
      if (!userContext.isLoading) {
        _setupListener();
        return;
      }

      // ✅ הוסף listener מיידית - כדי לבטל את הטיימר אם הטעינה נגמרת מוקדם
      _setupListener();

      // ⏱️ Timer כ-fallback - רק למקרה שה-listener לא נורה
      _delayTimer = Timer(const Duration(milliseconds: _initialDelayMs), () {
        if (mounted && !_hasNavigated) {
          _checkAndNavigate();
        }
      });
    });
  }

  /// מגדיר listener ל-UserContext שיגיב לשינויים
  void _setupListener() {
    // Guard למניעת listener כפול
    if (_listenerAdded) return;

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
      // ✅ בטל את הטיימר - כבר קיבלנו עדכון מה-listener
      _delayTimer?.cancel();
      _checkAndNavigate();
    }
  }

  Future<void> _checkAndNavigate() async {
    // ✅ מניעת בדיקות מקבילות (race condition fix)
    if (_hasNavigated || _isChecking) return;
    _isChecking = true;

    try {
      // ✅ מקור אמת יחיד - UserContext!
      final userContext = Provider.of<UserContext>(context, listen: false);

      // 🔥 בדיקה נוספת: האם Firebase Auth מצביע על משתמש מחובר?
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

      // ⏳ אם UserContext עדיין טוען, נחכה
      if (userContext.isLoading) {
        _isChecking = false;
        return; // ה-listener יקרא לנו שוב כש-isLoading ישתנה
      }

      // אם Firebase Auth מצביע על משתמש אבל UserContext עדיין לא עדכן - נחכה
      if (firebaseUser != null && !userContext.isLoggedIn) {
        // ✅ התחל לעקוב אחרי זמן ההמתנה
        _waitingForSyncSince ??= DateTime.now();

        // ⏱️ בדוק timeout - אם חיכינו יותר מדי זמן, משהו תקוע
        final waitingSeconds =
            DateTime.now().difference(_waitingForSyncSince!).inSeconds;
        if (waitingSeconds >= _syncTimeoutSeconds) {
          // 🚨 Timeout! נסה לרענן את UserContext או הצג שגיאה
          _syncTimeoutTimer?.cancel();
          _syncTimeoutTimer = null;
          _isChecking = false;

          // ניסיון אחד לרענן
          try {
            await userContext.retry();
            if (!mounted) return;

            // אם עדיין לא מסתנכרן - הצג שגיאה
            if (!userContext.isLoggedIn) {
              setState(() => _hasError = true);
              return;
            }
          } catch (e) {
            if (mounted) setState(() => _hasError = true);
            return;
          }
        } else {
          // ✅ הגדר timeout timer אם עוד לא קיים
          _syncTimeoutTimer ??= Timer(
            Duration(seconds: _syncTimeoutSeconds - waitingSeconds),
            () {
              if (mounted && !_hasNavigated) {
                _checkAndNavigate();
              }
            },
          );
          _isChecking = false;
          return; // ה-listener יקרא לנו שוב כשה-UserContext יתעדכן
        }
      }

      // ✅ איפוס מעקב המתנה - כבר לא מחכים לסנכרון
      _waitingForSyncSince = null;
      _syncTimeoutTimer?.cancel();
      _syncTimeoutTimer = null;

      // ✅ מצב 1: משתמש מחובר → ישר לדף הבית
      if (userContext.isLoggedIn) {
        _hasNavigated = true;
        _isChecking = false;
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
      if (!mounted) {
        _isChecking = false;
        return;
      }

      final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

      if (!seenOnboarding) {
        // ✅ מצב 2: לא ראה welcome → שולח לשם
        _hasNavigated = true;
        _isChecking = false;
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
      _isChecking = false;
      userContext.removeListener(_onUserContextChanged);
      unawaited(navigator.pushReplacementNamed('/login'));
    } catch (e) {
      _isChecking = false;
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
    // איפוס מצב הטיימרים והמתנה
    _isChecking = false;
    _waitingForSyncSince = null;
    _delayTimer?.cancel();
    _delayTimer = null;
    _syncTimeoutTimer?.cancel();
    _syncTimeoutTimer = null;

    setState(() {
      _hasError = false;
      _hasNavigated = false;
    });
    _checkAndNavigate();
  }

  @override
  void dispose() {
    // 🔧 בטל Timers אם עדיין רצים
    _delayTimer?.cancel();
    _syncTimeoutTimer?.cancel();

    // ✅ ניקוי listener — משתמש ב-reference שנשמר (בטוח ב-dispose)
    if (_listenerAdded && _userContext != null) {
      _userContext!.removeListener(_onUserContextChanged);
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
