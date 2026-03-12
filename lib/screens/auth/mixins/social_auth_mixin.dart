// 📄 lib/screens/auth/mixins/social_auth_mixin.dart
//
// 🎯 Shared social login logic for Login + Register screens
// ✅ DRY: Eliminates duplicate _handleGoogleSignIn/_handleAppleSignIn
//
// Usage:
// ```dart
// class _LoginScreenState extends State<LoginScreen>
//     with SocialAuthMixin {
//   @override
//   void onSocialAuthError(String message) {
//     _showStatus(message, type: StatusType.error);
//   }
// }
// ```

import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/user_context.dart';
import '../../../services/auth_service.dart';

/// 🔐 Mixin for shared social authentication logic
mixin SocialAuthMixin<T extends StatefulWidget> on State<T> {
  bool _socialAuthLoading = false;

  bool get isSocialAuthLoading => _socialAuthLoading;

  /// Override to show error messages in UI
  void onSocialAuthError(String message);

  /// Override for custom loading state management (optional)
  void onSocialAuthLoadingChanged(bool loading) {
    setState(() => _socialAuthLoading = loading);
  }

  /// 🔵 Google Sign In
  Future<void> handleGoogleSignIn() async {
    if (_socialAuthLoading) return;

    unawaited(HapticFeedback.lightImpact());
    onSocialAuthLoadingChanged(true);

    try {
      final userContext = context.read<UserContext>();
      await userContext.signInWithGoogle();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seenOnboarding', true);

      if (mounted) {
        onSocialAuthLoadingChanged(false);
        await Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ handleGoogleSignIn: $e');
      if (mounted) {
        onSocialAuthLoadingChanged(false);
        final isCancelled = e is AuthException && e.code == AuthErrorCode.socialLoginCancelled;
        if (!isCancelled) {
          onSocialAuthError(e.toString().replaceAll('Exception: ', ''));
        }
      }
    }
  }

  /// 🍎 Apple Sign In
  Future<void> handleAppleSignIn() async {
    if (_socialAuthLoading) return;

    unawaited(HapticFeedback.lightImpact());
    onSocialAuthLoadingChanged(true);

    try {
      final userContext = context.read<UserContext>();
      await userContext.signInWithApple();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seenOnboarding', true);

      if (mounted) {
        onSocialAuthLoadingChanged(false);
        await Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ handleAppleSignIn: $e');
      if (mounted) {
        onSocialAuthLoadingChanged(false);
        final isCancelled = e is AuthException && e.code == AuthErrorCode.socialLoginCancelled;
        if (!isCancelled) {
          onSocialAuthError(e.toString().replaceAll('Exception: ', ''));
        }
      }
    }
  }
}
