// 📄 lib/screens/home/dashboard/widgets/onboarding_tips_card.dart
//
// 🎯 כרטיסי הדרכה למשתמשים חדשים — מופיעים כשהמסך ריק.
// כל כרטיס נעלם אוטומטית כשהמשתמש ביצע את הפעולה.
//
// 🔗 Related: HomeDashboardScreen, InventoryProvider, UserContext

import 'dart:async';

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

/// כרטיסי הדרכה — "התחל כאן" למשתמש חדש
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
    // בדיקה בסיסית אם יש חברי בית (אם שם הבית מכיל "של" — סביר שזה solo)
    final isSoloHousehold = householdName == null ||
        householdName.contains('של') ||
        householdName.contains('Home');

    // בנה רשימת טיפים שעדיין רלוונטיים
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

    // אם אין טיפים — לא מציגים
    if (tips.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        ...tips.asMap().entries.map((entry) {
          final index = entry.key;
          final tip = entry.value;
          return _TipTile(tip: tip)
              .animate()
              .fadeIn(duration: 400.ms, delay: (100 * index).ms)
              .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: (100 * index).ms);
        }),
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

class _TipTile extends StatelessWidget {
  final _TipData tip;
  const _TipTile({required this.tip});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      color: tip.color.withValues(alpha: 0.08),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
        side: BorderSide(color: tip.color.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: tip.onAction,
        borderRadius: BorderRadius.circular(kBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(kSpacingSmallPlus),
          child: Row(
            children: [
              // אייקון בעיגול צבעוני
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tip.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(tip.icon, color: tip.color, size: kIconSizeSmallPlus),
              ),
              const SizedBox(width: kSpacingSmallPlus),

              // טקסט
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip.title,
                      style: TextStyle(
                        fontSize: kFontSizeSmall,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tip.subtitle,
                      style: TextStyle(
                        fontSize: kFontSizeTiny,
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: kSpacingSmall),

              // כפתור פעולה
              Container(
                padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingTiny),
                decoration: BoxDecoration(
                  color: tip.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                ),
                child: Text(
                  tip.actionLabel,
                  style: TextStyle(
                    fontSize: kFontSizeTiny,
                    fontWeight: FontWeight.bold,
                    color: tip.color,
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
