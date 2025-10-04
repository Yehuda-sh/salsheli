// 📄 File: lib/screens/auth/register_screen.dart
// תיאור: מסך הרשמה - טופס יצירת חשבון חדש עם ולידציה + כפתור דמו
//
// עדכונים:
// ✅ תיעוד מלא בראש הקובץ
// ✅ שימוש ב-AuthButton במקום ElevatedButton/OutlinedButton
// ✅ שימוש ב-NavigationService במקום קריאות ישירות ל-SharedPreferences
// ✅ הוספת כפתור כניסה מהירה עם משתמש דמו
// 🔒 חסימת Back - המשתמש חייב להשלים הרשמה

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_context.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/demo_login_button.dart';
import '../../services/navigation_service.dart';

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
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// ✅ פונקציית Register מתוקנת - עם חיבור מלא
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();

      // 🔹 1. יצירת userId ייחודי
      final userId =
          '${email.split('@').first}_${DateTime.now().millisecondsSinceEpoch}';

      // 🔹 2. יצירת משתמש חדש דרך Repository
      final userContext = context.read<UserContext>();
      await userContext.loadUser(userId);

      // 🔹 3. עדכון שם המשתמש
      if (userContext.user != null) {
        final updatedUser = userContext.user!.copyWith(name: name);
        await userContext.saveUser(updatedUser);
      }

      // 🔹 4. בדיקה שהמשתמש נוצר בהצלחה
      if (!userContext.isLoggedIn) {
        throw Exception('לא ניתן ליצור משתמש חדש');
      }

      // 🔹 5. שמירה ב-SharedPreferences דרך NavigationService
      await NavigationService.saveUserId(userId);
      await NavigationService.markOnboardingSeen();

      // 🔹 6. ניווט לדף הבית
      if (mounted) {
        await NavigationService.goToHome(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'שגיאה בהרשמה: ${e.toString()}';
        _isLoading = false;
      });

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

  /// ניווט למסך התחברות
  void _navigateToLogin() {
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
            const SnackBar(
              content: Text('יש להשלים את תהליך ההרשמה'),
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
                      'הרשמה',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'צור חשבון חדש',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // שדה שם
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'שם מלא',
                        hintText: 'הזן את שמך',
                        prefixIcon: const Icon(Icons.person_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'נא להזין שם';
                        }
                        if (value.length < 2) {
                          return 'שם חייב להכיל לפחות 2 תווים';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

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
                      textInputAction: TextInputAction.next,
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
                    const SizedBox(height: 16),

                    // שדה אימות סיסמה
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'אימות סיסמה',
                        hintText: '••••••••',
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleRegister(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'נא לאמת את הסיסמה';
                        }
                        if (value != _passwordController.text) {
                          return 'הסיסמאות לא תואמות';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // כפתור הרשמה
                    AuthButton.primary(
                      onPressed: _isLoading ? null : _handleRegister,
                      isLoading: _isLoading,
                      label: 'הירשם',
                    ),
                    const SizedBox(height: 16),

                    // קישור להתחברות
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'כבר יש לך חשבון?',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : _navigateToLogin,
                          child: Text(
                            'התחבר',
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
