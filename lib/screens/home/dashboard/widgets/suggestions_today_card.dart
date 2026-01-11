// 📄 lib/screens/home/dashboard/widgets/suggestions_today_card.dart
//
// כרטיס "הצעות מהמזווה" - קרוסלה אופקית בסגנון Sticky Notes.
// כל כרטיס עם צללים, סיבוב קל, וכפתורי Add/Dismiss.
//
// Version: 3.0 (08/01/2026) - Sticky Notes design
// 🔗 Related: SmartSuggestion, SuggestionsProvider, StickyNote

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/ui_constants.dart';
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
              'טוען הצעות...',
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
        // כותרת עם אייקון מזווה
        Padding(
          padding: const EdgeInsets.only(bottom: kSpacingSmall),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: kStickyOrange.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 18,
                  color: Color(0xFFE65100),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'הצעות מהמזווה',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Badge עם מספר
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
                  '${suggestions.length} פריטים',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFFE65100),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
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
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : kSpacingSmall,
                  right: index == suggestions.length - 1 ? 0 : 0,
                ),
                child: _StickyNoteCard(
                  suggestion: suggestions[index],
                  rotation: rotation,
                  index: index,
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

  Color _getCardColor(String urgency) {
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
    switch (urgency) {
      case 'critical':
        return 'נגמר!';
      case 'high':
        return 'כמעט נגמר';
      case 'medium':
        return 'מתמעט';
      default:
        return 'מומלץ';
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
          const SnackBar(
            content: Text('אין רשימות פעילות - צור רשימה חדשה'),
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

      await HapticFeedback.mediumImpact();
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('נוסף "${widget.suggestion.productName}" לרשימה'),
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

      await HapticFeedback.lightImpact();
      messenger.showSnackBar(
        SnackBar(
          content: Text('דחיתי "${widget.suggestion.productName}" לשבוע'),
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

    return Transform.rotate(
      angle: widget.rotation,
      child: Container(
        width: 145,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            // צל ראשי - אפקט הדבקה
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
            // צל משני - עומק
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
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
                      'במלאי: ${suggestion.currentStock} ${suggestion.unit}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

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
                        // כפתור הוסף
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
                                      'הוסף',
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
                        // כפתור X
                        Material(
                          color: Colors.black.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () => _onDismiss(context),
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.black45,
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
    )
        .animate(delay: Duration(milliseconds: 100 * widget.index))
        .fadeIn(duration: const Duration(milliseconds: 300))
        .slideX(
          begin: 0.2,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
  }
}
