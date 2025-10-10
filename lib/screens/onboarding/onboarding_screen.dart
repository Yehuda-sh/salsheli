// 📄 File: lib/screens/onboarding/onboarding_screen.dart
// תיאור: מסך Onboarding - היכרות ראשונית עם המשתמש
//
// תפקיד:
// - הצגת שלבי Onboarding למשתמש חדש
// - איסוף העדפות בסיסיות (גודל משפחה, חנויות, תקציב וכו')
// - שמירת ההעדפות דרך OnboardingService
// - ניווט למסך הבא (Register) בסיום
//
// תלויות: OnboardingData, OnboardingSteps, OnboardingService, AppBrand

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/ui_constants.dart';
import '../../data/onboarding_data.dart';
import '../../l10n/app_strings.dart';
import '../../services/onboarding_service.dart';
import 'widgets/onboarding_steps.dart';
import '../../theme/app_theme.dart';

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

  void _nextStep(int totalSteps) {
    if (_isLoading) return;

    if (_currentStep < totalSteps - 1) {
      _pageController.nextPage(
        duration: kAnimationDurationMedium,
        curve: Curves.easeOut,
      );
      _haptic();
    } else {
      _finishOnboarding();
    }
  }

  void _prevStep() {
    if (_isLoading) return;

    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: kAnimationDurationShort,
        curve: Curves.easeOut,
      );
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
      onBudgetChanged: (v) => setState(() {
        _data = _data.copyWith(monthlyBudget: v);
      }),
      onCategoriesChanged: (v) => setState(() {
        _data = _data.copyWith(importantCategories: v);
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
          backgroundColor: cs.surface,
          appBar: AppBar(
            backgroundColor: cs.surface,
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
                  style: TextStyle(color: accent),
                ),
              ),
            ],
          ),
          body: SafeArea(
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

                  // כפתורי ניווט
                  _buildNavigationButtons(cs, accent, steps.length),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(ColorScheme cs, Color accent, int totalSteps) {
    return Row(
      children: [
        // כפתור "הקודם"
        Expanded(
          child: OutlinedButton(
            onPressed: _currentStep == 0 || _isLoading ? null : _prevStep,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: BorderSide(
                color: _currentStep == 0 || _isLoading
                    ? cs.outlineVariant
                    : accent,
              ),
              foregroundColor: _currentStep == 0 || _isLoading
                  ? cs.onSurfaceVariant
                  : accent,
            ),
            child: Text(AppStrings.onboarding.previous),
          ),
        ),
        const SizedBox(width: kSpacingSmall),

        // כפתור "הבא" / "סיום"
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : () => _nextStep(totalSteps),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: accent,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: kIconSizeSmall,
                    width: kIconSizeSmall,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _currentStep == totalSteps - 1
                        ? AppStrings.onboarding.finish
                        : AppStrings.onboarding.next,
                  ),
          ),
        ),
      ],
    );
  }
}
