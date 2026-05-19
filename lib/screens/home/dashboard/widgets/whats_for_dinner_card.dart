// lib/screens/home/dashboard/widgets/whats_for_dinner_card.dart — "What's for dinner" — Google recipe search using current pantry items

import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/filters_data.dart';
import '../../../../core/ui_constants.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../models/inventory_item.dart';
import '../../../../providers/inventory_provider.dart';
import '../../../../providers/user_context.dart';
import '../../../../theme/app_theme.dart';
import '../../../../utils/ingredient_cleaner.dart';

// Hide the card unless the pantry has at least this many items — a
// "recipe with eggs and salt" query is too thin to be useful.
const int _kMinPantryItemsForSearch = 3;

// Number of pantry items pushed into the Google search query. Above ~5
// the query gets over-specific (fewer results); below 3 under-specific.
const int _kSearchItemsCount = 5;

// Sticky-note styling consistent with the home screen's other cards.
const double _kCardRotation = -0.005;
const double _kCardShadowBlur = 4.0;
const Offset _kCardShadowOffset = Offset(1, 2);

/// 🍲 "What's for dinner?" — Google search using the user's pantry items.
///
/// Why a Google search and not a recipe API:
/// A research pass (see REVIEW_BACKLOG 17/5/2026) confirmed no free
/// Hebrew recipe API exists. Spoonacular / Edamam / TheMealDB all serve
/// English-only Western recipes and would require an extra translation
/// step plus cultural mismatch (Tortilla, BBQ, Mac & Cheese — not what
/// the average Israeli user cooks). Bundling a local recipe DB is a
/// content-engineering product on its own.
///
/// Google's own search results page indexes Mako / Walla / Ynet /
/// Hashulchan recipes in Hebrew, for free, with cultural relevance —
/// so the card hands the query off to the user's browser and lets
/// Google do the matching work.
class WhatsForDinnerCard extends StatelessWidget {
  const WhatsForDinnerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.select<UserContext, bool>((u) => u.isLoggedIn);
    if (!isLoggedIn) return const SizedBox.shrink();

    final inventoryProvider = context.watch<InventoryProvider>();
    // Two-layer food filter:
    //  1. Category must be edible (handles Hebrew labels via synonyms).
    //  2. Product name must not contain a non-food hint — defensive
    //     because the supermarket catalog has observable mis-categorizations
    //     (e.g. "בגד ים חליפה בנות" tagged as "מוצרי חלב" — confirmed in
    //     assets/data/list_types/supermarket.json). Category alone is
    //     not a trustworthy signal of "this is food".
    final pantryItems = inventoryProvider.items
        .where((i) => i.quantity > 0)
        .where((i) => CategoriesData.isFoodCategory(i.category))
        .where((i) => !CategoriesData.looksLikeNonFood(i.productName))
        .toList();

    if (pantryItems.length < _kMinPantryItemsForSearch) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final strings = AppStrings.whatsForDinner;
    final stickyColor = brand?.stickyOrange ?? kStickyOrange;

    // First N items by insertion order — pantry items are typically
    // sorted by recency, so this nudges toward "what you just bought"
    // rather than long-dormant staples.
    final selectedItems = pantryItems.take(_kSearchItemsCount).toList();
    // Both the preview and the Google query use cleaned ingredient names
    // — "חלב תנובה 3% 1 ליטר" → "חלב". The verbose raw names dilute the
    // recipe search with brand/size/percentage noise.
    final cleanedNames =
        selectedItems.map((i) => cleanIngredientName(i.productName)).toList();
    final previewText = cleanedNames.join(' · ');

    return Transform.rotate(
      angle: _kCardRotation,
      child: Container(
        margin: const EdgeInsets.only(bottom: kSpacingSmall),
        padding: const EdgeInsets.symmetric(
          horizontal: kSpacingMedium,
          vertical: kSpacingSmallPlus,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [
              stickyColor.withValues(alpha: kOpacitySoft),
              stickyColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
          border: Border.all(
            color: stickyColor.withValues(alpha: kOpacityLight),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: kOpacitySubtle),
              blurRadius: _kCardShadowBlur,
              offset: _kCardShadowOffset,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ExcludeSemantics(
                  child: Text('🍲', style: TextStyle(fontSize: kFontSizeLarge)),
                ),
                const SizedBox(width: kSpacingSmall),
                Expanded(
                  child: Text(
                    strings.title,
                    style: TextStyle(
                      fontSize: kFontSizeBody,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: kSpacingXTiny),
            Text(
              // fixBidiNumbers covers product names that mix Hebrew + Latin
              // (e.g. "Coca Cola 1.5 ל"); digits in the joined preview
              // would otherwise mirror in RTL.
              fixBidiNumbers(strings.preview(previewText)),
              style: TextStyle(
                fontSize: kFontSizeSmall,
                color: cs.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: kSpacingSmall),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: ElevatedButton.icon(
                onPressed: () => _searchRecipes(context, selectedItems),
                icon: const Icon(Icons.open_in_new, size: kIconSizeSmall),
                label: Text(strings.searchButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: brand?.accent ?? cs.primary,
                  foregroundColor: cs.onSurface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSpacingMedium,
                    vertical: kSpacingSmall,
                  ),
                  minimumSize: const Size(0, kMinTapTarget),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchRecipes(
    BuildContext context,
    List<InventoryItem> items,
  ) async {
    unawaited(HapticFeedback.lightImpact());
    final strings = AppStrings.whatsForDinner;
    // Capture messenger before the async gap so we don't read context
    // post-await (browser launch can be slow on cold platforms).
    final messenger = ScaffoldMessenger.of(context);
    // Same cleaning as the preview — "חלב תנובה 3%" → "חלב" so Google
    // surfaces recipes, not Tnuva store listings.
    final ingredientList =
        items.map((i) => cleanIngredientName(i.productName)).join(' ');
    final query = '${strings.searchPrefix} $ingredientList';
    final url = Uri.https('www.google.com', '/search', {'q': query});

    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        messenger
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(strings.errorFallback)));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ WhatsForDinner: launchUrl failed: $e');
      }
      messenger
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(strings.errorFallback)));
    }
  }
}
