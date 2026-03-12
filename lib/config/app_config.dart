// 📄 lib/config/app_config.dart
//
// הגדרות סביבה לאפליקציה - development עם Emulators, production עם Firebase Cloud.
//
// 🔗 Related: Firebase, main.dart

import 'package:flutter/foundation.dart';

enum AppEnvironment { development, production }

class AppConfig {
  AppConfig._();

  /// 🌍 קביעת הסביבה: אם זה Release - תמיד Production.
  static AppEnvironment get environment {
    const env = String.fromEnvironment('ENV', defaultValue: '');
    if (env == 'production' || kReleaseMode) return AppEnvironment.production;
    return AppEnvironment.development;
  }

  /// 🔥 הפעלת אמולטורים רק אם אנחנו ב-Dev ושלחנו דגל מתאים בהרצה
  /// פקודה: flutter run --dart-define=USE_EMULATORS=true
  static bool get useEmulators {
    if (kReleaseMode) return false; // אבטחה: לעולם לא באפליקציה שבחנות
    return const bool.fromEnvironment('USE_EMULATORS', defaultValue: false);
  }

  static bool get isProduction => environment == AppEnvironment.production;
  static bool get isDevelopment => environment == AppEnvironment.development;

  /// 🖥️ Host לחיבור ל-Emulators (אנדרואיד רואה localhost כ-10.0.2.2)
  static String get emulatorHost {
    if (kIsWeb) return 'localhost';
    return (defaultTargetPlatform == TargetPlatform.android) ? '10.0.2.2' : 'localhost';
  }

  // === Emulator Ports ===
  static const int authPort = 9099;
  static const int firestorePort = 8080;
  static const int storagePort = 9199;

  /// 📊 הדפסת הגדרות נוכחיות (לדיבאג)
  static void printConfig() {
    if (!kDebugMode) return;
    debugPrint('--- ⚙️ MEMOZAP CONFIG ---');
    debugPrint('📍 MODE: ${environment.name.toUpperCase()}');
    debugPrint('🧪 EMULATORS: ${useEmulators ? "ACTIVE (Host: $emulatorHost)" : "OFF"}');
    debugPrint('-------------------------');
  }
}
