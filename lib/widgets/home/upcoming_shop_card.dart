// 📄 File: lib/widgets/home/upcoming_shop_card.dart
//
// ✅ עדכונים (14/10/2025) - Modern UI/UX v8.0:
// 1. ✨ Button Animations - כל הכפתורים מונפשים
// 2. ✨ Enhanced "התחל קנייה" - Scale + Elevation + Ripple
// 3. ✨ Badge Animations - תגים אינטראקטיביים
// 4. ✨ Card Entrance Animation - Slide + Fade
// 5. 🎨 Modern UI polish מלא
//
// ✅ עדכונים קודמים (08/10/2025):
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

class UpcomingShopCard extends StatefulWidget {
  final ShoppingList? list;

  const UpcomingShopCard({super.key, this.list});

  @override
  State<UpcomingShopCard> createState() => _UpcomingShopCardState();
}

class _UpcomingShopCardState extends State<UpcomingShopCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // 🆕 Card entrance animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
    // 🆕 Wrap with animations
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.list == null
            ? _EmptyUpcomingCard(
                onCreateList: () => _showCreateListDialog(context),
              )
            : DashboardCard(
                title: "הקנייה הקרובה",
                icon: Icons.shopping_cart,
                elevation: 3,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/populate-list',
                    arguments: widget.list,
                  );
                },
                child: _ListSummary(list: widget.list!),
              ),
      ),
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
          
          // 🆕 Animated button
          _AnimatedButton(
            onPressed: onCreateList,
            child: FilledButton.icon(
              onPressed: null, // ה-AnimatedButton מטפל ב-onPressed
              icon: const Icon(Icons.add),
              label: const Text("צור רשימה חדשה"),
            ),
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
            
            // 🆕 Animated icon button
            _AnimatedIconButton(
              icon: Icons.edit_outlined,
              size: kIconSizeSmall,
              color: cs.onSurface,
              tooltip: 'ערוך רשימה',
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

        // 🆕 תגים מונפשים
        Wrap(
          spacing: kSpacingSmall,
          runSpacing: kSpacingSmall,
          children: [
            _AnimatedBadge(
              child: _buildTypeBadge(context, list.type),
            ),
            if (list.budget != null)
              _AnimatedBadge(
                child: _buildBudgetChip(context, list.budget!),
              ),
            if (list.eventDate != null)
              _AnimatedBadge(
                child: _buildEventDateChip(context, list.eventDate!),
              ),
          ],
        ),
        const SizedBox(height: kSpacingMedium),

        // התקדמות - עם טיפול ב-0%
        if (progress == 0.0) ...[
          // סטטוס טקסטואלי כשאין התקדמות
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

        // 🆕 כפתור "התחל קנייה" מונפש מלא!
        _EnhancedShoppingButton(
          accent: accent,
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/active-shopping',
              arguments: list,
            );
          },
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

    // בחירת צבע + אייקון לפי מרחק
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
            size: kIconSizeSmall - 2,
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

// ═══════════════════════════════════════════════════════════════
// 🆕 ANIMATION WIDGETS
// ═══════════════════════════════════════════════════════════════

// 1. Animated Button - Scale Effect
class _AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const _AnimatedButton({
    required this.child,
    required this.onPressed,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}

// 2. Animated Icon Button
class _AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const _AnimatedIconButton({
    required this.icon,
    required this.size,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: IconButton(
          icon: Icon(widget.icon, size: widget.size),
          color: widget.color,
          tooltip: widget.tooltip,
          padding: const EdgeInsets.all(kSpacingSmall),
          constraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ),
          onPressed: null, // ה-GestureDetector מטפל ב-onPressed
        ),
      ),
    );
  }
}

// 3. Animated Badge - Subtle Tap Effect
class _AnimatedBadge extends StatefulWidget {
  final Widget child;

  const _AnimatedBadge({required this.child});

  @override
  State<_AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<_AnimatedBadge> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}

// 4. Enhanced Shopping Button - הכפתור הגדול המונפש!
class _EnhancedShoppingButton extends StatefulWidget {
  final Color accent;
  final VoidCallback onPressed;

  const _EnhancedShoppingButton({
    required this.accent,
    required this.onPressed,
  });

  @override
  State<_EnhancedShoppingButton> createState() =>
      _EnhancedShoppingButtonState();
}

class _EnhancedShoppingButtonState extends State<_EnhancedShoppingButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.accent,
                widget.accent.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(kBorderRadius),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withValues(
                  alpha: _isPressed ? 0.4 : 0.3,
                ),
                blurRadius: _isPressed ? 12 : 8,
                offset: Offset(0, _isPressed ? 6 : 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: null, // ה-GestureDetector מטפל ב-onTap
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
    );
  }
}
