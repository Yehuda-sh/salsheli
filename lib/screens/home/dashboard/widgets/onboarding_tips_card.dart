// 📄 lib/screens/home/dashboard/widgets/onboarding_tips_card.dart
//
// 🎯 כרטיסי הדרכה למשתמשים חדשים — Sticky Notes צבעוניים.
// נעלמים אוטומטית כשהמשתמש מתקדם.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/ui_constants.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../providers/inventory_provider.dart';
import '../../../../providers/shopping_lists_provider.dart';
import '../../../../providers/user_context.dart';
import '../../../../theme/app_theme.dart';

class OnboardingTipsCard extends StatelessWidget {
  final VoidCallback? onNavigateToPantry;
  final VoidCallback? onNavigateToCreateList;
  final VoidCallback? onNavigateToInvite;

  const OnboardingTipsCard({
    super.key,
    this.onNavigateToPantry,
    this.onNavigateToCreateList,
    this.onNavigateToInvite,
  });

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContext>();
    final listsProvider = context.watch<ShoppingListsProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();
    final brand = Theme.of(context).extension<AppBrand>();

    if (!userContext.isLoggedIn) return const SizedBox.shrink();

    final listCount = listsProvider.lists.length;
    final pantryCount = inventoryProvider.items.length;
    final householdName = userContext.user?.householdName;
    // isSolo field — fallback to heuristic for existing users without the field
    final isSoloHousehold = userContext.user?.isSolo ??
        (householdName == null ||
         householdName.contains('של') ||
         householdName.contains('Home'));

    final tips = <_TipData>[];

    if (pantryCount < 3) {
      tips.add(_TipData(
        icon: Icons.inventory_2_outlined,
        color: brand?.stickyYellow ?? kStickyYellow,
        title: AppStrings.onboardingTips.fillPantryTitle,
        subtitle: AppStrings.onboardingTips.fillPantrySubtitle,
        actionLabel: AppStrings.onboardingTips.fillPantryAction,
        onAction: () {
          unawaited(HapticFeedback.lightImpact());
          onNavigateToPantry?.call();
        },
      ));
    }

    if (isSoloHousehold) {
      tips.add(_TipData(
        icon: Icons.people_outline,
        color: brand?.stickyCyan ?? kStickyCyan,
        title: AppStrings.onboardingTips.inviteFamilyTitle,
        subtitle: AppStrings.onboardingTips.inviteFamilySubtitle,
        actionLabel: AppStrings.onboardingTips.inviteFamilyAction,
        onAction: () {
          unawaited(HapticFeedback.lightImpact());
          onNavigateToInvite?.call();
        },
      ));
    }

    if (listCount < 3) {
      tips.add(_TipData(
        icon: Icons.playlist_add,
        color: brand?.stickyGreen ?? kStickyGreen,
        title: AppStrings.onboardingTips.createListsTitle,
        subtitle: AppStrings.onboardingTips.createListsSubtitle,
        actionLabel: AppStrings.onboardingTips.createListsAction,
        onAction: () {
          unawaited(HapticFeedback.lightImpact());
          onNavigateToCreateList?.call();
        },
      ));
    }

    if (tips.isEmpty) return const SizedBox.shrink();

    // Sticky Notes אנכיים — כל כרטיס שורה מלאה
    return Column(
      children: tips.asMap().entries.map((entry) {
        final index = entry.key;
        final tip = entry.value;
        final rotation = (index.isEven ? 1 : -1) * 0.01;
        return Padding(
          padding: const EdgeInsets.only(bottom: kSpacingSmall),
          child: _StickyNoteTip(tip: tip, rotation: rotation)
              .animate()
              .fadeIn(duration: 400.ms, delay: (100 * index).ms)
              .slideX(begin: 0.1, end: 0, duration: 400.ms, delay: (100 * index).ms),
        );
      }).toList(),
    );
  }
}

class _TipData {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _TipData({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });
}

/// Sticky Note tip — עיצוב פתקית צבעונית עם צל וסיבוב
class _StickyNoteTip extends StatelessWidget {
  final _TipData tip;
  final double rotation;

  const _StickyNoteTip({required this.tip, required this.rotation});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final shadowColor = Theme.of(context).shadowColor;

    return Transform.rotate(
      angle: rotation,
      child: GestureDetector(
        onTap: tip.onAction,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmallPlus),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                tip.color,
                Color.lerp(tip.color, shadowColor, 0.04)!,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withValues(alpha: 0.12),
                blurRadius: 4,
                offset: const Offset(1, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // אייקון בעיגול
              Container(
                width: kIconSizeXLarge,
                height: kIconSizeXLarge,
                decoration: BoxDecoration(
                  color: cs.scrim.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(tip.icon, size: kIconSizeMedium, color: cs.onSurface.withValues(alpha: 0.7)),
              ),
              const SizedBox(width: kSpacingMedium),

              // טקסט
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tip.title,
                      style: TextStyle(
                        fontSize: kFontSizeBody,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: kSpacingXTiny),
                    Text(
                      tip.subtitle,
                      style: TextStyle(
                        fontSize: kFontSizeSmall,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: kSpacingSmall),

              // כפתור
              Container(
                padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
                decoration: BoxDecoration(
                  color: cs.scrim.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                ),
                child: Text(
                  tip.actionLabel,
                  style: TextStyle(
                    fontSize: kFontSizeSmall,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
