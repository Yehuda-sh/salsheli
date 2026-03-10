// 📄 lib/screens/auth/login_screen.dart
//
// 🎯 Purpose: מסך התחברות עם Firebase Auth
//
// 📋 Features:
//     - שילוב NotebookBackground (Paper & Ink design language)
//     - אנימציות כניסה מדורגות (Staggered) עם flutter_animate
//     - Loading Overlay משופר עם Glassmorphism וטקסט משתנה
//     - Form validation + shake animation לשגיאות
//     - Password reset בלחיצה על "שכחת סיסמה"
//     - PopScope חוסם Back (חובה להתחבר)
//     - Haptic Feedback משולב
//     - ריכוז לוגיקת SnackBar
//     - DEV Mode עם Glassmorphic UI
//
// 🔗 Related: UserContext, RegisterScreen, AppStrings.auth
//
// 📜 History:
//     - v3.1: Form validation, shake, haptic, social login
//     - v4.0 (22/02/2026): NotebookBackground, staggered animations, glassmorphic overlay
//
// Version: 4.0
// Last Updated: 22/02/2026

import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'widgets/quick_login_bottom_sheet.dart';
import 'widgets/social_login_button.dart';
import 'widgets/loading_overlay.dart';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';
import '../../core/status_colors.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../providers/user_context.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/notebook_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // 🎬 Animation controller לשגיאות
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // 🎯 Focus node for auto-focus
  final FocusNode _emailFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // 🎬 הגדרת shake animation לשגיאות
    // 🔧 FIX: TweenSequence מבטיח שהאנימציה מתחילה ומסתיימת ב-0
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6, end: -4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));

    // 🎯 Auto-focus על שדה אימייל בכניסה למסך
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(_emailFocusNode.requestFocus);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _shakeController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════
  // 📢 UI Helper - SnackBar מרוכז
  // ═══════════════════════════════════════════════════════════════════

  /// הצגת הודעת סטטוס אחידה עם StatusColors
  void _showStatus(String message, {required StatusType type}) {
    final icon = switch (type) {
      StatusType.success => Icons.check_circle,
      StatusType.warning => Icons.info_outline,
      _ => Icons.error_outline,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: StatusColors.getOnContainer(type, context), size: 24),
            const SizedBox(width: kSpacingSmall),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: kFontSizeSmall,
                  color: StatusColors.getOnContainer(type, context),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: StatusColors.getContainer(type, context),
        duration: type == StatusType.success ? const Duration(seconds: 2) : kSnackBarDurationLong,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        margin: const EdgeInsets.all(kSpacingMedium),
      ),
    );
  }

  /// ✅ פונקציית Login עם Firebase Authentication
  Future<void> _handleLogin() async {
    // 🛡️ מניעת לחיצות כפולות
    if (_isLoading) return;

    unawaited(HapticFeedback.mediumImpact());
    if (kDebugMode) debugPrint('🔐 _handleLogin() | Starting login process...');
    if (!_formKey.currentState!.validate()) {
      if (kDebugMode) debugPrint('❌ _handleLogin() | Form validation failed');
      unawaited(_shakeController.forward(from: 0)); // 🎬 Shake animation
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // 💡 שמור context/navigator לפני await (best practice!)
      final userContext = context.read<UserContext>();
      final navigator = Navigator.of(context);

      // 🔹 1. התחברות דרך Firebase Auth
      if (kDebugMode) debugPrint('🔐 _handleLogin() | Signing in...');
      await userContext.signIn(email: email, password: password);

      // ✅ signIn() זורק Exception אם נכשל, אחרת מצליח
      if (kDebugMode) {
      }

      // 🔹 2. שמירה ב-SharedPreferences (רק seenOnboarding!)
      // ✅ FIX: שם עקבי עם IndexScreen ו-UserContext
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seenOnboarding', true);
      if (kDebugMode) debugPrint('✅ _handleLogin() | Onboarding flag saved');

      // 🔹 3. הצגת feedback ויזואלי + ניווט
      if (mounted) {
        setState(() => _isLoading = false);

        // 🎉 הצגת הודעת הצלחה קצרה
        _showStatus(AppStrings.auth.loginSuccessRedirect, type: StatusType.success);

        // ⏱️ המתנה קצרה לפני ניווט (feedback ויזואלי)
        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          // ✅ FIX: ניווט ל-Index במקום Home
          // Index מטפל ב-sync profile ומחליט לאן לנווט
          if (kDebugMode) debugPrint('🔄 _handleLogin() | Navigating to index screen');
          await navigator.pushNamedAndRemoveUntil('/', (route) => false);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ _handleLogin() | Login failed: $e');
      final errorMsg = e.toString().replaceAll('Exception: ', '');

      if (mounted) {
        setState(() => _isLoading = false);
        unawaited(_shakeController.forward(from: 0)); // 🎬 Shake animation

        // 🎨 הודעת שגיאה משופרת
        _showStatus(errorMsg, type: StatusType.error);
      }
    }
    if (kDebugMode) debugPrint('🏁 _handleLogin() | Completed');
  }

  /// ניווט למסך הרשמה
  void _navigateToRegister() {
    if (kDebugMode) debugPrint('🔄 _navigateToRegister() | Navigating to register screen');
    Navigator.pushReplacementNamed(context, '/register');
  }

  /// 🔵 התחברות עם Google
  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    unawaited(HapticFeedback.lightImpact());
    if (kDebugMode) debugPrint('🔵 _handleGoogleSignIn() | Starting Google sign in...');
    setState(() => _isLoading = true);

    try {
      final userContext = context.read<UserContext>();

      await userContext.signInWithGoogle();

      if (kDebugMode) debugPrint('✅ _handleGoogleSignIn() | Success');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seenOnboarding', true);

      if (mounted) {
        setState(() => _isLoading = false);

        // ניווט לאפליקציה
        await Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ _handleGoogleSignIn() | Error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        _showStatus(errorMsg, type: StatusType.error);
      }
    }
  }

  /// 🍎 התחברות עם Apple
  Future<void> _handleAppleSignIn() async {
    if (_isLoading) return;

    unawaited(HapticFeedback.lightImpact());
    if (kDebugMode) debugPrint('🍎 _handleAppleSignIn() | Starting Apple sign in...');
    setState(() => _isLoading = true);

    try {
      final userContext = context.read<UserContext>();

      await userContext.signInWithApple();

      if (kDebugMode) debugPrint('✅ _handleAppleSignIn() | Success');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seenOnboarding', true);

      if (mounted) {
        setState(() => _isLoading = false);

        // ניווט לאפליקציה
        await Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ _handleAppleSignIn() | Error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        _showStatus(errorMsg, type: StatusType.error);
      }
    }
  }

  /// 🔑 איפוס סיסמה - שליחת מייל דרך Firebase Auth
  Future<void> _handleForgotPassword() async {
    // 🛡️ מניעת לחיצות כפולות
    if (_isLoading) return;

    if (kDebugMode) debugPrint('🔑 _handleForgotPassword() | Starting password reset process');

    // בדוק אם יש אימייל בשדה
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showStatus(AppStrings.auth.enterEmailFirst, type: StatusType.warning);
      return;
    }

    if (!email.contains('@')) {
      _showStatus(AppStrings.auth.emailInvalid, type: StatusType.error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userContext = context.read<UserContext>();
      await userContext.sendPasswordResetEmail(email);

      if (kDebugMode) debugPrint('✅ _handleForgotPassword() | Reset email sent');

      if (mounted) {
        setState(() => _isLoading = false);

        // הצג הודעת הצלחה
        _showStatus(AppStrings.auth.resetEmailSentTo(email), type: StatusType.success);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ _handleForgotPassword() | Failed: $e');

      if (mounted) {
        setState(() => _isLoading = false);

        _showStatus(AppStrings.auth.resetEmailSendError, type: StatusType.error);
      }
    }

    if (kDebugMode) debugPrint('🏁 _handleForgotPassword() | Completed');
  }

  // ═══════════════════════════════════════════════════════════════════
  // 🧪 DEV MODE - Quick Login (only in development/emulator mode)
  // ═══════════════════════════════════════════════════════════════════

  /// רשימת משתמשי דמו לכניסה מהירה (רק ב-development)
  static const List<Map<String, String>> _demoUsers = [
    // 👨‍👩‍👧‍👦 משפחת כהן — 4 members, 2 רשימות, 20 פריטי מזווה, קבלה
    {'name': 'אבי כהן', 'email': 'avi.cohen@demo.com', 'role': 'Admin', 'group': 'משפחת כהן'},
    {'name': 'רונית כהן', 'email': 'ronit.cohen@demo.com', 'role': 'Admin', 'group': 'משפחת כהן'},
    {'name': 'יובל כהן', 'email': 'yuval.cohen@demo.com', 'role': 'Editor', 'group': 'משפחת כהן'},
    {'name': 'נועה כהן', 'email': 'noa.cohen@demo.com', 'role': 'Editor', 'group': 'משפחת כהן'},
    // 💑 זוג לוי — 2 members, 1 רשימה
    {'name': 'דן לוי', 'email': 'dan.levi@demo.com', 'role': 'Admin', 'group': 'זוג צעיר'},
    {'name': 'מאיה לוי', 'email': 'maya.levi@demo.com', 'role': 'Admin', 'group': 'זוג צעיר'},
    // 🧑 בודד — מזווה + רשימה פרטית
    {'name': 'תומר בר', 'email': 'tomer.bar@demo.com', 'role': 'Admin', 'group': 'גר לבד'},
    // 🆕 משתמש חדש — מזווה בלבד, בלי רשימות
    {'name': 'שירן גל', 'email': 'shiran.gal@demo.com', 'role': 'Admin', 'group': 'משתמש חדש'},
  ];

  /// סיסמה לכל משתמשי הדמו
  static const String _demoPassword = 'Demo123456!';

  /// פתיחת דיאלוג לבחירת משתמש דמו
  void _showQuickLoginDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickLoginBottomSheet(
        users: _demoUsers,
        onUserSelected: (email) {
          Navigator.pop(context);
          _quickLogin(email);
        },
      ),
    );
  }

  /// התחברות מהירה עם משתמש דמו
  Future<void> _quickLogin(String email) async {
    unawaited(HapticFeedback.lightImpact());
    if (kDebugMode) debugPrint('🧪 Quick login with: $email');

    // 🔑 Debug: use Firebase REST API to bypass reCAPTCHA on emulators
    if (kDebugMode) {
      try {
        setState(() => _isLoading = true);
        debugPrint('🔑 Trying REST API sign-in for $email...');
        
        final response = await http.post(
          Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyB52eBlYLTiOQdZFl0U1B4F4g75xo31oN8'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': email,
            'password': _demoPassword,
            'returnSecureToken': true,
          }),
        ).timeout(const Duration(seconds: 10));
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          debugPrint('✅ REST sign-in success! UID: ${data['localId']}');
          debugPrint('🔄 Now signing in via SDK (should use cached session)...');
          
          // REST worked → SDK should also work now (session is cached server-side)
          // Try SDK with longer timeout
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email, password: _demoPassword,
          ).timeout(const Duration(seconds: 90));
          
          debugPrint('✅ SDK sign-in success!');
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/index');
          }
          return;
        } else {
          debugPrint('⚠️ REST API returned ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        debugPrint('⚠️ REST login failed: $e, falling back to normal login');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }

    // Fallback: מילוי השדות + email/password login
    _emailController.text = email;
    _passwordController.text = _demoPassword;
    await _handleLogin();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    // 💡 שמור messenger לפני PopScope
    final messenger = ScaffoldMessenger.of(context);

    // 🔒 חסימת Back - המשתמש חייב להשלים התחברות
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(AppStrings.auth.mustCompleteLogin),
                duration: kSnackBarDuration,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: brand?.paperBackground ?? kPaperBackground,
          body: Stack(
            children: [
              // 📓 רקע מחברת עדין - Paper & Ink design language
              const NotebookBackground(
                lineOpacity: 0.10,
                lineColor: kNotebookBlueSoft,
                showRedLine: false,
                fadeEdges: true,
              ),

              // 🧪 DEV MODE - Quick Login Button (Glassmorphic)
              if (AppConfig.useEmulators)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: kGlassBlurLow, sigmaY: kGlassBlurLow),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cs.tertiary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                          border: Border.all(
                            color: cs.tertiary.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: InkWell(
                          onTap: _showQuickLoginDialog,
                          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bug_report, size: 16, color: cs.tertiary),
                                SizedBox(width: 4),
                                Text(
                                  'DEV',
                                  style: TextStyle(
                                    fontSize: kFontSizeSmall,
                                    fontWeight: FontWeight.bold,
                                    color: cs.tertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // תוכן המסך
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    // ✅ ריווח דינמי - נותן מקום למקלדת
                    padding: EdgeInsets.only(
                      left: kSpacingMedium,
                      right: kSpacingMedium,
                      top: kSpacingSmall,
                      bottom: MediaQuery.of(context).viewInsets.bottom + kSpacingMedium,
                    ),
                    child: AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: child,
                        );
                      },
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: kSpacingMedium),

                            // 📝 כותרת - staggered animation
                            Text(
                              AppStrings.auth.loginTitle,
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: kFontSizeDisplay,
                                color: cs.onSurface,
                                letterSpacing: 1,
                              ),
                              textAlign: TextAlign.center,
                            )
                                .animate()
                                .fadeIn(duration: 400.ms)
                                .slideX(begin: -0.1, curve: Curves.easeOutCubic),
                            SizedBox(height: 4),
                            Text(
                              AppStrings.auth.loginSubtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontSize: kFontSizeBody,
                              ),
                              textAlign: TextAlign.center,
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 50.ms)
                                .slideX(begin: -0.1, curve: Curves.easeOutCubic),
                            const SizedBox(height: kSpacingLarge),

                            // 📧 שדה אימייל - paper fillColor
                            TextFormField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              decoration: InputDecoration(
                                labelText: AppStrings.auth.emailLabel,
                                hintText: AppStrings.auth.emailHint,
                                prefixIcon: Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(kBorderRadius),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(kBorderRadius),
                                  borderSide: BorderSide(color: cs.primary, width: 2),
                                ),
                                filled: true,
                                fillColor: cs.surface.withValues(alpha: 0.6),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: kSpacingMedium,
                                  vertical: kSpacingSmall,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppStrings.auth.emailRequired;
                                }
                                if (!value.contains('@')) {
                                  return AppStrings.auth.emailInvalid;
                                }
                                return null;
                              },
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 100.ms)
                                .slideX(begin: -0.1, curve: Curves.easeOutCubic),
                            const SizedBox(height: kSpacingSmall),

                            // 🔒 שדה סיסמה - paper fillColor
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: AppStrings.auth.passwordLabel,
                                hintText: AppStrings.auth.passwordHint,
                                prefixIcon: const Icon(Icons.lock_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  tooltip: _obscurePassword
                                      ? AppStrings.auth.showPassword
                                      : AppStrings.auth.hidePassword,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(kBorderRadius),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(kBorderRadius),
                                  borderSide: BorderSide(color: cs.primary, width: 2),
                                ),
                                filled: true,
                                fillColor: cs.surface.withValues(alpha: 0.6),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: kSpacingMedium,
                                  vertical: kSpacingSmall,
                                ),
                              ),
                              obscureText: _obscurePassword,
                              onFieldSubmitted: (_) => _handleLogin(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppStrings.auth.passwordRequired;
                                }
                                if (value.length < 6) {
                                  return AppStrings.auth.passwordTooShort;
                                }
                                return null;
                              },
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 150.ms)
                                .slideX(begin: -0.1, curve: Curves.easeOutCubic),
                            const SizedBox(height: kSpacingSmall),

                            // 🔑 קישור שכחתי סיסמה
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Semantics(
                                button: true,
                                label: AppStrings.auth.forgotPasswordSemanticLabel,
                                hint: AppStrings.auth.forgotPasswordSemanticHint,
                                enabled: !_isLoading,
                                child: TextButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _handleForgotPassword,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: kSpacingSmall,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    AppStrings.auth.forgotPassword,
                                    style: TextStyle(
                                      color: accent,
                                      fontSize: kFontSizeTiny,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 200.ms),
                            SizedBox(height: kSpacingSmall),

                            // 🔘 כפתור התחברות + shimmer CTA
                            FilledButton.icon(
                              onPressed: _isLoading ? null : _handleLogin,
                              icon: Icon(Icons.login),
                              label: Text(AppStrings.auth.loginButton),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                backgroundColor: brand?.success ?? cs.primary,
                                foregroundColor: cs.onPrimary,
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 250.ms)
                                .slideX(begin: -0.1, curve: Curves.easeOutCubic)
                                .then() // ✅ shimmer starts after entry animation
                                .shimmer(
                                  duration: kAnimationDurationSlow,
                                  color: cs.onPrimary.withValues(alpha: kOpacityLow),
                                  angle: kShimmerAngle,
                                  delay: 1200.ms,
                                ),
                            SizedBox(height: kSpacingLarge),

                            // ➖ Divider עם "או התחבר עם"
                            Padding(
                              padding: const EdgeInsets.only(bottom: kSpacingMedium),
                              child: Row(
                                children: [
                                  Expanded(child: Divider(color: cs.outlineVariant)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
                                    child: Text(
                                      AppStrings.auth.orLoginWith,
                                      style: TextStyle(
                                        color: cs.onSurfaceVariant,
                                        fontSize: kFontSizeSmall,
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: cs.outlineVariant)),
                                ],
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 300.ms),

                            // 🔵 כפתורי Social Login
                            Row(
                              children: [
                                // Google
                                Expanded(
                                  child: SocialLoginButton(
                                    icon: FontAwesomeIcons.google,
                                    label: 'Google',
                                    color: Color(0xFFDB4437),
                                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                                  ),
                                ),
                                SizedBox(width: kSpacingSmall),
                                // Apple
                                Expanded(
                                  child: SocialLoginButton(
                                    icon: FontAwesomeIcons.apple,
                                    label: 'Apple',
                                    color: cs.onSurface,
                                    onPressed: _isLoading ? null : _handleAppleSignIn,
                                  ),
                                ),
                              ],
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 350.ms)
                                .slideY(begin: 0.15, curve: Curves.easeOutCubic),
                            SizedBox(height: kSpacingMedium),

                            // 🔗 קישור להרשמה
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppStrings.auth.noAccount,
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: kFontSizeBody,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _navigateToRegister,
                                  child: Text(
                                    AppStrings.auth.registerNow,
                                    style: TextStyle(
                                      color: accent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: kFontSizeBody,
                                      decoration: TextDecoration.underline,
                                      decorationColor: accent,
                                      decorationThickness: 2,
                                    ),
                                  ),
                                ),
                              ],
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 400.ms),
                            const SizedBox(height: kSpacingMedium),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 🌫️ Loading overlay עם Glassmorphism + טקסט משתנה
              if (_isLoading)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: kGlassBlurMedium,
                      sigmaY: kGlassBlurMedium,
                    ),
                    child: Container(
                      color: cs.scrim.withValues(alpha: 0.25),
                      child: Center(
                        child: LoadingOverlay(color: cs.primary),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🧪 DEV MODE - Quick Login Bottom Sheet
// ═══════════════════════════════════════════════════════════════════════════

/// Bottom sheet לבחירת משתמש דמו להתחברות מהירה (רק ב-development)
