// 📄 File: lib/widgets/home/smart_suggestions_card.dart
// 🎯 Purpose: כרטיס המלצות חכמות במסך הבית
//
// ✅ עדכונים (14/10/2025) - Modern UI/UX v8.0:
// 1. ✨ Skeleton Screen במקום CircularProgressIndicator
// 2. ✨ Micro Animations - כפתורים + רשימה
// 3. ✨ Error State מלא עם retry
// 4. ✨ SnackBar Animations משופרות
// 5. 🎨 4 Empty States מלאים: Loading/Error/Empty/Content
//
// ✅ עדכונים קודמים (12/10/2025):
// 1. השלמת תצוגת המלצות - 3 המלצות עליונות
// 2. כפתורי פעולה - הוספה לרשימה + הסרה
// 3. Logging מלא + Visual Feedback
// 4. Touch Targets 48x48 (Accessibility)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/shopping_list.dart';
import '../../models/receipt.dart';
import '../../models/suggestion.dart';
import '../../providers/suggestions_provider.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../core/ui_constants.dart';

class SmartSuggestionsCard extends StatelessWidget {
  final ShoppingList? mostRecentList;
  static final Uuid _uuid = Uuid();

  const SmartSuggestionsCard({super.key, this.mostRecentList});

  /// טיפול בהוספת פריט להמלצה לרשימה פעילה
  ///
  /// תהליך:
  /// 1. בדיקה אם יש רשימה פעילה (mostRecentList)
  /// 2. יצירת ReceiptItem חדש מנתוני ההמלצה
  /// 3. הוספה דרך ListsProvider
  /// 4. SnackBar משוב (הצלחה/שגיאה)
  ///
  /// הודעות:
  /// - אם אין רשימה: "אין רשימה פעילה להוסיף אליה" (כתום)
  /// - אם הצלחה: "נוסף [שם פריט] לרשימה" (ירוק)
  /// - אם שגיאה: "שגיאה בהוספה: [שגיאה]" (אדום)
  ///
  /// [context] - BuildContext לגישה ל-Providers
  /// [suggestion] - ההמלצה להוספה (עם productName + suggestedQuantity)
  /// Returns: Future&lt;void&gt;
  /// Throws: Exception מ-provider (מטופל ב-try-catch)
  Future<void> _handleAddToList(
    BuildContext context,
    Suggestion suggestion,
  ) async {
    debugPrint('➡️ SmartSuggestionsCard: מנסה להוסיף "${suggestion.productName}" לרשימה');
    
    final listsProvider = context.read<ShoppingListsProvider>();
    final list = mostRecentList;

    if (list == null) {
      debugPrint('⚠️ SmartSuggestionsCard: אין רשימה פעילה');
      _showAnimatedSnackBar(
        context,
        message: 'אין רשימה פעילה להוסיף אליה',
        icon: Icons.warning_amber_rounded,
        backgroundColor: Colors.orange,
      );
      return;
    }

    try {
      final newItem = ReceiptItem(
        id: _uuid.v4(),
        name: suggestion.productName,
        quantity: suggestion.suggestedQuantity,
      );

      await listsProvider.addItemToList(
        list.id,
        newItem.name ?? 'מוצר ללא שם',
        newItem.quantity,
        newItem.unit ?? "יח'"
      );
      debugPrint('✅ SmartSuggestionsCard: הוסף "${suggestion.productName}" בהצלחה');
      
      if (context.mounted) {
        _showAnimatedSnackBar(
          context,
          message: 'נוסף "${suggestion.productName}" לרשימה',
          icon: Icons.check_circle,
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      debugPrint('❌ SmartSuggestionsCard: שגיאה בהוספה - $e');
      if (context.mounted) {
        _showAnimatedSnackBar(
          context,
          message: 'שגיאה בהוספה: $e',
          icon: Icons.error_outline,
          backgroundColor: Colors.red,
        );
      }
    }
  }

  /// מחיקת המלצה מרשימת ההמלצות
  ///
  /// תהליך:
  /// 1. קריאה ל-SuggestionsProvider.removeSuggestion()
  /// 2. הצגת SnackBar אפור עם "ההמלצה הוסרה"
  /// 3. משך SnackBar: 2 שניות (קצר יותר)
  ///
  /// [context] - BuildContext לגישה ל-SuggestionsProvider
  /// [suggestionId] - ID הייחודי של ההמלצה למחיקה
  void _handleRemove(BuildContext context, String suggestionId) {
    debugPrint('➖ SmartSuggestionsCard: מסיר המלצה $suggestionId');
    
    final suggestionsProvider = context.read<SuggestionsProvider>();
    suggestionsProvider.removeSuggestion(suggestionId);
    
    _showAnimatedSnackBar(
      context,
      message: 'ההמלצה הוסרה',
      icon: Icons.delete_outline,
      backgroundColor: Colors.grey,
      duration: const Duration(seconds: 2),
    );
  }

  /// ניווט למסך יצירת רשימה חדשה
  ///
  /// ניווט: Navigator.pushNamed(context, '/shopping-lists')
  /// משמש כ-CTA כש-Empty State (אין המלצות)
  ///
  /// [context] - BuildContext לניווט
  void _showCreateListDialog(BuildContext context) {
    Navigator.pushNamed(context, '/shopping-lists');
  }

  // 🆕 Animated SnackBar with Slide + Fade
  /// הצגת SnackBar עם אנימציות (Slide + Fade)
  ///
  /// תכונות:
  /// - Row עם Icon + Text
  /// - backgroundColor מותאם אישית
  /// - floating behavior (מעל content)
  /// - rounded corners (kBorderRadius)
  /// - margin: kSpacingMedium
  /// - duration: ברירת מחדל 3 שניות
  ///
  /// צבעים מומלצים:
  /// - Colors.green: הצלחה ("נוסף...")
  /// - Colors.red: שגיאה ("שגיאה...")
  /// - Colors.orange: אזהרה ("אין רשימה...")
  /// - Colors.blue: מידע ("צפה בכל...")
  /// - Colors.grey: כללי ("הוסרה...")
  ///
  /// [context] - BuildContext לגישה ל-ScaffoldMessenger
  /// [message] - הודעת ה-SnackBar
  /// [icon] - IconData להצגה (עם צבע לבן)
  /// [backgroundColor] - צבע הרקע של ה-SnackBar
  /// [duration] - משך ההצגה (ברירת מחדל: 3 שניות)
  void _showAnimatedSnackBar(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(kSpacingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        animation: CurvedAnimation(
          parent: const AlwaysStoppedAnimation(1.0),
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SuggestionsProvider>(
      builder: (context, suggestionsProvider, child) {
        // 1️⃣ Loading State - 🆕 Skeleton Screen!
        if (suggestionsProvider.isLoading) {
          return _buildSkeletonCard(context);
        }

        // 2️⃣ 🆕 Error State
        if (suggestionsProvider.hasError) {
          return _buildErrorCard(context, suggestionsProvider);
        }

        final suggestions = suggestionsProvider.suggestions;

        // 3️⃣ Empty State
        if (suggestions.isEmpty) {
          return _buildEmptyCard(context);
        }

        // 4️⃣ Content State - יש המלצות
        return _buildContentCard(context, suggestions);
      },
    );
  }

  // 🆕 1. Skeleton Screen - במקום CircularProgressIndicator
  /// בנייה של Skeleton Screen (טעינה עם shimmer effect)
  ///
  /// תצוגה:
  /// - כותרת skeleton (אייקון + טקסט)
  /// - 3 skeleton items (שורות חוזרות)
  /// - כל skeleton box עם animation (opacity 0.3-0.7)
  ///
  /// Animation:
  /// - Pulsing effect (1500ms duration)
  /// - Smooth opacity transition
  /// - Dark/Light mode aware
  ///
  /// [context] - BuildContext
  /// Returns: Card widget עם skeleton UI
  Widget _buildSkeletonCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // כותרת Skeleton
            Row(
              children: [
                _SkeletonBox(
                  width: 24,
                  height: 24,
                  borderRadius: BorderRadius.circular(12),
                  isDark: isDark,
                ),
                const SizedBox(width: kSpacingSmall),
                _SkeletonBox(
                  width: 120,
                  height: 20,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: kSpacingMedium),

            // 3 Skeleton Items
            ...[1, 2, 3].map((index) => Padding(
              padding: const EdgeInsets.only(bottom: kSpacingSmall),
              child: _SuggestionItemSkeleton(isDark: isDark),
            )),
          ],
        ),
      ),
    );
  }

  // 🆕 2. Error State
  /// בנייה של Error State כרטיס
  ///
  /// תצוגה:
  /// - כותרת עם אייקון שגיאה
  /// - אייקון מרכזי (cloud_off_outlined)
  /// - כותרת: "שגיאה בטעינת ההמלצות"
  /// - הודעת שגיאה מ-provider (errorMessage)
  /// - כפתור "נסה שוב" עם אנימציה
  ///
  /// כפתור Retry:
  /// - עטוף ב-_AnimatedButton (scale effect)
  /// - קורא provider.retry()
  /// - צבע: errorContainer
  ///
  /// [context] - BuildContext
  /// [provider] - SuggestionsProvider (ל-errorMessage + retry())
  /// Returns: Card widget עם error UI
  Widget _buildErrorCard(BuildContext context, SuggestionsProvider provider) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // כותרת
            Row(
              children: [
                Icon(Icons.error_outline, color: cs.error),
                const SizedBox(width: kSpacingSmall),
                Text(
                  'המלצות חכמות',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: kSpacingMedium),

            // אייקון שגיאה
            Container(
              padding: const EdgeInsets.all(kSpacingMedium),
              decoration: BoxDecoration(
                color: cs.errorContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                size: kSpacingLarge * 2,
                color: cs.error,
              ),
            ),
            const SizedBox(height: kSpacingMedium),

            // הודעת שגיאה
            Text(
              'שגיאה בטעינת ההמלצות',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.error,
              ),
            ),
            const SizedBox(height: kSpacingSmall),
            Text(
              provider.errorMessage ?? 'משהו השתבש',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingMedium + kSpacingSmall),

            // כפתור retry
            _AnimatedButton(
              onPressed: () {
                debugPrint('🔄 SmartSuggestionsCard: retry');
                provider.retry();
              },
              child: ElevatedButton.icon(
                onPressed: null, // ה-AnimatedButton מטפל ב-onPressed
                icon: const Icon(Icons.refresh, size: kIconSizeSmall),
                label: const Text('נסה שוב'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.errorContainer,
                  foregroundColor: cs.onErrorContainer,
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSpacingMedium,
                    vertical: kSpacingSmallPlus,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Empty State
  /// בנייה של Empty State כרטיס
  ///
  /// תצוגה:
  /// - כותרת עם אייקון
  /// - אייקון מרכזי (lightbulb_outline) - רעיון/המלצה
  /// - כותרת: "אין המלצות זמינות"
  /// - הסבר: "צור רשימות קניות וסרוק קבלות..."
  /// - 2 כפתורי CTA עם אנימציות:
  ///   1. "צור רשימה" (ראשי) - מקום צבע primaryContainer
  ///   2. "סרוק קבלה" (משני) - outlined
  ///
  /// CTA:
  /// - כל כפתור עטוף ב-_AnimatedButton (scale 0.95)
  /// - ניווט דרך Navigator.pushNamed()
  /// - פעולה תלויה בכפתור
  ///
  /// [context] - BuildContext
  /// Returns: Card widget עם empty UI + CTAs
  Widget _buildEmptyCard(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // כותרת
            Row(
              children: [
                Icon(Icons.auto_awesome_outlined, color: cs.outline),
                const SizedBox(width: kSpacingSmall),
                Text(
                  'המלצות חכמות',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: kSpacingMedium),

            // אייקון מרכזי
            Container(
              padding: const EdgeInsets.all(kSpacingMedium),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lightbulb_outline,
                size: kSpacingLarge * 2,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: kSpacingMedium),

            // כותרת משנה
            Text(
              'אין המלצות זמינות',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: kSpacingSmall),

            // הסבר מפורט
            Text(
              'צור רשימות קניות וסרוק קבלות\nכדי לקבל המלצות מותאמות אישית',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingMedium + kSpacingSmall),

            // 🆕 כפתורי CTA עם אנימציה
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // כפתור ראשי
                _AnimatedButton(
                  onPressed: () => _showCreateListDialog(context),
                  child: ElevatedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.add, size: kIconSizeSmall),
                    label: const Text('צור רשימה'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primaryContainer,
                      foregroundColor: cs.onPrimaryContainer,
                      padding: const EdgeInsets.symmetric(
                        horizontal: kSpacingMedium,
                        vertical: kSpacingSmallPlus,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: kSpacingSmall),

                // כפתור משני
                _AnimatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/receipts');
                  },
                  child: OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.receipt_long, size: kIconSizeSmall),
                    label: const Text('סרוק קבלה'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kSpacingMedium,
                        vertical: kSpacingSmallPlus,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 4. Content State - 🆕 עם List Animations
  /// בנייה של Content State כרטיס (יש המלצות)
  ///
  /// תצוגה:
  /// - כותרת עם אייקון (auto_awesome)
  /// - Chip "+X נוספות" (אם יותר מ-3 המלצות)
  /// - רשימה של 3 המלצות עליונות עם אנימציות:
  ///   - Slide + Fade effect (stagger 100ms בין איזה)
  ///   - _AnimatedSuggestionItem widgets
  /// - כפתור "צפה בכל ההמלצות" (אם יותר מ-3)
  ///
  /// אנימציות:
  /// - כל item נכנס עם delay: index * 100ms
  /// - Slide from (0, 0.1) to (0, 0)
  /// - Fade from 0.0 to 1.0
  /// - Duration: 300ms + easeOut
  ///
  /// [context] - BuildContext
  /// [suggestions] - רשימת ההמלצות
  /// Returns: Card widget עם 3 המלצות יותר + info
  Widget _buildContentCard(BuildContext context, List<Suggestion> suggestions) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final topSuggestions = suggestions.take(3).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // כותרת
            Row(
              children: [
                Icon(Icons.auto_awesome, color: cs.primary),
                const SizedBox(width: kSpacingSmall),
                Text(
                  'המלצות חכמות',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (suggestions.length > 3)
                  Chip(
                    label: Text(
                      '+${suggestions.length - 3} נוספות',
                      style: theme.textTheme.labelSmall,
                    ),
                    backgroundColor: cs.secondaryContainer,
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: kSpacingMedium),

            // 🆕 רשימת 3 ההמלצות עם אנימציות
            ...topSuggestions.asMap().entries.map((entry) {
              final index = entry.key;
              final suggestion = entry.value;
              
              return _AnimatedSuggestionItem(
                key: ValueKey(suggestion.id),
                index: index,
                suggestion: suggestion,
                onAdd: () => _handleAddToList(context, suggestion),
                onRemove: () => _handleRemove(context, suggestion.id),
              );
            }),

            // כפתור לכל ההמלצות
            if (suggestions.length > 3) ...[
              const SizedBox(height: kSpacingSmall),
              Center(
                child: _AnimatedButton(
                  onPressed: () {
                    _showAnimatedSnackBar(
                      context,
                      message: 'מסך המלצות מלא יתווסף בקרוב',
                      icon: Icons.info_outline,
                      backgroundColor: Colors.blue,
                    );
                  },
                  child: TextButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('צפה בכל ההמלצות'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 🆕 SKELETON WIDGETS
// ═══════════════════════════════════════════════════════════════

class _SkeletonBox extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool isDark;

  const _SkeletonBox({
    this.width,
    this.height,
    this.borderRadius,
    required this.isDark,
  });

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.isDark
                ? Colors.grey[700]!.withValues(alpha: _animation.value)
                : Colors.grey[300]!.withValues(alpha: _animation.value),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(kBorderRadius),
          ),
        );
      },
    );
  }
}

class _SuggestionItemSkeleton extends StatelessWidget {
  final bool isDark;

  const _SuggestionItemSkeleton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(kSpacingSmall),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Row(
        children: [
          // אייקון
          _SkeletonBox(
            width: 40,
            height: 40,
            borderRadius: BorderRadius.circular(20),
            isDark: isDark,
          ),
          const SizedBox(width: kSpacingSmall),

          // טקסט
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(
                  width: double.infinity,
                  height: 16,
                  isDark: isDark,
                ),
                const SizedBox(height: 6),
                _SkeletonBox(
                  width: 80,
                  height: 12,
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // כפתורים
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SkeletonBox(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(20),
                isDark: isDark,
              ),
              const SizedBox(width: 4),
              _SkeletonBox(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(20),
                isDark: isDark,
              ),
            ],
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

// 2. Animated Suggestion Item - Slide + Fade
class _AnimatedSuggestionItem extends StatefulWidget {
  final int index;
  final Suggestion suggestion;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _AnimatedSuggestionItem({
    super.key,
    required this.index,
    required this.suggestion,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<_AnimatedSuggestionItem> createState() => _AnimatedSuggestionItemState();
}

class _AnimatedSuggestionItemState extends State<_AnimatedSuggestionItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
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

    // Start animation with delay based on index
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: kSpacingSmall),
          padding: const EdgeInsets.all(kSpacingSmall),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
          child: Row(
            children: [
              // אייקון
              Container(
                padding: const EdgeInsets.all(kSpacingSmall),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_basket_outlined,
                  size: kIconSizeSmall,
                  color: cs.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: kSpacingSmall),

              // פרטי המלצה
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.suggestion.productName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'כמות מוצעת: ${widget.suggestion.suggestedQuantity}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // כפתורי פעולה עם אנימציה
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // כפתור הוספה
                  _AnimatedIconButton(
                    icon: Icons.add_circle_outline,
                    color: cs.primary,
                    onPressed: widget.onAdd,
                    tooltip: 'הוסף לרשימה',
                  ),
                  // כפתור הסרה
                  _AnimatedIconButton(
                    icon: Icons.close,
                    color: cs.error,
                    onPressed: widget.onRemove,
                    tooltip: 'הסר המלצה',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 3. Animated Icon Button
class _AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;

  const _AnimatedIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
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
          icon: Icon(
            widget.icon,
            size: widget.icon == Icons.close ? kIconSizeSmall : kIconSizeMedium,
          ),
          color: widget.color,
          onPressed: null, // ה-GestureDetector מטפל ב-onPressed
          tooltip: widget.tooltip,
          constraints: const BoxConstraints(
            minWidth: kMinTouchTarget,
            minHeight: kMinTouchTarget,
          ),
        ),
      ),
    );
  }
}
