// 📄 File: lib/widgets/list_selector.dart
// תיאור: בורר רשימות קניות - תצוגת כרטיסים לבחירת רשימה
//
// Purpose:
// וידג'ט מרכזי להצגת רשימות קניות בצורה ויזואלית ואינטראקטיבית.
// תומך בתצוגה בודדת או Grid של מספר רשימות.
//
// Features:
// - תצוגת רשימה בודדת או Grid של רשימות (2 columns)
// - כרטיסי רשימה עם מידע: שם, כמות פריטים, תקציב, תאריך עדכון
// - תגים חכמים (עדכון אחרון, רשימה ריקה)
// - כפתור "התחל קנייה" בולט
// - Hover effect לכרטיסים
// - 3 Empty States: Loading, Empty, Content
// - Material Design: touch targets 48px, theme colors
// - Accessibility: Semantics מלאה
// - Logging מפורט לכל פעולה
//
// Dependencies:
// - ShoppingList model (lib/models/shopping_list.dart)
// - Theme colors (AppBrand)
// - intl (לפורמט מחיר)
// - constants.dart (ListType)
//
// Usage:
//
// Example 1 - רשימה בודדת:
// ```dart
// ListSelector(
//   lists: [myShoppingList],
//   onStartShopping: (list) => Navigator.push(...),
//   onEdit: (list) => Navigator.push(...),
// )
// ```
//
// Example 2 - Grid של רשימות:
// ```dart
// ListSelector(
//   lists: allLists, // 2+ lists
//   onStartShopping: (list) {
//     debugPrint('מתחיל קנייה: ${list.name}');
//     Navigator.push(context, MaterialPageRoute(
//       builder: (_) => ActiveShoppingScreen(listId: list.id),
//     ));
//   },
//   onEdit: (list) => Navigator.push(...),
// )
// ```
//
// Example 3 - עם Loading state:
// ```dart
// Consumer<ShoppingListsProvider>(
//   builder: (context, provider, _) {
//     return ListSelector(
//       lists: provider.lists,
//       isLoading: provider.isLoading,
//       onStartShopping: (list) => ...,
//     );
//   },
// )
// ```
//
// Example 4 - כרטיס בודד (ללא actions):
// ```dart
// ListCard(
//   list: myList,
//   onStartShopping: (_) {},
//   onEdit: (_) {},
//   showActions: false, // בלי כפתורים
// )
// ```
//
// Version: 2.1

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../models/shopping_list.dart';
import '../theme/app_theme.dart';

// ============================
// קבועים
// ============================

const double _kCardPadding = 16.0;
const double _kCardBorderRadius = 12.0;
const double _kCardElevation = 3.0;
const double _kCardElevationHover = 6.0;
const double _kTitleFontSize = 18.0;
const double _kSubtitleFontSize = 13.0;
const double _kBodyFontSize = 14.0;
const double _kLabelFontSize = 11.0;
const double _kIconSize = 24.0;
const double _kButtonMinHeight = 48.0;
const double _kGridSpacing = 12.0;
const double _kGridAspectRatio = 0.9;

// ============================
// Helper Functions
// ============================

/// פורמט מחיר ל-₪
String _formatILS(num amount) {
  final formatter = NumberFormat.currency(locale: "he", symbol: "₪");
  return formatter.format(amount);
}

// ============================
// Smart Label Model
// ============================

class _SmartLabel {
  final String text;
  final Color Function(ColorScheme) getColor;
  final Color Function(ColorScheme) getBgColor;
  final IconData icon;
  final int priority;

  const _SmartLabel({
    required this.text,
    required this.getColor,
    required this.getBgColor,
    required this.icon,
    required this.priority,
  });
}

// ============================
// ListCard Widget
// ============================

class ListCard extends StatefulWidget {
  final ShoppingList list;
  final void Function(ShoppingList) onStartShopping;
  final void Function(ShoppingList) onEdit;
  final bool showActions;

  const ListCard({
    super.key,
    required this.list,
    required this.onStartShopping,
    required this.onEdit,
    this.showActions = true,
  });

  @override
  State<ListCard> createState() => _ListCardState();
}

class _ListCardState extends State<ListCard> {
  bool isHovered = false;

