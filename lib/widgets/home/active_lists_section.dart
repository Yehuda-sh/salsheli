// 📄 File: lib/widgets/home/active_lists_section.dart
// 🎯 Purpose: רשימת רשימות קניות פעילות נוספות (מלבד הראשית)
//
// 📋 Features:
// ✅ תצוגת רשימות כפתקים ירוקים
// ✅ Navigation לפרטי רשימה
// ✅ Empty state כשאין רשימות
// ✅ עיצוב Sticky Notes
// ✅ RTL support
//
// 🎨 Design:
// - צבע: kStickyGreen (ירוק)
// - סיבוב: -0.01 עד 0.01 (דינמי)
// - אנימציות: fadeIn + slideY

import 'package:flutter/material.dart';
import 'package:memozap/core/ui_constants.dart';
import 'package:memozap/l10n/app_strings.dart';
import 'package:memozap/models/shopping_list.dart';
import 'package:memozap/widgets/common/sticky_note.dart';

class ActiveListsSection extends StatelessWidget {
  final List<ShoppingList> lists;
  final VoidCallback onTapList;

  const ActiveListsSection({
    super.key,
    required this.lists,
    required this.onTapList,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    // Empty state
    if (lists.isEmpty) {
      return StickyNote(
        color: kStickyGreen,
        rotation: 0.01,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(kSpacingLarge),
            child: Text(
              AppStrings.home.noOtherActiveLists,
              style: t.bodyMedium?.copyWith(
                color: Colors.black87,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return StickyNote(
      color: kStickyGreen,
      rotation: -0.01,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // כותרת
          Row(
            children: [
              const Icon(
                Icons.list_alt,
                size: kIconSizeSmall,
                color: Colors.black87,
              ),
              const SizedBox(width: kSpacingSmall),
              Text(
                AppStrings.home.otherActiveLists,
                style: t.titleMedium?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // ספירת רשימות
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: kSpacingSmall,
                  vertical: kSpacingXTiny,
                ),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                ),
                child: Text(
                  '${lists.length}',
                  style: t.labelMedium?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: kSpacingSmall),
          const Divider(color: Colors.black26, height: 1),
          const SizedBox(height: kSpacingSmall),

          // רשימת הרשימות
          ...lists.map((list) => _ListTile(
                list: list,
                onTap: onTapList,
              )),
        ],
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  final ShoppingList list;
  final VoidCallback onTap;

  const _ListTile({
    required this.list,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final itemCount = list.items.length;
    final hasItems = itemCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kBorderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: kSpacingSmall,
            vertical: kSpacingSmall,
          ),
          child: Row(
            children: [
              // אייקון
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: kIconSizeSmall,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: kSpacingSmall),

              // שם + פרטים
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.name,
                      style: t.bodyLarge?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasItems)
                      Text(
                        AppStrings.home.itemsCount(itemCount),
                        style: t.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),

              // חץ
              const Icon(
                Icons.chevron_left,
                size: kIconSizeSmall,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
