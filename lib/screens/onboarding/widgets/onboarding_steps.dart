// 📄 lib/screens/onboarding/widgets/onboarding_steps.dart
//
// רכיבי שלבי Onboarding - 7 שלבים אינטראקטיביים.
// כולל Welcome, גודל הבית, חנויות, תדירות, שיתוף, תזכורת וסיכום.
//
// 📋 Features:
// - משוב Haptic מבוסס הקשר (Slider/Chips/Buttons)
// - אנימציות כניסה מדורגות (Staggered)
// - שיפור 'חומריות' הפתקיות (Paper Materiality)
//
// 📝 Version: 4.0 (Hybrid Premium)
// 📅 Updated: 22/02/2026
// 🔗 Related: OnboardingData, OnboardingScreen, StickyNote

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../config/stores_config.dart';
import '../../../core/constants.dart';
import '../../../core/ui_constants.dart';
import '../../../data/child.dart';
import '../../../data/onboarding_data.dart';
import '../../../l10n/app_strings.dart';
import '../../../l10n/onboarding_extensions.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/sticky_note.dart';

class OnboardingSteps {
  static List<Widget> build({
    required OnboardingData data,
    required ValueChanged<int> onFamilySizeChanged,
    required ValueChanged<Set<String>> onStoresChanged,
    required ValueChanged<int> onShoppingFrequencyChanged,
    required ValueChanged<Set<int>> onShoppingDaysChanged,
    required ValueChanged<bool> onHasChildrenChanged,
    required ValueChanged<List<Child>> onChildrenChanged,
    required ValueChanged<bool> onShareChanged,
    required ValueChanged<String> onReminderChanged,
  }) {
    return [
      const _WelcomeStep(),
      _FamilySizeStep(
        value: data.familySize,
        onChanged: onFamilySizeChanged,
        hasChildren: data.hasChildren,
        children: data.children,
        onHasChildrenChanged: onHasChildrenChanged,
        onChildrenChanged: onChildrenChanged,
        stickyColor: kStickyYellow,
        rotation: -0.015,
      ),
      _MultiSelectStep(
        title: AppStrings.onboarding.storesTitle,
        icon: Icons.store,
        options: StoresConfig.allDisplayNames,
        selected: data.preferredStores,
        onChanged: onStoresChanged,
        stickyColor: kStickyPink,
        rotation: 0.02,
      ),
      _ShoppingFrequencyStep(
        frequency: data.shoppingFrequency,
        selectedDays: data.shoppingDays,
        onFrequencyChanged: onShoppingFrequencyChanged,
        onDaysChanged: onShoppingDaysChanged,
        stickyColor: kStickyGreen,
        rotation: -0.01,
      ),
      _SharingStep(
        value: data.shareLists,
        onChanged: onShareChanged,
        stickyColor: kStickyOrange,
        rotation: -0.02,
      ),
      _ReminderStep(
        value: data.reminderTime,
        onChanged: onReminderChanged,
        stickyColor: kStickyCyan,
        rotation: 0.01,
      ),
      _SummaryStep(
        data: data,
        stickyColor: kStickyGreen,
        rotation: -0.015,
      ),
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
  final Color? stickyColor;
  final double rotation;

  const _StepWrapper({
    required this.icon,
    required this.title,
    required this.child,
    this.stickyColor,
    this.rotation = 0.01,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;
    // צבע ברירת מחדל למערכת Sticky Notes
    final noteColor = stickyColor ?? kStickyCyan;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: accent),
            SizedBox(height: kSpacingLarge),
            Text(
              title,
              textAlign: TextAlign.center,
              style: t.headlineSmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: kSpacingLarge),
            // StickyNote עם shimmer חד-פעמי ברגע ההופעה
            // Note: StickyNote has an `animate` property that shadows
            // flutter_animate's extension, so we wrap in SizedBox.
            SizedBox(
              width: double.infinity,
              child: StickyNote(
                color: noteColor,
                rotation: rotation,
                padding: kSpacingLarge,
                child: child,
              ),
            ).animate().shimmer(
                  duration: 800.ms,
                  delay: 400.ms,
                  color: noteColor.withValues(alpha: 0.3),
                ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: kAnimationDurationMedium)
          .slideY(begin: 0.1, curve: Curves.easeOutCubic),
    );
  }
}

// ========================================
// שלב 1: Welcome - משופר עם אנימציות!
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // אייקון מונפש עם זוהר
          _AnimatedWelcomeIcon(accent: accent),
          SizedBox(height: kSpacingXLarge),
          Text(
            AppStrings.onboarding.welcomeTitle,
            style: t.titleLarge?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: kSpacingMedium),
          Text(
            AppStrings.onboarding.welcomeSubtitle,
            textAlign: TextAlign.center,
            style: t.bodyLarge?.copyWith(
              color: cs.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: kSpacingSmall),
        ],
      )
          .animate()
          .fadeIn(duration: kAnimationDurationMedium)
          .slideY(begin: 0.1, curve: Curves.easeOutCubic),
    );
  }
}

