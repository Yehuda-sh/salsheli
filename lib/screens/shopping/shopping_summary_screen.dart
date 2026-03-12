// 📄 File: lib/screens/shopping/shopping_summary_screen.dart
//
// 🎯 Purpose: מסך סיכום קנייה לאחר סיום רשימת קניות
//
// 📦 Dependencies:
// - ShoppingListsProvider: שליפת נתוני הרשימה
//
// ✨ Features:
// - 📊 סטטיסטיקות: תקציב, אחוז הצלחה, פירוט פריטים
// - 🎉 UI חגיגי לסיום קנייה מוצלח
// - 📱 Navigation חזרה לדף הבית
// - 🎨 Theme-aware colors
// - 🔄 Empty states (loading, error, not found)
//
// 📝 Usage:
// ```dart
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => ShoppingSummaryScreen(listId: 'list_123'),
//   ),
// );
// ```

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_button.dart';
import '../../widgets/common/sticky_note.dart';

// 🔧 Wrapper ללוגים - פועל רק ב-debug mode
void _log(String message) {
}

class ShoppingSummaryScreen extends StatelessWidget {
  /// מזהה הרשימה
  final String listId;

  const ShoppingSummaryScreen({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    _log('🎉 ShoppingSummaryScreen.build: listId=$listId');

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: kPaperBackground,
      body: Stack(
        children: [
          const NotebookBackground(),
          SafeArea(
            child: Consumer<ShoppingListsProvider>(
              builder: (context, provider, _) {
                // 1️⃣ Loading State
                if (provider.isLoading) {
                  _log('   ⏳ Loading...');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: cs.primary),
                        SizedBox(height: kSpacingMedium),
                        Text(
                          'טוען סיכום...',
                          style: TextStyle(
                            fontSize: kFontSizeBody,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // 2️⃣ Error State
                if (provider.errorMessage != null) {
                  _log('   ❌ Error: ${provider.errorMessage}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: cs.error),
                        SizedBox(height: kSpacingMedium),
                        Text(
                          'שגיאה בטעינת הסיכום',
                          style: TextStyle(fontSize: kFontSizeTitle, color: cs.onSurface),
                        ),
                        SizedBox(height: kSpacingSmall),
                        Text(
                          provider.errorMessage ?? 'שגיאה לא ידועה',
                          style: TextStyle(fontSize: kFontSizeMedium, color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: kSpacingLarge),
                        StickyButton(
                          label: 'חזור',
                          icon: Icons.arrow_back,
                          color: kStickyYellow,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                }

                // 3️⃣ Not Found State
                final list = provider.getById(listId);
                if (list == null) {
                  _log('   ⚠️ List not found: $listId');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 80, color: cs.onSurfaceVariant),
                        SizedBox(height: kSpacingMedium),
                        Text(
                          'הרשימה לא נמצאה',
                          style: TextStyle(
                            fontSize: kFontSizeLarge,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        SizedBox(height: kSpacingSmall),
                        Text(
                          'ייתכן שהרשימה נמחקה',
                          style: TextStyle(fontSize: kFontSizeMedium, color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: kSpacingLarge),
                        StickyButton(
                          label: 'חזרה לדף הבית',
                          icon: Icons.home,
                          color: kStickyYellow,
                          onPressed: () {
                            _log('   🏠 ניווט חזרה לדף הבית');

                            // ✨ Haptic feedback למשוב מישוש
                            HapticFeedback.lightImpact();

                            // 🔧 שמור Navigator לפני שימוש
                            final navigator = Navigator.of(context);
                            navigator.popUntil((route) => route.isFirst);
                          },
                        ),
                      ],
                    ),
                  );
                }

                // 4️⃣ Content - חישוב סטטיסטיקות
                _log('   ✅ מציג סיכום: ${list.name}');
                final total = list.items.length;
                final purchased = list.items.where((item) => item.isChecked).length;
                final missing = total - purchased;
                final spentAmount = list.items
                    .where((item) => item.isChecked)
                    .fold(0.0, (sum, item) => sum + (item.totalPrice ?? 0.0));
                final budget = list.budget ?? 0.0;
                final budgetDiff = budget - spentAmount;
                final successRate = total > 0 ? (purchased / total) * 100 : 0;

                _log('   📊 נקנו: $purchased/$total');
                _log('   💰 הוצאו: ₪${spentAmount.toStringAsFixed(2)}');
                _log('   📈 אחוז הצלחה: ${successRate.toStringAsFixed(1)}%');

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(kSpacingMedium),
                  child: Column(
                    children: [
                      // 🎉 כותרת
                      Column(
                        children: [
                          ClipOval(
                            child: Image.asset(
                              'assets/images/shopping_success.webp',
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'קנייה הושלמה בהצלחה!',
                            style: TextStyle(
                              fontSize: kFontSizeXLarge,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          SizedBox(height: kSpacingSmall),
                          Text(
                            list.name,
                            style: TextStyle(
                              fontSize: kFontSizeTitle,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // 💰 תקציב
                      StickyNote(
                        color: kStickyYellow,
                        rotation: -0.02,
                        child: _SummaryCard(
                          icon: Icons.account_balance_wallet,
                          title: 'תקציב',
                          value: '₪${spentAmount.toStringAsFixed(2)}',
                          subtitle: budget > 0
                              ? '${budgetDiff >= 0 ? 'נשאר' : 'חריגה'}: ₪${budgetDiff.abs().toStringAsFixed(2)}'
                              : null,
                          color: budgetDiff >= 0 ? kStickyGreen : cs.error,
                        ),
                      ),

                      const SizedBox(height: kSpacingMedium),

                      // ✅ הצלחה
                      StickyNote(
                        color: kStickyGreen,
                        rotation: 0.015,
                        child: _SummaryCard(
                          icon: Icons.trending_up,
                          title: 'אחוז הצלחה',
                          value: '${successRate.toStringAsFixed(1)}%',
                          subtitle: '$purchased מתוך $total פריטים נרכשו',
                          color: cs.tertiary,
                        ),
                      ),

                      const SizedBox(height: kSpacingMedium),

                      // 📊 פירוט פריטים
                      Row(
                        children: [
                          Expanded(
                            child: StickyNote(
                              color: kStickyPink,
                              rotation: -0.01,
                              child: _StatBox(
                                icon: Icons.check_circle,
                                label: 'נרכשו',
                                value: '$purchased',
                                color: kStickyGreen,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StickyNote(
                              color: kStickyCyan,
                              rotation: 0.01,
                              child: _StatBox(
                                icon: Icons.cancel,
                                label: 'חסרו',
                                value: '$missing',
                                color: cs.error,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // 🔙 כפתור חזרה
                      StickyButton(
                        label: 'חזרה לדף הבית',
                        icon: Icons.home,
                        color: kStickyYellow,
                        onPressed: () {
                          _log('   🏠 לחיצה על כפתור חזרה - popUntil');

                          // ✨ Haptic feedback למשוב מישוש
                          HapticFeedback.lightImpact();

                          // 🔧 שמור Navigator לפני שימוש
                          final navigator = Navigator.of(context);
                          navigator.popUntil((route) => route.isFirst);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// Widget: כרטיס סיכום
// ========================================

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // StickyNote תמיד בהיר - צריך טקסט כהה
    // ב-dark mode המערכת רוצה טקסט בהיר, אז מתקנים ל-black87
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? cs.onSurface
        : cs.onSurface.withValues(alpha: 0.6);

    return Padding(
      padding: const EdgeInsets.all(kSpacingLarge),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: kFontSizeMedium,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: kFontSizeTitle,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: kFontSizeSmall,
                      color: textColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// Widget: תיבת סטטיסטיקה
// ========================================

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // StickyNote תמיד בהיר - צריך טקסט כהה
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? cs.onSurface
        : cs.onSurface.withValues(alpha: 0.6);

    return Padding(
      padding: const EdgeInsets.all(kSpacingMedium),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: kFontSizeLarge,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: kFontSizeSmall,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
