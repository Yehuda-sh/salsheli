// 📄 File: lib/screens/onboarding/widgets/onboarding_steps.dart
//
// 🎯 מטרה: רכיבי שלבי Onboarding - 8 שלבים interactives
//
// 📋 כולל:
// - 8 שלבים: Welcome, Family Size, Stores, Budget, Categories, Sharing, Reminder, Summary
// - אנימציות חלקות עם flutter_animate
// - תמיכה RTL מלאה
// - עיצוב אחיד עם AppBrand
//
// 🔗 Dependencies:
// - flutter_animate: אנימציות (300ms fade + slide)
// - ../../../data/onboarding_data.dart: מודל OnboardingData
// - ../../../config/filters_config.dart: kCategories
// - ../../../config/stores_config.dart: StoresConfig.allStores
// - ../../../l10n/app_strings.dart: כל המחרוזות
// - ../../../core/ui_constants.dart: spacing + icon sizes
// - ../../../core/constants.dart: kMinFamilySize, kMaxFamilySize, kMinMonthlyBudget, kMaxMonthlyBudget
// - ../../../theme/app_theme.dart: AppBrand extension
//
// 🎯 שימוש:
// ```dart
// final steps = OnboardingSteps.build(
//   data: onboardingData,
//   onFamilySizeChanged: (size) => setState(() => data.familySize = size),
//   onStoresChanged: (stores) => setState(() => data.preferredStores = stores),
//   onBudgetChanged: (budget) => setState(() => data.monthlyBudget = budget),
//   onCategoriesChanged: (cats) => setState(() => data.importantCategories = cats),
//   onShareChanged: (share) => setState(() => data.shareLists = share),
//   onReminderChanged: (time) => setState(() => data.reminderTime = time),
// );
// ```
//
// 📝 הערות:
// - כל שלב הוא Widget נפרד עם _StepWrapper משותף
// - Callbacks מעדכנים את OnboardingData
// - Logging מפורט בפעולות (time picker, בחירות)
//
// Version: 2.0
// Last Updated: 08/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../data/onboarding_data.dart';
import '../../../config/filters_config.dart';
import '../../../config/stores_config.dart';
import '../../../theme/app_theme.dart';
import '../../../l10n/app_strings.dart';
import '../../../core/ui_constants.dart';
import '../../../core/constants.dart';

class OnboardingSteps {
  static List<Widget> build({
    required OnboardingData data,
    required ValueChanged<int> onFamilySizeChanged,
    required ValueChanged<Set<String>> onStoresChanged,
    required ValueChanged<double> onBudgetChanged,
    required ValueChanged<Set<String>> onCategoriesChanged,
    required ValueChanged<bool> onShareChanged,
    required ValueChanged<String> onReminderChanged,
  }) {
    debugPrint('📋 onboarding: בניית 8 שלבים');
    return [
      const _WelcomeStep(),
      _FamilySizeStep(value: data.familySize, onChanged: onFamilySizeChanged),
      _MultiSelectStep(
        title: AppStrings.onboarding.storesTitle,
        icon: Icons.store,
        options: StoresConfig.allStores,
        selected: data.preferredStores,
        onChanged: onStoresChanged,
      ),
      _BudgetStep(value: data.monthlyBudget, onChanged: onBudgetChanged),
      _MultiSelectStep(
        title: AppStrings.onboarding.categoriesTitle,
        icon: Icons.category,
        options: kCategories.map((id) => getCategoryLabel(id)).toList(),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: kIconSizeXLarge, color: accent),
          const SizedBox(height: kSpacingMedium),
          Text(
            title,
            textAlign: TextAlign.center,
            style: t.titleLarge?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: kSpacingLarge),
          child,
        ],
      )
          .animate()
          .fadeIn(duration: kAnimationDurationMedium)
          .slideY(begin: 0.1, curve: Curves.easeOut),
    );
  }
}

// ========================================
// שלב 1: Welcome - משופר עם אנימציות! ⭐
// ========================================

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    debugPrint('👋 onboarding: Welcome step');
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // אייקון מונפש עם זוהר! ⭐
          _AnimatedWelcomeIcon(accent: accent),
          const SizedBox(height: kSpacingLarge),
          Text(
            AppStrings.onboarding.welcomeTitle,
            style: t.titleLarge?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            AppStrings.onboarding.welcomeSubtitle,
            textAlign: TextAlign.center,
            style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      )
          .animate()
          .fadeIn(duration: kAnimationDurationMedium)
          .slideY(begin: 0.1, curve: Curves.easeOut),
    );
  }
}

/// אייקון מונפש עם זוהר ואנימציית shimmer ⭐
class _AnimatedWelcomeIcon extends StatelessWidget {
  final Color accent;

