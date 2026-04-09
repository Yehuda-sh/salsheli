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

import '../../../../config/list_types_config.dart';
import 'package:provider/provider.dart';

import '../../../../core/ui_constants.dart';
import '../../../../theme/app_theme.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../models/enums/suggestion_status.dart';
import '../../../../models/shopping_list.dart';
import '../../../../models/smart_suggestion.dart';
import '../../../../providers/shopping_lists_provider.dart';
import '../../../../providers/suggestions_provider.dart';
import '../../../../core/error_utils.dart';

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
    final brand = theme.extension<AppBrand>();

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: (brand?.stickyYellow ?? kStickyYellow).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: kIconSizeSmallPlus,
              height: kIconSizeSmallPlus,
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
/// מנקה שם מוצר להצגה בפתקית:
/// - מסיר מספרים בסוף (כמו "1.33ל")
/// - מסיר סימני % צמודים למילים
/// - מקצר ל-25 תווים מקסימום
String _cleanProductName(String name) {
  // הסר רווחים מיותרים
  var clean = name.trim().replaceAll(RegExp(r'\s+'), ' ');

  // הסר גדלים/נפחים בסוף (כמו "1 ל", "1.33ל", "500 מל", "750 מל", "1000 גרם")
  clean = clean.replaceAll(RegExp(r'\s*\d+\.?\d*\s*(ל|מ"ל|מל|גרם|ג|ק"ג|קג|יח|מיליליטר)\s*$'), '');

  // הסר מילים אנגליות בודדות בסוף (כמו "selected", "classic", "X")
  clean = clean.replaceAll(RegExp(r'\s+[a-zA-Z]{1,15}\s*$'), '');

  // הסר סוגריים עם תוכן אנגלי
  clean = clean.replaceAll(RegExp(r'\s*\([a-zA-Z\s]+\)\s*$'), '');

  // הסר מספרים בודדים שנשארו בסוף (כמו "1", "500")
  clean = clean.replaceAll(RegExp(r'\s+\d+\.?\d*\s*$'), '');

  // לא מקצרים ידנית — maxLines+ellipsis ב-Text widget מטפל
  return clean.trim();
}

class _SuggestionsCarousel extends StatefulWidget {
  final List<SmartSuggestion> suggestions;

  const _SuggestionsCarousel({required this.suggestions});

  @override
  State<_SuggestionsCarousel> createState() => _SuggestionsCarouselState();
}

