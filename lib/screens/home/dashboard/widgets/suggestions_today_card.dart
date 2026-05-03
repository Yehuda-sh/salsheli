// lib/screens/home/dashboard/widgets/suggestions_today_card.dart — Suggestions carousel — sticky-note cards with pantry restock recommendations

import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../config/list_types_config.dart';
import '../../../../core/error_utils.dart';
import '../../../../core/ui_constants.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../models/enums/suggestion_status.dart';
import '../../../../models/shopping_list.dart';
import '../../../../models/smart_suggestion.dart';
import '../../../../providers/shopping_lists_provider.dart';
import '../../../../providers/suggestions_provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/common/product_thumbnail.dart';

// Carousel layout — keep page-index math and ListView in sync.
const double _kCarouselHeight = 200.0;
const double _kCardWidth = 170.0;
const double _kCardGap = kSpacingSmall;
const double _kCardItemExtent = _kCardWidth + _kCardGap; // 178
const double _kCardRotation = 0.02;
const double _kTapeHeight = 18.0;
const double _kTapeHorizontalMargin = 30.0;

// Dot indicator dimensions — active is wider to read as "current page".
const double _kDotActiveWidth = 16.0;
const double _kDotInactiveWidth = 6.0;
const double _kDotHeight = 6.0;
const double _kDotMarginH = 3.0;

// Sticky-note ink — alphas tuned as a unit for "paper + ink" appearance.
// 0.6 (subtle text), 0.08 (scrim shadow), 0.18 / 0.4 (error tints), 0.03 / 0.06
// (gradient overlays) are intentionally distinct from kOpacity* and kept inline
// where each appears, since they're tuned together with the gradient + shadow.

// Pre-compiled regexes for product name cleanup — avoids re-parsing on
// every card build.
final RegExp _kReWhitespace = RegExp(r'\s+');
final RegExp _kReSizeSuffix =
    RegExp(r'\s*\d+\.?\d*\s*(ל|מ"ל|מל|גרם|ג|ק"ג|קג|יח|מיליליטר)\s*$');
final RegExp _kReEnglishSuffix = RegExp(r'\s+[a-zA-Z]{1,15}\s*$');
final RegExp _kReEnglishParens = RegExp(r'\s*\([a-zA-Z\s]+\)\s*$');
final RegExp _kReNumberSuffix = RegExp(r'\s+\d+\.?\d*\s*$');

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

    return Semantics(
      label: AppStrings.suggestionsToday.loading,
      liveRegion: true,
      child: Container(
        // Match the loaded carousel height so the layout doesn't jump when
        // suggestions arrive.
        height: _kCarouselHeight,
        decoration: BoxDecoration(
          color: (brand?.stickyYellow ?? kStickyYellow).withValues(alpha: kOpacityLight),
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
      ),
    );
  }
}

/// קרוסלת הצעות אופקית בסגנון Sticky Notes
/// מנקה שם מוצר להצגה בפתקית:
/// - מסיר מספרים בסוף (כמו "1.33ל")
/// - מסיר סימני % צמודים למילים
/// - מסיר מילים כפולות עוקבות (כמו "דג דג" → "דג")
String _cleanProductName(String name) {
  // הסר רווחים מיותרים
  var clean = name.trim().replaceAll(_kReWhitespace, ' ');

  // הסר גדלים/נפחים בסוף (כמו "1 ל", "1.33ל", "500 מל", "750 מל", "1000 גרם")
  clean = clean.replaceAll(_kReSizeSuffix, '');

  // הסר מילים אנגליות בודדות בסוף (כמו "selected", "classic", "X")
  clean = clean.replaceAll(_kReEnglishSuffix, '');

  // הסר סוגריים עם תוכן אנגלי
  clean = clean.replaceAll(_kReEnglishParens, '');

  // הסר מספרים בודדים שנשארו בסוף (כמו "1", "500")
  clean = clean.replaceAll(_kReNumberSuffix, '');

  // הסר מילים כפולות עוקבות (כמו "דג דג" → "דג", "טבעי טבעי" → "טבעי")
  // משתמשים ב-split/dedupe במקום regex בגלל תמיכה ב-Unicode/עברית
  final words = clean.split(' ');
  final deduped = <String>[];
  for (final word in words) {
    if (word.isEmpty) continue;
    if (deduped.isEmpty || deduped.last != word) {
      deduped.add(word);
    }
  }
  clean = deduped.join(' ');

  // לא מקצרים ידנית — maxLines+ellipsis ב-Text widget מטפל
  return fixBidiNumbers(clean.trim());
}

