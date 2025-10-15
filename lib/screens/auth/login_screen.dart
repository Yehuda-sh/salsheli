// 📄 File: lib/screens/auth/login_screen.dart
// 🎯 Purpose: מסך התחברות - טופס login עם Firebase Auth + session management
//
// 📋 Features:
// ✅ Firebase Authentication (email/password)
// ✅ Form validation עם הודעות שגיאה
// ✅ AuthButton עם loading state + animations
// ✅ DemoLoginButton לכניסה מהירה
// ✅ AppStrings - i18n ready
// ✅ ui_constants - עיצוב עקבי
// ✅ Enhanced UX - Improved visual feedback 🎨 ⭐ חדש!
// 🔒 PopScope - חסימת Back (חובה להשלים התחברות)
//
// 🎨 UI/UX Improvements (14/10/2025): ⭐
// - שיפור קישור "הירשם עכשיו" - underline + צבע מודגש
// - מרווחים משופרים בין אלמנטים
// - הודעות שגיאה ויזואליות עם אייקונים
// - Animation feedback על שגיאות
//
// 🔗 Related:
// - UserContext - state management + Firebase Auth
// - RegisterScreen - יצירת חשבון חדש
// - SharedPreferences - שמירת seenOnboarding בלבד (לא user_id!)
// - AppStrings.auth - מחרוזות UI
//
// 📝 Version: 2.1 - Enhanced UX + Visual Improvements ⭐
// 📅 Updated: 14/10/2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_context.dart';
import '../../theme/app_theme.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/demo_login_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  
  // 🎬 Animation controller לשגיאות ⭐ חדש!
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    
    // 🎬 הגדרת shake animation לשגיאות ⭐
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _shakeController.dispose(); // ⭐ חדש!
    super.dispose();
  }

  /// ✅ פונקציית Login עם Firebase Authentication
  /// 
  /// שיפורים (v2.1): ⭐
  /// - הודעות שגיאה משופרות עם אייקונים
  /// - Animation feedback על שגיאות
  /// - SnackBar מעוצב יותר
  Future<void> _handleLogin() async {
    debugPrint('🔐 _handleLogin() | Starting login process...');
    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ _handleLogin() | Form validation failed');
      _shakeController.forward(from: 0); // 🎬 Shake animation ⭐
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
      debugPrint('🔐 _handleLogin() | Signing in with email: $email');
      await userContext.signIn(
        email: email,
        password: password,
      );

      // ✅ signIn() זורק Exception אם נכשל, אחרת מצליח
      // ה-listener של authStateChanges יעדכן את isLoggedIn אוטומטית
      debugPrint('✅ _handleLogin() | Sign in successful, userId: ${userContext.userId}');

      // 🔹 2. שמירה ב-SharedPreferences (רק seenOnboarding!)
      // ⚠️ לא שומרים user_id - UserContext כבר מחזיק את זה מ-Firebase!
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seen_onboarding', true);
      debugPrint('✅ _handleLogin() | Onboarding flag saved (not user_id - UserContext has it!)');

      // 🔹 3. ניווט לדף הבית
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint('🔄 _handleLogin() | Navigating to home screen');
        navigator.pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      debugPrint('❌ _handleLogin() | Login failed: $e');
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      
      if (mounted) {
        setState(() => _isLoading = false);
        _shakeController.forward(from: 0); // 🎬 Shake animation ⭐
        
        // 🎨 הודעת שגיאה משופרת ⭐
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 24), // ⭐ אייקון
                const SizedBox(width: kSpacingSmall),
                Expanded(
                  child: Text(
                    errorMsg,
                    style: const TextStyle(fontSize: kFontSizeSmall),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            duration: kSnackBarDurationLong,
            behavior: SnackBarBehavior.floating, // ⭐ floating למראה מודרני
            shape: RoundedRectangleBorder( // ⭐ פינות מעוגלות
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            margin: const EdgeInsets.all(kSpacingMedium), // ⭐ margin
          ),
        );
      }
    }
    debugPrint('🏁 _handleLogin() | Completed');
  }

  /// ניווט למסך הרשמה
  void _navigateToRegister() {
    debugPrint('🔄 _navigateToRegister() | Navigating to register screen');
    Navigator.pushReplacementNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    // 💡 שמור messenger לפני PopScope (best practice)
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
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(kSpacingLarge),
              child: AnimatedBuilder( // 🎬 Shake animation wrapper ⭐
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
                      // 🎨 לוגו/אייקון עם רקע מעגלי עדין ⭐ (שיפור #1)
                      Container(
                        padding: const EdgeInsets.all(kSpacingLarge),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withValues(alpha: 0.1), // ⭐ רקע עדין
                        ),
                        child: Icon(
                          Icons.shopping_basket_outlined,
                          size: kIconSizeXLarge,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: kSpacingLarge),

                      // כותרת - גדול ומודגש יותר ⭐ (שיפור #2)
                      Text(
                        AppStrings.auth.loginTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 32, // ⭐ גדול יותר
                          color: cs.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: kSpacingSmall),
                      Text(
                        AppStrings.auth.loginSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontSize: kFontSizeMedium, // ⭐ גודל מותאם
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: kSpacingXLarge),

                      // שדה אימייל - עם אייקון ⭐
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: AppStrings.auth.emailLabel,
                          hintText: AppStrings.auth.emailHint,
                          prefixIcon: const Icon(Icons.email_outlined), // ⭐ כבר יש
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

                      // שדה סיסמה - עם "הצג סיסמה" ⭐
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: AppStrings.auth.passwordLabel,
                          hintText: AppStrings.auth.passwordHint,
                          prefixIcon: const Icon(Icons.lock_outlined), // ⭐ כבר יש
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
                            tooltip: _obscurePassword ? 'הצג סיסמה' : 'הסתר סיסמה', // ⭐ tooltip
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(kBorderRadius),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
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
                      const SizedBox(height: kSpacingLarge),

                      // כפתור התחברות - עם animations ⭐
                      AuthButton.primary(
                        onPressed: _isLoading ? null : _handleLogin,
                        isLoading: _isLoading,
                        label: AppStrings.auth.loginButton,
                      ),
                      const SizedBox(height: kSpacingMedium),

                      // 🎨 קישור להרשמה - משופר! ⭐ (שיפור #6)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.auth.noAccount, // "אין לך חשבון?"
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: kFontSizeSmall,
                            ),
                          ),
                          const SizedBox(width: kSpacingXSmall), // ⭐ רווח קטן
                          TextButton(
                            onPressed: _isLoading ? null : _navigateToRegister,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: kSpacingSmall,
                                vertical: kSpacingXSmall,
                              ),
                            ),
                            child: Text(
                              AppStrings.auth.registerNow, // "הירשם עכשיו"
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline, // ⭐ underline!
                                decorationColor: accent, // ⭐ צבע ה-underline
                                decorationThickness: 2, // ⭐ עובי
                                fontSize: kFontSizeSmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: kSpacingXXLarge), // ⭐ מרווח גדול יותר (שיפור #8)

                      // מפריד
                      Row(
                        children: [
                          Expanded(child: Divider(color: cs.outlineVariant)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                            child: Text(
                              AppStrings.auth.or,
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: kFontSizeSmall,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: cs.outlineVariant)),
                        ],
                      ),
                      const SizedBox(height: kSpacingXLarge), // ⭐ מרווח גדול יותר (שיפור #8)

                      // כפתור כניסה מהירה - משופר! ⭐ (שיפור #7)
                      const DemoLoginButton(),
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
