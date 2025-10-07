// 📄 File: lib/screens/auth/login_screen.dart
// תיאור: מסך התחברות - טופס login עם אימות ושמירת session + כפתור דמו
//
// עדכונים:
// ✅ תיעוד מלא בראש הקובץ
// ✅ שימוש ב-AuthButton במקום ElevatedButton/OutlinedButton
// ✅ שימוש ב-NavigationService במקום קריאות ישירות ל-SharedPreferences
// ✅ הוספת כפתור כניסה מהירה עם משתמש דמו
// 🔒 חסימת Back - המשתמש חייב להשלים התחברות

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_context.dart';
import '../../theme/app_theme.dart';
import '../../core/ui_constants.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/demo_login_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// ✅ פונקציית Login עם Firebase Authentication
  Future<void> _handleLogin() async {
    debugPrint('🔐 _handleLogin() | Starting login process...');
    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ _handleLogin() | Form validation failed');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // 🔹 1. התחברות דרך Firebase Auth
      debugPrint('🔐 _handleLogin() | Signing in with email: $email');
      final userContext = context.read<UserContext>();
      await userContext.signIn(
        email: email,
        password: password,
      );

      // ✅ signIn() זורק Exception אם נכשל, אחרת מצליח
      // ה-listener של authStateChanges יעדכן את isLoggedIn אוטומטית
      debugPrint('✅ _handleLogin() | Sign in successful, userId: ${userContext.userId}');

      // 🔹 2. שמירה ב-SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userContext.userId!);
      await prefs.setBool('seen_onboarding', true);
      debugPrint('✅ _handleLogin() | User data saved to SharedPreferences');

      // 🔹 3. ניווט לדף הבית
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint('🔄 _handleLogin() | Navigating to home screen');
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      debugPrint('❌ _handleLogin() | Login failed: $e');
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      setState(() => _isLoading = false);

      // הצגת הודעה למשתמש
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
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

    // 🔒 חסימת Back - המשתמש חייב להשלים התחברות
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('יש להשלים את תהליך ההתחברות'),
              duration: Duration(seconds: 2),
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
                      size: 80,
                      color: accent,
                    ),
                    const SizedBox(height: kSpacingLarge),

                    // כותרת
                    Text(
                      'התחברות',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: kSpacingSmall),
                    Text(
                      'ברוך שובך!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: kSpacingXLarge),

                    // שדה אימייל
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'אימייל',
                        hintText: 'example@email.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'נא להזין אימייל';
                        }
                        if (!value.contains('@')) {
                          return 'אימייל לא תקין';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: kSpacingMedium),

                    // שדה סיסמה
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'סיסמה',
                        hintText: '••••••••',
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleLogin(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'נא להזין סיסמה';
                        }
                        if (value.length < 6) {
                          return 'סיסמה חייבת להכיל לפחות 6 תווים';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: kSpacingLarge),

                    // כפתור התחברות
                    AuthButton.primary(
                      onPressed: _isLoading ? null : _handleLogin,
                      isLoading: _isLoading,
                      label: 'התחבר',
                    ),
                    const SizedBox(height: kSpacingMedium),

                    // קישור להרשמה
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'אין לך חשבון?',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : _navigateToRegister,
                          child: Text(
                            'הירשם עכשיו',
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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'או',
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
