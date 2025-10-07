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
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/demo_login_button.dart';
import '../../services/navigation_service.dart';

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
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// ✅ פונקציית Login עם Firebase Authentication
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // 🔹 1. התחברות דרך Firebase Auth
      final userContext = context.read<UserContext>();
      await userContext.signIn(
        email: email,
        password: password,
      );

      // ✅ signIn() זורק Exception אם נכשל, אחרת מצליח
      // ה-listener של authStateChanges יעדכן את isLoggedIn אוטומטית

      // 🔹 2. שמירה ב-SharedPreferences
      await NavigationService.saveUserId(userContext.userId!);
      await NavigationService.markOnboardingSeen();

      // 🔹 4. ניווט לדף הבית
      if (mounted) {
        setState(() => _isLoading = false);
        await NavigationService.goToHome(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });

      // הצגת הודעה למשתמש
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// ניווט למסך הרשמה
  void _navigateToRegister() {
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
              padding: const EdgeInsets.all(24),
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
                    const SizedBox(height: 24),

                    // כותרת
                    Text(
                      'התחברות',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ברוך שובך!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

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
                    const SizedBox(height: 16),

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
                    const SizedBox(height: 24),

                    // כפתור התחברות
                    AuthButton.primary(
                      onPressed: _isLoading ? null : _handleLogin,
                      isLoading: _isLoading,
                      label: 'התחבר',
                    ),
                    const SizedBox(height: 16),

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
                    const SizedBox(height: 24),

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
                    const SizedBox(height: 24),

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
