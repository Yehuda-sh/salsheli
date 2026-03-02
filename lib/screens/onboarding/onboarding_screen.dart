// 📄 File: lib/screens/onboarding/onboarding_screen.dart
// 🎯 Purpose: מסך Onboarding - היכרות ראשונית עם המשתמש
//
// 📋 Features:
// - Header בעיצוב Glassmorphic
// - משוב Haptic Feedback במעברי עמודים
// - אנימציות כניסה מדורגות (Staggered)
// - מנגנון Loading Overlay משופר
//
// 🔗 Related:
// - NotebookBackground - רקע מחברת
// - StickyButton - כפתורים מעוצבים
// - OnboardingSteps - בניית השלבים
// - OnboardingService - שמירת העדפות
//
// 📝 Version: 4.0 (Hybrid Premium)
// 📅 Updated: 22/02/2026

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  /// חזרה לשלב הקודם
  ///
  /// מבצע אנימציה קצרה חזרה אחורה
  /// לא פועל אם כבר בשלב הראשון או במצב loading
  void _prevStep() {
    if (_isLoading) return;

    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: kAnimationDurationShort,
        curve: Curves.easeOutCubic,
      );
    }
  }

  // ========================================
  // Actions
  // ========================================

  /// סיום ושמירת העדפות
  Future<void> _finishOnboarding() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    // רצף רטטים לסימון הצלחה
    unawaited(HapticFeedback.mediumImpact());
    unawaited(Future.delayed(
      const Duration(milliseconds: 150),
      () => HapticFeedback.mediumImpact(),
    ));

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

    unawaited(HapticFeedback.mediumImpact());
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
      onChildrenChanged: (v) => setState(() {
        _data = _data.copyWith(children: v);
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
          body: Stack(
            children: [
              // רקע נייר מחברת
              const NotebookBackground(),
              SafeArea(
                child: Column(
                  children: [
                    // Header Glassmorphic: כותרת + מחוון התקדמות
                    ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: kGlassBlurMedium,
                          sigmaY: kGlassBlurMedium,
                        ),
                        child: Container(
                          color: cs.surface.withValues(alpha: 0.7),
                          padding: const EdgeInsets.fromLTRB(
                            kSpacingMedium,
                            kSpacingSmall,
                            kSpacingMedium,
                            kSpacingSmall,
                          ),
                          child: Column(
                            children: [
                              // כותרת inline עם כפתור דילוג
                              Padding(
                                padding: const EdgeInsets.only(bottom: kSpacingSmall),
                                child: Row(
                                  children: [
                                    Icon(Icons.waving_hand, size: 24, color: cs.primary),
                                    const SizedBox(width: kSpacingSmall),
                                    Expanded(
                                      child: Text(
                                        AppStrings.onboarding.title,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: cs.onSurface,
                                        ),
                                      ),
                                    ),
                                    // כפתור דילוג
                                    TextButton(
                                      onPressed: _isLoading ? null : _skip,
                                      child: Text(
                                        AppStrings.onboarding.skip,
                                        style: TextStyle(
                                          color: _isLoading
                                              ? cs.onSurfaceVariant
                                              : cs.onSurface.withValues(alpha: 0.7),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // מחוון התקדמות
                              _buildProgressIndicator(cs, accent, steps.length),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: kSpacingSmall),

                    // השלבים
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: steps.length,
                          onPageChanged: (i) {
                            unawaited(HapticFeedback.selectionClick());
                            setState(() => _currentStep = i);
                          },
                          itemBuilder: (_, i) => steps[i],
                        ),
                      ),
                    ),

                    const SizedBox(height: kSpacingMedium),

                    // Progress Dots
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                      child: _ProgressDots(
                        currentStep: _currentStep,
                        totalSteps: steps.length,
                        accent: accent,
                      ),
                    ),
                    const SizedBox(height: kSpacingLarge),

                    // כפתורי ניווט
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        kSpacingMedium,
                        0,
                        kSpacingMedium,
                        kSpacingMedium,
                      ),
                      child: _buildNavigationButtons(cs, accent, steps.length),
                    ),
                  ],
                ),
              ),

              // Loading Overlay
              if (_isLoading)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      color: cs.surface.withValues(alpha: 0.4),
                      child: Center(
                        child: CircularProgressIndicator(color: accent),
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

  /// בונה מחוון התקדמות בראש המסך
  ///
  /// מציג LinearProgressIndicator עם טקסט דינמי "שלב X/Y"
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
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: kSpacingSmall),
        Text(
          AppStrings.onboarding.stepProgress(_currentStep + 1, totalSteps),
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// בונה כפתורי ניווט - "הקודם" ו "הבא/סיום"
  Widget _buildNavigationButtons(ColorScheme cs, Color accent, int totalSteps) {
    return Row(
      children: [
        // כפתור "הקודם"
        Expanded(
          child: StickyButton(
            color: Colors.white,
            textColor: _currentStep == 0 || _isLoading
                ? cs.onSurfaceVariant
                : accent,
            label: AppStrings.onboarding.previous,
            icon: Icons.arrow_back,
            onPressed: _currentStep == 0 || _isLoading ? null : _prevStep,
          ),
        ),
        const SizedBox(width: kSpacingSmall),

        // כפתור "הבא" / "סיום"
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
            onPressed: _isLoading ? null : () => _nextStep(totalSteps),
            isLoading: _isLoading,
          ),
        ),
      ],
    );
  }
}

/// Progress Dots - מחוון התקדמות בנקודות
///
/// מציג נקודות שמראות את השלב הנוכחי בתהליך ה-onboarding
///
/// **תכונות:**
/// - נקודה פעילה: גדולה ומלאה עם זוהר
/// - נקודות אחרות: קטנות ושקופות
/// - אנימציה חלקה במעברים (300ms)
/// - shimmer חד-פעמי בהופעה ראשונה
/// - נגישות: Semantics label לקוראי מסך
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
    return Semantics(
      label: AppStrings.onboarding.stepAccessibilityLabel(currentStep + 1, totalSteps),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          totalSteps,
          (index) => AnimatedContainer(
            duration: kAnimationDurationMedium,
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: index == currentStep ? 20 : 12,
            height: index == currentStep ? 20 : 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == currentStep
                  ? accent
                  : accent.withValues(alpha: kOpacityLight),
              boxShadow: index == currentStep
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.5),
                        blurRadius: 12,
                        spreadRadius: 4,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      )
          .animate()
          .shimmer(
            duration: 1200.ms,
            delay: 500.ms,
            color: accent.withValues(alpha: 0.2),
          ),
    );
  }
}
