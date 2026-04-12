// 📄 lib/widgets/common/product_thumbnail.dart
//
// 🎯 Shared product thumbnail widget with multi-source CDN image + emoji fallback
//    Uses CachedNetworkImage for disk caching (offline support)
//    Fallback chain: Rami Levy → Shufersal → category emoji
//
// 🔗 Used by: my_pantry_screen, shopping_list_details_screen,
//    active_shopping_item_tile, checklist_screen, who_brings_screen,
//    suggestions_today_card
//
// Version: 2.0
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
/// Shows product image from multiple CDN sources (Rami Levy → Shufersal)
/// when barcode is available, falls back to category emoji otherwise.
/// Images are cached on disk via CachedNetworkImage.
class ProductThumbnail extends StatelessWidget {
  /// Product barcode for CDN image lookup
  final String? barcode;

  /// Category key (Hebrew or English) for emoji fallback
  final String category;

  /// Optional product name — when provided, the emoji fallback uses
  /// keyword matching for a more specific icon (🧅 onion instead of
  /// generic 🥬 vegetable). Falls back to category emoji if no
  /// keyword matches.
  final String? productName;

  /// Size of the thumbnail container
  final double size;

  /// Optional background tint color (e.g., status color)
  final Color? tintColor;

  const ProductThumbnail({
    super.key,
    this.barcode,
    required this.category,
    this.productName,
    this.size = kIconSizeXLarge,
    this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final imageUrls = ProductImagesConfig.getImageUrls(barcode);

    // Filter out known-failed URLs
    final validUrls =
        imageUrls.where((url) => !_failedImageUrls.contains(url)).toList();

    if (validUrls.isEmpty) {
      return _buildEmojiCircle(cs);
    }

    return _FallbackImage(
      urls: validUrls,
      size: size,
      tintColor: tintColor,
      emojiBuilder: () => _buildEmojiCircle(cs),
      containerBuilder: (child) => Container(
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
        child: child,
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
    // Try product-specific emoji first (keyword match on Hebrew name)
    final specificEmoji = matchProductEmoji(productName);
    if (specificEmoji != null) {
      return Text(specificEmoji, style: TextStyle(fontSize: size * 0.45));
    }
    // Fall back to generic category emoji
    final englishKey = FiltersConfig.hebrewCategoryToEnglish(category);
    final emoji = FiltersConfig.getCategoryEmoji(englishKey);
    return Text(emoji, style: TextStyle(fontSize: size * 0.45));
  }

  /// Keyword → emoji mapping for common Israeli products.
  /// Matches the FIRST keyword found in the product name.
  /// Returns null if no keyword matches → caller uses category emoji.
  ///
  /// Public so other widgets (e.g., product_selection_bottom_sheet) can
  /// use the same mapping without going through the full Thumbnail widget.
  static String? matchProductEmoji(String? name) {
    if (name == null || name.isEmpty) return null;

    // Ordered: longer/more-specific keywords first to avoid false matches.
    // e.g., "תפוח אדמה" before "תפוח" so potatoes don't get 🍎.
    const mapping = <String, String>{
      // Vegetables
      'תפוח אדמה': '🥔', 'תפו"א': '🥔',
      'ברוקולי': '🥦', 'כרובית': '🥦',
      'בצל': '🧅', 'שום': '🧄',
      'גזר': '🥕', 'מלפפון': '🥒',
      'עגבני': '🍅', 'חסה': '🥬',
      'כרוב': '🥬', 'פלפל': '🌶️',
      'אבוקדו': '🥑', 'חציל': '🍆',
      'תירס': '🌽', 'פטריו': '🍄',
      'זנגביל': '🫚', 'קישוא': '🥒',
      'סלק': '🫒', 'דלעת': '🎃',
      // Fruits
      'תפוז': '🍊', 'קלמנטינ': '🍊',
      'לימון': '🍋', 'בננה': '🍌',
      'תפוח': '🍎', 'ענבי': '🍇',
      'אבטיח': '🍉', 'מלון': '🍈',
      'אננס': '🍍', 'מנגו': '🥭',
      'אגס': '🍐', 'שזיף': '🫐',
      'דובדבן': '🍒', 'תות': '🍓',
      'אפרסק': '🍑', 'נקטרינ': '🍑',
      'רימון': '🫒', 'קיווי': '🥝',
      // Dairy
      'חלב': '🥛', 'גבינ': '🧀',
      'יוגורט': '🥛', 'שמנת': '🥛',
      'ביצ': '🥚',
      // Bakery
      'לחם': '🍞', 'חלה': '🍞',
      'פיתה': '🫓', 'באגט': '🥖',
      'לחמני': '🍞', 'קרואסון': '🥐',
      // Meat & Fish
      'עוף': '🍗', 'חזה': '🍗',
      'שניצל': '🍗', 'בשר': '🥩',
      'המבורגר': '🍔', 'נקניק': '🌭',
      'דג': '🐟', 'סלמון': '🐟',
      'טונה': '🐟',
      // Grains & Pasta
      'אורז': '🍚', 'פסטה': '🍝',
      'אטריות': '🍝', 'גריסים': '🍚',
      'קוסקוס': '🍚', 'בורגול': '🍚',
      // Drinks
      'מים': '💧', 'מיץ': '🧃',
      'קולה': '🥤', 'סודה': '🥤',
      'בירה': '🍺', 'יין': '🍷',
      'קפה': '☕', 'תה ': '🍵',
      // Snacks
      'שוקולד': '🍫', 'במבה': '🥜',
      'חטיף': '🍬', 'ביסקוויט': '🍪',
      'עוגיו': '🍪', 'גלידה': '🍦',
      // Cleaning & Hygiene
      'סבון': '🧴', 'שמפו': '🧴',
      'נייר טואלט': '🧻', 'כביסה': '🧺',
      'משחת שיני': '🪥',
    };

    for (final entry in mapping.entries) {
      if (name.contains(entry.key)) return entry.value;
    }
    return null;
  }
}

/// Internal stateful widget that tries URLs in sequence until one works
class _FallbackImage extends StatefulWidget {
  final List<String> urls;
  final double size;
  final Color? tintColor;
  final Widget Function() emojiBuilder;
  final Widget Function(Widget child) containerBuilder;

  const _FallbackImage({
    required this.urls,
    required this.size,
    required this.tintColor,
    required this.emojiBuilder,
    required this.containerBuilder,
  });

  @override
  State<_FallbackImage> createState() => _FallbackImageState();
}

class _FallbackImageState extends State<_FallbackImage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= widget.urls.length) {
      return widget.emojiBuilder();
    }

    final url = widget.urls[_currentIndex];

    return widget.containerBuilder(
      CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (_, __) => Center(
          child: widget.emojiBuilder(),
        ),
        errorWidget: (_, __, ___) {
          _failedImageUrls.add(url);
          // Try next URL
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _currentIndex++);
            }
          });
          return Center(child: widget.emojiBuilder());
        },
      ),
    );
  }
}
