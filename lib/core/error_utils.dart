// lib/core/error_utils.dart — Error formatting — userFriendlyError() converts Firebase/network errors to Hebrew messages

import 'package:flutter/foundation.dart';

import '../l10n/app_strings.dart';

/// ממיר exception להודעה ידידותית למשתמש.
///
/// מסווג שגיאות נפוצות (רשת/הרשאה/לא נמצא) להודעה תואמת מ-AppStrings,
/// ואם אין התאמה מחזיר הודעת שגיאה גנרית.
/// בdebug — גם מדפיס את הdetails לconsole.
///
/// ```dart
/// } catch (e) {
///   messenger.showSnackBar(SnackBar(content: Text(userFriendlyError(e))));
/// }
/// ```
String userFriendlyError(dynamic error, {String? context}) {
  // 🔍 Debug: log full error for developers
  if (kDebugMode) {
    debugPrint('⚠️ ${context ?? 'Error'}: $error');
  }

  final msg = error.toString().toLowerCase();

  // 🌐 Network errors
  if (msg.contains('network') ||
      msg.contains('connection') ||
      msg.contains('socket') ||
      msg.contains('timeout') ||
      msg.contains('unavailable')) {
    return AppStrings.common.networkError;
  }

  // 🔒 Permission errors
  if (msg.contains('permission') || msg.contains('unauthorized') || msg.contains('unauthenticated')) {
    return AppStrings.common.permissionError;
  }

  // 📦 Not found
  if (msg.contains('not-found') || msg.contains('not found')) {
    return AppStrings.common.notFoundError;
  }

  // 🔄 Generic fallback
  return AppStrings.common.unknownErrorGeneric;
}