  const _AnimatedWelcomeIcon({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kIconSizeXXLarge + kLogoGlowPadding,
      height: kIconSizeXXLarge + kLogoGlowPadding,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // זוהר רדיאלי סביב האייקון
        gradient: RadialGradient(
          colors: [
            accent.withValues(alpha: kOpacityLow),
            accent.withValues(alpha: kOpacityVeryLow),
            accent.withValues(alpha: kOpacityMinimal),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.shopping_cart,
          size: kIconSizeXXLarge,
          color: accent,
        ),
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .shimmer(
          duration: kAnimationDurationSlow,
          color: accent.withValues(alpha: kOpacityLow),
          angle: kShimmerAngle,
          delay: const Duration(milliseconds: 800),
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
      title: AppStrings.onboarding.familySizeTitle,
      child: Column(
        children: [
          Text(
            "$value",
            style: t.displayLarge?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: kSpacingMedium),
          Slider(
            value: value.toDouble(),
            min: kMinFamilySize.toDouble(),
            max: kMaxFamilySize.toDouble(),
            divisions: kMaxFamilySize - kMinFamilySize,
            onChanged: (v) {
              final newSize = v.toInt();
              debugPrint('👨‍👩‍👧‍👦 onboarding: Family size = $newSize');
              onChanged(newSize);
            },
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
        spacing: kSpacingSmall,
        runSpacing: kSpacingSmall,
        children: options.map((opt) {
          final isSelected = selected.contains(opt);
          return FilterChip(
            label: Text(opt),
            selected: isSelected,
            onSelected: (val) {
              final newSet = Set<String>.from(selected);
              if (val) {
                newSet.add(opt);
                debugPrint('➕ onboarding: נוסף - $opt');
              } else {
                newSet.remove(opt);
                debugPrint('➖ onboarding: הוסר - $opt');
              }
              debugPrint('✅ onboarding: סה"כ נבחרו ${newSet.length} פריטים');
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
      title: AppStrings.onboarding.budgetTitle,
      child: Column(
        children: [
          Text(
            AppStrings.onboarding.budgetAmount(value),
            style: t.displayMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: kSpacingMedium),
          Slider(
            value: value,
            min: kMinMonthlyBudget,
            max: kMaxMonthlyBudget,
            divisions: 100,
            onChanged: (v) {
              debugPrint('💰 onboarding: תקציב חודשי = ${v.toStringAsFixed(0)} ₪');
              onChanged(v);
            },
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
      title: AppStrings.onboarding.sharingTitle,
      child: SwitchListTile(
        contentPadding: const EdgeInsetsDirectional.only(
          start: kSpacingSmall,
          end: kSpacingTiny,
        ),
        title: Text(
          AppStrings.onboarding.sharingOption,
          textAlign: TextAlign.right,
          style: t.bodyLarge?.copyWith(color: cs.onSurface),
        ),
        value: value,
        activeThumbColor: accent,
        onChanged: (val) {
          debugPrint('🤝 onboarding: שיתוף רשימות = ${val ? "מופעל" : "כבוי"}');
          onChanged(val);
        },
      ),
    );
  }
}

// ========================================
// שלב 7: Reminder Time
// ========================================

class _ReminderStep extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _ReminderStep({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    return _StepWrapper(
      icon: Icons.alarm,
      title: AppStrings.onboarding.reminderTitle,
      child: Column(
        children: [
          Text(
            value,
            style: t.displayMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: kSpacingMedium),
          OutlinedButton.icon(
            onPressed: () async {
              debugPrint('⏰ onboarding: פתיחת time picker');
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
                debugPrint('✅ onboarding: זמן תזכורת עודכן ל-$timeString');
                onChanged(timeString);
              } else {
                debugPrint('❌ onboarding: time picker בוטל');
              }
            },
            icon: Icon(Icons.access_time, color: accent),
            label: Text(
              AppStrings.onboarding.reminderChangeButton,
              style: TextStyle(color: accent),
            ),
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
    debugPrint('📊 onboarding: Summary step');
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    final storesText = data.preferredStores.isEmpty
        ? AppStrings.onboarding.noStoresSelected
        : data.preferredStores.join(", ");

    final categoriesText = data.importantCategories.isEmpty
        ? AppStrings.onboarding.noCategoriesSelected
        : data.importantCategories.join(", ");

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: kIconSizeXLarge, color: accent),
          const SizedBox(height: kSpacingMedium),
          Text(
            AppStrings.onboarding.summaryTitle,
            textAlign: TextAlign.center,
            style: t.titleLarge?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: kSpacingLarge),
          _RtlSummaryRow(
            leadingEmojiOrIconText: "👨‍👩‍👧‍👦",
            text: AppStrings.onboarding.familySizeSummary(data.familySize),
          ),
          const SizedBox(height: kSpacingXTiny),
          _RtlSummaryRow(
            leadingEmojiOrIconText: "🏪",
            text: AppStrings.onboarding.storesSummary(storesText),
          ),
          const SizedBox(height: kSpacingXTiny),
          _RtlSummaryRow(
            leadingEmojiOrIconText: "💰",
            text: AppStrings.onboarding.budgetSummary(data.monthlyBudget),
          ),
          const SizedBox(height: kSpacingXTiny),
          _RtlSummaryRow(
            leadingEmojiOrIconText: "📦",
            text: AppStrings.onboarding.categoriesSummary(categoriesText),
          ),
          const SizedBox(height: kSpacingXTiny),
          _RtlSummaryRow(
            leadingEmojiOrIconText: "🤝",
            text: AppStrings.onboarding.sharingSummary(data.shareLists),
          ),
          const SizedBox(height: kSpacingXTiny),
          _RtlSummaryRow(
            leadingEmojiOrIconText: "⏰",
            text: AppStrings.onboarding.reminderTimeSummary(data.reminderTime),
          ),
          const SizedBox(height: kSpacingMedium),
          Text(
            AppStrings.onboarding.summaryFinishHint,
            textAlign: TextAlign.right,
            style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      )
          .animate()
          .fadeIn(duration: kAnimationDurationMedium)
          .slideY(begin: 0.1, curve: Curves.easeOut),
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
        Text(leadingEmojiOrIconText, style: const TextStyle(fontSize: kFontSizeMedium)),
        const SizedBox(width: kSpacingSmall),
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
