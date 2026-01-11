// 📄 File: lib/mixins/connectivity_mixin.dart
// 🎯 Purpose: Mixin לניטור מצב חיבור לאינטרנט
//
// 📋 Features:
// - האזנה לשינויי חיבור
// - בדיקת חיבור ידנית
// - ניקוי אוטומטי ב-dispose
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
// }
// ```
//
// 📝 Version: 1.0
// 📅 Created: 01/2026

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 🌐 Mixin לניטור מצב חיבור לאינטרנט
///
/// מספק:
/// - [isOffline] - האם אין חיבור
/// - [isOnline] - האם יש חיבור
/// - [checkConnectivity] - בדיקה ידנית
/// - [onConnectivityChanged] - callback לשינויים (לדריסה)
///
/// הערות:
/// - יש לקרוא ל-initConnectivity() ב-initState
/// - ניקוי אוטומטי של subscription ב-dispose
mixin ConnectivityMixin<T extends StatefulWidget> on State<T> {
  /// Connectivity instance
  final Connectivity _connectivity = Connectivity();

  /// Subscription לשינויי חיבור
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// מצב חיבור נוכחי
  bool _isOffline = false;

  /// האם אין חיבור לאינטרנט
  bool get isOffline => _isOffline;

  /// האם יש חיבור לאינטרנט
  bool get isOnline => !_isOffline;

  /// אתחול ניטור החיבור
  ///
  /// יש לקרוא ל-method זו ב-initState:
  /// ```dart
  /// @override
  /// void initState() {
  ///   super.initState();
  ///   initConnectivity();
  /// }
  /// ```
  @protected
  void initConnectivity() {
    // בדיקה ראשונית
    checkConnectivity();

    // האזנה לשינויים
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
    );
  }

  /// בדיקת מצב החיבור
  @protected
  Future<void> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _handleConnectivityChange(results);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ConnectivityMixin: שגיאה בבדיקת חיבור - $e');
      }
      // במקרה של שגיאה, נניח שיש חיבור
      _updateConnectivityState(false);
    }
  }

  /// טיפול בשינוי מצב חיבור
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final wasOffline = _isOffline;

    // אם אין תוצאות או יש רק none - אין חיבור
    final hasNoConnection = results.isEmpty ||
        (results.length == 1 && results.first == ConnectivityResult.none);

    _updateConnectivityState(hasNoConnection);

    // קריאה ל-callback אם השתנה המצב
    if (wasOffline != _isOffline) {
      onConnectivityChanged(isOnline);
    }
  }

  /// עדכון מצב החיבור
  void _updateConnectivityState(bool offline) {
    if (_isOffline != offline) {
      if (mounted) {
        setState(() {
          _isOffline = offline;
        });
      } else {
        _isOffline = offline;
      }

      if (kDebugMode) {
        debugPrint(
          offline
            ? '📡 ConnectivityMixin: אין חיבור לאינטרנט'
            : '✅ ConnectivityMixin: יש חיבור לאינטרנט'
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
    _connectivitySubscription?.cancel();
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
  Future<void> init() async {
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
    final hasNoConnection = results.isEmpty ||
        (results.length == 1 && results.first == ConnectivityResult.none);

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
