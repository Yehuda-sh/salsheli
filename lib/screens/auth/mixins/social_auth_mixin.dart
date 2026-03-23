// 📄 lib/screens/auth/mixins/social_auth_mixin.dart
//
// 🎯 Shared social login logic for Login + Register screens
// ✅ DRY: Eliminates duplicate _handleGoogleSignIn/_handleAppleSignIn
//
// Usage:
// ```dart
// class _LoginScreenState extends State<LoginScreen>
//     with SingleTickerProviderStateMixin, SocialAuthMixin {
//   @override
//   bool get isAuthLoading => _isLoading;
//   @override
//   void setAuthLoading(bool v) => setState(() => _isLoading = v);
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
  /// Override: return true when any auth is in progress
  bool get isAuthLoading;

  /// Override: set the screen's loading state
  void setAuthLoading(bool loading);

  /// Override: show error messages in UI
  void onSocialAuthError(String message);

  /// 🔵 Google Sign In
  Future<void> handleGoogleSignIn() async {
    if (isAuthLoading) return;

    unawaited(HapticFeedback.lightImpact());
    if (kDebugMode) debugPrint('🔵 handleGoogleSignIn() | Starting...');
    setAuthLoading(true);

    try {
      final userContext = context.read<UserContext>();
      await userContext.signInWithGoogle();

      if (kDebugMode) debugPrint('✅ handleGoogleSignIn() | Success');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seenOnboarding', true);

      if (mounted) {
        setAuthLoading(false);
        await Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ handleGoogleSignIn() | Error: $e');
      if (mounted) {
        setAuthLoading(false);
        final isCancelled = e is AuthException && e.code == AuthErrorCode.socialLoginCancelled;
        if (!isCancelled) {
          onSocialAuthError(e.toString().replaceAll('Exception: ', ''));
        }
      }
    }
  }

  /// 🍎 Apple Sign In
  Future<void> handleAppleSignIn() async {
    if (isAuthLoading) return;

    unawaited(HapticFeedback.lightImpact());
    if (kDebugMode) debugPrint('🍎 handleAppleSignIn() | Starting...');
    setAuthLoading(true);

    try {
      final userContext = context.read<UserContext>();
      await userContext.signInWithApple();

      if (kDebugMode) debugPrint('✅ handleAppleSignIn() | Success');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seenOnboarding', true);

      if (mounted) {
        setAuthLoading(false);
        await Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ handleAppleSignIn() | Error: $e');
      if (mounted) {
        setAuthLoading(false);
        final isCancelled = e is AuthException && e.code == AuthErrorCode.socialLoginCancelled;
        if (!isCancelled) {
          onSocialAuthError(e.toString().replaceAll('Exception: ', ''));
        }
      }
    }
  }
}
