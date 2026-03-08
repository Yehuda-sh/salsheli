// 📄 lib/screens/auth/register_screen.dart
//
// **מסך הרשמה** - יצירת חשבון חדש עם Firebase Auth.
// כולל Form validation, shake animation לשגיאות,
// תמיכה מלאה ב-RTL ו-Dark Mode.
//
// ✅ Features:
//    - Form validation עם הודעות שגיאה בעברית
//    - Shake animation לפידבק ויזואלי על שגיאות
//    - Theme-aware colors (Dark Mode support)
//    - Accessibility: Semantics + Tooltips
//    - RTL support מלא
//    - בדיקת הזמנות ממתינות לקבוצות אחרי הרשמה
//    - Haptic Feedback משולב
//    - ריכוז לוגיקת SnackBar
//    - אנימציות כניסה מדורגות (Staggered Entrance)
//    - Loading Overlay בעיצוב Glassmorphic
//    - שילוב NotebookBackground עמוק
//
// 🔗 Related: UserContext, LoginScreen, PendingInvitesProvider
//
// 📜 History:
//     - v3.1: Form validation, shake, haptic, social login
//     - v4.0 (22/02/2026): Staggered animations, glassmorphic overlay, deep NotebookBackground
//
// Version: 4.0
// Last Updated: 22/02/2026

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/status_colors.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../providers/user_context.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/notebook_background.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // 🎬 Animation controller לשגיאות
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // 🎯 Focus nodes for auto-focus
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  // 📱 ולידציית טלפון ישראלי
  static final _phoneRegex = RegExp(r'^05[0-9]-?[0-9]{7}$');

  // 🎯 מעקב ולידציה למשוב תחושתי
  final Map<String, bool> _fieldWasValid = {};

  @override
  void initState() {
    super.initState();

    // 🎬 הגדרת shake animation לשגיאות
    _shakeController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    // ✅ TweenSequence שמחזיר ל-0 בסוף (מונע תקיעה)
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6, end: -4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));

    // 🎯 Auto-focus על שדה שם בכניסה למסך
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _nameFocusNode.requestFocus();
      }
    });
  }

  void _togglePasswordVisibility() {
    unawaited(HapticFeedback.lightImpact());
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    unawaited(HapticFeedback.lightImpact());
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  /// 📳 רצף רטט שגיאה
  Future<void> _errorHaptic() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _shakeController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════
  // 📢 UI Helper - SnackBar מרוכז
  // ═══════════════════════════════════════════════════════════════════

  /// הצגת הודעת סטטוס אחידה עם StatusColors
  /// [type] = 'success' | 'error' | 'warning'
  void _showStatus(String message, {required String type}) {
    final icon = switch (type) {
      'success' => Icons.check_circle,
      'warning' => Icons.info_outline,
      _ => Icons.error_outline,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: StatusColors.getOnContainer(StatusType.fromString(type), context), size: 24),
            const SizedBox(width: kSpacingSmall),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: kFontSizeSmall,
                  color: StatusColors.getOnContainer(StatusType.fromString(type), context),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: StatusColors.getContainer(StatusType.fromString(type), context),
        duration: type == 'success' ? const Duration(seconds: 2) : kSnackBarDurationLong,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusUnified),
        ),
        margin: const EdgeInsets.all(kSpacingMedium),
      ),
    );
  }

  /// ✅ פונקציית Register עם Firebase Authentication
  Future<void> _handleRegister() async {
    // 🛡️ מניעת לחיצות כפולות
    if (_isLoading) return;

    if (kDebugMode) debugPrint('📝 _handleRegister() | Starting registration process...');

    // Validation
    if (!_formKey.currentState!.validate()) {
      if (kDebugMode) debugPrint('❌ _handleRegister() | Form validation failed');
      unawaited(_shakeController.forward(from: 0)); // 🎬 Shake animation
      return;
    }

    // שמירת context לפני async
    final navigator = Navigator.of(context);

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim().replaceAll('-', '').replaceAll(' ', '');
      final password = _passwordController.text;

      // רישום דרך UserContext
      if (kDebugMode) debugPrint('📝 _handleRegister() | Signing up...');
      final userContext = context.read<UserContext>();
      await userContext.signUp(email: email, password: password, name: name, phone: phone);

      // ✅ הרישום הצליח!
      if (kDebugMode) debugPrint('✅ _handleRegister() | Success! userId: ${userContext.userId}');

      // 🔹 שמירת seenOnboarding - כמו ב-LoginScreen
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seenOnboarding', true);
      if (kDebugMode) debugPrint('✅ _handleRegister() | Onboarding flag saved');

      // 🎉 הצגת feedback ויזואלי + ניווט
      if (mounted) {
        setState(() => _isLoading = false);

        // 🎉 הודעת הצלחה
        _showStatus(AppStrings.auth.registerSuccessRedirect, type: 'success');

        // ⏱️ המתנה קצרה לפני ניווט
        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          if (kDebugMode) debugPrint('🔄 _handleRegister() | Navigating to index screen');
          await navigator.pushNamedAndRemoveUntil('/', (route) => false);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ _handleRegister() | Registration failed: $e');

      final errorMessage = e.toString().replaceAll('Exception: ', '');

      if (mounted) {
        setState(() => _isLoading = false);
        unawaited(_shakeController.forward(from: 0)); // 🎬 Shake animation
        unawaited(_errorHaptic()); // 📳 רצף רטט שגיאה

        // 🎨 הודעת שגיאה משופרת
        _showStatus(errorMessage, type: 'error');
      }
    }

    if (kDebugMode) debugPrint('🏁 _handleRegister() | Completed');
  }

  /// ניווט למסך התחברות
  void _navigateToLogin() {
    if (kDebugMode) debugPrint('🔄 _navigateToLogin() | Navigating to login screen');
    unawaited(Navigator.pushReplacementNamed(context, '/login'));
  }

  /// טיפול בלחיצה על כפתור הרשמה
  void _onRegisterPressed() {
    unawaited(HapticFeedback.mediumImpact());
    unawaited(_handleRegister());
  }

  /// 🔵 התחברות עם Google
  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    unawaited(HapticFeedback.lightImpact());
    setState(() => _isLoading = true);

    try {
      final userContext = context.read<UserContext>();

      await userContext.signInWithGoogle();

      // 🔹 שמירת seenOnboarding
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seenOnboarding', true);

      if (mounted) {
        setState(() => _isLoading = false);

        // ניווט לאפליקציה
        await Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ _handleGoogleSignIn: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        // ✅ בדיקת ביטול לפי error code (לא string matching)
        final isCancelled = e is AuthException && e.code == AuthErrorCode.socialLoginCancelled;
        if (!isCancelled) {
          unawaited(_errorHaptic()); // 📳 רצף רטט שגיאה
          _showStatus(e.toString().replaceAll('Exception: ', ''), type: 'error');
        }
      }
    }
  }

  /// 🍎 התחברות עם Apple
  Future<void> _handleAppleSignIn() async {
    if (_isLoading) return;

    unawaited(HapticFeedback.lightImpact());
    setState(() => _isLoading = true);

    try {
      final userContext = context.read<UserContext>();

      await userContext.signInWithApple();

      // 🔹 שמירת seenOnboarding
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seenOnboarding', true);

      if (mounted) {
        setState(() => _isLoading = false);

        // ניווט לאפליקציה
        await Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ _handleAppleSignIn: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        // ✅ בדיקת ביטול לפי error code (לא string matching)
        final isCancelled = e is AuthException && e.code == AuthErrorCode.socialLoginCancelled;
        if (!isCancelled) {
          unawaited(_errorHaptic()); // 📳 רצף רטט שגיאה
          _showStatus(e.toString().replaceAll('Exception: ', ''), type: 'error');
        }
      }
    }
  }

  /// 🎨 Helper method לבניית שדה טופס
  /// ✅ כולל Semantics לנגישות + shimmer on focus + haptic validation
  Widget _buildFormField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
    void Function(String)? onFieldSubmitted,
    String? Function(String?)? validator,
    String? semanticLabel,
    String? helperText,
  }) {
    final cs = Theme.of(context).colorScheme;
    final formField = Semantics(
      label: semanticLabel ?? label,
      textField: true,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(kBorderRadiusUnified)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusUnified),
            borderSide: BorderSide(color: cs.primary, width: 2),
          ),
          filled: true,
          // ✅ v4.0: שקיפות עמוקה – קווי מחברת נראים בעדינות ("דיו על נייר")
          fillColor: cs.surface.withValues(alpha: 0.4),
          contentPadding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
          helperText: helperText,
          helperStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: kFontSizeTiny),
        ),
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        onChanged: (value) {
          // 📳 משוב תחושתי בעת מעבר מלא-תקין לתקין
          if (validator != null) {
            final isValid = validator(value) == null && value.isNotEmpty;
            final wasValid = _fieldWasValid[label] ?? false;
            _fieldWasValid[label] = isValid;
            if (isValid && !wasValid) {
              unawaited(HapticFeedback.lightImpact());
            }
          }
        },
        onFieldSubmitted: onFieldSubmitted,
        validator: validator,
      ),
    );

    // ✅ v4.0: shimmer עדין על השדה בעת קבלת פוקוס
    return _ShimmerOnFocus(
      focusNode: focusNode,
      shimmerColor: cs.primary.withValues(alpha: 0.04),
      child: formField,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    // 🔒 חסימת Back - המשתמש יכול לחזור ל-login
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: Scaffold(
        backgroundColor: brand?.paperBackground ?? kPaperBackground,
        body: Stack(
          children: [
            // 📓 רקע מחברת עדין מאוד - brand texture (Auth = נקי, מינימלי)
            const NotebookBackground(
              lineOpacity: 0.10,
              lineColor: kNotebookBlueSoft,
              showRedLine: false,
              fadeEdges: true,
            ),
            // תוכן המסך
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  // 📐 ריווח דינמי - מתאים למקלדת פתוחה
                  padding: EdgeInsets.only(
                    left: kSpacingMedium,
                    right: kSpacingMedium,
                    top: kSpacingSmall,
                    bottom: MediaQuery.of(context).viewInsets.bottom + kSpacingMedium,
                  ),
                  child: AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(offset: Offset(_shakeAnimation.value, 0), child: child);
                    },
                    // ✅ RepaintBoundary לאופטימיזציה
                    child: RepaintBoundary(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: kSpacingMedium),

                            // 📝 כותרת - staggered animation
                            Text(
                              AppStrings.auth.registerTitle,
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 36,
                                color: cs.onSurface.withValues(alpha: 0.87),
                                letterSpacing: 0.8,
                              ),
                              textAlign: TextAlign.center,
                            )
                                .animate()
                                .fadeIn(duration: 400.ms)
                                .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                            SizedBox(height: 4),

                            Text(
                              AppStrings.auth.registerSubtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.70),
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 50.ms)
                                .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                            const SizedBox(height: kSpacingLarge),

                            // 👤 שדה שם
                            _buildFormField(
                              controller: _nameController,
                              focusNode: _nameFocusNode,
                              label: AppStrings.auth.nameLabel,
                              hint: AppStrings.auth.nameHint,
                              icon: Icons.person_outlined,
                              textInputAction: TextInputAction.next,
                              semanticLabel: AppStrings.auth.nameFieldSemanticLabel,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppStrings.auth.nameRequired;
                                }
                                if (value.length < 2) {
                                  return AppStrings.auth.nameTooShort;
                                }
                                return null;
                              },
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 100.ms)
                                .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                            const SizedBox(height: kSpacingMedium),

                            // 📧 שדה אימייל
                            _buildFormField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              label: AppStrings.auth.emailLabel,
                              hint: AppStrings.auth.emailHint,
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              semanticLabel: AppStrings.auth.emailFieldSemanticLabel,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppStrings.auth.emailRequired;
                                }
                                if (!value.contains('@') || !value.contains('.') ||
                                    value.indexOf('.') <= value.indexOf('@') + 1) {
                                  return AppStrings.auth.emailInvalid;
                                }
                                return null;
                              },
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 150.ms)
                                .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                            const SizedBox(height: kSpacingMedium),

                            // 📱 שדה טלפון (לפני סיסמה - שדות זיהוי קודם)
                            _buildFormField(
                              controller: _phoneController,
                              focusNode: _phoneFocusNode,
                              label: AppStrings.auth.phoneLabel,
                              hint: AppStrings.auth.phoneHint,
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              semanticLabel: AppStrings.auth.phoneFieldSemanticLabel,
                              helperText: AppStrings.auth.phoneHelperText,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppStrings.auth.phoneRequired;
                                }
                                final normalized = value.replaceAll('-', '').replaceAll(' ', '');
                                if (!_phoneRegex.hasMatch(normalized)) {
                                  return AppStrings.auth.phoneInvalid;
                                }
                                return null;
                              },
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 200.ms)
                                .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                            const SizedBox(height: kSpacingMedium),

                            // 🔒 שדה סיסמה
                            _buildFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              label: AppStrings.auth.passwordLabel,
                              hint: AppStrings.auth.passwordHint,
                              icon: Icons.lock_outlined,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                ),
                                onPressed: _togglePasswordVisibility,
                                tooltip: _obscurePassword ? AppStrings.auth.showPassword : AppStrings.auth.hidePassword,
                              ),
                              textInputAction: TextInputAction.next,
                              semanticLabel: AppStrings.auth.passwordFieldSemanticLabel,
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
                                .fadeIn(duration: 400.ms, delay: 250.ms)
                                .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                            const SizedBox(height: kSpacingMedium),

                            // 🔒 שדה אימות סיסמה
                            _buildFormField(
                              controller: _confirmPasswordController,
                              focusNode: _confirmPasswordFocusNode,
                              label: AppStrings.auth.confirmPasswordLabel,
                              hint: AppStrings.auth.confirmPasswordHint,
                              icon: Icons.lock_outlined,
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                ),
                                onPressed: _toggleConfirmPasswordVisibility,
                                tooltip: _obscureConfirmPassword
                                    ? AppStrings.auth.showPassword
                                    : AppStrings.auth.hidePassword,
                              ),
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) {
                                _onRegisterPressed();
                              },
                              semanticLabel: AppStrings.auth.confirmPasswordFieldSemanticLabel,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppStrings.auth.confirmPasswordRequired;
                                }
                                if (value != _passwordController.text) {
                                  return AppStrings.auth.passwordsDoNotMatch;
                                }
                                return null;
                              },
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 300.ms)
                                .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                            SizedBox(height: kSpacingLarge),

                            // 🔘 כפתור הרשמה - auto-contrast foreground + shimmer CTA
                            Builder(builder: (context) {
                              final ctaBg = brand?.success ?? cs.primary;
                              final ctaFg = ThemeData.estimateBrightnessForColor(ctaBg) == Brightness.light
                                  ? cs.onSurface
                                  : cs.onPrimary;
                              return FilledButton.icon(
                                onPressed: _isLoading ? null : _onRegisterPressed,
                                icon: const Icon(Icons.app_registration),
                                label: Text(AppStrings.auth.registerButton),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(kButtonHeight),
                                  backgroundColor: ctaBg,
                                  foregroundColor: ctaFg,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(kBorderRadiusUnified),
                                  ),
                                ),
                              );
                            })
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 350.ms)
                                .slideY(begin: 0.2, curve: Curves.easeOutCubic)
                                .then() // ✅ shimmer starts after entry animation
                                .shimmer(
                                  duration: kAnimationDurationSlow,
                                  color: cs.onPrimary.withValues(alpha: kOpacityLow),
                                  angle: kShimmerAngle,
                                  delay: 1200.ms,
                                ),
                            const SizedBox(height: kSpacingLarge),

                            // ➖ Divider עם "או הירשם במהירות עם"
                            Padding(
                              padding: const EdgeInsets.only(bottom: kSpacingMedium),
                              child: Row(
                                children: [
                                  Expanded(child: Divider(color: cs.outlineVariant)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
                                    child: Text(
                                      AppStrings.auth.orContinueWith,
                                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: kFontSizeSmall),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: cs.outlineVariant)),
                                ],
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 400.ms),

                            // 🔵 כפתורי Social Login
                            Row(
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
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 450.ms)
                                .slideY(begin: 0.15, curve: Curves.easeOutCubic),
                            const SizedBox(height: kSpacingMedium),

                            // 🔗 קישור להתחברות - Hybrid Premium style
                            Semantics(
                              label: AppStrings.auth.loginLinkSemanticLabel,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppStrings.auth.haveAccount,
                                    style: TextStyle(
                                      color: cs.onSurface.withValues(alpha: 0.55),
                                      fontSize: 15,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _isLoading ? null : _navigateToLogin,
                                    child: Text(
                                      AppStrings.auth.loginButton,
                                      style: TextStyle(
                                        color: accent.withValues(alpha: 0.75),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        decoration: TextDecoration.underline,
                                        decorationColor: accent.withValues(alpha: 0.45),
                                        decorationThickness: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 500.ms),
                            const SizedBox(height: kSpacingMedium),
                          ],
                        ),
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
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    color: cs.scrim.withValues(alpha: 0.25),
                    child: Center(child: _LoadingOverlay(color: accent)),
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
// 🌫️ Loading Overlay - טקסט משתנה + Spinner
// ═══════════════════════════════════════════════════════════════════════════

/// Glassmorphic loading overlay עם טקסט משתנה לחיזוק הציפייה
class _LoadingOverlay extends StatefulWidget {
  final Color color;
  const _LoadingOverlay({required this.color});

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay> {
  int _messageIndex = 0;
  late Timer _timer;

  static const _messages = [
    'יוצר חשבון...',
    'מכין את המזווה שלך...',
    'כמעט שם...',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        setState(() => _messageIndex = (_messageIndex + 1) % _messages.length);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: widget.color),
        const SizedBox(height: kSpacingMedium),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _messages[_messageIndex],
            key: ValueKey(_messageIndex),
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.8),
              fontSize: kFontSizeBody,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ✨ Shimmer On Focus - אפקט shimmer עדין בעת קבלת פוקוס
// ═══════════════════════════════════════════════════════════════════════════

/// Wrapper שמפעיל shimmer עדין פעם אחת כשהשדה מקבל פוקוס
class _ShimmerOnFocus extends StatefulWidget {
  final FocusNode focusNode;
  final Widget child;
  final Color shimmerColor;

  const _ShimmerOnFocus({
    required this.focusNode,
    required this.child,
    required this.shimmerColor,
  });

  @override
  State<_ShimmerOnFocus> createState() => _ShimmerOnFocusState();
}

class _ShimmerOnFocusState extends State<_ShimmerOnFocus> {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (widget.focusNode.hasFocus && mounted && _controller != null) {
      _controller!.forward(from: 0);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child
        .animate(
          autoPlay: false,
          onInit: (controller) => _controller = controller,
        )
        .shimmer(
          duration: 800.ms,
          color: widget.shimmerColor,
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

  const _SocialLoginButton({required this.icon, required this.label, required this.color, this.onPressed});

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
    final shadowColor = isDark ? cs.surfaceContainerLowest.withValues(alpha: 0.1) : cs.shadow.withValues(alpha: 0.15);

    return Semantics(
      button: true,
      label: AppStrings.auth.socialRegisterSemanticLabel(widget.label),
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
              color: isDisabled ? cs.surfaceContainerHighest.withValues(alpha: 0.5) : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(kBorderRadiusUnified),
              boxShadow: isDisabled ? null : [BoxShadow(color: shadowColor, blurRadius: 6, offset: const Offset(0, 3))],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: BorderRadius.circular(kBorderRadiusUnified),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: kSpacingSmall + 4, horizontal: kSpacingMedium),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        widget.icon,
                        size: 18,
                        color: isDisabled ? widget.color.withValues(alpha: 0.5) : widget.color,
                      ),
                      SizedBox(width: kSpacingSmall),
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: isDisabled ? cs.onSurface.withValues(alpha: 0.5) : cs.onSurface,
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
