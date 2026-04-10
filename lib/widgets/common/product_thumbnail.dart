// 📄 lib/widgets/common/product_thumbnail.dart
//
// 🎯 Shared product thumbnail widget with CDN image + emoji fallback
//    Uses CachedNetworkImage for disk caching (offline support)
//
// 🔗 Used by: my_pantry_screen, shopping_list_details_screen,
//    active_shopping_item_tile
//
// Version: 1.0
// Last Updated: 10/04/2026

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../config/filters_config.dart';
import '../../config/product_images_config.dart';
import '../../core/ui_constants.dart';

/// Cached set of URLs that failed to load (shared across all instances)
final Set<String> _failedImageUrls = {};

/// Product thumbnail with CDN image and emoji fallback.
///
/// Shows product image from Rami Levy CDN when barcode is available,
/// falls back to category emoji otherwise. Images are cached on disk.
class ProductThumbnail extends StatelessWidget {
  /// Product barcode for CDN image lookup
  final String? barcode;

  /// Category key (Hebrew or English) for emoji fallback
  final String category;

  /// Size of the thumbnail container
  final double size;

  /// Optional background tint color (e.g., status color)
  final Color? tintColor;

  const ProductThumbnail({
    super.key,
    this.barcode,
    required this.category,
    this.size = kIconSizeXLarge,
    this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final imageUrl = ProductImagesConfig.getImageUrl(barcode);
    final hasImage =
        imageUrl != null && !_failedImageUrls.contains(imageUrl);

    if (!hasImage) {
      return _buildEmojiCircle(cs);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (_, __) => Center(child: _emojiText),
        errorWidget: (_, __, ___) {
          _failedImageUrls.add(imageUrl);
          return Center(child: _emojiText);
        },
      ),
    );
  }

  Widget _buildEmojiCircle(ColorScheme cs) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: (tintColor ?? cs.primaryContainer).withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(child: _emojiText),
    );
  }

  Text get _emojiText {
    final englishKey = FiltersConfig.hebrewCategoryToEnglish(category);
    final emoji = FiltersConfig.getCategoryEmoji(englishKey);
    return Text(
      emoji,
      style: TextStyle(fontSize: size * 0.45),
    );
  }
}