/// אייקון מונפש עם זוהר ואנימציית shimmer
class _AnimatedWelcomeIcon extends StatelessWidget {
  final Color accent;

  const _AnimatedWelcomeIcon({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kIconSizeXLarge + kLogoGlowPadding,
      height: kIconSizeXLarge + kLogoGlowPadding,
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
          child: Image.asset(
            'assets/images/app_icon.png',
            width: kIconSizeXLarge,
            height: kIconSizeXLarge,
            errorBuilder: (_, __, ___) => Icon(
              Icons.shopping_cart,
              size: kIconSizeXLarge,
              color: accent,
            ),
          ),
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

class _FamilySizeStep extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final bool hasChildren;
  final List<Child> children;
  final ValueChanged<bool> onHasChildrenChanged;
  final ValueChanged<List<Child>> onChildrenChanged;
  final Color? stickyColor;
  final double rotation;

  const _FamilySizeStep({
    required this.value,
    required this.onChanged,
    required this.hasChildren,
    required this.children,
    required this.onHasChildrenChanged,
    required this.onChildrenChanged,
    this.stickyColor,
    this.rotation = 0.01,
  });

  @override
  State<_FamilySizeStep> createState() => _FamilySizeStepState();
}

class _FamilySizeStepState extends State<_FamilySizeStep> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return _StepWrapper(
      icon: Icons.family_restroom,
      title: AppStrings.onboarding.familySizeTitle,
      stickyColor: widget.stickyColor,
      rotation: widget.rotation,
      child: Column(
        children: [
          // מספר אנשים
          Text(
            '${widget.value}',
            style: t.displayLarge?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: kSpacingMedium),
          Slider(
            value: widget.value.toDouble(),
            min: kMinFamilySize.toDouble(),
            max: kMaxFamilySize.toDouble(),
            divisions: kMaxFamilySize - kMinFamilySize,
            onChanged: (v) {
              unawaited(HapticFeedback.selectionClick());
              final newSize = v.toInt();
              widget.onChanged(newSize);
            },
          ),

          // אם יש יותר מ-2 אנשים, שאל על ילדים
          if (widget.value > 2) ...[
            const SizedBox(height: kSpacingLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: widget.hasChildren,
                  onChanged: (val) {
                    widget.onHasChildrenChanged(val ?? false);
                  },
                ),
                Text(
                  AppStrings.onboarding.hasChildrenQuestion,
                  style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          // אם יש ילדים, הצג טופס
          if (widget.hasChildren && widget.value > 2) ...[
            const SizedBox(height: kSpacingMedium),
            ...widget.children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              return _ChildForm(
                key: ValueKey('child_$index'),
                child: child,
                index: index,
                onChanged: (updated) {
                  final newList = List<Child>.from(widget.children);
                  newList[index] = updated;
                  widget.onChildrenChanged(newList);
                },
                onRemove: () {
                  unawaited(HapticFeedback.lightImpact());
                  final newList = List<Child>.from(widget.children);
                  newList.removeAt(index);
                  widget.onChildrenChanged(newList);
                },
              );
            }),
            const SizedBox(height: kSpacingSmall),
            TextButton.icon(
              onPressed: () {
                unawaited(HapticFeedback.mediumImpact());
                final newList = List<Child>.from(widget.children)
                  ..add(const Child(name: '', ageCategory: '0-1'));
                widget.onChildrenChanged(newList);
              },
              icon: const Icon(Icons.add),
              label: Text(AppStrings.onboarding.addChild),
            ),
          ],
        ],
      ),
    );
  }
}

// טופס ילד בודד — Premium
class _ChildForm extends StatefulWidget {
  final Child child;
  final int index;
  final ValueChanged<Child> onChanged;
  final VoidCallback onRemove;

