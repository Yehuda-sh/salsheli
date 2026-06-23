// lib/screens/auth/widgets/auth_error_dialog.dart — TEMP diagnostic — show raw auth error on screen

import 'package:flutter/material.dart';

/// ⚠️ אבחון זמני בלבד.
/// מציג את השגיאה הגולמית על המסך כדי שנוכל לראות את הסיבה האמיתית
/// (cause) בגרסה מופצת (App Distribution), שבה לוגים של דיבאג מושתקים.
/// **להסיר אחרי שאיתרנו את הבעיה.**
Future<void> showAuthErrorDetails(BuildContext context, Object error) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('שגיאת התחברות (אבחון)'),
      content: SingleChildScrollView(
        child: SelectableText(error.toString()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('סגור'),
        ),
      ],
    ),
  );
}
