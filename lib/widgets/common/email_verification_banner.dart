// 📄 lib/widgets/common/email_verification_banner.dart
//
// באנר קומפקטי לאימות אימייל — מוצג אחרי הברכה במסך הבית.
// ניתן לסגירה ל-24 שעות.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isDismissed = false;

  static const _dismissKey = 'email_banner_dismissed_until';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkDismissed();
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
    try {
      await context.read<AuthService>().reloadUser();
      if (mounted) setState(() {}); // rebuild — isEmailVerified may have changed
    } catch (_) {}
  }

  Future<void> _checkDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissedUntil = prefs.getInt(_dismissKey) ?? 0;
    if (DateTime.now().millisecondsSinceEpoch < dismissedUntil) {
      if (mounted) setState(() => _isDismissed = true);
    }
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    // סגירה ל-24 שעות
    final until = DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch;
    await prefs.setInt(_dismissKey, until);
    if (mounted) setState(() => _isDismissed = true);
  }

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
        unawaited(_dismiss()); // סגור אחרי שליחה מוצלחת
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
          color: cs.surfaceContainerHighest.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(kBorderRadius),
          border: Border.all(
            color: cs.outline.withValues(alpha: 0.2),
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
                      padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      AppStrings.auth.sendVerificationEmailButton,
                      style: TextStyle(fontSize: kFontSizeSmall, fontWeight: FontWeight.bold),
                    ),
                  ),
            // כפתור X — סגירה ל-24 שעות
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
