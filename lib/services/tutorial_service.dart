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
      barrierColor: Colors.black87,
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
  static const List<_TutorialStep> _steps = [
    _TutorialStep(
      icon: Icons.waving_hand,
      title: 'ברוכים הבאים ל-MemoZap! 🎉',
      description: 'האפליקציה שתנהל לכם את הקניות, המזווה והמשפחה — במקום אחד.\n\nבואו נכיר בקצרה!',
    ),
    _TutorialStep(
      icon: Icons.shopping_cart_outlined,
      title: 'יצירת רשימת קניות 🛒',
      description: 'לחצו על כפתור ➕ רשימה חדשה בדף הבית.\n\nבחרו סוג חנות (סופר, ירקן, מאפייה...) והוסיפו מוצרים מהקטלוג או ידנית.\n\nאפשר לבחור כמות, קטגוריה ועדיפות לכל פריט.',
    ),
    _TutorialStep(
      icon: Icons.shopping_bag_outlined,
      title: 'מצב קנייה פעיל 🏃',
      description: 'כשמגיעים לחנות — לחצו "התחל קנייה".\n\nהמסך עובר למצב קנייה: סמנו פריטים ✓ תוך כדי הליכה, ראו את ההתקדמות, והוסיפו מוצרים שמצאתם בדרך.\n\nבסיום — תקבלו סיכום עם סכום כולל.',
    ),
    _TutorialStep(
      icon: Icons.kitchen_outlined,
      title: 'המזווה הביתי 📦',
      description: 'המזווה עוקב אחרי מה שיש בבית.\n\n🔄 אוטומטי: כשמסיימים קנייה — המוצרים עולים למזווה.\n✏️ ידני: לחצו ➕ במזווה להוסיף מוצרים בעצמכם.\n\nכשמשהו אוזל — תופיע הצעה חכמה בדף הבית להוסיף אותו לרשימה הבאה.',
    ),
    _TutorialStep(
      icon: Icons.family_restroom,
      title: 'ניהול משפחתי 👨‍👩‍👧‍👦',
      description: 'כך מצרפים משפחה:\n\n1️⃣ הגדרות → ניהול משפחה → הזמן חברים\n2️⃣ שלחו הזמנה באימייל\n3️⃣ בן המשפחה מאשר ומצטרף\n\nמרגע ההצטרפות — כולם רואים את אותן רשימות ומזווה בזמן אמת. בלי להתקשר לשאול "מה לקנות?" 😄',
    ),
    _TutorialStep(
      icon: Icons.history_outlined,
      title: 'היסטוריה וסטטיסטיקות 📊',
      description: 'כל קנייה נשמרת כקבלה עם תאריך, חנות וסכום.\n\nבטאב 📜 היסטוריה תראו:\n• כמה הוצאתם החודש\n• ממוצע לקנייה\n• פירוט לפי חנות\n\nאפשר לסנן לפי תקופה ולמיין לפי תאריך, חנות או סכום.',
    ),
    _TutorialStep(
      icon: Icons.explore_outlined,
      title: 'הניווט שלכם 🧭',
      description: '🏠 בית — סיכום יומי, הצעות חכמות ורשימות פעילות\n\n📦 מזווה — כל המוצרים בבית + הוספה ידנית\n\n📜 היסטוריה — קבלות, הוצאות וסטטיסטיקות\n\n⚙️ הגדרות — פרופיל, משפחה, התראות, ערכת נושא',
    ),
    _TutorialStep(
      icon: Icons.rocket_launch,
      title: 'מוכנים! 🚀',
      description: 'התחילו ביצירת רשימת הקניות הראשונה שלכם.\n\n💡 טיפ: הוסיפו מוצרים מהקטלוג — הם יזכרו אותם לפעם הבאה!\n\nאפשר תמיד לחזור להדרכה דרך ⚙️ הגדרות → הצג הדרכה מחדש.',
    ),
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
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
