// 📄 File: lib/screens/auth/register_screen.dart
// 🎯 Purpose: מסך הרשמה - טופס יצירת חשבון עם Firebase Auth
//
// 📋 Features:
// ✅ Firebase Authentication (email/password + name)
// ✅ Form validation עם אימות סיסמה
// ✅ AuthButton עם loading state + animations
// ✅ DemoLoginButton לכניסה מהירה
// ✅ AppStrings - i18n ready
// ✅ ui_constants - עיצוב עקבי
// ✅ Enhanced UX - Improved visual feedback 🎨 ⭐ חדש!
// 🔒 PopScope - חסימת Back (חובה להשלים הרשמה)
//
// 🎨 UI/UX Improvements (14/10/2025): ⭐
// - כותרת גדולה ומודגשת יותר
// - אייקון לוגו עם רקע מעגלי עדין
// - קישור "התחבר" עם underline
// - מרווחים משופרים בין אלמנטים
// - הודעות שגיאה ויזואליות עם אייקונים
// - Animation feedback על שגיאות
// - Tooltip להצגת/הסתרת סיסמה
//
// 🔗 Related:
// - UserContext - state management + Firebase Auth (Single Source of Truth)
// - LoginScreen - התחברות לחשבון קיים
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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _shakeController.dispose(); // ⭐ חדש!
    super.dispose();
  }

  /// ✅ פונקציית Register עם Firebase Authentication
  /// 
  /// שיפורים (v2.1): ⭐
  /// - הודעות שגיאה משופרות עם אייקונים
  /// - Animation feedback על שגיאות
  /// - SnackBar מעוצב יותר
  Future<void> _handleRegister() async {
    debugPrint('📝 _handleRegister() | Starting registration process...');
    
    // Validation
    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ _handleRegister() | Form validation failed');
      _shakeController.forward(from: 0); // 🎬 Shake animation ⭐
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
        _shakeController.forward(from: 0); // 🎬 Shake animation ⭐
        
        // 🎨 הודעת שגיאה משופרת ⭐
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 24), // ⭐ אייקון
                const SizedBox(width: kSpacingSmall),
                Expanded(
                  child: Text(
                    errorMessage,
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
                      // 🎨 לוגו/אייקון עם רקע מעגלי עדין ⭐
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

                      // כותרת - גדול ומודגש יותר ⭐
                      Text(
                        AppStrings.auth.registerTitle, // "הרשמה"
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 32, // ⭐ גדול יותר
                          color: cs.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: kSpacingSmall),
                      Text(
                        AppStrings.auth.registerSubtitle, // "צור חשבון חדש"
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontSize: kFontSizeMedium, // ⭐ גודל מותאם
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

                      // שדה סיסמה - עם tooltip ⭐
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
                            tooltip: _obscurePassword ? 'הצג סיסמה' : 'הסתר סיסמה', // ⭐ tooltip
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

                      // שדה אימות סיסמה - עם tooltip ⭐
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
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                            tooltip: _obscureConfirmPassword ? 'הצג סיסמה' : 'הסתר סיסמה', // ⭐ tooltip
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

                      // כפתור הרשמה - עם animations ⭐
                      AuthButton.primary(
                        onPressed: _isLoading ? null : () => _handleRegister(),
                        isLoading: _isLoading,
                        label: AppStrings.auth.registerButton,
                      ),
                      const SizedBox(height: kSpacingMedium),

                      // 🎨 קישור להתחברות - משופר! ⭐
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.auth.haveAccount, // "יש לך חשבון?"
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: kFontSizeSmall,
                            ),
                          ),
                          const SizedBox(width: kSpacingXSmall), // ⭐ רווח קטן
                          TextButton(
                            onPressed: _isLoading ? null : _navigateToLogin,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: kSpacingSmall,
                                vertical: kSpacingXSmall,
                              ),
                            ),
                            child: Text(
                              AppStrings.auth.loginButton, // "התחבר"
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
                      const SizedBox(height: kSpacingXXLarge), // ⭐ מרווח גדול יותר

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
                      const SizedBox(height: kSpacingXLarge), // ⭐ מרווח גדול יותר

                      // כפתור כניסה מהירה - משופר! ⭐
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
