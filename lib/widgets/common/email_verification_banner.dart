// 📄 lib/widgets/common/email_verification_banner.dart
//
// באנר שמוצג כשהמשתמש לא אימת את האימייל שלו.
// כולל כפתור לשליחת מייל אימות מחדש.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../providers/user_context.dart';
import '../../services/auth_service.dart';

/// באנר אימות אימייל — מוצג בראש דף הבית אם האימייל לא אומת
class EmailVerificationBanner extends StatelessWidget {
  const EmailVerificationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContext>();

    // לא מציג אם: לא מחובר, או אימייל מאומת, או Social Login (אין צורך)
    if (!userContext.isLoggedIn || userContext.isEmailVerified) {
      return const SizedBox.shrink();
    }

    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: kSpacingMedium,
        vertical: kSpacingSmall,
      ),
      padding: const EdgeInsets.all(kSpacingSmallPlus),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer,
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Row(
        children: [
          Icon(Icons.mark_email_unread_outlined, color: cs.onTertiaryContainer),
          const SizedBox(width: kSpacingSmall),
          Expanded(
            child: Text(
              AppStrings.auth.verifyEmailMessage,
              style: TextStyle(
                color: cs.onTertiaryContainer,
                fontSize: kFontSizeSmall,
              ),
            ),
          ),
          const SizedBox(width: kSpacingSmall),
          TextButton(
            onPressed: () async {
              unawaited(HapticFeedback.lightImpact());
              try {
                final authService = context.read<AuthService>();
                await authService.sendEmailVerification();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppStrings.auth.verificationEmailSent)),
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppStrings.auth.verificationEmailError(null))),
                  );
                }
              }
            },
            child: Text(AppStrings.auth.sendVerificationEmailButton),
          ),
        ],
      ),
    );
  }
}
