// 📄 lib/widgets/inventory/pantry_empty_state.dart
//
// Empty State למזווה — חוויה מזמינה, "חיה" ויוקרתית.
//
// Features:
//   - Choreographed Entrance: כניסה מדורגת 5 קבוצות, 200ms בין כל קבוצה
//   - Physical Sticky Notes: rotate 0.01/-0.01, animate:false (תיזמון חיצוני)
//   - Haptic via StickyButton.haptic (not manual)
//   - RepaintBoundary: מבודד אנימציות כניסה משאר עץ הווידג'טים
//   - Gap: ריווח סמנטי במקום SizedBox
//   - Status Badge: Center wrapper לתיקון יישור RTL
//
// 🔗 Related: MyPantryScreen, InventoryProvider

import 'package:flutter/material.dart';
import 'package:memozap/l10n/app_strings.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../core/status_colors.dart';
import '../../core/ui_constants.dart';
import '../../theme/app_theme.dart';
import '../common/animated_button.dart' show ButtonHaptic;
import '../common/sticky_button.dart';
import '../common/sticky_note.dart';

/// Empty State למזווה — מוצג כאשר אין פריטים
class PantryEmptyState extends StatelessWidget {
  final bool isGroupMode;
  final String? groupName;
  final VoidCallback? onAddItem;
  final VoidCallback? onAddStarterItems;

  const PantryEmptyState({
    super.key,
    this.isGroupMode = false,
    this.groupName,
    this.onAddItem,
    this.onAddStarterItems,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final strings = AppStrings.pantry;

    // Theme-aware sticky colors
    final yellowColor = brand?.stickyYellow ?? kStickyYellow;
    final greenColor = brand?.stickyGreen ?? kStickyGreen;

    // 🎬 Stagger Delays — 5 קבוצות, 200ms בין כל קבוצה
    const d0 = Duration.zero;
    const d1 = Duration(milliseconds: 200);
    const d2 = Duration(milliseconds: 400);
    const d3 = Duration(milliseconds: 600);
    const d4 = Duration(milliseconds: 800);

    final Widget yellowNote = StickyNote(
      color: yellowColor,
      rotation: 0.01,
      animate: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: cs.primary, size: kIconSizeMedium),
              const Gap(kSpacingSmall),
              Text(
                strings.howToStartTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: kFontSizeMedium,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const Gap(kSpacingSmall),
          _buildTip(1, strings.howToStartStep1, cs),
          _buildTip(2, strings.howToStartStep2, cs),
          _buildTip(3, strings.howToStartStep3, cs),
          const Gap(kSpacingSmall),
          const Divider(),
          const Gap(kSpacingSmall),
          Text(
            strings.howToStartHint,
            style: TextStyle(
              fontSize: kFontSizeSmall,
              color: cs.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );

    final Widget greenNote = onAddStarterItems != null
        ? StickyNote(
            color: greenColor,
            rotation: -0.01,
            animate: false,
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, color: cs.primary, size: kIconSizeMedium),
                    const Gap(kSpacingSmall),
                    Expanded(
                      child: Text(
                        strings.starterItemsTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: kFontSizeMedium,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(kSpacingSmall),
                Text(
                  strings.starterItemsSubtitle,
                  style: TextStyle(
                    fontSize: kFontSizeSmall,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const Gap(kSpacingMedium),
                StickyButton(
                  color: yellowColor,
                  label: strings.addBasicsButton,
                  icon: Icons.check,
                  haptic: ButtonHaptic.light,
                  onPressed: onAddStarterItems,
                ),
              ],
            ),
          )
        : const SizedBox.shrink();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: RepaintBoundary(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: kSpacingLarge, vertical: kSpacingMedium),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Group 1 — אייקון ראשי
                Semantics(
                  label: strings.emptyLabel,
                  excludeSemantics: true,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                    child: Image.asset(
                      'assets/images/empty_pantry.webp',
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: d0)
                    .scale(
                      begin: const Offset(0.75, 0.75),
                      end: const Offset(1.0, 1.0),
                      duration: 500.ms,
                      delay: d0,
                      curve: Curves.easeOutBack,
                    ),

                const Gap(kSpacingLarge),

                // Group 2 — כותרת + תיאור
                Column(
                  children: [
                    Text(
                      strings.emptyMainTitle,
                      style: TextStyle(
                        fontSize: kFontSizeXLarge,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const Gap(kSpacingSmall),
                    Text(
                      isGroupMode ? strings.emptySubtitleGroup : strings.emptySubtitlePersonal,
                      style: TextStyle(
                        fontSize: kFontSizeMedium,
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 350.ms, delay: d1)
                    .slideY(begin: 0.06, end: 0, duration: 350.ms, delay: d1, curve: Curves.easeOut),

                const Gap(kSpacingMedium),

                // Group 3 — פתק "איך להתחיל?"
                yellowNote
                    .animate()
                    .fadeIn(duration: 350.ms, delay: d2)
                    .slideY(begin: 0.06, end: 0, duration: 350.ms, delay: d2, curve: Curves.easeOut),

                const Gap(kSpacingMedium),

                // Group 4 — פתק starter + badge
                Column(
                  children: [
                    if (onAddStarterItems != null) ...[
                      greenNote,
                      const Gap(kSpacingLarge),
                    ],
                    Center(child: _buildStatusBadge(context, cs, strings)),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 350.ms, delay: d3)
                    .slideY(begin: 0.06, end: 0, duration: 350.ms, delay: d3, curve: Curves.easeOut),

                const Gap(kSpacingMedium),

                // Group 5 — CTA ראשי
                if (onAddItem != null)
                  StickyButton(
                    color: greenColor,
                    label: strings.addFirstProduct,
                    icon: Icons.add,
                    haptic: ButtonHaptic.medium,
                    onPressed: onAddItem,
                  )
                      .animate()
                      .fadeIn(duration: 350.ms, delay: d4)
                      .slideY(begin: 0.06, end: 0, duration: 350.ms, delay: d4, curve: Curves.easeOut),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, ColorScheme cs, PantryStrings strings) {
    if (isGroupMode && groupName != null) {
      final badgeColor = StatusColors.getColor(StatusType.success, context);
      final badgeContainer = StatusColors.getContainer(StatusType.success, context);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
        decoration: BoxDecoration(
          color: badgeContainer,
          borderRadius: BorderRadius.circular(kBorderRadius),
          border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.home_outlined, color: badgeColor, size: kIconSizeSmallPlus),
            const Gap(kSpacingSmall),
            Text(
              strings.pantryBadgeGroup(groupName!),
              style: TextStyle(color: badgeColor, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(kBorderRadius),
        border: Border.all(color: cs.primary.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.kitchen_outlined, color: cs.primary, size: kIconSizeSmallPlus),
          const Gap(kSpacingSmall),
          Text(
            strings.pantryBadgePersonal,
            style: TextStyle(color: cs.primary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(int number, String text, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpacingTiny),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: kIconSizeSmallPlus,
            height: kIconSizeSmallPlus,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: kFontSizeTiny,
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
          ),
          const Gap(kSpacingSmall),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: kFontSizeSmall, color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
