// lib/services/tutorial_service.dart — Tutorial service — onboarding multi-step dialog for new users

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/ui_constants.dart';
import '../l10n/app_strings.dart';
import '../providers/user_context.dart';
import '../widgets/common/app_dialog.dart';

// Delay between screen mount and the tutorial appearing — lets the home
// dashboard's own entry animations settle so the modal doesn't compete.
const Duration _kStartupDelay = Duration(milliseconds: 800);

// Progress-dot dimensions. The active dot grows wider (a tablet-style
// indicator) so the user can tell their position at a glance.
const double _kDotActiveWidth = 24.0;
const double _kDotInactiveWidth = 8.0;
const double _kDotHeight = 8.0;
const double _kDotBorderRadius = 4.0; // half of dot height → fully rounded
const Duration _kDotAnimDuration = Duration(milliseconds: 200);

// Step icon container — circular tint behind the Material icon. Wider
// than kIconSizeXLarge (64) so the icon has breathing room and reads as
// a "feature card" rather than a button.
const double _kIconBoxSize = 80.0;

// Dialog body width cap — keeps the modal compact on tablets and
// landscape phones; on portrait phones the device width is the binding
// constraint anyway.
const double _kDialogMaxWidth = 340.0;

// Soft drop shadow under the dialog card.
const double _kShadowBlur = 20.0;
const Offset _kShadowOffset = Offset(0, 10);

/// שירות הדרכה אינטראקטיבית
class TutorialService {
  TutorialService._();

  // ========================================
  // בדיקת מצב (מ-Firestore)
  // ========================================

  /// האם המשתמש ראה את הדרכת הבית?
  static bool hasSeenHomeTutorial(BuildContext context) {
    final userContext = context.read<UserContext>();
    return userContext.user?.seenTutorial ?? false;
  }

  /// סימון שהמשתמש ראה את הדרכת הבית (שומר ב-Firestore)
  static Future<void> markHomeTutorialAsSeen(BuildContext context) async {
    final userContext = context.read<UserContext>();
    final user = userContext.user;

    if (user == null) {
      return;
    }

    try {
      await userContext.saveUser(user.copyWith(seenTutorial: true));
    } catch (_) {
      // Silent: tutorial state is non-critical
    }
  }

  /// איפוס ההדרכה (לבדיקות או מהגדרות)
  static Future<void> resetTutorial(BuildContext context) async {
    final userContext = context.read<UserContext>();
    final user = userContext.user;

    if (user == null) return;

    try {
      await userContext.saveUser(user.copyWith(seenTutorial: false));
    } catch (_) {
      // Silent: tutorial state is non-critical
    }
  }

  // ========================================
  // הצגת הדרכה
  // ========================================

  /// הצגת הדרכת הבית אם עדיין לא נראתה
  static Future<void> showHomeTutorialIfNeeded(BuildContext context) async {
    final seen = hasSeenHomeTutorial(context);
    if (seen) {
      return;
    }

    // המתן קצת לאנימציות המסך להסתיים
    await Future.delayed(_kStartupDelay);

    if (!context.mounted) return;

    await AppDialog.show<void>(
      context: context,
      barrierDismissible: false,
      child: _TutorialDialog(
        onComplete: () => markHomeTutorialAsSeen(context),
      ),
    );
  }
}

// ========================================
// Tutorial Dialog - הדרכה עם שלבים
// ========================================

class _TutorialDialog extends StatefulWidget {
  final VoidCallback onComplete;

  const _TutorialDialog({required this.onComplete});

