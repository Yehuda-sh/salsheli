// 📄 File: lib/services/tutorial_service.dart
// 🎯 Purpose: שירות הדרכה אינטראקטיבית למשתמשים חדשים
//
// 📋 Features:
// - הדרכה פשוטה עם Dialog slides
// - שמירת מצב ב-SharedPreferences
// - RTL support מלא
// - אנימציות חלקות
//
// Version: 1.0
// Created: 14/12/2025

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/ui_constants.dart';

/// שירות הדרכה אינטראקטיבית
class TutorialService {
  TutorialService._();

  static const String _keySeenHomeTutorial = 'seen_home_tutorial';

  // ========================================
  // בדיקת מצב
  // ========================================

  /// האם המשתמש ראה את הדרכת הבית?
  static Future<bool> hasSeenHomeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySeenHomeTutorial) ?? false;
  }

  /// סימון שהמשתמש ראה את הדרכת הבית
  static Future<void> markHomeTutorialAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySeenHomeTutorial, true);
    debugPrint('✅ TutorialService: Home tutorial marked as seen');
  }

  /// איפוס ההדרכה (לבדיקות או מהגדרות)
  static Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySeenHomeTutorial);
    debugPrint('🔄 TutorialService: Tutorial reset');
  }

  // ========================================
  // הצגת הדרכה
  // ========================================

  /// הצגת הדרכת הבית אם עדיין לא נראתה
  static Future<void> showHomeTutorialIfNeeded(BuildContext context) async {
    final seen = await hasSeenHomeTutorial();
    if (seen) {
      debugPrint('ℹ️ TutorialService: Home tutorial already seen, skipping');
      return;
    }

    // המתן קצת לאנימציות המסך להסתיים
    await Future.delayed(const Duration(milliseconds: 800));

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) => const _TutorialDialog(),
    );

    await markHomeTutorialAsSeen();
  }
}

// ========================================
// Tutorial Dialog - הדרכה עם שלבים
// ========================================

class _TutorialDialog extends StatefulWidget {
  const _TutorialDialog();

  @override
  State<_TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<_TutorialDialog> {
  int _currentStep = 0;

  // שלבי ההדרכה
  static const List<_TutorialStep> _steps = [
    _TutorialStep(
      icon: Icons.waving_hand,
      title: 'ברוכים הבאים! 🎉',
      description: 'MemoZap תעזור לך לנהל את הקניות בקלות.\n\nבואו נכיר את האפליקציה בקצרה!',
    ),
    _TutorialStep(
      icon: Icons.add_circle_outline,
      title: 'יצירת רשימה',
      description: 'לחץ על כפתור ה-+ כדי ליצור רשימה חדשה.\n\nאפשר ליצור רשימת קניות, משימות, או אפילו הצבעה!',
    ),
    _TutorialStep(
      icon: Icons.navigation_outlined,
      title: 'ניווט באפליקציה',
      description: 'בתחתית המסך תמצא את התפריט:\n\n🏠 בית - סיכום ופעולות מהירות\n📝 רשימות - כל הרשימות שלך\n📦 מזווה - מעקב מלאי\n⚙️ הגדרות',
    ),
    _TutorialStep(
      icon: Icons.rocket_launch,
      title: 'מוכנים להתחיל!',
      description: 'זהו! עכשיו אתה מוכן.\n\nאפשר תמיד לחזור להדרכה מההגדרות.',
    ),
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _skip() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final isLast = _currentStep == _steps.length - 1;
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
                  color: Colors.black.withValues(alpha: 0.3),
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
                  children: List.generate(_steps.length, (index) {
                    final isActive = index == _currentStep;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? cs.primary : cs.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
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
                          'דלג',
                          style: TextStyle(color: cs.outline),
                        ),
                      ),
                    const Spacer(),

                    // Next/Finish button
                    FilledButton(
                      onPressed: _nextStep,
                      child: Text(isLast ? 'בואו נתחיל! 🚀' : 'הבא'),
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
