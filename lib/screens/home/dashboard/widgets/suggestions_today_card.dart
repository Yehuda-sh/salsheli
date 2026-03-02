// 📄 lib/screens/home/dashboard/widgets/suggestions_today_card.dart
//
// כרטיס "הצעות מהמזווה" - קרוסלה אופקית בסגנון Sticky Notes.
// כל כרטיס עם צללים, סיבוב קל, וכפתורי Add/Dismiss.
// ✨ v4.0: עיצוב כותרת Highlighter, משוב Haptic דינמי (Add vs Dismiss),
//          אפקט 'הרמה' (Lift) בלחיצה על פתקית, אופטימיזציה עם RepaintBoundary
//
// Version: 4.0 (22/02/2026)
// 🔗 Related: SmartSuggestion, SuggestionsProvider, StickyNote

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/ui_constants.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../models/enums/suggestion_status.dart';
import '../../../../models/shopping_list.dart';
import '../../../../models/smart_suggestion.dart';
import '../../../../providers/shopping_lists_provider.dart';
import '../../../../providers/suggestions_provider.dart';

/// כרטיס הצעות מהמזווה - קרוסלה אופקית בסגנון Sticky Notes
class SuggestionsTodayCard extends StatelessWidget {
  const SuggestionsTodayCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SuggestionsProvider>(
      builder: (context, provider, child) {
        // Loading state
        if (provider.isLoading) {
          return const _LoadingState();
        }

        // Get active suggestions (max 3)
        final suggestions = provider.suggestions
            .where((s) => s.isActive)
            .take(3)
            .toList();

        // Empty state - don't show card
        if (suggestions.isEmpty) {
          return const SizedBox.shrink();
        }

        return _SuggestionsCarousel(suggestions: suggestions);
      },
    );
  }
}

