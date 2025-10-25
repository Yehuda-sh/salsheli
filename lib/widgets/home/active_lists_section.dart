// 📄 File: lib/widgets/home/active_lists_section.dart
// Description: Active lists section for home dashboard - shows other active lists
//
// ✅ Features:
// - Shows list of active shopping lists (excluding upcoming shop)
// - Sticky Notes design with green color
// - Tap to navigate to list details
// - Shows item count per list

import 'package:flutter/material.dart';

import '../../core/ui_constants.dart';
import '../../models/shopping_list.dart';
import '../../widgets/common/sticky_note.dart';

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
    if (lists.isEmpty) {
      return const SizedBox.shrink();
    }

    return StickyNote(
      color: kStickyGreen,
      rotation: 0.01,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.format_list_bulleted,
                color: Colors.black87,
                size: kIconSizeMedium,
              ),
              const SizedBox(width: kSpacingSmall),
              const Text(
                'רשימות נוספות',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: kSpacingSmall,
                  vertical: kSpacingXTiny,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${lists.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: kSpacingMedium),

          // List of lists
          ...lists.map((list) => _buildListTile(context, list)),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, ShoppingList list) {
    final itemCount = list.items.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: kSpacingSmall),
      child: InkWell(
        onTap: onTapList,
        borderRadius: BorderRadius.circular(kBorderRadius),
        child: Container(
          padding: const EdgeInsets.all(kSpacingSmall),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
          child: Row(
            children: [
              // List icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shopping_basket,
                  size: 20,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: kSpacingSmall),

              // List name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (itemCount > 0)
                      Text(
                        '$itemCount פריטים',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
