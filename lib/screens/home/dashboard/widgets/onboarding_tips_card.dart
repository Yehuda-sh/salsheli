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
    final isSoloHousehold = householdName == null ||
        householdName.contains('של') ||
        householdName.contains('Home');

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

    // קרוסלה אופקית של Sticky Notes — כמו הצעות המזווה
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            itemCount: tips.length,
            itemBuilder: (context, index) {
              final rotation = (index.isEven ? 1 : -1) * 0.015;
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : kSpacingSmall,
                ),
                child: _StickyNoteTip(tip: tips[index], rotation: rotation)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: (100 * index).ms)
                    .slideY(begin: 0.15, end: 0, duration: 400.ms, delay: (100 * index).ms),
              );
            },
          ),
        ),
      ],
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
          width: 160,
          padding: const EdgeInsets.all(kSpacingSmallPlus),
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
                color: shadowColor.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(2, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // אייקון
              Container(
                width: kIconSizeLarge,
                height: kIconSizeLarge,
                decoration: BoxDecoration(
                  color: cs.scrim.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(tip.icon, size: kIconSizeSmallPlus, color: cs.onSurface.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: kSpacingSmall),

              // כותרת
              Text(
                tip.title,
                style: TextStyle(
                  fontSize: kFontSizeSmall,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: kSpacingXTiny),

              // תיאור
              Expanded(
                child: Text(
                  tip.subtitle,
                  style: TextStyle(
                    fontSize: kFontSizeTiny,
                    color: cs.onSurface.withValues(alpha: 0.6),
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // כפתור
              Container(
                padding: const EdgeInsets.symmetric(horizontal: kSpacingSmallPlus, vertical: kSpacingXTiny),
                decoration: BoxDecoration(
                  color: cs.scrim.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_forward, size: kFontSizeSmall, color: cs.onSurface),
                    const SizedBox(width: kSpacingXTiny),
                    Text(
                      tip.actionLabel,
                      style: TextStyle(
                        fontSize: kFontSizeTiny,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