/// Loading state
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: kStickyYellow.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: kSpacingSmall),
            Text(
              AppStrings.suggestionsToday.loading,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// קרוסלת הצעות אופקית בסגנון Sticky Notes
class _SuggestionsCarousel extends StatelessWidget {
  final List<SmartSuggestion> suggestions;

  const _SuggestionsCarousel({required this.suggestions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // כותרת Highlighter style (v4.0)
        Padding(
          padding: const EdgeInsets.only(bottom: kSpacingSmall),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: kStickyOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: const BorderDirectional(
                start: BorderSide(
                  color: kStickyOrangeDark,
                  width: 4,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: kStickyOrange.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                    color: kStickyOrangeDark,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  AppStrings.suggestionsToday.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Badge עם shimmer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kStickyOrange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: kStickyOrange.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    AppStrings.suggestionsToday.itemCount(suggestions.length),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: kStickyOrangeDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shimmer(
                      delay: 3000.ms,
                      duration: 1000.ms,
                      color: kStickyOrange.withValues(alpha: 0.3),
                    ),
              ],
            ),
          ),
        ),

        // קרוסלה אופקית
        SizedBox(
          height: 165,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              // סיבוב אקראי קטן לכל כרטיס
              final rotation = (index.isEven ? 1 : -1) * 0.02;
              return RepaintBoundary(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : kSpacingSmall,
                    right: index == suggestions.length - 1 ? 0 : 0,
                  ),
                  child: _StickyNoteCard(
                    suggestion: suggestions[index],
                    rotation: rotation,
                    index: index,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// כרטיס הצעה בודד בסגנון Sticky Note
class _StickyNoteCard extends StatefulWidget {
  final SmartSuggestion suggestion;
  final double rotation;
  final int index;

  const _StickyNoteCard({
    required this.suggestion,
    required this.rotation,
    required this.index,
  });

  @override
  State<_StickyNoteCard> createState() => _StickyNoteCardState();
}

class _StickyNoteCardState extends State<_StickyNoteCard> {
  bool _isProcessing = false;
  bool _isPressed = false;

  /// Check if suggestion has unknown status
  bool get _isUnknownStatus =>
      widget.suggestion.status == SuggestionStatus.unknown;

  Color _getCardColor(String urgency) {
    // ⚠️ Grey for unknown status
    if (_isUnknownStatus) return Colors.grey.shade400;

    switch (urgency) {
      case 'critical':
        return kStickyPink;
      case 'high':
        return kStickyOrange;
      case 'medium':
        return kStickyYellow;
      default:
        return kStickyGreen;
    }
  }

  String _getUrgencyText(String urgency) {
    final strings = AppStrings.suggestionsToday;
    switch (urgency) {
      case 'critical':
        return strings.urgencyCritical;
      case 'high':
        return strings.urgencyHigh;
      case 'medium':
        return strings.urgencyMedium;
      default:
        return strings.urgencyLow;
    }
  }

  IconData _getUrgencyIcon(String urgency) {
    switch (urgency) {
      case 'critical':
        return Icons.error;
      case 'high':
        return Icons.warning_amber;
      case 'medium':
        return Icons.info_outline;
      default:
        return Icons.lightbulb_outline;
    }
  }

  Future<void> _onAdd(BuildContext context) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    final messenger = ScaffoldMessenger.of(context);
    final listsProvider = context.read<ShoppingListsProvider>();
    final suggestionsProvider = context.read<SuggestionsProvider>();

    try {
      final activeLists = listsProvider.lists
          .where((l) => l.status == ShoppingList.statusActive)
          .toList();

      if (activeLists.isEmpty) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(AppStrings.suggestionsToday.noActiveLists),
            backgroundColor: kStickyOrange,
          ),
        );
        return;
      }

      final targetList = activeLists.first;
      final item = widget.suggestion.toUnifiedListItem();

      await listsProvider.addUnifiedItem(targetList.id, item);
      await suggestionsProvider.addSuggestionById(
        widget.suggestion.id,
        targetList.id,
      );

      if (!mounted) return;

      unawaited(HapticFeedback.mediumImpact());
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(AppStrings.suggestionsToday.addedToList(widget.suggestion.productName)),
              ),
            ],
          ),
          backgroundColor: kStickyGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('שגיאה: $e'),
          backgroundColor: kStickyPink,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _onDismiss(BuildContext context) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    final messenger = ScaffoldMessenger.of(context);
    final suggestionsProvider = context.read<SuggestionsProvider>();

    try {
      await suggestionsProvider.dismissSuggestionById(widget.suggestion.id);

      if (!mounted) return;

      unawaited(HapticFeedback.selectionClick());
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppStrings.suggestionsToday.dismissedForWeek(widget.suggestion.productName)),
          backgroundColor: kStickyCyan,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('שגיאה: $e'),
          backgroundColor: kStickyPink,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suggestion = widget.suggestion;
    final cardColor = _getCardColor(suggestion.urgency);
    final shadowColor = theme.shadowColor;

    final result = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Transform.rotate(
      angle: widget.rotation,
      child: Container(
        width: 145,
        decoration: BoxDecoration(
          // טקסטורת נייר: gradient עדין לתחושת קיפול
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardColor,
              Color.alphaBlend(
                Colors.white.withValues(alpha: 0.06),
                cardColor,
              ),
              Color.alphaBlend(
                Colors.black.withValues(alpha: 0.03),
                cardColor,
              ),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            // צל ראשי - משתנה בלחיצה
            BoxShadow(
              color: shadowColor.withValues(alpha: _isPressed ? 0.1 : 0.2),
              blurRadius: _isPressed ? 4 : 8,
              offset: _isPressed ? const Offset(1, 2) : const Offset(2, 4),
            ),
            // צל משני - עומק
            BoxShadow(
              color: shadowColor.withValues(alpha: _isPressed ? 0.05 : 0.1),
              blurRadius: _isPressed ? 2 : 4,
              offset: _isPressed ? const Offset(0, 1) : const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // "סרט הדבקה" למעלה
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 14,
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(2),
                  ),
                ),
              ),
            ),

            // תוכן הכרטיס
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 20, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge דחיפות
                  Row(
                    children: [
                      Icon(
                        _getUrgencyIcon(suggestion.urgency),
                        size: 14,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getUrgencyText(suggestion.urgency),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // שם המוצר
                  Expanded(
                    child: Text(
                      suggestion.productName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // כמות במלאי
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      AppStrings.suggestionsToday.inStock(suggestion.currentStock, suggestion.unit),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ⚠️ Warning for unknown status
                  if (_isUnknownStatus) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber, size: 10, color: Colors.black54),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              AppStrings.inventory.unknownSuggestionUpdateApp,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 9,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],

                  // כפתורי פעולה
                  if (_isProcessing)
                    const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black54,
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        // כפתור הוסף (always enabled - safe operation)
                        Expanded(
                          child: Material(
                            color: Colors.black.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: () => _onAdd(context),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add,
                                      size: 16,
                                      color: Colors.black87,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppStrings.suggestionsToday.addButton,
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // כפתור X - disabled for unknown
                        Material(
                          color: Colors.black.withValues(alpha: _isUnknownStatus ? 0.03 : 0.06),
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: _isUnknownStatus ? null : () => _onDismiss(context),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: _isUnknownStatus ? Colors.black26 : Colors.black45,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    ),
    );

    // אנימציות כניסה מדורגות עם Curve יוקרתי
    Widget animated = result
        .animate(delay: Duration(milliseconds: 100 * widget.index))
        .fadeIn(duration: 350.ms, curve: Curves.easeOutBack)
        .slideX(
          begin: 0.2,
          curve: Curves.easeOutBack,
          duration: 350.ms,
        );

    // Shake עדין לפתקיות critical — פעם ב-5 שניות
    if (suggestion.urgency == 'critical') {
      animated = animated
          .animate(
            onPlay: (c) => c.repeat(),
          )
          .shake(
            delay: 5000.ms,
            duration: 500.ms,
            hz: 3,
            rotation: 0.008,
          );
    }

    return animated;
  }
}
