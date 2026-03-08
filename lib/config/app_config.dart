// 📄 lib/config/app_config.dart
//
// הגדרות סביבה לאפליקציה - development עם Emulators, production עם Firebase Cloud.
// כולל host דינמי לפי פלטפורמה ו-ports לכל שירות.
//
// 🔗 Related: Firebase, main.dart

import 'package:flutter/foundation.dart';

/// 🌍 סביבות האפליקציה
enum AppEnvironment {
  development, // פיתוח מקומי עם Emulators
  production, // ייצור עם Firebase Cloud
}

/// ⚙️ הגדרות האפליקציה
///
/// כל השדות static - אין צורך ליצור instance.
/// Constructor פרטי מונע יצירה בטעות.
class AppConfig {
  // מניעת יצירת instances
  AppConfig._();

  /// 🌍 סביבה נוכחית
  ///
  /// ✅ לוגיקה: Release בלבד = production, כל השאר = development
  /// (כולל Profile mode לבדיקת ביצועים)
  ///
  /// ניתן לדרוס עם: --dart-define=ENV=production
  static AppEnvironment get environment {
    // בדיקת override ידני מ-dart-define
    const envOverride = String.fromEnvironment('ENV');
    if (envOverride == 'production') return AppEnvironment.production;
    if (envOverride == 'development') return AppEnvironment.development;

    // ברירת מחדל: רק Release = production
    return kReleaseMode ? AppEnvironment.production : AppEnvironment.development;
  }

  /// 🔥 האם להשתמש ב-Emulators?
  static bool get useEmulators => environment == AppEnvironment.development;

  /// 🚀 האם אנחנו בסביבת production?
  static bool get isProduction => environment == AppEnvironment.production;

  /// 🛠️ האם אנחנו בסביבת development?
  static bool get isDevelopment => environment == AppEnvironment.development;

  /// 🖥️ Host לחיבור ל-Emulators
  /// Android Emulator רואה את localhost כ-10.0.2.2
  /// iOS Simulator ו-Web משתמשים ב-localhost
  /// 💡 למכשיר פיזי: החלף localhost ב-IP המקומי שלך
  static String get emulatorHost {
    if (kIsWeb) return 'localhost';
    if (defaultTargetPlatform == TargetPlatform.android) return '10.0.2.2';
    return 'localhost'; // iOS, macOS, Windows, Linux
  }

  // === Emulator Ports ===
  static const int authPort = 9099;
  static const int firestorePort = 8080;
  static const int storagePort = 9199;

  /// 📊 הדפסת הגדרות נוכחיות (לדיבאג)
  static void printConfig() {
    if (!kDebugMode) return;
    debugPrint('╔════════════════════════════════════════╗');
    debugPrint('║         🔧 App Configuration           ║');
    debugPrint('╠════════════════════════════════════════╣');
    debugPrint('║ Environment: ${environment.name.padRight(24)}║');
    debugPrint('║ Use Emulators: ${useEmulators.toString().padRight(22)}║');
    if (useEmulators) {
      debugPrint('║ Emulator Host: ${emulatorHost.padRight(22)}║');
      debugPrint('║ Auth Port: ${authPort.toString().padRight(26)}║');
      debugPrint('║ Firestore Port: ${firestorePort.toString().padRight(21)}║');
      debugPrint('║ Storage Port: ${storagePort.toString().padRight(23)}║');
    }
    debugPrint('╚════════════════════════════════════════╝');
  }
}
