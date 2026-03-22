// 📄 lib/widgets/shopping/shopping_list_tile.dart
//
// כרטיס רשימת קניות Premium - פתק ממו יוקרתי עם משוב תחושתי.
//
// Features:
//   - Paper Gradient: גרדיאנט עדין שיוצר עומק של נייר
//   - Perforation Line: קו פרפורציה לפני כפתור הפעולה
//   - Glassmorphic Tags: תגים שקופים למחצה
//   - Staggered Entrance: אנימציית "נחיתה" מדורגת (flutter_animate)
//   - Haptic Signature: רטט מובחן לכל סוג אינטראקציה
//   - Organic Progress: פס התקדמות מעוגל עם שינוי צבע
//   - RepaintBoundary + Gap: אופטימיזציה וריווח סמנטי
//
// 🔗 Related: ShoppingList, ShoppingListTags, PerforationPainter

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../core/status_colors.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/shopping_list.dart';
import '../common/painters/perforation_painter.dart';
import '../common/tappable_card.dart';
import 'shopping_list_tags.dart';

/// כרטיס רשימת קניות Premium
///
/// מציג שם, פריטים, התקדמות, תגים וכפתור פעולה.
/// עיצוב פתק ממו יוקרתי עם גרדיאנט, פרפורציה ואנימציות.
///
/// Parameters:
/// - [list]: מודל רשימת הקניות
/// - [index]: אינדקס ברשימה לאנימציית כניסה מדורגת (ברירת מחדל: 0)
/// - [animate]: האם להפעיל אנימציית כניסה (ברירת מחדל: true)
/// - [onTap]: לחיצה על הכרטיס (ניווט לרשימה)
/// - [onDelete]: מחיקת הרשימה (async)
/// - [onRestore]: שחזור רשימה שנמחקה (Undo)
/// - [onStartShopping]: התחלת קנייה
/// - [onEdit]: עריכת הרשימה
class ShoppingListTile extends StatelessWidget {
  final ShoppingList list;
  final int index;
  final bool animate;
  final VoidCallback? onTap;
  final Future<void> Function()? onDelete;
  final Future<void> Function(ShoppingList list)? onRestore;
  final VoidCallback? onStartShopping;
  final VoidCallback? onEdit;

