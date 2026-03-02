// 📄 lib/widgets/inventory/pantry_empty_state.dart
// Version 4.0 - Hybrid Premium | 22/02/2026
//
// Empty State למזווה — חוויה מזמינה, "חיה" ויוקרתית.
//
// Features:
//   - Choreographed Entrance: כניסה מדורגת 5 קבוצות, 200ms בין כל קבוצה
//   - Physical Sticky Notes: rotate 0.01/-0.01, animate:false (תיזמון חיצוני)
//   - Haptic Signatures: mediumImpact לCTA ראשי, lightImpact לCTA משני
//   - RepaintBoundary: מבודד אנימציות כניסה משאר עץ הווידג'טים
//   - Gap: ריווח סמנטי במקום SizedBox
//   - Status Badge: Center wrapper לתיקון יישור RTL
//
// 🔗 Related: MyPantryScreen, InventoryProvider

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../core/status_colors.dart';
import '../../core/ui_constants.dart';
import '../common/sticky_button.dart';
import '../common/sticky_note.dart';

/// Empty State למזווה — מוצג כאשר אין פריטים
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

  /// Callback להוספת פריט — mediumImpact haptic
  final VoidCallback? onAddItem;

  /// Callback להוספת פריטי starter — lightImpact haptic
  final VoidCallback? onAddStarterItems;

  const PantryEmptyState({
    super.key,
    this.isGroupMode = false,
    this.groupName,
    this.onAddItem,
    this.onAddStarterItems,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // 🎬 Stagger Delays — 5 קבוצות, 200ms בין כל קבוצה
    const d0 = Duration.zero;               // Group 1: אייקון ראשי
    const d1 = Duration(milliseconds: 200); // Group 2: טקסטים
    const d2 = Duration(milliseconds: 400); // Group 3: פתק צהוב
    const d3 = Duration(milliseconds: 600); // Group 4: פתק ירוק + badge
    const d4 = Duration(milliseconds: 800); // Group 5: כפתור CTA

    // 🗒️ Extract StickyNotes to local widgets — נמנע מבעיית הפענוח של הנאלייזר
    // שגיאה ידועה: StickyNote(...).animate() ישירות בתוך list children
    // פתרון: הגדרה מחוץ לרשימה
    final Widget yellowNote = StickyNote(
      color: kStickyYellow,
      rotation: 0.01,
      animate: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 20)),
              const Gap(kSpacingSmall),
              Text(
                'איך להתחיל?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: kFontSizeMedium,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const Gap(kSpacingSmall),
          _buildTip('1️⃣', 'לחץ על הכפתור + למטה', cs.onSurfaceVariant),
          _buildTip('2️⃣', 'בחר מוצר מהקטלוג או הוסף חדש', cs.onSurfaceVariant),
          _buildTip('3️⃣', 'הגדר כמות ומיקום אחסון', cs.onSurfaceVariant),
          const Gap(kSpacingSmall),
          const Divider(),
          const Gap(kSpacingSmall),
          Text(
            '✨ המזווה יעזור לך לעקוב אחרי מה שיש לך בבית',
            style: TextStyle(
              fontSize: kFontSizeSmall,
              color: cs.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );

    final Widget greenNote = onAddStarterItems != null
        ? StickyNote(
            color: kStickyGreen,
            rotation: -0.01,
            animate: false,
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('🎁', style: TextStyle(fontSize: 20)),
                    const Gap(kSpacingSmall),
                    Expanded(
                      child: Text(
                        'רוצה להתחיל עם מוצרי יסוד?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: kFontSizeMedium,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(kSpacingSmall),
                Text(
                  'קמח, סוכר, שמן, אורז ועוד - נוסיף אותם אוטומטית',
                  style: TextStyle(
                    fontSize: kFontSizeSmall,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const Gap(kSpacingMedium),
                StickyButton(
                  color: kStickyYellow,
                  label: 'כן, הוסף!',
                  icon: Icons.check,
                  onPressed: () {
                    unawaited(HapticFeedback.lightImpact());
                    onAddStarterItems!();
                  },
                ),
              ],
            ),
          )
        : const SizedBox.shrink();

    return Directionality(
      textDirection: TextDirection.rtl,
      // 🎨 RepaintBoundary מבודד אנימציות כניסה משאר האפליקציה
      child: RepaintBoundary(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(kSpacingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ═══════════════════════════════════════════════════════
                // Group 1 — אייקון ראשי (נוחת ראשון, scale מ-0.75)
                // ═══════════════════════════════════════════════════════
                Semantics(
                  label: 'מזווה ריק',
                  excludeSemantics: true,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: kStickyCyan.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🏪', style: TextStyle(fontSize: 60)),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: d0)
                    .scale(
                      begin: const Offset(0.75, 0.75),
                      end: const Offset(1.0, 1.0),
                      duration: 500.ms,
                      delay: d0,
                      curve: Curves.easeOutBack,
                    ),

                const Gap(kSpacingLarge),

                // ═══════════════════════════════════════════════════════
                // Group 2 — כותרת + תיאור
                // ═══════════════════════════════════════════════════════
                Column(
                  children: [
                    Text(
                      'המזווה ריק',
                      style: TextStyle(
                        fontSize: kFontSizeXLarge,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const Gap(kSpacingSmall),
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
                  ],
                )
                    .animate()
                    .fadeIn(duration: 350.ms, delay: d1)
                    .slideY(
                      begin: 0.06,
                      end: 0,
                      duration: 350.ms,
                      delay: d1,
                      curve: Curves.easeOut,
                    ),

                const Gap(kSpacingXLarge),

                // ═══════════════════════════════════════════════════════
                // Group 3 — פתק "איך להתחיל?" (צהוב, 0.01°)
                // ═══════════════════════════════════════════════════════
                yellowNote
                    .animate()
                    .fadeIn(duration: 350.ms, delay: d2)
                    .slideY(
                      begin: 0.06,
                      end: 0,
                      duration: 350.ms,
                      delay: d2,
                      curve: Curves.easeOut,
                    ),

                const Gap(kSpacingMedium),

                // ═══════════════════════════════════════════════════════
                // Group 4 — פתק starter + badge מצב
                // ═══════════════════════════════════════════════════════
                Column(
                  children: [
                    // פתק מוצרי יסוד (ירוק, -0.01°) — contra-rotation
                    if (onAddStarterItems != null) ...[
                      greenNote
                          .animate()
                          .fadeIn(duration: 350.ms, delay: d3)
                          .slideY(
                            begin: 0.06,
                            end: 0,
                            duration: 350.ms,
                            delay: d3,
                            curve: Curves.easeOut,
                          ),
                      const Gap(kSpacingLarge),
                    ],

                    // Badge מצב מזווה — Center מתקן יישור RTL
                    Center(child: _buildStatusBadge(context, cs)),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 350.ms, delay: d3)
                    .slideY(
                      begin: 0.06,
                      end: 0,
                      duration: 350.ms,
                      delay: d3,
                      curve: Curves.easeOut,
                    ),

                const Gap(kSpacingXLarge),

                // ═══════════════════════════════════════════════════════
                // Group 5 — CTA ראשי (נכנס אחרון)
                // ═══════════════════════════════════════════════════════
                if (onAddItem != null)
                  // 📳 mediumImpact — CTA ראשי
                  StickyButton(
                    color: kStickyGreen,
                    label: 'הוסף מוצר ראשון',
                    icon: Icons.add,
                    onPressed: () {
                      unawaited(HapticFeedback.mediumImpact());
                      onAddItem!();
                    },
                  )
                      .animate()
                      .fadeIn(duration: 350.ms, delay: d4)
                      .slideY(
                        begin: 0.06,
                        end: 0,
                        duration: 350.ms,
                        delay: d4,
                        curve: Curves.easeOut,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🏷️ Status Badge
  // ═══════════════════════════════════════════════════════════════════════════

  /// Badge מצב מזווה (קבוצתי / אישי)
  ///
  /// עטוף ב-Center בצד הקורא — Container עם mainAxisSize.min נשאר ממורכז.
  Widget _buildStatusBadge(BuildContext context, ColorScheme cs) {
    if (isGroupMode && groupName != null) {
      final badgeColor = StatusColors.getColor(StatusType.success, context);
      final badgeContainer = StatusColors.getContainer(StatusType.success, context);

      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: kSpacingMedium,
          vertical: kSpacingSmall,
        ),
        decoration: BoxDecoration(
          color: badgeContainer,
          borderRadius: BorderRadius.circular(kBorderRadius),
          border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.family_restroom, color: badgeColor, size: 20),
            const Gap(kSpacingSmall),
            Text(
              'מזווה משותף - $groupName',
              style: TextStyle(color: badgeColor, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kSpacingMedium,
        vertical: kSpacingSmall,
      ),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(kBorderRadius),
        border: Border.all(color: cs.primary.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person, color: cs.primary, size: 20),
          const Gap(kSpacingSmall),
          Text(
            'המזווה האישי שלך',
            style: TextStyle(color: cs.primary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 💡 Tip Row
  // ═══════════════════════════════════════════════════════════════════════════

  /// שורת טיפ — Gap פנימי עקבי
  Widget _buildTip(String number, String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpacingTiny),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number, style: const TextStyle(fontSize: 14)),
          const Gap(kSpacingSmall),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: kFontSizeSmall, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
