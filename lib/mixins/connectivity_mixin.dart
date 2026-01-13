// 📄 File: lib/mixins/connectivity_mixin.dart
// 🎯 Purpose: Mixin לניטור מצב חיבור לאינטרנט
//
// 📋 Features:
// - האזנה לשינויי חיבור דרך ConnectivityProvider (מקור אמת יחיד!)
// - callback לשינויים (onConnectivityChanged)
// - אין subscription כפול - רק מאזין ל-Provider
//
// 📝 Usage:
// ```dart
// class MyScreen extends StatefulWidget { ... }
// class _MyScreenState extends State<MyScreen> with ConnectivityMixin {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         OfflineBanner(isOffline: isOffline),
//         // ...rest of content
//       ],
//     );
//   }
//
//   @override
//   void onConnectivityChanged(bool isOnline) {
//     if (isOnline) _syncData();
//   }
// }
// ```
//
// ⚠️ דרישות:
// - ConnectivityProvider חייב להיות זמין ב-widget tree
// - אין צורך לקרוא initConnectivity() - עובד אוטומטית!
//
// 📝 Version: 2.0 (refactored to use Provider)
// 📅 Updated: 01/2026

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// 🌐 Mixin לניטור מצב חיבור לאינטרנט
///
/// ✅ גרסה 2.0: מאזין ל-ConnectivityProvider (מקור אמת יחיד!)
/// אין subscription כפול - רק delegate ל-Provider.
///
/// מספק:
/// - [isOffline] - האם אין חיבור (מ-Provider)
/// - [isOnline] - האם יש חיבור (מ-Provider)
/// - [onConnectivityChanged] - callback לשינויים (לדריסה)
///
/// הערות:
/// - עובד אוטומטית! אין צורך לקרוא initConnectivity()
/// - דורש ConnectivityProvider ב-widget tree
mixin ConnectivityMixin<T extends StatefulWidget> on State<T> {
  /// רפרנס ל-Provider (נשמר לניקוי listener)
  ConnectivityProvider? _provider;

  /// מצב חיבור קודם (לזיהוי שינויים)
  bool? _previousIsOffline;

  /// האם אין חיבור לאינטרנט
  bool get isOffline => _provider?.isOffline ?? false;

  /// האם יש חיבור לאינטרנט
  bool get isOnline => !isOffline;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupProviderListener();
  }

  /// 🔗 התחברות ל-ConnectivityProvider
  void _setupProviderListener() {
    // הסר listener קודם אם קיים
    _provider?.removeListener(_onProviderChanged);

    // קבל את ה-Provider (listen: false כי אנחנו מאזינים ידנית)
    try {
      _provider = context.read<ConnectivityProvider>();
      _provider!.addListener(_onProviderChanged);

      // אתחול ראשוני
      _previousIsOffline ??= _provider!.isOffline;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ ConnectivityMixin: ConnectivityProvider לא נמצא! '
          'ודא שהוא זמין ב-widget tree.',
        );
      }
    }
  }

  /// 📡 טיפול בשינוי מצב ב-Provider
  void _onProviderChanged() {
    if (!mounted) return;

    final currentIsOffline = _provider?.isOffline ?? false;

    // בדוק אם השתנה המצב
    if (_previousIsOffline != currentIsOffline) {
      _previousIsOffline = currentIsOffline;

      // עדכן UI
      setState(() {});

      // קרא ל-callback
      onConnectivityChanged(!currentIsOffline);

      if (kDebugMode) {
        debugPrint(
          currentIsOffline
              ? '📡 ConnectivityMixin: אין חיבור לאינטרנט'
              : '✅ ConnectivityMixin: יש חיבור לאינטרנט',
        );
      }
    }
  }

  /// Callback כאשר מצב החיבור משתנה
  ///
  /// ניתן לדרוס method זו כדי לטפל בשינויי חיבור:
  /// ```dart
  /// @override
  /// void onConnectivityChanged(bool isOnline) {
  ///   if (isOnline) {
  ///     // חזר החיבור - לסנכרן נתונים
  ///     _syncData();
  ///   }
  /// }
  /// ```
  @protected
  void onConnectivityChanged(bool isOnline) {
    // ברירת מחדל - לא עושה כלום
    // ניתן לדרוס ב-State
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderChanged);
    super.dispose();
  }
}

/// 🔌 Provider לניטור חיבור ברמת האפליקציה
///
/// משמש לניטור חיבור גלובלי שזמין לכל המסכים.
///
/// Usage:
/// ```dart
/// // ב-main.dart:
/// ChangeNotifierProvider(
///   create: (_) => ConnectivityProvider()..init(),
///   child: MyApp(),
/// )
///
/// // בכל מסך:
/// final connectivity = context.watch<ConnectivityProvider>();
/// if (connectivity.isOffline) {
///   // הצג הודעה
/// }
/// ```
class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isOffline = false;

  /// האם אין חיבור
  bool get isOffline => _isOffline;

  /// האם יש חיבור
  bool get isOnline => !_isOffline;

  /// אתחול ניטור
  ///
  /// ✅ כולל guard למניעת אתחול כפול
  Future<void> init() async {
    // 🛡️ Guard: אל תאתחל פעמיים
    if (_subscription != null) return;

    // בדיקה ראשונית
    await _checkConnectivity();

    // האזנה לשינויים
    _subscription = _connectivity.onConnectivityChanged.listen(
      _handleChange,
    );
  }

  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _handleChange(results);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ConnectivityProvider: שגיאה - $e');
      }
    }
  }

  void _handleChange(List<ConnectivityResult> results) {
    // ✅ אין חיבור אם הרשימה ריקה או כל הערכים הם none
    final hasNoConnection = results.isEmpty ||
        results.every((r) => r == ConnectivityResult.none);

    if (_isOffline != hasNoConnection) {
      _isOffline = hasNoConnection;
      notifyListeners();

      if (kDebugMode) {
        debugPrint(
          _isOffline
            ? '📡 ConnectivityProvider: אין חיבור'
            : '✅ ConnectivityProvider: יש חיבור'
        );
      }
    }
  }

  /// בדיקת חיבור ידנית
  Future<void> refresh() => _checkConnectivity();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
