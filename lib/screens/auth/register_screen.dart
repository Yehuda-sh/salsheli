// 📄 File: lib/screens/auth/register_screen.dart
// 🎯 Purpose: מסך הרשמה - טופס יצירת חשבון עם Firebase Auth
//
// 📋 Features:
// ✅ Firebase Authentication (email/password + name)
// ✅ Form validation עם אימות סיסמה
// ✅ StickyButton עם loading state + animations
// ✅ AppStrings - i18n ready
// ✅ ui_constants - עיצוב עקבי
// ✅ Sticky Notes Design System 🎨📝 ⭐ חדש!
// 🔙 PopScope - חזרה ל-login (לא חסימה)
// 🚫 הוסרה כניסת Demo (26/10/2025)
//
// 🎨 UI/UX Improvements (15/10/2025): ⭐
// - מעוצב כולו עם Sticky Notes Design System!
// - רקע מחברת עם קווים כחולים וקו אדום
// - לוגו בפתק צהוב מסובב
// - כותרת בפתק לבן מסובב
// - שדות טקסט בפתקים צבעוניים (סגול, תכלת, ירוק, ורוד)
// - כפתורים בסגנון StickyButton
// - קישור התחברות בפתק תכלת
// - רווחים מותאמים למסך אחד ללא גלילה 📐
//
// 🔗 Related:
// - UserContext - state management + Firebase Auth (Single Source of Truth)
// - LoginScreen - התחברות לחשבון קיים
// - AppStrings.auth - מחרוזות UI
//
// 📝 Version: 4.0 - Clean design without logo, unified colors
// 📅 Updated: 16/12/2025

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.group_add, color: Colors.orange, size: 28),
                  SizedBox(width: kSpacingSmall),
                  Text('הזמנות ממתינות!'),
                ],
              ),
              content: Text(
                'יש לך ${pendingInvitesProvider.pendingCount} הזמנות לקבוצות ממתינות לאישור.\n\nהאם לעבור למסך ההזמנות?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('אחר כך'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('צפה בהזמנות'),
                ),
              ],
            ),
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
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 24),
                  SizedBox(width: kSpacingSmall),
                  Text('הרשמת בהצלחה! מעביר לדף הבית...'),
                ],
              ),
              backgroundColor: Colors.green.shade700,
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
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 24),
                const SizedBox(width: kSpacingSmall),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(fontSize: kFontSizeSmall),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
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

  /// 🎨 Helper method לבניית שדה טופס עטוף ב-StickyNote
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
  }) {
    return StickyNote(
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
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: kSpacingMedium,
            vertical: kSpacingSmall,
          ),
        ),
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        onFieldSubmitted: onFieldSubmitted,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

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
        backgroundColor: kPaperBackground, // 🎨 צבע רקע מחברת
        body: Stack(
          children: [
            // 📓 רקע מחברת עם קווים
            const NotebookBackground(),
            
            // תוכן המסך
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSpacingMedium, // 📐 צמצום padding צדדי
                    vertical: kSpacingSmall, // 📐 צמצום padding עליון/תחתון
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

                          // 📝 כותרת פשוטה - בלי לוגו
                          Text(
                            AppStrings.auth.registerTitle,
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 36,
                              color: Colors.black87,
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.auth.registerSubtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.black54,
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
                            color: kStickyYellow,
                            rotation: 0.008,
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

                          // 📧 שדה אימייל - פתק צהוב בהיר
                          _buildFormField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            label: AppStrings.auth.emailLabel,
                            hint: AppStrings.auth.emailHint,
                            icon: Icons.email_outlined,
                            color: kStickyYellow,
                            rotation: -0.01,
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

                          // 🔒 שדה סיסמה - פתק צהוב בהיר
                          _buildFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            label: AppStrings.auth.passwordLabel,
                            hint: AppStrings.auth.passwordHint,
                            icon: Icons.lock_outlined,
                            color: kStickyYellow,
                            rotation: 0.012,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: _togglePasswordVisibility,
                            ),
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

                          // 🔒 שדה אימות סיסמה - פתק צהוב בהיר
                          _buildFormField(
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocusNode,
                            label: AppStrings.auth.confirmPasswordLabel,
                            hint: AppStrings.auth.confirmPasswordHint,
                            icon: Icons.lock_outlined,
                            color: kStickyYellow,
                            rotation: -0.008,
                            obscureText: _obscureConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: _toggleConfirmPasswordVisibility,
                            ),
                            textInputAction: TextInputAction.next,
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
                            color: kStickyYellow,
                            rotation: 0.006,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) { _onRegisterPressed(); },
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

                          // 🔘 כפתור הרשמה
                          StickyButton(
                            color: accent,
                            label: AppStrings.auth.registerButton,
                            icon: Icons.app_registration,
                            onPressed: _isLoading ? null : _onRegisterPressed,
                            height: 52,
                          ),
                          const SizedBox(height: kSpacingMedium),

                          // 🔗 קישור להתחברות - טקסט פשוט
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppStrings.auth.haveAccount,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15,
                                ),
                              ),
                              TextButton(
                                onPressed: _isLoading ? null : _navigateToLogin,
                                child: Text(
                                  AppStrings.auth.loginButton,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
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
          ],
        ),
      ),
    ),
    );
  }
}