/// Shared "which list?" picker — used by single-add and add-all flows so
/// they show the same UI (icon + name + item count). Returns null if the
/// user dismisses the sheet.
Future<ShoppingList?> _chooseTargetList(
  BuildContext context,
  List<ShoppingList> activeLists,
) {
  final cs = Theme.of(context).colorScheme;
  final brand = Theme.of(context).extension<AppBrand>();
  return showModalBottomSheet<ShoppingList>(
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
              children: activeLists
                  .map((l) => ListTile(
                        leading: Icon(
                          ListTypes.getByKeySafe(l.type).icon,
                          color: ListTypes.getColor(l.type, cs, brand),
                        ),
                        title: Text(l.name),
                        subtitle: Text(AppStrings.suggestionsToday.itemCount(l.items.length)),
                        onTap: () => Navigator.pop(ctx, l),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: kSpacingSmall),
        ],
      ),
    ),
  );
}

class _SuggestionsCarousel extends StatefulWidget {
  final List<SmartSuggestion> suggestions;

  const _SuggestionsCarousel({required this.suggestions});

  @override
  State<_SuggestionsCarousel> createState() => _SuggestionsCarouselState();
}

class _SuggestionsCarouselState extends State<_SuggestionsCarousel> {
  // ValueNotifier so dot updates don't rebuild the whole carousel on every
  // scroll frame.
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);

  @override
  void dispose() {
    _currentPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // כותרת: ממורכזת, עם רקע paper לקריאות על קווי מחברת
        Padding(
          padding: const EdgeInsets.only(bottom: kSpacingSmall),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: kSpacingSmallPlus, vertical: kSpacingXTiny),
              decoration: BoxDecoration(
                color: brand?.paperBackground.withValues(alpha: kOpacityHigh),
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
                ],
              ),
            ),
          ),
        ),

        // קרוסלה אופקית
        SizedBox(
          height: _kCarouselHeight,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                final page = (notification.metrics.pixels / _kCardItemExtent).round();
                if (page != _currentPage.value && page >= 0 && page < widget.suggestions.length) {
                  _currentPage.value = page;
                }
              }
              return false;
            },
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              physics: const BouncingScrollPhysics(),
              // Fixed width per card — lets Flutter skip per-child layout
              // measurement on scroll. Must match _kCardItemExtent used for
              // the page index calculation above.
              itemExtent: _kCardItemExtent,
              itemCount: widget.suggestions.length,
              itemBuilder: (context, index) {
                // סיבוב אקראי קטן לכל כרטיס — כיוון מתחלף לחיוניות
                final rotation = (index.isEven ? 1 : -1) * _kCardRotation;
                // Symmetric horizontal padding so the page-index math
                // (pixels / _kCardItemExtent) stays accurate from card 0.
                return RepaintBoundary(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _kCardGap / 2),
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
            child: ValueListenableBuilder<int>(
              valueListenable: _currentPage,
              builder: (context, page, _) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.suggestions.length, (i) {
                  final isActive = i == page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: _kDotMarginH),
                    width: isActive ? _kDotActiveWidth : _kDotInactiveWidth,
                    height: _kDotHeight,
                    decoration: BoxDecoration(
                      color: isActive
                          ? cs.primary.withValues(alpha: kOpacityStrong)
                          : cs.outline.withValues(alpha: kOpacityLight),
                      borderRadius: BorderRadius.circular(kBorderRadiusTiny),
                    ),
                  );
                }),
              ),
            ),
          ),

        // "הוסף הכל" — כפתור גדול, רק כשיש שתי הצעות ומעלה
        if (widget.suggestions.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: kSpacingSmall),
            child: _AddAllButton(suggestions: widget.suggestions),
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
  // Pressed-state isolated to AnimatedScale so tap feedback doesn't rebuild
  // the entire card (gradient/shadows/Stack).
  final ValueNotifier<bool> _isPressed = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isPressed.dispose();
    super.dispose();
  }

  /// Check if suggestion has unknown status
  bool get _isUnknownStatus =>
      widget.suggestion.status == SuggestionStatus.unknown;

  /// Card color — a subtle wash of the urgency hue blended onto the
  /// neutral surface tier. Earlier this returned the full sticky-note
  /// color (kStickyPink etc.) which made every "out-of-stock" card scream
  /// like an emergency, even though the user action is just "add to
  /// list". Blending at ~25% with the surface keeps the urgency cue
  /// recognizable while letting the cards read as friendly suggestions.
  Color _getCardColor(String urgency, AppBrand? brand) {
    final cs = Theme.of(context).colorScheme;
    if (_isUnknownStatus) {
      return Color.alphaBlend(
        cs.outline.withValues(alpha: 0.18),
        cs.surfaceContainer,
      );
    }
    final accent = switch (urgency) {
      'critical' => brand?.stickyPink ?? kStickyPink,
      'high' => brand?.stickyOrange ?? kStickyOrange,
      'medium' => brand?.stickyYellow ?? kStickyYellow,
      _ => brand?.stickyGreen ?? kStickyGreen,
    };
    return Color.alphaBlend(
      accent.withValues(alpha: 0.25),
      cs.surfaceContainer,
    );
  }

  String _getUrgencyLabel(String urgency) {
    final s = AppStrings.suggestionsToday;
    switch (urgency) {
      case 'critical':
        return s.urgencyCritical;
      case 'high':
        return s.urgencyHigh;
      case 'medium':
        return s.urgencyMedium;
      default:
        return s.urgencyLow;
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
        messenger
          ..removeCurrentSnackBar()
          ..showSnackBar(
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
        final chosen = await _chooseTargetList(context, activeLists);
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
      messenger
        ..removeCurrentSnackBar()
        ..showSnackBar(
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
      messenger
        ..removeCurrentSnackBar()
        ..showSnackBar(
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
      messenger
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(AppStrings.suggestionsToday.dismissedForWeek(widget.suggestion.productName)),
            backgroundColor: brand?.stickyCyan ?? kStickyCyan,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
    } catch (e) {
      if (!mounted) return;
      messenger
        ..removeCurrentSnackBar()
        ..showSnackBar(
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
    final urgencyLabel = _getUrgencyLabel(suggestion.urgency);
    // Compute once per build — used by the visible name and the card-level
    // Semantics value below.
    final cleanedName = _cleanProductName(suggestion.productName);

    // Static visuals (gradient + shadows + content) — built once per
    // suggestion, not per tap. Only AnimatedScale rebuilds on press.
    final cardVisual = Transform.rotate(
      angle: widget.rotation,
      child: Container(
        width: _kCardWidth,
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
          ),
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: kOpacityLow),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Urgency badge — replaces decorative tape; gives the card a
            // semantic label ("נגמר!"/"כמעט נגמר"/"מתמעט"/"מומלץ").
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ExcludeSemantics(
                child: Container(
                  height: _kTapeHeight,
                  margin: const EdgeInsets.symmetric(horizontal: _kTapeHorizontalMargin),
                  decoration: BoxDecoration(
                    color: cs.surface.withValues(alpha: kOpacityMedium),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(kBorderRadiusSmall),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    urgencyLabel,
                    style: TextStyle(
                      fontSize: kFontSizeTiny,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),

            // תוכן הכרטיס — top padding clears the urgency badge.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                kSpacingSmall,
                _kTapeHeight + kSpacingXTiny,
                kSpacingSmall,
                kSpacingSmallPlus,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // תמונת מוצר
                  Center(
                    child: ProductThumbnail(
                      barcode: suggestion.barcode.isNotEmpty ? suggestion.barcode : null,
                      category: suggestion.category,
                      productName: suggestion.productName,
                      size: kIconSizeXXLarge,
                    ),
                  ),
                  const SizedBox(height: kSpacingSmall),

                  // שם המוצר — מנקה, פונט קטן יותר, 3 שורות
                  Expanded(
                    child: Text(
                      cleanedName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                        height: 1.2,
                        fontSize: kFontSizeSmall,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // כמות במלאי — only when there's actual stock to report.
                  // When the urgency banner already says "נגמר!" the chip
                  // duplicated the same fact in red ("במלאי 0 יח' ⚠️");
                  // dropping it for stock=0 keeps the card calmer while
                  // still showing a useful number for low-but-not-empty.
                  Builder(
                    builder: (context) {
                      if (suggestion.currentStock <= 0) {
                        // No remaining stock — the urgency banner
                        // ("נגמר!") already conveys this, no chip.
                        return const SizedBox.shrink();
                      }
                      return Container(
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
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: kSpacingSmallPlus),

                  // ⚠️ Warning for unknown status
                  if (_isUnknownStatus) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kSpacingTiny,
                        vertical: kSpacingXTiny,
                      ),
                      decoration: BoxDecoration(
                        color: cs.tertiary.withValues(alpha: kOpacityLight),
                        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            size: kFontSizeTiny,
                            color: cs.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: kSpacingXTiny),
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
                        // כפתור X (dismiss) — מסתיר לשבוע
                        if (!_isUnknownStatus)
                          Semantics(
                            button: true,
                            label: AppStrings.suggestionsToday.dismissTooltip,
                            child: InkWell(
                              onTap: () => _onDismiss(context),
                              borderRadius: BorderRadius.circular(kIconSizeLarge / 2),
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
                                  color: cs.onSurface.withValues(alpha: kOpacityMedium),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: kSpacingSmall),
                        // כפתור הוסף — ממלא את השאר
                        Expanded(
                          child: Semantics(
                            button: true,
                            label: AppStrings.suggestionsToday.addButton,
                            child: Material(
                              color: cs.scrim.withValues(alpha: kOpacitySubtle),
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
                        ),
                        const SizedBox(width: kSpacingTiny),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Tap feedback rebuilds only the AnimatedScale subtree.
    final result = Semantics(
      // explicitChildNodes keeps the dismiss/add buttons as their own
      // accessible nodes instead of being merged into this label.
      explicitChildNodes: true,
      label: '$urgencyLabel, $cleanedName',
      value: AppStrings.suggestionsToday.inStock(suggestion.currentStock, suggestion.unit),
      child: GestureDetector(
        onTapDown: (_) => _isPressed.value = true,
        onTapUp: (_) => _isPressed.value = false,
        onTapCancel: () => _isPressed.value = false,
        child: ValueListenableBuilder<bool>(
          valueListenable: _isPressed,
          builder: (context, pressed, child) => AnimatedScale(
            scale: pressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: child,
          ),
          child: cardVisual,
        ),
      ),
    );

    // אנימציות כניסה מדורגות עם Curve יוקרתי
    // Slide direction follows reading direction — same precedent as
    // welcome_screen + onboarding_tips_card.
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    Widget animated = result
        .animate(delay: Duration(milliseconds: 100 * widget.index))
        .fadeIn(duration: 350.ms, curve: Curves.easeOutBack)
        .slideX(
          begin: 0.2 * (isRtl ? -1 : 1),
          curve: Curves.easeOutBack,
          duration: 350.ms,
        );

    // Shake עדין לפתקיות critical — פעם אחת אחרי הכניסה כדי למשוך תשומת לב
    // בלי להישאר מטריד.
    if (suggestion.urgency == 'critical') {
      animated = animated.animate().shake(
            delay: 800.ms,
            duration: 600.ms,
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
      messenger
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(AppStrings.suggestionsToday.noActiveLists),
          backgroundColor: brand?.stickyOrange ?? kStickyOrange,
        ));
      if (mounted) setState(() => _isAdding = false);
      return;
    }

    // If multiple active lists — same picker as single-add for consistency.
    ShoppingList targetList;
    if (activeLists.length == 1) {
      targetList = activeLists.first;
    } else {
      final chosen = await _chooseTargetList(context, activeLists);
      if (chosen == null) {
        if (mounted) setState(() => _isAdding = false);
        return;
      }
      targetList = chosen;
    }
    if (!mounted) return;
    int added = 0;

    for (final suggestion in widget.suggestions) {
      try {
        final item = suggestion.toUnifiedListItem();
        await listsProvider.addUnifiedItem(targetList.id, item);
        await suggestionsProvider.addSuggestionById(suggestion.id, targetList.id);
        added++;
      } catch (e) {
        if (kDebugMode) debugPrint('⚠️ AddAll: failed to add ${suggestion.productName}: $e');
      }
    }

    if (!mounted) return;
    setState(() => _isAdding = false);

    // If every add failed, surface that as an error rather than a green
    // "0 items added" success.
    if (added == 0) {
      messenger
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(AppStrings.suggestionsToday.addAllFailed),
          backgroundColor: brand?.stickyPink ?? kStickyPink,
        ));
      return;
    }

    unawaited(HapticFeedback.mediumImpact());
    messenger
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Theme.of(context).colorScheme.onPrimary, size: kIconSizeSmallPlus),
            const SizedBox(width: kSpacingSmall),
            Text(AppStrings.suggestionsToday.addedAll(added, targetList.name)),
          ],
        ),
        backgroundColor: brand?.stickyGreen ?? kStickyGreen,
      ));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Filled primary button — "+ הוסף הכל" is the positive action that
    // commits the whole carousel into a list, so the visual treatment
    // matches its intent. The earlier OutlinedButton with orange border
    // on a light surface read as a destructive/cancel button instead of
    // a constructive CTA.
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isAdding ? null : _addAll,
        icon: _isAdding
            ? SizedBox(
                width: kIconSizeSmall,
                height: kIconSizeSmall,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cs.onPrimary,
                ),
              )
            : const Icon(Icons.playlist_add, size: kIconSizeSmallPlus),
        label: Text(
          AppStrings.suggestionsToday.addAll,
          style: const TextStyle(
            fontSize: kFontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: kSpacingSmall),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
        ),
      ),
    );
  }
}