class _SuggestionsCarouselState extends State<_SuggestionsCarousel> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // כותרת: ממורכזת עם הוסף הכל בשורה מתחת
        Padding(
          padding: const EdgeInsets.only(bottom: kSpacingSmall),
          child: Column(
            children: [
              // שורה ראשית — ממורכזת, עם רקע paper לקריאות על קווי מחברת
              Container(
                padding: const EdgeInsets.symmetric(horizontal: kSpacingSmallPlus, vertical: kSpacingXTiny),
                decoration: BoxDecoration(
                  color: brand?.paperBackground?.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: kIconSizeSmallPlus, color: cs.onSurfaceVariant),
                    const SizedBox(width: kSpacingSmall),
                    Text(
                      AppStrings.suggestionsToday.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: kSpacingXTiny),
                    Text(
                      '${widget.suggestions.length}',
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.outline),
                    ),
                    const SizedBox(width: kSpacingSmallPlus),
                    _AddAllButton(suggestions: widget.suggestions),
                  ],
                ),
              ),
            ],
          ),
        ),

        // קרוסלה אופקית
        SizedBox(
          height: 165,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                final page = (notification.metrics.pixels / 180).round();
                if (page != _currentPage && page >= 0 && page < widget.suggestions.length) {
                  setState(() => _currentPage = page);
                }
              }
              return false;
            },
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.suggestions.length,
              itemBuilder: (context, index) {
                // סיבוב אקראי קטן לכל כרטיס
                final rotation = (index.isEven ? 1 : -1) * 0.02;
                return RepaintBoundary(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 0 : kSpacingSmall,
                      right: index == widget.suggestions.length - 1 ? 0 : 0,
                    ),
                    child: _StickyNoteCard(
                      suggestion: widget.suggestions[index],
                      rotation: rotation,
                      index: index,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Dot indicator (רק אם יש יותר מ-2 כרטיסים)
        if (widget.suggestions.length > 2)
          Padding(
            padding: const EdgeInsets.only(top: kSpacingSmall),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.suggestions.length, (i) {
                final isActive = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? cs.primary.withValues(alpha: 0.7)
                        : cs.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
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

  Color _getCardColor(String urgency, AppBrand? brand) {
    // ⚠️ Grey for unknown status
    if (_isUnknownStatus) return Theme.of(context).colorScheme.outline;

    switch (urgency) {
      case 'critical':
        return brand?.stickyPink ?? kStickyPink;
      case 'high':
        return brand?.stickyOrange ?? kStickyOrange;
      case 'medium':
        return brand?.stickyYellow ?? kStickyYellow;
      default:
        return brand?.stickyGreen ?? kStickyGreen;
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
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();
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
            backgroundColor: brand?.stickyOrange ?? kStickyOrange,
          ),
        );
        return;
      }

      // אם יש יותר מרשימה אחת — dialog בחירה
      ShoppingList targetList;
      if (activeLists.length == 1) {
        targetList = activeLists.first;
      } else {
        final chosen = await showModalBottomSheet<ShoppingList>(
          context: context,
          backgroundColor: cs.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(kBorderRadiusLarge)),
          ),
          isScrollControlled: true,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(kSpacingMedium),
                  child: Text(
                    AppStrings.suggestionsToday.chooseListTitle,
                    style: Theme.of(ctx).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: activeLists.map((l) => ListTile(
                      leading: Icon(ListTypes.getByKeySafe(l.type).icon, color: ListTypes.getColor(l.type, cs, brand)),
                      title: Text(l.name),
                      subtitle: Text(AppStrings.suggestionsToday.itemCount(l.items.length)),
                      onTap: () => Navigator.pop(ctx, l),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: kSpacingSmall),
              ],
            ),
          ),
        );
        if (chosen == null || !mounted) return;
        targetList = chosen;
      }
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
              Icon(Icons.check_circle, color: cs.onPrimary, size: kIconSizeSmallPlus),
              const SizedBox(width: kSpacingSmall),
              Expanded(
                child: Text(AppStrings.suggestionsToday.addedToListName(widget.suggestion.productName)),
              ),
            ],
          ),
          backgroundColor: brand?.stickyGreen ?? kStickyGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(userFriendlyError(e, context: 'suggestion')),
          backgroundColor: brand?.stickyPink ?? kStickyPink,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _onDismiss(BuildContext context) async {
    final brand = Theme.of(context).extension<AppBrand>();
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
          backgroundColor: brand?.stickyCyan ?? kStickyCyan,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(userFriendlyError(e, context: 'suggestion')),
          backgroundColor: brand?.stickyPink ?? kStickyPink,
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
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final brand = theme.extension<AppBrand>();
    final suggestion = widget.suggestion;
    final cardColor = _getCardColor(suggestion.urgency, brand);
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
                cs.surface.withValues(alpha: 0.06),
                cardColor,
              ),
              Color.alphaBlend(
                cs.scrim.withValues(alpha: 0.03),
                cardColor,
              ),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
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
                  color: cs.surface.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(kBorderRadiusSmall),
                  ),
                ),
              ),
            ),

            // תוכן הכרטיס
            Padding(
              padding: const EdgeInsets.fromLTRB(kSpacingSmallPlus, 20, kSpacingSmallPlus, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge דחיפות
                  Row(
                    children: [
                      Icon(
                        _getUrgencyIcon(suggestion.urgency),
                        size: 14,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: kSpacingXTiny),
                      Text(
                        _getUrgencyText(suggestion.urgency),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                          fontSize: kFontSizeTiny,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: kSpacingSmall),

                  // שם המוצר — מנקה, פונט קטן יותר, 3 שורות
                  Expanded(
                    child: Text(
                      _cleanProductName(suggestion.productName),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                        height: 1.25,
                        fontSize: kFontSizeSmall,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // כמות במלאי
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kSpacingSmall,
                      vertical: kSpacingXTiny,
                    ),
                    decoration: BoxDecoration(
                      color: cs.scrim.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                    child: Text(
                      AppStrings.suggestionsToday.inStock(suggestion.currentStock, suggestion.unit),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: kSpacingSmall + 2),

                  // ⚠️ Warning for unknown status
                  if (_isUnknownStatus) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: kSpacingTiny, vertical: 3),
                      decoration: BoxDecoration(
                        color: cs.tertiary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, size: 10, color: cs.onSurface.withValues(alpha: 0.6)),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              AppStrings.inventory.unknownSuggestionUpdateApp,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: kFontSizeTiny,
                                color: cs.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: kSpacingTiny),
                  ],

                  // כפתורי פעולה — שורה מסודרת: X | + הוסף
                  if (_isProcessing)
                    Center(
                      child: SizedBox(
                        width: kIconSizeSmallPlus,
                        height: kIconSizeSmallPlus,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        // כפתור X (dismiss) — עיגול קטן בצד
                        if (!_isUnknownStatus)
                          GestureDetector(
                            onTap: () => _onDismiss(context),
                            child: Container(
                              width: kIconSizeLarge,
                              height: kIconSizeLarge,
                              decoration: BoxDecoration(
                                color: cs.scrim.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: kFontSizeMedium,
                                color: cs.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        const SizedBox(width: kSpacingSmall),
                        // כפתור הוסף — ממלא את השאר
                        Expanded(
                          child: Material(
                            color: cs.scrim.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                            child: InkWell(
                              onTap: () => _onAdd(context),
                              borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: kSpacingTiny),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add, size: kFontSizeMedium, color: cs.onSurface),
                                    const SizedBox(width: kSpacingXTiny),
                                    Text(
                                      AppStrings.suggestionsToday.addButton,
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        color: cs.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
<<<<<<< HEAD
                        const SizedBox(width: kSpacingTiny),
                        // כפתור X - disabled for unknown
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

/// כפתור "הוסף הכל" — מוסיף את כל ההצעות לרשימה הפעילה הראשונה
class _AddAllButton extends StatefulWidget {
  final List<SmartSuggestion> suggestions;
  const _AddAllButton({required this.suggestions});

  @override
  State<_AddAllButton> createState() => _AddAllButtonState();
}

class _AddAllButtonState extends State<_AddAllButton> {
  bool _isAdding = false;

  Future<void> _addAll() async {
    if (_isAdding) return;
    setState(() => _isAdding = true);

    final listsProvider = context.read<ShoppingListsProvider>();
    final suggestionsProvider = context.read<SuggestionsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final brand = Theme.of(context).extension<AppBrand>();

    final activeLists = listsProvider.lists.where((l) => l.status == ShoppingList.statusActive).toList();
    if (activeLists.isEmpty) {
      messenger.showSnackBar(SnackBar(
        content: Text(AppStrings.suggestionsToday.noActiveLists),
      ));
      if (mounted) setState(() => _isAdding = false);
      return;
    }

    final targetList = activeLists.first;
    int added = 0;

    for (final suggestion in widget.suggestions) {
      try {
        final item = suggestion.toUnifiedListItem();
        await listsProvider.addUnifiedItem(targetList.id, item);
        await suggestionsProvider.addSuggestionById(suggestion.id, targetList.id);
        added++;
      } catch (_) {
        // Skip failed items
      }
    }

    if (!mounted) return;
    setState(() => _isAdding = false);

    unawaited(HapticFeedback.mediumImpact());
    messenger.showSnackBar(SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle, color: Theme.of(context).colorScheme.onPrimary, size: kIconSizeSmall + 2),
          const SizedBox(width: kSpacingSmall),
          Text(AppStrings.suggestionsToday.addedAll(added, targetList.name)),
        ],
      ),
      backgroundColor: brand?.stickyGreen ?? kStickyGreen,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<AppBrand>();

    return SizedBox(
      height: 28,
      child: TextButton.icon(
        onPressed: _isAdding ? null : _addAll,
        icon: _isAdding
            ? const SizedBox(
                width: 14, height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.playlist_add, size: kIconSizeSmall),
        label: Text(
          AppStrings.suggestionsToday.addAll,
          style: const TextStyle(fontSize: kFontSizeTiny),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
          foregroundColor: brand?.stickyOrange ?? kStickyOrange,
        ),
      ),
    );
  }
}
