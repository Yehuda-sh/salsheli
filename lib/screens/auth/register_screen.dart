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
// 🔒 PopScope - חסימת Back (חובה להשלים הרשמה)
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
// 📝 Version: 3.2 - Removed Demo Login
// 📅 Updated: 26/10/2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_context.dart';
import '../../theme/app_theme.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';

import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_note.dart';
import '../../widgets/common/sticky_button.dart';

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
  
  // 🎬 Animation controller לשגיאות
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  
  // 🎯 Focus nodes for auto-focus
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _shakeController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
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
      _shakeController.forward(from: 0); // 🎬 Shake animation
      return;
    }

    // שמירת context לפני async
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // רישום דרך UserContext
      debugPrint('📝 _handleRegister() | Signing up...');
      final userContext = context.read<UserContext>();
      await userContext.signUp(
        email: email,
        password: password,
        name: name,
      );

      // ✅ הרישום הצליח!
      debugPrint('✅ _handleRegister() | Success! userId: ${userContext.userId}');

      // 🎉 הצגת feedback ויזואלי + ניווט
      if (mounted) {
        setState(() => _isLoading = false);
        
        // 🎉 הודעת הצלחה
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 24),
                const SizedBox(width: kSpacingSmall),
                const Text('הרשמת בהצלחה! מעביר לדף הבית...'),
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
          navigator.pushNamedAndRemoveUntil('/home', (route) => false);
        }
      }
    } catch (e) {
      debugPrint('❌ _handleRegister() | Registration failed: $e');
      
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      if (mounted) {
        setState(() => _isLoading = false);
        _shakeController.forward(from: 0); // 🎬 Shake animation
        
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
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    // 💡 שמור messenger לפני PopScope
    final messenger = ScaffoldMessenger.of(context);

    // 🔒 חסימת Back - המשתמש חייב להשלים הרשמה
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(AppStrings.auth.mustCompleteRegister),
              duration: kSnackBarDuration,
            ),
          );
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
                          const SizedBox(height: kSpacingSmall), // 📐 רווח קטן מלמעלה
                          
                          // 🟨 לוגו בפתק צהוב מסובב - גודל מצומצם
                          Hero(
                            tag: 'app_logo',
                            child: Transform.scale(
                              scale: 0.85, // 📐 הקטנת הלוגו ב-15%
                              child: StickyNoteLogo(
                                color: kStickyYellow,
                                icon: Icons.shopping_basket_outlined,
                                iconColor: accent,
                                rotation: -0.03,
                              ),
                            ),
                          ),
                          const SizedBox(height: kSpacingSmall), // 📐 רווח קטן

                          // 📝 כותרת בפתק לבן מסובב - גודל מצומצם
                          StickyNote(
                            color: Colors.white,
                            rotation: -0.02,
                            child: Column(
                              children: [
                                Text(
                                  AppStrings.auth.registerTitle,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24, // 📐 גודל מצומצם
                                    color: cs.onSurface,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppStrings.auth.registerSubtitle,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontSize: kFontSizeSmall,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: kSpacingSmall), // 📐 רווח קטן

                          // 🟣 שדה שם בפתק סגול
                          StickyNote(
                            color: kStickyPurple,
                            rotation: 0.01,
                            child: TextFormField(
                              controller: _nameController,
                              focusNode: _nameFocusNode,
                              decoration: InputDecoration(
                                labelText: AppStrings.auth.nameLabel,
                                hintText: AppStrings.auth.nameHint,
                                prefixIcon: const Icon(Icons.person_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(kBorderRadius),
                                ),
                                filled: true,
                                fillColor: cs.surface.withValues(alpha: 0.9),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: kSpacingMedium,
                                  vertical: kSpacingSmall,
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
                          ),
                          const SizedBox(height: kSpacingSmall), // 📐 רווח קטן

                          // 🔵 שדה אימייל בפתק תכלת
                          StickyNote(
                            color: kStickyCyan,
                            rotation: -0.015,
                            child: TextFormField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              decoration: InputDecoration(
                                labelText: AppStrings.auth.emailLabel,
                                hintText: AppStrings.auth.emailHint,
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(kBorderRadius),
                                ),
                                filled: true,
                                fillColor: cs.surface.withValues(alpha: 0.9),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: kSpacingMedium,
                                  vertical: kSpacingSmall,
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
                          ),
                          const SizedBox(height: kSpacingSmall),

                          // 🟩 שדה סיסמה בפתק ירוק
                          StickyNote(
                            color: kStickyGreen,
                            rotation: 0.01,
                            child: TextFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
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
                                  tooltip: _obscurePassword ? 'הצג סיסמה' : 'הסתר סיסמה',
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(kBorderRadius),
                                ),
                                filled: true,
                                fillColor: cs.surface.withValues(alpha: 0.9),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: kSpacingMedium,
                                  vertical: kSpacingSmall,
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
                          ),
                          const SizedBox(height: kSpacingSmall),

                          // 🌸 שדה אימות סיסמה בפתק ורוד
                          StickyNote(
                            color: kStickyPink,
                            rotation: -0.015,
                            child: TextFormField(
                              controller: _confirmPasswordController,
                              focusNode: _confirmPasswordFocusNode,
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
                                  tooltip: _obscureConfirmPassword ? 'הצג סיסמה' : 'הסתר סיסמה',
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(kBorderRadius),
                                ),
                                filled: true,
                                fillColor: cs.surface.withValues(alpha: 0.9),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: kSpacingMedium,
                                  vertical: kSpacingSmall,
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
                          ),
                          const SizedBox(height: kSpacingMedium),

                          // 🔘 כפתור הרשמה - StickyButton
                          StickyButton(
                            color: accent,
                            label: AppStrings.auth.registerButton,
                            icon: Icons.app_registration,
                            onPressed: _isLoading ? () {} : () => _handleRegister(),
                            height: 44, // 📐 גובה מצומצם
                          ),
                          const SizedBox(height: kSpacingSmall),

                          // 🔵 קישור להתחברות בפתק תכלת - compact
                          StickyNote(
                            color: kStickyCyan,
                            rotation: 0.01,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppStrings.auth.haveAccount,
                                    style: TextStyle(
                                      color: cs.onSurface.withValues(alpha: 0.7),
                                      fontSize: kFontSizeTiny,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  TextButton(
                                    onPressed: _isLoading ? null : _navigateToLogin,
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: kSpacingXSmall,
                                        vertical: 0,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      AppStrings.auth.loginButton,
                                      style: TextStyle(
                                        color: accent,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        decorationColor: accent,
                                        decorationThickness: 2,
                                        fontSize: kFontSizeTiny,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: kSpacingSmall), // 📐 רווח קטן בתחתית
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
    );
  }
}