  @override
  State<_TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<_TutorialDialog> {
  int _currentStep = 0;

  // שלבי ההדרכה
  static List<_TutorialStep> _steps() {
    final s = AppStrings.tutorial;
    return [
      _TutorialStep(icon: Icons.waving_hand, title: s.welcomeTitle, description: s.welcomeDesc),
      _TutorialStep(icon: Icons.shopping_cart_outlined, title: s.shoppingTitle, description: s.shoppingDesc),
      _TutorialStep(icon: Icons.shopping_bag_outlined, title: s.activeShoppingTitle, description: s.activeShoppingDesc),
      _TutorialStep(icon: Icons.kitchen_outlined, title: s.pantryTitle, description: s.pantryDesc),
      _TutorialStep(icon: Icons.family_restroom, title: s.householdTitle, description: s.householdDesc),
      _TutorialStep(icon: Icons.history_outlined, title: s.historyTitle, description: s.historyDesc),
      _TutorialStep(icon: Icons.explore_outlined, title: s.navigationTitle, description: s.navigationDesc),
      _TutorialStep(icon: Icons.rocket_launch, title: s.readyTitle, description: s.readyDesc),
    ];
  }

  late final List<_TutorialStep> _stepsList = _steps();

  void _nextStep() {
    if (_currentStep < _stepsList.length - 1) {
      setState(() => _currentStep++);
    } else {
      widget.onComplete();
      Navigator.of(context).pop();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _skip() {
    widget.onComplete();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final step = _stepsList[_currentStep];
    final isFirst = _currentStep == 0;
    final isLast = _currentStep == _stepsList.length - 1;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final strings = AppStrings.tutorial;
    // Back arrow points toward the start of the reading direction:
    // arrow_forward in RTL (Hebrew) points right = "previous step",
    // arrow_back in LTR (English) points left = "previous step".
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final backIcon =
        isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded;

    // The Dialog is wrapped in app-wide Directionality already — no
    // hardcoded RTL wrapper here. App supports both Hebrew and English;
    // forcing RTL would break the English locale.
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedSwitcher(
        duration: kDialogTransitionDuration,
        // Cross-fade between steps; the previous step fades out while the
        // new one fades in, giving a softer transition than a hard swap.
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: Container(
          key: ValueKey(_currentStep),
          constraints: const BoxConstraints(maxWidth: _kDialogMaxWidth),
          padding: const EdgeInsets.all(kSpacingLarge),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(kBorderRadiusLarge),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: kOpacityLight),
                blurRadius: _kShadowBlur,
                offset: _kShadowOffset,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress dots — decorative, the actual step is announced
              // through the title/description text. Excluding from
              // semantics avoids "8 separate elements" being read out.
              ExcludeSemantics(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_stepsList.length, (index) {
                    final isActive = index == _currentStep;
                    return AnimatedContainer(
                      duration: _kDotAnimDuration,
                      margin: const EdgeInsets.symmetric(
                          horizontal: kSpacingXTiny),
                      width: isActive ? _kDotActiveWidth : _kDotInactiveWidth,
                      height: _kDotHeight,
                      decoration: BoxDecoration(
                        color: isActive
                            ? cs.primary
                            : cs.outline.withValues(alpha: kOpacityLight),
                        borderRadius:
                            BorderRadius.circular(_kDotBorderRadius),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: kSpacingLarge),

              // Icon
              Container(
                width: _kIconBoxSize,
                height: _kIconBoxSize,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  step.icon,
                  size: kIconSizeLarge,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: kSpacingLarge),

              // Title — headlineSmall with bold weight per Material 3
              // emphasis pattern; one copyWith call combines the two.
              Text(
                step.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: kSpacingMedium),

              // Description
              Text(
                step.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: kSpacingXLarge),

              // Buttons row
              //  ┌─────────────────────────────────────────────────┐
              //  │ [Skip]  ↔  [Back] [Next / Let's start]          │
              //  └─────────────────────────────────────────────────┘
              // Skip hides on the last step (nothing left to skip past),
              // Back hides on the first step (nothing to go back to).
              Row(
                children: [
                  if (!isLast)
                    TextButton(
                      onPressed: _skip,
                      child: Text(
                        strings.skip,
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ),
                  const Spacer(),
                  if (!isFirst) ...[
                    IconButton(
                      onPressed: _previousStep,
                      icon: Icon(backIcon),
                      color: cs.onSurfaceVariant,
                      tooltip: strings.back,
                    ),
                    const SizedBox(width: kSpacingXTiny),
                  ],
                  FilledButton(
                    onPressed: _nextStep,
                    child: Text(isLast ? strings.letsStart : strings.next),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================
// מודל שלב הדרכה
// ========================================

class _TutorialStep {
  final IconData icon;
  final String title;
  final String description;

  const _TutorialStep({
    required this.icon,
    required this.title,
    required this.description,
  });
}
