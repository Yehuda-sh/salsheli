// 📄 File: lib/screens/onboarding/onboarding_screen.dart
// 🎯 Purpose: מסך Onboarding - היכרות ראשונית עם המשתמש
//
// 📋 Features:
// - עיצוב Sticky Notes מלא 🎨📝
// - הצגת שלבי Onboarding למשתמש חדש
// - איסוף העדפות בסיסיות (גודל משפחה, חנויות, תקציב וכו')
// - שמירת ההעדפות דרך OnboardingService
// - ניווט למסך הבא (Register) בסיום
// - אנימציות חלקות ומשוב
//
// 🔗 Related:
// - NotebookBackground - רקע מחברת
// - StickyButton - כפתורים מעוצבים
// - OnboardingSteps - בניית השלבים
// - OnboardingService - שמירת העדפות
//
// 🎨 Design:
// - עיצוב Sticky Notes System 2025
// - רקע נייר קרם עם קווים כחולים
// - כפתורים בסגנון פתקים עם צללים
// - Progress indicators מודרניים
// - אנימציות חלקות במעברים
//
// Version: 2.0 - Sticky Notes Design (15/10/2025) 🎨📝

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/ui_constants.dart';
import '../../data/onboarding_data.dart';
import '../../l10n/app_strings.dart';
import '../../services/onboarding_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_button.dart';
import 'widgets/onboarding_steps.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Controllers
  final PageController _pageController = PageController();
  final OnboardingService _onboardingService = OnboardingService();

  // State
  late OnboardingData _data;
  int _currentStep = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // אתחול עם ברירות מחדל
    _data = OnboardingData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ========================================
  // Navigation Logic
  // ========================================

  /// מעבר לשלב הבא או סיום ה-onboarding
  /// 
  /// אם זה השלב האחרון - קורא ל-[_finishOnboarding]
  /// אחרת - עובר לשלב הבא עם אנימציה
  void _nextStep(int totalSteps) {
    if (_isLoading) return;

    if (_currentStep < totalSteps - 1) {
      _pageController.nextPage(
        duration: kAnimationDurationMedium,
        curve: Curves.easeOut,
      );
      // ignore: unawaited_futures
      _haptic();
    } else {
      _finishOnboarding();
    }
  }

  /// חזרה לשלב הקודם
  /// 
  /// מבצע אנימציה קצרה (200ms) חזרה אחורה
  /// לא פועל אם כבר בשלב הראשון או במצב loading
  void _prevStep() {
    if (_isLoading) return;

    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: kAnimationDurationShort,
        curve: Curves.easeOut,
      );
      // ignore: unawaited_futures
      _haptic();
    }
  }

  // ========================================
  // Actions
  // ========================================

  /// סיום ושמירת העדפות
  Future<void> _finishOnboarding() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      debugPrint('🎉 OnboardingScreen: המשתמש סיים את ה-onboarding');

      // שמירת כל ההעדפות דרך השירות
      // השירות אוטומטית מסמן שה-onboarding הושלם
      final success = await _onboardingService.savePreferences(_data);

      if (!success) {
        throw Exception('שמירת ההגדרות נכשלה');
      }

      debugPrint('✅ OnboardingScreen: שמירה הצליחה, עובר למסך רישום');

      if (!mounted) return;

      // מעבר למסך הבא
      Navigator.of(context).pushNamedAndRemoveUntil('/register', (r) => false);
    } catch (e) {
      debugPrint('❌ OnboardingScreen: שגיאה - $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.onboarding.savingError(e.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// דילוג על ה-onboarding
  Future<void> _skip() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      debugPrint('⏭️ OnboardingScreen: המשתמש דילג על ה-onboarding');

      // שמירת ברירות מחדל
      final success = await _onboardingService.savePreferences(_data);

      if (!success) {
        throw Exception('לא ניתן לדלג');
      }

      debugPrint('✅ OnboardingScreen: דילוג הצליח, עובר למסך רישום');

      if (!mounted) return;

      // מעבר למסך הבא
      Navigator.of(context).pushNamedAndRemoveUntil('/register', (r) => false);
    } catch (e) {
      debugPrint('❌ OnboardingScreen: שגיאה בדילוג - $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.onboarding.skipError}: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ========================================
  // Helpers
  // ========================================

  Future<void> _haptic() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {
      // Haptic לא זמין - לא נורא
    }
  }

  // ========================================
  // UI
  // ========================================

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    // בניית השלבים
    final steps = OnboardingSteps.build(
      data: _data,
      onFamilySizeChanged: (v) => setState(() {
        _data = _data.copyWith(familySize: v);
      }),
      onStoresChanged: (v) => setState(() {
        _data = _data.copyWith(preferredStores: v);
      }),
      onShoppingFrequencyChanged: (v) => setState(() {
        _data = _data.copyWith(shoppingFrequency: v);
      }),
      onShoppingDaysChanged: (v) => setState(() {
        _data = _data.copyWith(shoppingDays: v);
      }),
      onHasChildrenChanged: (v) => setState(() {
        _data = _data.copyWith(hasChildren: v);
      }),
      onChildrenAgesChanged: (v) => setState(() {
        _data = _data.copyWith(childrenAges: v);
      }),
      onShareChanged: (v) => setState(() {
        _data = _data.copyWith(shareLists: v);
      }),
      onReminderChanged: (v) => setState(() {
        _data = _data.copyWith(reminderTime: v);
      }),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: _currentStep == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && _currentStep > 0) {
            _prevStep();
          }
        },
        child: Scaffold(
          backgroundColor: kPaperBackground,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              AppStrings.onboarding.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: cs.onSurface,
              ),
            ),
            actions: [
              TextButton(
                onPressed: _isLoading ? null : _skip,
                child: Text(
                  AppStrings.onboarding.skip,
                  style: TextStyle(
                    color: _isLoading ? cs.onSurfaceVariant : cs.onSurface.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              // 📄 רקע נייר מחברת - Sticky Notes Design ⭐
              const NotebookBackground(),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    kSpacingMedium,
                    kSpacingSmall,
                    kSpacingMedium,
                    kSpacingMedium,
                  ),
                  child: Column(
                    children: [
                      // מחוון התקדמות
                      _buildProgressIndicator(cs, accent, steps.length),
                      const SizedBox(height: kSpacingSmall),

                      // השלבים
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: steps.length,
                          onPageChanged: (i) => setState(() => _currentStep = i),
                          itemBuilder: (_, i) => steps[i],
                        ),
                      ),

                      const SizedBox(height: kSpacingMedium),

                      // Progress Dots - נקודות התקדמות ⭐
                      _ProgressDots(
                        currentStep: _currentStep,
                        totalSteps: steps.length,
                        accent: accent,
                      ),
                      const SizedBox(height: kSpacingLarge),

                      // כפתורי ניווט
                      _buildNavigationButtons(cs, accent, steps.length),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// בונה מחוון התקדמות בראש המסך
  /// 
  /// מציג LinearProgressIndicator עם טקסט "שלב X/Y"
  /// הצבע מתאים ל-accent מה-theme
  Widget _buildProgressIndicator(ColorScheme cs, Color accent, int totalSteps) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / totalSteps,
              backgroundColor: cs.surfaceContainerHighest.withValues(alpha: kProgressIndicatorBackgroundAlpha),
              color: accent,
              minHeight: kSpacingSmall,
            ),
          ),
        ),
        const SizedBox(width: kSpacingSmall),
        Text(
          AppStrings.onboarding.progress,
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// בונה כפתורי ניווט - "הקודם" ו "הבא/סיום"
  /// 
  /// **כפתור "הקודם":**
  /// - שימוש ב-StickyButton לבן
  /// - disabled בשלב הראשון עם empty callback () {}
  /// 
  /// **כפתור "הבא/סיום":**
  /// - תומך במצב loading דרך פרמטר isLoading
  /// - במצב loading: מציג CircularProgressIndicator
  /// - במצב רגיל: מציג אייקון משתנה (חץ / V)
  Widget _buildNavigationButtons(ColorScheme cs, Color accent, int totalSteps) {
    return Row(
      children: [
        // כפתור "הקודם" - Sticky Notes Design ⭐
        Expanded(
          child: StickyButton(
            color: Colors.white,
            textColor: _currentStep == 0 || _isLoading
                ? cs.onSurfaceVariant
                : accent,
            label: AppStrings.onboarding.previous,
            icon: Icons.arrow_back,
            onPressed: _currentStep == 0 || _isLoading ? () {} : _prevStep,
          ),
        ),
        const SizedBox(width: kSpacingSmall),

        // כפתור "הבא" / "סיום" - Sticky Notes Design ⭐
        Expanded(
          child: StickyButton(
            color: accent,
            textColor: Colors.white,
            label: _currentStep == totalSteps - 1
                ? AppStrings.onboarding.finish
                : AppStrings.onboarding.next,
            icon: _currentStep == totalSteps - 1
                ? Icons.check
                : Icons.arrow_forward,
            onPressed: _isLoading ? () {} : () => _nextStep(totalSteps),
            isLoading: _isLoading,
          ),
        ),
      ],
    );
  }
}

/// Progress Dots - מחוון התקדמות בנקודות ⭐
///
/// מציג נקודות שמראות את השלב הנוכחי בתהליך ה-onboarding
///
/// **תכונות:**
/// - נקודה פעילה: גדולה ומלאה עם זוהר
/// - נקודות אחרות: קטנות ושקופות
/// - אנימציה חלקה במעברים (300ms)
class _ProgressDots extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color accent;

  const _ProgressDots({
    required this.currentStep,
    required this.totalSteps,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalSteps,
        (index) => AnimatedContainer(
          duration: kAnimationDurationMedium,
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: index == currentStep ? 16 : 10,
          height: index == currentStep ? 16 : 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == currentStep
                ? accent
                : accent.withValues(alpha: kOpacityLight),
            boxShadow: index == currentStep
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.4),
                      blurRadius: 10,
                      spreadRadius: 3,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
