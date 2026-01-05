// 📄 lib/screens/auth/register_screen.dart
//
// **מסך הרשמה** - יצירת חשבון חדש עם Firebase Auth.
// כולל Form validation, shake animation לשגיאות,
// ועיצוב Sticky Notes עם תמיכה מלאה ב-RTL ו-Dark Mode.
//
// ✅ Features:
//    - Form validation עם הודעות שגיאה בעברית
//    - Shake animation לפידבק ויזואלי על שגיאות
//    - Theme-aware colors (Dark Mode support)
//    - Accessibility: Semantics + Tooltips
//    - RTL support מלא
//    - בדיקת הזמנות ממתינות לקבוצות אחרי הרשמה
//
// 🔗 Related: UserContext, LoginScreen, PendingInvitesProvider
//
// ----------------------------------------------------------------------------
// The RegisterScreen widget handles new user registration with Firebase Auth.
// Features form validation with Hebrew error messages, shake animation for
// error feedback, and checks for pending group invitations after signup.
// ----------------------------------------------------------------------------

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/status_colors.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../providers/pending_invites_provider.dart';
import '../../providers/user_context.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_button.dart';
import '../../widgets/common/sticky_note.dart';

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
  bool _showSocialButtons = false; // 🎬 לאנימציית כניסה

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

  @override
  void initState() {
    super.initState();
    
    // 🎬 הגדרת shake animation לשגיאות
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    
    // 🎯 Auto-focus על שדה שם בכניסה למסך
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _nameFocusNode.requestFocus();
      }
    });

    // 🎬 אנימציית כניסה לכפתורי Social Login
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _showSocialButtons = true);
      }
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
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

  /// ✅ פונקציית Register עם Firebase Authentication
  Future<void> _handleRegister() async {
    debugPrint('📝 _handleRegister() | Starting registration process...');
    
    // Validation
    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ _handleRegister() | Form validation failed');
      unawaited(_shakeController.forward(from: 0)); // 🎬 Shake animation
      return;
    }

    // שמירת context לפני async
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim().replaceAll('-', '').replaceAll(' ', '');
      final password = _passwordController.text;

      // רישום דרך UserContext
      debugPrint('📝 _handleRegister() | Signing up...');
      final userContext = context.read<UserContext>();
      await userContext.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      // ✅ הרישום הצליח!
      debugPrint('✅ _handleRegister() | Success! userId: ${userContext.userId}');

      // 📨 בדיקת הזמנות ממתינות לקבוצות
      if (mounted) {
        final pendingInvitesProvider = context.read<PendingInvitesProvider>();
        await pendingInvitesProvider.checkPendingInvites(
          phone: phone,
          email: email,
        );
        debugPrint('📨 Checked pending invites: ${pendingInvitesProvider.pendingCount} found');
      }

      // 🎉 הצגת feedback ויזואלי + ניווט
      if (mounted) {
        setState(() => _isLoading = false);

        final pendingInvitesProvider = context.read<PendingInvitesProvider>();
        final hasPendingInvites = pendingInvitesProvider.pendingCount > 0;

        if (hasPendingInvites) {
          // 📨 יש הזמנות ממתינות - הצג דיאלוג
          final goToInvites = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              final dialogBrand = Theme.of(dialogContext).extension<AppBrand>();
              final dialogCs = Theme.of(dialogContext).colorScheme;
              // ✅ צבע אזהרה מ-Theme (תומך Dynamic Color)
              final warningColor = dialogBrand?.warning ?? dialogCs.tertiary;

              return AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.group_add, color: warningColor, size: 28),
                    const SizedBox(width: kSpacingSmall),
                    const Text('הזמנות ממתינות!'),
                  ],
                ),
                content: Text(
                  'יש לך ${pendingInvitesProvider.pendingCount} הזמנות לקבוצות ממתינות לאישור.\n\nהאם לעבור למסך ההזמנות?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('אחר כך'),
                  ),
                  // ✅ כפתור ללא style מותאם - נותן ל-Theme להחליט
                  ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('צפה בהזמנות'),
                  ),
                ],
              );
            },
          );

          if (mounted) {
            if (goToInvites == true) {
              // נווט למסך ההזמנות
              await navigator.pushNamedAndRemoveUntil('/home', (route) => false);
              if (mounted) {
                await navigator.pushNamed('/pending-group-invites');
              }
            } else {
              // נווט לדף הבית
              await navigator.pushNamedAndRemoveUntil('/home', (route) => false);
            }
          }
        } else {
          // 🎉 הודעת הצלחה רגילה
          // ✅ שימוש ב-StatusColors API
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: StatusColors.getOnStatusContainer('success', context), size: 24),
                  const SizedBox(width: kSpacingSmall),
                  Text(
                    'הרשמת בהצלחה! מעביר לדף הבית...',
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

          // ⏱️ המתנה קצרה לפני ניווט
          await Future.delayed(const Duration(milliseconds: 1500));

          if (mounted) {
            debugPrint('🔄 _handleRegister() | Navigating to home screen');
            await navigator.pushNamedAndRemoveUntil('/home', (route) => false);
          }
        }
      }
    } catch (e) {
      debugPrint('❌ _handleRegister() | Registration failed: $e');
      
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      if (mounted) {
        setState(() => _isLoading = false);
        unawaited(_shakeController.forward(from: 0)); // 🎬 Shake animation

        // 🎨 הודעת שגיאה משופרת
        // ✅ שימוש ב-StatusColors API
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: StatusColors.getOnStatusContainer('error', context), size: 24),
                const SizedBox(width: kSpacingSmall),
                Expanded(
                  child: Text(
                    errorMessage,
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
    
    debugPrint('🏁 _handleRegister() | Completed');
  }

  /// ניווט למסך התחברות
  void _navigateToLogin() {
    debugPrint('🔄 _navigateToLogin() | Navigating to login screen');
    unawaited(Navigator.pushReplacementNamed(context, '/login'));
  }

  /// טיפול בלחיצה על כפתור הרשמה
  void _onRegisterPressed() {
    unawaited(_handleRegister());
  }

  /// 🔵 התחברות עם Google
  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final userContext = context.read<UserContext>();
      final navigator = Navigator.of(context);

      await userContext.signInWithGoogle();

      if (mounted) {
        setState(() => _isLoading = false);
        await navigator.pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      debugPrint('❌ _handleGoogleSignIn: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        // שגיאות ביטול לא מציגות הודעה
        if (!e.toString().contains('בוטל')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString().replaceAll('Exception: ', ''),
                style: TextStyle(color: StatusColors.getOnStatusContainer('error', context)),
              ),
              backgroundColor: StatusColors.getStatusContainer('error', context),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  /// 🍎 התחברות עם Apple
  Future<void> _handleAppleSignIn() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final userContext = context.read<UserContext>();
      final navigator = Navigator.of(context);

      await userContext.signInWithApple();

      if (mounted) {
        setState(() => _isLoading = false);
        await navigator.pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      debugPrint('❌ _handleAppleSignIn: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        // שגיאות ביטול לא מציגות הודעה
        if (!e.toString().contains('בוטל')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString().replaceAll('Exception: ', ''),
                style: TextStyle(color: StatusColors.getOnStatusContainer('error', context)),
              ),
              backgroundColor: StatusColors.getStatusContainer('error', context),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  /// 🎨 Helper method לבניית שדה טופס עטוף ב-StickyNote
  /// ✅ כולל Semantics לנגישות
  Widget _buildFormField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
    double rotation = 0.0,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
    void Function(String)? onFieldSubmitted,
    String? Function(String?)? validator,
    String? semanticLabel, // ✅ תיאור לנגישות
    String? helperText, // ✅ טקסט עזרה מתחת לשדה
  }) {
    return Semantics(
      label: semanticLabel ?? label,
      textField: true,
      child: StickyNote(
        color: color,
        rotation: rotation,
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            // ✅ Focus border צבע מ-Theme
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: kSpacingMedium,
              vertical: kSpacingSmall,
            ),
            helperText: helperText,
            helperStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: kFontSizeTiny,
            ),
          ),
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;
    // ✅ צבע Sticky Note מ-Theme (תומך Dark Mode)
    final yellow = brand?.stickyYellow ?? kStickyYellow;

    // 🔒 חזרה ל-login במקום welcome
    return Directionality(
      textDirection: TextDirection.rtl, // 🔄 תמיכה מלאה ב-RTL
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            // נווט ל-login במקום ל-welcome
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            });
          }
        },
        child: Scaffold(
        // ✅ צבע רקע מ-Theme (תומך Dark Mode)
        backgroundColor: brand?.paperBackground ?? theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            // 📓 רקע מחברת עם קווים
            const NotebookBackground(),
            
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
                      return Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: child,
                      );
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

                          // 📝 כותרת פשוטה - בלי לוגו
                          Text(
                            AppStrings.auth.registerTitle,
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
                            AppStrings.auth.registerSubtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              // ✅ צבע מ-Theme (תומך Dark Mode)
                              color: cs.onSurfaceVariant,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: kSpacingLarge),

                          // 👤 שדה שם - פתק צהוב בהיר
                          _buildFormField(
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            label: AppStrings.auth.nameLabel,
                            hint: AppStrings.auth.nameHint,
                            icon: Icons.person_outlined,
                            color: yellow,
                            rotation: 0.008,
                            textInputAction: TextInputAction.next,
                            semanticLabel: 'שדה שם מלא, חובה', // ✅ Accessibility
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.auth.nameRequired;
                              }
                              if (value.length < 2) {
                                return AppStrings.auth.nameTooShort;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: kSpacingMedium),

                          // 📧 שדה אימייל - פתק צהוב בהיר
                          _buildFormField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            label: AppStrings.auth.emailLabel,
                            hint: AppStrings.auth.emailHint,
                            icon: Icons.email_outlined,
                            color: yellow,
                            rotation: -0.01,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            semanticLabel: 'שדה כתובת אימייל, חובה', // ✅ Accessibility
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
                          const SizedBox(height: kSpacingMedium),

                          // 🔒 שדה סיסמה - פתק צהוב בהיר
                          _buildFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            label: AppStrings.auth.passwordLabel,
                            hint: AppStrings.auth.passwordHint,
                            icon: Icons.lock_outlined,
                            color: yellow,
                            rotation: 0.012,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: _togglePasswordVisibility,
                              tooltip: _obscurePassword ? 'הצג סיסמה' : 'הסתר סיסמה', // ✅ Accessibility
                            ),
                            textInputAction: TextInputAction.next,
                            semanticLabel: 'שדה סיסמה, לפחות 6 תווים', // ✅ Accessibility
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
                          const SizedBox(height: kSpacingMedium),

                          // 🔒 שדה אימות סיסמה - פתק צהוב בהיר
                          _buildFormField(
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocusNode,
                            label: AppStrings.auth.confirmPasswordLabel,
                            hint: AppStrings.auth.confirmPasswordHint,
                            icon: Icons.lock_outlined,
                            color: yellow,
                            rotation: -0.008,
                            obscureText: _obscureConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: _toggleConfirmPasswordVisibility,
                              tooltip: _obscureConfirmPassword ? 'הצג סיסמה' : 'הסתר סיסמה', // ✅ Accessibility
                            ),
                            textInputAction: TextInputAction.next,
                            semanticLabel: 'שדה אימות סיסמה, חייב להתאים לסיסמה', // ✅ Accessibility
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.auth.confirmPasswordRequired;
                              }
                              if (value != _passwordController.text) {
                                return AppStrings.auth.passwordsDoNotMatch;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: kSpacingMedium),

                          // 📱 שדה טלפון - פתק צהוב בהיר
                          _buildFormField(
                            controller: _phoneController,
                            focusNode: _phoneFocusNode,
                            label: AppStrings.auth.phoneLabel,
                            hint: AppStrings.auth.phoneHint,
                            icon: Icons.phone_outlined,
                            color: yellow,
                            rotation: 0.006,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) { _onRegisterPressed(); },
                            semanticLabel: 'שדה טלפון נייד ישראלי, חובה', // ✅ Accessibility
                            helperText: 'מספר נייד ישראלי - לקבלת עדכונים מהקבוצות', // ✅ Helper text
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
                          ),
                          const SizedBox(height: kSpacingLarge),

                          // 🔘 כפתור הרשמה - צבע success עדין יותר
                          StickyButton(
                            color: brand?.success ?? cs.primaryContainer,
                            label: AppStrings.auth.registerButton,
                            icon: Icons.app_registration,
                            onPressed: _isLoading ? null : _onRegisterPressed,
                            height: 52,
                          ),
                          const SizedBox(height: kSpacingLarge),

                          // ➖ Divider עם "או הירשם במהירות עם" - אנימציה יחד עם Social buttons
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
                                      AppStrings.auth.orContinueWith,
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

                          // 🔗 קישור להתחברות - בולט יותר
                          // ✅ Semantics לנגישות
                          Semantics(
                            label: 'יש לך חשבון? לחץ לעבור למסך התחברות',
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppStrings.auth.haveAccount,
                                  // ✅ צבע מ-Theme (תומך Dark Mode)
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 15,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _isLoading ? null : _navigateToLogin,
                                  child: Text(
                                    AppStrings.auth.loginButton,
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
                          ),
                          const SizedBox(height: kSpacingMedium),
                        ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // ✅ Loading overlay עם blur - אפקט iOS-like
            if (_isLoading)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.25),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: cs.primary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
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
      label: 'הירשם או התחבר באמצעות ${widget.label}',
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
