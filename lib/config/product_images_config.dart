// 📄 lib/config/product_images_config.dart
//
// Purpose: Image URL generation for products using multiple CDN sources
//
// Sources (in priority order):
//   1. Rami Levy CDN: https://img.rami-levy.co.il/product/{barcode}/small.jpg
//   2. Shufersal Cloudinary: https://res.cloudinary.com/shufersal/image/upload/...
//   3. Open Food Facts (global free DB): https://images.openfoodfacts.org/...
//
// Version: 6.0
// Last Updated: 10/04/2026

/// Product image URL helper with multi-source fallback
class ProductImagesConfig {
  ProductImagesConfig._();

  /// Rami Levy CDN base URL
  static const String _ramiLevyCdnBase = 'https://img.rami-levy.co.il/product';

  /// Shufersal Cloudinary base URL
  static const String _shufersalCdnBase =
      'https://res.cloudinary.com/shufersal/image/upload/f_auto,q_auto,w_200/v1/products/products_zoomed';

  /// Open Food Facts image base URL (global free product DB)
  /// URL format requires barcode split into groups: e.g.
  /// 7290116537849 → 729/011/653/7849
  static const String _openFoodFactsBase =
      'https://images.openfoodfacts.org/images/products';

  /// Valid barcode lengths (EAN-8, UPC-A, EAN-13)
  /// Other lengths (7, 9, 11, etc.) are usually internal codes that
  /// don't have CDN images.
  static const Set<int> _validBarcodeLengths = {8, 12, 13};

  /// Generate all available image URLs for a barcode (primary first).
  /// Returns empty list if barcode is invalid or has unsupported length.
  static List<String> getImageUrls(String? barcode) {
    if (barcode == null || !_validBarcodeLengths.contains(barcode.length)) {
      return const [];
    }
    return [
      '$_ramiLevyCdnBase/$barcode/small.jpg',
      '$_shufersalCdnBase/$barcode',
      _openFoodFactsUrl(barcode),
    ];
  }

  /// Generate primary image URL from barcode (Rami Levy).
  /// Returns null if barcode is invalid or unsupported length.
  static String? getImageUrl(String? barcode) {
    if (barcode == null || !_validBarcodeLengths.contains(barcode.length)) {
      return null;
    }
    return '$_ramiLevyCdnBase/$barcode/small.jpg';
  }

  /// Build Open Food Facts image URL from a barcode.
  /// Open Food Facts uses a directory structure: groups of 3 digits.
  /// For 13-digit EAN: AAA/BBB/CCC/DDDD
  /// For 12-digit UPC-A: it's converted to EAN-13 with leading 0.
  static String _openFoodFactsUrl(String barcode) {
    // Convert UPC-A (12) to EAN-13 by prepending '0'
    final ean13 = barcode.length == 12 ? '0$barcode' : barcode;

    if (ean13.length == 13) {
      // 13-digit: AAA/BBB/CCC/DDDD
      final p1 = ean13.substring(0, 3);
      final p2 = ean13.substring(3, 6);
      final p3 = ean13.substring(6, 9);
      final p4 = ean13.substring(9);
      return '$_openFoodFactsBase/$p1/$p2/$p3/$p4/front_he.200.jpg';
    } else {
      // 8-digit EAN-8: just the code
      return '$_openFoodFactsBase/$ean13/front_he.200.jpg';
    }
  }
}
