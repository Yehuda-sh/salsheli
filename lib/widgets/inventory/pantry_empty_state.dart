// 📄 File: lib/widgets/inventory/pantry_empty_state.dart
// 🎯 Purpose: Empty State למזווה - כאשר אין פריטים
//
// 📋 Features:
// - תצוגה ידידותית כשהמזווה ריק
// - הכוונה למשתמש איך להתחיל
// - כפתור הוספת פריט ראשון
// - מידע על מצב מזווה (אישי/משותף)
//
// Version: 1.0
// Created: 16/12/2025

import 'package:flutter/material.dart';

import '../../core/ui_constants.dart';
import '../common/sticky_note.dart';

/// Empty State למזווה - מוצג כאשר אין פריטים
///
/// Example:
/// ```dart
/// PantryEmptyState(
///   isGroupMode: inventoryProvider.isGroupMode,
///   onAddItem: () => _addItemDialog(),
/// )
/// ```
class PantryEmptyState extends StatelessWidget {
  /// האם במצב קבוצתי
  final bool isGroupMode;

  /// שם הקבוצה (אם במצב קבוצתי)
  final String? groupName;

  /// Callback להוספת פריט
  final VoidCallback? onAddItem;

  const PantryEmptyState({
    super.key,
    this.isGroupMode = false,
    this.groupName,
    this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kSpacingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // === אייקון ראשי ===
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: kStickyCyan.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '🏪',
                    style: TextStyle(fontSize: 60),
                  ),
                ),
              ),

              const SizedBox(height: kSpacingLarge),

              // === כותרת ===
              Text(
                'המזווה ריק',
                style: TextStyle(
                  fontSize: kFontSizeXLarge,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),

              const SizedBox(height: kSpacingSmall),

              // === תיאור ===
              Text(
                isGroupMode
                    ? 'עדיין לא הוספתם מוצרים למזווה המשותף'
                    : 'עדיין לא הוספת מוצרים למזווה שלך',
                style: TextStyle(
                  fontSize: kFontSizeMedium,
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: kSpacingXLarge),

              // === כרטיס הסבר ===
              StickyNote(
                color: kStickyYellow,
                rotation: 0.01,
                child: Padding(
                  padding: const EdgeInsets.all(kSpacingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: kSpacingSmall),
                          Text(
                            'איך להתחיל?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: kFontSizeMedium,
                              color: Colors.brown.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: kSpacingSmall),
                      _buildTip(
                        '1️⃣',
                        'לחץ על הכפתור + למטה',
                      ),
                      _buildTip(
                        '2️⃣',
                        'בחר מוצר מהקטלוג או הוסף חדש',
                      ),
                      _buildTip(
                        '3️⃣',
                        'הגדר כמות ומיקום אחסון',
                      ),
                      const SizedBox(height: kSpacingSmall),
                      const Divider(),
                      const SizedBox(height: kSpacingSmall),
                      Text(
                        '✨ המזווה יעזור לך לעקוב אחרי מה שיש לך בבית',
                        style: TextStyle(
                          fontSize: kFontSizeSmall,
                          color: Colors.brown.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: kSpacingLarge),

              // === מידע על מצב המזווה ===
              if (isGroupMode && groupName != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSpacingMedium,
                    vertical: kSpacingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(kBorderRadius),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.family_restroom,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: kSpacingSmall),
                      Text(
                        'מזווה משותף - $groupName',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSpacingMedium,
                    vertical: kSpacingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(kBorderRadius),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: kSpacingSmall),
                      Text(
                        'המזווה האישי שלך',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: kSpacingXLarge),

              // === כפתור הוספה ===
              if (onAddItem != null)
                ElevatedButton.icon(
                  onPressed: onAddItem,
                  icon: const Icon(Icons.add),
                  label: const Text('הוסף מוצר ראשון'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kStickyCyan,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: kSpacingLarge,
                      vertical: kSpacingMedium,
                    ),
                    textStyle: const TextStyle(
                      fontSize: kFontSizeMedium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// בונה שורת טיפ
  Widget _buildTip(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpacingTiny),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: kSpacingSmall),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: kFontSizeSmall,
                color: Colors.brown.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
