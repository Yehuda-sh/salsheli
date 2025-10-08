// 📄 File: lib/widgets/list_type_selector_grouped.dart
//
// Purpose: דוגמה לשימוש ב-ListTypeGroups - בחירת סוג רשימה בקבוצות
//
// Features:
// - תצוגה מקובצת לפי: קניות יומיומיות, קניות מיוחדות, אירועים
// - אייקונים ותיאורים לכל קבוצה
// - Grid layout נוח
// - תמיכה מלאה ב-21 סוגי הרשימות
//
// Usage:
// ```dart
// showDialog(
//   context: context,
//   builder: (_) => ListTypeSelectorGrouped(
//     onTypeSelected: (type) {
//       // עשה משהו עם ה-type שנבחר
//     },
//   ),
// );
// ```
//
// Version: 1.0
// Last Updated: 08/10/2025

import 'package:flutter/material.dart';
import '../config/list_type_groups.dart';
import '../core/constants.dart';

/// Widget לבחירת סוג רשימה בתצוגה מקובצת
///
/// מציג את כל סוגי הרשימות מקובצים ב-3 קבוצות:
/// 1. קניות יומיומיות (2 סוגים)
/// 2. קניות מיוחדות (12 סוגים)
/// 3. אירועים (6 סוגים)
class ListTypeSelectorGrouped extends StatelessWidget {
  final Function(String type) onTypeSelected;

  const ListTypeSelectorGrouped({
    super.key,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              'בחר סוג רשימה',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: ListView.separated(
                itemCount: ListTypeGroups.allGroups.length,
                separatorBuilder: (_, __) => const Divider(height: 32),
                itemBuilder: (context, index) {
                  final group = ListTypeGroups.allGroups[index];
                  return _buildGroup(context, group);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// בניית קבוצה אחת
  Widget _buildGroup(BuildContext context, ListTypeGroup group) {
    final types = ListTypeGroups.getTypesInGroup(group);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group Header
        Row(
          children: [
            Text(
              ListTypeGroups.getGroupIcon(group),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ListTypeGroups.getGroupName(group),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  ListTypeGroups.getGroupDescription(group),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Types Grid
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: types.map((type) => _buildTypeChip(context, type)).toList(),
        ),
      ],
    );
  }

  /// בניית chip לסוג אחד
  Widget _buildTypeChip(BuildContext context, String type) {
    final typeInfo = kListTypes[type]!;

    return ActionChip(
      avatar: Text(typeInfo['icon']!),
      label: Text(typeInfo['name']!),
      onPressed: () {
        onTypeSelected(type);
        Navigator.of(context).pop();
      },
    );
  }
}

// ========================================
// 💡 דוגמאות שימוש נוספות
// ========================================

/// דוגמה 1: בדיקה אם type הוא אירוע
void example1(String listType) {
  if (ListTypeGroups.isEvent(listType)) {
    print('זוהי רשימת אירוע - הצג אפשרויות מיוחדות');
  }
}

/// דוגמה 2: קבלת כל הסוגים בקבוצה
void example2() {
  final eventTypes = ListTypeGroups.getTypesInGroup(ListTypeGroup.events);
  print('סוגי אירועים: $eventTypes');
  // → [birthday, party, wedding, picnic, holiday, gifts]
}

/// דוגמה 3: קבלת קבוצה של type
void example3(String listType) {
  final group = ListTypeGroups.getGroup(listType);
  final groupName = ListTypeGroups.getGroupName(group);
  print('$listType שייך לקבוצה: $groupName');
}
