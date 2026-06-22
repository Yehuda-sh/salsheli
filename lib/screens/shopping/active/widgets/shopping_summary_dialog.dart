// lib/screens/shopping/active/widgets/shopping_summary_dialog.dart — Shopping summary dialog — finish shopping confirmation with stats and store picker

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/ui_constants.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/common/sticky_button.dart';


enum ShoppingSummaryResult {
  cancel, // חזור לרשימה
  // 🔄 פאזה 6: סיים. הרשימה החיה נשארת — הנקנים יוצאים (עלו למזווה + קבלה),
  // הלא-נקנים נשארים. אין יותר "גלגול/השלמה".
  finish,
}

/// תוצאת דיאלוג סיכום — כוללת גם שם חנות אופציונלי
class ShoppingSummaryOutcome {
  final ShoppingSummaryResult result;
  final String? storeName;
  const ShoppingSummaryOutcome(this.result, {this.storeName});
}

// ========================================
// Dialog: סיכום קנייה
// ========================================

class ShoppingSummaryDialog extends StatefulWidget {
  final String listName;
  final int total;
  final int purchased;
  final int outOfStock;
  final int notNeeded;
  final int pending;
  /// חנויות מועדפות/מוכרות להצגה כצ'יפים
  final List<String> knownStores;

  const ShoppingSummaryDialog({super.key, 
    required this.listName,
    required this.total,
    required this.purchased,
    required this.outOfStock,
    required this.notNeeded,
    required this.pending,
    this.knownStores = const [],
  });

  @override
  State<ShoppingSummaryDialog> createState() => _ShoppingSummaryDialogState();
}

class _ShoppingSummaryDialogState extends State<ShoppingSummaryDialog> {
  // שם חנות שהמשתמש בחר/הקליד
  String? _selectedStoreName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();

