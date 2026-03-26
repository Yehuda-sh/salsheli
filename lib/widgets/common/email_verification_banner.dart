// 📄 lib/widgets/common/email_verification_banner.dart
//
// באנר שמוצג כשהמשתמש לא אימת את האימייל שלו.
// כולל כפתור לשליחת מייל אימות מחדש.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:provider/provider.dart';

import '../../core/error_utils.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../providers/user_context.dart';
import '../../services/auth_service.dart';

/// באנר אימות אימייל — מוצג בראש דף הבית אם האימייל לא אומת
class EmailVerificationBanner extends StatefulWidget {
  const EmailVerificationBanner({super.key});

  @override
  State<EmailVerificationBanner> createState() => _EmailVerificationBannerState();
}

class _EmailVerificationBannerState extends State<EmailVerificationBanner> {
  bool _isSending = false;

  Future<void> _sendVerification() async {
    if (_isSending) return;
    setState(() => _isSending = true);

    unawaited(HapticFeedback.lightImpact());
    try {
      await context.read<AuthService>().sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.auth.verificationEmailSent)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFriendlyError(e, context: 'email_verification'))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContext>();

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
            onPressed: _isSending ? null : _sendVerification,
            child: _isSending
                ? SizedBox(
                    width: kIconSizeSmall,
                    height: kIconSizeSmall,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.onTertiaryContainer,
                    ),
                  )
                : Text(AppStrings.auth.sendVerificationEmailButton),
          ),
        ],
      ),
    );
  }
}