  const _ChildForm({
    super.key,
    required this.child,
    required this.index,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<_ChildForm> createState() => _ChildFormState();
}

class _ChildFormState extends State<_ChildForm> {
  bool _shaking = false;

  void _onDeleteTap() {
    setState(() => _shaking = true);
    Future.delayed(400.ms, () {
      if (mounted) {
        widget.onRemove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final form = Container(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      padding: const EdgeInsets.all(kSpacingSmall),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${widget.child.emoji} ${AppStrings.onboarding.childLabel(widget.index + 1)}',
                style: t.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: _onDeleteTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: kSpacingSmall),
          TextFormField(
            decoration: InputDecoration(
              labelText: AppStrings.onboarding.childNameLabel,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            initialValue: widget.child.name,
            onChanged: (val) => widget.onChanged(widget.child.copyWith(name: val)),
          ),
          const SizedBox(height: kSpacingSmall),
          DropdownButtonFormField<String>(
            value: widget.child.ageCategory,
            decoration: InputDecoration(
              labelText: AppStrings.onboarding.childAgeLabel,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            items: kChildrenAgeGroups.map((age) {
              return DropdownMenuItem(
                value: age,
                child: Text(age.ageLabel),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                widget.onChanged(widget.child.copyWith(ageCategory: val));
              }
            },
          ),
        ],
      ),
    );

    if (_shaking) {
      return form
          .animate(onComplete: (_) {})
          .shake(hz: 4, duration: 350.ms);
    }
    return form;
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
  final Color? stickyColor;
  final double rotation;

  const _MultiSelectStep({
    required this.title,
    required this.icon,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.stickyColor,
    this.rotation = 0.01,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return _StepWrapper(
      icon: icon,
      title: title,
      stickyColor: stickyColor,
      rotation: rotation,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: kSpacingSmall,
        runSpacing: kSpacingSmall,
        children: options.map((opt) {
          final isSelected = selected.contains(opt);
          return FilterChip(
            label: Text(
              opt,
              style: const TextStyle(
                fontSize: kFontSizeBody,
                fontWeight: FontWeight.w500,
              ),
            ),
            selected: isSelected,
            padding: const EdgeInsets.symmetric(
              horizontal: kSpacingMedium,
              vertical: kSpacingSmall,
            ),
            onSelected: (val) {
              unawaited(HapticFeedback.lightImpact());
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
// שלב 4: Shopping Frequency + Days (מסך אחד!)
// ========================================

class _ShoppingFrequencyStep extends StatelessWidget {
  final int frequency;
  final Set<int> selectedDays;
  final ValueChanged<int> onFrequencyChanged;
  final ValueChanged<Set<int>> onDaysChanged;
  final Color? stickyColor;
  final double rotation;

  const _ShoppingFrequencyStep({
    required this.frequency,
    required this.selectedDays,
    required this.onFrequencyChanged,
    required this.onDaysChanged,
    this.stickyColor,
    this.rotation = 0.01,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return _StepWrapper(
      icon: Icons.calendar_today,
      title: AppStrings.onboarding.frequencyTitle,
      stickyColor: stickyColor,
      rotation: rotation,
      child: Column(
        children: [
          // שאלה 1: תדירות
          Text(
            AppStrings.onboarding.frequencyQuestion,
            style: t.titleSmall?.copyWith(color: cs.onSurface),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: kSpacingSmall),
          Text(
            AppStrings.onboarding.frequencyPerWeek(frequency),
            style: t.displaySmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: kSpacingSmall),
          Slider(
            value: frequency.toDouble(),
            min: 1,
            max: 7,
            divisions: 6,
            onChanged: (v) {
              unawaited(HapticFeedback.selectionClick());
              final newFreq = v.toInt();
              onFrequencyChanged(newFreq);
            },
          ),
          SizedBox(height: kSpacingLarge),

          // שאלה 2: ימים קבועים
          Text(
            AppStrings.onboarding.fixedDaysQuestion,
            style: t.titleSmall?.copyWith(color: cs.onSurface),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: kSpacingSmall),
          Text(
            AppStrings.onboarding.multiSelectHint,
            style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: kSpacingMedium),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: kSpacingSmall,
            runSpacing: kSpacingSmall,
            children: OnboardingDayX.allDays.map((day) {
              final isSelected = selectedDays.contains(day);
              final dayLabel = day.dayLabel;
              return FilterChip(
                label: Text(dayLabel),
                selected: isSelected,
                onSelected: (val) {
                  unawaited(HapticFeedback.lightImpact());
                  final newSet = Set<int>.from(selectedDays);
                  if (val) {
                    newSet.add(day);
                  } else {
                    newSet.remove(day);
                  }
                  onDaysChanged(newSet);

                  // עדכון אוטומטי של התדירות לפי מספר הימים שנבחרו
                  if (newSet.isNotEmpty && newSet.length != frequency) {
                    onFrequencyChanged(newSet.length);
                  }
                },
                backgroundColor: cs.surfaceContainerHighest.withValues(alpha: 0.18),
                selectedColor: cs.primaryContainer,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ========================================
// שלב 5: Sharing
// ========================================

class _SharingStep extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? stickyColor;
  final double rotation;

  const _SharingStep({
    required this.value,
    required this.onChanged,
    this.stickyColor,
    this.rotation = 0.01,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    return _StepWrapper(
      icon: Icons.share,
      title: AppStrings.onboarding.sharingTitle,
      stickyColor: stickyColor,
      rotation: rotation,
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
        activeColor: accent,
        onChanged: (val) {
          onChanged(val);
        },
      ),
    );
  }
}

// ========================================
// שלב 5: Reminder Time
// ========================================

class _ReminderStep extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final Color? stickyColor;
  final double rotation;

  const _ReminderStep({
    required this.value,
    required this.onChanged,
    this.stickyColor,
    this.rotation = 0.01,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    return _StepWrapper(
      icon: Icons.alarm,
      title: AppStrings.onboarding.reminderTitle,
      stickyColor: stickyColor,
      rotation: rotation,
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
              } else {
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
// שלב 6: Summary — Premium
// ========================================

class _SummaryStep extends StatelessWidget {
  final OnboardingData data;
  final Color? stickyColor;
  final double rotation;

  const _SummaryStep({
    required this.data,
    this.stickyColor,
    this.rotation = 0.01,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;
    final noteColor = stickyColor ?? kStickyGreen;

    final storesText = data.preferredStores.isEmpty
        ? AppStrings.onboarding.noStoresSelected
        : data.preferredStores.join(', ');

    // שורות הסיכום
    final summaryRows = <Widget>[
      _RtlSummaryRow(
        leadingEmojiOrIconText: '👨‍👩‍👧‍👦',
        text: AppStrings.onboarding.familySizeSummary(data.familySize),
      ),
      _RtlSummaryRow(
        leadingEmojiOrIconText: '🏪',
        text: AppStrings.onboarding.storesSummary(storesText),
      ),
      _RtlSummaryRow(
        leadingEmojiOrIconText: '📅',
        text: AppStrings.onboarding.frequencySummary(data.shoppingFrequency),
      ),
      if (data.shoppingDays.isNotEmpty)
        _RtlSummaryRow(
          leadingEmojiOrIconText: '🗓️',
          text: AppStrings.onboarding.fixedDaysSummary(
            data.shoppingDays.map((d) => d.dayLabel).join(', '),
          ),
        ),
      if (data.hasChildren)
        _RtlSummaryRow(
          leadingEmojiOrIconText: '👶',
          text: AppStrings.onboarding.childrenSummary(
            data.children.isEmpty
                ? AppStrings.onboarding.childrenYes
                : data.children
                    .map((c) => '${c.name} (${c.ageDescription})')
                    .join(', '),
          ),
        ),
      _RtlSummaryRow(
        leadingEmojiOrIconText: '🤝',
        text: AppStrings.onboarding.sharingSummary(data.shareLists),
      ),
      _RtlSummaryRow(
        leadingEmojiOrIconText: '⏰',
        text: AppStrings.onboarding.reminderTimeSummary(data.reminderTime),
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: kIconSizeXLarge, color: accent),
          SizedBox(height: kSpacingMedium),
          Text(
            AppStrings.onboarding.summaryTitle,
            textAlign: TextAlign.center,
            style: t.titleLarge?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: kSpacingLarge),
          // StickyNote עם Gradient עדין של "נייר פוטו"
          StickyNote(
            color: noteColor,
            rotation: rotation,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    cs.surface.withValues(alpha: 0.08),
                    Colors.transparent,
                    cs.scrim.withValues(alpha: 0.03),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: Column(
                children: [
                  // שורות סיכום עם אנימציה מדורגת (40ms delay)
                  ...summaryRows.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: kSpacingXTiny),
                      child: entry.value
                          .animate()
                          .fadeIn(
                            duration: 300.ms,
                            delay: (entry.key * 40).ms,
                          )
                          .slideX(
                            begin: 0.05,
                            end: 0,
                            duration: 300.ms,
                            delay: (entry.key * 40).ms,
                            curve: Curves.easeOut,
                          ),
                    );
                  }),
                  SizedBox(height: kSpacingMedium),
                  Text(
                    AppStrings.onboarding.summaryFinishHint,
                    textAlign: TextAlign.right,
                    style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
          .animate()
          .fadeIn(duration: kAnimationDurationMedium)
          .slideY(begin: 0.1, curve: Curves.easeOutCubic),
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
        Text(leadingEmojiOrIconText, style: TextStyle(fontSize: kFontSizeMedium)),
        SizedBox(width: kSpacingSmall),
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
