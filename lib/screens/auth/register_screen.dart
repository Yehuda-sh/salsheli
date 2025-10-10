// 📄 File: lib/screens/auth/register_screen.dart
// 🎯 Purpose: מסך הרשמה - טופס יצירת חשבון עם Firebase Auth
//
// 📋 Features:
// ✅ Firebase Authentication (email/password + name)
// ✅ Form validation עם אימות סיסמה
// ✅ AuthButton עם loading state
// ✅ DemoLoginButton לכניסה מהירה
// ✅ AppStrings - i18n ready
// ✅ ui_constants - עיצוב עקבי
// 🔒 PopScope - חסימת Back (חובה להשלים הרשמה)
//
// 🔗 Related:
// - UserContext - state management + Firebase Auth (Single Source of Truth)
// - LoginScreen - התחברות לחשבון קיים
// - AppStrings.auth - מחרוזות UI
//
// 📝 Version: 2.0 (10/10/2025)
// - הסרת SharedPreferences (UserContext = Single Source of Truth)
// - תיקון Context handling אחרי async
// - תיקון race condition logic

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_context.dart';
import '../../theme/app_theme.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/demo_login_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// ✅ פונקציית Register עם Firebase Authentication
  /// 
  /// תהליך:
  /// 1. Validation של הטופס
  /// 2. רישום דרך UserContext.signUp() (זורק Exception אם נכשל)
  /// 3. ניווט לדף הבית (אם הגענו לכאן = הצלחנו)
  Future<void> _handleRegister() async {
    debugPrint('📝 _handleRegister() | Starting registration process...');
    
    // Validation
    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ _handleRegister() | Form validation failed');
      return;
    }

    // שמירת context לפני async (למניעת "Context used after disposal")
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // רישום דרך UserContext (זורק Exception אם נכשל)
      debugPrint('📝 _handleRegister() | Signing up: $email (name: $name)');
      final userContext = context.read<UserContext>();
      await userContext.signUp(
        email: email,
        password: password,
        name: name,
      );

      // ✅ אם הגענו לכאן = הרישום הצליח!
      // UserContext מנהל את ה-session דרך Firebase Auth (Single Source of Truth)
      debugPrint('✅ _handleRegister() | Success! userId: ${userContext.userId}');

      // ניווט לדף הבית
      if (mounted) {
        debugPrint('🔄 _handleRegister() | Navigating to home screen');
        navigator.pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      debugPrint('❌ _handleRegister() | Registration failed: $e');
      
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      if (mounted) {
        setState(() => _isLoading = false);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: kSnackBarDurationLong,
          ),
        );
      }
    }
    
    debugPrint('🏁 _handleRegister() | Completed');
  }

  /// ניווט למסך התחברות
  void _navigateToLogin() {
    debugPrint('🔄 _navigateToLogin() | Navigating to login screen');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    // 🔒 חסימת Back - המשתמש חייב להשלים הרשמה
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.auth.mustCompleteRegister),
              duration: kSnackBarDuration,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(kSpacingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // לוגו/אייקון
                    Icon(
                      Icons.shopping_basket_outlined,
                      size: kIconSizeXLarge,
                      color: accent,
                    ),
                    const SizedBox(height: kSpacingLarge),

                    // כותרת
                    Text(
                      AppStrings.auth.registerTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: kSpacingSmall),
                    Text(
                      AppStrings.auth.registerSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: kSpacingXLarge),

                    // שדה שם
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: AppStrings.auth.nameLabel,
                        hintText: AppStrings.auth.nameHint,
                        prefixIcon: const Icon(Icons.person_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kBorderRadius),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
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

                    // שדה אימייל
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: AppStrings.auth.emailLabel,
                        hintText: AppStrings.auth.emailHint,
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kBorderRadius),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
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

                    // שדה סיסמה
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
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kBorderRadius),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
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

                    // שדה אימות סיסמה
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: AppStrings.auth.confirmPasswordLabel,
                        hintText: AppStrings.auth.confirmPasswordHint,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kBorderRadius),
                        ),
                      ),
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleRegister(),
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
                    const SizedBox(height: kSpacingLarge),

                    // כפתור הרשמה
                    AuthButton.primary(
                      onPressed: _isLoading ? null : _handleRegister,
                      isLoading: _isLoading,
                      label: AppStrings.auth.registerButton,
                    ),
                    const SizedBox(height: kSpacingMedium),

                    // קישור להתחברות
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.auth.haveAccount,
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : _navigateToLogin,
                          child: Text(
                            AppStrings.auth.loginButton,
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: kSpacingLarge),

                    // מפריד
                    Row(
                      children: [
                        Expanded(child: Divider(color: cs.outlineVariant)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                          child: Text(
                            AppStrings.auth.or,
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ),
                        Expanded(child: Divider(color: cs.outlineVariant)),
                      ],
                    ),
                    const SizedBox(height: kSpacingLarge),

                    // כפתור כניסה מהירה
                    const DemoLoginButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
