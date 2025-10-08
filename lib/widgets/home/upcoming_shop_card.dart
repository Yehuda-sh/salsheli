// 📄 File: lib/widgets/home/upcoming_shop_card.dart
//
// ✅ עדכונים (08/10/2025):
// 1. Progress bar 0% → סטטוס טקסטואלי "טרם התחלת"
// 2. כפתור "התחל קנייה" בולט יותר (gradient + elevation)
// 3. תגי אירוע משופרים (אייקון + צבעים)
// 4. Visual hierarchy משופר

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shopping_list.dart';
import '../../providers/shopping_lists_provider.dart';
import '../create_list_dialog.dart';
import '../common/dashboard_card.dart';
import '../../core/ui_constants.dart';
import '../../theme/app_theme.dart';

class UpcomingShopCard extends StatelessWidget {
  final ShoppingList? list;

  const UpcomingShopCard({super.key, this.list});

  void _showCreateListDialog(BuildContext context) {
    final provider = context.read<ShoppingListsProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) => CreateListDialog(
        onCreateList: (listData) async {
          Navigator.of(dialogContext).pop();

          final name = listData['name'] as String?;
          final type = listData['type'] as String? ?? 'super';
          final budget = listData['budget'] as double?;
          final eventDate = listData['eventDate'] as DateTime?;

          if (name != null && name.trim().isNotEmpty) {
            await provider.createList(
              name: name, 
              type: type, 
              budget: budget,
              eventDate: eventDate,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (list == null) {
      return _EmptyUpcomingCard(
        onCreateList: () => _showCreateListDialog(context),
      );
    }

    return DashboardCard(
      title: "הקנייה הקרובה",
      icon: Icons.shopping_cart,
      elevation: 3, // ← elevation גבוה יותר
      onTap: () {
        Navigator.pushNamed(context, '/populate-list', arguments: list);
      },
      child: _ListSummary(list: list!),
    );
  }
}

class _EmptyUpcomingCard extends StatelessWidget {
  final VoidCallback onCreateList;

  const _EmptyUpcomingCard({required this.onCreateList});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return DashboardCard(
      title: "הקנייה הקרובה",
      icon: Icons.shopping_cart_outlined,
      elevation: 2,
      child: Column(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 48,
            color: cs.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: kBorderRadius),
          Text(
            "אין רשימה פעילה כרגע",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: kSpacingMedium),
          FilledButton.icon(
            onPressed: onCreateList,
            icon: const Icon(Icons.add),
            label: const Text("צור רשימה חדשה"),
          ),
        ],
      ),
    );
  }
}

class _ListSummary extends StatelessWidget {
  final ShoppingList list;

  const _ListSummary({required this.list});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;
    
