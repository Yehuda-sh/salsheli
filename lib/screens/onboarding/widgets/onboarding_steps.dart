// 📄 lib/screens/onboarding/widgets/onboarding_steps.dart
//
// רכיבי שלבי Onboarding - 7 שלבים אינטראקטיביים.
// כולל Welcome, גודל משפחה, חנויות, תדירות, שיתוף, תזכורת וסיכום.
//
// 🔗 Related: OnboardingData, OnboardingScreen, StickyNote

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../config/stores_config.dart';
import '../../../core/constants.dart';
import '../../../core/ui_constants.dart';
import '../../../data/child.dart'; // ✅ NEW
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
    debugPrint('📋 onboarding: בניית 7 שלבים');
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
        options: StoresConfig.allStores,
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
            Icon(icon, size: 72, color: accent), // ✅ מוגדל מ-kIconSizeXLarge (64)
            const SizedBox(height: kSpacingLarge), // ✅ מוגדל מ-Medium
            Text(
              title,
              textAlign: TextAlign.center,
              style: t.headlineSmall?.copyWith( // ✅ מוגדל מ-titleLarge
                color: cs.onSurface,
                fontWeight: FontWeight.bold, // ✅ bold במקום w600
              ),
            ),
            const SizedBox(height: kSpacingLarge),
            // ⭐ עטיפה ב-StickyNote לעיצוב אחיד - מוגדל!
            StickyNote(
              color: noteColor,
              rotation: rotation,
              padding: kSpacingLarge, // ✅ padding מוגדל (24px במקום 16px)
              child: child,
            ),
          ],
        ),
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
          const SizedBox(height: kSpacingXLarge),
          Text(
            AppStrings.onboarding.welcomeTitle,
            style: t.titleLarge?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: kSpacingMedium),
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
        child: Icon(
          Icons.shopping_cart,
          size: kIconSizeXLarge,
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
      title: 'כמה אנשים במשפחה?', // ✅ טקסט מעודכן
      stickyColor: widget.stickyColor,
      rotation: widget.rotation,
      child: Column(
        children: [
          // מספר אנשים
          Text(
            "${widget.value}",
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
              final newSize = v.toInt();
              debugPrint('👨‍👩‍👧‍👦 onboarding: Family size = $newSize');
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
                  'יש לכם ילדים?',
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
                key: ValueKey('child_$index'), // ✅ key ייחודי לכל ילד
                child: child,
                index: index,
                onChanged: (updated) {
                  final newList = List<Child>.from(widget.children);
                  newList[index] = updated;
                  widget.onChildrenChanged(newList);
                },
                onRemove: () {
                  final newList = List<Child>.from(widget.children);
                  newList.removeAt(index);
                  widget.onChildrenChanged(newList);
                },
              );
            }),
            const SizedBox(height: kSpacingSmall),
            TextButton.icon(
              onPressed: () {
                final newList = List<Child>.from(widget.children)
                  ..add(const Child(name: '', ageCategory: '0-1'));
                widget.onChildrenChanged(newList);
              },
              icon: const Icon(Icons.add),
              label: const Text('הוסף ילד נוסף'),
            ),
          ],
        ],
      ),
    );
  }
}

