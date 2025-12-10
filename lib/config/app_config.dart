// 📄 File: lib/config/app_config.dart
// 🎯 Purpose: הגדרות סביבה לאפליקציה (Development/Production)
//
// 📋 Features:
// - הגדרת סביבה (development/production)
// - הגדרות חיבור ל-Firebase Emulators
// - host דינמי לפי פלטפורמה (Android/iOS/Web)
//
// 📝 Version: 1.0
// 📅 Created: 04/12/2025

import 'dart:io';
import 'package:flutter/foundation.dart';

/// 🌍 סביבות האפליקציה
enum AppEnvironment {
  development, // פיתוח מקומי עם Emulators
  production,  // ייצור עם Firebase Cloud
}

/// ⚙️ הגדרות האפליקציה
class AppConfig {
  // === Singleton ===
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  /// 🌍 סביבה נוכחית
  /// ב-debug mode → development (Emulators)
  /// ב-release mode → production (Cloud)
  static AppEnvironment get environment =>
      kDebugMode ? AppEnvironment.development : AppEnvironment.production;

  /// 🔥 האם להשתמש ב-Emulators?
  static bool get useEmulators => environment == AppEnvironment.development;

  /// 🖥️ Host לחיבור ל-Emulators
  /// Android Emulator רואה את localhost כ-10.0.2.2
  /// iOS Simulator ו-Web משתמשים ב-localhost
  static String get emulatorHost {
    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost'; // iOS, macOS, Windows, Linux
  }

  // === Emulator Ports ===
  static const int authPort = 9099;
  static const int firestorePort = 8080;
  static const int storagePort = 9199;

  /// 📊 הדפסת הגדרות נוכחיות (לדיבאג)
  static void printConfig() {
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
