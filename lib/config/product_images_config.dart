// 📄 lib/config/product_images_config.dart
//
// Purpose: Image URL generation for products using Rami Levy CDN
//
// Provides product image URLs from the Rami Levy online store.
// Uses a URL pattern based on barcode.
// Falls back to a static URL map if available.
//
// Version: 2.0
// Last Updated: 09/04/2026

import 'product_image_urls.dart';

/// Product image URL helper using Rami Levy product images
class ProductImagesConfig {
  ProductImagesConfig._();

  /// Credit source name
  static const String creditSource = 'רמי לוי';

  /// Credit URL
  static const String creditUrl = 'https://www.rami-levy.co.il';

  /// Generate product image URL from barcode.
  /// First checks the static URL map, then falls back to URL pattern.
  /// Returns null if barcode is invalid or too short.
  static String? getImageUrl(String? barcode) {
    if (barcode == null || barcode.length < 7) return null;

    // Check static map first (most reliable)
    final staticUrl = productImageUrls[barcode];
    if (staticUrl != null) return staticUrl;

    // Fallback: Rami Levy URL pattern
    return 'https://www.rami-levy.co.il/product/$barcode/small.jpg';
  }
}
