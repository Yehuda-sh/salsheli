// 📄 File: lib/screens/onboarding/widgets/onboarding_steps.dart
// תיאור: רכיבי שלבי Onboarding - כל שלב במסך נפרד
//
// כולל:
// - 8 שלבים: Welcome, Family Size, Stores, Budget, Categories, Sharing, Reminder, Summary
// - אנימציות חלקות
// - תמיכה RTL מלאה
// - עיצוב אחיד עם AppBrand

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../data/onboarding_data.dart';
import '../../../config/filters_config.dart'; // kCategories
import '../../../theme/app_theme.dart'; // AppBrand

// רשימת חנויות מקומית (מחליף את kPredefinedStores שנמחק)
const List<String> _kStores = [
  'שופרסל',
  'רמי לוי',
  'ויקטורי',
  'סופר פארם',
  'יינות ביתן',
  'טיב טעם',
  'מגה',
  'יוחננוף',
];

class OnboardingSteps {
  static List<Widget> build({
    required OnboardingData data,
    required ValueChanged<int> onFamilySizeChanged,
    required ValueChanged<Set<String>> onStoresChanged,
    required ValueChanged<double> onBudgetChanged,
    required ValueChanged<Set<String>> onCategoriesChanged,
    required ValueChanged<bool> onShareChanged,
    required ValueChanged<String> onReminderChanged, // ✅ שונה ל-String
  }) {
    return [
      const _WelcomeStep(),
      _FamilySizeStep(value: data.familySize, onChanged: onFamilySizeChanged),
      _MultiSelectStep(
        title: "בחר חנויות מועדפות:",
        icon: Icons.store,
        options: _kStores,
        selected: data.preferredStores,
        onChanged: onStoresChanged,
      ),
      _BudgetStep(value: data.monthlyBudget, onChanged: onBudgetChanged),
      _MultiSelectStep(
        title: "אילו קטגוריות חשובות לכם במיוחד?",
        icon: Icons.category,
        options: kCategories.values.toList(),
        selected: data.importantCategories,
        onChanged: onCategoriesChanged,
      ),
      _SharingStep(value: data.shareLists, onChanged: onShareChanged),
      _ReminderStep(value: data.reminderTime, onChanged: onReminderChanged),
      _SummaryStep(data: data),
    ];
  }
}

// ========================================
// StepWrapper - מעטפת לכל שלב
// ========================================

class _StepWrapper extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _StepWrapper({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child:
          Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 80, color: accent),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: t.titleLarge?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  child,
                ],
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.1, curve: Curves.easeOut),
    );
  }
}

// ========================================
// שלב 1: Welcome
// ========================================

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child:
          Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 100, color: accent),
                  const SizedBox(height: 20),
                  Text(
                    "ברוכים הבאים ל־Salsheli 🎉",
                    style: t.titleLarge?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "נהל רשימות חכמות, שתף את המשפחה וחסוך כסף וזמן.",
                    textAlign: TextAlign.center,
                    style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.1, curve: Curves.easeOut),
    );
  }
}

// ========================================
// שלב 2: Family Size
// ========================================

class _FamilySizeStep extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _FamilySizeStep({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return _StepWrapper(
      icon: Icons.family_restroom,
      title: "כמה נפשות במשפחה?",
      child: Column(
        children: [
          Text(
            "$value",
            style: t.displayLarge?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: value.toDouble(),
            min: kMinFamilySize.toDouble(),
            max: kMaxFamilySize.toDouble(),
            divisions: kMaxFamilySize - kMinFamilySize,
            onChanged: (v) => onChanged(v.toInt()),
          ),
        ],
      ),
    );
  }
}

// ========================================
// שלב 3+5: Multi Select (Stores + Categories)
// ========================================

class _MultiSelectStep extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  const _MultiSelectStep({
    required this.title,
    required this.icon,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return _StepWrapper(
      icon: icon,
      title: title,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: options.map((opt) {
          final isSelected = selected.contains(opt);
          return FilterChip(
            label: Text(opt),
            selected: isSelected,
            onSelected: (val) {
              final newSet = Set<String>.from(selected);
              if (val) {
                newSet.add(opt);
              } else {
                newSet.remove(opt);
              }
              onChanged(newSet);
            },
            backgroundColor: cs.surfaceContainerHighest.withValues(alpha: 0.18),
            selectedColor: cs.primaryContainer,
          );
        }).toList(),
      ),
    );
  }
}

// ========================================
// שלב 4: Budget
// ========================================

