// 📄 File: lib/services/tutorial_service.dart
// 🎯 Purpose: שירות הדרכה אינטראקטיבית למשתמשים חדשים
//
// 📋 Features:
// - הדרכה פשוטה עם Dialog slides
// - שמירת מצב ב-Firestore (נשמר עם המשתמש)
// - RTL support מלא
// - אנימציות חלקות
//
// Version: 2.0 - Firestore persistence
// Updated: 01/01/2026

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/ui_constants.dart';
import '../l10n/app_strings.dart';
import '../providers/user_context.dart';

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
    await Future.delayed(const Duration(milliseconds: 800));

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.87),
      builder: (dialogContext) => _TutorialDialog(
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

  void _skip() {
    widget.onComplete();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final step = _stepsList[_currentStep];
    final isLast = _currentStep == _stepsList.length - 1;
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            key: ValueKey(_currentStep),
            constraints: const BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.all(kSpacingLarge),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(kBorderRadiusLarge),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_stepsList.length, (index) {
                    final isActive = index == _currentStep;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? cs.primary : cs.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(kBorderRadiusSmall / 2),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: kSpacingLarge),

                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    step.icon,
                    size: 40,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: kSpacingLarge),

                // Title
                Text(
                  step.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: kSpacingMedium),

                // Description
                Text(
                  step.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: kSpacingXLarge),

                // Buttons
                Row(
                  children: [
                    // Skip button (not on last step)
                    if (!isLast)
                      TextButton(
                        onPressed: _skip,
                        child: Text(
                          AppStrings.tutorial.skip,
                          style: TextStyle(color: cs.outline),
                        ),
                      ),
                    const Spacer(),

                    // Next/Finish button
                    FilledButton(
                      onPressed: _nextStep,
                      child: Text(isLast ? AppStrings.tutorial.letsStart : AppStrings.tutorial.next),
                    ),
                  ],
                ),
              ],
            ),
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