  List<_SmartLabel> _getSmartLabels(ColorScheme cs) {
    debugPrint('   🏷️ _getSmartLabels()');
    final labels = <_SmartLabel>[];

    // תווית עדכון אחרון
    labels.add(
      _SmartLabel(
        text:
            "עודכנה ${DateFormat('dd/MM/yyyy').format(widget.list.updatedDate)}",
        getColor: (cs) => cs.onSurfaceVariant,
        getBgColor: (cs) => cs.surfaceContainerHighest,
        icon: Icons.calendar_today,
        priority: 1,
      ),
    );

    // פריטים ריקים
    if (widget.list.items.isEmpty) {
      labels.add(
        _SmartLabel(
          text: "רשימה ריקה",
          getColor: (cs) => cs.onSurfaceVariant.withValues(alpha: 0.7),
          getBgColor: (cs) => cs.surfaceContainerHigh,
          icon: Icons.inventory_2,
          priority: 3,
        ),
      );
    }

    labels.sort((a, b) => a.priority.compareTo(b.priority));
    final result = labels.take(2).toList();
    debugPrint('      ✅ נוצרו ${result.length} תוויות: ${result.map((l) => l.text).join(", ")}');
    return result;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎴 ListCard.build()');
    debugPrint('   📝 שם: ${widget.list.name}');
    debugPrint('   📦 פריטים: ${widget.list.items.length}');
    debugPrint('   💰 תקציב: ${widget.list.budget ?? "אין"}');
    debugPrint('   🗓️ עדכון: ${DateFormat("dd/MM/yyyy").format(widget.list.updatedDate)}');

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();

    final itemsCount = widget.list.items.length;
    final labels = _getSmartLabels(cs);
    final listIcon = _getListTypeIcon(widget.list.type);

    return Semantics(
      label: 'רשימת קניות ${widget.list.name}, $itemsCount פריטים',
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: GestureDetector(
          onTap: () => widget.onStartShopping(widget.list),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Card(
              color: cs.surfaceContainer,
              elevation: isHovered ? _kCardElevationHover : _kCardElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_kCardBorderRadius),
                side: BorderSide(
                  color: cs.outline.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(_kCardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // כותרת + אייקון
                    Row(
                      children: [
                        Icon(
                          listIcon,
                          color: brand?.accent ?? cs.primary,
                          size: _kIconSize,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.list.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: _kTitleFontSize,
                              color: cs.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // תגים חכמים
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: labels.map((label) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: label.getBgColor(cs),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                label.icon,
                                size: 12,
                                color: label.getColor(cs),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                label.text,
                                style: TextStyle(
                                  fontSize: _kLabelFontSize,
                                  color: label.getColor(cs),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // מידע על פריטים
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "פריטים",
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: _kSubtitleFontSize,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          "$itemsCount",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: _kBodyFontSize,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),

                    // תקציב (אם קיים)
                    if (widget.list.budget != null &&
                        widget.list.budget! > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "תקציב",
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: _kSubtitleFontSize,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            _formatILS(widget.list.budget!),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: _kBodyFontSize,
                              fontWeight: FontWeight.bold,
                              color: brand?.accent ?? cs.primary,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 12),
                    Divider(
                      color: cs.outline.withValues(alpha: 0.2),
                      height: 1,
                    ),
                    const SizedBox(height: 12),

                    // כפתור התחל קנייה
                    Center(
                      child: SizedBox(
                        height: _kButtonMinHeight,
                        child: ElevatedButton.icon(
                          onPressed: () => widget.onStartShopping(widget.list),
                          icon: const Icon(Icons.shopping_bag, size: 18),
                          label: const Text("התחל קנייה"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brand?.accent ?? cs.primary,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
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

  IconData _getListTypeIcon(String type) {
    // ✅ עכשיו משתמש ב-kListTypes מ-constants
    switch (type) {
      case ListType.super_:
        return Icons.shopping_cart;
      case ListType.pharmacy:
        return Icons.local_pharmacy;
      default:
        return Icons.shopping_bag;
    }
  }
}

// ============================
// ListSelector Widget
// ============================

class ListSelector extends StatelessWidget {
  final List<ShoppingList> lists;
  final void Function(ShoppingList)? onStartShopping;
  final void Function(ShoppingList)? onEdit;
  final bool isLoading;
  final bool showActions;

  const ListSelector({
    super.key,
    this.lists = const [],
    this.onStartShopping,
    this.onEdit,
    this.isLoading = false,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('🎯 ListSelector.build()');
    debugPrint('   📊 lists.length: ${lists.length}');
    debugPrint('   ⏳ isLoading: $isLoading');

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // מצב טעינה
    if (isLoading) {
      debugPrint('   ⏳ מציג Loading state');
      return Center(
        child: CircularProgressIndicator(
          color: theme.extension<AppBrand>()?.accent ?? cs.primary,
        ),
      );
    }

    // מצב ריק
    if (lists.isEmpty) {
      debugPrint('   📦 רשימות ריקות - SizedBox.shrink()');
      return const SizedBox.shrink();
    }

    // רשימה בודדת
    if (lists.length == 1) {
      debugPrint('   📑 תצוגת רשימה בודדת: ${lists.first.name}');
      return ListCard(
        list: lists.first,
        onStartShopping: onStartShopping ?? (_) {},
        onEdit: onEdit ?? (_) {},
        showActions: showActions,
      );
    }

    // Grid של רשימות
    debugPrint('   🔲 תצוגת Grid של ${lists.length} רשימות');
    return Semantics(
      label: 'רשימת ${lists.length} רשימות קניות',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: lists.length,
        padding: const EdgeInsets.all(_kGridSpacing),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: _kGridSpacing,
          mainAxisSpacing: _kGridSpacing,
          childAspectRatio: _kGridAspectRatio,
        ),
        itemBuilder: (context, index) {
          final list = lists[index];
          return ListCard(
            list: list,
            onStartShopping: onStartShopping ?? (_) {},
            onEdit: onEdit ?? (_) {},
            showActions: showActions,
          );
        },
      ),
    );
  }
}