// ✅ טופס ילד בודד
class _ChildForm extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      padding: const EdgeInsets.all(kSpacingSmall),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${_getChildIcon(child.ageCategory)} ילד ${index + 1}',
                style: t.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: kSpacingSmall),
          TextField(
            decoration: const InputDecoration(
              labelText: 'שם',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            controller: TextEditingController(text: child.name),
            onChanged: (val) => onChanged(child.copyWith(name: val)),
          ),
          const SizedBox(height: kSpacingSmall),
          DropdownButtonFormField<String>(
            value: child.ageCategory,
            decoration: const InputDecoration(
              labelText: 'גיל',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: kChildrenAgeGroups.map((age) {
              return DropdownMenuItem(
                value: age,
                child: Text(_getAgeLabel(age)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                onChanged(child.copyWith(ageCategory: val));
              }
            },
          ),
        ],
      ),
    );
  }

  String _getChildIcon(String age) {
    switch (age) {
      case '0-1':
        return '👶';
      case '2-3':
        return '🧒';
      case '4-6':
        return '🧒';
      case '7-12':
        return '👦';
      case '13-18':
        return '🧑';
      default:
        return '👶';
    }
  }

  String _getAgeLabel(String age) {
    switch (age) {
      case '0-1':
        return 'תינוק/ת (0-1)';
      case '2-3':
        return 'גיל הרך (2-3)';
      case '4-6':
        return 'גן (4-6)';
      case '7-12':
        return 'בית ספר (7-12)';
      case '13-18':
        return 'נוער (13-18)';
      default:
        return age;
    }
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
                fontSize: 16, // ✅ מוגדל מ-14 (ברירת מחדל)
                fontWeight: FontWeight.w500,
              ),
            ),
            selected: isSelected,
            padding: const EdgeInsets.symmetric(
              horizontal: kSpacingMedium, // ✅ padding מוגדל
              vertical: kSpacingSmall,
            ),
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
// שלב 4: Shopping Frequency + Days 🆕 (מסך אחד!)
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
      title: 'תדירות קניות',
      stickyColor: stickyColor,
      rotation: rotation,
      child: Column(
        children: [
          // שאלה 1: תדירות
          Text(
            'כמה פעמים בשבוע אתם קונים קניות?',
            style: t.titleSmall?.copyWith(color: cs.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            '$frequency פעמים בשבוע',
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
              final newFreq = v.toInt();
              debugPrint('📅 onboarding: Shopping frequency = $newFreq');
              onFrequencyChanged(newFreq);
            },
          ),
          const SizedBox(height: kSpacingLarge),
          
          // שאלה 2: ימים קבועים
          Text(
            'יש לכם ימים קבועים לקניות?',
            style: t.titleSmall?.copyWith(color: cs.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            '(בחירה מרובה)',
            style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: kSpacingMedium),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: kSpacingSmall,
            runSpacing: kSpacingSmall,
            children: OnboardingExtensions.allDays.map((day) {
              final isSelected = selectedDays.contains(day);
              final dayLabel = OnboardingExtensions.getDayLabel(day);
              return FilterChip(
                label: Text(dayLabel),
                selected: isSelected,
                onSelected: (val) {
                  final newSet = Set<int>.from(selectedDays);
                  if (val) {
                    newSet.add(day);
                    debugPrint('➕ onboarding: נוסף יום - $dayLabel');
                  } else {
                    newSet.remove(day);
                    debugPrint('➖ onboarding: הוסר יום - $dayLabel');
                  }
                  debugPrint('✅ onboarding: סה"צ נבחרו ${newSet.length} ימים');
                  onDaysChanged(newSet);

                  // ✅ עדכון אוטומטי של התדירות לפי מספר הימים שנבחרו
                  if (newSet.isNotEmpty && newSet.length != frequency) {
                    debugPrint('🔄 onboarding: מעדכן תדירות ל-${newSet.length} (לפי ימים נבחרים)');
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
// שלב 6: Summary
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
    debugPrint('📊 onboarding: Summary step');
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;
    final noteColor = stickyColor ?? kStickyGreen;

    final storesText = data.preferredStores.isEmpty
        ? AppStrings.onboarding.noStoresSelected
        : data.preferredStores.join(", ");

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
          // ⭐ עטיפה ב-StickyNote לעיצוב אחיד!
          StickyNote(
            color: noteColor,
            rotation: rotation,
            child: Column(
              children: [
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
                  leadingEmojiOrIconText: "📅",
                  text: 'תדירות: ${data.shoppingFrequency} פעמים בשבוע',
                ),
                if (data.shoppingDays.isNotEmpty) ...[
                  const SizedBox(height: kSpacingXTiny),
                  _RtlSummaryRow(
                    leadingEmojiOrIconText: "🗓️",
                    text: 'ימים קבועים: ${data.shoppingDays.map((d) => OnboardingExtensions.getDayLabel(d)).join(', ')}',
                  ),
                ],
                if (data.hasChildren) ...[
                  const SizedBox(height: kSpacingXTiny),
                  _RtlSummaryRow(
                    leadingEmojiOrIconText: "👶",
                    text: 'ילדים: ${data.children.isEmpty ? 'כן' : data.children.map((c) => '${c.name} (${c.ageDescription})').join(', ')}',
                  ),
                ],
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
            ),
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
