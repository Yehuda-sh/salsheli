// 📄 lib/screens/auth/login_screen.dart
//
// מסך התחברות עם Firebase Auth.
// - Form validation + shake animation לשגיאות
// - Password reset בלחיצה על "שכחת סיסמה"
// - PopScope חוסם Back (חובה להתחבר)
//
// 🔗 Related: UserContext, RegisterScreen, AppStrings.auth

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';
import '../../core/status_colors.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../providers/user_context.dart';
import '../../theme/app_theme.dart';

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
  bool _showSocialButtons = false; // 🎬 לאנימציית כניסה

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

    // 🎬 אנימציית כניסה לכפתורי Social Login
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _showSocialButtons = true);
      }
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

  /// ✅ פונקציית Login עם Firebase Authentication
  Future<void> _handleLogin() async {
    // 🛡️ מניעת לחיצות כפולות
    if (_isLoading) return;

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
        debugPrint('✅ _handleLogin() | Sign in successful, userId: ${userContext.userId}');
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
        // ✅ שימוש ב-StatusColors API
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: StatusColors.getOnStatusContainer('success', context), size: 24),
                const SizedBox(width: kSpacingSmall),
                Text(
                  AppStrings.auth.loginSuccessRedirect,
                  style: TextStyle(color: StatusColors.getOnStatusContainer('success', context)),
                ),
              ],
            ),
            backgroundColor: StatusColors.getStatusContainer('success', context),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            margin: const EdgeInsets.all(kSpacingMedium),
          ),
        );

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
        // ✅ שימוש ב-StatusColors API
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: StatusColors.getOnStatusContainer('error', context), size: 24),
                const SizedBox(width: kSpacingSmall),
                Expanded(
                  child: Text(
                    errorMsg,
                    style: TextStyle(fontSize: kFontSizeSmall, color: StatusColors.getOnStatusContainer('error', context)),
                  ),
                ),
              ],
            ),
            backgroundColor: StatusColors.getStatusContainer('error', context),
            duration: kSnackBarDurationLong,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            margin: const EdgeInsets.all(kSpacingMedium),
          ),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMsg,
              style: TextStyle(color: StatusColors.getOnStatusContainer('error', context)),
            ),
            backgroundColor: StatusColors.getStatusContainer('error', context),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// 🍎 התחברות עם Apple
  Future<void> _handleAppleSignIn() async {
    if (_isLoading) return;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMsg,
              style: TextStyle(color: StatusColors.getOnStatusContainer('error', context)),
            ),
            backgroundColor: StatusColors.getStatusContainer('error', context),
            behavior: SnackBarBehavior.floating,
          ),
        );
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
      // ✅ שימוש ב-StatusColors API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.info_outline, color: StatusColors.getOnStatusContainer('warning', context)),
              const SizedBox(width: kSpacingSmall),
              Expanded(
                child: Text(
                  AppStrings.auth.enterEmailFirst,
                  style: TextStyle(
                    fontSize: kFontSizeSmall,
                    color: StatusColors.getOnStatusContainer('warning', context),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: StatusColors.getStatusContainer('warning', context),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
          margin: const EdgeInsets.all(kSpacingMedium),
        ),
      );
      return;
    }

    if (!email.contains('@')) {
      // ✅ שימוש ב-StatusColors API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.auth.emailInvalid,
            style: TextStyle(color: StatusColors.getOnStatusContainer('error', context)),
          ),
          backgroundColor: StatusColors.getStatusContainer('error', context),
        ),
      );
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
        // ✅ שימוש ב-StatusColors API
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: StatusColors.getOnStatusContainer('success', context)),
                const SizedBox(width: kSpacingSmall),
                Expanded(
                  child: Text(
                    AppStrings.auth.resetEmailSentTo(email),
                    style: TextStyle(
                      fontSize: kFontSizeSmall,
                      color: StatusColors.getOnStatusContainer('success', context),
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: StatusColors.getStatusContainer('success', context),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            margin: const EdgeInsets.all(kSpacingMedium),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ _handleForgotPassword() | Failed: $e');

      if (mounted) {
        setState(() => _isLoading = false);

        // ✅ שימוש ב-StatusColors API
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: StatusColors.getOnStatusContainer('error', context)),
                const SizedBox(width: kSpacingSmall),
                Expanded(
                  child: Text(
                    AppStrings.auth.resetEmailSendError,
                    style: TextStyle(fontSize: kFontSizeSmall, color: StatusColors.getOnStatusContainer('error', context)),
                  ),
                ),
              ],
            ),
            backgroundColor: StatusColors.getStatusContainer('error', context),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            margin: const EdgeInsets.all(kSpacingMedium),
          ),
        );
      }
    }

    if (kDebugMode) debugPrint('🏁 _handleForgotPassword() | Completed');
  }

  // ═══════════════════════════════════════════════════════════════════
  // 🧪 DEV MODE - Quick Login (only in development/emulator mode)
  // ═══════════════════════════════════════════════════════════════════

  /// רשימת משתמשי דמו לכניסה מהירה (רק ב-development)
  static const List<Map<String, String>> _demoUsers = [
    // משפחת כהן
    {'name': 'אבי כהן', 'email': 'avi.cohen@demo.com', 'role': 'Owner', 'group': 'משפחת כהן'},
    {'name': 'רונית כהן', 'email': 'ronit.cohen@demo.com', 'role': 'Admin', 'group': 'משפחת כהן'},
    {'name': 'יובל כהן', 'email': 'yuval.cohen@demo.com', 'role': 'Editor', 'group': 'משפחת כהן'},
    {'name': 'נועה כהן', 'email': 'noa.cohen@demo.com', 'role': 'Editor', 'group': 'משפחת כהן'},
    // זוג לוי
    {'name': 'דן לוי', 'email': 'dan.levi@demo.com', 'role': 'Owner', 'group': 'זוג צעיר'},
    {'name': 'מאיה לוי', 'email': 'maya.levi@demo.com', 'role': 'Admin', 'group': 'זוג צעיר'},
    // בודדים
    {'name': 'תומר בר', 'email': 'tomer.bar@demo.com', 'role': 'Owner', 'group': 'גר לבד'},
    {'name': 'שירן גל', 'email': 'shiran.gal@demo.com', 'role': 'Owner', 'group': 'משתמש חדש'},
    // ועד בית - הדקל 15
    {'name': 'משה גולן', 'email': 'moshe.golan@demo.com', 'role': 'Owner', 'group': 'ועד בית'},
    {'name': 'שרה לוי', 'email': 'sara.levi@demo.com', 'role': 'Admin', 'group': 'ועד בית'},
    {'name': 'דוד כהן', 'email': 'david.cohen.vaad@demo.com', 'role': 'Editor', 'group': 'ועד בית'},
    {'name': 'מיכל אברהם', 'email': 'michal.avraham@demo.com', 'role': 'Viewer', 'group': 'ועד בית'},
    // ועד גן - שושנים
    {'name': 'יעל ברק', 'email': 'yael.barak@demo.com', 'role': 'Owner', 'group': 'ועד גן'},
    {'name': 'אורנה שלום', 'email': 'orna.shalom@demo.com', 'role': 'Admin', 'group': 'ועד גן'},
    {'name': 'רמי דור', 'email': 'rami.dor@demo.com', 'role': 'Editor', 'group': 'ועד גן'},
    // חתונה - ליאור ונועם
    {'name': 'ליאור כץ', 'email': 'lior.katz@demo.com', 'role': 'Owner', 'group': 'חתונה'},
    {'name': 'נועם שפירא', 'email': 'noam.shapira@demo.com', 'role': 'Admin', 'group': 'חתונה'},
    {'name': 'אייל כץ', 'email': 'eyal.katz@demo.com', 'role': 'Editor', 'group': 'חתונה'},
  ];

  /// סיסמה לכל משתמשי הדמו
  static const String _demoPassword = 'Demo123!';

  /// פתיחת דיאלוג לבחירת משתמש דמו
  void _showQuickLoginDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuickLoginBottomSheet(
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
    if (kDebugMode) debugPrint('🧪 Quick login with: $email');

    // מילוי השדות
    _emailController.text = email;
    _passwordController.text = _demoPassword;

    // הפעלת login
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
          backgroundColor: cs.surface,
          body: Stack(
            children: [
              // 🧪 DEV MODE - Quick Login Button (only in development)
              if (AppConfig.useEmulators)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  child: Material(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                    elevation: 2,
                    child: InkWell(
                      onTap: _showQuickLoginDialog,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bug_report, size: 16, color: Colors.orange.shade800),
                            const SizedBox(width: 4),
                            Text(
                              'DEV',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ],
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
                            const SizedBox(height: kSpacingMedium),

                            // 📝 כותרת פשוטה - בלי לוגו (כמו מסך הרשמה)
                            Text(
                              AppStrings.auth.loginTitle,
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 36,
                                // ✅ צבע מ-Theme (תומך Dark Mode)
                                color: cs.onSurface,
                                letterSpacing: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.auth.loginSubtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                // ✅ צבע מ-Theme (תומך Dark Mode)
                                color: cs.onSurfaceVariant,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: kSpacingLarge),
                            // 📧 שדה אימייל
                            TextFormField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              decoration: InputDecoration(
                                labelText: AppStrings.auth.emailLabel,
                                hintText: AppStrings.auth.emailHint,
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(kBorderRadius),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(kBorderRadius),
                                  borderSide: BorderSide(color: cs.primary, width: 2),
                                ),
                                filled: true,
                                fillColor: cs.surfaceContainerHighest,
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
                            ),
                            const SizedBox(height: kSpacingSmall),
                            // 🔒 שדה סיסמה
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
                                fillColor: cs.surfaceContainerHighest,
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
                            ),
                            const SizedBox(
                              height: kSpacingSmall,
                            ), // 📐 רווח קטן
                            // 🔑 קישור שכחתי סיסמה - מימין לשדה הסיסמה
                            // ✅ נגישות משופרת עם Semantics
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
                            ),
                            const SizedBox(height: kSpacingSmall),
                            // 🔘 כפתור התחברות
                            FilledButton.icon(
                              onPressed: _isLoading ? null : _handleLogin,
                              icon: const Icon(Icons.login),
                              label: Text(AppStrings.auth.loginButton),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                backgroundColor: brand?.success ?? cs.primary,
                                foregroundColor: cs.onPrimary,
                              ),
                            ),
                            const SizedBox(height: kSpacingLarge),

                            // ➖ Divider עם "או התחבר עם" - אנימציה יחד עם Social buttons
                            AnimatedOpacity(
                              opacity: _showSocialButtons ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              child: Padding(
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
                              ),
                            ),

                            // 🔵 כפתורי Social Login עם אנימציית כניסה
                            AnimatedSlide(
                              offset: _showSocialButtons ? Offset.zero : const Offset(0, 0.3),
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                              child: AnimatedOpacity(
                                opacity: _showSocialButtons ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 400),
                                child: Row(
                                  children: [
                                    // Google
                                    Expanded(
                                      child: _SocialLoginButton(
                                        icon: FontAwesomeIcons.google,
                                        label: 'Google',
                                        color: const Color(0xFFDB4437),
                                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                                      ),
                                    ),
                                    const SizedBox(width: kSpacingSmall),
                                    // Apple
                                    Expanded(
                                      child: _SocialLoginButton(
                                        icon: FontAwesomeIcons.apple,
                                        label: 'Apple',
                                        color: cs.onSurface, // שחור/לבן לפי Theme
                                        onPressed: _isLoading ? null : _handleAppleSignIn,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: kSpacingMedium),

                            // 🔗 קישור להרשמה - Row פשוט (כמו מסך הרשמה)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppStrings.auth.noAccount,
                                  // ✅ צבע מ-Theme (תומך Dark Mode)
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 15,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _navigateToRegister,
                                  child: Text(
                                    AppStrings.auth.registerNow,
                                    // ✅ סגנון בולט יותר עם קו תחתון
                                    style: TextStyle(
                                      color: accent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      decoration: TextDecoration.underline,
                                      decorationColor: accent,
                                      decorationThickness: 2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: kSpacingMedium),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 🌫️ Loading overlay עם blur עדין
              if (_isLoading)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.25),
                      child: Center(
                        child: CircularProgressIndicator(color: cs.primary),
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
class _QuickLoginBottomSheet extends StatelessWidget {
  final List<Map<String, String>> users;
  final void Function(String email) onUserSelected;

  const _QuickLoginBottomSheet({
    required this.users,
    required this.onUserSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // קיבוץ משתמשים לפי קבוצה
    final groupedUsers = <String, List<Map<String, String>>>{};
    for (final user in users) {
      final group = user['group'] ?? 'אחר';
      groupedUsers.putIfAbsent(group, () => []).add(user);
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.bug_report, color: Colors.orange.shade800, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'התחברות מהירה - DEV',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'בחר משתמש דמו להתחברות',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // User list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: groupedUsers.length,
              itemBuilder: (context, index) {
                final group = groupedUsers.keys.elementAt(index);
                final groupUsers = groupedUsers[group]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Group header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        group,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Users in group
                    ...groupUsers.map((user) => _buildUserTile(context, user)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(BuildContext context, Map<String, String> user) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final roleColor = switch (user['role']) {
      'Owner' => Colors.amber,
      'Admin' => Colors.blue,
      'Editor' => Colors.green,
      _ => Colors.grey,
    };

    // 🔧 FIX: שימוש ב-characters.first במקום substring לתמיכה באמוג'י ותווים מיוחדים
    final firstChar = user['name']!.characters.firstOrNull ?? '?';

    return ListTile(
      onTap: () => onUserSelected(user['email']!),
      leading: CircleAvatar(
        backgroundColor: roleColor.withValues(alpha: 0.2),
        child: Text(
          firstChar,
          style: TextStyle(
            color: roleColor.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        user['name']!,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        user['email']!,
        style: theme.textTheme.bodySmall?.copyWith(
          color: cs.onSurfaceVariant,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: roleColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          user['role']!,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: roleColor.shade700,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔵 Social Login Button Widget
// ═══════════════════════════════════════════════════════════════════════════

/// כפתור Social Login (Google/Apple) בעיצוב Theme-aware
/// ✅ כולל AnimatedScale feedback בלחיצה + צללים מותאמים ל-Dark Mode
class _SocialLoginButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  @override
  State<_SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<_SocialLoginButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDisabled = widget.onPressed == null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ צל מותאם ל-Dark Mode
    final shadowColor = isDark
        ? cs.surfaceContainerLowest.withValues(alpha: 0.1)
        : cs.shadow.withValues(alpha: 0.15);

    return Semantics(
      button: true,
      label: AppStrings.auth.socialLoginSemanticLabel(widget.label),
      enabled: !isDisabled,
      child: GestureDetector(
        onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
        onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
        onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: Container(
            decoration: BoxDecoration(
              color: isDisabled
                  ? cs.surfaceContainerHighest.withValues(alpha: 0.5)
                  : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(kBorderRadius),
              boxShadow: isDisabled
                  ? null
                  : [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: BorderRadius.circular(kBorderRadius),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: kSpacingSmall + 4,
                    horizontal: kSpacingMedium,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        widget.icon,
                        size: 18,
                        color: isDisabled
                            ? widget.color.withValues(alpha: 0.5)
                            : widget.color,
                      ),
                      const SizedBox(width: kSpacingSmall),
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: isDisabled
                              ? cs.onSurface.withValues(alpha: 0.5)
                              : cs.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: kFontSizeMedium,
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
    );
  }
}