    final itemsCount = list.items.length;
    final checkedCount = list.items.where((item) => item.isChecked).length;
    final progress = itemsCount > 0 ? checkedCount / itemsCount : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // שם הרשימה + כפתור עריכה
        Row(
          children: [
            Expanded(
              child: Text(
                list.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: kIconSizeSmall),
              tooltip: 'ערוך רשימה',
              padding: const EdgeInsets.all(kSpacingSmall),
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/populate-list',
                  arguments: list,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: kSpacingSmall),

        // תגים: סוג + תקציב + תאריך אירוע
        Wrap(
          spacing: kSpacingSmall,
          runSpacing: kSpacingSmall,
          children: [
            _buildTypeBadge(context, list.type),
            if (list.budget != null) _buildBudgetChip(context, list.budget!),
            if (list.eventDate != null) _buildEventDateChip(context, list.eventDate!),
          ],
        ),
        const SizedBox(height: kSpacingMedium),

        // 🆕 התקדמות - עם טיפול ב-0%
        if (progress == 0.0) ...[
          // ✅ סטטוס טקסטואלי כשאין התקדמות
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: kBorderRadius,
              vertical: kSpacingSmall,
            ),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
              border: Border.all(
                color: cs.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hourglass_empty,
                  size: kIconSizeSmall,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: kSpacingSmall),
                Text(
                  'טרם התחלת',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Progress bar רגיל
          LinearProgressIndicator(
            value: progress,
            backgroundColor: cs.surfaceContainerHighest,
            color: accent,
            minHeight: kSpacingSmall,
            borderRadius: BorderRadius.circular(kBorderWidthThick),
          ),
        ],
        const SizedBox(height: kSpacingSmall),

        // מידע נוסף
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$checkedCount מתוך $itemsCount פריטים",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            if (progress > 0)
              Text(
                "${(progress * 100).toInt()}%",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
          ],
        ),
        const SizedBox(height: kSpacingMedium),

        // 🆕 כפתור "התחל קנייה" בולט יותר
        SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent,
                  accent.withValues(alpha: 0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(kBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/active-shopping',
                    arguments: list,
                  );
                },
                borderRadius: BorderRadius.circular(kBorderRadius),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: kSpacingMedium - 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_cart,
                        size: kIconSizeSmall,
                        color: Colors.white,
                      ),
                      const SizedBox(width: kSpacingSmall),
                      Text(
                        'התחל קנייה',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeBadge(BuildContext context, String type) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final typeLabels = {
      'super': 'סופר',
      'pharmacy': 'בית מרקחת',
      'hardware': 'חומרי בניין',
      'toys': 'צעצועים',
      'books': 'ספרים',
      'sports': 'ספורט',
      'homeDecor': 'קישוטי בית',
      'automotive': 'רכב',
      'baby': 'תינוקות',
      'birthday': 'יום הולדת',
      'wedding': 'חתונה',
      'holiday': 'חג',
      'picnic': 'פיקניק',
      'party': 'מסיבה',
      'camping': 'קמפינג',
      'other': 'אחר',
    };

    final typeIcons = {
      'super': Icons.shopping_cart,
      'pharmacy': Icons.local_pharmacy,
      'hardware': Icons.hardware,
      'toys': Icons.toys,
      'books': Icons.menu_book,
      'sports': Icons.sports_basketball,
      'homeDecor': Icons.chair,
      'automotive': Icons.directions_car,
      'baby': Icons.child_care,
      'birthday': Icons.cake,
      'wedding': Icons.favorite,
      'holiday': Icons.celebration,
      'picnic': Icons.park,
      'party': Icons.party_mode,
      'camping': Icons.nature_people,
      'other': Icons.more_horiz,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kSpacingSmallPlus - 2,
        vertical: kBorderWidthThick + 2,
      ),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            typeIcons[type] ?? Icons.list,
            size: kFontSizeSmall,
            color: cs.onPrimaryContainer,
          ),
          const SizedBox(width: kBorderWidthThick),
          Text(
            typeLabels[type] ?? type,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetChip(BuildContext context, double budget) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kSpacingSmallPlus - 2,
        vertical: kBorderWidthThick + 2,
      ),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: kFontSizeSmall,
            color: cs.onSecondaryContainer,
          ),
          const SizedBox(width: kBorderWidthThick),
          Text(
            '₪${budget.toStringAsFixed(0)}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDateChip(BuildContext context, DateTime eventDate) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final daysUntil = eventDate.difference(now).inDays;

    // 🆕 בחירת צבע + אייקון לפי מרחק
    Color chipColor;
    Color textColor;
    IconData icon;
    
    if (daysUntil <= 7) {
      // דחוף - אדום
      chipColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
      icon = Icons.event;
    } else if (daysUntil <= 14) {
      // בינוני - כתום
      chipColor = Colors.orange.shade100;
      textColor = Colors.orange.shade800;
      icon = Icons.event;
    } else {
      // רגיל - ירוק
      chipColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
      icon = Icons.event;
    }

    // פורמט טקסט
    String dateText;
    if (daysUntil == 0) {
      dateText = 'היום! 🎂';
      icon = Icons.cake;
    } else if (daysUntil == 1) {
      dateText = 'מחר';
    } else if (daysUntil > 0) {
      dateText = 'בעוד $daysUntil ימים';
    } else {
      dateText = 'עבר';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kSpacingSmallPlus,
        vertical: kBorderWidthThick + 2,
      ),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(kBorderRadius),
        border: Border.all(
          color: textColor.withValues(alpha: 0.3),
          width: kBorderWidth,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: kIconSizeSmall - 2, // 14px
            color: textColor,
          ),
          const SizedBox(width: kBorderWidthThick + 2),
          Text(
            dateText,
            style: theme.textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
