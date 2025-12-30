// 📄 lib/screens/auth/login_screen.dart
//
// מסך התחברות עם Firebase Auth ועיצוב Sticky Notes.
// - Form validation + shake animation לשגיאות
// - Password reset בלחיצה על "שכחת סיסמה"
// - PopScope חוסם Back (חובה להתחבר)
//
// 🔗 Related: UserContext, RegisterScreen, AppStrings.auth

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/status_colors.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../providers/user_context.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_button.dart';
import '../../widgets/common/sticky_note.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // 🎬 Animation controller לשגיאות
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // 🎯 Focus node for auto-focus
  final FocusNode _emailFocusNode = FocusNode();

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

    // 🎯 Auto-focus על שדה אימייל בכניסה למסך
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(_emailFocusNode.requestFocus);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _shakeController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  /// ✅ פונקציית Login עם Firebase Authentication
  Future<void> _handleLogin() async {
    debugPrint('🔐 _handleLogin() | Starting login process...');
    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ _handleLogin() | Form validation failed');
      unawaited(_shakeController.forward(from: 0)); // 🎬 Shake animation
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
      debugPrint('🔐 _handleLogin() | Signing in...');
      await userContext.signIn(email: email, password: password);

      // ✅ signIn() זורק Exception אם נכשל, אחרת מצליח
      debugPrint(
        '✅ _handleLogin() | Sign in successful, userId: ${userContext.userId}',
      );

      // 🔹 2. שמירה ב-SharedPreferences (רק seenOnboarding!)
      // ✅ FIX: שם עקבי עם IndexScreen ו-UserContext
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seenOnboarding', true);
      debugPrint('✅ _handleLogin() | Onboarding flag saved');

      // 🔹 3. הצגת feedback ויזואלי + ניווט
      if (mounted) {
        setState(() => _isLoading = false);

        // 🎉 הצגת הודעת הצלחה קצרה
        // ✅ שימוש ב-StatusColors API
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: StatusColors.getOnStatusContainer('success', context), size: 24),
                const SizedBox(width: kSpacingSmall),
                Text(
                  'התחברת בהצלחה! מעביר לדף הבית...',
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

        // ⏱️ המתנה קצרה לפני ניווט (feedback ויזואלי)
        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          // ✅ FIX: ניווט ל-Index במקום Home
          // Index מטפל ב-sync profile ומחליט לאן לנווט
          debugPrint('🔄 _handleLogin() | Navigating to index screen');
          await navigator.pushNamedAndRemoveUntil('/', (route) => false);
        }
      }
    } catch (e) {
      debugPrint('❌ _handleLogin() | Login failed: $e');
      final errorMsg = e.toString().replaceAll('Exception: ', '');

      if (mounted) {
        setState(() => _isLoading = false);
        unawaited(_shakeController.forward(from: 0)); // 🎬 Shake animation

        // 🎨 הודעת שגיאה משופרת
        // ✅ שימוש ב-StatusColors API
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: StatusColors.getOnStatusContainer('error', context), size: 24),
                const SizedBox(width: kSpacingSmall),
                Expanded(
                  child: Text(
                    errorMsg,
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
    debugPrint('🏁 _handleLogin() | Completed');
  }

  /// ניווט למסך הרשמה
  void _navigateToRegister() {
    debugPrint('🔄 _navigateToRegister() | Navigating to register screen');
    Navigator.pushReplacementNamed(context, '/register');
  }

  /// 🔑 איפוס סיסמה - שליחת מייל דרך Firebase Auth
  Future<void> _handleForgotPassword() async {
    debugPrint('🔑 _handleForgotPassword() | Starting password reset process');

    // בדוק אם יש אימייל בשדה
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      // ✅ שימוש ב-StatusColors API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.info_outline, color: StatusColors.getOnStatusContainer('warning', context)),
              const SizedBox(width: kSpacingSmall),
              Expanded(
                child: Text(
                  'אנא הזן את כתובת האימייל שלך בשדה למעלה',
                  style: TextStyle(
                    fontSize: kFontSizeSmall,
                    color: StatusColors.getOnStatusContainer('warning', context),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: StatusColors.getStatusContainer('warning', context),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
          margin: const EdgeInsets.all(kSpacingMedium),
        ),
      );
      return;
    }

    if (!email.contains('@')) {
      // ✅ שימוש ב-StatusColors API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'כתובת אימייל לא תקינה',
            style: TextStyle(color: StatusColors.getOnStatusContainer('error', context)),
          ),
          backgroundColor: StatusColors.getStatusContainer('error', context),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userContext = context.read<UserContext>();
      await userContext.sendPasswordResetEmail(email);

      debugPrint('✅ _handleForgotPassword() | Reset email sent');

      if (mounted) {
        setState(() => _isLoading = false);

        // הצג הודעת הצלחה
        // ✅ שימוש ב-StatusColors API
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: StatusColors.getOnStatusContainer('success', context)),
                const SizedBox(width: kSpacingSmall),
                Expanded(
                  child: Text(
                    'נשלח מייל לאיפוס סיסמה ל-$email',
                    style: TextStyle(
                      fontSize: kFontSizeSmall,
                      color: StatusColors.getOnStatusContainer('success', context),
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: StatusColors.getStatusContainer('success', context),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            margin: const EdgeInsets.all(kSpacingMedium),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ _handleForgotPassword() | Failed: $e');

      if (mounted) {
        setState(() => _isLoading = false);

        // ✅ שימוש ב-StatusColors API
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: StatusColors.getOnStatusContainer('error', context)),
                const SizedBox(width: kSpacingSmall),
                Expanded(
                  child: Text(
                    'שגיאה בשליחת מייל איפוס',
                    style: TextStyle(fontSize: kFontSizeSmall, color: StatusColors.getOnStatusContainer('error', context)),
                  ),
                ),
              ],
            ),
            backgroundColor: StatusColors.getStatusContainer('error', context),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            margin: const EdgeInsets.all(kSpacingMedium),
          ),
        );
      }
    }

    debugPrint('🏁 _handleForgotPassword() | Completed');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    // 💡 שמור messenger לפני PopScope
    final messenger = ScaffoldMessenger.of(context);

    // 🔒 חסימת Back - המשתמש חייב להשלים התחברות
    return Directionality(
      textDirection: TextDirection.rtl, // 🔄 תמיכה מלאה ב-RTL
      child: PopScope(
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
          // ✅ רקע מ-Theme (AppBrand.paperBackground או scaffoldBackgroundColor)
          backgroundColor: brand?.paperBackground ?? theme.scaffoldBackgroundColor,
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
                            const SizedBox(
                              height: kSpacingSmall,
                            ), // 📐 רווח קטן מלמעלה
                            // 🟨 לוגו בפתק צהוב מסובב - גודל מצומצם
                            // ✅ Dark-aware: שימוש ב-AppBrand
                            Hero(
                              tag: 'app_logo',
                              child: Transform.scale(
                                scale: 0.85, // 📐 הקטנת הלוגו ב-15%
                                child: StickyNoteLogo(
                                  color: brand?.stickyYellow ?? kStickyYellow,
                                  icon: Icons.shopping_basket_outlined,
                                  iconColor: accent,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: kSpacingSmall,
                            ), // 📐 צמצום מ-Large ל-Small
                            // 📝 כותרת בפתק - גודל מצומצם
                            // ✅ Dark-aware: surfaceContainerHighest במקום לבן
                            StickyNote(
                              color: cs.surfaceContainerHighest,
                              rotation: -0.02,
                              child: Column(
                                children: [
                                  Text(
                                    AppStrings.auth.loginTitle,
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24, // 📐 הקטנה מ-28 ל-24
                                          color: cs.onSurface,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4), // 📐 רווח מצומצם
                                  Text(
                                    AppStrings.auth.loginSubtitle,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      fontSize: kFontSizeSmall, // 📐 הקטנה
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: kSpacingMedium,
                            ), // 📐 צמצום מ-XLarge ל-Medium
                            // 🔵 שדה אימייל בפתק תכלת
                            // ✅ Dark-aware: שימוש ב-AppBrand
                            StickyNote(
                              color: brand?.stickyCyan ?? kStickyCyan,
                              rotation: 0.01,
                              child: TextFormField(
                                controller: _emailController,
                                focusNode: _emailFocusNode,
                                decoration: InputDecoration(
                                  labelText: AppStrings.auth.emailLabel,
                                  hintText: AppStrings.auth.emailHint,
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      kBorderRadius,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: cs.surface.withValues(alpha: 0.9),
                                  contentPadding: const EdgeInsets.symmetric(
                                    // 📐 צמצום padding פנימי
                                    horizontal: kSpacingMedium,
                                    vertical: kSpacingSmall,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
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
                            const SizedBox(
                              height: kSpacingSmall,
                            ), // 📐 צמצום מ-Medium ל-Small
                            // 🟩 שדה סיסמה בפתק ירוק
                            // ✅ Dark-aware: שימוש ב-AppBrand
                            StickyNote(
                              color: brand?.stickyGreen ?? kStickyGreen,
                              rotation: -0.015,
                              child: TextFormField(
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
                                    tooltip: _obscurePassword
                                        ? 'הצג סיסמה'
                                        : 'הסתר סיסמה',
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      kBorderRadius,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: cs.surface.withValues(alpha: 0.9),
                                  contentPadding: const EdgeInsets.symmetric(
                                    // 📐 צמצום padding פנימי
                                    horizontal: kSpacingMedium,
                                    vertical: kSpacingSmall,
                                  ),
                                ),
                                obscureText: _obscurePassword,
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
                            ),
                            const SizedBox(
                              height: kSpacingSmall,
                            ), // 📐 רווח קטן
                            // 🔑 קישור שכחתי סיסמה - מימין לשדה הסיסמה
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : _handleForgotPassword,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: kSpacingSmall,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'שכחת סיסמה?',
                                  style: TextStyle(
                                    color: accent,
                                    fontSize: kFontSizeTiny,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: kSpacingSmall,
                            ), // 📐 רווח קטן
                            // 🔘 כפתור התחברות - StickyButton ירוק
                            // ✅ FIX: שימוש ב-isLoading במקום onPressed: () {}
                            StickyButton(
                              color: accent,
                              label: AppStrings.auth.loginButton,
                              icon: Icons.login,
                              isLoading: _isLoading,
                              onPressed: _handleLogin,
                              height: 44, // 📐 הקטנת גובה הכפתור מעט
                            ),
                            const SizedBox(
                              height: kSpacingSmall,
                            ), // 📐 צמצום מ-Large ל-Small
                            // 🌸 קישור להרשמה בפתק ורוד - compact
                            // ✅ Dark-aware: שימוש ב-AppBrand
                            StickyNote(
                              color: brand?.stickyPink ?? kStickyPink,
                              rotation: 0.01,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ), // 📐 padding מצומצם
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      AppStrings.auth.noAccount,
                                      style: TextStyle(
                                        color: cs.onSurface.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: kFontSizeTiny, // 📐 הקטנה
                                      ),
                                    ),
                                    const SizedBox(width: 4), // 📐 רווח מצומצם
                                    TextButton(
                                      onPressed: _isLoading
                                          ? null
                                          : _navigateToRegister,
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: kSpacingTiny,
                                        ),
                                        minimumSize:
                                            Size.zero, // 📐 ביטול גודל מינימלי
                                        tapTargetSize: MaterialTapTargetSize
                                            .shrinkWrap, // 📐 כפתור צמוד
                                      ),
                                      child: Text(
                                        AppStrings.auth.registerNow,
                                        style: TextStyle(
                                          color: accent,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                          decorationColor: accent,
                                          decorationThickness: 2,
                                          fontSize: kFontSizeTiny, // 📐 הקטנה
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: kSpacingSmall,
                            ), // 📐 רווח קטן בתחתית
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
