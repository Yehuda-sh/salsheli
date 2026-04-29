// lib/widgets/common/email_verification_banner.dart — Email verification banner — dismissible per-user prompt to verify email

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:provider/provider.dart';

import '../../core/error_utils.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../providers/user_context.dart';
import '../../services/auth_service.dart';

/// באנר אימות אימייל — קומפקטי, ניתן לסגירה, מוצג אחרי הברכה
class EmailVerificationBanner extends StatefulWidget {
  const EmailVerificationBanner({super.key});

  @override
  State<EmailVerificationBanner> createState() => _EmailVerificationBannerState();
}

class _EmailVerificationBannerState extends State<EmailVerificationBanner>
    with WidgetsBindingObserver {
  bool _isSending = false;
  // In-memory only — banner returns on next cold start, so an accidental
  // X tap never silently buries the prompt for hours.
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// כשהאפליקציה חוזרת מ-background — reload user לבדוק אם אימת
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isDismissed) {
      _checkIfVerified();
    }
  }

  Future<void> _checkIfVerified() async {
    // Already verified — banner is hidden, no need to refetch.
    if (context.read<UserContext>().isEmailVerified) return;

    try {
      await context.read<AuthService>().reloadUser();
      if (!mounted) return;

      if (context.read<UserContext>().isEmailVerified) {
        // Transitioned unverified → verified. Confirm to the user instead
        // of silently hiding the banner, so they know the round-trip worked.
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(AppStrings.auth.emailVerifiedSuccess)),
          );
      }
      // Force a rebuild — UserContext doesn't notifyListeners on
      // isEmailVerified changes from reloadUser.
      setState(() {});
    } catch (e) {
      debugPrint('EmailVerificationBanner: reload failed — $e');
    }
  }

  void _dismiss() {
    setState(() => _isDismissed = true);
  }

  Future<void> _sendVerification() async {
    if (_isSending) return;
    setState(() => _isSending = true);

    unawaited(HapticFeedback.lightImpact());
    try {
      await context.read<AuthService>().sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(AppStrings.auth.verificationEmailSent)),
          );
        _dismiss(); // סגור אחרי שליחה מוצלחת
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(userFriendlyError(e, context: 'sendEmailVerification'))),
          );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContext>();

    if (!userContext.isLoggedIn || userContext.isEmailVerified || _isDismissed) {
      return const SizedBox.shrink();
    }

    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: kSpacingSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: kSpacingSmallPlus,
          vertical: kSpacingSmall,
        ),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: kOpacityStrong),
          borderRadius: BorderRadius.circular(kBorderRadius),
          border: Border.all(
            color: cs.outline.withValues(alpha: kOpacityLow),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.mark_email_unread_outlined, color: cs.primary, size: kIconSizeSmallPlus),
            const SizedBox(width: kSpacingSmall),
            Expanded(
              child: Text(
                AppStrings.auth.verifyEmailMessage,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: kFontSizeSmall,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: kSpacingXTiny),
            // כפתור שליחה
            _isSending
                ? SizedBox(
                    width: kIconSizeSmall,
                    height: kIconSizeSmall,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.primary,
                    ),
                  )
                : TextButton(
                    onPressed: _sendVerification,
                    style: TextButton.styleFrom(
                      foregroundColor: cs.primary,
                      padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      AppStrings.auth.sendVerificationEmailButton,
                      style: const TextStyle(fontSize: kFontSizeSmall, fontWeight: FontWeight.w600),
                    ),
                  ),
            // כפתור X — מסתיר עד הכניסה הבאה לאפליקציה
            InkWell(
              onTap: _dismiss,
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
              child: Padding(
                padding: const EdgeInsets.all(kSpacingXTiny),
                child: Icon(Icons.close, size: kIconSizeSmall, color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
