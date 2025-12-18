// 📄 File: lib/core/app_logger.dart
// 🎯 Purpose: מנגנון logging מרכזי לאפליקציה
//
// 📋 Usage:
//   AppLogger.info('message');      // מידע רגיל (מושתק ב-production)
//   AppLogger.debug('message');     // דיבוג מפורט (מושתק ב-production)
//   AppLogger.warning('message');   // אזהרה (תמיד מוצג)
//   AppLogger.error('message', e);  // שגיאה (תמיד מוצג)
//
// 📝 Version: 1.0
// 📅 Created: 18/12/2025

import 'package:flutter/foundation.dart';

/// רמות לוגינג
enum LogLevel {
  /// ללא לוגים
  none,

  /// רק שגיאות
  error,

  /// שגיאות + אזהרות
  warning,

  /// שגיאות + אזהרות + מידע חשוב
  info,

  /// הכל (כולל דיבוג מפורט)
  debug,
}

/// מנגנון logging מרכזי
class AppLogger {
  AppLogger._();

  /// רמת הלוגינג הנוכחית
  /// ב-debug mode: info (לא debug כדי לצמצם רעש)
  /// ב-release mode: warning בלבד
  static LogLevel currentLevel = kDebugMode ? LogLevel.info : LogLevel.warning;

  /// האם להציג timestamp
  static bool showTimestamp = false;

  /// האם להציג את שם הקובץ/מחלקה
  static bool showSource = true;

  // ============================================================
  // LOGGING METHODS
  // ============================================================

  /// לוג שגיאה - תמיד מוצג
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (currentLevel.index >= LogLevel.error.index) {
      _log('❌', message, error: error, stackTrace: stackTrace);
    }
  }

  /// לוג אזהרה - מוצג ברמה warning ומעלה
  static void warning(String message, [dynamic error]) {
    if (currentLevel.index >= LogLevel.warning.index) {
      _log('⚠️', message, error: error);
    }
  }

  /// לוג מידע חשוב - מוצג ברמה info ומעלה
  static void info(String message) {
    if (currentLevel.index >= LogLevel.info.index) {
      _log('ℹ️', message);
    }
  }

  /// לוג דיבוג מפורט - מוצג רק ברמה debug
  static void debug(String message) {
    if (currentLevel.index >= LogLevel.debug.index) {
      _log('🔍', message);
    }
  }

  /// לוג הצלחה - מוצג ברמה info ומעלה
  static void success(String message) {
    if (currentLevel.index >= LogLevel.info.index) {
      _log('✅', message);
    }
  }

  // ============================================================
  // SPECIALIZED LOGS
  // ============================================================

  /// לוג Firebase/Network
  static void network(String message) {
    if (currentLevel.index >= LogLevel.debug.index) {
      _log('🌐', message);
    }
  }

  /// לוג Authentication
  static void auth(String message) {
    if (currentLevel.index >= LogLevel.info.index) {
      _log('🔐', message);
    }
  }

  /// לוג Navigation
  static void nav(String message) {
    if (currentLevel.index >= LogLevel.debug.index) {
      _log('🧭', message);
    }
  }

  // ============================================================
  // INTERNAL
  // ============================================================

  static void _log(
    String emoji,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    final buffer = StringBuffer();

    if (showTimestamp) {
      final now = DateTime.now();
      buffer.write('[${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}] ');
    }

    buffer.write('$emoji $message');

    if (error != null) {
      buffer.write('\n   Error: $error');
    }

    debugPrint(buffer.toString());

    if (stackTrace != null && currentLevel == LogLevel.debug) {
      debugPrintStack(stackTrace: stackTrace, maxFrames: 5);
    }
  }

  // ============================================================
  // CONFIGURATION
  // ============================================================

  /// הגדרת רמת לוגינג
  static void setLevel(LogLevel level) {
    currentLevel = level;
    info('Log level set to: ${level.name}');
  }

  /// השתקת כל הלוגים
  static void mute() {
    currentLevel = LogLevel.none;
  }

  /// הפעלת לוגים מלאים (לדיבוג)
  static void verbose() {
    currentLevel = LogLevel.debug;
  }
}
