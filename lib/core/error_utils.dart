// 📄 lib/core/error_utils.dart
//
// 🎯 המרת שגיאות טכניות להודעות ידידותיות למשתמש.
// ✅ מונע חשיפת מידע טכני פנימי (Firebase errors, stack traces).
//
// 🔗 Related: All screens that catch exceptions and show SnackBars

import 'package:flutter/foundation.dart';

import '../l10n/app_strings.dart';

/// ממיר exception להודעה ידידותית למשתמש.
///
/// בdebug — גם מדפיס את הdetails לconsole.
/// בproduction — מחזיר הודעה גנרית בלבד.
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
