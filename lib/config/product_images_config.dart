// 📄 lib/config/product_images_config.dart
//
// Purpose: Image URL generation for products using multiple CDN sources
//
// Sources (in priority order):
//   1. Rami Levy CDN: https://img.rami-levy.co.il/product/{barcode}/small.jpg
//   2. Shufersal Cloudinary: https://res.cloudinary.com/shufersal/image/upload/...
//
// Version: 5.0
// Last Updated: 10/04/2026

/// Product image URL helper with multi-source fallback
class ProductImagesConfig {
  ProductImagesConfig._();

  /// Rami Levy CDN base URL
  static const String _ramiLevyCdnBase = 'https://img.rami-levy.co.il/product';

  /// Shufersal Cloudinary base URL
  static const String _shufersalCdnBase =
      'https://res.cloudinary.com/shufersal/image/upload/f_auto,q_auto,w_200/v1/products/products_zoomed';

  /// Generate all available image URLs for a barcode (primary first).
  /// Returns empty list if barcode is invalid.
  static List<String> getImageUrls(String? barcode) {
    if (barcode == null || barcode.length < 7) return const [];
    return [
      '$_ramiLevyCdnBase/$barcode/small.jpg',
      '$_shufersalCdnBase/$barcode',
    ];
  }

  /// Generate primary image URL from barcode (Rami Levy).
  /// Returns null if barcode is invalid or too short.
  static String? getImageUrl(String? barcode) {
    if (barcode == null || barcode.length < 7) return null;
    return '$_ramiLevyCdnBase/$barcode/small.jpg';
  }
}