    // מסך סיכום רגיל
    return AlertDialog(
      title: Column(
        children: [
          // 🛒 עגלה תלת-ממדית — hero visual
          Image.asset(
            'assets/images/shopping_cart_3d.webp',
            height: 80,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            widget.purchased > 0
                ? AppStrings.shopping.summarySuccess
                : AppStrings.shopping.summaryTitle,
            style: TextStyle(fontSize: kFontSizeLarge + 2, fontWeight: FontWeight.bold, color: cs.onSurface),
            textAlign: TextAlign.center,
          ),
          Text(
            widget.listName,
            style: TextStyle(fontSize: kFontSizeSmall, color: cs.primary, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Divider(height: kSpacingLarge),

            // ✅ קנוי
            SummaryRow(
              icon: Icons.check_circle,
              label: AppStrings.shopping.activePurchased,
              value: AppStrings.shopping.summaryPurchased(widget.purchased, widget.total),
              color: brand?.stickyGreen ?? kStickyGreen,
            ),

            // 🚫 לא צריך
            if (widget.notNeeded > 0)
              SummaryRow(icon: Icons.block, label: AppStrings.shopping.activeNotNeeded, value: '${widget.notNeeded}', color: cs.onSurfaceVariant),

            // ❌ אזלו
            if (widget.outOfStock > 0)
              SummaryRow(
                icon: Icons.remove_shopping_cart,
                label: AppStrings.shopping.summaryOutOfStock,
                value: '${widget.outOfStock}',
                color: cs.error,
              ),

            // ⏸️ לא סומנו
            if (widget.pending > 0)
              SummaryRow(
                icon: Icons.radio_button_unchecked,
                label: AppStrings.shopping.summaryNotMarked,
                value: '${widget.pending}',
                color: brand?.stickyOrange ?? kStickyOrange,
              ),

            // 🏪 מאיפה קנית? (אופציונלי)
            if (widget.purchased > 0) ...[
              const Divider(height: kSpacingLarge),
              Row(
                children: [
                  Icon(Icons.store_outlined, size: 18, color: cs.onSurfaceVariant),
                  const SizedBox(width: kSpacingTiny),
                  Text(
                    AppStrings.shopping.storeQuestion,
                    style: TextStyle(
                      fontSize: kFontSizeMedium,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: kSpacingXTiny),
                  Text(
                    AppStrings.common.optional,
                    style: TextStyle(
                      fontSize: kFontSizeTiny,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: kSpacingSmall),
              // 🏪 פתקיות חנויות מוכרות
              if (widget.knownStores.isNotEmpty)
                Wrap(
                  spacing: kSpacingSmall,
                  runSpacing: kSpacingSmall,
                  children: widget.knownStores.asMap().entries.map((entry) {
                    final store = entry.value;
                    final isSelected = _selectedStoreName == store;
                    // צבעים מתחלפים לפתקיות
                    final colors = [brand?.stickyYellow ?? kStickyYellow, brand?.stickyGreen ?? kStickyGreen, brand?.stickyCyan ?? kStickyCyan, brand?.stickyPink ?? kStickyPink, brand?.stickyOrange ?? kStickyOrange, brand?.stickyPurple ?? kStickyPurple];
                    final noteColor = colors[entry.key % colors.length];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedStoreName = isSelected ? null : store;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? noteColor : noteColor.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                          border: isSelected
                              ? Border.all(color: cs.primary, width: 2)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: cs.shadow.withValues(alpha: isSelected ? 0.15 : 0.06),
                              blurRadius: isSelected ? 6 : 3,
                              offset: const Offset(1, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(start: 4),
                                child: Icon(Icons.check_circle, size: 14, color: cs.primary),
                              ),
                            Text(
                              store,
                              style: TextStyle(
                                fontSize: kFontSizeSmall,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: cs.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              if (widget.knownStores.isNotEmpty)
                const SizedBox(height: kSpacingSmall),
              // ✏️ שדה טקסט לחנות אחרת
              SizedBox(
                height: 42,
                child: TextField(
                  style: const TextStyle(fontSize: kFontSizeSmall),
                  decoration: InputDecoration(
                    hintText: AppStrings.shopping.otherStoreHint,
                    hintStyle: TextStyle(fontSize: kFontSizeSmall, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(kBorderRadius),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(kBorderRadius),
                      borderSide: BorderSide(color: cs.primary),
                    ),
                    prefixIcon: Icon(Icons.edit_outlined, size: kIconSizeSmall, color: cs.onSurfaceVariant),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedStoreName = value.trim().isEmpty ? null : value.trim();
                    });
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        Semantics(
          label: AppStrings.shopping.backToListSemantics,
          button: true,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context, const ShoppingSummaryOutcome(ShoppingSummaryResult.cancel));
            },
            child: Text(AppStrings.shopping.summaryBack),
          ),
        ),
        Semantics(
          label: AppStrings.shopping.finishAndSaveSemantics,
          button: true,
          child: StickyButton(
            label: AppStrings.shopping.summaryFinishShopping,
            icon: Icons.check,
            onPressed: () {
              unawaited(HapticFeedback.mediumImpact());
              // 🔄 פאזה 6: סיום אחיד — הלא-נקנים פשוט נשארים ברשימה החיה.
              Navigator.pop(context, ShoppingSummaryOutcome(ShoppingSummaryResult.finish, storeName: _selectedStoreName));
            },
            color: brand?.stickyGreen ?? kStickyGreen,
            textColor: cs.onPrimary,
            height: 44,
          ),
        ),
      ],
    );
  }

}

// 🔄 פאזה 6: PendingOptionTile + _buildPendingOptionsDialog הוסרו —
// אין יותר אפשרויות גלגול/מחיקה בסיום קנייה.

// ========================================
// Widget: אווטר קונה פעיל עם הילה פועמת
// ========================================

class ShopperAvatar extends StatelessWidget {
  final String initial;
  final bool isStarter;
  final Color accentColor;

  const ShopperAvatar({super.key, 
    required this.initial,
    required this.isStarter,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bgColor = isStarter ? accentColor : cs.primaryContainer;
    final fgColor = isStarter ? cs.onPrimary : cs.onPrimaryContainer;

    return Container(
      width: kIconSizeMedium,
      height: kIconSizeMedium,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: cs.surface, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.4),
            blurRadius: 4,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: kFontSizeSmall,
            fontWeight: FontWeight.bold,
            color: fgColor,
          ),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 1.0, end: 1.1, duration: 1500.ms, curve: Curves.easeInOut);
  }
}

// ========================================
// Widget: שורת סיכום
// ========================================

class SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const SummaryRow({super.key, required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpacingSmall),
      child: Row(
        children: [
          Icon(icon, color: color, size: kIconSizeMedium + 2),
          const SizedBox(width: kSpacingSmallPlus),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: kFontSizeBody)),
          ),
          Text(
            value,
            style: TextStyle(fontSize: kFontSizeBody, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
