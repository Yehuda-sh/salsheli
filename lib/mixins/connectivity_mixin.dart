// 📄 File: lib/mixins/connectivity_mixin.dart
// 🎯 Purpose: Mixin לניטור מצב חיבור לאינטרנט
//
// 📋 Features:
// - האזנה לשינויי חיבור דרך ConnectivityProvider (מקור אמת יחיד!)
// - callback לשינויים (onConnectivityChanged)
// - אין subscription כפול - רק מאזין ל-Provider
// - משוב Haptic בשינויי סטטוס
// - מנגנון חסין שגיאות ב-didChangeDependencies
// - תמיכה ב-unawaited לביצועים
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
// 📝 Version: 3.0 (Hybrid Premium)
// 📅 Updated: 22/02/2026

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// 🌐 Mixin לניטור מצב חיבור לאינטרנט
///
/// ✅ גרסה 3.0 (Hybrid Premium):
/// - מאזין ל-ConnectivityProvider (מקור אמת יחיד!)
/// - משוב Haptic בשינויי סטטוס (heavy לניתוק, medium לחזרה)
/// - מנגנון חסין שגיאות ב-didChangeDependencies
/// - unawaited לקריאות Haptic לביצועים אופטימליים
///
/// מספק:
/// - [isOffline] - האם אין חיבור (מ-Provider)
/// - [isOnline] - האם יש חיבור (מ-Provider)
/// - [onConnectivityChanged] - callback לשינויים (לדריסה)
///
/// הערות:
/// - עובד אוטומטית! אין צורך לקרוא initConnectivity()
/// - דורש ConnectivityProvider ב-widget tree
/// - ב-Overlay ויזואלי עתידי: להשתמש ב-withValues(alpha: ...) לשקיפות
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
          '❌ ConnectivityMixin ERROR: ConnectivityProvider לא נמצא!\n'
          '   ודא שהוא זמין ב-widget tree.\n'
          '   Widget: $T\n'
          '   Error: $e',
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

      // 📳 משוב Haptic - heavy לניתוק (התראה), medium לחזרה
      if (currentIsOffline) {
        unawaited(HapticFeedback.heavyImpact());
      } else {
        unawaited(HapticFeedback.mediumImpact());
      }

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

  /// סוג החיבור הנוכחי (לדיבאג)
  List<ConnectivityResult> _lastResults = [];

  /// האם אין חיבור
  bool get isOffline => _isOffline;

  /// האם יש חיבור
  bool get isOnline => !_isOffline;

  /// אתחול ניטור
  ///
  /// ✅ כולל guard למניעת אתחול כפול
  /// ✅ מחזיר Result ראשוני מיד (await) לפני האזנה ל-Stream
  ///    כדי למנוע "שטח מת" (Blank state) בשניות הראשונות
  Future<void> init() async {
    // 🛡️ Guard: אל תאתחל פעמיים
    if (_subscription != null) return;

    // בדיקה ראשונית - await כדי לקבל תוצאה מיידית
    await _checkConnectivity();

    // האזנה לשינויים (רק אחרי שיש לנו מצב ראשוני)
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
        debugPrint('❌ ConnectivityProvider: שגיאה בבדיקת חיבור - $e');
      }
    }
  }

  void _handleChange(List<ConnectivityResult> results) {
    _lastResults = results;

    // ✅ אין חיבור אם הרשימה ריקה או כל הערכים הם none
    final hasNoConnection = results.isEmpty ||
        results.every((r) => r == ConnectivityResult.none);

    if (_isOffline != hasNoConnection) {
      _isOffline = hasNoConnection;
      notifyListeners();

      if (kDebugMode) {
        final connectionTypes = _lastResults
            .where((r) => r != ConnectivityResult.none)
            .map(_connectionTypeLabel)
            .join(', ');

        debugPrint(
          _isOffline
            ? '📡 ConnectivityProvider: אין חיבור (results: $results)'
            : '✅ ConnectivityProvider: יש חיבור [$connectionTypes]',
        );
      }
    }
  }

  /// תיאור סוג חיבור בעברית (לדיבאג)
  String _connectionTypeLabel(ConnectivityResult result) {
    return switch (result) {
      ConnectivityResult.wifi => 'WiFi',
      ConnectivityResult.mobile => 'Mobile',
      ConnectivityResult.ethernet => 'Ethernet',
      ConnectivityResult.bluetooth => 'Bluetooth',
      ConnectivityResult.vpn => 'VPN',
      ConnectivityResult.other => 'Other',
      ConnectivityResult.none => 'None',
    };
  }

  /// בדיקת חיבור ידנית
  Future<void> refresh() => _checkConnectivity();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