  const ShoppingListTile({
    super.key,
    required this.list,
    this.index = 0,
    this.animate = true,
    this.onTap,
    this.onDelete,
    this.onRestore,
    this.onStartShopping,
    this.onEdit,
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔘 Bottom Action Button
  // ═══════════════════════════════════════════════════════════════════════════

  /// כפתור פעולה בתחתית הכרטיס (מתחת לקו הפרפורציה)
  Widget _buildBottomActionButton(BuildContext context, ThemeData theme) {
    final hasItems = list.items.isNotEmpty;
    final (icon, label) = _getActionButtonConfig(hasItems);
    final onPressed = hasItems ? onStartShopping : onTap;

    return Column(
      children: [
        // ✂️ Perforation line - "קו תלישה"
        SizedBox(
          height: 1,
          width: double.infinity,
          child: CustomPaint(
            painter: PerforationPainter(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
        ),
        TappableCard(
              tooltip: label,
              semanticLabel: label,
              animateElevation: false,
              onTap: onPressed,
              haptic: ButtonHaptic.medium, // CTA haptic
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(kBorderRadius),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: kSpacingMedium,
                  vertical: kSpacingSmall,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: theme.colorScheme.primary, size: kIconSizeMedium),
                    const Gap(kSpacingSmall),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: kFontSizeBody,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  /// מחזיר אייקון וטקסט לכפתור הפעולה לפי סוג הרשימה
  (IconData, String) _getActionButtonConfig(bool hasItems) {
    if (!hasItems) {
      return (Icons.add_circle_outline, AppStrings.shopping.addProductsToStart);
    }

    if (list.type == ShoppingList.typeEvent &&
        list.eventMode == ShoppingList.eventModeWhoBrings) {
      return (Icons.people, AppStrings.shopping.whoBringsWhat);
    }

    if (list.type == ShoppingList.typeEvent &&
        list.eventMode == ShoppingList.eventModeTasks) {
      return (Icons.checklist, AppStrings.shopping.checklist);
    }

    return (Icons.shopping_cart_checkout, AppStrings.shopping.startShoppingButton);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📊 Organic Progress Indicator
  // ═══════════════════════════════════════════════════════════════════════════

  /// פס התקדמות אורגני - קצוות מעוגלים, 6px, ירוק ב-100%
  Widget _buildOrganicProgress(BuildContext context, ThemeData theme) {
    if (list.items.isEmpty) return const SizedBox.shrink();
    final progress = list.items.where((item) => item.isChecked).length / list.items.length;
    final isComplete = progress >= 1.0;

    // ירוק ב-100% (success), אחרת primary
    final progressColor = isComplete
        ? StatusColors.getColor(StatusType.success, context)
        : theme.colorScheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(kBorderRadiusSmall / 2),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: kProgressIndicatorHeight,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        color: progressColor,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🗑️ Delete Confirmation Dialog
  // ═══════════════════════════════════════════════════════════════════════════

  void _showDeleteConfirmation(BuildContext context) {
    // 📳 Haptic: heavyImpact למחיקה
    unawaited(HapticFeedback.heavyImpact());

    final messenger = ScaffoldMessenger.of(context);
    final successColor = StatusColors.getColor(StatusType.success, context);
    final errorColor = StatusColors.getColor(StatusType.error, context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.shopping.deleteListTitle),
        content: Text(AppStrings.shopping.deleteListMessage(list.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppStrings.common.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              final deletedList = list;

              try {
                await onDelete?.call();

                messenger.showSnackBar(
                  SnackBar(
                    content: Text(AppStrings.shopping.listDeleted(deletedList.name)),
                    backgroundColor: successColor,
                    action: SnackBarAction(
                      label: AppStrings.shopping.undoButton,
                      onPressed: () {
                        onRestore?.call(deletedList);
                      },
                    ),
                    duration: const Duration(seconds: 5),
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(AppStrings.shopping.deleteError),
                    backgroundColor: errorColor,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: errorColor),
            child: Text(AppStrings.shopping.deleteButton),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🏗️ Build
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatted = DateFormat('dd/MM/yyyy – HH:mm').format(list.updatedDate);
    final checkedCount = list.items.where((item) => item.isChecked).length;
    final totalCount = list.items.length;
    final stickyColor = list.stickyColor;

    Widget card = Semantics(
      label: AppStrings.shopping.listTileSemantics(list.name, totalCount, checkedCount),
      button: true,
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(kBorderRadius),
        // 🎨 Material color transparent — gradient handles the fill
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            // 🌈 Paper Gradient: עומק של נייר שתופס אור
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                stickyColor.withValues(alpha: 0.4),
                stickyColor.withValues(alpha: 0.22),
              ],
            ),
            borderRadius: BorderRadius.circular(kBorderRadius),
            border: Border.all(
              color: stickyColor.withValues(alpha: 0.5),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🎨 Colored side strip — לפי סוג רשימה
              Container(
                width: kSpacingTiny,
                decoration: BoxDecoration(
                  color: stickyColor,
                  borderRadius: const BorderRadiusDirectional.horizontal(
                    end: Radius.circular(kBorderRadius),
                  ).resolve(Directionality.of(context)),
                ),
              ),
              // 📋 Card content
              Expanded(
                child: Column(
            children: [
              // 📋 Card content (tappable area)
              InkWell(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(kBorderRadius),
                ),
                onTap: onTap != null
                    ? () {
                        // 📳 Haptic: selectionClick לניווט
                        unawaited(HapticFeedback.selectionClick());
                        onTap!();
                      }
                    : null,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: kSpacingMedium,
                    vertical: kSpacingSmallPlus,
                  ),
                  leading: Hero(
                    tag: 'list_hero_${list.id}',
                    child: Container(
                      width: kIconSizeLarge + kSpacingXTiny,
                      height: kIconSizeLarge + kSpacingXTiny,
                      decoration: BoxDecoration(
                        color: stickyColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                      ),
                      child: Center(
                        child: Text(list.typeEmoji, style: const TextStyle(fontSize: kFontSizeTitle)),
                      ),
                    ),
                  ),
                  title: Text(
                    list.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(kSpacingTiny),
                      // 🏷️ Glassmorphic tags
                      Wrap(
                        spacing: kSpacingSmall,
                        runSpacing: kSpacingTiny,
                        children: [
                          ListTypeTag(list: list),
                          UrgencyTag(list: list),
                          if (list.isShared)
                            const SharedTag(),
                          if (!list.isShared && list.isPrivate)
                            const PrivacyTag(),
                          if (list.isBeingShopped)
                            _LiveBadge(color: theme.colorScheme.error),
                        ],
                      ),
                      const Gap(kSpacingSmall),
                      Text(
                        AppStrings.shopping.itemsAndDate(list.items.length, dateFormatted),
                        style: theme.textTheme.bodySmall,
                      ),
                      const Gap(kSpacingTiny),
                      // 📊 Organic progress indicator
                      if (list.items.isNotEmpty)
                        _buildOrganicProgress(context, theme),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    tooltip: AppStrings.shopping.moreOptionsTooltip,
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'delete':
                          _showDeleteConfirmation(context);
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      final deleteColor = StatusColors.getColor(StatusType.error, context);
                      return [
                        PopupMenuItem(
                          value: 'edit',
                          child: Semantics(
                            label: AppStrings.shopping.editListButton,
                            child: Row(
                              children: [
                                const Icon(Icons.edit, size: kIconSizeMedium),
                                const Gap(kSpacingSmall),
                                Text(AppStrings.shopping.editListButton),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Semantics(
                            label: AppStrings.shopping.deleteListButton,
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: kIconSizeMedium, color: deleteColor),
                                const Gap(kSpacingSmall),
                                Text(
                                  AppStrings.shopping.deleteListButton,
                                  style: TextStyle(color: deleteColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ];
                    },
                  ),
                ),
              ),

              // ✂️ Action button with perforation — active lists only
              if (list.status == ShoppingList.statusActive)
                _buildBottomActionButton(context, theme),
            ],
          ),
              ),
            ],
          ),
          ),
        ),
      ),
    );

    // 🎬 Staggered Entrance: "נחיתה" מדורגת
    if (animate) {
      final delay = (index * 50).ms;
      card = card
          .animate()
          .fadeIn(duration: 400.ms, delay: delay)
          .slideY(
            begin: 0.08,
            end: 0,
            curve: Curves.easeOutBack,
            delay: delay,
          )
          .scale(
            begin: const Offset(0.96, 0.96),
            end: const Offset(1.0, 1.0),
            delay: delay,
          );
    }

    // 🎨 RepaintBoundary isolates card animations from scroll repaints
    return RepaintBoundary(child: card);
  }
}

/// 🔴 LIVE badge — pulsing dot + text for active shopping
class _LiveBadge extends StatefulWidget {
  final Color color;
  const _LiveBadge({required this.color});

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: 2),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.1 + _pulse.value * 0.08),
            borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            border: Border.all(color: widget.color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.6 + _pulse.value * 0.4),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: kSpacingXTiny),
              Text(
                'LIVE',
                style: TextStyle(
                  fontSize: kFontSizeTiny,
                  fontWeight: FontWeight.w800,
                  color: widget.color,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
