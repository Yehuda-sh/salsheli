// 📄 lib/widgets/shopping/shopping_list_tags.dart
//
// תגי מידע לכרטיס רשימת קניות - סוג, שיתוף, פרטיות, דחיפות.
// עיצוב Glassmorphic: שקיפות עדינה שמאפשרת לרקע הגרדיאנט להשתקף.
//
// 🔗 Related: ShoppingListTile, ShoppingListUrgency

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../core/status_colors.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/shopping_list.dart';
import 'shopping_list_urgency.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🏷️ Glass Tag Wrapper - Glassmorphic container for all tags
// ═══════════════════════════════════════════════════════════════════════════

/// Container שקוף למחצה בסגנון זכוכית (Glassmorphic)
///
/// הרקע בשקיפות נמוכה מאפשר לגרדיאנט של הפתק להשתקף דרכו.
class _GlassTag extends StatelessWidget {
  final Color color;
  final Color? borderColor;
  final Widget child;

  const _GlassTag({
    required this.color,
    this.borderColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kSpacingSmall,
        vertical: kSpacingXTiny,
      ),
      decoration: BoxDecoration(
        // Glassmorphic: שקיפות נמוכה → הגרדיאנט של הפתק נראה מאחור
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        border: Border.all(
          color: (borderColor ?? color).withValues(alpha: 0.35),
          width: 0.5,
        ),
      ),
      child: child,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🏷️ List Type Tag
// ═══════════════════════════════════════════════════════════════════════════

/// תג סוג רשימה - אימוג'י + שם הסוג
///
/// משתמש ב-getters מהמודל: [ShoppingList.typeEmoji], [ShoppingList.stickyColor], [ShoppingList.typeName]
class ListTypeTag extends StatelessWidget {
  final ShoppingList list;

  const ListTypeTag({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _GlassTag(
      color: list.stickyColor,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(list.typeEmoji, style: const TextStyle(fontSize: 14)),
          const Gap(kSpacingXTiny),
          Text(
            list.typeName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🏷️ Shared Tag - "משותפת"
// ═══════════════════════════════════════════════════════════════════════════

/// תג "משותפת" - מוצג כשהרשימה משותפת עם אחרים
class SharedTag extends StatelessWidget {
  const SharedTag({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _GlassTag(
      color: theme.colorScheme.secondaryContainer,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.group,
            size: kIconSizeSmall,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const Gap(kSpacingXTiny),
          Text(
            AppStrings.shopping.sharedLabel,
            style: TextStyle(
              color: theme.colorScheme.onSecondaryContainer,
              fontSize: kFontSizeTiny,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔒 Privacy Tag - "אישית"
// ═══════════════════════════════════════════════════════════════════════════

/// תג "אישית" - מוצג רק לרשימות פרטיות שלא משותפות
class PrivacyTag extends StatelessWidget {
  const PrivacyTag({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _GlassTag(
      color: theme.colorScheme.tertiaryContainer,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person,
            size: kIconSizeSmall,
            color: theme.colorScheme.onTertiaryContainer,
          ),
          const Gap(kSpacingXTiny),
          Text(
            'אישית',
            style: TextStyle(
              color: theme.colorScheme.onTertiaryContainer,
              fontSize: kFontSizeTiny,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ⏰ Urgency Tag
// ═══════════════════════════════════════════════════════════════════════════

/// תג דחיפות - מציג סטטוס לפי תאריך יעד
///
/// מחזיר null אם אין targetDate (שימוש עם `if (UrgencyTag(...) case final tag?) tag`)
class UrgencyTag extends StatelessWidget {
  final ShoppingList list;

  const UrgencyTag({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    final urgencyData = ShoppingListUrgency.fromList(list);
    if (urgencyData == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final statusColor = StatusColors.getColor(urgencyData.status, context);
    final overlayColor = StatusColors.getContainer(urgencyData.status, context);

    return _GlassTag(
      color: overlayColor,
      borderColor: statusColor,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(urgencyData.icon, size: kIconSizeSmall, color: statusColor),
          const Gap(kSpacingXTiny),
          Text(
            urgencyData.text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: kFontSizeTiny,
            ),
          ),
        ],
      ),
    );
  }
}