class _BudgetStep extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _BudgetStep({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return _StepWrapper(
      icon: Icons.monetization_on,
      title: "מה התקציב החודשי שלך?",
      child: Column(
        children: [
          Text(
            "${value.toStringAsFixed(0)} ₪",
            style: t.displayMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: value,
            min: kMinMonthlyBudget,
            max: kMaxMonthlyBudget,
            divisions: 100,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ========================================
// שלב 6: Sharing
// ========================================

class _SharingStep extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SharingStep({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    return _StepWrapper(
      icon: Icons.share,
      title: "האם תרצה לשתף רשימות עם בני משפחה?",
      child: SwitchListTile(
        contentPadding: const EdgeInsetsDirectional.only(start: 8, end: 4),
        title: Text(
          "שיתוף רשימות משפחתי",
          textAlign: TextAlign.right,
          style: t.bodyLarge?.copyWith(color: cs.onSurface),
        ),
        value: value,
        activeThumbColor: accent,
        onChanged: onChanged,
      ),
    );
  }
}

// ========================================
// שלב 7: Reminder Time
// ========================================

class _ReminderStep extends StatelessWidget {
  final String value; // ✅ שונה מ-TimeOfDay ל-String
  final ValueChanged<String> onChanged; // ✅ שונה מ-TimeOfDay ל-String

  const _ReminderStep({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    return _StepWrapper(
      icon: Icons.alarm,
      title: "באיזו שעה נוח לך לקבל תזכורות?",
      child: Column(
        children: [
          Text(
            value, // ✅ מציג את המחרוזת ישירות
            style: t.displayMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () async {
              // המרה של המחרוזת ל-TimeOfDay לצורך הצגה ב-picker
              final parts = value.split(':');
              final currentTime = TimeOfDay(
                hour: int.parse(parts[0]),
                minute: int.parse(parts[1]),
              );

              final pickedTime = await showTimePicker(
                context: context,
                initialTime: currentTime,
                builder: (context, child) {
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: child!,
                  );
                },
              );

              if (pickedTime != null) {
                // המרה חזרה למחרוזת בפורמט HH:MM
                final timeString =
                    '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                onChanged(timeString);
              }
            },
            icon: Icon(Icons.access_time, color: accent),
            label: Text("שינוי שעה", style: TextStyle(color: accent)),
            style: OutlinedButton.styleFrom(side: BorderSide(color: accent)),
          ),
        ],
      ),
    );
  }
}

// ========================================
// שלב 8: Summary
// ========================================

class _SummaryStep extends StatelessWidget {
  final OnboardingData data;

  const _SummaryStep({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 80, color: accent),
          const SizedBox(height: 16),
          Text(
            "סיכום ההעדפות שלך",
            textAlign: TextAlign.center,
            style: t.titleLarge?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          _RtlSummaryRow(
            leadingEmojiOrIconText: "👨‍👩‍👧‍👦",
            text: "משפחה: ${data.familySize} נפשות",
          ),
          const SizedBox(height: 6),
          _RtlSummaryRow(
            leadingEmojiOrIconText: "🏪",
            text:
                "חנויות: ${data.preferredStores.isEmpty ? "לא נבחר" : data.preferredStores.join(", ")}",
          ),
          const SizedBox(height: 6),
          _RtlSummaryRow(
            leadingEmojiOrIconText: "💰",
            text: "תקציב חודשי: ${data.monthlyBudget.toStringAsFixed(0)} ₪",
          ),
          const SizedBox(height: 6),
          _RtlSummaryRow(
            leadingEmojiOrIconText: "📦",
            text:
                "קטגוריות: ${data.importantCategories.isEmpty ? "לא נבחר" : data.importantCategories.join(", ")}",
          ),
          const SizedBox(height: 6),
          _RtlSummaryRow(
            leadingEmojiOrIconText: "🤝",
            text: "שיתוף רשימות: ${data.shareLists ? "כן" : "לא"}",
          ),
          const SizedBox(height: 6),
          _RtlSummaryRow(
            leadingEmojiOrIconText: "⏰",
            text:
                "שעה מועדפת: ${data.reminderTime}", // ✅ מציג את המחרוזת ישירות
          ),
          const SizedBox(height: 16),
          Text(
            "לחץ על 'סיום' כדי להמשיך להרשמה.",
            textAlign: TextAlign.right,
            style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, curve: Curves.easeOut),
    );
  }
}

// ========================================
// Helper Widget - שורה בסיכום
// ========================================

class _RtlSummaryRow extends StatelessWidget {
  final String leadingEmojiOrIconText;
  final String text;

  const _RtlSummaryRow({
    required this.leadingEmojiOrIconText,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(leadingEmojiOrIconText, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.right,
            style: t.bodyLarge?.copyWith(color: cs.onSurface),
          ),
        ),
      ],
    );
  }
}
